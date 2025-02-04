<?php

namespace Opencontent\OpenApi\SchemaFactory;

use erasys\OpenApi\Spec\v3 as OA;
use Opencontent\OpenApi\SchemaFactory;

class ServiceCategorySchemaFactory extends SchemaFactory
{
    protected $name = 'ServiceCategory';

    public function generateSchema()
    {
        $schema = new OA\Schema();
        $schema->title = $this->name;
        $schema->type = 'object';
        $schema->properties = [
            'name' => $this->generateSchemaProperty([
                'type' => 'string',
                'description' => 'Service category name',
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
