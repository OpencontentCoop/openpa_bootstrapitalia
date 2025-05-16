<?php

use Opencontent\OpenApi\EndpointFactory;

class BookingEndpointFactory extends EndpointFactory
{
    public function provideSchemaFactories()
    {
        return [
            new BookingSchemaFactory(),
        ];

    }
}