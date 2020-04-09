<?php

$Module = array('name' => 'Join');

$ViewList = array();
$ViewList['as'] = array(
    'functions' => array( 'join' ),
    'script' => 'join.php',
    'params' => array('ClassIdentifier', 'Action'),
    'unordered_params' => array(),
    "default_navigation_part" => 'ezsetupnavigationpart',
    'ui_context' => 'edit',
    'single_post_actions' => array(
        'RegisterButton' => 'Publish',
        'CancelButton' => 'Cancel',
        'CustomActionButton' => 'CustomAction'
    )
);

$FunctionList = array();
$FunctionList['join'] = array();
