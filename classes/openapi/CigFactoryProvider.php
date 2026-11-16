<?php

use Opencontent\OpenApi\EndpointDiscover\EmptyEndpointFactory;
use Opencontent\OpenApi\EndpointDiscover\NodeClassesEndpointFactoryProvider;
use Opencontent\OpenApi\EndpointFactoryProvider;

class CigFactoryProvider extends EndpointFactoryProvider
{
    const REMOTE_ID_C1 = 'dd628e7bbe6fd442a5f915ae6e98ea43';
    const REMOTE_ID_C2 = 't_c2_atti-e-documenti-relativi-a';

    private function getContainerRemoteId(): string
    {
        return TrasparenzaEndpointFactoryProvider::getTree() === TrasparenzaEndpointFactoryProvider::TREE_C2 ?
            self::REMOTE_ID_C2 : self::REMOTE_ID_C1;
    }

    public function getEndpointFactoryCollection()
    {
        if (class_exists('\Opencontent\OpenApi\EndpointDiscover\NodeClassesEndpointFactoryProvider')) {
            $node = false;
            $object = eZContentObject::fetchByRemoteID($this->getContainerRemoteId());
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