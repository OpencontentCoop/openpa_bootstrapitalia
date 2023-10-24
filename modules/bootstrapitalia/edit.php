<?php

$module = $Params['Module'];
$http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();
$identifier = $Params['Identifier'];
$dashboards = BootstrapItaliaEditDashboard::getDashboards($identifier);

if ($http->hasGetVariable('dashboards')) {
    header('Content-Type: application/json');
    echo json_encode($dashboards);
    eZExecution::cleanExit();
}

if (empty($dashboards)){
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

$Result = [];
$Result['content'] = $tpl->fetch('design:bootstrapitalia/edit.tpl');
$Result['path'] = [
    [
        'text' => 'Edit',
        'url' => false,
    ],
];
$contentInfoArray = [
    'node_id' => null,
    'class_identifier' => null,
];
$contentInfoArray['persistent_variable'] = [
    'show_path' => true,
];
if (is_array($tpl->variable('persistent_variable'))) {
    $contentInfoArray['persistent_variable'] = array_merge(
        $contentInfoArray['persistent_variable'],
        $tpl->variable('persistent_variable')
    );
}
$Result['content_info'] = $contentInfoArray;