<?php

use Opencontent\Easyontology\MapperRegistry;
use Opencontent\Easyontology\Map;

class BootstrapItaliaInstallerUtils
{
    public static function setGovernmentServiceOntologyMap()
    {
        $classIdentifier = 'public_service';
        $contentClass = eZContentClass::fetchByIdentifier($classIdentifier);
        if ($contentClass instanceof eZContentClass) {
            $collection = MapperRegistry::fetchMapCollectionByClassIdentifier($classIdentifier);
            $map = new Map();
            $map->setSlug('GovernmentService');
            if (!$collection->hasMap($map)) {
                $collection->addMap($map);
                MapperRegistry::storeMapCollection($collection);

                $extraHandler = new EasyOntologyExtraParameter($contentClass);
                $extraHandler->storeParameters([
                    'class' => [
                        $classIdentifier => [
                            'enabled' => 1,
                            'easyontology' => 'GovernmentService',
                        ],
                    ],
                ]);
            }
        }
    }

    public static function resetClassLanguageMask()
    {
        /** @var eZContentClass[] $classList */
        $query = "SELECT id FROM ezcontentclass where version = 0";
        $idList = eZDB::instance()->arrayQuery($query);
        foreach ($idList as $item) {
            $class = eZContentClass::fetch((int)$item['id']);
            $nameList = new eZContentClassNameList();
            $nameList->initFromSerializedList($class->attribute('serialized_name_list'));
            $originalLanguageMask = $class->attribute('language_mask');
            foreach ($nameList->nameList() as $lang => $name) {
                if ($lang !== 'always-available') {
                    $class->setName($name, $lang);
                    $languageMask = $class->attribute('language_mask');
                }
            }
            if ($originalLanguageMask != $languageMask) {
                $class->setAttribute('language_mask', $languageMask);
                eZPersistentObject::storeObject($class);
            }
        }
    }
}