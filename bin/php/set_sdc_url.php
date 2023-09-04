<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => '',
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions(
    '[url:]',
    '',
    [
        'url' => 'Esempio https://servizi.comune.bugliano.pi.it/lang',
    ]
);
$script->initialize();
$script->setUseDebugAccumulators(true);

$cli = eZCLI::instance();
$helper = new eZCacheHelper(
    $cli = eZCLI::instance(),
    $script
);

try {
    if ($options['url']){
        $cli->output(' - set access url');
        StanzaDelCittadinoBridge::factory()->setTenantByUrl($options['url']);
        OpenPABootstrapItaliaOperators::setCurrentPartner('comunweb');
        $helper->clearItems(eZCache::fetchList(), false);
        eZExtension::getHandlerClass(new ezpExtensionOptions([
            'iniFile' => 'site.ini',
            'iniSection' => 'ContentSettings',
            'iniVariable' => 'StaticCacheHandler',
        ]))->generateCache(true, false, false, false);
    }
} catch (Throwable $e) {
    $cli->error($e->getMessage());
}

$script->shutdown();

