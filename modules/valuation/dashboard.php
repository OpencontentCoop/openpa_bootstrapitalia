<?php

$http = eZHTTPTool::instance();
$module = $Params['Module'];
$offset = $Params['Offset'];
$id = (int)$Params['ID'];
$tpl = eZTemplate::factory();

if (!is_numeric($offset)) {
    $offset = 0;
}

$object = eZContentObject::fetchByRemoteID('openpa-valuation');
if (!$object) {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

if ($id > 0 && $collection = eZInformationCollection::fetch($id)) {
    $tpl->setVariable('collection', $collection);
} else {
    $limit = 50;
    $collections = eZInformationCollection::fetchCollectionsList(
        $object->attribute('id'), /* object id */
        false,
        false,
        ['limit' => $limit, 'offset' => $offset],
        ['created', false]
    );
    $collectionCount = eZInformationCollection::fetchCollectionsCount($object->attribute('id'));
    $viewParameters = ['offset' => $offset];

    $collectAttributes = [];
    $attributes = $object->contentObjectAttributes();
    $usefulId = $problemTypeId = 0;
    foreach ($attributes as $contentObjectAttribute) {
        $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
        if ($contentClassAttribute->attribute('is_information_collector')) {
            $collectAttributes[$contentClassAttribute->attribute('identifier')] = $contentClassAttribute;
            if ($contentClassAttribute->attribute('identifier') == 'useful'){
                $usefulId = (int)$contentClassAttribute->attribute('id');
            }
            if ($contentClassAttribute->attribute('identifier') == 'problem_type'){
                $problemTypeId = (int)$contentClassAttribute->attribute('id');
            }
        }
    }

    $usefulCount = eZDB::instance()->arrayQuery("SELECT COUNT(data_text), data_text  FROM ezinfocollection_attribute WHERE contentclass_attribute_id = $usefulId GROUP BY data_text;");
    $problemTypeCount = eZDB::instance()->arrayQuery("SELECT COUNT(data_text), data_text  FROM ezinfocollection_attribute WHERE contentclass_attribute_id = $problemTypeId GROUP BY data_text;");

    $tpl->setVariable('limit', $limit);
    $tpl->setVariable('view_parameters', $viewParameters);
    $tpl->setVariable('object', $object);
    $tpl->setVariable('collection_array', $collections);
    $tpl->setVariable('collection_count', $collectionCount);
    $tpl->setVariable('useful_count', $usefulCount);
    $tpl->setVariable('problem_type_count', $problemTypeCount);
    $tpl->setVariable('attributes', $collectAttributes);
}

$Result = [];
$Result['content'] = $tpl->fetch('design:valuation/dashboard.tpl');
$Result['path'] = array(
    array(
        'text' => ezpI18n::tr('bootstrapitalia/valuation', 'User feedbacks'),
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