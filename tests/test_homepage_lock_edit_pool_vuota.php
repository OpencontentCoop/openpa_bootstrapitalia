<?php
/**
 * Test: HomepageLockEditClassConnector — pool vuota non distrugge la struttura homepage
 *
 * Verifica i fix del piano v2 (doc/fix-lockedit-pool-vuota-v2.md).
 * Tutti i test seguono TDD: scritti prima dell'implementazione, verificati in RED.
 *
 * Run:
 *   docker compose exec -T app sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_homepage_lock_edit_pool_vuota.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'HomepageLockEditClassConnector pool-vuota test v2',
    'use-session'    => false,
    'use-modules'    => true,
    'use-extensions' => true,
]);
$script->startup();
$script->initialize();

// ── Helpers ───────────────────────────────────────────────────────────────────

$PASSED = 0;
$FAILED = 0;

function assert_true(bool $condition, string $label): void
{
    global $PASSED, $FAILED;
    if ($condition) {
        echo "\033[32m[PASS]\033[0m $label\n";
        $PASSED++;
    } else {
        echo "\033[31m[FAIL]\033[0m $label\n";
        $FAILED++;
    }
}

function assert_eq($actual, $expected, string $label): void
{
    $ok = $actual === $expected;
    assert_true($ok, "$label"
        . ($ok ? '' : " (atteso=" . json_encode($expected) . " ottenuto=" . json_encode($actual) . ")"));
}

function invoke(object $obj, string $method, array $args = [])
{
    $rm = new ReflectionMethod($obj, $method);
    $rm->setAccessible(true);
    return $rm->invokeArgs($obj, $args);
}

// ── Setup ─────────────────────────────────────────────────────────────────────

$ezClass = eZContentClass::fetchByIdentifier('homepage')
    ?: eZContentClass::fetchByIdentifier('edit_homepage');
$helper  = new \Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ConnectorHelper('lock_edit');

$conn = new class($ezClass, $helper) extends HomepageLockEditClassConnector {
    public static function getContentClass(): eZContentClass {
        return eZContentClass::fetchByIdentifier('homepage')
            ?: eZContentClass::fetchByIdentifier('edit_homepage');
    }
};

$rcBase    = new ReflectionClass(LockEditClassConnector::class);
$propSrc   = $rcBase->getProperty('sourceBlocks');  $propSrc->setAccessible(true);
$propCurr  = $rcBase->getProperty('currentBlocks'); $propCurr->setAccessible(true);
$propCont  = new ReflectionProperty(
    \Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector::class, 'content'
);
$propCont->setAccessible(true);

// Blocchi di riferimento (struttura minima senza valid_items)
$mkBlock = function(string $id, string $type, string $name = '') {
    return [
        'block_id' => $id,
        'type'     => $type,
        'name'     => $name,
        'view'     => 'default',
        'custom_attributes' => [
            'elementi_per_riga' => '3',
            'color_style'       => '',
            'container_style'   => '',
            'intro_text'        => '',
            'image'             => '',
        ],
        'valid_items' => [],
    ];
};

$bannerBlock  = $mkBlock(HomepageLockEditClassConnector::SECTION_BANNER,       'ListaManuale', 'Siti tematici');
$newsBlock    = $mkBlock(HomepageLockEditClassConnector::SECTION_NEWS,         'ListaAutomatica', 'Notizie');
$eventsBlock  = $mkBlock(HomepageLockEditClassConnector::SECTION_NEXT_EVENTS,  'Eventi', 'Eventi');
$mgmtBlock    = $mkBlock(HomepageLockEditClassConnector::SECTION_MANAGEMENT,   'ListaManuale', 'Amministrazione');
$placeBlock   = $mkBlock(HomepageLockEditClassConnector::SECTION_PLACE,        'ListaManuale', 'Luoghi');
$topicBlock   = $mkBlock(HomepageLockEditClassConnector::SECTION_TOPIC,        'Argomenti', 'Argomenti');
$searchBlock  = $mkBlock(HomepageLockEditClassConnector::SEARCH,               'Ricerca', 'Ricerca');
$singolBlock  = $mkBlock(HomepageLockEditClassConnector::MAIN_NEWS,            'Singolo', '');

// Blocco Singolo con 1 valid_item (come se pool avesse 1 elemento)
$singolBlockWithItem = array_merge($singolBlock, ['valid_items' => ['remote-id-notizia']]);

// ── TEST 1: Pool vuota, blocco in XML → add_section_banner=true ───────────────
echo "\n=== TEST 1: getData() — add_section_* true se blocco in XML (pool vuota) ===\n";

$connEmpty = new class($ezClass, $helper) extends HomepageLockEditClassConnector {
    public static function getContentClass(): eZContentClass {
        return eZContentClass::fetchByIdentifier('homepage')
            ?: eZContentClass::fetchByIdentifier('edit_homepage');
    }
    // Pool vuota: tutti i map*Relations restituiscono null/false
    protected function mapListaManualeToRelations($block): ?array  { return null; }
    protected function mapListaAutomaticaToBoolean($block): bool   { return false; }
    protected function mapEventiToBoolean($block): bool            { return false; }
    protected function mapSingoloToRelation($block): ?array        { return null; }
    protected function mapArgomentiToRelations($block): array      { return []; }
    protected function mapMenuArgomentiToRelations(): array        { return []; }
    protected function mapCustomAttributeImageToRelation($block, $key = 'image'): ?array { return null; }
    protected function mapRicercaToRelations($block): ?array       { return null; }
};

$rcE   = new ReflectionClass(LockEditClassConnector::class);
$pSrcE = $rcE->getProperty('sourceBlocks');  $pSrcE->setAccessible(true);
$pCrrE = $rcE->getProperty('currentBlocks'); $pCrrE->setAccessible(true);
$pCntE = new ReflectionProperty(
    \Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector::class, 'content'
);
$pCntE->setAccessible(true);

$allBlocks = [$bannerBlock, $newsBlock, $eventsBlock, $mgmtBlock, $placeBlock, $topicBlock, $searchBlock, $singolBlock];
$pSrcE->setValue($connEmpty, $allBlocks);
$pCrrE->setValue($connEmpty, $allBlocks);
$pCntE->setValue($connEmpty, [
    'page' => ['content' => ['global' => ['blocks' => $allBlocks]]],
    'notice_header_link' => ['content' => ''],
    'notice_header_text' => ['content' => ''],
]);

$data = invoke($connEmpty, 'getData');

assert_true($data['add_section_banner'] === true,
    "T1a: add_section_banner=true quando pool vuota ma blocco in XML");
assert_true($data['add_section_news'] === true,
    "T1b: add_section_news=true quando pool vuota ma blocco SECTION_NEWS in XML");
assert_true($data['add_section_events'] === true,
    "T1c: add_section_events=true quando pool vuota ma blocco SECTION_NEXT_EVENTS in XML");
assert_true($data['add_section_search'] === true,
    "T1d: add_section_search=true quando pool vuota ma blocco SEARCH in XML");

// ── TEST 2: Toggle OFF → blocco rimosso ───────────────────────────────────────
echo "\n=== TEST 2: mapSectionBanner() — toggle OFF rimuove il blocco ===\n";

$propSrc->setValue($conn, [$bannerBlock]);
$propCurr->setValue($conn, [$bannerBlock]);

$r = invoke($conn, 'mapSectionBanner', [['add_section_banner' => 'false']]);
assert_eq($r, null, "T2a: toggle 'false' (stringa Alpaca) → null");

$r = invoke($conn, 'mapSectionBanner', [['add_section_banner' => false]]);
assert_eq($r, null, "T2b: toggle false (bool) → null");

$r = invoke($conn, 'mapSectionBanner', [[]]);
assert_eq($r, null, "T2c: toggle assente → null");

// ── TEST 3: Toggle ON, items assenti → blocco preservato (non null) ───────────
echo "\n=== TEST 3: mapSectionBanner() — toggle ON, items assenti → preservato ===\n";

$r = invoke($conn, 'mapSectionBanner', [['add_section_banner' => 'true', 'title_banner' => 'Test']]);
assert_true($r !== null, "T3a: toggle 'true' senza items → blocco preservato (non null)");
assert_eq($r['type'] ?? null, 'ListaManuale', "T3b: tipo = ListaManuale");
assert_eq($r['valid_items'] ?? null, [], "T3c: valid_items=[] (pool vuota, blocco struttura preservata)");

// ── TEST 4: Toggle ON, items nel POST → usa i nuovi items ─────────────────────
echo "\n=== TEST 4: mapSectionBanner() — toggle ON con items → items usati ===\n";

// ID 999999 non esiste → remoteIdList = [] → ma il blocco è restituito
$r = invoke($conn, 'mapSectionBanner', [[
    'add_section_banner' => 'true',
    'section_banner'     => [['id' => '999999']],
    'title_banner'       => 'Titolo',
]]);
assert_true($r !== null, "T4a: blocco restituito quando POST ha items");
assert_eq($r['valid_items'] ?? null, [], "T4b: items non esistenti in DB → valid_items=[]");

// ── TEST 5: Management assente, blocco in XML → preservato ────────────────────
echo "\n=== TEST 5: mapSectionManagement() — campo assente, blocco in XML → preservato ===\n";

$propSrc->setValue($conn, [$mgmtBlock]);
$propCurr->setValue($conn, [$mgmtBlock]);

$r = invoke($conn, 'mapSectionManagement', [['section_management' => []], false]);
assert_true($r !== null, "T5a: section_management assente/vuoto, blocco in XML → preservato");

$propCurr->setValue($conn, []); // blocco NON in XML
$r = invoke($conn, 'mapSectionManagement', [['section_management' => []], false]);
assert_eq($r, null, "T5b: blocco non in XML → null (non crea blocchi inesistenti)");

// ── TEST 6: Places assente, blocco in XML → preservato ───────────────────────
echo "\n=== TEST 6: mapSectionPlaces() — campo assente, blocco in XML → preservato ===\n";

$propSrc->setValue($conn, [$placeBlock]);
$propCurr->setValue($conn, [$placeBlock]);

$r = invoke($conn, 'mapSectionPlaces', [[]]);
assert_true($r !== null, "T6a: section_place assente, blocco in XML → preservato");

$propCurr->setValue($conn, []);
$r = invoke($conn, 'mapSectionPlaces', [[]]);
assert_eq($r, null, "T6b: blocco non in XML → null");

// ── TEST 7: Topics assente, blocco in XML → preservato ───────────────────────
echo "\n=== TEST 7: mapSectionTopics() — campo assente, blocco in XML → preservato ===\n";

$propSrc->setValue($conn, [$topicBlock]);
$propCurr->setValue($conn, [$topicBlock]);

$r = invoke($conn, 'mapSectionTopics', [[]]);
assert_true($r !== null, "T7a: section_topic assente, blocco in XML → preservato");

$propCurr->setValue($conn, []);
$r = invoke($conn, 'mapSectionTopics', [[]]);
assert_eq($r, null, "T7b: blocco non in XML → null");

// ── TEST 8: News automatica con pool vuota ────────────────────────────────────
echo "\n=== TEST 8: mapSectionNews() — modalità automatica, pool vuota ===\n";

$propSrc->setValue($conn, [$newsBlock]);
$propCurr->setValue($conn, [$newsBlock]);

$r = invoke($conn, 'mapSectionNews', [[
    'add_section_news'    => 'true',
    'section_latest_news' => 'true',
    'title_news'          => 'Notizie',
]]);
assert_true($r !== null, "T8a: notizie automatiche → blocco restituito");
assert_eq($r['type'] ?? null, 'ListaAutomatica', "T8b: tipo = ListaAutomatica (da sourceBlocks)");

// ── TEST 9: News manuale, pool vuota → fallback blocco corrente ───────────────
echo "\n=== TEST 9: mapSectionNews() — modalità manuale, pool vuota → fallback ===\n";

$newsManualBlock = array_merge($newsBlock, ['type' => 'ListaManuale']);
$propSrc->setValue($conn, [$newsBlock]);
$propCurr->setValue($conn, [$newsManualBlock]);

$r = invoke($conn, 'mapSectionNews', [[
    'add_section_news'    => 'true',
    'section_latest_news' => 'false',
    // section_news assente — pool vuota
    'title_news'          => 'Notizie',
]]);
assert_true($r !== null, "T9a: notizie manuali, pool vuota → blocco preservato (fallback)");
assert_eq($r['block_id'] ?? null, HomepageLockEditClassConnector::SECTION_NEWS,
    "T9b: block_id corretto");

// ── TEST 10: News toggle OFF → null ──────────────────────────────────────────
echo "\n=== TEST 10: mapSectionNews() — toggle OFF → null ===\n";

$r = invoke($conn, 'mapSectionNews', [['add_section_news' => 'false']]);
assert_eq($r, null, "T10a: toggle notizie OFF → null");

// ── TEST 11: Events toggle OFF → null ────────────────────────────────────────
echo "\n=== TEST 11: mapSectionEvents() — toggle OFF → null ===\n";

$propSrc->setValue($conn, [$eventsBlock]);
$propCurr->setValue($conn, [$eventsBlock]);

$r = invoke($conn, 'mapSectionEvents', [['add_section_events' => 'false', 'title_events' => '']]);
assert_eq($r, null, "T11a: toggle eventi OFF → null");

// ── TEST 12: Events automatici, pool vuota → preservato ──────────────────────
echo "\n=== TEST 12: mapSectionEvents() — automatici, pool vuota → preservato ===\n";

$r = invoke($conn, 'mapSectionEvents', [[
    'add_section_events'  => 'true',
    'section_next_events' => 'true',
    'title_events'        => 'Events',
]]);
assert_true($r !== null, "T12a: eventi automatici → blocco restituito");

// ── TEST 13: mapSectionSearch toggle ON, items assenti → preservato ───────────
echo "\n=== TEST 13: mapSectionSearch() — toggle ON, items assenti → preservato ===\n";

$propSrc->setValue($conn, [$searchBlock]);
$propCurr->setValue($conn, [$searchBlock]);

$r = invoke($conn, 'mapSectionSearch', [['add_section_search' => 'true']]);
assert_true($r !== null, "T13a: ricerca toggle ON senza items → blocco preservato");

$r = invoke($conn, 'mapSectionSearch', [['add_section_search' => 'false']]);
assert_eq($r, null, "T13b: ricerca toggle OFF → null");

// ── TEST 14: Null-check sourceBlocks mancante — no crash ─────────────────────
echo "\n=== TEST 14: null-check sourceBlocks mancante — no crash ===\n";

$propSrc->setValue($conn, []); // YAML vuoto
$propCurr->setValue($conn, [$newsBlock]);

$crashed = false;
try {
    $r = invoke($conn, 'mapSectionNews', [['add_section_news' => 'true', 'section_latest_news' => 'true', 'title_news' => '']]);
} catch (Throwable $e) {
    $crashed = true;
}
assert_true(!$crashed, "T14a: mapSectionNews con sourceBlocks vuoti → no crash");

$propSrc->setValue($conn, []); // YAML vuoto
$crashed = false;
try {
    $r = invoke($conn, 'mapSectionEvents', [['add_section_events' => 'true', 'section_next_events' => 'true', 'title_events' => '']]);
} catch (Throwable $e) {
    $crashed = true;
}
assert_true(!$crashed, "T14b: mapSectionEvents con sourceBlocks vuoti → no crash");

// ── TEST 15: Regressione — salvataggio normale con items nel POST ─────────────
echo "\n=== TEST 15: regressione — salvataggio con items nel POST funziona ===\n";

$propSrc->setValue($conn, [$bannerBlock]);
$propCurr->setValue($conn, [$bannerBlock]);

// Quando section_banner ha items reali (ID esistenti in DB), valid_items viene popolato
// Usiamo ID 999999 (non esiste) per verificare che la logica giri, anche se restituisce []
$r = invoke($conn, 'mapSectionBanner', [[
    'add_section_banner' => 'true',
    'section_banner'     => [['id' => '229'], ['id' => '230']],
    'title_banner'       => 'Banner',
]]);
assert_true($r !== null, "T15a: banner con items nel POST → blocco restituito");
assert_eq($r['name'] ?? null, 'Banner', "T15b: title_banner aggiornato correttamente");

// ── Report ─────────────────────────────────────────────────────────────────────

echo "\n";
$total = $PASSED + $FAILED;
echo "Risultato: \033[" . ($FAILED > 0 ? '31' : '32') . "m$PASSED/$total passati\033[0m\n";

$script->shutdown($FAILED > 0 ? 1 : 0);
