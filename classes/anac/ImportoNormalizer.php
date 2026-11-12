<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Porta un importo digitato dal redattore al formato ANAC "n.nnn,dd" (punto
 * delle migliaia, virgola decimale, sempre due decimali).
 *
 * Sono accettate solo forme non ambigue (dopo aver tolto il simbolo euro e gli
 * spazi, con segno meno opzionale):
 *   1550            1550,33         1.550,33        (italiano)
 *   1.550           1.000.000                       (solo migliaia, gruppi di 3 cifre)
 *   1550.33         1,550.33                        (inglese, 1-2 decimali)
 * Tutto il resto (3+ decimali, gruppi sbagliati come "100.000.00", un solo
 * "1,550", testo, vuoto) genera InvalidImportoException.
 *
 * Un solo punto seguito da esattamente 3 cifre e' sempre un separatore delle
 * migliaia ("2.304" = 2304), come nei campi prezzo di eZ con locale ita-IT.
 * Il calcolo e' fatto sulle stringhe, senza float, quindi esatto per qualsiasi
 * lunghezza.
 */
class ImportoNormalizer
{
    /**
     * @param mixed $raw
     * @return string
     * @throws InvalidImportoException
     */
    public static function normalize($raw)
    {
        $value = str_replace(["\xe2\x82\xac", "\xc2\xa0", ' ', "\t"], '', trim((string)$raw));

        $negative = false;
        if (substr($value, 0, 1) === '-') {
            $negative = true;
            $value = substr($value, 1);
        }

        if ($value === '') {
            throw self::invalid($raw);
        }

        $int = null;
        $dec = '';
        if (preg_match('/^\d+$/', $value)) {
            $int = $value;
        } elseif (preg_match('/^\d{1,3}(\.\d{3})+$/', $value)) {
            $int = str_replace('.', '', $value);
        } elseif (preg_match('/^(\d+|\d{1,3}(\.\d{3})+),(\d{1,2})$/', $value, $m)) {
            $int = str_replace('.', '', $m[1]);
            $dec = $m[3];
        } elseif (preg_match('/^(\d+|\d{1,3}(,\d{3})+)\.(\d{1,2})$/', $value, $m)) {
            $int = str_replace(',', '', $m[1]);
            $dec = $m[3];
        }

        if ($int === null) {
            throw self::invalid($raw);
        }

        $int = ltrim($int, '0');
        if ($int === '') {
            $int = '0';
        }
        $dec = str_pad($dec, 2, '0');
        if ($int === '0' && $dec === '00') {
            $negative = false;
        }

        return ($negative ? '-' : '') . preg_replace('/\B(?=(\d{3})+(?!\d))/', '.', $int) . ',' . $dec;
    }

    private static function invalid($raw)
    {
        return new InvalidImportoException(
            "Importo '" . (string)$raw . "' non interpretabile in modo univoco "
            . "(formati ammessi: 1550, 1550,33, 1.550,33, 1.550, 1550.33, 1,550.33; massimo 2 decimali)"
        );
    }
}
