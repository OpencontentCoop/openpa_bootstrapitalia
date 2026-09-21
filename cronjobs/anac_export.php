<?php

/**
 * Rigenera gli export ANAC (Amministrazione Trasparente) i cui dati sorgente
 * sono cambiati dall'ultima esecuzione. Registrato sotto [CronjobPart-changesection]
 * (vedi settings/cronjob.ini.append.php): gruppo con semantica non pertinente
 * ma gia' schedulato su tutti i tenant SaaS, scelta per non aggiungere un nuovo
 * gruppo cron con relativo costo infrastrutturale - vedi classes/anac/CLAUDE.md.
 *
 * Un fallimento su uno schema non deve bloccare gli altri: ogni schema e'
 * avvolto nel proprio try/catch (vedi classes/anac/CLAUDE.md, sezione
 * "Gestione errori" - tutto-o-niente PER SCHEMA, non per l'intero cron).
 */

/**
 * Il cron gira 2 volte al giorno sul gruppo `changesection`, condiviso con
 * tutti i tenant SaaS: la maggior parte non ha ancora questa trasparenza
 * attiva. Uscita immediata prima di qualunque scan PHP se il sito non ha
 * nessuno schema ANAC configurato - evita di pagare comunque il costo di
 * fetchAllBindings() (uno scan completo della classe pagina_trasparenza) su
 * quei siti.
 *
 * Nota: l'art.4-bis NON dipende da schema_pubblicazione (vedi publishArt4Bis
 * e SchemaPubblicazioneLookup) - e' ancorato al dataset 'dati_sui_pagamenti'
 * per remote_id, indipendentemente dalle pagine trasparenza. Un sito puo'
 * avere l'art.4-bis attivo senza aver ancora configurato schema_pubblicazione
 * su nessuna pagina: la condizione di uscita deve quindi controllare
 * ENTRAMBE le fonti, non solo l'attributo.
 */
function hasAnyAnacExportActive()
{
    $db = eZDB::instance();

    $attributeRow = $db->arrayQuery(
        "SELECT ca.id FROM ezcontentclass_attribute ca
         JOIN ezcontentclass c ON c.id = ca.contentclass_id
         WHERE c.identifier = 'pagina_trasparenza' AND ca.identifier = 'schema_pubblicazione'
         LIMIT 1"
    );
    if (!empty($attributeRow)) {
        $attributeId = $attributeRow[0]['id'];
        $valueRow = $db->arrayQuery(
            "SELECT 1 FROM ezcontentobject_attribute
             WHERE contentclassattribute_id = " . (int)$attributeId . "
             AND data_text IS NOT NULL AND data_text != '' AND data_text != '0'
             LIMIT 1"
        );
        if (!empty($valueRow)) {
            return true;
        }
    }

    return eZContentObject::fetchByRemoteID('dati_sui_pagamenti') instanceof eZContentObject;
}

if (!hasAnyAnacExportActive()) {
    $cli->notice('anac_export: nessuno schema ANAC attivo su questo sito, uscita immediata');

    return;
}

/**
 * Un solo scan di `pagina_trasparenza` per tutti gli schemi insieme (vedi
 * SchemaPubblicazioneLookup) - condiviso da publishArt13()/publishArt31(),
 * cosi' non lo si ripete due volte nella stessa esecuzione del cron.
 */
$schemaBindings = \SchemaPubblicazioneLookup::fetchAllBindings();

publishArt4Bis($cli, $schemaBindings);
publishArt13($cli, $schemaBindings);
publishArt31($cli, $schemaBindings);

