<?php

use Opencontent\OpenApi\EndpointDiscover\ChainEndpointFactoryDiscover;

class TrasparenzaEndpointFactoryProvider extends ChainEndpointFactoryDiscover
{
    public function __construct()
    {
        $providers = [
            new PagineTrasparenzaEndpointFactoryProvider(),
            new LottiEndpointFactoryProvider(),
            new CigFactoryProvider()
        ];

        parent::__construct($providers);
    }

    public static function clearSchemaBuilder()
    {
        $schemaBuilder = \Opencontent\OpenApi\Loader::instance()->getSchemaBuilder();
        if ($schemaBuilder instanceof \Opencontent\OpenApi\CachedSchemaBuilder) {
            $schemaBuilder->clearCache();
        }
    }

    public function clearCache()
    {
        parent::clearCache();
    }


}