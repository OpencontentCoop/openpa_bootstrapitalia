<?php

use Opencontent\OpenApi\EndpointDiscover\ChainEndpointFactoryDiscover;

class TrasparenzaEndpointFactoryProvider extends ChainEndpointFactoryDiscover
{
    public function __construct()
    {
        $providers = [
            new PagineTrasparenzaEndpointFactoryProvider(),
            new LottiEndpointFactoryProvider()
        ];
        parent::__construct($providers);
    }
}