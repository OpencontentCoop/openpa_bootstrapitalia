<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$http = eZHTTPTool::instance();

$availableBuiltins = BuiltinApp::fetchIdentifierList();

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
    $tpl->setVariable('list', BuiltinApp::fetchList());
    $Result['content_info'] = $contentInfoArray;
    $Result['content'] = $tpl->fetch('design:bootstrapitalia/widget.tpl');
} else {
    $Result = BuiltinApp::instanceByIdentifier($builtin)->getModuleResult($Module);
}
