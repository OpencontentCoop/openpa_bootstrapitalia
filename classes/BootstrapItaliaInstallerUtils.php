<?php

use Opencontent\Easyontology\MapperRegistry;
use Opencontent\Easyontology\Map;
use Opencontent\Installer\AbstractStepInstaller;

class BootstrapItaliaInstallerUtils
{
    public static function setStaticOntologyMap()
    {
        self::setGovernmentServiceOntologyMap();
        self::setPlaceOntologyMap();
    }

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

    public static function setPlaceOntologyMap()
    {
        $classIdentifier = 'place';
        $contentClass = eZContentClass::fetchByIdentifier($classIdentifier);
        if ($contentClass instanceof eZContentClass) {
            $collection = MapperRegistry::fetchMapCollectionByClassIdentifier($classIdentifier);
            $map = new Map();
            $map->setSlug('Place');
            if (!$collection->hasMap($map)) {
                $collection->addMap($map);
                MapperRegistry::storeMapCollection($collection);

                $extraHandler = new EasyOntologyExtraParameter($contentClass);
                $extraHandler->storeParameters([
                    'class' => [
                        $classIdentifier => [
                            'enabled' => 1,
                            'easyontology' => 'Place',
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

            if ($tag->attribute('main_tag_id') == $mainTag->attribute('id')) {
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

    public static function renameTagMembroInComponente(AbstractStepInstaller $step)
    {
        $db = eZDB::instance();
        $tags = eZTagsObject::fetchByKeyword('Membro');
        $membroM = $tags[0] ?? null;
        $refreshList = [];
        if ($membroM instanceof eZTagsObject) {
            $componenteS = null;
            $synonyms = $membroM->getSynonyms();
            foreach ($synonyms as $synonym) {
                if ($synonym->attribute('keyword') == 'Componente') {
                    $componenteS = $synonym;
                }
            }

            $membroMId = (int)$membroM->attribute('id');
            $relatedList = $db->arrayQuery(
                'SELECT DISTINCT o.id FROM eztags_attribute_link l
                                   INNER JOIN ezcontentobject o ON l.object_id = o.id
                                   AND l.objectattribute_version = o.current_version
                                   AND o.status = 1
                                   WHERE l.keyword_id = ' . $membroMId
            );
            $refreshList = array_merge($refreshList, array_column($relatedList, 'id'));

            $updateMQuery = "UPDATE eztags_keyword 
                SET keyword = 'Componente' 
                WHERE keyword_id = $membroMId AND locale = 'ita-IT' AND keyword = 'Membro'";
            $step->getLogger()->info(' - Change Membro keyword');
            $db->arrayQuery($updateMQuery);

            if ($componenteS instanceof eZTagsObject) {
                $componenteSId = $componenteS->attribute('id');
                $relatedList = $db->arrayQuery(
                    'SELECT DISTINCT o.id FROM eztags_attribute_link l
                                   INNER JOIN ezcontentobject o ON l.object_id = o.id
                                   AND l.objectattribute_version = o.current_version
                                   AND o.status = 1
                                   WHERE l.keyword_id = ' . $componenteSId
                );
                $refreshList = array_merge($refreshList, array_column($relatedList, 'id'));
                $updateSQuery = "UPDATE eztags_keyword 
                    SET keyword = 'Membro' 
                    WHERE keyword_id = $componenteSId AND locale = 'ita-IT' AND keyword = 'Componente'";
                $step->getLogger()->info(' - Change Componente synonym');
                $db->arrayQuery($updateSQuery);
            }

            $step->getLogger()->info(sprintf(' - Refresh %s objects', count($refreshList)));
            foreach ($refreshList as $refresh) {
                $object = eZContentObject::fetch((int)$refresh);
                if ($object instanceof eZContentObject) {
                    $class = $object->contentClass();
                    $object->setName($class->contentObjectName($object));
                    $object->store();
                    eZSearch::getEngine()->addObject($object, true);
                    eZContentObject::clearCache();
                }
            }
            eZContentCacheManager::clearContentCache($refreshList);
        }
    }

    public static function appendToFooterLink(AbstractStepInstaller $step){
        $remoteId = $step->getStep()['remote_id'];
        $object = eZContentObject::fetchByRemoteID($remoteId);
        if ($object instanceof eZContentObject) {
            $home = OpenPaFunctionCollection::fetchHome();
            $dataMap = $home->dataMap();
            $footerLinks = $dataMap['link_nel_footer'] ?? null;
            if ($footerLinks) {
                $currentItems = explode('-', $footerLinks->toString());
                $currentItems[] = $object->attribute('id');
                $footerLinks->fromString(implode('-', $currentItems));
                $footerLinks->store();
            }
        } else {
            $step->getLogger()->error("Object $remoteId not found");
        }
    }

    public static function appendToHeaderLink(AbstractStepInstaller $step){
        $remoteId = $step->getStep()['remote_id'];
        $object = eZContentObject::fetchByRemoteID($remoteId);
        if ($object instanceof eZContentObject) {
            $home = OpenPaFunctionCollection::fetchHome();
            $dataMap = $home->dataMap();
            $headerLinks = $dataMap['link_nell_header'] ?? null;
            if ($headerLinks) {
                $currentItems = explode('-', $headerLinks->toString());
                $currentItems[] = $object->attribute('id');
                $currentItems = array_unique($currentItems);
                $headerLinks->fromString(implode('-', $currentItems));
                $headerLinks->store();
            }
        } else {
            $step->getLogger()->error("Object $remoteId not found");
        }
    }


    public static function addEditorsDatasetLocations(AbstractStepInstaller $step)
    {
        $editorsAmministrazione = eZContentObject::fetchByRemoteID('editors_amministrazione');
        $editorsDataset = eZContentObject::fetchByRemoteID('editors_dataset');
        if ($editorsAmministrazione instanceof eZContentObject && $editorsDataset instanceof eZContentObject) {
            $editorsDatasetNode = $editorsDataset->mainNode();
            if ($editorsDatasetNode->childrenCount(false) == 0) {
                $editorsAmministrazioneNode = $editorsAmministrazione->mainNode();
                /** @var eZContentObjectTreeNode[] $children */
                $children = $editorsAmministrazioneNode->children();
                foreach ($children as $child) {
                    $step->getLogger()->info(' - add location to user ' . $child->attribute('name'));
                    self::addAssignment(
                        $child->attribute('node_id'),
                        $child->attribute('contentobject_id'),
                        [$editorsDatasetNode->attribute('node_id')]
                    );
                }
            }
        }
    }

    /*
     * Crea collocazione senza considerare i permessi
     * @see eZContentOperationCollection::addAssignment
     */
    private static function addAssignment($nodeID, $objectID, $selectedNodeIDArray)
    {
        $userClassIDArray = eZUser::contentClassIDs();

        $object = eZContentObject::fetch($objectID);
        $class = $object->contentClass();

        $nodeAssignmentList = eZNodeAssignment::fetchForObject(
            $objectID,
            $object->attribute('current_version'),
            0,
            false
        );
        $assignedNodes = $object->assignedNodes();

        $parentNodeIDArray = [];

        foreach ($assignedNodes as $assignedNode) {
            $append = false;
            foreach ($nodeAssignmentList as $nodeAssignment) {
                if ($nodeAssignment['parent_node'] == $assignedNode->attribute('parent_node_id')) {
                    $append = true;
                    break;
                }
            }
            if ($append) {
                $parentNodeIDArray[] = $assignedNode->attribute('parent_node_id');
            }
        }

        $db = eZDB::instance();
        $db->begin();
        $locationAdded = false;
        $node = eZContentObjectTreeNode::fetch($nodeID);
        foreach ($selectedNodeIDArray as $selectedNodeID) {
            if (!in_array($selectedNodeID, $parentNodeIDArray)) {
                $parentNode = eZContentObjectTreeNode::fetch($selectedNodeID);
                $parentNodeObject = $parentNode->attribute('object');

                $insertedNode = $object->addLocation($selectedNodeID, true);

                // Now set is as published and fix main_node_id
                $insertedNode->setAttribute('contentobject_is_published', 1);
                $insertedNode->setAttribute('main_node_id', $node->attribute('main_node_id'));
                $insertedNode->setAttribute('contentobject_version', $node->attribute('contentobject_version'));
                // Make sure the url alias is set updated.
                $insertedNode->updateSubTreePath();
                $insertedNode->sync();

                $locationAdded = true;
            }
        }
        if ($locationAdded) {
            eZSearch::addNodeAssignment($nodeID, $objectID, $selectedNodeIDArray);
            if (in_array($object->attribute('contentclass_id'), $userClassIDArray)) {
                eZUser::purgeUserCacheByUserId($object->attribute('id'));
            }
        }
        $db->commit();
        eZContentCacheManager::clearContentCacheIfNeeded($objectID);
        if (!eZSearch::getEngine() instanceof eZSearchEngine) {
            eZContentOperationCollection::registerSearchObject($objectID);
        }
    }
}