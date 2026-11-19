<?php
/**
 * Test di TelefonoNormalizer (logica pura, nessun kernel eZ).
 * Run: php tests/test_anac_telefono_normalizer.php
 */

require __DIR__ . '/../classes/anac/InvalidTelefonoException.php';
require __DIR__ . '/../classes/anac/TelefonoNormalizer.php';

use OpenPABootstrapItalia\Anac\TelefonoNormalizer;
use OpenPABootstrapItalia\Anac\InvalidTelefonoException;

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
        return TelefonoNormalizer::normalize($raw);
    } catch (InvalidTelefonoException $e) {
        return 'EXC';
    }
}

// Validi (esempi dallo schema commons-v1.0.schema.json)
check('fisso con prefisso', '+39 06 12345678', run('+39 06 12345678'));
check('fisso senza prefisso', '06 12345678', run('06 12345678'));
check('fisso provincia lunga', '+39 0382 123456', run('+39 0382 123456'));
check('cellulare senza prefisso', '333 1234567', run('333 1234567'));
check('cellulare con prefisso', '+39 333 1234567', run('+39 333 1234567'));
check('fisso senza spazi', '0612345678', run('0612345678'));
check('cellulare senza spazi', '3331234567', run('3331234567'));
check('con trim esterno', '06 12345678', run('  06 12345678  '));

// Non validi
check('vuoto', 'EXC', run(''));
check('testo', 'EXC', run('non è un numero'));
check('url', 'EXC', run('https://esempio.it/telefono'));
check('troppo corto', 'EXC', run('123'));
check('email', 'EXC', run('ufficio@esempio.it'));

echo "\nPassed: $passed, Failed: $failed\n";
exit($failed > 0 ? 1 : 0);
