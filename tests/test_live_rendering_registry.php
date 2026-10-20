<?php
/**
 * Verifica LiveRenderingRegistry: riconosce gli schemi registrati, ne
 * delega il rendering al fornitore giusto, ignora schemi non registrati
 * (fallback al meccanismo fields/datatable esistente), e invalida la cache
 * HTTP solo delle pagine effettivamente bindate a uno schema registrato.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_live_rendering_registry.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'LiveRenderingRegistry test',
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

assert_true(
    \OpenPABootstrapItalia\Anac\LiveRenderingRegistry::hasProvider('art.13-op'),
    'art.13-op ha un fornitore di rendering live registrato'
);
assert_true(
    \OpenPABootstrapItalia\Anac\LiveRenderingRegistry::hasProvider('art.13-oa'),
    'art.13-oa ha un fornitore di rendering live registrato'
);
assert_true(
    !\OpenPABootstrapItalia\Anac\LiveRenderingRegistry::hasProvider('art.4-bis'),
    'art.4-bis NON ha un fornitore (legge da un dataset, non adattabile allo stesso modo) - deve continuare a usare fields/datatable'
);
assert_true(
    !\OpenPABootstrapItalia\Anac\LiveRenderingRegistry::hasProvider('schema-mai-esistito'),
    'Uno schema sconosciuto non ha un fornitore (nessun errore, solo nessun rendering live)'
);

$renderedOp = \OpenPABootstrapItalia\Anac\LiveRenderingRegistry::render('art.13-op');
assert_true(is_string($renderedOp) && json_decode($renderedOp) !== null, 'render(art.13-op) restituisce JSON valido');

$renderedUnknown = \OpenPABootstrapItalia\Anac\LiveRenderingRegistry::render('schema-mai-esistito');
assert_true($renderedUnknown === null, 'render() di uno schema senza fornitore restituisce null, non un errore');

// clearAllCaches() con bindings vuoti (nessuna pagina_trasparenza dichiara
// nessuno schema registrato su questo sito) non deve lanciare eccezioni.
try {
    \OpenPABootstrapItalia\Anac\LiveRenderingRegistry::clearAllCaches([]);
    assert_true(true, 'clearAllCaches() con bindings vuoti non lancia eccezioni');
} catch (\Throwable $e) {
    assert_true(false, 'clearAllCaches() con bindings vuoti non lancia eccezioni (' . $e->getMessage() . ')');
}

// Con un binding finto per uno schema effettivamente registrato (Home, id 2,
// nodo noto in ogni ambiente di sviluppo, usata solo per avere un
// eZContentObject valido) deve risolvere l'oggetto e invalidarne la cache
// senza errori - non verifica che Varnish sia stato davvero invalidato,
// fuori portata di un test PHP standalone.
$homeObject = eZContentObjectTreeNode::fetch(2)->attribute('object');
try {
    \OpenPABootstrapItalia\Anac\LiveRenderingRegistry::clearAllCaches(['art.13-op' => $homeObject]);
    assert_true(true, 'clearAllCaches() con un binding su uno schema registrato non lancia eccezioni');
} catch (\Throwable $e) {
    assert_true(false, 'clearAllCaches() con un binding su uno schema registrato non lancia eccezioni (' . $e->getMessage() . ')');
}

// Senza argomento, deve eseguire SchemaPubblicazioneLookup::fetchAllBindings()
// internamente senza errori (non verifica il contenuto del binding, solo che
// il percorso di default funzioni).
try {
    \OpenPABootstrapItalia\Anac\LiveRenderingRegistry::clearAllCaches();
    assert_true(true, 'clearAllCaches() senza argomenti (fetchAllBindings interno) non lancia eccezioni');
} catch (\Throwable $e) {
    assert_true(false, 'clearAllCaches() senza argomenti non lancia eccezioni (' . $e->getMessage() . ')');
}

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
