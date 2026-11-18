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
 * Interruttore esplicito (openpa.ini, [Trasparenza] EnableAnacExport,
 * default disabled): finche' non e' enabled su un tenant, nessun file di
 * export ANAC viene mai prodotto, a prescindere da schema_pubblicazione o
 * dal dataset 'dati_sui_pagamenti' - rollout controllato tenant per tenant.
 */
if (OpenPAINI::variable('Trasparenza', 'EnableAnacExport', 'disabled') !== 'enabled') {
    $cli->notice('anac_export: EnableAnacExport disabled su questo sito, uscita immediata');

    return;
}

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
/**
 * Centralizza la decisione se un fallimento vada segnalato ai redattori
 * (ExportErrorTracker::recordError(), banner frontend) o no: una
 * EmptyExportException su uno schema elencato in [Trasparenza]
 * HideExportErrors (openpa.ini) significa "nessun dato, non un errore di
 * validazione" - viene loggata ma non mostrata nel banner. Qualsiasi altro
 * errore (vocabolario malformato, eccezioni generiche) continua a essere
 * sempre segnalato, su tutti gli schemi - vedi commento ini.
 */
function recordAnacExportError(eZCLI $cli, \Exception $e, $failedIdentifier, eZContentObject $relatedObject = null)
{
    $hideExportErrors = (array)OpenPAINI::variable('Trasparenza', 'HideExportErrors', []);
    if ($e instanceof \OpenPABootstrapItalia\Anac\EmptyExportException && in_array($failedIdentifier, $hideExportErrors, true)) {
        $cli->notice("anac_export: schema {$failedIdentifier} vuoto (nessun dato), errore non segnalato nel banner (HideExportErrors): {$e->getMessage()}");

        return;
    }

    (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($failedIdentifier))->recordError($e->getMessage(), $relatedObject);
}

$schemaBindings = \SchemaPubblicazioneLookup::fetchAllBindings();

publishArt4Bis($cli, $schemaBindings);
publishArt13($cli, $schemaBindings);
publishArt31($cli, $schemaBindings);
publishArt12($cli, $schemaBindings);
publishArt36($cli, $schemaBindings);
publishArt20($cli, $schemaBindings);

/**
 * Rete di sicurezza per le pagine con rendering live (vedi
 * OpenPABootstrapItalia\Anac\LiveRenderingRegistry): invalidazione
 * incondizionata, indipendente dall'esito delle publish sopra - gira comunque
 * 2 volte al giorno su tutti i tenant SaaS (vedi docblock di testa), quindi
 * limita a poche ore la finestra di dati stantii nel caso raro in cui il
 * plugin di indicizzazione agganciato alla pubblicazione di organization/
 * time_indexed_role/online_contact_point non sia scattato (indicizzazione
 * asincrona in coda, disabilitata, ecc. - vedi
 * classes/indexplugins/index_live_rendering_cache_bust.php).
 */
\OpenPABootstrapItalia\Anac\LiveRenderingRegistry::clearAllCaches($schemaBindings);

