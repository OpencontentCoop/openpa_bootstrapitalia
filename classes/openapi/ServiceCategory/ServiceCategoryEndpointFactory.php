<?php

use Opencontent\OpenApi\EndpointFactory;
use Opencontent\OpenApi\SchemaFactory\ServiceCategorySchemaFactory;

class ServiceCategoryEndpointFactory extends EndpointFactory
{
    public function provideSchemaFactories()
    {
        return [
            new ServiceCategorySchemaFactory(),
        ];

    }

}