<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();

$appName = 'support';
$config = eZSiteData::fetchByName("built_in_{$appName}_config");
if (!$config instanceof eZSiteData){
    $config = eZSiteData::create("built_in_{$appName}_config", false);
}
if ($http->hasPostVariable('StoreConfig') && $http->hasPostVariable('Config')) {
    $configValue = $http->postVariable('Config');
    $config->setAttribute('value', $configValue);
    $config->store();
    $Module->redirectTo($Module->Name);
    return;
}
$tpl->setVariable('built_in_app', $appName);
$tpl->setVariable('built_in_app_script', $config->attribute('value'));

$Result = [];
$Result['content'] = $tpl->fetch('design:openpa/built_in_app.tpl');
$path = [];
$path[] = [
    'text' => OpenPaFunctionCollection::fetchHome()->getName(),
    'url' => '/',
];
$allServices = eZContentObject::fetchByRemoteID('all-services');
if ($allServices instanceof eZContentObject){
    $path[] = [
        'text' => $allServices->attribute('name'),
        'url' => $allServices->mainNode()->urlAlias(),
    ];
}
$path[] = [
    'text' => ezpI18n::tr('bootstrapitalia', 'Support'),
    'url' => false,
];
$Result['path'] = $path;
$contentInfoArray = [
    'node_id' => null,
    'class_identifier' => null,
];
$contentInfoArray['persistent_variable'] = [
    'show_path' => true,
    'built_in_app' => 'support'
];
if (is_array($tpl->variable('persistent_variable'))) {
    $contentInfoArray['persistent_variable'] = array_merge(
        $contentInfoArray['persistent_variable'],
        $tpl->variable('persistent_variable')
    );
}
$Result['content_info'] = $contentInfoArray;


