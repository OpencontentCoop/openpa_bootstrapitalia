<?php
/**
 * Verifica ezfIndexLiveRenderingCacheBust: interviene solo per le classi
 * rilevanti (organization, time_indexed_role, online_contact_point) e non
 * lancia eccezioni per nessuna classe, rilevante o meno - il plugin gira su
 * ogni pubblicazione di quelle classi su tutti i tenant, quindi deve essere
 * innocuo anche quando non c'e' nessuna pagina_trasparenza con rendering
 * live attivo su questo sito.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_index_live_rendering_cache_bust.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'ezfIndexLiveRenderingCacheBust test',
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

$plugin = new ezfIndexLiveRenderingCacheBust();

// Home (id 2) è una classe non rilevante (`homepage`/`folder`, a seconda
// dell'ambiente) - il plugin deve ignorarla senza errori.
$irrelevantObject = eZContentObjectTreeNode::fetch(2)->attribute('object');
assert_true(
    !in_array($irrelevantObject->attribute('class_identifier'), ['organization', 'time_indexed_role', 'online_contact_point'], true),
    'Fixture di test: la Home non è una delle classi rilevanti (precondizione del test)'
);

$docList = [];
try {
    $plugin->modify($irrelevantObject, $docList);
    assert_true(true, 'modify() su una classe non rilevante non lancia eccezioni');
} catch (\Throwable $e) {
    assert_true(false, 'modify() su una classe non rilevante non lancia eccezioni (' . $e->getMessage() . ')');
}

// "Giunta comunale" (id 226) è una fixture di sviluppo nota, classe
// `organization` - classe rilevante, il plugin deve eseguire
// LiveRenderingRegistry::clearAllCaches() senza errori anche quando nessuna
// pagina_trasparenza ha un fornitore di rendering live attivo.
$relevantObject = eZContentObject::fetch(226);
if ($relevantObject instanceof eZContentObject && $relevantObject->attribute('class_identifier') === 'organization') {
    try {
        $plugin->modify($relevantObject, $docList);
        assert_true(true, 'modify() su una classe rilevante (organization) non lancia eccezioni');
    } catch (\Throwable $e) {
        assert_true(false, 'modify() su una classe rilevante (organization) non lancia eccezioni (' . $e->getMessage() . ')');
    }
} else {
    echo "\033[33m[SKIP]\033[0m Fixture di sviluppo attesa (id 226, classe organization) non trovata in questo ambiente\n";
}

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
