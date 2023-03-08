<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();

$hasSpidAccess = OpenPAINI::variable('AccessPage', 'SpidAccess', 'enabled') === 'enabled';
$spidAccessLink = '#';

$hasCieAccess = OpenPAINI::variable('AccessPage', 'CieAccess', 'disabled') === 'enabled';
$cieAccessLink = '#';

$bridge = StanzaDelCittadinoBridge::factory();
$spidAccessLink = $bridge->getUserLoginUri();
$hasSpidAccess = !empty($spidAccessLink);

$localUserLoginUri = '/user/login';
$others = OpenPAINI::variable('AccessPage', 'Others', []);
$otherAccessLinks = [];
foreach ($others as $index => $other){
    if ($other === 'EditorAccess'){
        $link = $localUserLoginUri;
    }elseif ($other === 'OperatorAccess'){
        $link = $bridge->getOperatorLoginUri() ?? OpenPAINI::variable('AccessPage', $other . '_Link', null);
    }else{
        $link = OpenPAINI::variable('AccessPage', $other . '_Link', null);
    }
    if ($link){
        $otherAccessLinks[$other] = $link;
    }else{
        unset($others[$index]);
    }
}

if (!$hasSpidAccess && !$hasCieAccess && count($others) === 1){
    $Module->redirectTo($localUserLoginUri);
    return;
}

$tpl->setVariable('others', $others);
$tpl->setVariable('has_spid_access', $hasSpidAccess);
$tpl->setVariable('has_cie_access', $hasCieAccess);
$tpl->setVariable('others_access_links', $otherAccessLinks);
$tpl->setVariable('cie_access_link', $cieAccessLink);
$tpl->setVariable('spid_access_link', $spidAccessLink);

$Result = [];
$Result['content'] = $tpl->fetch('design:openpa/access_entrypoint.tpl');
$path = [];
$path[] = [
    'text' => OpenPaFunctionCollection::fetchHome()->getName(),
    'url' => '/',
];
$path[] = [
    'text' => ezpI18n::tr('bootstrapitalia', 'Accedi'),
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


