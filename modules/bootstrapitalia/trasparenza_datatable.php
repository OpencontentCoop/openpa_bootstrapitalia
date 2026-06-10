<?php

use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\EnvironmentLoader;

$module = $Params['Module'];
$nodeId = (int)$Params['NodeID'];
$tableIndex = (int)$Params['TableIndex'];

$node = eZContentObjectTreeNode::fetch($nodeId);
if (!$node instanceof eZContentObjectTreeNode) {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

$fieldsString = $node->attribute('object')->attribute('data_map')['fields']->toString();
$tables = [];
foreach (explode('&', $fieldsString) as $p) {
    $t = ObjectHandlerServiceContentTrasparenza::parseTableFieldsParameter($p, $node);
    if (!empty($t)) {
        $tables[] = $t;
    }
}

$fields = $tables[$tableIndex] ?? null;
if ($fields === null) {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

$includeExpired = $fields['include_expired'] ?? false;
$limitation = $includeExpired ? [] : null;

$currentEnvironment = EnvironmentLoader::loadPreset('datatable');
$parser = new ezpRestHttpRequestParser();
$request = $parser->createRequest();
$currentEnvironment->__set('request', $request);

$contentSearch = new ContentSearch();
$contentSearch->setEnvironment($currentEnvironment);

$result = (array)$contentSearch->search($fields['query'], $limitation);

if ($includeExpired) {
    foreach ($result['data'] as &$hit) {
        $states = $hit['metadata']['stateIdentifiers'] ?? [];
        $hit['metadata']['is_expired'] = in_array('privacy.expired', $states);
    }
    unset($hit);
}

header('Content-Type: application/json');
echo json_encode($result);
eZExecution::cleanExit();
