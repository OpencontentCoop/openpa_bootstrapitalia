<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();
$redirectNodeId = $http->hasGetVariable('r') ? (int)$http->getVariable('r') : null;
if ($redirectNodeId > 0 && eZContentObjectTreeNode::fetch($redirectNodeId, false)) {
    $http->setSessionVariable('RedirectAfterLogin', '/content/view/full/' . $redirectNodeId);
}
$bridge = StanzaDelCittadinoBridge::factory();

$localUserLoginUri = '/user/login';
if (BootstrapItaliaLoginOauth::instance()->isEnabled()){
    $localUserLoginUri = '/login-oauth';
}
eZURI::transformURI($localUserLoginUri);
$editorAccessList = OpenPAINI::variable('AccessPage', 'EditorAccessList', []);
$accessLinks = [];
foreach ($editorAccessList as $index => $editorAccess) {
    if ($editorAccess === 'EditorAccess') {
        $link = $localUserLoginUri;
    } elseif ($editorAccess === 'OperatorAccess') {
        $link = $bridge->getOperatorLoginUri() ?? OpenPAINI::variable('AccessPage', $editorAccess . '_Link', null);
    } else {
        $link = OpenPAINI::variable('AccessPage', $editorAccess . '_Link', null);
    }
    if ($link) {
        $accessLinks[$editorAccess] = $link;
    } else {
        unset($editorAccessList[$index]);
    }
}

$tpl->setVariable('access_list', $editorAccessList);
$tpl->setVariable('access_links', $accessLinks);

$homeUrl = '/';
eZURI::transformURI($homeUrl);
$Result = [];
$Result['content'] = $tpl->fetch('design:openpa/editor_access_entrypoint.tpl');
$Result['path'] = [
    [
        'text' => OpenPAINI::variable('GeneralSettings', 'ShowMainContacts', 'enabled') == 'enabled' ?
            'Home' : OpenPaFunctionCollection::fetchHome()->getName(),
        'url' => $homeUrl,
    ],
    [
        'text' => ezpI18n::tr('bootstrapitalia', ezpI18n::tr('bootstrapitalia/signin',
            OpenPAINI::variable('AccessPage', 'EditorAccessTitle', 'Access reserved only for staff')
        )),
        'url' => false,
    ]
];

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


