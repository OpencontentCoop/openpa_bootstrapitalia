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

$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

try {
    $url = $options['url'];
    $cli->output('Importo da ' . $url, false);
    $error = false;
    try {
        $import = SiteInfo::importFromUrl($url, true);
    } catch (Exception $e) {
        $import = false;
        $error = $e->getMessage();
    }
    if ($import) {
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
