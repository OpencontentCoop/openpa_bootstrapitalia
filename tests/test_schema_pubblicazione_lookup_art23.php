<?php
/**
 * Verifica che i tre identificativi art.23 siano registrati con gli id
 * 26/27/28 (scelti per non collidere con 22-25, già presi dal branch
 * trasparenza-additional-scheme-26-27 non ancora mergeato - vedi piano,
 * Global Constraints) e che abbiano un'etichetta.
 * Run: php tests/test_schema_pubblicazione_lookup_art23.php
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$PASSED = 0;
$FAILED = 0;
function check($label, $expected, $actual)
{
    global $PASSED, $FAILED;
    if ($expected === $actual) {
        $PASSED++;
        return;
    }
    $FAILED++;
    echo "FAIL $label\n  atteso:   " . var_export($expected, true) . "\n  ottenuto: " . var_export($actual, true) . "\n";
}

check('art.23-org id', 26, SchemaPubblicazioneLookup::OPTION_IDS['art.23-org'] ?? null);
check('art.23-altra-tipologia id', 27, SchemaPubblicazioneLookup::OPTION_IDS['art.23-altra-tipologia'] ?? null);
check('art.23 id', 28, SchemaPubblicazioneLookup::OPTION_IDS['art.23'] ?? null);

check('nessun id duplicato', count(SchemaPubblicazioneLookup::OPTION_IDS), count(array_unique(SchemaPubblicazioneLookup::OPTION_IDS)));

foreach (['art.23-org', 'art.23-altra-tipologia', 'art.23'] as $schema) {
    check("label non vuota per $schema", true, isset(SchemaPubblicazioneLookup::LABELS[$schema]) && SchemaPubblicazioneLookup::LABELS[$schema] !== '');
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
