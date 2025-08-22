<?php

class ezfIndexFaseBando implements ezfIndexPlugin
{
    public function modify(eZContentObject $contentObject, &$docList)
    {
        $version = $contentObject->currentVersion();
        if ($version === false) {
            return;
        }
        $groups = [
            'pubblicazione',
            'affidamento',
            'esecutiva',
            'sponsorizzazioni',
            'somma_urgenza',
            'finanza',
        ];
        $availableLanguages = $version->translationList(false, false);
        $dataMap = $contentObject->dataMap();
        foreach ($groups as $group) {
            $value = 0;
            foreach (['', '_relations'] as $suffix) {
                if (isset($dataMap[$group . $suffix]) && $dataMap[$group . $suffix]->hasContent()) {
                    $value++;
                }
            }
            foreach ($availableLanguages as $languageCode) {
                if ($docList[$languageCode] instanceof eZSolrDoc) {
                    $docList[$languageCode]->addField("extra_{$group}_si", $value);
                }
            }
        }
    }
}
