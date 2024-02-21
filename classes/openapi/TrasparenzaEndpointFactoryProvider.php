<?php

use Lotti\LottiEndpointFactoryProvider;
use Opencontent\OpenApi\EndpointDiscover\ChainEndpointFactoryDiscover;
use PagineTrasparenza\PagineTrasparenzaEndpointFactoryProvider;

class TrasparenzaEndpointFactoryProvider extends ChainEndpointFactoryDiscover
{
    public function __construct()
    {
        $providers = [
            new PagineTrasparenzaEndpointFactoryProvider(),
            new LottiEndpointFactoryProvider(),
        ];
        parent::__construct($providers);
    }

    public static function clearTrasparenzaTree()
    {
        self::regenerateTrasparenzaTree();
        self::clearSchemaBuilder();
    }

    public static function clearSchemaBuilder()
    {
        $schemaBuilder = \Opencontent\OpenApi\Loader::instance()->getSchemaBuilder();
        if ($schemaBuilder instanceof \Opencontent\OpenApi\CachedSchemaBuilder){
            $schemaBuilder->clearCache();
        }
    }

    private static function regenerateTrasparenzaTree()
    {
        $trasparenzaRoot = eZContentObject::fetchByRemoteID(
            PagineTrasparenzaEndpointFactoryProvider::TRASPARENZA_REMOTE_ID
        );
        if ($trasparenzaRoot instanceof eZContentObject) {
            $parameters = [
                'root_node_id' => $trasparenzaRoot->mainNodeID(),
                'user_hash' => false,
                'scope' => 'side_menu',
            ];
            $menu = new OpenPATreeMenuHandler($parameters);
            $fileHandler = eZClusterFileHandler::instance(eZDir::path(
                [
                    eZSys::cacheDirectory(),
                    OpenPAMenuTool::cacheDirectory(),
                    OpenPABase::getFrontendSiteaccessName(),
                    $menu->cacheFileName(),
                ]
            ));
            try {
                eZDB::setErrorHandling(eZDB::ERROR_HANDLING_EXCEPTIONS);
                eZDB::instance()->query("DELETE FROM ezdfsfile_cache WHERE name = '$cachePath'");
            } catch (Throwable $e) {
            }
            $fileHandler->processCache(
                null,
                ['OpenPATreeMenuHandler', 'menuGenerate'],
                null,
                null,
                compact('parameters')
            );
        }
    }

    public function clearCache()
    {
        self::regenerateTrasparenzaTree();;
        parent::clearCache();
    }


}