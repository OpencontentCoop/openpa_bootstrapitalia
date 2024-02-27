<?php

class ezfIndexPublicServiceMenu implements ezfIndexPlugin
{
    public function modify(eZContentObject $contentObject, &$docList)
    {
        $aliases = BootstrapItaliaClassAlias::getAliasIdList();
        $publicServiceClassId = eZContentClass::classIDByIdentifier('public_service');
        $publicServiceClasses = [$publicServiceClassId];
        if (isset($aliases[$publicServiceClassId])) {
            $publicServiceClasses[] = $aliases[$publicServiceClassId];
        }

        if (in_array($contentObject->attribute('contentclass_id'), $publicServiceClasses)) {
            self::clearServiceMenu();
        }
    }

    private static function clearServiceMenu()
    {
        try {
            $allService = eZContentObject::fetchByRemoteID('all-services');
            if ($allService instanceof eZContentObject) {
                $rootNode = $allService->mainNode();
                if ($rootNode instanceof eZContentObjectTreeNode) {
                    $mainParentNodeId = $rootNode->attribute('node_id');
                    $serviceMenuList = OpenPABootstrapItaliaOperators::getTagMenuIdList($rootNode);
                    $serviceMenuIdList = array_map(function ($val) use ($mainParentNodeId) {
                        return $mainParentNodeId . '-' . $val;
                    }, array_column($serviceMenuList, 'id'));
                    sort($serviceMenuIdList);

                    $parameters = [
                        'root_node_id' => $mainParentNodeId,
                        'scope' => 'side_menu',
                        'hide_empty_tag' => true,
                        'hide_empty_tag_callback' => ['OpenPABootstrapItaliaOperators', 'tagTreeHasContents'],
                    ];
                    $menu = (array)OpenPAMenuTool::getTreeMenu($parameters);

                    if (!empty($menu['children'])) {
                        $currentMenuItemList = array_column($menu['children'], 'item');
                        $currentMenuIdList = array_column($currentMenuItemList, 'node_id');
                        sort($currentMenuIdList);

                        if ($currentMenuIdList != $serviceMenuIdList) {
                            $menuHandler = new OpenPATreeMenuHandler($parameters);
                            eZDebug::writeDebug(
                                'Clear menu and template cache on modify public_service',
                                __METHOD__
                            );
                            OpenPAMenuTool::refreshMenu($menuHandler->cacheFileName());
                            eZCache::clearTemplateBlockCache(null);
                            ezfIndexHomepage::clearStaticCache();
                        }
                    }
                }
            }
        } catch (Throwable $e) {
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }
    }
}