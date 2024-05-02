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
            $languageMask = null;
            foreach ($nameList->nameList() as $lang => $name) {
                if ($lang !== 'always-available') {
                    $class->setName($name, $lang);
                    $languageMask = $class->attribute('language_mask');
                }
            }
            if ($languageMask && $originalLanguageMask != $languageMask) {
                $class->setAttribute('language_mask', $languageMask);
                eZPersistentObject::storeObject($class);
            }
        }
    }

    public static function convertDocumentAuthorDatatype()
    {
        $class = eZContentClass::fetchByIdentifier('document');
        if ($class instanceof eZContentClass) {
            /** @var eZContentClassAttribute[] $attributes */
            $attributes = $class->dataMap();
            $attributeClass = $attributes['author'];

            if ($attributeClass->attribute('data_type_string') !== eZAuthorType::DATA_TYPE_STRING) {
                return;
            }

            $db = eZDB::instance();
            /** @var eZContentObjectAttribute[] $attributeObjects */
            $attributeObjects = eZContentObjectAttribute::fetchObjectList(
                eZContentObjectAttribute::definition(),
                null,
                ['contentclassattribute_id' => $attributeClass->attribute('id')]
            );

            $db->begin();
            $attributeClass->setAttribute('data_type_string', eZXMLTextType::DATA_TYPE_STRING);
            $attributeClass->store();
            foreach ($attributeObjects as $attributeObject) {
                if ($attributeObject->hasContent()) {
                    /** @var eZAuthor $content */
                    $content = $attributeObject->attribute('content');
                    $authorList = [];
                    foreach ($content->attribute('author_list') as $author) {
                        if (!eZUser::fetchByEmail($author['email'])) {
                            $authorList[] = '<li>' . $author['name'] . '</li>';
                        }
                    }
                    $authorAsEzXml = '';
                    if (count($authorList)) {
                        $authorAsEzXml = '<ul>' . implode('', $authorList) . '</ul>';
                    }
                    $attributeObject->setAttribute('data_text', SQLIContentUtils::getRichContent($authorAsEzXml));
                    $attributeObject->setAttribute(
                        'data_type_string',
                        eZXMLTextType::DATA_TYPE_STRING
                    );
                    $attributeObject->store();
                }
            }
            $db->commit();
        }
    }

    public static function addEventLinkInSetupHomepage()
    {
        $class = eZContentClass::fetchByIdentifier('edit_homepage');
        if ($class instanceof eZContentClass) {
            $dataMap = $class->dataMap();
            $attributeIdentifier = 'section_calendar';
            $targetClassIdentifier = 'event_link';
            if (isset($dataMap[$attributeIdentifier])
                && $dataMap[$attributeIdentifier]->attribute(
                    'data_type_string'
                ) == eZObjectRelationListType::DATA_TYPE_STRING) {
                $eventLink = eZContentClass::fetchByIdentifier($targetClassIdentifier);
                if ($eventLink instanceof eZContentClass) {
                    $xmlText = $dataMap[$attributeIdentifier]->attribute('data_text5');
                    if (trim($xmlText) !== '') {
                        $doc = eZObjectRelationListType::parseXML($xmlText);
                        $structure = (array)(new eZObjectRelationListType())->createClassContentStructure($doc);
                        if (!in_array($targetClassIdentifier, $structure['class_constraint_list'])) {
                            $structure['class_constraint_list'][] = $targetClassIdentifier;
                            $doc = eZObjectRelationListType::createClassDOMDocument($structure);
                            $docText = eZObjectRelationListType::domString($doc);
                            $dataMap[$attributeIdentifier]->setAttribute('data_text5', $docText);
                            $dataMap[$attributeIdentifier]->store();
                            $handler = eZExpiryHandler::instance();
                            $handler->setTimestamp('user-class-cache', time());
                            $handler->store();
                            ezpEvent::getInstance()->notify('content/class/cache', [$class->attribute('id')]);
                        }
                    }
                }
            }
        }
    }

    public static function clearTrasparenzaMenu()
    {
        $nodeId = OpenPAOperator::getTrasparenzaRootNodeId();
        if ($nodeId) {
            $parameters = [
                'root_node_id' => $nodeId,
                'scope' => 'side_menu',
                'user_hash' => false,
            ];
            $menuHandler = new OpenPATreeMenuHandler($parameters);
            OpenPAMenuTool::refreshMenu($menuHandler->cacheFileName());
            eZCache::clearTemplateBlockCache(null);
        }
    }

    public static function fixDocumentTypeTags()
    {
        $tagsToSynonyms = [
            'pdf' => 'PDF',
            'odt' => 'ODT',
        ];
        foreach ($tagsToSynonyms as $synonym => $main) {
            /** @var eZTagsObject $tag */
            $tag = eZTagsObject::fetchByKeyword($synonym)[0] ?? null;
            /** @var eZTagsObject $mainTag */
            $mainTag = eZTagsObject::fetchByKeyword($main)[0] ?? null;

            if (!$tag || !$mainTag) {
                continue;
            }

            if ($tag->attribute( 'main_tag_id' ) == $mainTag->attribute('id')) {
                continue;
            }

            $updateDepth = false;
            $updatePathString = false;

            $db = eZDB::instance();
            $db->begin();

            if ($tag->attribute('depth') != $mainTag->attribute('depth')) {
                $updateDepth = true;
            }

            if ($tag->attribute('parent_id') != $mainTag->attribute('parent_id')) {
                $oldParentTag = $tag->getParent(true);
                if ($oldParentTag instanceof eZTagsObject) {
                    $oldParentTag->updateModified();
                }

                $updatePathString = true;
            }

            $tag->moveChildrenBelowAnotherTag($mainTag);

            $synonyms = $tag->getSynonyms(true);
            foreach ($synonyms as $synonym) {
                $synonym->setAttribute('parent_id', $mainTag->attribute('parent_id'));
                $synonym->setAttribute('main_tag_id', $mainTag->attribute('id'));
                $synonym->store();
            }

            $tag->setAttribute('parent_id', $mainTag->attribute('parent_id'));
            $tag->setAttribute('main_tag_id', $mainTag->attribute('id'));
            $tag->store();

            if ($updatePathString) {
                $tag->updatePathString();
            }

            if ($updateDepth) {
                $tag->updateDepth();
            }

            $tag->updateModified();

            if (eZINI::instance('eztags.ini')->variable('SearchSettings', 'IndexSynonyms') !== 'enabled') {
                $tag->registerSearchObjects();
            }

            $db->commit();
        }
    }
}