/**
 * OIV e Organi di revisione non hanno un dataset dedicato: sono documenti
 * (classe `document`) taggati con `document_type`, ramo "Documenti di
 * rilievo dell'organismo di controllo" (vedi
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
    $succeeded = [];
    // schema ANAC => oggetto pagina che lo ancora, per invalidare la cache
    // di quella pagina da ExportErrorTracker::recordError()/clear() - vedi
    // docblock di ExportErrorTracker.
    $identifierObjects = [];

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

        $corteDataMap = $corteDeiContiObject->fetchDataMap(false, SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        if (!isset($corteDataMap['csv_resource'])) {
            $cli->error("anac_export: attributo 'csv_resource' non trovato sul dataset Corte dei conti (id {$corteDeiContiObject->attribute('id')}), schema art.31 saltato");

            return;
        }

        $oivPageObject = isset($schemaBindings['art.31-oiv']) ? $schemaBindings['art.31-oiv'] : null;
        $orPageObject = isset($schemaBindings['art.31-or']) ? $schemaBindings['art.31-or'] : null;
        if (!$oivPageObject instanceof eZContentObject || !$orPageObject instanceof eZContentObject) {
            $cli->warning('anac_export: nessuna pagina con schema_pubblicazione = art.31-oiv/art.31-or, schema art.31 saltato (modulo trasparenza-c1 non installato o non aggiornato su questo sito?)');

            return;
        }

        $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer($corteDataMap['csv_resource']);

        $oivDocuments = $serializer->fetchDocumentsByKeys(\OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::OIV_KEYS);
        $orDocuments = $serializer->fetchDocumentsByKeys(\OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::OR_KEYS);

        // Ogni sottosezione pubblica CSV+JSON insieme, con lo stesso
        // identificativo (quindi stesso naming file pubblico, nessun "file
        // unico" condiviso - corretto 2026-10-21, vedi docblock di classe).
        // publish() calcola l'hash sul solo CSV (non contiene date) e
        // costruisce il JSON via callback dopo aver risolto le date - stesso
        // principio di publishArt4Bis(). Il blocco JSON va omesso del tutto
        // (non un array vuoto) se non c'e' nessun dato valido per quella
        // sottosezione (schema ANAC: tutte opzionali a livello root) - per
        // questo la chiave 'json' non viene nemmeno aggiunta a $files quando
        // il blocco e' vuoto.
        $attiOiv = $serializer->getAttiOrganiDiValutazione($oivDocuments);
        $oivIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::SCHEMA_IDENTIFIER_OIV;
        $identifierObjects[$oivIdentifier] = $oivPageObject;
        $oivPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($oivIdentifier, $oivPageObject->attribute('main_node')->attribute('node_id'));
        $csvOiv = $serializer->toCsvOiv($oivDocuments);
        $oivTracking = $oivPublisher->publish($csvOiv, function ($first, $last) use ($serializer, $attiOiv) {
            return !empty($attiOiv) ? $serializer->toJsonOiv($first, $last, $attiOiv) : null;
        });
        $cli->notice("anac_export: schema {$oivIdentifier} ok, ultima modifica {$oivTracking['dataUltimaModifica']}");
        $succeeded[] = $oivIdentifier;
        (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($oivIdentifier))->clear($oivPageObject);

        $attiOr = $serializer->getAttiOrganiDiRevisione($orDocuments);
        $orIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::SCHEMA_IDENTIFIER_OR;
        $identifierObjects[$orIdentifier] = $orPageObject;
        $orPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($orIdentifier, $orPageObject->attribute('main_node')->attribute('node_id'));
        $csvOr = $serializer->toCsvOr($orDocuments);
        $orTracking = $orPublisher->publish($csvOr, function ($first, $last) use ($serializer, $attiOr) {
            return !empty($attiOr) ? $serializer->toJsonOr($first, $last, $attiOr) : null;
        });
        $cli->notice("anac_export: schema {$orIdentifier} ok, ultima modifica {$orTracking['dataUltimaModifica']}");
        $succeeded[] = $orIdentifier;
        (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($orIdentifier))->clear($orPageObject);

        $ccIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::SCHEMA_IDENTIFIER_CC;
        // Stesso principio di publishArt4Bis(): preferisce la pagina di
        // trasparenza reale (schema_pubblicazione = art.31-cc, se
        // configurata) come ancoraggio url invece del nodo tecnico del
        // dataset - fallback al dataset per i tenant senza quel binding.
        $ccPageObject = isset($schemaBindings[$ccIdentifier]) ? $schemaBindings[$ccIdentifier] : null;
        $ccRootObject = $ccPageObject instanceof eZContentObject ? $ccPageObject : $corteDeiContiObject;
        $identifierObjects[$ccIdentifier] = $ccRootObject;
        $ccRootNodeId = $ccRootObject->attribute('main_node')->attribute('node_id');
        $rilievi = $serializer->getRilieviCorteDeiConti();
        $ccPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($ccIdentifier, $ccRootNodeId);
        $csvCc = $serializer->toCsvCc();
        $ccTracking = $ccPublisher->publish($csvCc, function ($first, $last) use ($serializer, $rilievi) {
            return $rilievi !== null ? $serializer->toJsonCc($first, $last, $rilievi) : null;
        });
        $cli->notice("anac_export: schema {$ccIdentifier} ok, ultima modifica {$ccTracking['dataUltimaModifica']}");
        $succeeded[] = $ccIdentifier;
        (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($ccIdentifier))->clear($ccRootObject);
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: art.31');
        $cli->error('anac_export: schema art.31 fallito: ' . $e->getMessage());
        foreach (array_diff([
            \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::SCHEMA_IDENTIFIER_OIV,
            \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::SCHEMA_IDENTIFIER_OR,
            \OpenPABootstrapItalia\Anac\Serializer\Art31Serializer::SCHEMA_IDENTIFIER_CC,
        ], $succeeded) as $failedIdentifier) {
            $relatedObject = isset($identifierObjects[$failedIdentifier]) ? $identifierObjects[$failedIdentifier] : null;
            recordAnacExportError($cli, $e, $failedIdentifier, $relatedObject);
        }
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
    $ownedIdentifiers = [];
    $succeeded = [];
    $identifierObjects = [];

    try {
        // art.13-op (organi di indirizzo politico) e art.13-oa (organi di
        // amministrazione e gestione) NON sono un fork C1/C2 alternativo -
        // sono due categorie di organi che uno stesso ente (anche C1)
        // pubblica entrambe, se bindate (correzione 2026-09-22, vedi
        // classes/anac/CLAUDE.md, "Organi di amministrazione e gestione").
        // $isC1 resta derivato da QUALE schema e' davvero agganciato a una
        // pagina reale, non da una fonte separata: un ente ha organi di
        // indirizzo politico solo se e' una pubblica amministrazione - un
        // fork C2 puro (nessun organo politico) ha solo art.13-oa bindato.
        $opObject = isset($schemaBindings[\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OP])
            ? $schemaBindings[\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OP]
            : null;
        $oaObject = isset($schemaBindings[\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OA])
            ? $schemaBindings[\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OA]
            : null;

        if (!$opObject instanceof eZContentObject && !$oaObject instanceof eZContentObject) {
            $cli->warning('anac_export: nessuna pagina con schema_pubblicazione = art.13-op/art.13-oa, schema art.13 saltato (modulo trasparenza-c1/c2 non installato o non aggiornato su questo sito?)');

            return;
        }

        $isC1 = $opObject instanceof eZContentObject;
        $jsonSchemaIdentifier = $isC1
            ? \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_JSON_C1
            : \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_JSON_C2;

        $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer();

        // art.13-as condivide sempre la stessa pagina di art.13-op (o, se
        // assente, di art.13-oa) - vedi installer/trasparenza-c1/CLAUDE.md.
        $asRootObject = $isC1 ? $opObject : $oaObject;
        $asRootNodeId = $asRootObject->attribute('main_node')->attribute('node_id');

        $asIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_AS;
        $ownedIdentifiers[] = $asIdentifier;
        $identifierObjects[$asIdentifier] = $asRootObject;
        $asPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($asIdentifier, $asRootNodeId);
        $asTracking = $asPublisher->publishSingle($serializer->toCsvAmbitoSoggettivo($isC1), 'csv');
        $cli->notice("anac_export: schema {$asIdentifier} ok, ultima modifica {$asTracking['dataUltimaModifica']}");
        $succeeded[] = $asIdentifier;
        (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($asIdentifier))->clear($asRootObject);

        $organiPolitici = [];
        if ($opObject instanceof eZContentObject) {
            $organiPolitici = $serializer->fetchOrganiConUffici();
            $opIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OP;
            $ownedIdentifiers[] = $opIdentifier;
            $identifierObjects[$opIdentifier] = $opObject;
            $opRootNodeId = $opObject->attribute('main_node')->attribute('node_id');
            $opPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($opIdentifier, $opRootNodeId);
            $opTracking = $opPublisher->publishSingle($serializer->toCsvOrganiUffici($organiPolitici), 'csv');
            $cli->notice("anac_export: schema {$opIdentifier} ok, ultima modifica {$opTracking['dataUltimaModifica']}");
            $succeeded[] = $opIdentifier;
            (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($opIdentifier))->clear($opObject);
        }

        $organiAmministrativi = [];
        if ($oaObject instanceof eZContentObject) {
            $organiAmministrativi = $serializer->fetchOrganiAmministrativi();
            $oaIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OA;
            $ownedIdentifiers[] = $oaIdentifier;
            $identifierObjects[$oaIdentifier] = $oaObject;
            $oaRootNodeId = $oaObject->attribute('main_node')->attribute('node_id');
            $oaPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($oaIdentifier, $oaRootNodeId);
            $oaTracking = $oaPublisher->publishSingle($serializer->toCsvOrganiUffici($organiAmministrativi), 'csv');
            $cli->notice("anac_export: schema {$oaIdentifier} ok, ultima modifica {$oaTracking['dataUltimaModifica']}");
            $succeeded[] = $oaIdentifier;
            (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($oaIdentifier))->clear($oaObject);
        }

        $organi = array_merge($organiPolitici, $organiAmministrativi);

        // art.13-rif (Riferimenti e contatti): nessuna controparte nel JSON
        // per PA/Societa' ed Enti (esiste solo per Ordini e Collegi
        // professionali, non ancora coperti da nessun serializer) - vedi
        // CLAUDE.md, "Riferimenti e contatti". Export solo CSV.
        $rifObject = isset($schemaBindings[\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_RIF])
            ? $schemaBindings[\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_RIF]
            : null;
        if ($rifObject instanceof eZContentObject) {
            $rifIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_RIF;
            $ownedIdentifiers[] = $rifIdentifier;
            $identifierObjects[$rifIdentifier] = $rifObject;
            $riferimenti = $serializer->fetchRiferimentiContatti();
            $rifRootNodeId = $rifObject->attribute('main_node')->attribute('node_id');
            $rifPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($rifIdentifier, $rifRootNodeId);
            $rifTracking = $rifPublisher->publishSingle($serializer->toCsvRiferimenti($riferimenti), 'csv');
            $cli->notice("anac_export: schema {$rifIdentifier} ok, ultima modifica {$rifTracking['dataUltimaModifica']}");
            $succeeded[] = $rifIdentifier;
            (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($rifIdentifier))->clear($rifObject);
        }

        // L'organigramma (solo C1) va risolto una volta sola qui, non dentro
        // toJson(): deve entrare nell'hash insieme a $organi, altrimenti un
        // cambiamento del solo organigramma (nuovo documento pubblicato sotto
        // "Articolazione degli uffici", nessun cambiamento agli organi) non
        // farebbe mai scattare una nuova pubblicazione.
        $organigramma = $isC1 ? $serializer->fetchOrganigramma($asRootNodeId) : null;

        // Oltre al campo dentro il JSON, ANAC pubblica l'organigramma anche
        // come CSV a se' stante (verificato scaricando l'esempio reale,
        // vedi Art13Serializer::toCsvOrganigramma()) - nessun file se non e'
        // ancora stato pubblicato nessun documento (stesso principio "ometti
        // invece di pubblicare un dato mancante" gia' usato altrove).
        if ($organigramma !== null) {
            $orgIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_ORG;
            $ownedIdentifiers[] = $orgIdentifier;
            $identifierObjects[$orgIdentifier] = $asRootObject;
            $orgPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($orgIdentifier, $asRootNodeId);
            $orgTracking = $orgPublisher->publishSingle($serializer->toCsvOrganigramma($organigramma), 'csv');
            $cli->notice("anac_export: schema {$orgIdentifier} ok, ultima modifica {$orgTracking['dataUltimaModifica']}");
            $succeeded[] = $orgIdentifier;
            (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($orgIdentifier))->clear($asRootObject);
        }

        $ownedIdentifiers[] = $jsonSchemaIdentifier;
        $identifierObjects[$jsonSchemaIdentifier] = $asRootObject;
        $jsonPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($jsonSchemaIdentifier, $asRootNodeId);
        $jsonTracking = $jsonPublisher->publishWithDates(
            json_encode(['organi' => $organi, 'organigramma' => $organigramma]),
            function ($dataPrimaPubblicazione, $dataUltimaModifica) use ($serializer, $organi, $isC1, $organigramma) {
                return $serializer->toJson($dataPrimaPubblicazione, $dataUltimaModifica, $organi, $isC1, $organigramma);
            },
            'json'
        );
        $cli->notice("anac_export: schema {$jsonSchemaIdentifier} ok, ultima modifica {$jsonTracking['dataUltimaModifica']}");
        $succeeded[] = $jsonSchemaIdentifier;
        (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($jsonSchemaIdentifier))->clear($asRootObject);
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: art.13');
        $cli->error('anac_export: schema art.13 fallito: ' . $e->getMessage());
        foreach (array_diff($ownedIdentifiers, $succeeded) as $failedIdentifier) {
            $relatedObject = isset($identifierObjects[$failedIdentifier]) ? $identifierObjects[$failedIdentifier] : null;
            recordAnacExportError($cli, $e, $failedIdentifier, $relatedObject);
        }
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

        $dataMap = $object->fetchDataMap(false, SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
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
        $rootObject = $pageObject instanceof eZContentObject ? $pageObject : $object;
        $rootNodeId = $rootObject->attribute('main_node')->attribute('node_id');

        $publisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($identifier, $rootNodeId);
        $tracking = $publisher->publish($csv, function ($dataPrimaPubblicazione, $dataUltimaModifica) use ($serializer) {
            return $serializer->toJson($dataPrimaPubblicazione, $dataUltimaModifica);
        });

        $cli->notice("anac_export: schema {$identifier} ok, ultima modifica {$tracking['dataUltimaModifica']}");
        (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($identifier))->clear($rootObject);
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: ' . $identifier);
        $cli->error("anac_export: schema {$identifier} fallito: " . $e->getMessage());
        $relatedObject = isset($rootObject) ? $rootObject : (isset($object) ? $object : null);
        recordAnacExportError($cli, $e, $identifier, $relatedObject);
    }
}

/**
 * art.12 co.1-bis - Scadenzario obblighi amministrativi (cms#485), solo C1.
 * Stesso scheletro di publishArt4Bis() (dataset-anchored, preferenza pagina
 * reale con fallback al nodo dataset). Il JSON si pubblica SEMPRE (mai
 * omesso): lo schema reale ammette un oggetto vuoto valido quando il
 * dataset non ha righe - vedi Art12Serializer::toJsonPa1Bis().
 */
