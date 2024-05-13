<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$http = eZHTTPTool::instance();

$app = new BuiltinApp('support', 'Request assistance');

if ($http->hasPostVariable('StoreConfig')) {
    $configValue = $http->postVariable('Config', '');
    $app->setCustomConfig($configValue);
    $Module->redirectTo($Module->Name);
    return;
}

$Result = $app->getModuleResult();