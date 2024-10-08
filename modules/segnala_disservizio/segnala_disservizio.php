<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$http = eZHTTPTool::instance();

$app = BuiltinAppFactory::instanceByIdentifier('inefficiency');

if ($http->hasPostVariable('StoreConfig')) {
    $configValue = $http->postVariable('Config', '');
    $app->setCustomConfig($configValue);
    $Module->redirectTo($Module->Name);
    return;
}

$Result = $app->getModuleResult($Module);