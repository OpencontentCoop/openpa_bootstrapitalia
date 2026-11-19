<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Numero di telefono non conforme al pattern ANAC per numeri italiani
 * (schema commons-v1.0.schema.json, definizione Telefono): l'export fallisce
 * esplicitamente invece di pubblicare un valore che lo schema JSON ANAC
 * rifiuterebbe - stesso principio di InvalidVocabolarioException/
 * InvalidImportoException/MissingCodiceFiscaleException.
 */
class InvalidTelefonoException extends \Exception
{
}
