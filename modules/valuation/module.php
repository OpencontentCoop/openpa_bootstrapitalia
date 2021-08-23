<?php

$Module = array('name' => 'Valuation');

$ViewList = array();
$ViewList['send'] = array(
    'script' => 'send.php',
    'params' => array(),
    'unordered_params' => array()
);
$ViewList['form'] = array(
    'script' => 'form.php',
    'params' => array('Service'),
    'unordered_params' => array()
);
$ViewList['dashboard'] = array(
    'script' => 'dashboard.php',
    'functions' => array('dashboard'),
    'params' => array('ID'),
    'unordered_params' => array('offset' => 'Offset'),
);
$ViewList['csv'] = array(
    'script' => 'csv.php',
    'functions' => array('dashboard'),
    'params' => array()
);

$FunctionList = array();
$FunctionList['dashboard'] = array();