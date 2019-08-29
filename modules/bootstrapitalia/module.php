<?php

$Module = array( 'name' => 'OpenContent BootstrapItalia' );

$ViewList = array();
$ViewList['palette'] = array(
    'functions' => array( 'palette' ),
    'script' => 'palette.php',
    'params' => array( ),
    'unordered_params' => array(),
    "default_navigation_part" => 'ezsetupnavigationpart',
);
$ViewList['theme'] = array(
    'functions' => array( 'theme' ),
    'script' => 'theme.php',
    'params' => array( ),
    'unordered_params' => array(),
    "default_navigation_part" => 'ezsetupnavigationpart',
);


$FunctionList = array();
$FunctionList['theme'] = array();
