<?php
$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance(['description' => 'timing test', 'use-session' => false, 'use-modules' => true, 'use-extensions' => true]);
$script->startup();
$script->initialize();

$bannerBlockInDb = [
    'block_id'          => HomepageLockEditClassConnector::SECTION_BANNER,
    'name'              => 'Siti tematici di interesse pubblico',
    'type'              => 'ListaManuale',
    'view'              => 'lista_banner_color',
    'custom_attributes' => ['elementi_per_riga' => '3', 'color_style' => '', 'container_style' => '', 'intro_text' => ''],
    'valid_items' => [],
];

$ezClass = eZContentClass::fetchByIdentifier('homepage') ?: eZContentClass::fetchByIdentifier('edit_homepage');
$helper  = new \Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ConnectorHelper('lock_edit');
$connector = new class($ezClass, $helper) extends HomepageLockEditClassConnector {
    public static function getContentClass(): eZContentClass { return eZContentClass::fetchByIdentifier('homepage'); }
};

$rcLocal    = new ReflectionClass(LockEditClassConnector::class);
$propSource  = $rcLocal->getProperty('sourceBlocks');  $propSource->setAccessible(true);
$propCurrent = $rcLocal->getProperty('currentBlocks'); $propCurrent->setAccessible(true);
$findMethod  = $rcLocal->getMethod('findBlockById');   $findMethod->setAccessible(true);

$N = 50000;

// ── Senza fix: solo strict=true (ritorna null quando non in YAML) ─────────────
$propSource->setValue($connector, []);
$propCurrent->setValue($connector, [$bannerBlockInDb]);
$t = microtime(true);
for ($i = 0; $i < $N; $i++) {
    $findMethod->invoke($connector, HomepageLockEditClassConnector::SECTION_BANNER, true);
}
$msWithout = (microtime(true) - $t) * 1000;

// ── Con fix: strict=true + fallback strict=false ───────────────────────────────
$propSource->setValue($connector, []);
$propCurrent->setValue($connector, [$bannerBlockInDb]);
$t = microtime(true);
for ($i = 0; $i < $N; $i++) {
    $findMethod->invoke($connector, HomepageLockEditClassConnector::SECTION_BANNER, true)
        ?? $findMethod->invoke($connector, HomepageLockEditClassConnector::SECTION_BANNER, false);
}
$msWith = (microtime(true) - $t) * 1000;

echo "findBlockById x{$N} chiamate:\n";
echo "  Senza fix (strict=true, null):     " . round($msWithout, 2) . " ms totali\n";
echo "  Con fix   (strict=true + fallback): " . round($msWith, 2) . " ms totali\n";
echo "  Overhead per singola chiamata:      " . round(($msWith - $msWithout) / $N * 1000, 4) . " µs\n";
echo "\nNota: il salvataggio chiama mapSectionBanner() UNA SOLA VOLTA per salvataggio.\n";
echo "Overhead effettivo sul salvataggio: ~" . round(($msWith - $msWithout) / $N * 1000, 4) . " µs (irrilevante).\n";

$script->shutdown(0);
