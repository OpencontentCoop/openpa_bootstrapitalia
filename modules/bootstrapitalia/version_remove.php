<?php
/** @var eZModule $module */
$module = $Params['Module'];
$objectId = (int)$Params['Id'];
$versionNumber = (int)$Params['Version'];
$locale = $Params['Locale'];

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

if ($version->attribute('status') != eZContentObjectVersion::STATUS_DRAFT) {
    return $module->handleError(eZError::KERNEL_ACCESS_DENIED, 'kernel');
}

$db = eZDB::instance();
$db->begin();
$version->removeThis();
$db->commit();

$module->redirectTo('/content/history/' . $objectId);