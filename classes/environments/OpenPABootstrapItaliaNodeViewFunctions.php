<?php

class OpenPABootstrapItaliaNodeViewFunctions extends eZNodeviewfunctions
{
    /**
     * @var bool
     * @see DataHandlerOpendataQueriedContents::getData()
     */
    private static $isIgnoringPolicy = false;

    public static function setIgnorePolicy($ignorePolicy)
    {
        self::$isIgnoringPolicy = (bool)$ignorePolicy;
    }

    public static function isIgnoringPolicy()
    {
        return self::$isIgnoringPolicy;
    }

    /**
     * @param false|string $file
     * @param array $args
     * @return array
     * @see OpenPABootstrapItaliaContentEnvironmentSettings::filterContent()
     */
    static public function contentViewGenerate($file, $args)
    {
        extract($args);
        $node = eZContentObjectTreeNode::fetch($NodeID);
        if (!$node instanceof eZContentObjectTreeNode) {
            if (!eZDB::instance()->isConnected()) {
                return self::contentViewGenerateError($Module, eZError::KERNEL_NO_DB_CONNECTION, false);
            }

            return self::contentViewGenerateError($Module, eZError::KERNEL_NOT_AVAILABLE);
        }

        $object = $node->attribute('object');
        if (!$object instanceof eZContentObject) {
            return self::contentViewGenerateError($Module, eZError::KERNEL_NOT_AVAILABLE);
        }

        if ($node->attribute('is_invisible') && !eZContentObjectTreeNode::showInvisibleNodes()) {
            return self::contentViewGenerateError($Module, eZError::KERNEL_ACCESS_DENIED);
        }

        if (!$node->canRead() && !self::$isIgnoringPolicy) {
            return self::contentViewGenerateError(
                $Module,
                eZError::KERNEL_ACCESS_DENIED,
                true,
                ['AccessList' => $node->checkAccess('read', false, false, true)]
            );
        }

        $result = self::generateNodeViewData(
            $tpl,
            $node,
            $object,
            $LanguageCode,
            $ViewMode,
            $Offset,
            $viewParameters,
            $collectionAttributes,
            $validation
        );

        // 'store' depends on noCache: if $noCache is set, this means that retrieve
        // returned it, and the noCache fake cache file is already stored
        // and should not be stored again
        $retval = ['content' => $result,
            'scope' => 'viewcache',
            'store' => !(isset($noCache) and $noCache)];
        if ($file !== false && $retval['store'])
            $retval['binarydata'] = serialize($result);
        return $retval;
    }

    static protected function contentViewGenerateError( eZModule $Module, $error, $store = true, array $errorParameters = array() )
    {
        $content = '';

        return array(
            'content' => $content,
            'scope' => 'viewcache',
            'store' => $store,
            'binarydata' => serialize( $content ),
        );
    }
}
