<?php

require 'autoload.php';

$script = eZScript::instance([
        'description' => "",
        'use-session' => false,
        'use-modules' => true,
        'use-extensions' => true,
    ]
);

$script->startup();

$options = $script->getOptions(
    '[url:]',
    '',
    [
        'url' => 'Url istanza opencity da cui importare',
    ]
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();

try {
    $url = $options['url'];
    $cli->output('Importo da ' . $url, false);
    $error = false;
    try {
        $import = SiteInfo::importFromUrl($url);
    } catch (Exception $e) {
        $import = false;
        $error = $e->getMessage();
    }
    if (SiteInfo::importFromUrl($url)) {
        $cli->output(' OK!');
    } else {
        $cli->error(' ERROR! ' . $error);
    }

    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}
