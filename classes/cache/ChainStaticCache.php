<?php

use Opencontent\FosHttpCache\Logger;

class ChainStaticCache implements ezpStaticCache
{
    private static $handlers;

    public function generateAlwaysUpdatedCache($quiet = false, $cli = false, $delay = true)
    {
        foreach (self::getHandlers() as $handler){
            $handler->generateAlwaysUpdatedCache($quiet, $cli, $delay);
        }
    }

    public function generateNodeListCache($nodeList)
    {
        foreach (self::getHandlers() as $handler){
            $handler->generateNodeListCache($nodeList);
        }
    }

    public function generateCache($force = false, $quiet = false, $cli = false, $delay = true)
    {
        foreach (self::getHandlers() as $handler){
            $handler->generateCache($force, $quiet, $cli, $delay);
        }
    }

    public function cacheURL($url, $nodeID = false, $skipExisting = false, $delay = true)
    {
        foreach (self::getHandlers() as $handler){
            $handler->cacheURL($url, $nodeID, $skipExisting, $delay);
        }
    }

    public function removeURL($url)
    {
        foreach (self::getHandlers() as $handler){
            $handler->removeURL($url);
        }
    }

    static function executeActions()
    {
        foreach (self::getHandlers() as $handler){
            $handler::executeActions();
        }
    }

    /**
     * @return ezpStaticCache[]
     */
    private static function getHandlers(): array
    {
        if (null === self::$handlers) {
            $ini = eZINI::instance('staticcache.ini');
            self::$handlers = [];
            if ($ini->hasVariable('ChainCacheHandler', 'StaticCacheHandler')) {
                (new Logger())->info(
                    'Init chain staticcache handlers: '
                    . implode(', ', $ini->variable('ChainCacheHandler', 'StaticCacheHandler'))
                );
                foreach ($ini->variable('ChainCacheHandler', 'StaticCacheHandler') as $handler){
                    self::$handlers[] = new $handler();
                }
            }
        }

        return self::$handlers;
    }
}