<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Costruzione di righe CSV conformi a RFC 4180 (quoting dei campi che
 * contengono il delimitatore, virgolette o ritorni a capo). Prima di questa
 * classe i serializer ANAC costruivano le righe con un semplice implode(),
 * che rompe la struttura del CSV quando un campo di testo libero (es.
 * "competenze", testo ricco multi-paragrafo) contiene un ritorno a capo: il
 * parser lo legge come fine riga invece che come contenuto della cella - bug
 * segnalato da Federica su cms#478 (COMPETENZE_ORGANO del Sindaco, con piu'
 * paragrafi nel campo main_function, spaccava la tabella in righe CSV
 * aggiuntive), verificato leggendo lo screenshot allegato al commento.
 */
class CsvLineBuilder
{
    public static function line(array $fields, $delimiter = ';')
    {
        $escaped = array_map(function ($field) use ($delimiter) {
            $field = (string)$field;
            if (strpbrk($field, $delimiter . "\"\n\r") !== false) {
                return '"' . str_replace('"', '""', $field) . '"';
            }

            return $field;
        }, $fields);

        return implode($delimiter, $escaped);
    }
}
