<?php
/**
 * Test di ImportoNormalizer (logica pura, nessun kernel eZ).
 * Run: php tests/test_anac_importo_normalizer.php
 */

require __DIR__ . '/../classes/anac/InvalidImportoException.php';
require __DIR__ . '/../classes/anac/ImportoNormalizer.php';

use OpenPABootstrapItalia\Anac\ImportoNormalizer;
use OpenPABootstrapItalia\Anac\InvalidImportoException;

$passed = 0;
$failed = 0;
function check($label, $expected, $actual)
{
    global $passed, $failed;
    if ($expected === $actual) {
        $passed++;
        return;
    }
    $failed++;
    echo "FAIL $label\n  atteso:   " . var_export($expected, true) . "\n  ottenuto: " . var_export($actual, true) . "\n";
}
function run($raw)
{
    try {
        return ImportoNormalizer::normalize($raw);
    } catch (InvalidImportoException $e) {
        return 'EXC';
    }
}

/** Copia della funzione ANAC precedente, solo per i confronti di parita'. */
function legacy($raw)
{
    $value = trim(str_replace(["\xe2\x82\xac", ' '], '', $raw));
    $hasComma = strpos($value, ',') !== false;
    $hasDot = strpos($value, '.') !== false;
    if ($hasComma && $hasDot) {
        if (strrpos($value, ',') > strrpos($value, '.')) {
            $value = str_replace('.', '', $value);
            $value = str_replace(',', '.', $value);
        } else {
            $value = str_replace(',', '', $value);
        }
    } elseif ($hasComma) {
        $value = str_replace(',', '.', $value);
    }
    return number_format((float)$value, 2, ',', '.');
}

// ---- tabella di casi: input => atteso ('EXC' = InvalidImportoException)
$cases = [
    // interi
    '10000' => '10.000,00', '2304' => '2.304,00', '0' => '0,00', '007' => '7,00', '999' => '999,00',
    // virgola decimale
    '1000,20' => '1.000,20', '10000,20' => '10.000,20', '2304,5' => '2.304,50', '0,5' => '0,50', '1,55' => '1,55',
    // formato ANAC (idempotenza)
    '1.550,33' => '1.550,33', '24.400,00' => '24.400,00', '1.234.567,89' => '1.234.567,89', '0,00' => '0,00',
    // solo migliaia (punto + gruppi di 3)
    '1.000' => '1.000,00', '2.304' => '2.304,00', '100.000' => '100.000,00',
    '100.000.000' => '100.000.000,00', '1.000.000' => '1.000.000,00',
    // punto decimale (inglese)
    '1550.33' => '1.550,33', '10000.20' => '10.000,20', '2.30' => '2,30', '1.5' => '1,50',
    '1,550.33' => '1.550,33', '1,234,567.89' => '1.234.567,89',
    // simbolo, spazi, segno
    '€ 12.688,40' => '12.688,40', '€ 1.464,00' => '1.464,00', '1.464,00 €' => '1.464,00', '€1464' => '1.464,00',
    '10 000,50' => '10.000,50', "10\xc2\xa0000,50" => '10.000,50', '  500  ' => '500,00',
    '-500,5' => '-500,50', '-€ 1.000,00' => '-1.000,00', '-0,00' => '0,00',
    // non interpretabili
    '100.000.00' => 'EXC', '1.000,5,3' => 'EXC', '1000,2,3' => 'EXC', '1,550' => 'EXC', '1,550,000' => 'EXC',
    '1.550,333' => 'EXC', '2304,567' => 'EXC', '1.00.000' => 'EXC', '1000.000,50' => 'EXC',
    'abc' => 'EXC', '' => 'EXC', '   ' => 'EXC', 'n.d.' => 'EXC', 'EUR 100' => 'EXC', '1e3' => 'EXC',
    '1550.333' => 'EXC', '1234.5678' => 'EXC', '1,550.333' => 'EXC', '1.550.33' => 'EXC', '--5' => 'EXC', '5-' => 'EXC', '€' => 'EXC', ',50' => 'EXC', '.50' => 'EXC', '12,' => 'EXC',
];
foreach ($cases as $input => $expected) {
    check("input '" . $input . "'", $expected, run((string)$input));
}

