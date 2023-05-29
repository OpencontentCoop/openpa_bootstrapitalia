<?php

$http = eZHTTPTool::instance();
$module = $Params['Module'];
$offset = $Params['Offset'];
$id = $Params['ID'];
$tpl = eZTemplate::factory();

if ($http->hasPostVariable('SatisfyEntrypoint') && eZUser::currentUser()->hasAccessTo('valuation', 'dashboard')['accessWord'] === 'yes'){
    OpenPABootstrapItaliaOperators::setSatisfyEntrypoint($http->postVariable('SatisfyEntrypoint'));
    $module->redirectTo('/valuation/dashboard/satisfy');
    return;
}

if ($id == 'satisfy' || !empty(OpenPABootstrapItaliaOperators::getSatisfyEntrypoint())){

    $tpl->setVariable('entrypoint_id', OpenPABootstrapItaliaOperators::getSatisfyEntrypoint());

    $Result = [];
    $Result['content'] = $tpl->fetch('design:valuation/satisfy-dashboard.tpl');
    $Result['path'] = [
        [
            'text' => ezpI18n::tr('bootstrapitalia/valuation', 'User feedbacks'),
            'url' => false
        ]
    ];
    $contentInfoArray = [
        'node_id' => null,
        'class_identifier' => null
    ];
    $contentInfoArray['persistent_variable'] = ['show_path' => false];
    if (is_array($tpl->variable('persistent_variable'))) {
        $contentInfoArray['persistent_variable'] = array_merge(
            $contentInfoArray['persistent_variable'],
            $tpl->variable('persistent_variable')
        );
    }
    $Result['content_info'] = $contentInfoArray;

}else {

    $id = (int)$Params['ID'];

    if (!is_numeric($offset)) {
        $offset = 0;
    }

    $object = eZContentObject::fetchByRemoteID('openpa-valuation');
    if (!$object) {
        if (eZINI::instance()->variable('DesignSettings', 'SiteDesign') === 'bootstrapitalia2'){
            $module->redirectTo('/valuation/dashboard/satisfy');
        }else{
            return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
        }
        return;
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
                if ($contentClassAttribute->attribute('identifier') == 'useful') {
                    $usefulId = (int)$contentClassAttribute->attribute('id');
                }
                if ($contentClassAttribute->attribute('identifier') == 'problem_type') {
                    $problemTypeId = (int)$contentClassAttribute->attribute('id');
                }
            }
        }

        $usefulCount = eZDB::instance()->arrayQuery(
            "SELECT COUNT(data_text), data_text  FROM ezinfocollection_attribute WHERE contentclass_attribute_id = $usefulId GROUP BY data_text;"
        );
        $problemTypeCount = eZDB::instance()->arrayQuery(
            "SELECT COUNT(data_text), data_text  FROM ezinfocollection_attribute WHERE contentclass_attribute_id = $problemTypeId GROUP BY data_text;"
        );

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
    $Result['path'] = [
        [
            'text' => ezpI18n::tr('bootstrapitalia/valuation', 'User feedbacks'),
            'url' => false
        ]
    ];
    $contentInfoArray = [
        'node_id' => null,
        'class_identifier' => null
    ];
    $contentInfoArray['persistent_variable'] = [
        'show_path' => true
    ];
    if (is_array($tpl->variable('persistent_variable'))) {
        $contentInfoArray['persistent_variable'] = array_merge(
            $contentInfoArray['persistent_variable'],
            $tpl->variable('persistent_variable')
        );
    }
    $Result['content_info'] = $contentInfoArray;
}