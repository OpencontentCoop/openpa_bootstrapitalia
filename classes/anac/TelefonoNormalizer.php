<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Valida un recapito telefonico contro il pattern ANAC per numeri italiani
 * (schema commons-v1.0.schema.json, definizione Telefono - verificato
 * scaricando lo schema il 2026-11-19):
 *   ^(\+39)?\s?(0\d{1,4}[\s\-]?\d{4,8}|3\d{2}[\s\-]?\d{6,7})$
 *
 * A differenza di ImportoNormalizer, non trasforma il valore in una forma
 * canonica diversa - lo schema ammette varianti di spaziatura equivalenti
 * (es. "06 12345678" e "0612345678" sono entrambe valide) - si limita a
 * un trim e alla validazione del pattern, restituendo il valore cosi'
 * com'e' se valido.
 */
class TelefonoNormalizer
{
    const PATTERN = '/^(\+39)?\s?(0\d{1,4}[\s\-]?\d{4,8}|3\d{2}[\s\-]?\d{6,7})$/';

    /**
     * @param mixed $raw
     * @return string
     * @throws InvalidTelefonoException
     */
    public static function normalize($raw)
    {
        $value = trim((string)$raw);

        if ($value === '' || !preg_match(self::PATTERN, $value)) {
            throw new InvalidTelefonoException(
                "Numero di telefono '" . (string)$raw . "' non conforme al pattern ANAC per numeri italiani "
                . "(es. '06 12345678', '+39 333 1234567')"
            );
        }

        return $value;
    }
}
