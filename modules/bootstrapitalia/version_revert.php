<?php

$module = $Params['Module'];
$objectId = (int)$Params['Id'];
$versionNumber = (int)$Params['Version'];
$locale = $Params['Locale'] ?? eZLocale::currentLocaleCode();

$object = eZContentObject::fetch($objectId);

if (!$object instanceof eZContentObject) {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

if (!LockEditConnector::canLockEdit($object)) {
    return $module->handleError(eZError::KERNEL_ACCESS_DENIED, 'kernel');
}

$version = eZContentObjectVersion::fetchVersion($versionNumber, $objectId);
if (!$version instanceof eZContentObjectVersion) {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

if ($version->attribute('status') != eZContentObjectVersion::STATUS_ARCHIVED) {
    return $module->handleError(eZError::KERNEL_ACCESS_DENIED, 'kernel');
}

$language = $locale ?? $version->initialLanguageCode();

$db = eZDB::instance();
$db->begin();
$newVersion = $object->createNewVersionIn($language, false, $version->attribute('version'));
$db->commit();

if (!$newVersion instanceof eZContentObjectVersion) {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

eZOperationHandler::execute(
    'content',
    'publish',
    ['object_id' => $objectId, 'version' => $newVersion->attribute('version')]
);

$module->redirectTo('/content/history/' . $objectId);

