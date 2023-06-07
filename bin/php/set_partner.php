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
    '[id:]',
    '',
    [
        'id' => 'Identificativo partner',
    ]
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();

$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));
$partners = OpenPAINI::variable('CreditsSettings', 'Partners', []);
try {
    $selectedPartner = $options['id'];
    if (empty($selectedPartner)){
        throw new Exception('Seleziona un id tra: ' . implode(', ', array_keys($partners)));
    }
    if (!isset($partners[$selectedPartner])){
        throw new Exception('Partner non configurato. Seleziona tra: ' . implode(', ', array_keys($partners)));
    }

    OpenPABootstrapItaliaOperators::setCurrentPartner($selectedPartner);

    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}
