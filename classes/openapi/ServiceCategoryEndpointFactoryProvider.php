<?php

use Opencontent\OpenApi\EndpointFactoryCollection;
use Opencontent\OpenApi\EndpointFactoryProvider;
use Opencontent\OpenApi\OperationFactoryCollection;

class ServiceCategoryEndpointFactoryProvider extends EndpointFactoryProvider
{

    public function getEndpointFactoryCollection()
    {
        return new EndpointFactoryCollection([
            (new ServiceCategoryEndpointFactory())
                ->setPath('/categorie-servizi')
                ->setTags(['servizi'])
                ->setOperationFactoryCollection(
                    new OperationFactoryCollection([
                        new ServiceCategoryOperationFactory()
                    ])
                )
        ]);

    }

}