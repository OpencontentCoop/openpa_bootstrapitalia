<?php

class ezfIndexHomepage implements ezfIndexPlugin
{
    // workaround
    public function modify(eZContentObject $contentObject, &$docList)
    {
        $contentIni = eZINI::instance('content.ini');
        $mainNodeId = $contentObject->mainNodeID();
        if ($contentIni->variable('NodeSettings', 'RootNode') == $mainNodeId
            || $contentIni->variable('NodeSettings', 'HomepageNode') == $mainNodeId) {
            eZDebug::writeWarning('Clear template cache on update homepage', __METHOD__);
            eZCache::clearTemplateBlockCache(null);
            if ( eZINI::instance()->variable( 'ContentSettings', 'StaticCache' ) == 'enabled' ) {
                try {
                    eZDebug::writeWarning('Clear static cache on update homepage', __METHOD__);
                    $options = new ezpExtensionOptions([
                        'iniFile' => 'site.ini',
                        'iniSection' => 'ContentSettings',
                        'iniVariable' => 'StaticCacheHandler'
                    ]);
                    $staticCacheHandler = eZExtension::getHandlerClass($options);
                    $staticCacheHandler->generateCache(true, false, false, false);
                }catch (Exception $e){
                    eZDebug::writeError($e->getMessage(), __METHOD__);
                }
            }
        }
    }

}
