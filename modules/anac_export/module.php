<?php
$Module = array('name' => 'ANAC Export');

$ViewList = array();
$ViewList['file'] = array(
    'functions' => array('file'),
    'script' => 'file.php',
    'params' => array('SchemaIdentifier', 'Filename'),
);

// Richiesto da eZUser::hasAccessToView(): 'file' deve comparire tra le chiavi
// di $FunctionList, altrimenti l'espressione 'functions' della view non viene
// mai sostituita con true/false e l'accesso e' sempre negato (vedi
// ezuser.php:hasAccessToView, ramo "mistake in the functions array data").
$FunctionList = array();
$FunctionList['file'] = array();
