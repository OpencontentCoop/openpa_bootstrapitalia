<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Install service by identifier\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions(
    '[identifiers:]',
    '',
    [
        'identifiers' => 'Comma separated identifiers'
    ]
);
$script->initialize();
$script->setUseDebugAccumulators(true);

$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

try {
    $identifiers = $options['identifiers'] ?? die('Missing identifiers');
    $identifiers = explode(',', $identifiers);
    $bridge = StanzaDelCittadinoBridge::factory();
    foreach ($identifiers as $identifier){
        $url = $bridge->importServiceByIdentifier($identifier);
        eZCLI::instance()->output($url);
    }

    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}