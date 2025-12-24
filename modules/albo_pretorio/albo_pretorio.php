<?php

/** @var eZModule $module */
$module = $Params['Module'];
$archive = $Params['Parameters'][0] == "archivio";
$tpl = eZTemplate::factory();

if (isset($Params['Parameters'][0]) && $Params['Parameters'][0] !== "archivio") {
    return $module->handleError(eZError::KERNEL_NOT_FOUND, 'kernel');
}

$tpl->setVariable('archive', $archive);
$documentsObject = eZContentObject::fetchByRemoteID('cb945b1cdaad4412faaa3a64f7cdd065');

if ($documentsObject instanceof eZContentObject) {
    $tpl->setVariable('documents_node_id', $documentsObject->mainNodeID());
} else {
    return $module->handleError(eZError::KERNEL_NOT_FOUND, 'kernel');
}

$mainTag = eZTagsObject::fetchByRemoteID('984c6235761dac258fe8c245541095fa');

if ($mainTag instanceof eZTagsObject) {
    $tpl->setVariable('main_tag_id', $mainTag->attribute('id'));
} else {
    return $module->handleError(eZError::KERNEL_NOT_FOUND, 'kernel');
}

$setupObject = eZContentObject::fetchByRemoteID('setup_albo');
$tpl->setVariable('setup_object', $setupObject);

$Result = [];
$Result['content'] = $tpl->fetch('design:bootstrapitalia/albo-pretorio/list.tpl');
$Result['content_info'] = [
    'node_id' => null,
    'class_identifier' => null,
    'persistent_variable' => [
        'show_path' => false,
    ],
];
if (is_array($tpl->variable('persistent_variable'))) {
    $Result['content_info']['persistent_variable'] = array_merge(
        $Result['content_info']['persistent_variable'],
        $tpl->variable('persistent_variable')
    );
}
$Result['path'] = array(
    array(
        'text' => 'Albo Pretorio',
        'url' => false
    )
);