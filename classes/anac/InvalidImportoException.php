<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Importo non interpretabile in modo univoco: l'export fallisce esplicitamente
 * invece di pubblicare un valore sbagliato (stesso principio di
 * InvalidVocabolarioException e MissingCodiceFiscaleException).
 */
class InvalidImportoException extends \Exception
{
}
