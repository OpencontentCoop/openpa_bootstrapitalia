<?php

$FunctionList = [];
$FunctionList['comuni_italiani'] = [
    'name' => 'comuni_italiani',
    'operation_types' => ['read'],
    'call_method' => [
        'class' => 'OpenPAComuniItaliani',
        'method' => 'fetchListForFunctions',
    ],
    'parameter_type' => 'standard',
    'parameters' => [
        [
            'name' => 'grouped',
            'type' => 'boolean',
            'required' => false,
            'default' => false,
        ],
    ],
];
$FunctionList['comune_italiano'] = [
    'name' => 'comune_italiano',
    'operation_types' => ['read'],
    'call_method' => [
        'class' => 'OpenPAComuniItaliani',
        'method' => 'fetchItemForFunctions',
    ],
    'parameter_type' => 'standard',
    'parameters' => [
        [
            'name' => 'code',
            'type' => 'string',
            'required' => true,
            'default' => false,
        ],
    ],
];



