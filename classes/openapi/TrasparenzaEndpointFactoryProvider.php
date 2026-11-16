<?php

use Opencontent\OpenApi\EndpointDiscover\ChainEndpointFactoryDiscover;

class TrasparenzaEndpointFactoryProvider extends ChainEndpointFactoryDiscover
{
    const TREE_C1 = 'c1';
    const TREE_C2 = 'c2';
    const ROOT_REMOTE_ID_C1 = '5399ef12f98766b90f1804e5d52afd75';
    const ROOT_REMOTE_ID_C2 = 't_c2_root';

    /**
     * Albero della trasparenza a cui agganciare gli endpoint (ocopenapi.ini [TrasparenzaEndpoints] Tree)
     */
    public static function getTree(): string
    {
        $ini = eZINI::instance('ocopenapi.ini');
        $tree = $ini->hasVariable('TrasparenzaEndpoints', 'Tree') ?
            strtolower((string)$ini->variable('TrasparenzaEndpoints', 'Tree')) : self::TREE_C1;

        return $tree === self::TREE_C2 ? self::TREE_C2 : self::TREE_C1;
    }

    public static function getRootRemoteId(): string
    {
        return self::getTree() === self::TREE_C2 ? self::ROOT_REMOTE_ID_C2 : self::ROOT_REMOTE_ID_C1;
    }

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