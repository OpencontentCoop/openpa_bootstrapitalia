<?php

/** @var eZModule $module */
$module = $Params['Module'];
$tpl = eZTemplate::factory();
$action = $Params['Action'];
$parameter = (int)$Params['Parameter'];

$states = $stateId = false;
try {
    $states = OpenPABase::initStateGroup('privacy', ['public', 'private']);
} catch (Exception $e) {
    eZDebug::writeError($e->getMessage(), __METHOD__);
}
if ($states) {
    if ($action === 'make-private') {
        $stateId = $states['privacy.private']->attribute('id');
    }
    if ($action === 'make-public') {
        $stateId = $states['privacy.public']->attribute('id');
    }
}
$object = eZContentObject::fetch($parameter);
if ($object instanceof eZContentObject && $stateId) {
    if (eZOperationHandler::operationIsAvailable('content_updateobjectstate')) {
        $operationResult = eZOperationHandler::execute(
            'content', 'updateobjectstate',
            [
                'object_id' => $parameter,
                'state_id_list' => [$stateId],
            ]
        );
    } else {
        eZContentOperationCollection::updateObjectState($parameter, [$stateId]);
    }
    eZContentCacheManager::clearContentCache($parameter);
    $module->redirectTo($object->mainNode()->attribute('url_alias'));
} else {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}




