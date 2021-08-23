<?php

$tpl = eZTemplate::factory();
$tpl->setVariable('endpoint_url',  ExtraIndexController::getServerUrl() . '/');
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
    $contentInfoArray['persistent_variable'] = array_merge($contentInfoArray['persistent_variable'], $tpl->variable('persistent_variable'));
}
$Result['title_path'] = $Result['path'] = [[
    'text' => 'Extra index Api Doc',
    'url' => false,
    'url_alias' => false
]];
$Result['content_info'] = $contentInfoArray;
$Result['content'] = $tpl->fetch('design:openapi.tpl');
