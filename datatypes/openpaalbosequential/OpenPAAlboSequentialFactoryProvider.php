<?php

use Opencontent\OpenApi\SchemaFactory\ContentClassAttributePropertyFactory;

class OpenPAAlboSequentialFactoryProvider extends ContentClassAttributePropertyFactory
{
    public function provideProperties()
    {
        $data = parent::provideProperties();
        $data['type'] = "string";
        $data["nullable"] = true;

        return $data;
    }
}