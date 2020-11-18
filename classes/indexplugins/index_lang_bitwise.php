<?php

class ezfIndexLangBitwise implements ezfIndexPlugin
{
    const EXTRA_FIELD_PREFIX = 'extra_lang_';

    /**
     * @param eZContentObject $contentObect
     * @param array $docList
     */
    public function modify(eZContentObject $contentObject, &$docList)
    {
        $version = $contentObject->currentVersion();
        if ($version === false) {
            return;
        }
        $availableLanguages = $version->translationList(false, false);

        $extraFields = $allLanguagesCodes = [];
        foreach (eZContentLanguage::fetchList() as $language) {
            $allLanguagesCodes[] = $language->attribute('locale');
        }

        $base = array_fill_keys($allLanguagesCodes, 'false');

        foreach ($availableLanguages as $languageCode) {
            $extraFields[$languageCode] = $base;
            $extraFields[$languageCode][$languageCode] = 'true';
        }

        foreach ($allLanguagesCodes as $languageCode) {
            if (!in_array($languageCode, $availableLanguages)) {
                if (isset($extraFields['eng-GB'])) {
                    $extraFields['eng-GB'][$languageCode] = 'true';
                } else {
                    $extraFields[$availableLanguages[0]][$languageCode] = 'true';
                }
            }
        }

        foreach ($availableLanguages as $languageCode) {
            foreach ($extraFields[$languageCode] as $code => $value) {
                $extraField = $this->getExtraFieldString($code);
                if (isset($docList[$languageCode])) {
                    if ($docList[$languageCode] instanceof eZSolrDoc) {
                        if ($docList[$languageCode]->Doc instanceof DOMDocument) {
                            $xpath = new DomXpath($docList[$languageCode]->Doc);
                            if ($xpath->evaluate('//field[@name="' . $extraField . '"]')->length == 0) {
                                $docList[$languageCode]->addField($extraField, $value);
                            }
                        } elseif (is_array($docList[$languageCode]->Doc) && !isset($docList[$languageCode]->Doc[$extraField])) {
                            $docList[$languageCode]->addField($extraField, $value);
                        }
                    }
                }
            }
        }
    }

    private function getExtraFieldString($languageCode)
    {
        return 'extra_lang_' . $languageCode . '_b';
    }
}
