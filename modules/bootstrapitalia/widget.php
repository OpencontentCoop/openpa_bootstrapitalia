<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$http = eZHTTPTool::instance();

$availableBuiltins = BuiltinAppFactory::fetchDescriptionIdentifierList();

$builtin = $Params['Identifier'] ?? null;
if (!$builtin || !in_array($builtin, $availableBuiltins)) {
    $tpl = eZTemplate::factory();
    $Result = [];
    $Result['path'] = [];
    $contentInfoArray = [
        'node_id' => null,
        'class_identifier' => null,
    ];
    $contentInfoArray['persistent_variable'] = [];
    if (is_array($tpl->variable('persistent_variable'))) {
        $contentInfoArray['persistent_variable'] = array_merge(
            $contentInfoArray['persistent_variable'],
            $tpl->variable('persistent_variable')
        );
    }
    $list = [];
    foreach ($availableBuiltins as $builtin) {
        $list[$builtin] = BuiltinAppFactory::instanceByIdentifier($builtin);
    }
    $tpl->setVariable('list', $list);
    $Result['content_info'] = $contentInfoArray;
    $Result['content'] = $tpl->fetch('design:bootstrapitalia/widget.tpl');
} else {

    $app = BuiltinAppFactory::instanceByIdentifier($builtin);
    if ($http->hasPostVariable('StoreConfig')) {
        $configValue = $http->postVariable('Config', '');
        $app->setCustomConfig($configValue);
        $Module->redirectTo('bootstrapitalia/widget/' . $builtin);
        return;
    }

    $app->setDeployEnv(BuiltinApp::ENV_TEST);
    $Result = $app->getModuleResult($Module);
}
