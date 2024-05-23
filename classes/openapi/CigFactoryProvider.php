<?php

use Opencontent\OpenApi\EndpointDiscover\EmptyEndpointFactory;
use Opencontent\OpenApi\EndpointDiscover\NodeClassesEndpointFactoryProvider;
use Opencontent\OpenApi\EndpointFactoryProvider;

class CigFactoryProvider extends EndpointFactoryProvider
{
    public function getEndpointFactoryCollection()
    {
        if (class_exists('\Opencontent\OpenApi\EndpointDiscover\NodeClassesEndpointFactoryProvider')) {
            $node = false;
            $object = eZContentObject::fetchByRemoteID('dd628e7bbe6fd442a5f915ae6e98ea43');
            if ($object instanceof eZContentObject) {
                $node = $object->mainNode();
            }
            if ($node instanceof eZContentObjectTreeNode && eZContentClass::classIDByIdentifier('bando')) {
                return (new NodeClassesEndpointFactoryProvider(
                    $node,
                    ['bando'],
                    '/cig',
                    ['trasparenza']
                ))->getEndpointFactoryCollection();
            }
        }

        return (new EmptyEndpointFactory())->getEndpointFactoryCollection();
    }

}