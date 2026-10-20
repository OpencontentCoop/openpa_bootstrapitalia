<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Lanciata quando un array richiesto non vuoto dallo schema JSON ANAC
 * (`minItems: 1`) risulterebbe vuoto nell'export - es. `datiSuiPagamenti`
 * (art. 4-bis) o `organi` (art. 13). Blocca la pubblicazione invece di
 * scrivere un file che ANAC considererebbe non conforme, stesso principio
 * di MissingCodiceFiscaleException/InvalidVocabolarioException: un file
 * mancante e' un problema visibile nei log, un file pubblicato ma
 * schema-invalido e' un problema silenzioso.
 *
 * Decisione con Marco il 2026-09-15: NON uno skip silenzioso (rischia di
 * lasciare "-latest" bloccato su dati vecchi senza segnalazione, o di
 * mascherare un bug reale - es. "organi" vuoto per un comune con Consiglio e
 * Giunta e' quasi certamente un bug di query, non uno stato legittimo).
 */
class EmptyExportException extends \Exception
{
}
