<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Valida un JSON (gia' serializzato in stringa) contro uno schema ANAC
 * reale scaricato e committato come fixture locale (classes/anac/schema/),
 * MAI recuperato via HTTP a runtime: un export di produzione che gira su
 * ~600 tenant non deve dipendere dalla raggiungibilita' di
 * guida-servizi.anticorruzione.it ne' dalla sua latenza, e un eventuale
 * cambio di contenuto lato ANAC non deve alterare silenziosamente cosa
 * viene validato.
 *
 * I $ref dello schema specifico (es. art.23-v1.0.schema.json) puntano
 * all'URL assoluto $id di commons-v1.0.schema.json (non un path relativo) -
 * il contenuto locale di commons viene pre-registrato in una SchemaStorage
 * sotto quello stesso $id, cosi' la risoluzione dei $ref non genera MAI una
 * richiesta di rete.
 *
 * Pensata da subito riusabile per futuri schemi ANAC ($schemaFilename non
 * hardcoded) - questo lavoro non retrofitta pero' la validazione sugli
 * schemi gia' scritti (art.4-bis/13/20/31): fuori scope di questo rilascio.
 */
class JsonSchemaValidator
{
    const SCHEMA_DIR = __DIR__ . '/schema';

    const COMMONS_ID = 'https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/commons-v1.0.schema.json';

    /**
     * @throws InvalidAnacSchemaException se $json non e' JSON valido o non e' conforme allo schema
     */
    public static function validate($schemaFilename, $json)
    {
        $data = json_decode($json);
        if ($data === null && json_last_error() !== JSON_ERROR_NONE) {
            throw new InvalidAnacSchemaException('JSON non valido: ' . json_last_error_msg());
        }

        $commonsPath = self::SCHEMA_DIR . '/commons-v1.0.schema.json';
        $commonsSchema = json_decode(file_get_contents($commonsPath));

        $schemaStorage = new \JsonSchema\SchemaStorage(new \JsonSchema\Uri\UriRetriever(), new \JsonSchema\Uri\UriResolver());
        $schemaStorage->addSchema(self::COMMONS_ID, $commonsSchema);

        $schemaPath = self::SCHEMA_DIR . '/' . $schemaFilename;
        $schema = json_decode(file_get_contents($schemaPath));
        $schemaId = isset($schema->{'$id'}) ? $schema->{'$id'} : 'file://' . $schemaPath;
        $schemaStorage->addSchema($schemaId, $schema);

        $validator = new \JsonSchema\Validator(new \JsonSchema\Constraints\Factory($schemaStorage));
        $validator->validate($data, $schema);

        if (!$validator->isValid()) {
            $messages = [];
            foreach ($validator->getErrors() as $error) {
                $messages[] = ($error['property'] !== '' ? $error['property'] . ': ' : '') . $error['message'];
            }
            throw new InvalidAnacSchemaException(
                "JSON non conforme allo schema ANAC '{$schemaFilename}': " . implode('; ', $messages)
            );
        }
    }
}
