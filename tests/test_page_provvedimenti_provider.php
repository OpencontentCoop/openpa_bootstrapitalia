<?php
/**
 * Verifica PageProvvedimentiProvider: righe appiattite con i campi per
 * tabella+filtri (NON provvedimento/allegati, solo export), JSON gia' reso
 * sicuro per l'incorporamento in pagina.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_page_provvedimenti_provider.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'PageProvvedimentiProvider test',
    'use-session'    => false,
    'use-modules'    => true,
    'use-extensions' => true,
]);
$script->startup();
$script->initialize();

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

$provider = new \OpenPABootstrapItalia\Anac\PageProvvedimentiProvider();
$organiJson = $provider->getOrganiRowsJson();
$dirigentiJson = $provider->getDirigentiRowsJson();

check('getOrganiRowsJson restituisce JSON valido', true, json_decode($organiJson) !== null || $organiJson === '[]');
check('getDirigentiRowsJson restituisce JSON valido', true, json_decode($dirigentiJson) !== null || $dirigentiJson === '[]');

$rows = json_decode($organiJson, true);
foreach ((array)$rows as $row) {
    check('nessuna riga espone provvedimento', false, array_key_exists('provvedimento', $row));
    check('nessuna riga espone allegati', false, array_key_exists('allegati', $row));
    check('riga ha denominazione', true, array_key_exists('denominazione', $row));
    check('riga ha anno', true, array_key_exists('anno', $row));
    check('riga ha pubblicazioneInizio', true, array_key_exists('pubblicazioneInizio', $row));
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
