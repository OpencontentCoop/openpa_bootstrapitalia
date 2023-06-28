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
    '[user:]',
    '',
    [
        'user' => 'username (default: admin)',
    ]
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();

/** @var eZUser $admin */
$admin = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($admin, $admin->attribute('contentobject_id'));

try {

    $username = $options['user'] ?? 'admin';
    $user = eZUser::fetchByName($username);
    if($user instanceof eZUser) {
        $versions = eZContentObjectVersion::fetchForUser($user->id());
        $cli->output('Remove ' . count($versions) . ' drafts');
        $db = eZDB::instance();
        $db->begin();
        foreach ($versions as $version) {
            $cli->output('.', false);
            $version->removeThis();
        }
        $db->commit();
        $cli->output();
    }

    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}
