<?php

class ezfIndexEndlessRole implements ezfIndexPlugin
{
    const START_FIELD = 'attr_start_time_dt';
    const END_FIELD = 'attr_end_time_dt';

    public function modify(eZContentObject $contentObject, &$docList)
    {
        if ($contentObject->attribute('class_identifier') == 'time_indexed_role') {
            $version = $contentObject->currentVersion();
            if ($version === false) {
                return;
            }
            $availableLanguages = $version->translationList(false, false);
            /** @var eZContentObjectAttribute[] $dataMap */
            $dataMap = $version->dataMap();
            if ((isset($dataMap['end_time']) && !$dataMap['end_time']->hasContent()) || (isset($dataMap['start_time']) && !$dataMap['start_time']->hasContent())) {

                $endlessDateTime = ezfSolrDocumentFieldBase::convertTimestampToDate(mktime(23, 59, 59, 12, 31, 2100));
                $veryOldDateTime = ezfSolrDocumentFieldBase::convertTimestampToDate(mktime(0, 0, 0, 1, 1, 1970));

                foreach ($availableLanguages as $languageCode) {
                    if ($docList[$languageCode] instanceof eZSolrDoc) {
                        if ($docList[$languageCode]->Doc instanceof DOMDocument) {
                            $xpath = new DomXpath($docList[$languageCode]->Doc);
                            if (!$dataMap['start_time']->hasContent()) {
                                $docList[$languageCode]->addField(self::START_FIELD, $veryOldDateTime);
                            }
                            if (!$dataMap['end_time']->hasContent()) {
                                $docList[$languageCode]->addField(self::END_FIELD, $endlessDateTime);
                            }
                        } elseif (is_array($docList[$languageCode]->Doc)) {
                            if (!$dataMap['start_time']->hasContent()) {
                                $docList[$languageCode]->addField(self::START_FIELD, $veryOldDateTime);
                            }
                            if (!$dataMap['end_time']->hasContent()) {
                                $docList[$languageCode]->addField(self::END_FIELD, $endlessDateTime);
                            }
                        }
                    }
                }
            }
        }
    }
}