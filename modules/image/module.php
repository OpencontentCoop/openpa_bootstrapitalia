<?php

$Module = array('name' => 'OpenContent BootstrapItalia Image');

$ViewList = array();
$ViewList['view'] = array(
    'functions' => array('view'),
    'script' => 'view.php',
    'params' => array('ID', 'Alias'),
);
$ViewList['inefficiency'] = array(
    'functions' => array('view'),
    'script' => 'inefficiency.php',
    'params' => array('DatasetGuid', 'Index'),
);

$FunctionList = array();
$FunctionList['view'] = array();
