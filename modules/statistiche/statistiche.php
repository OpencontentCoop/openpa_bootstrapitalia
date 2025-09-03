<?php

/** @var eZModule $module */
$module = $Params['Module'];

$siteId = OpenPAINI::variable('Seo', 'webAnalyticsItaliaSiteID', '');
if (empty($siteId)){
    return $module->handleError(eZError::KERNEL_NOT_FOUND, 'kernel');
}

$tpl = eZTemplate::factory();
$tpl->setVariable('site_id', $siteId);

$Result = [];
$Result['content'] = $tpl->fetch('design:bootstrapitalia/statistiche.tpl');
$Result['content_info'] = [
    'node_id' => null,
    'class_identifier' => null,
    'persistent_variable' => [
        'show_path' => false,
        'site_title' => 'Statistiche',
    ],
];
if (is_array($tpl->variable('persistent_variable'))) {
    $Result['content_info']['persistent_variable'] = array_merge(
        $Result['content_info']['persistent_variable'],
        $tpl->variable('persistent_variable')
    );
}
$Result['path'] = [];