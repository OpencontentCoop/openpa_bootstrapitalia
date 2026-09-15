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
