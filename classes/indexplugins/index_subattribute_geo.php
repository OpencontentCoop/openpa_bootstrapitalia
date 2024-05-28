<?php

use Opencontent\Opendata\Api\Values\ExtraDataProviderInterface;
use Opencontent\Opendata\Api\Values\ExtraData;

class ezfIndexSubAttributeGeo implements ezfIndexPlugin, ExtraDataProviderInterface
{
    const FIELD = 'extra_geo____gpt';
    const RPT_FIELD = 'extra_geo____rpt';

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
            foreach ($subGeoValues as $index => $subGeoValue) {
                if (!empty($subGeoValue) && !empty($subGeoValue['longitude']) && !empty($subGeoValue['latitude'])) {
                    foreach ($availableLanguages as $languageCode) {
                        if ($docList[$languageCode] instanceof eZSolrDoc) {
                            $docList[$languageCode]->addField(self::FIELD, implode(',', $subGeoValue));
                            if ($index === 0) {
                                $docList[$languageCode]->addField(self::RPT_FIELD, $subGeoValue['longitude'] . ' ' . $subGeoValue['latitude']);
                            }
                        }
                    }
                }
            }
        }
    }

    private static function getGeoClassIdentifiers($contextClassIdentifier = null)
    {
        if (!isset(self::$geoClassIdentifiers[$contextClassIdentifier])) {
            $geoClassIdentifiers = [];
            $avoidIdentifiers = [];
            if ($contextClassIdentifier) {
                $excludeList = OpenPAINI::variable('MotoreRicerca', 'ExcludeRelatedClassesFromIndexSubAttributeGeo', []);
                if (isset($excludeList[$contextClassIdentifier])) {
                    $avoidIdentifiers = explode(',', $excludeList[$contextClassIdentifier]);
                }
            }
            $classIds = eZContentClass::fetchIDListContainingDatatype(eZGmapLocationType::DATA_TYPE_STRING);
            if (count($classIds) > 0) {
                foreach ($classIds as $id) {
                    $identifier = eZContentClass::classIdentifierByID($id);
                    if (!in_array($identifier, $avoidIdentifiers)) {
                        $geoClassIdentifiers[] = $identifier;
                    }
                }
            }

            self::$geoClassIdentifiers[$contextClassIdentifier] = $geoClassIdentifiers;
        }
        
        return self::$geoClassIdentifiers[$contextClassIdentifier];
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
                        if (in_array($classIdentifier, self::getGeoClassIdentifiers($contentObject->attribute('class_identifier')))) {
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
