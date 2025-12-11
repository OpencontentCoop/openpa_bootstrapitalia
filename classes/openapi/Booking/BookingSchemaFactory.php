<?php

use Opencontent\OpenApi\SchemaFactory;
use erasys\OpenApi\Spec\v3 as OA;

class BookingSchemaFactory extends SchemaFactory
{
    protected $name = 'BookingConfig';

    public function generateSchema()
    {
        $schema = new OA\Schema();
        $schema->title = $this->name;
        $schema->type = 'object';
        $schema->description = 'Public service booking configuration';
        $schema->properties = [
            'id' => $this->generateSchemaProperty([
                'type' => 'integer',
                'format' => 'int32',
                'description' => 'Public service internal id',
            ]),
            'link' => $this->generateSchemaProperty([
                'type' => 'string',
                'format' => 'uri',
                'description' => 'Public service api url',
            ]),
            'name' => $this->generateSchemaProperty([
                'type' => 'string',
                'description' => 'Public service title',
            ]),
            'offices' => $this->generateSchemaProperty([
                'type' => 'array',
                'items' => [
                    'title' => 'Office',
                    'type' => 'object',
                    'description' => 'Info about offices',
                    'properties' => [
                        'id' => $this->generateSchemaProperty([
                            'type' => 'integer',
                            'format' => 'int32',
                            'description' => 'Office internal id',
                        ]),
                        'link' => $this->generateSchemaProperty([
                            'type' => 'string',
                            'format' => 'uri',
                            'description' => 'Office api url',
                        ]),
                        'name' => $this->generateSchemaProperty([
                            'type' => 'string',
                            'description' => 'Office title',
                        ]),
                        'places' => $this->generateSchemaProperty([
                            'type' => 'array',
                            'items' => [
                                'title' => 'Place',
                                'type' => 'object',
                                'description' => 'Info about places',
                                'properties' => [
                                    'id' => $this->generateSchemaProperty([
                                        'type' => 'integer',
                                        'format' => 'int32',
                                        'description' => 'Place internal id',
                                    ]),
                                    'link' => $this->generateSchemaProperty([
                                        'type' => 'string',
                                        'format' => 'uri',
                                        'description' => 'Place api url',
                                    ]),
                                    'name' => $this->generateSchemaProperty([
                                        'type' => 'string',
                                        'description' => 'Place title',
                                    ]),
                                    'location' => $this->generateSchemaProperty([
                                        'type' => 'object',
                                        'description' => 'Place location',
                                        'properties' => [
                                            'address' => $this->generateSchemaProperty(['type' => 'string']),
                                            'lat' => $this->generateSchemaProperty(['type' => 'number', 'format' => 'float']),
                                            'lng' => $this->generateSchemaProperty(['type' => 'number', 'format' => 'float']),
                                        ],
                                    ]),
                                    'calendars' => $this->generateSchemaProperty([
                                        'type' => 'array',
                                        'items' => [
                                            'title' => 'Calendar',
                                            'type' => 'object',
                                            'description' => 'Info about calendars',
                                            'properties' => [
                                                'id' => $this->generateSchemaProperty([
                                                    'type' => 'string',
                                                    'format' => 'uuid',
                                                ]),
                                                'link' => $this->generateSchemaProperty([
                                                    'type' => 'string',
                                                    'format' => 'uri',
                                                    'description' => 'Calendar api url',
                                                ]),
                                                'availabilities_link' => $this->generateSchemaProperty([
                                                    'type' => 'string',
                                                    'format' => 'uri',
                                                    'description' => 'Calendar slot availabilities api url',
                                                ]),
                                            ]
                                        ],
                                    ]),
                                    'merge_availabilities' => $this->generateSchemaProperty([
                                        'type' => 'boolean',
                                        'description' => 'Indicates whether to hide individual calendars in the availability selection interface',
                                    ]),
                                    'merged_availabilities_link' => $this->generateSchemaProperty([
                                        'type' => 'string',
                                        'format' => 'uri',
                                        'nullable' => true,
                                        'description' => 'Calendar slot availabilities api url',
                                    ]),
                                ],
                            ],
                        ]),
                    ],
                ],
            ]),
            'categories' => $this->generateSchemaProperty([
                'type' => 'array',
                'items' => [
                    'type' => 'string',
                ],
                'description' => 'Public service category',
            ]),
            'abstract' => $this->generateSchemaProperty([
                'type' => 'string',
                'description' => 'Public service abstract',
            ]),
            'show_howto_in_motivation' => $this->generateSchemaProperty([
                'type' => 'boolean',
                'description' => 'Show howto instructions in motivation field',
            ]),
            'view_type' => $this->generateSchemaProperty([
                'type' => 'string',
                'enum' => ['select', 'calendar'],
                'description' => 'Select view type',
            ]),
        ];

        return $schema;
    }

    public function generateRequestBody()
    {
        return new OA\RequestBody([
            'application/json' => new OA\MediaType([
                'schema' => new OA\Reference('#/components/schemas/' . $this->name),
            ]),
        ]);
    }

    public function serialize()
    {
        return serialize([
            'name' => $this->name,
        ]);
    }
}