/**
 * OIV e Organi di revisione non hanno un dataset dedicato: sono documenti
 * (classe `document`) taggati con `anac_document_type` (vedi
 * installer/modules/trasparenza/CLAUDE.md), pubblicati come figli delle
 * rispettive pagine trasparenza. Corte dei conti invece e' un dataset reale,
 * stesso pattern di art.4-bis - per questo il suo nodo si risolve ancora dal
 * remote_id del dataset (`corte_dei_conti`), non da `schema_pubblicazione`
 * (la classe `dataset` non ha quell'attributo, vedi
 * SchemaPubblicazioneLookup). Il JSON "file unico" (copre tutte e tre le
 * sottosezioni insieme) e' ospitato sotto "Controlli e rilievi
 * sull'amministrazione", il genitore reale di tutte e tre le pagine di
 * trasparenza dell'art. 31 - verificato con Marco il 2026-09-15, vedi
 * classes/anac/CLAUDE.md.
 */
function publishArt31(eZCLI $cli, array $schemaBindings)
{
    try {
        // Nessuna guardia di tipologia: a differenza dell'art.13, Art31Serializer
        // non forka mai l'output per C1/C2 (stessi CSV/JSON, nessun isC1) - il
        // binding reale su $schemaBindings sotto e' gia' l'unica fonte di verita'
        // su quale pagina (C1 o C2, quale che sia installata) ancora questi export.
        $corteDeiContiObject = eZContentObject::fetchByRemoteID('corte_dei_conti');
        if (!$corteDeiContiObject instanceof eZContentObject) {
            $cli->warning("anac_export: oggetto dataset 'corte_dei_conti' non trovato, schema art.31 saltato (modulo trasparenza-c1 non installato su questo sito?)");

            return;
        }

        $corteDataMap = $corteDeiContiObject->attribute('data_map');
        if (!isset($corteDataMap['csv_resource'])) {
            $cli->error("anac_export: attributo 'csv_resource' non trovato sul dataset Corte dei conti (id {$corteDeiContiObject->attribute('id')}), schema art.31 saltato");

            return;
        }

        $oivPageObject = isset($schemaBindings['art.31-oiv']) ? $schemaBindings['art.31-oiv'] : null;
        $orPageObject = isset($schemaBindings['art.31-or']) ? $schemaBindings['art.31-or'] : null;
        $controlliERilieviPage = isset($schemaBindings['art.31']) ? $schemaBindings['art.31'] : null;
        if (!$oivPageObject instanceof eZContentObject || !$orPageObject instanceof eZContentObject || !$controlliERilieviPage instanceof eZContentObject) {
            $cli->warning('anac_export: nessuna pagina con schema_pubblicazione = art.31-oiv/art.31-or/art.31, schema art.31 saltato (modulo trasparenza-c1 non installato o non aggiornato su questo sito?)');

            return;
        }

        $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer($corteDataMap['csv_resource']);

        $oivDocuments = $serializer->fetchDocumentsByKeys(\OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::OIV_KEYS);
        $orDocuments = $serializer->fetchDocumentsByKeys(\OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::OR_KEYS);

        $oivIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::SCHEMA_IDENTIFIER_OIV;
        $oivPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($oivIdentifier, $oivPageObject->attribute('main_node')->attribute('node_id'));
        $oivTracking = $oivPublisher->publishSingle($serializer->toCsvOiv($oivDocuments), 'csv');
        $cli->notice("anac_export: schema {$oivIdentifier} ok, ultima modifica {$oivTracking['dataUltimaModifica']}");

        $orIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::SCHEMA_IDENTIFIER_OR;
        $orPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($orIdentifier, $orPageObject->attribute('main_node')->attribute('node_id'));
        $orTracking = $orPublisher->publishSingle($serializer->toCsvOr($orDocuments), 'csv');
        $cli->notice("anac_export: schema {$orIdentifier} ok, ultima modifica {$orTracking['dataUltimaModifica']}");

        $ocIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::SCHEMA_IDENTIFIER_OC;
        // Stesso principio di publishArt4Bis(): preferisce la pagina di
        // trasparenza reale (schema_pubblicazione = art.31-oc, se
        // configurata) come ancoraggio url invece del nodo tecnico del
        // dataset - fallback al dataset per i tenant senza quel binding.
        $ocPageObject = isset($schemaBindings[$ocIdentifier]) ? $schemaBindings[$ocIdentifier] : null;
        $ocRootNodeId = $ocPageObject instanceof eZContentObject
            ? $ocPageObject->attribute('main_node')->attribute('node_id')
            : $corteDeiContiObject->attribute('main_node')->attribute('node_id');
        $ocPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($ocIdentifier, $ocRootNodeId);
        $ocTracking = $ocPublisher->publishSingle($serializer->toCsvOc(), 'csv');
        $cli->notice("anac_export: schema {$ocIdentifier} ok, ultima modifica {$ocTracking['dataUltimaModifica']}");

        $jsonIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::SCHEMA_IDENTIFIER_JSON;
        $rilievi = $serializer->getRilieviCorteDeiConti();
        $jsonHashSource = json_encode([
            $serializer->getAttiOrganiDiValutazione($oivDocuments),
            $serializer->getAttiOrganiDiRevisione($orDocuments),
            $rilievi,
        ]);
        $jsonPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($jsonIdentifier, $controlliERilieviPage->attribute('main_node')->attribute('node_id'));
        $jsonTracking = $jsonPublisher->publishWithDates(
            $jsonHashSource,
            function ($dataPrimaPubblicazione, $dataUltimaModifica) use ($serializer, $oivDocuments, $orDocuments) {
                return $serializer->toJson($dataPrimaPubblicazione, $dataUltimaModifica, $oivDocuments, $orDocuments);
            },
            'json'
        );
        $cli->notice("anac_export: schema {$jsonIdentifier} ok, ultima modifica {$jsonTracking['dataUltimaModifica']}");
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: art.31');
        $cli->error('anac_export: schema art.31 fallito: ' . $e->getMessage());
    }
}

