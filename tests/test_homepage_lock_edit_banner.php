<?php
/**
 * Test: HomepageLockEditClassConnector - blocco banner con source block mancante
 *
 * Bug: findBlockById(SECTION_BANNER, strict=true) ritorna null se il blocco non è
 * nel YAML dell'installer. PHP converte null→array senza 'view'. Page::validate()
 * lancia "Missing field view in $block N in input field page".
 *
 * Fix: fallback a findBlockById(SECTION_BANNER, strict=false) per leggere la view
 * dai currentBlocks (DB) quando i source blocks non la hanno.
 *
 * Run:
 *   docker compose exec -T app sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_homepage_lock_edit_banner.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'HomepageLockEditClassConnector banner test',
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

// ── Setup ─────────────────────────────────────────────────────────────────────

// Blocco SECTION_BANNER come esiste nel DB (ita-IT, versione corrente con items)
$bannerBlockInDb = [
    'block_id'          => HomepageLockEditClassConnector::SECTION_BANNER,
    'name'              => 'Siti tematici di interesse pubblico',
    'type'              => 'ListaManuale',
    'view'              => 'lista_banner_color',
    'custom_attributes' => [
        'elementi_per_riga' => '3',
        'color_style'       => '',
        'container_style'   => '',
        'intro_text'        => '',
    ],
    'valid_items' => [],
];

// Subclass minimale: soddisfa l'interfaccia passando oggetti reali.
// Il helper non viene usato da mapSectionBanner() perché sourceBlocks è pre-impostato
// via reflection, quindi fetchSourceBlocks() non viene mai chiamato.
$ezClass = eZContentClass::fetchByIdentifier('homepage')
    ?: eZContentClass::fetchByIdentifier('edit_homepage');
$helper = new \Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ConnectorHelper('lock_edit');

$connector = new class($ezClass, $helper) extends HomepageLockEditClassConnector {
    public static function getContentClass(): eZContentClass {
        return eZContentClass::fetchByIdentifier('homepage');
    }
};

// Accesso ai campi protetti di LockEditClassConnector
$rc = new ReflectionClass(LockEditClassConnector::class);

$propSource  = $rc->getProperty('sourceBlocks');
$propCurrent = $rc->getProperty('currentBlocks');
$propSource->setAccessible(true);
$propCurrent->setAccessible(true);

// Accesso al metodo privato
$mapMethod = new ReflectionMethod(HomepageLockEditClassConnector::class, 'mapSectionBanner');
$mapMethod->setAccessible(true);

// Input form: un item nel blocco banner.
// ID 999999 non esiste nel DB → eZContentObject::fetch() → null → valid_items rimane []
$formData = [
    'title_banner'   => 'Siti tematici',
    'section_banner' => [['id' => 999999]],
];

// ── Test 1: SECTION_BANNER assente dai source blocks → deve comunque avere 'view' ──
// Riproduce il bug di Arco: source blocks = YAML installer (senza SECTION_BANNER),
// current blocks = DB del tenant (con SECTION_BANNER configurato con items)

$propSource->setValue($connector, []);                  // YAML installer: no SECTION_BANNER
$propCurrent->setValue($connector, [$bannerBlockInDb]); // DB: blocco configurato

$result = $mapMethod->invoke($connector, $formData);

assert_true(
    is_array($result),
    "mapSectionBanner() ritorna un array anche con source blocks vuoti"
);

assert_true(
    isset($result['view']) && $result['view'] !== '' && $result['view'] !== null,
    "mapSectionBanner() produce un blocco con 'view' valorizzato quando SECTION_BANNER non è nei source blocks (fix del bug ticket #30647)"
);

assert_true(
    isset($result['block_id']) && $result['block_id'] === HomepageLockEditClassConnector::SECTION_BANNER,
    "mapSectionBanner() preserva il block_id corretto"
);

assert_true(
    $result['type'] === 'ListaManuale',
    "mapSectionBanner() imposta type=ListaManuale"
);

assert_true(
    array_key_exists('custom_attributes', $result),
    "mapSectionBanner() include custom_attributes"
);

// ── Test 2: SECTION_BANNER presente nei source blocks → usa la view dal source ──

$propSource->setValue($connector, [$bannerBlockInDb]);
$propCurrent->setValue($connector, [$bannerBlockInDb]);

$result2 = $mapMethod->invoke($connector, $formData);

assert_true(
    isset($result2['view']) && $result2['view'] === 'lista_banner_color',
    "mapSectionBanner() usa la view dal source block quando disponibile"
);

// ── Test 3: nessun banner nel form → ritorna null (comportamento invariato) ──

$result3 = $mapMethod->invoke($connector, ['section_banner' => []]);

assert_true(
    $result3 === null,
    "mapSectionBanner() ritorna null quando section_banner è vuoto"
);

// ── Report ────────────────────────────────────────────────────────────────────

echo "\n";
echo "Risultato: $PASSED passati / " . ($PASSED + $FAILED) . " totali\n";

$script->shutdown($FAILED > 0 ? 1 : 0);
