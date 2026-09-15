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
