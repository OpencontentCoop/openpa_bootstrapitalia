<?php

$FunctionList = array();

$FunctionList['search_with_external_data'] = array(
    'name' => 'search_with_external_data',
    'operation_types' => 'read',
    'call_method' => array(
        'class' => 'ExtraIndexModuleFunctionCollection',
        'include_file' => 'extension/openpa_bootstrapitalia/classes/extraindex/ExtraIndexModuleFunctionCollection.php',
        'method' => 'searchWithExternalData'
    ),
    'parameter_type' => 'standard',
    'parameters' => array(
        array(
            'name' => 'query',
            'type' => 'string',
            'required' => false,
            'default' => ''
        ),
        array(
            'name' => 'offset',
            'type' => 'integer',
            'required' => false,
            'default' => 0
        ),
        array(
            'name' => 'limit',
            'type' => 'integer',
            'required' => false,
            'default' => 10

        ),
        array(
            'name' => 'facet',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'filter',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'sort_by',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'class_id',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'section_id',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'subtree_array',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'ignore_visibility',
            'type' => 'bool',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'limitation',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'as_objects',
            'type' => 'boolean',
            'required' => false,
            'default' => true
        ),
        array(
            'name' => 'spell_check',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'boost_functions',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'query_handler',
            'type' => 'string',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'enable_elevation',
            'type' => 'boolean',
            'required' => false,
            'default' => true
        ),
        array(
            'name' => 'force_elevation',
            'type' => 'boolean',
            'required' => false,
            'default' => false
        ),
        array(
            'name' => 'publish_date',
            'type' => 'integer',
            'required' => false,
            'default' => false
        ),
        array(
            'name' => 'distributed_search',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'fields_to_return',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'search_result_clustering',
            'type' => 'array',
            'required' => false,
            'default' => null
        ),
        array(
            'name' => 'extended_attribute_filter',
            'type' => 'array',
            'required' => false,
            'default' => array()
        )
    )
);
