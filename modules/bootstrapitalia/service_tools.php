<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();

if ($Params['Page'] === 'doc') {
    $tpl->setVariable('endpoint_url', ServiceToolsController::getServerUrl() . '/');
    $tpl->setVariable('load_page', false);
    $contentInfoArray = [
        'node_id' => null,
        'class_identifier' => null,
    ];
    $contentInfoArray['persistent_variable'] = [
        'show_path' => false,
        'has_container' => true,
    ];
    if (is_array($tpl->variable('persistent_variable'))) {
        $contentInfoArray['persistent_variable'] = array_merge(
            $contentInfoArray['persistent_variable'],
            $tpl->variable('persistent_variable')
        );
    }
    $Result['title_path'] = $Result['path'] = [
        [
            'text' => 'Service tools Api Doc',
            'url' => false,
            'url_alias' => false,
        ],
    ];
    $Result['content_info'] = $contentInfoArray;
    $Result['content'] = $tpl->fetch('design:openapi.tpl');

    return;
}

if (is_numeric($Params['Page'])){
    $object = eZContentObject::fetch((int)$Params['Page']);
    if ($object instanceof eZContentObject && $object->attribute('class_identifier') == 'public_service'){
        $data = $data = StanzaDelCittadinoBridge::factory()->checkServiceSync($object->mainNode());
        $tpl->setVariable('service', $object);
        $tpl->setVariable('info', $data['info']);
        $tpl->setVariable('errors', $data['errors']);
        $contentInfoArray = [
            'node_id' => null,
            'class_identifier' => null,
        ];
        $contentInfoArray['persistent_variable'] = [
            'show_path' => false,
            'has_container' => true,
        ];
        if (is_array($tpl->variable('persistent_variable'))) {
            $contentInfoArray['persistent_variable'] = array_merge(
                $contentInfoArray['persistent_variable'],
                $tpl->variable('persistent_variable')
            );
        }
        $Result['title_path'] = $Result['path'] = [
            [
                'text' => 'Service tools',
                'url' => false,
                'url_alias' => false,
            ],
        ];
        $Result['content_info'] = $contentInfoArray;
        $Result['content'] = $tpl->fetch('design:bootstrapitalia/service_sync_status.tpl');
    }else{
        $Module->redirectTo('bootstrapitalia/service_tools');
    }
    return;
}

$tpl->setVariable('prototype_content_base_url', StanzaDelCittadinoBridge::getServiceContentPrototypeBaseUrl());
$tpl->setVariable('prototype_operation_base_url', StanzaDelCittadinoBridge::getServiceOperationPrototypeBaseUrl());
$services = [];
$tenant = ['name' => '?'];
$bridge = StanzaDelCittadinoBridge::factory();
try {
    StanzaDelCittadinoClient::$connectionTimeout = 60;
    StanzaDelCittadinoClient::$processTimeout = 60;
    try {
        $tenant = $bridge->getTenantInfo();
    } catch (Throwable $e) {
        eZDebug::writeError($e->getMessage());
    }
    $services = $bridge->getServiceListMergedWithPrototypes();
} catch (Throwable $e) {
    $tpl->setVariable('error', $e->getMessage());
}

if ($http->hasPostVariable('ImportService')) {
    try {
        $bridge->importServiceByIdentifier(
            $http->postVariable('identifier'),
            $http->hasPostVariable('ReImportService')
        );
        $Module->redirectTo('bootstrapitalia/service_tools');
        return;
    } catch (Throwable $e) {
        $tpl->setVariable('error', 'Import failed:' . $e->getMessage());
    }
}

$tpl->setVariable('title', 'Sincronizzazione schede servizio');
$tpl->setVariable('services', $services);
$tpl->setVariable('base_url', $bridge->getApiBaseUri());
$tpl->setVariable('tenant', $tenant);

$Result = [];
$Result['content'] = $tpl->fetch('design:bootstrapitalia/service_tools.tpl');
$path = [];
$path[] = [
    'text' => OpenPaFunctionCollection::fetchHome()->getName(),
    'url' => '/',
];
$path[] = [
    'text' => ezpI18n::tr('bootstrapitalia', ezpI18n::tr('bootstrapitalia/signin', 'Service tools')),
    'url' => false,
];
$Result['path'] = $path;
$contentInfoArray = [
    'node_id' => null,
    'class_identifier' => null,
];
$contentInfoArray['persistent_variable'] = [
    'show_path' => false,
];
if (is_array($tpl->variable('persistent_variable'))) {
    $contentInfoArray['persistent_variable'] = array_merge(
        $contentInfoArray['persistent_variable'],
        $tpl->variable('persistent_variable')
    );
}
$Result['content_info'] = $contentInfoArray;