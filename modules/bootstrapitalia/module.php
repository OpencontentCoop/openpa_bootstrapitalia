<?php

$Module = ['name' => 'OpenContent BootstrapItalia'];

$ViewList = [];
$ViewList['theme'] = [
    'functions' => ['theme'],
    'script' => 'theme.php',
    'params' => [],
    'unordered_params' => [],
    "default_navigation_part" => 'ezsetupnavigationpart',
];
$ViewList['permissions'] = [
    'functions' => ['permissions'],
    'script' => 'permissions.php',
    'params' => ['Action', 'UserNode', 'GroupNode'],
    'unordered_params' => [],
    "default_navigation_part" => 'ezsetupnavigationpart',
];
$ViewList['role_list'] = [
    'functions' => ['theme'],
    'script' => 'role_list.php',
    'params' => [],
    'unordered_params' => [],
    "default_navigation_part" => 'ezsetupnavigationpart',
];
$ViewList['avatar'] = [
    'functions' => ['avatar'],
    'script' => 'avatar.php',
    'params' => ['ID'],
    'unordered_params' => [],
];
$ViewList['info'] = [
    'functions' => ['opencity_info_editor'],
    'script' => 'info.php',
    'params' => [],
    'unordered_params' => [],
];
$ViewList['service_tools'] = [
    'functions' => ['service_tools'],
    'script' => 'service_tools.php',
    'params' => ['Page'],
    'unordered_params' => [],
];

$FunctionList = [];
$FunctionList['theme'] = [];
$FunctionList['permissions'] = [];
$FunctionList['edit_tag_description'] = [];
$FunctionList['advanced_editor_tools'] = [];
$FunctionList['avatar'] = [];
$FunctionList['config_built_in_apps'] = [];
$FunctionList['opencity_locked_editor'] = [
    'Node' => [
        'name'=> 'Node',
        'values'=> []
    ],
    'Subtree' => [
        'name'=> 'Subtree',
        'values'=> []
    ],
];
$FunctionList['opencity_info_editor'] = [];
$FunctionList['service_tools'] = [];
