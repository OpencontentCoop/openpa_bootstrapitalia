<?php

use Opencontent\OpenApi\SchemaFactory\ContentMetaPropertyFactory\UriFactoryProvider;
use Opencontent\Opendata\Api\Values\Content;

class ParentTopicObjectFactoryProvider extends UriFactoryProvider
{
    public function providePropertyIdentifier()
    {
        return 'parent_topic';
    }

    public function provideProperties()
    {
        return [
            "type" => "object",
            "nullable" => true,
            "readOnly" => true,
            "properties" => [
                "id" => [
                    "description" => 'Content id',
                    "type" => "string",
                    "readOnly" => true,
                ],
                "name" => [
                    "description" => "Name",
                    "type" => "string",
                    "readOnly" => true,
                ],
                "uri" => parent::provideProperties(),
            ],
            "required" => ['id'],
        ];
    }

    public function serializeValue(Content $content, $locale)
    {
        $parentNodeId = $content->metadata->parentNodes[0]['id'] ?? null;
        if ($parentNodeId > 0) {
            $node = eZContentObjectTreeNode::fetch($parentNodeId);
            if ($node instanceof eZContentObjectTreeNode
                && $node->attribute('class_identifier') === $content->metadata->classIdentifier) {

                $remoteId = $node->object()->remoteID();
                $name = $node->attribute('name');
                $resourcePath = $this->getResourceEndpointPathForClassIdentifier(
                    $node->attribute('class_identifier'),
                    $parentNodeId,
                    $node->attribute('path_array')
                );
                $uri = $resourcePath ? $resourcePath . $remoteId
                    . '#' . \eZCharTransform::instance()->transformByGroup($name, 'urlalias') : null;

                return [
                    'id' => $remoteId,
                    'name' => $name,
                    'uri' => $uri,
                ];
            }
        }
        return null;
    }
}