/**
 * art.13-as e art.13-op sono CSV a se stanti (nessun JSON gemello sotto lo
 * stesso identificativo); il JSON e' un "file unico" con un identificativo
 * proprio (art.13-pa per C1), che copre ambito soggettivo + organi insieme -
 * vedi Art13Serializer e classes/anac/CLAUDE.md.
 */
function publishArt13(eZCLI $cli, array $schemaBindings)
{
    try {
        // La tipologia si deriva da QUALE schema e' davvero agganciato a una
        // pagina reale (schema_pubblicazione), non da una fonte separata
        // (un ini o un'euristica sul modulo installato): le due potrebbero
        // disallinearsi (es. un fork mal configurato), il binding reale e'
        // l'unica fonte di verita' qui.
        //
        // Stesso meccanismo per C1 e C2 una volta noto l'identificativo:
        // fetchOrganiConUffici() individua gli organi per prefisso di path su
        // un id di tag fisso (Struttura politica/Struttura amministrativa),
        // non per nome - su un sito C2 (fork di un sito comunale) quella
        // tassonomia viene modificata a mano in fase di personalizzazione del
        // fork (tag comunali tolti, organi societari aggiunti come figli
        // della stessa radice), senza bisogno di alcuna differenza di codice.
        $opObject = isset($schemaBindings[\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OP])
            ? $schemaBindings[\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OP]
            : null;
        $oaObject = isset($schemaBindings[\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OA])
            ? $schemaBindings[\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OA]
            : null;

        if ($opObject instanceof eZContentObject) {
            $isC1 = true;
            $organiSchemaIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OP;
            $jsonSchemaIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_JSON_C1;
            $object = $opObject;
        } elseif ($oaObject instanceof eZContentObject) {
            $isC1 = false;
            $organiSchemaIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OA;
            $jsonSchemaIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_JSON_C2;
            $object = $oaObject;
        } else {
            $cli->warning('anac_export: nessuna pagina con schema_pubblicazione = art.13-op/art.13-oa, schema art.13 saltato (modulo trasparenza-c1/c2 non installato o non aggiornato su questo sito?)');

            return;
        }

        $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer();
        $rootNodeId = $object->attribute('main_node')->attribute('node_id');

        $asIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_AS;
        $asPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($asIdentifier, $rootNodeId);
        $asTracking = $asPublisher->publishSingle($serializer->toCsvAmbitoSoggettivo($isC1), 'csv');
        $cli->notice("anac_export: schema {$asIdentifier} ok, ultima modifica {$asTracking['dataUltimaModifica']}");

        $organi = $serializer->fetchOrganiConUffici();

        $organiPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($organiSchemaIdentifier, $rootNodeId);
        $organiTracking = $organiPublisher->publishSingle($serializer->toCsvOrganiUffici($organi), 'csv');
        $cli->notice("anac_export: schema {$organiSchemaIdentifier} ok, ultima modifica {$organiTracking['dataUltimaModifica']}");

        $jsonPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($jsonSchemaIdentifier, $rootNodeId);
        $jsonTracking = $jsonPublisher->publishWithDates(
            json_encode($organi),
            function ($dataPrimaPubblicazione, $dataUltimaModifica) use ($serializer, $organi, $isC1) {
                return $serializer->toJson($dataPrimaPubblicazione, $dataUltimaModifica, $organi, $isC1);
            },
            'json'
        );
        $cli->notice("anac_export: schema {$jsonSchemaIdentifier} ok, ultima modifica {$jsonTracking['dataUltimaModifica']}");
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: art.13');
        $cli->error('anac_export: schema art.13 fallito: ' . $e->getMessage());
    }
}