function publishArt12(eZCLI $cli, array $schemaBindings)
{
    $succeeded = [];

    try {
        $object = eZContentObject::fetchByRemoteID('scadenzario_obblighi_amministrativi');
        if (!$object instanceof eZContentObject) {
            // Caso NORMALE per la maggioranza dei tenant: schema opzionale,
            // modulo trasparenza-additional-anac-schemes non installato su questo sito.
            return;
        }

        $dataMap = $object->fetchDataMap(false, SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        if (!isset($dataMap['csv_resource'])) {
            $cli->error("anac_export: attributo 'csv_resource' non trovato sul dataset Scadenzario (id {$object->attribute('id')}), schema art.12 saltato");

            return;
        }

        $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art12Serializer($dataMap['csv_resource']);

        $csvIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art12Serializer::SCHEMA_IDENTIFIER_CSV;
        $pageObject = isset($schemaBindings[$csvIdentifier]) ? $schemaBindings[$csvIdentifier] : null;
        $rootObject = $pageObject instanceof eZContentObject ? $pageObject : $object;
        $rootNodeId = $rootObject->attribute('main_node')->attribute('node_id');

        $csvPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($csvIdentifier, $rootNodeId);
        $csvTracking = $csvPublisher->publishSingle($serializer->toCsvScadenz(), 'csv');
        $cli->notice("anac_export: schema {$csvIdentifier} ok, ultima modifica {$csvTracking['dataUltimaModifica']}");
        $succeeded[] = $csvIdentifier;
        (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($csvIdentifier))->clear($rootObject);

        // Il JSON si pubblica sempre, mai omesso: lo schema reale
        // (art.12-v1.0.schema.json) ammette "attiPubblicheAmministrazioni: {}"
        // come stato valido quando $scadenzario e' null - vedi
        // Art12Serializer::toJsonPa1Bis(). publishWithDates() non supporta
        // un contentBuilder che ritorna null (scriverebbe comunque un file
        // rotto): non serve qui, perche' il builder ritorna sempre un JSON
        // valido.
        $scadenzario = $serializer->getScadenzario();
        $jsonIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art12Serializer::SCHEMA_IDENTIFIER_JSON;
        $jsonPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($jsonIdentifier, $rootNodeId);
        $jsonTracking = $jsonPublisher->publishWithDates(
            json_encode($scadenzario),
            function ($first, $last) use ($serializer, $scadenzario) {
                return $serializer->toJsonPa1Bis($first, $last, $scadenzario);
            },
            'json'
        );
        $cli->notice("anac_export: schema {$jsonIdentifier} ok, ultima modifica {$jsonTracking['dataUltimaModifica']}");
        $succeeded[] = $jsonIdentifier;
        (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($jsonIdentifier))->clear($rootObject);
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: art.12');
        $cli->error('anac_export: schema art.12 fallito: ' . $e->getMessage());
        $relatedObject = isset($rootObject) ? $rootObject : (isset($object) ? $object : null);
        foreach (array_diff([
            \OpenPABootstrapItalia\Anac\Serializer\Art12Serializer::SCHEMA_IDENTIFIER_CSV,
            \OpenPABootstrapItalia\Anac\Serializer\Art12Serializer::SCHEMA_IDENTIFIER_JSON,
        ], $succeeded) as $failedIdentifier) {
            recordAnacExportError($cli, $e, $failedIdentifier, $relatedObject);
        }
    }
}

/**
 * art.36 - IBAN e pagamenti informatici (cms#488), C1 e C2. $isC1 si deriva
 * direttamente da quale dei due dataset (Task 3) esiste sul sito - non
 * serve controllare il nodo radice C1 separatamente, i due dataset hanno
 * remote_id distinti per profilo. Il JSON qui PUO' essere omesso (a
 * differenza di art.12): se il dataset non ha righe, getPagamenti() torna
 * null e il builder ritorna null a publish(), che lo supporta nativamente
 * (ometti json, pubblica comunque il CSV).
 */
function publishArt36(eZCLI $cli, array $schemaBindings)
{
    $succeeded = [];

    try {
        $objectC1 = eZContentObject::fetchByRemoteID('iban_pagamenti_informatici_c1');
        $objectC2 = eZContentObject::fetchByRemoteID('iban_pagamenti_informatici_c2');
        $isC1 = $objectC1 instanceof eZContentObject;
        $object = $isC1 ? $objectC1 : $objectC2;
        if (!$object instanceof eZContentObject) {
            return;
        }

        $dataMap = $object->fetchDataMap(false, SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        if (!isset($dataMap['csv_resource'])) {
            $cli->error("anac_export: attributo 'csv_resource' non trovato sul dataset IBAN e pagamenti (id {$object->attribute('id')}), schema art.36 saltato");

            return;
        }

        $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art36Serializer($dataMap['csv_resource'], $isC1);

        $identifierObjects = [];

        $asIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art36Serializer::SCHEMA_IDENTIFIER_AS;
        $asPageObject = isset($schemaBindings[$asIdentifier]) ? $schemaBindings[$asIdentifier] : null;
        $asRootObject = $asPageObject instanceof eZContentObject ? $asPageObject : $object;
        $identifierObjects[$asIdentifier] = $asRootObject;
        $asRootNodeId = $asRootObject->attribute('main_node')->attribute('node_id');
        $asPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($asIdentifier, $asRootNodeId);
        $asTracking = $asPublisher->publishSingle($serializer->toCsvAs(), 'csv');
        $cli->notice("anac_export: schema {$asIdentifier} ok, ultima modifica {$asTracking['dataUltimaModifica']}");
        $succeeded[] = $asIdentifier;
        (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($asIdentifier))->clear($asRootObject);

        $identifier = \OpenPABootstrapItalia\Anac\Serializer\Art36Serializer::SCHEMA_IDENTIFIER;
        $pageObject = isset($schemaBindings[$identifier]) ? $schemaBindings[$identifier] : null;
        $rootObject = $pageObject instanceof eZContentObject ? $pageObject : $object;
        $identifierObjects[$identifier] = $rootObject;
        $rootNodeId = $rootObject->attribute('main_node')->attribute('node_id');

        // Se getPagamenti() e' null (nessuna riga nel dataset) il JSON va
        // omesso del tutto - lo schema non ammette uno stato vuoto valido
        // per modalitaDiPagamento (vedi Art36Serializer::toJson()). Se
        // invece ci sono righe ma la combinazione non e' valida (es. C2
        // senza PagoPA), toJson() lancia InvalidVocabolarioException -
        // tutto publishArt36() fallisce (CSV incluso), stesso principio
        // "tutto o niente per schema" gia' in uso per gli altri schemi ANAC.
        $csv = $serializer->toCsv();
        $pagamenti = $serializer->getPagamenti();
        $publisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($identifier, $rootNodeId);
        $tracking = $publisher->publish($csv, function ($dataPrimaPubblicazione, $dataUltimaModifica) use ($serializer, $pagamenti) {
            return $pagamenti !== null ? $serializer->toJson($dataPrimaPubblicazione, $dataUltimaModifica, $pagamenti) : null;
        });
        $cli->notice("anac_export: schema {$identifier} ok, ultima modifica {$tracking['dataUltimaModifica']}");
        $succeeded[] = $identifier;
        (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($identifier))->clear($rootObject);
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: art.36');
        $cli->error('anac_export: schema art.36 fallito: ' . $e->getMessage());
        foreach (array_diff([
            \OpenPABootstrapItalia\Anac\Serializer\Art36Serializer::SCHEMA_IDENTIFIER_AS,
            \OpenPABootstrapItalia\Anac\Serializer\Art36Serializer::SCHEMA_IDENTIFIER,
        ], $succeeded) as $failedIdentifier) {
            $relatedObject = isset($identifierObjects[$failedIdentifier]) ? $identifierObjects[$failedIdentifier] : null;
            recordAnacExportError($cli, $e, $failedIdentifier, $relatedObject);
        }
    }
}

/**
 * art.20 - Performance e premi (cms#486), solo C1. A differenza di tutti
 * gli altri schemi, il JSON rappresenta una sola annualita' per blocco
 * (vedi Art20Serializer, docblock di classe): sia il JSON co.1 sia il JSON
 * co.2 vanno quindi costruiti con la riga PIU' RECENTE per chiave, non con
 * tutte le righe del dataset (che restano comunque tutte nel CSV).
 */
function publishArt20(eZCLI $cli, array $schemaBindings)
{
    $ownedIdentifiers = [];
    $succeeded = [];
    $identifierObjects = [];

    try {
        $ammontareObject = eZContentObject::fetchByRemoteID('ammontare_complessivo_premi');
        $datiObject = eZContentObject::fetchByRemoteID('dati_relativi_ai_premi');
        if (!$ammontareObject instanceof eZContentObject || !$datiObject instanceof eZContentObject) {
            // Caso NORMALE per la maggioranza dei tenant: schema opzionale,
            // modulo trasparenza-additional-anac-schemes non installato
            // (o non aggiornato a questa versione) su questo sito.
            return;
        }

        $ammontareDataMap = $ammontareObject->fetchDataMap(false, SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        $datiDataMap = $datiObject->fetchDataMap(false, SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        if (!isset($ammontareDataMap['csv_resource']) || !isset($datiDataMap['csv_resource'])) {
            $cli->error('anac_export: attributo csv_resource non trovato su uno dei due dataset art.20, schema saltato');

            return;
        }

        $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art20Serializer(
            $ammontareDataMap['csv_resource'],
            $datiDataMap['csv_resource']
        );

        // --- co.1: Ammontare complessivo dei premi ---
        $premiIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art20Serializer::SCHEMA_IDENTIFIER_CSV_PREMI;
        $premiPageObject = isset($schemaBindings[$premiIdentifier]) ? $schemaBindings[$premiIdentifier] : null;
        $premiRootObject = $premiPageObject instanceof eZContentObject ? $premiPageObject : $ammontareObject;
        $premiRootNodeId = $premiRootObject->attribute('main_node')->attribute('node_id');

        $csvPremi = $serializer->toCsvPremi();
        $ammontarePiuRecente = $serializer->getAmmontarePremiPiuRecente();

        // Il CSV e il JSON del co.1 hanno prefissi diversi nella guida ANAC
        // (art.20-premi-YYYYMMDD-YYYYMMDD.csv, art.20-YYYYMMDD-YYYYMMDD.json),
        // quindi vanno pubblicati con due publisher separati, come per il
        // co.2 (art.20-dirig/art.20-non-dirig CSV + art.20-c2 JSON), e non
        // con publish() che scrive CSV e JSON sotto lo stesso identificatore.
        // Il CSV ha tracking proprio sotto 'art.20-premi', senza callback
        // sulle date (non incorpora intestazione).
        $ownedIdentifiers[] = $premiIdentifier;
        $identifierObjects[$premiIdentifier] = $premiRootObject;
        $premiPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($premiIdentifier, $premiRootNodeId);
        $premiTracking = $premiPublisher->publishSingle($csvPremi, 'csv');
        $cli->notice("anac_export: schema {$premiIdentifier} ok, ultima modifica {$premiTracking['dataUltimaModifica']}");
        $succeeded[] = $premiIdentifier;
        (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($premiIdentifier))->clear($premiRootObject);

        // Il JSON resta sotto 'art.20'. L'hash e' calcolato sul CSV, come
        // prima del cambio, cosi' il tracking esistente di 'art.20' non
        // risulta cambiato al deploy (nessuna ripubblicazione spuria). Se il
        // dataset e' vuoto il JSON viene omesso (nessuno stato vuoto valido
        // nello schema reale, vedi Art20Serializer::getAmmontarePremiPiuRecente()).
        if ($ammontarePiuRecente !== null) {
            $co1Identifier = \OpenPABootstrapItalia\Anac\Serializer\Art20Serializer::SCHEMA_IDENTIFIER_JSON_CO1;
            $ownedIdentifiers[] = $co1Identifier;
            $identifierObjects[$co1Identifier] = $premiRootObject;
            $co1Publisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($co1Identifier, $premiRootNodeId);
            $co1Tracking = $co1Publisher->publishWithDates(
                $csvPremi,
                function ($first, $last) use ($serializer, $ammontarePiuRecente) {
                    return $serializer->toJsonCo1($first, $last, $ammontarePiuRecente);
                },
                'json'
            );
            $cli->notice("anac_export: schema {$co1Identifier} ok, ultima modifica {$co1Tracking['dataUltimaModifica']}");
            $succeeded[] = $co1Identifier;
            (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($co1Identifier))->clear($premiRootObject);
        }

        // --- co.2: Dati relativi ai premi ---
        $dirigIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art20Serializer::SCHEMA_IDENTIFIER_CSV_DIRIG;
        $dirigPageObject = isset($schemaBindings[$dirigIdentifier]) ? $schemaBindings[$dirigIdentifier] : null;
        $datiRootObject = $dirigPageObject instanceof eZContentObject ? $dirigPageObject : $datiObject;
        $datiRootNodeId = $datiRootObject->attribute('main_node')->attribute('node_id');

        $dirigPiuRecente = $serializer->getDirigPiuRecente();
        if ($dirigPiuRecente !== null) {
            $ownedIdentifiers[] = $dirigIdentifier;
            $identifierObjects[$dirigIdentifier] = $datiRootObject;
            $dirigPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($dirigIdentifier, $datiRootNodeId);
            $dirigTracking = $dirigPublisher->publishSingle($serializer->toCsvDirig(), 'csv');
            $cli->notice("anac_export: schema {$dirigIdentifier} ok, ultima modifica {$dirigTracking['dataUltimaModifica']}");
            $succeeded[] = $dirigIdentifier;
            (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($dirigIdentifier))->clear($datiRootObject);
        }

        $nonDirigPiuRecente = $serializer->getNonDirigPiuRecente();
        if ($nonDirigPiuRecente !== null) {
            $nonDirigIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art20Serializer::SCHEMA_IDENTIFIER_CSV_NON_DIRIG;
            $ownedIdentifiers[] = $nonDirigIdentifier;
            $identifierObjects[$nonDirigIdentifier] = $datiRootObject;
            $nonDirigPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($nonDirigIdentifier, $datiRootNodeId);
            $nonDirigTracking = $nonDirigPublisher->publishSingle($serializer->toCsvNonDirig(), 'csv');
            $cli->notice("anac_export: schema {$nonDirigIdentifier} ok, ultima modifica {$nonDirigTracking['dataUltimaModifica']}");
            $succeeded[] = $nonDirigIdentifier;
            (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($nonDirigIdentifier))->clear($datiRootObject);
        }

        // Il JSON co.2 va omesso del tutto se NESSUNA delle due tipologie ha
        // righe (stesso principio "ometti se vuoto" di Art36Serializer) -
        // altrimenti pubblica con una sola chiave se solo una tipologia ha
        // righe (vedi Art20Serializer::toJsonCo2()).
        if ($dirigPiuRecente !== null || $nonDirigPiuRecente !== null) {
            $co2Identifier = \OpenPABootstrapItalia\Anac\Serializer\Art20Serializer::SCHEMA_IDENTIFIER_JSON_CO2;
            $ownedIdentifiers[] = $co2Identifier;
            $identifierObjects[$co2Identifier] = $datiRootObject;
            $co2Publisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($co2Identifier, $datiRootNodeId);
            $co2Tracking = $co2Publisher->publishWithDates(
                json_encode(['dirig' => $dirigPiuRecente, 'nonDirig' => $nonDirigPiuRecente]),
                function ($first, $last) use ($serializer, $dirigPiuRecente, $nonDirigPiuRecente) {
                    return $serializer->toJsonCo2($first, $last, $dirigPiuRecente, $nonDirigPiuRecente);
                },
                'json'
            );
            $cli->notice("anac_export: schema {$co2Identifier} ok, ultima modifica {$co2Tracking['dataUltimaModifica']}");
            $succeeded[] = $co2Identifier;
            (new \OpenPABootstrapItalia\Anac\ExportErrorTracker($co2Identifier))->clear($datiRootObject);
        }
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: art.20');
        $cli->error('anac_export: schema art.20 fallito: ' . $e->getMessage());
        foreach (array_diff($ownedIdentifiers, $succeeded) as $failedIdentifier) {
            $relatedObject = isset($identifierObjects[$failedIdentifier]) ? $identifierObjects[$failedIdentifier] : null;
            recordAnacExportError($cli, $e, $failedIdentifier, $relatedObject);
        }
    }
}
