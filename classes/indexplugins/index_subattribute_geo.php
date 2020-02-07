<?php

use Opencontent\Opendata\Api\Values\ExtraDataProviderInterface;
use Opencontent\Opendata\Api\Values\ExtraData;

class ezfIndexSubAttributeGeo implements ezfIndexPlugin, ExtraDataProviderInterface
{
    const FIELD = 'extra_geo____gpt';

    private static $geoClassIdentifiers;

    private static $objectCache = [];

    public function modify(eZContentObject $contentObject, &$docList)
    {
        $version = $contentObject->currentVersion();
        if ($version === false) {
            return;
        }
        $availableLanguages = $version->translationList(false, false);

        $subGeoValues = self::getSubAttributeGeo($contentObject);
        if (!empty($subGeoValues)) {
            foreach ($subGeoValues as $subGeoValue) {
                if (!empty($subGeoValue) && !empty($subGeoValue[0]) && !empty($subGeoValue[1])) {
                    foreach ($availableLanguages as $languageCode) {
                        if ($docList[$languageCode] instanceof eZSolrDoc) {
                            if ($docList[$languageCode]->Doc instanceof DOMDocument) {
                                $xpath = new DomXpath($docList[$languageCode]->Doc);
                                $docList[$languageCode]->addField(self::FIELD, implode(',', $subGeoValue));
                            } elseif (is_array($docList[$languageCode]->Doc)) {
                                $docList[$languageCode]->addField(self::FIELD, implode(',', $subGeoValue));
                            }
                        }
                    }
                }
            }
        }
    }

    private static function getGeoClassIdentifiers()
    {
        if (self::$geoClassIdentifiers === null) {
            self::$geoClassIdentifiers = [];
            $classIds = eZContentClass::fetchIDListContainingDatatype(eZGmapLocationType::DATA_TYPE_STRING);
            if (count($classIds) > 0) {
                foreach ($classIds as $id) {
                    self::$geoClassIdentifiers[] = eZContentClass::classIdentifierByID($id);
                }
            }
        }

        return self::$geoClassIdentifiers;
    }

    private static function getSubAttributeGeo(eZContentObject $contentObject)
    {
        if (!isset(self::$objectCache[$contentObject->attribute('id')])) {
            self::$objectCache[$contentObject->attribute('id')] = [];
            /** @var eZContentObjectAttribute[] $dataMap */
            $dataMap = $contentObject->dataMap();
            foreach ($dataMap as $identifier => $attribute) {
                if ($attribute->hasContent() && $attribute->attribute('data_type_string') == eZObjectRelationListType::DATA_TYPE_STRING) {
                    $classAttributeContent = $attribute->attribute('contentclass_attribute')->content();
                    foreach ($classAttributeContent['class_constraint_list'] as $classIdentifier) {
                        if (in_array($classIdentifier, self::getGeoClassIdentifiers())) {
                            $objects = OpenPABase::fetchObjects(explode('-', $attribute->toString()));
                            foreach ($objects as $object) {
                                $objectDataMap = $object->dataMap();
                                foreach ($objectDataMap as $objectAttribute) {
                                    if ($objectAttribute->attribute('data_type_string') == eZGmapLocationType::DATA_TYPE_STRING) {
                                        $longitude = $objectAttribute->attribute('content')->attribute('longitude');
                                        $latitude = $objectAttribute->attribute('content')->attribute('latitude');
                                        self::$objectCache[$contentObject->attribute('id')][] = ['longitude' => $longitude, 'latitude' => $latitude];
                                    }
                                }
                            }
                        }
                    }

                }
            }
        }
        return self::$objectCache[$contentObject->attribute('id')];

    }

    public function setExtraDataFromContentObject(eZContentObject $contentObject, ExtraData $extraData)
    {
        $subGeoValues = self::getSubAttributeGeo($contentObject);
        $extraData->set('geo', $subGeoValues);
    }


}