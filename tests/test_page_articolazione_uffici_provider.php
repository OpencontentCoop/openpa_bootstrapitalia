<?php
/**
 * Verifica che PageArticolazioneUfficiProvider esponga i dati di
 * Art13Serializer senza modificarli, e che il JSON prodotto per
 * l'incorporamento in pagina sia sempre sicuro contro un tentativo di XSS
 * via chiusura prematura del tag <script>.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_page_articolazione_uffici_provider.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'PageArticolazioneUfficiProvider test',
    'use-session'    => false,
    'use-modules'    => true,
    'use-extensions' => true,
]);
$script->startup();
$script->initialize();

$PASSED = 0;
$FAILED = 0;

function assert_true(bool $condition, string $label): void
{
    global $PASSED, $FAILED;
    if ($condition) { echo "\033[32m[PASS]\033[0m $label\n"; $PASSED++; }
    else            { echo "\033[31m[FAIL]\033[0m $label\n"; $FAILED++; }
}
function assert_eq($a, $b, string $label): void
{
    global $PASSED, $FAILED;
    if ($a === $b) { echo "\033[32m[PASS]\033[0m $label\n"; $PASSED++; }
    else            { echo "\033[31m[FAIL]\033[0m $label (got " . var_export($a, true) . ", expected " . var_export($b, true) . ")\n"; $FAILED++; }
}

$provider = new \OpenPABootstrapItalia\Anac\PageArticolazioneUfficiProvider();

$organiPolitici = $provider->getOrganiPolitici();
assert_true(is_array($organiPolitici), 'getOrganiPolitici() restituisce un array');

$organiAmministrativi = $provider->getOrganiAmministrativi();
assert_true(is_array($organiAmministrativi), 'getOrganiAmministrativi() restituisce un array');

$politiciJson = $provider->getOrganiPoliticiRowsJson();
assert_true(is_string($politiciJson) && json_decode($politiciJson) !== null, 'getOrganiPoliticiRowsJson() restituisce JSON valido');

$amministrativiJson = $provider->getOrganiAmministrativiRowsJson();
assert_true(is_string($amministrativiJson) && json_decode($amministrativiJson) !== null, 'getOrganiAmministrativiRowsJson() restituisce JSON valido');

// Riga di prova con un payload pensato per rompere un embedding JSON ingenuo
// in un blocco <script> - deve restituire una stringa JSON valida che NON
// contenga la sequenza letterale "</script" (altrimenti il browser
// chiuderebbe il tag a meta' e inietterebbe il resto come markup/script).
$maliciousRows = [[
    'organo' => 'Test</script><script>window.xssFired=true;</script>',
    'competenzeOrgano' => '',
    'denominazione' => 'Ufficio "virgolette" & commerciale',
    'competenze' => '',
    'nominativo' => '',
    'telefono' => '',
    'email' => '',
]];
$reflection = new ReflectionMethod($provider, 'toSafeJson');
$reflection->setAccessible(true);
$json = $reflection->invoke($provider, $maliciousRows);

assert_true(
    strpos($json, '</script') === false,
    'toSafeJson() non produce mai la sequenza letterale "</script" nel suo output'
);
$decoded = json_decode($json, true);
assert_true(
    json_last_error() === JSON_ERROR_NONE && is_array($decoded),
    'toSafeJson() produce comunque JSON valido e decodificabile'
);
assert_eq(
    $decoded[0]['organo'],
    'Test</script><script>window.xssFired=true;</script>',
    'Il valore decodificato è identico all\'originale (solo l\'incapsulamento cambia, non il dato)'
);

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
