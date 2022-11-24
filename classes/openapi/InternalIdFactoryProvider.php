<?php

class InternalIdFactoryProvider extends \Opencontent\OpenApi\SchemaFactory\ContentClassAttributePropertyFactory\IntegerFactoryProvider
{
    public function providePropertyIdentifier()
    {
        return 'internal_id';
    }
}