// ---- idempotenza: normalizzare un valore gia' normalizzato non lo cambia
foreach ($cases as $input => $expected) {
    if ($expected !== 'EXC') {
        check("idempotenza '" . $input . "'", $expected, run($expected));
    }
}

// ---- parita' con la funzione precedente dove era corretta (tutto tranne gli ambigui/errati)
$parity = ['10000', '1000,20', '1.550,33', '550,33', '0,00', '1.234.567,89', '€ 12.688,40', '1550.33', '1,550.33',
    '10 000,50', '-500,5', '2304,5', '10000,20', '10.000,20', '24.400,00', '€ 1.464,00', '2.30', '1.5'];
foreach ($parity as $input) {
    check("parita' '" . $input . "'", legacy($input), run($input));
}

// ---- differenze volute rispetto alla funzione precedente (la vecchia sbagliava in silenzio)
$intentional = ['100.000.000' => ['100,00', '100.000.000,00'], '1.000' => ['1,00', '1.000,00'],
    '1.000.000' => ['1,00', '1.000.000,00'], '100.000' => ['100,00', '100.000,00'], '2.304' => ['2,30', '2.304,00']];
foreach ($intentional as $input => $pair) {
    check("vecchio sbagliato '" . $input . "'", $pair[0], legacy($input));
    check("nuovo corretto '" . $input . "'", $pair[1], run($input));
}
foreach (['abc', '', '100.000.00', '1000,2,3', 'n.d.'] as $input) {
    check("vecchio pubblicava un valore inventato '" . $input . "'", true, legacy($input) !== 'EXC');
    check("nuovo rifiuta '" . $input . "'", 'EXC', run($input));
}

// ---- proprieta': stesso importo in tutte le forme non ambigue => stessa stringa ANAC
mt_srand(42);
for ($i = 0; $i < 3000; $i++) {
    $digits = mt_rand(1, 12);
    $int = (string)mt_rand(0, 9) . ($digits > 1 ? substr((string)mt_rand(), 0, $digits - 1) : '');
    $int = ltrim($int, '0') === '' ? '0' : ltrim($int, '0');
    $cents = mt_rand(0, 99);
    $dec = str_pad((string)$cents, 2, '0', STR_PAD_LEFT);
    $anac = preg_replace('/\B(?=(\d{3})+(?!\d))/', '.', $int) . ',' . $dec;
    $itThousands = preg_replace('/\B(?=(\d{3})+(?!\d))/', '.', $int);
    $enThousands = preg_replace('/\B(?=(\d{3})+(?!\d))/', ',', $int);
    $variants = [
        $int . ',' . $dec, $int . '.' . $dec, $itThousands . ',' . $dec, $enThousands . '.' . $dec,
        '€ ' . $itThousands . ',' . $dec, $itThousands . ',' . $dec . ' €',
    ];
    if ($cents === 0) {
        $variants[] = $int;
        $variants[] = $itThousands;
    }
    foreach ($variants as $variant) {
        $got = run($variant);
        if ($got !== $anac) {
            check("proprieta' '" . $variant . "'", $anac, $got);
        } else {
            $passed++;
        }
    }
    // idempotenza
    if (run($anac) !== $anac) {
        check("idempotenza proprieta' '" . $anac . "'", $anac, run($anac));
    } else {
        $passed++;
    }
}

// ---- il messaggio d'errore riporta il valore e i formati ammessi
try {
    ImportoNormalizer::normalize('100.000.00');
    check('eccezione attesa', true, false);
} catch (InvalidImportoException $e) {
    check('messaggio contiene il valore', true, strpos($e->getMessage(), '100.000.00') !== false);
    check('messaggio contiene i formati', true, strpos($e->getMessage(), '1.550,33') !== false);
}

echo "\n$passed controlli ok, $failed falliti\n";
exit($failed === 0 ? 0 : 1);
