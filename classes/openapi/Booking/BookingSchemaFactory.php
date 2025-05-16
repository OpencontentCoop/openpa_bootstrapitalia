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
        $schema->properties = [
            'id' => $this->generateSchemaProperty([
                'type' => 'integer',
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
                    'properties' => [
                        'id' => $this->generateSchemaProperty([
                            'type' => 'integer',
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
                                'properties' => [
                                    'id' => $this->generateSchemaProperty([
                                        'type' => 'integer',
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
                                            'lat' => $this->generateSchemaProperty(['type' => 'decimal']),
                                            'lng' => $this->generateSchemaProperty(['type' => 'decimal']),
                                        ],
                                    ]),
                                    'calendars' => $this->generateSchemaProperty([
                                        'type' => 'array',
                                        'items' => [
                                            'type' => 'string',
                                            'format' => 'uuid',
                                        ],
                                    ]),
                                    'merge_availabilites' => $this->generateSchemaProperty([
                                        'type' => 'boolean',
                                    ]),
                                ],
                            ],
                        ]),
                    ],
                ],
            ]),
            'category' => $this->generateSchemaProperty([
                'type' => 'string',
                'description' => 'Public service category	',
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