function publishArt4Bis(eZCLI $cli, array $schemaBindings)
{
    $identifier = \OpenPABootstrapItalia\Anac\Serializer\Art4BisSerializer::SCHEMA_IDENTIFIER;

    try {
        $object = eZContentObject::fetchByRemoteID('dati_sui_pagamenti');
        if (!$object instanceof eZContentObject) {
            $cli->warning("anac_export: oggetto dataset 'dati_sui_pagamenti' non trovato, schema {$identifier} saltato (modulo trasparenza-c1 non installato su questo sito?)");

            return;
        }

        $dataMap = $object->attribute('data_map');
        if (!isset($dataMap['csv_resource'])) {
            $cli->error("anac_export: attributo 'csv_resource' non trovato sull'oggetto dataset (id {$object->attribute('id')}), schema {$identifier} saltato");

            return;
        }

        $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art4BisSerializer($dataMap['csv_resource']);
        $csv = $serializer->toCsv();

        // Preferisce la pagina di trasparenza reale (schema_pubblicazione =
        // art.4-bis, se configurata - patch_content in trasparenza-c1) come
        // ancoraggio url, cosi' il file compare sotto l'albero di trasparenza
        // visibile al cittadino invece che sotto il nodo tecnico del dataset
        // (Documenti-e-dati/Dataset/...). Fallback al nodo del dataset stesso
        // per i tenant che non hanno ancora quel binding configurato (vedi
        // hasAnyAnacExportActive() sopra: l'art.4-bis puo' essere attivo senza
        // schema_pubblicazione su nessuna pagina).
        $pageObject = isset($schemaBindings[$identifier]) ? $schemaBindings[$identifier] : null;
        $rootNodeId = $pageObject instanceof eZContentObject
            ? $pageObject->attribute('main_node')->attribute('node_id')
            : $object->attribute('main_node')->attribute('node_id');

        $publisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($identifier, $rootNodeId);
        $tracking = $publisher->publish($csv, function ($dataPrimaPubblicazione, $dataUltimaModifica) use ($serializer) {
            return $serializer->toJson($dataPrimaPubblicazione, $dataUltimaModifica);
        });

        $cli->notice("anac_export: schema {$identifier} ok, ultima modifica {$tracking['dataUltimaModifica']}");
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: ' . $identifier);
        $cli->error("anac_export: schema {$identifier} fallito: " . $e->getMessage());
    }
}
