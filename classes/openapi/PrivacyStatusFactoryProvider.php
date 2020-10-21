<?php

use Opencontent\OpenApi\OperationFactory\ContentObject\PayloadBuilder;
use Opencontent\OpenApi\SchemaFactory\ContentMetaPropertyFactory;
use Opencontent\Opendata\Api\Values\Content;

class PrivacyStatusFactoryProvider extends ContentMetaPropertyFactory
{
    public function providePropertyIdentifier()
    {
        return 'is_public';
    }

    public function provideProperties()
    {
        return [
            "type" => "boolean",
            "description" => 'Visibility of the content',
            "default" => true,
        ];
    }

    public function serializeValue(Content $content, $locale)
    {
        $stateIdentifiers = $content->metadata->stateIdentifiers;

        return in_array('privacy.public', $stateIdentifiers);
    }

    public function serializePayload(PayloadBuilder $payloadBuilder, array $payload, $locale)
    {
        if (isset($payload[$this->providePropertyIdentifier()])) {
            $public = (bool)$payload[$this->providePropertyIdentifier()];
            if ($public) {
                $payloadBuilder->setStateIdentifier('privacy.public');
            } else {
                $payloadBuilder->setStateIdentifier('privacy.private');
            }
        }
    }

}