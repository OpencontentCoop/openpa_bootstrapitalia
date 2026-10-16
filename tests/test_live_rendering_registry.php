<?php
/**
 * Verifica LiveRenderingRegistry: riconosce gli schemi registrati, ne
 * delega il rendering al fornitore giusto, ignora schemi non registrati
 * (fallback al meccanismo fields/datatable esistente), e produce un tag di
 * cache deterministico basato sul node_id della pagina.
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

$fakeNode = eZContentObjectTreeNode::fetch(2); // Home, nodo noto in ogni ambiente di sviluppo
assert_eq(
    \OpenPABootstrapItalia\Anac\LiveRenderingRegistry::getCacheTag($fakeNode),
    'trasparenza-live-rendering-2',
    'getCacheTag() produce un tag deterministico basato sul node_id'
);

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
