<?php

$module = $Params['Module'];
$http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();

if (eZUser::currentUser()->hasAccessTo('openpa', 'roles')['accessWord'] !== 'yes'){
    return $module->handleError(eZError::KERNEL_ACCESS_DENIED, 'kernel');
}

$class = eZContentClass::fetchByIdentifier('time_indexed_role');
if (!$class instanceof eZContentClass){
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}
$rootTagId = false;
/** @var eZContentClassAttribute $classAttribute */
foreach ($class->dataMap() as $classAttribute){
    if ($classAttribute->attribute('data_type_string') == eZTagsType::DATA_TYPE_STRING){
        $rootTagId = $classAttribute->attribute(eZTagsType::SUBTREE_LIMIT_FIELD);
    }
}
if (!$rootTagId){
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

$rootTag = eZTagsObject::fetch($rootTagId);
if (!$rootTag instanceof eZTagsObject){
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

$tpl->setVariable('root_tag', $rootTag);

$Result = array();
$Result['content'] = $tpl->fetch('design:bootstrapitalia/role_list.tpl');
$Result['path'] = array(
    array(
        'text' => $rootTag->attribute('keyword'),
        'url' => false
    )
);
$contentInfoArray = array(
    'node_id' => null,
    'class_identifier' => null
);
$contentInfoArray['persistent_variable'] = array(
    'show_path' => true
);
if (is_array($tpl->variable('persistent_variable'))) {
    $contentInfoArray['persistent_variable'] = array_merge($contentInfoArray['persistent_variable'], $tpl->variable('persistent_variable'));
}
$Result['content_info'] = $contentInfoArray;