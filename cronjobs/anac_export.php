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

publishArt4Bis($cli);
publishArt13($cli);
publishArt31($cli);

/**
 * OIV e Organi di revisione non hanno un dataset dedicato: sono documenti
 * (classe `document`) taggati con `anac_document_type` (vedi
 * installer/modules/trasparenza/CLAUDE.md), pubblicati come figli delle
 * rispettive pagine trasparenza. Corte dei conti invece e' un dataset reale,
 * stesso pattern di art.4-bis. Il nodo dell'export CSV di ciascuna
 * sottosezione e' quello della sua pagina/dataset (vedi
 * installer/modules/trasparenza-c1/CLAUDE.md, tabella di binding); il JSON
 * "file unico" (copre tutte e tre le sottosezioni insieme) e' ospitato sotto
 * "Controlli e rilievi sull'amministrazione", il genitore reale di tutte e
 * tre le pagine di trasparenza dell'art. 31 - verificato con Marco il
 * 2026-09-15, vedi classes/anac/CLAUDE.md. Specifico di trasparenza-c1: C2
 * ha un remote_id diverso per la stessa pagina concettuale.
 */
function publishArt31(eZCLI $cli)
{
    try {
        if (\AmministrazioneTrasparenteTools::getTipologiaEnte() !== \AmministrazioneTrasparenteTools::TIPOLOGIA_C1) {
            $cli->notice('anac_export: art.31 saltato (solo profilo C1 supportato per ora)');

            return;
        }

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

        $oivPageObject = eZContentObject::fetchByRemoteID('d20a1b517d9c0cba06af6b6b345f6c0e');
        $orPageObject = eZContentObject::fetchByRemoteID('583cd446c1978fdab33108b83ae9eb71');
        if (!$oivPageObject instanceof eZContentObject || !$orPageObject instanceof eZContentObject) {
            $cli->warning('anac_export: pagine "Organismi indipendenti di valutazione" o "Organi di revisione" non trovate, schema art.31 saltato (modulo trasparenza-c1 non installato su questo sito?)');

            return;
        }

        /**
         * remote_id specifico di trasparenza-c1: "Controlli e rilievi
         * sull'amministrazione" e' il genitore reale di tutte e tre le
         * pagine di trasparenza dell'art. 31 (OIV, Organi di revisione,
         * Corte dei conti) - verificato in sito-comunale-dev. Diverso da
         * trasparenza-c2, che ha il proprio remote_id per la stessa pagina
         * concettuale (`t_c2_controlli-e-rilievi-sull-am`) e comunque non ha
         * ancora OIV/Organi di revisione - se in futuro C2 verra' supportato,
         * questo remote_id andra' reso condizionale alla tipologia ente, non
         * riusato cosi' com'e' (vedi classes/anac/CLAUDE.md).
         */
        $controlliERilieviPage = eZContentObject::fetchByRemoteID('fc18dc0947cce81ed94b4f5228572fc1');
        if (!$controlliERilieviPage instanceof eZContentObject) {
            $cli->warning('anac_export: pagina "Controlli e rilievi sull\'amministrazione" non trovata, schema art.31 saltato (modulo trasparenza-c1 non installato su questo sito?)');

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
        $ocPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($ocIdentifier, $corteDeiContiObject->attribute('main_node')->attribute('node_id'));
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
function publishArt13(eZCLI $cli)
{
    try {
        if (\AmministrazioneTrasparenteTools::getTipologiaEnte() !== \AmministrazioneTrasparenteTools::TIPOLOGIA_C1) {
            $cli->notice('anac_export: art.13 saltato (solo profilo C1 supportato per ora)');

            return;
        }

        $object = eZContentObject::fetchByRemoteID('ae441f5d2f78bf88f0b3e39a36743bdd');
        if (!$object instanceof eZContentObject) {
            $cli->warning("anac_export: pagina 'Articolazione degli uffici' non trovata, schema art.13 saltato (modulo trasparenza-c1 non installato su questo sito?)");

            return;
        }

        $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer();
        $rootNodeId = $object->attribute('main_node')->attribute('node_id');

        $asIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_AS;
        $asPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($asIdentifier, $rootNodeId);
        $asTracking = $asPublisher->publishSingle($serializer->toCsvAmbitoSoggettivo(), 'csv');
        $cli->notice("anac_export: schema {$asIdentifier} ok, ultima modifica {$asTracking['dataUltimaModifica']}");

        $organi = $serializer->fetchOrganiConUffici();

        $opIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OP;
        $opPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($opIdentifier, $rootNodeId);
        $opTracking = $opPublisher->publishSingle($serializer->toCsvOrganiUffici($organi), 'csv');
        $cli->notice("anac_export: schema {$opIdentifier} ok, ultima modifica {$opTracking['dataUltimaModifica']}");

        $paIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_JSON_C1;
        $paPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($paIdentifier, $rootNodeId);
        $paTracking = $paPublisher->publishWithDates(
            json_encode($organi),
            function ($dataPrimaPubblicazione, $dataUltimaModifica) use ($serializer, $organi) {
                return $serializer->toJson($dataPrimaPubblicazione, $dataUltimaModifica, $organi);
            },
            'json'
        );
        $cli->notice("anac_export: schema {$paIdentifier} ok, ultima modifica {$paTracking['dataUltimaModifica']}");
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: art.13');
        $cli->error('anac_export: schema art.13 fallito: ' . $e->getMessage());
    }
}

function publishArt4Bis(eZCLI $cli)
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

        $node = $object->attribute('main_node');
        $publisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($identifier, $node->attribute('node_id'));
        $tracking = $publisher->publish($csv, function ($dataPrimaPubblicazione, $dataUltimaModifica) use ($serializer) {
            return $serializer->toJson($dataPrimaPubblicazione, $dataUltimaModifica);
        });

        $cli->notice("anac_export: schema {$identifier} ok, ultima modifica {$tracking['dataUltimaModifica']}");
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: ' . $identifier);
        $cli->error("anac_export: schema {$identifier} fallito: " . $e->getMessage());
    }
}
