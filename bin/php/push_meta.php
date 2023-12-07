<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Push meta to sdc tenant\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions(
    '[user:][password:]',
    '',
    []
);
$script->initialize();
$script->setUseDebugAccumulators(true);

try {
    $user = $options['user'] or die('Missing user');
    $password = $options['password'] or die('Missing password');
    StanzaDelCittadinoBridge::factory()->updateSiteInfo($options['user'], $options['password']);

    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}