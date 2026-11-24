<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * JSON non conforme allo schema ANAC reale (validato con JsonSchemaValidator):
 * l'export fallisce esplicitamente invece di pubblicare un file non
 * conforme - stesso principio di InvalidVocabolarioException/
 * InvalidImportoException/MissingCodiceFiscaleException.
 */
class InvalidAnacSchemaException extends \Exception
{
}
