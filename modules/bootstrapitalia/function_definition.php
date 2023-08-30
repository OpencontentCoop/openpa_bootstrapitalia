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
$FunctionList['openparole_people'] = [
    'name' => 'openparole_people',
    'operation_types' => ['read'],
    'call_method' => [
        'class' => 'OpenPARolesFunctionCollection',
        'method' => 'fetchPeople',
    ],
    'parameter_type' => 'standard',
    'parameters' => [
        [
            'name' => 'attribute',
            'type' => 'object',
            'required' => true,
            'default' => false,
        ],
        [
            'name' => 'offset',
            'type' => 'integer',
            'required' => false,
            'default' => false,
        ],
        [
            'name' => 'limit',
            'type' => 'integer',
            'required' => false,
            'default' => false,
        ],
    ],
];

$FunctionList['openparole_people_count'] = [
    'name' => 'openparole_people_count',
    'operation_types' => ['read'],
    'call_method' => [
        'class' => 'OpenPARolesFunctionCollection',
        'method' => 'fetchPeopleCount',
    ],
    'parameter_type' => 'standard',
    'parameters' => [
        [
            'name' => 'attribute',
            'type' => 'object',
            'required' => true,
            'default' => false,
        ]
    ],
];



