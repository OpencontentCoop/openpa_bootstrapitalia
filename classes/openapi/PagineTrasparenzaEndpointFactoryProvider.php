<?php

use Opencontent\OpenApi\EndpointDiscover\AbstractSlugClassesEntryPointFactoryProvider;

class PagineTrasparenzaEndpointFactoryProvider extends AbstractSlugClassesEntryPointFactoryProvider
{
    const TRASPARENZA_REMOTE_ID = '5399ef12f98766b90f1804e5d52afd75';

    private static $nodeIdMap;

    protected function getSlugLabel()
    {
        return 'page';
    }

    protected function getPrefix()
    {
        return '/trasparenza';
    }

    protected function getClassIdentifiers()
    {
        return ['link', 'document'];
    }

    protected function getTag()
    {
        return 'trasparenza';
    }

    protected function getSlugIdMap()
    {
        $trasparenzaRoot = eZContentObject::fetchByRemoteID(self::TRASPARENZA_REMOTE_ID);
        if ($trasparenzaRoot instanceof eZContentObject) {
            if (self::$nodeIdMap === null) {
                self::$nodeIdMap = [];
                $menu = OpenPAMenuTool::getTreeMenu([
                    'root_node_id' => $trasparenzaRoot->mainNodeID(),
                    'user_hash' => false,
                    'scope' => 'side_menu',
                ]);
                self::recursiveFindNodeIdMap($menu);
            }
        }
        return self::$nodeIdMap;
    }

    private static function recursiveFindNodeIdMap($menu)
    {
        foreach ($menu['children'] as $item) {
            $slug = \eZCharTransform::instance()->transformByGroup($item['item']['name'], 'identifier');
            if (strlen($slug) > 100) {
                $substr = substr($slug, 0, 100);
                $lastUnderscore = strrpos($substr, " ");
                $slug = substr($substr, 0, $lastUnderscore);
            }
            self::$nodeIdMap[$slug] = $item['item']['node_id'];
            self::recursiveFindNodeIdMap($item);
        }
    }

}