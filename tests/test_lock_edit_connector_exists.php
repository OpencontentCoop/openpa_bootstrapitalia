<?php
/**
 * Test: il pulsante "Modifica" del LockEdit non compare per le classi senza LockEditClassConnector
 *
 * Bug: in toolbar il LockEditButton compare per ogni oggetto in stato opencity_lock/locked se l'utente ha
 * opencity_locked_editor; per le classi senza connector (es. dataset) il form va in errore
 * ("Class connector not found").
 *
 * Fix: LockEditConnectorFactory::connectorClassName()/hasConnector() e LockEditConnector::canLockEdit() falso se manca il connector.
 *
 * Run:
 *   docker compose exec -T app sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_lock_edit_connector_exists.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'LockEditConnectorFactory connector exists test',
    'use-session'    => false,
    'use-modules'    => true,
    'use-extensions' => true,
]);
$script->startup();
$script->initialize();

// ── Helpers ───────────────────────────────────────────────────────────────────

$PASSED = 0;
$FAILED = 0;

function assert_same($expected, $actual, string $label): void
{
    global $PASSED, $FAILED;
    if ($expected === $actual) {
        echo "\033[32m[PASS]\033[0m $label\n";
        $PASSED++;
    } else {
        echo "\033[31m[FAIL]\033[0m $label\n  atteso:   " . var_export($expected, true) . "\n  ottenuto: " . var_export($actual, true) . "\n";
        $FAILED++;
    }
}

// ── Test 1: risoluzione del nome del connector ────────────────────────────────

assert_same(
    'HomepageLockEditClassConnector',
    LockEditConnectorFactory::connectorClassName('', 'homepage'),
    "connectorClassName('', 'homepage') risolve per class identifier"
);
assert_same(
    'PaginaSitoLockEditClassConnector',
    LockEditConnectorFactory::connectorClassName('', 'pagina_sito'),
    "connectorClassName('', 'pagina_sito') risolve per class identifier"
);
assert_same(
    'NewsLockEditClassConnector',
    LockEditConnectorFactory::connectorClassName('', 'news'),
    "connectorClassName('', 'news') risolve per class identifier"
);
assert_same(
    null,
    LockEditConnectorFactory::connectorClassName('', 'dataset'),
    "connectorClassName('', 'dataset') ritorna null: nessun connector"
);

// ── Test 2: canLockEdit() con un utente senza limiti ──────────────────────────
// Un utente con opencity_locked_editor senza limitazioni (admin) non deve poter
// aprire il LockEdit su un oggetto di una classe senza connector.

$admin = eZUser::fetch(14);
if ($admin instanceof eZUser) {
    eZUser::setCurrentlyLoggedInUser($admin, 14);

    $datasets = eZContentObjectTreeNode::subTreeByNodeID([
        'ClassFilterType'  => 'include',
        'ClassFilterArray' => ['dataset'],
        'Limit'            => 1,
        'AsObject'         => true,
    ], 2);
    if (!empty($datasets)) {
        $object = $datasets[0]->object();
        assert_same(false, LockEditConnectorFactory::hasConnector($object), 'hasConnector() è falso per un oggetto dataset');
        assert_same(false, LockEditConnector::canLockEdit($object), 'canLockEdit() è falso per un oggetto dataset, anche senza limiti');
    } else {
        echo "[SKIP] nessun oggetto dataset nel sito: salto i controlli su canLockEdit()\n";
    }

    $homepage = eZContentObject::fetchByRemoteID('homepage');
    if ($homepage instanceof eZContentObject) {
        assert_same(true, LockEditConnectorFactory::hasConnector($homepage), 'hasConnector() è vero per la homepage');
    }
}

// ── Report ────────────────────────────────────────────────────────────────────

echo "\n";
echo "Risultato: $PASSED passati / " . ($PASSED + $FAILED) . " totali\n";

$script->shutdown($FAILED > 0 ? 1 : 0);
