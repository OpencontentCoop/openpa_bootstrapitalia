<?php

use Opencontent\OpenApi\SchemaFactory\ContentClassAttributePropertyFactory;

class OpenPAComuniItalianiFactoryProvider extends ContentClassAttributePropertyFactory
{
    public function provideProperties()
    {
        $schema = array(
            "type" => "array",
            "items" => [
                "type" => "string",
            ],
            "description" => $this->getPropertyDescription(),
        );

        return $schema;
    }
}