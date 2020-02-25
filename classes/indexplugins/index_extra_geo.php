<?php

class ezfIndexExtraGeo implements ezfIndexPlugin
{
    const FIELD = 'extra_geo_rpt';

    public function modify(eZContentObject $contentObject, &$docList)
    {
        $version = $contentObject->currentVersion();
        if ($version === false) {
            return;
        }
        $availableLanguages = $version->translationList(false, false);

        $extraGeo = self::getExtraGeo($contentObject);
        if ($extraGeo) {
            foreach ($availableLanguages as $languageCode) {
                if ($docList[$languageCode] instanceof eZSolrDoc) {
                    if ($docList[$languageCode]->Doc instanceof DOMDocument) {
                        $xpath = new DomXpath($docList[$languageCode]->Doc);
                        $docList[$languageCode]->addField(self::FIELD, $extraGeo);
                    } elseif (is_array($docList[$languageCode]->Doc)) {
                        $docList[$languageCode]->addField(self::FIELD, $extraGeo);
                    }
                }
            }
        }
    }

    private static function getExtraGeo(eZContentObject $contentObject)
    {
        foreach ($contentObject->dataMap() as $attribute){
            if ($attribute->attribute('data_type_string') === eZGmapLocationType::DATA_TYPE_STRING && $attribute->hasContent()){
                /** @var eZGmapLocation $geo */
                $geo = $attribute->content();
                return $geo->attribute('longitude') . ' ' . $geo->attribute('latitude');
            }
        }

        return false;
    }
}
