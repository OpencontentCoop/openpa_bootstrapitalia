<?php

$Module = array('name' => 'tagdescription');

$ViewList = array();
$ViewList['update'] = array(
    'functions' => array( 'update' ),
    'script' => 'update.php',
    'params' => array('TagID', 'Locale'),
    'unordered_params' => array(),
    'ui_context' => 'edit',
    'single_post_actions' => array(
        'StoreTagDescriptionButton' => 'Store',
    )
);

$FunctionList = array();
$FunctionList['update'] = array();
