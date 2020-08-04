<?php

$Module = array( 'name' => 'OpenContent BootstrapItalia' );

$ViewList = array();
$ViewList['theme'] = array(
    'functions' => array( 'theme' ),
    'script' => 'theme.php',
    'params' => array( ),
    'unordered_params' => array(),
    "default_navigation_part" => 'ezsetupnavigationpart',
);
$ViewList['permissions'] = array(
    'functions' => array( 'permissions' ),
    'script' => 'permissions.php',
    'params' => array('Action', 'UserNode', 'GroupNode'),
    'unordered_params' => array(),
    "default_navigation_part" => 'ezsetupnavigationpart',
);

$FunctionList = array();
$FunctionList['theme'] = array();
$FunctionList['permissions'] = array();
$FunctionList['edit_tag_description'] = array();