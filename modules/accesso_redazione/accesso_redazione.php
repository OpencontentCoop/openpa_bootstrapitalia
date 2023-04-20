<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();

$bridge = StanzaDelCittadinoBridge::factory();

$localUserLoginUri = '/user/login';
$editorAccessList = OpenPAINI::variable('AccessPage', 'EditorAccessList', []);
$accessLinks = [];
foreach ($editorAccessList as $index => $editorAccess){
    if ($editorAccess === 'EditorAccess'){
        $link = $localUserLoginUri;
    }elseif ($editorAccess === 'OperatorAccess'){
        $link = $bridge->getOperatorLoginUri() ?? OpenPAINI::variable('AccessPage', $editorAccess . '_Link', null);
    }else{
        $link = OpenPAINI::variable('AccessPage', $editorAccess . '_Link', null);
    }
    if ($link){
        $accessLinks[$editorAccess] = $link;
    }else{
        unset($editorAccessList[$index]);
    }
}

$tpl->setVariable('access_list', $editorAccessList);
$tpl->setVariable('access_links', $accessLinks);

$Result = [];
$Result['content'] = $tpl->fetch('design:openpa/editor_access_entrypoint.tpl');
$path = [];
$path[] = [
    'text' => OpenPaFunctionCollection::fetchHome()->getName(),
    'url' => '/',
];
$path[] = [
    'text' => ezpI18n::tr('bootstrapitalia', ezpI18n::tr('bootstrapitalia/signin', 'Editor login')),
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


