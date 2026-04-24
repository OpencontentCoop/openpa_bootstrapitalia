<?php

class ezfIndexUserEnabled implements ezfIndexPlugin
{
    public function modify(eZContentObject $contentObject, &$docList)
    {
        $user = eZUser::fetch($contentObject->attribute('id'));
        if (!$user instanceof eZUser) {
            return;
        }
        $isEnabled = (bool)$user->attribute('is_enabled');
        $version = $contentObject->currentVersion();
        if ($version === false) {
            return;
        }
        $availableLanguages = $version->translationList(false, false);
        foreach ($availableLanguages as $languageCode) {
            if ($docList[$languageCode] instanceof eZSolrDoc) {
                $docList[$languageCode]->addField('attr_is_enabled_b', $isEnabled);
            }
        }
    }
}
