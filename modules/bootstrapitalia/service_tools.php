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
        'class_identifier' => null
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
            'url_alias' => false
        ]
    ];
    $Result['content_info'] = $contentInfoArray;
    $Result['content'] = $tpl->fetch('design:openapi.tpl');

    return;
}


$services = [];
$tenant = ['name' => '?'];
$bridge = StanzaDelCittadinoBridge::factory();
try {
    $tenant = $bridge->getTenantInfo();
    $services = $bridge->getServiceList();
}catch (Throwable $e){
    $tpl->setVariable('error', $e->getMessage());
}

if ($http->hasPostVariable('ImportService') || $http->hasPostVariable('ReImportService')){
    try {
        $bridge->importService(
            $http->postVariable('service_id'),
            $http->postVariable('identifier'),
            $http->postVariable('content_remote_id'),
            $http->hasPostVariable('ReImportService')
        );
        $Module->redirectTo('bootstrapitalia/service_tools');
        return;
    }catch (Throwable $e){
        $tpl->setVariable('error', 'Import failed:' . $e->getMessage());
    }
}

if ($http->hasPostVariable('UpdateService')){
    try {
        $bridge->updateServiceStatus(
            $http->postVariable('service_id'),
            $http->postVariable('identifier'),
            $http->postVariable('content_remote_id')
        );
        $Module->redirectTo('bootstrapitalia/service_tools');
        return;
    }catch (Throwable $e){
        $tpl->setVariable('error', 'Update failed:' . $e->getMessage());
    }
}

$tpl->setVariable('title', 'Sincronizzazione schede servizio da ' . $tenant['name']);
$tpl->setVariable('services', $services);
$tpl->setVariable('base_url', $bridge->getApiBaseUri());

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