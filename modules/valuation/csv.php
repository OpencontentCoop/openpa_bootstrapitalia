<?php

$http = eZHTTPTool::instance();
$module = $Params['Module'];

$object = eZContentObject::fetchByRemoteID('openpa-valuation');
if (!$object) {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

$infoCollectors = [];
$infoCollectorOptions = [];
$contentClass = $object->contentClass();
$classDataMap = $contentClass->dataMap();
foreach ($classDataMap as $attribute){
    if ($attribute->attribute('is_information_collector') && $attribute->attribute('data_type_string') != OcReCaptchaType::DATA_TYPE_STRING){
        $infoCollectors[$attribute->attribute('id')] = $attribute->attribute('identifier');
        if ($attribute->attribute('data_type_string') == eZSelectionType::DATA_TYPE_STRING){
            $options = $attribute->content();
            $infoCollectorOptions[$attribute->attribute('identifier')] = array_column($options['options'], 'name');
        }
    }
}
$infoCollectorsIdList = array_keys($infoCollectors);
$infoCollectorsIdentifierList = array_values($infoCollectors);

$firstCollectorId = array_shift($infoCollectorsIdList);
$firstCollectorIdentifier = array_shift($infoCollectorsIdentifierList);

$query = "select info.id, info.created, {$firstCollectorIdentifier}.data_text as useful";
foreach ($infoCollectorsIdentifierList as $infoCollectorsIdentifier){
    $query .= ", {$infoCollectorsIdentifier}.data_text as {$infoCollectorsIdentifier}";
}
$query .= " from (select informationcollection_id, data_text from ezinfocollection_attribute where contentclass_attribute_id = {$firstCollectorId}) {$firstCollectorIdentifier}";
$query .= " inner join ezinfocollection info on {$firstCollectorIdentifier}.informationcollection_id = info.id";
foreach ($infoCollectors as $infoCollectorId => $infoCollectorIdentifier){
    if ($infoCollectorId != $firstCollectorId){
        $query .= " inner join ( select informationcollection_id, data_text from ezinfocollection_attribute where contentclass_attribute_id = {$infoCollectorId} ) {$infoCollectorIdentifier} on {$firstCollectorIdentifier}.informationcollection_id = {$infoCollectorIdentifier}.informationcollection_id";
    }
}
$query .= " order by info.id asc";
$data = eZDB::instance()->arrayQuery($query);

ob_get_clean();
$filename = $contentClass->attribute('identifier') . '.csv';
header('X-Powered-By: eZ Publish');
header('Content-Description: File Transfer');
header('Content-Type: text/csv; charset=utf-8');
header("Content-Disposition: attachment; filename=$filename");
header("Pragma: no-cache");
header("Expires: 0");
$output = fopen('php://output', 'w');
$headers = array_merge(['id', 'created'], array_values($infoCollectors));
fputcsv($output, $headers);
foreach ($data as $item){
    $item['created'] = date('c', $item['created']);
    if (!empty($item['link']) && strpos($item['link'], 'http') === false){
        eZURI::transformURI($item['link'], false, 'full');
    }
    foreach ($infoCollectorOptions as $index => $options){
        if (isset($item[$index]) && isset($options[$item[$index]])){
            $item[$index] = $options[$item[$index]];
        }
    }
    fputcsv($output, array_values($item));
}
flush();
eZExecution::cleanExit();
