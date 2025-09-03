<?php

/** @var eZModule $module */
$module = $Params['Module'];
$tpl = eZTemplate::factory();

$Result = [];
$Result['content'] = $tpl->fetch('design:bootstrapitalia/stats.tpl');
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