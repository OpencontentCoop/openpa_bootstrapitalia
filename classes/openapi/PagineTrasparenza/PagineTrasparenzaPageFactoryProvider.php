<?php

use Opencontent\OpenApi\OperationFactory\ContentObject\PayloadBuilder;
use Opencontent\OpenApi\SchemaFactory\ContentMetaPropertyFactory;
use Opencontent\Opendata\Api\Values\Content;

class PagineTrasparenzaPageFactoryProvider extends ContentMetaPropertyFactory
{
    public function providePropertyIdentifier()
    {
        return 'page';
    }

    public function provideProperties()
    {
        return [
            "type" => "string",
            "description" => 'Page identifier',
            "default" => true,
            "readOnly" => true,
        ];
    }

    public function serializeValue(Content $content, $locale)
    {
        return PagineTrasparenzaEndpointFactoryProvider::generateSlug(
            $content->metadata['name'][$locale],
            $content->metadata->mainNodeId
        );
    }

    public function serializePayload(PayloadBuilder $payloadBuilder, array $payload, $locale)
    {
    }
}