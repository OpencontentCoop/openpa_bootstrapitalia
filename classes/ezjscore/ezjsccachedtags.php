<?php

/**
 * ezjscTags class implements eZ JS Core server functions for eztags
 */
class ezjscCachedTags extends ezjscTags
{
    /**
     * Returns children tags formatted for tree view plugin
     *
     * @static
     *
     * @param array $args
     *
     * @return array
     */
    static public function tree($args)
    {
        $tagID = 0;
        if (isset($args[0]) && is_numeric($args[0])) {
            $tagID = (int)$args[0];

            $tag = eZTagsObject::fetch($tagID);
            if ($tag instanceof eZTagsObject) {
                $retrieveCallback = function ($file) {
                    return include($file);
                };
                $cacheFileHandler = self::getCacheFileHandler($tagID);
                if ($cacheFileHandler->exists() && $cacheFileHandler->isExpired($tag->attribute('modified'), null, null)){
                    $retrieveCallback = null;
                }

                return $cacheFileHandler->processCache(
                    $retrieveCallback,
                    function ($file, $tagID) {
                        $tagTree = ezjscTags::tree([$tagID]);

                        return array(
                            'content' => $tagTree,
                            'scope' => 'tags_tree-cache',
                            'datatype' => 'php',
                            'store' => true
                        );
                    },
                    null,
                    null,
                    $tagID
                );
            }
        }

        return parent::tree($args);
    }

    protected static function getCacheFileHandler($identifier)
    {
        $cacheFile = $identifier . '.cache';
        $cacheFilePath = eZDir::path(
            array(eZSys::cacheDirectory(), 'cached_tags_tree', $cacheFile)
        );

        return eZClusterFileHandler::instance($cacheFilePath);
    }
}
