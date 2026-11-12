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

    public static function appendToFooterLink(AbstractStepInstaller $step)
    {
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

    public static function appendToHeaderLink(AbstractStepInstaller $step)
    {
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

    /**
     * @see https://gitlab.com/opencity-labs/sito-istituzionale/cms/-/work_items/331
     * steps:
     *     ...
     *     -   type: php_callable
     *         identifier: 'BootstrapItaliaInstallerUtils::migratePrivacyObjectStates'
     *         class: 'article'
     *         start_attribute: 'published'
     *         end_attribute: 'dead_line'
     *
     *     -   type: php_callable
     *         identifier: 'BootstrapItaliaInstallerUtils::migratePrivacyObjectStates'
     *         class: 'document'
     *         start_attribute: 'publication_start_time'
     *         end_attribute: 'expiration_time'
     * ...
     * @param AbstractStepInstaller $step
     * @return void
     * @throws Exception
     */
    public static function migratePrivacyObjectStates(AbstractStepInstaller $step)
    {
        $stepData = $step->getStep();
        $classIdentifier = $stepData['class'];
        $startDateIdentifier = $stepData['start_attribute'] ?? '?';
        $endDateIdentifier = $stepData['end_attribute'] ?? '?';

        if (!eZContentClass::classIDByIdentifier($classIdentifier)) {
            throw new Exception("Class $classIdentifier not found");
        }
        if (!eZContentObjectTreeNode::classAttributeIDByIdentifier("$classIdentifier/$startDateIdentifier")) {
            throw new Exception("Attribute $startDateIdentifier of class $classIdentifier not found");
        }
        if (!eZContentObjectTreeNode::classAttributeIDByIdentifier("$classIdentifier/$endDateIdentifier")) {
            throw new Exception("Attribute $endDateIdentifier of class $classIdentifier not found");
        }

        $currentDate = time();
        $privacyStates = OpenPABase::initStateGroup('privacy', ['public', 'private', 'scheduled', 'expired']);

        $step->getLogger()->info(' - Check ' . $classIdentifier . 's to mark them as expired');
        /** @var eZContentObjectTreeNode[] $makeExpired */
        $makeExpired = eZContentObjectTreeNode::subTreeByNodeID([
            'ClassFilterType' => 'include',
            'ClassFilterArray' => [$classIdentifier],
            'AttributeFilter' => [
                'and',
                ["{$classIdentifier}/{$endDateIdentifier}", '<', $currentDate],
                ["{$classIdentifier}/{$endDateIdentifier}", '>', 0],
                ['state', "=", $privacyStates['privacy.private']->attribute('id')],
            ],
        ], 1);
        if (count($makeExpired)) {
            $step->getLogger()->info('   -> Mark ' . count($makeExpired) . ' ' . $classIdentifier . '(s) as expired');

            foreach ($makeExpired as $expired) {
                $step->getLogger()->debug('   - ' . $expired->attribute('name'));
                eZContentOperationCollection::updateObjectState($expired->attribute('contentobject_id'), [$privacyStates['privacy.expired']->attribute('id')]);
            }
        } else {
            $step->getLogger()->info('   -> no changes needed');
        }

        $step->getLogger()->info(' - Check ' . $classIdentifier . 's to mark them as scheduled');
        $makeScheduledWithEndDate = eZContentObjectTreeNode::subTreeByNodeID([
            'ClassFilterType' => 'include',
            'ClassFilterArray' => [$classIdentifier],
            'AttributeFilter' => [
                'and',
                ["{$classIdentifier}/{$startDateIdentifier}", '>', $currentDate],
                ["{$classIdentifier}/{$startDateIdentifier}", '>', 0],
                ["{$classIdentifier}/{$endDateIdentifier}", '>', $currentDate],
                ["{$classIdentifier}/{$endDateIdentifier}", '>', 0],
                ['state', "=", $privacyStates['privacy.private']->attribute('id')],
            ],
        ], 1);
        $makeScheduledWithoutEndDate = eZContentObjectTreeNode::subTreeByNodeID([
            'ClassFilterType' => 'include',
            'ClassFilterArray' => [$classIdentifier],
            'AttributeFilter' => [
                'and',
                ["{$classIdentifier}/{$startDateIdentifier}", '>', $currentDate],
                ["{$classIdentifier}/{$startDateIdentifier}", '>', 0],
                ["{$classIdentifier}/{$endDateIdentifier}", '=', 0],
                ['state', "=", $privacyStates['privacy.private']->attribute('id')],
            ],
        ], 1);
        /** @var eZContentObjectTreeNode[] $makeScheduled */
        $makeScheduled = array_merge($makeScheduledWithEndDate, $makeScheduledWithoutEndDate);
        if (count($makeScheduled)) {
            $step->getLogger()->info('   -> Mark ' . count($makeScheduled) . ' ' . $classIdentifier . '(s) as scheduled');
            foreach ($makeScheduled as $scheduled) {
                $step->getLogger()->debug('   - ' . $scheduled->attribute('name'));
                eZContentOperationCollection::updateObjectState($scheduled->attribute('contentobject_id'), [$privacyStates['privacy.scheduled']->attribute('id')]);
            }
        } else {
            $step->getLogger()->info('   -> no changes needed');
        }
    }

    /**
     * Imposta un attributo booleano a true su tutti i contenuti con un dato stato privacy,
     * poi cambia il loro stato privacy.
     * steps:
     *     ...
     *     -   type: php_callable
     *         identifier: 'BootstrapItaliaInstallerUtils::setBooleanAttributeAndChangeState'
     *         class: 'place'
     *         boolean_attribute: 'excluded_from_listing'
     *         from_state: 'privacy.private'
     *         to_state: 'privacy.public'
     *     ...
     * @param AbstractStepInstaller $step
     * @return void
     * @throws Exception
     */
    public static function setBooleanAttributeAndChangeState(AbstractStepInstaller $step)
    {
        $stepData = $step->getStep();
        $classIdentifier = $stepData['class'];
        $booleanAttributeIdentifier = $stepData['boolean_attribute'];
        $fromState = $stepData['from_state'];
        $toState = $stepData['to_state'];

        if (!eZContentClass::classIDByIdentifier($classIdentifier)) {
            throw new Exception("Class $classIdentifier not found");
        }
        $class = eZContentClass::fetchByIdentifier($classIdentifier);
        if (!$class || !$class->fetchAttributeByIdentifier($booleanAttributeIdentifier)) {
            throw new Exception("Attribute $booleanAttributeIdentifier of class $classIdentifier not found");
        }

        [$fromStateGroup, $fromStateIdentifier] = explode('.', $fromState, 2);
        [$toStateGroup, $toStateIdentifier] = explode('.', $toState, 2);
        $stateIdentifiers = array_unique([$fromStateIdentifier, $toStateIdentifier]);
        $states = OpenPABase::initStateGroup($fromStateGroup, $stateIdentifiers);

        if (!isset($states[$fromState])) {
            throw new Exception("State $fromState not found");
        }
        if (!isset($states[$toState])) {
            throw new Exception("State $toState not found");
        }

        $step->getLogger()->info(" - Cerco $classIdentifier con stato $fromState");
        /** @var eZContentObjectTreeNode[] $nodes */
        $nodes = eZContentObjectTreeNode::subTreeByNodeID([
            'ClassFilterType' => 'include',
            'ClassFilterArray' => [$classIdentifier],
            'AttributeFilter' => [
                ['state', '=', $states[$fromState]->attribute('id')],
            ],
        ], 1);

        if (!count($nodes)) {
            $step->getLogger()->info('   -> nessuna modifica necessaria');
            return;
        }

        $step->getLogger()->info('   -> ' . count($nodes) . " $classIdentifier da migrare");
        foreach ($nodes as $node) {
            $step->getLogger()->debug('   - ' . $node->attribute('name'));
            $object = $node->attribute('object');
            $dataMap = $object->dataMap();
            if (isset($dataMap[$booleanAttributeIdentifier])) {
                $attr = $dataMap[$booleanAttributeIdentifier];
                $attr->fromString('1');
                $attr->store();
            }
            eZContentOperationCollection::updateObjectState(
                $node->attribute('contentobject_id'),
                [$states[$toState]->attribute('id')]
            );
            eZContentOperationCollection::registerSearchObject($node->attribute('contentobject_id'));
        }
    }

    /**
     * steps:
     *     ...
     *     -   type: php_callable
     *         identifier: 'BootstrapItaliaInstallerUtils::throwException'
     *         message: 'Debug!'
     *     ...
     * @param AbstractStepInstaller $step
     * @return mixed
     * @throws Exception
     */
    public static function throwException(AbstractStepInstaller $step)
    {
        $message = $step->getStep()['message'] ?? '';
        throw new Exception($message);
    }

    /**
     * ClassRepository::clearCache() svuota solo la cache su disco/DFS, non
     * l'array statico self::$classes popolato in memoria durante lo stesso
     * processo: se una classe viene modificata e poi usata per creare
     * contenuti nello stesso run dell'installer, ClassRepository puo'
     * restituire ancora la versione stale della classe, causando un fatal
     * error nella pipeline di pubblicazione.
     *
     * steps:
     *     ...
     *     -   type: php_callable
     *         identifier: 'BootstrapItaliaInstallerUtils::resetOpendataClassCache'
     *     ...
     */
    public static function resetOpendataClassCache()
    {
        $repository = new \Opencontent\Opendata\Api\ClassRepository();
        foreach (eZContentClass::fetchList(eZContentClass::VERSION_STATUS_DEFINED, true) as $class) {
            $repository->clearCache($class->attribute('identifier'));
        }

        $reflection = new ReflectionClass(\Opencontent\Opendata\Api\ClassRepository::class);
        foreach (['classes', 'identifierHash'] as $propertyName) {
            if ($reflection->hasProperty($propertyName)) {
                $property = $reflection->getProperty($propertyName);
                $property->setAccessible(true);
                $property->setValue(null, $propertyName === 'classes' ? [] : null);
            }
        }

        eZContentClass::expireCache();
    }

    /**
     * `patch_content` (Opencontent\Installer\PatchContent) scrive sempre
     * sulla lingua primaria dell'oggetto: il parametro `language` che
     * `updateAndPublishObject()` accetterebbe non viene mai passato da quello
     * step, quindi non c'e' modo di patchare una traduzione diversa
     * dall'italiano con `patch_content`. Qui si reimplementa lo stesso
     * meccanismo (nuova versione, conversione attributo, publish) ma
     * passando davvero la lingua a `createNewVersion()` - le altre lingue
     * gia' presenti sull'oggetto restano intatte nella nuova versione, solo
     * quella indicata viene aggiornata.
     *
     * steps:
     *     ...
     *     -   type: php_callable
     *         identifier: 'BootstrapItaliaInstallerUtils::patchContentAttributeForLanguage'
     *         remote_id: 'ae441f5d2f78bf88f0b3e39a36743bdd'
     *         language: 'ger-DE'
     *         attributes:
     *             guida_alla_compilazione: '<p>...</p>'
     *     ...
     * @param AbstractStepInstaller $step
     * @throws Exception
     */
    public static function patchContentAttributeForLanguage(AbstractStepInstaller $step)
    {
        $stepData = $step->getStep();
        $remoteId = $stepData['remote_id'];
        $languageCode = $stepData['language'];
        $attributes = $stepData['attributes'];

        $object = eZContentObject::fetchByRemoteID($remoteId);
        if (!$object instanceof eZContentObject) {
            $step->getLogger()->error("Object $remoteId not found");

            return;
        }

        $newVersion = $object->createNewVersion(false, true, $languageCode);
        if (!$newVersion instanceof eZContentObjectVersion) {
            throw new Exception("Unable to create a new version for object {$object->attribute('id')}");
        }
        $newVersion->setAttribute('modified', time());
        $newVersion->store();

        $fakePublicationProcess = new \Opencontent\Opendata\Api\PublicationProcess(null);
        foreach ($newVersion->contentObjectAttributes($languageCode) as $attribute) {
            $identifier = $attribute->attribute('contentclass_attribute_identifier');
            if (!array_key_exists($identifier, $attributes)) {
                continue;
            }
            $converter = \Opencontent\Opendata\Api\AttributeConverterLoader::load(
                $object->attribute('class_identifier'),
                $identifier,
                $attribute->attribute('data_type_string')
            );
            $dataString = $converter->set($attributes[$identifier], $fakePublicationProcess);
            $attribute->fromString($dataString);
            $attribute->store();
        }

        $result = eZOperationHandler::execute('content', 'publish', [
            'object_id' => $newVersion->attribute('contentobject_id'),
            'version' => $newVersion->attribute('version'),
        ]);

        if ($result['status'] != eZModuleOperationInfo::STATUS_CONTINUE) {
            throw new Exception('Publish failed with status ' . var_export($result['status'], true));
        }
    }

    /**
     * Risolve il nome del comune da usare nel campo `spatial` (datatype
     * `openpacomuniitaliani`) al posto del valore fisso 'Roma' (vedi
     * backlog_anac_dataset_spatial_roma). Parte da `SiteSettings.SiteName`
     * - lo stesso valore gia' usato da `IntestazioneProvider::getAmministrazione()`
     * per il campo ANAC `denominazione`, affidabile su ogni tenant reale (a
     * differenza di `Homepage::spatial`, non sempre compilato sui siti live).
     *
     * Prova prima il nome intero cosi' com'e' contro la tabella comuni
     * (`OpenPAComuniItaliani::getCodesFromNames()`, la stessa risoluzione
     * usata da `OpenPAComuniItalianiAttributeConverter::set()` in fase di
     * publish) - necessario perche' alcuni comuni si chiamano davvero
     * "Citta' di X" (es. Citta' di Castello), quindi non si puo' stripare
     * alla cieca un prefisso "Citta' di ". Solo se il nome intero non
     * matcha un comune, prova a togliere i prefissi di tipo ente ("Comune
     * di ", "Citta' Metropolitana di ", "Provincia di ") e riprova.
     *
     * Se nessun tentativo trova un comune valido, fallback a 'Roma' (stesso
     * valore gia' usato dagli altri moduli ANAC) invece di bloccare
     * l'installazione.
     *
     * steps:
     *     variables:
     *         -   name: comune_nome
     *             value: 'BootstrapItaliaInstallerUtils::resolveComuneSpatialName'
     *
     * @return string
     */
    public static function resolveComuneSpatialName()
    {
        $siteaccess = eZSiteAccess::current();
        $siteaccessName = str_replace('_backend', '_frontend', $siteaccess['name']);
        $siteName = trim((string)eZSiteAccess::getIni($siteaccessName)->variable('SiteSettings', 'SiteName'));

        if ($siteName !== '' && OpenPAComuniItaliani::getCodesFromNames([$siteName])) {
            return $siteName;
        }

        $stripped = trim((string)preg_replace(
            '/^(Comune|Citt[aà]\s+Metropolitana|Provincia)\s+di\s+/iu',
            '',
            $siteName
        ));

        if ($stripped !== '' && OpenPAComuniItaliani::getCodesFromNames([$stripped])) {
            return $stripped;
        }

        eZDebug::writeWarning(
            "Impossibile risolvere un comune da SiteSettings.SiteName ('$siteName'), uso 'Roma' come fallback per il campo spatial",
            __METHOD__
        );

        return 'Roma';
    }

    /**
     * Ripubblica i dataset ANAC ad adesione volontaria il cui campo
     * `spatial` e' ancora il valore di default 'Roma', sostituendolo con
     * quello risolto da `resolveComuneSpatialName()`. Serve a correggere i
     * dataset gia' creati su ambienti dove il modulo e' stato installato
     * prima di questo fix - un fresh install ottiene gia' il valore giusto
     * dal content step (`spatial: $comune_nome`), quindi qui si fa
     * esplicitamente no-op se `spatial` e' gia' diverso da 'Roma' (un
     * redattore potrebbe averlo gia' cambiato a mano).
     *
     * Il datatype `openpacomuniitaliani` salva in `data_text` dei CODICI
     * ISTAT (non il nome), quindi il confronto/scrittura qui va fatto a
     * livello di codice - non si puo' usare `toString()`/`fromString()`
     * del datatype (lavorano solo su codici, nessun fallback per nome:
     * vedi `OpenPAComuniItalianiType::fromString()`), bisogna risolvere i
     * nomi a mano con `OpenPAComuniItaliani::getCodesFromNames()`, stessa
     * logica di `OpenPAComuniItalianiAttributeConverter::set()`.
     *
     * steps:
     *     ...
     *     -   type: php_callable
     *         identifier: 'BootstrapItaliaInstallerUtils::fixAnacDatasetSpatialDefault'
     *         remote_ids:
     *             - iban_pagamenti_informatici_c1
     *             - iban_pagamenti_informatici_c2
     *             - scadenzario_obblighi_amministrativi
     *     ...
     * @param AbstractStepInstaller $step
     */
    public static function fixAnacDatasetSpatialDefault(AbstractStepInstaller $step)
    {
        $remoteIds = $step->getStep()['remote_ids'] ?? [];

        $romaValue = implode('#', OpenPAComuniItaliani::getCodesFromNames(['Roma']));
        if ($romaValue === '') {
            $step->getLogger()->error("Impossibile risolvere il codice comune di 'Roma', skip");

            return;
        }

        $comuneNome = null;
        $comuneValue = null;

        foreach ($remoteIds as $remoteId) {
            $object = eZContentObject::fetchByRemoteID($remoteId);
            if (!$object instanceof eZContentObject) {
                continue;
            }

            $dataMap = $object->dataMap();
            $attribute = $dataMap['spatial'] ?? null;
            if (!$attribute || trim($attribute->attribute('data_text')) !== $romaValue) {
                continue;
            }

            if ($comuneNome === null) {
                $comuneNome = self::resolveComuneSpatialName();
                $comuneValue = implode('#', OpenPAComuniItaliani::getCodesFromNames([$comuneNome]));
            }
            if ($comuneValue === '' || $comuneValue === $romaValue) {
                continue;
            }

            $step->getLogger()->info(" - Patch spatial su $remoteId -> $comuneNome");

            $newVersion = $object->createNewVersion(false, true);
            if (!$newVersion instanceof eZContentObjectVersion) {
                throw new Exception("Unable to create a new version for object {$object->attribute('id')}");
            }
            $newVersion->setAttribute('modified', time());
            $newVersion->store();

            foreach ($newVersion->contentObjectAttributes() as $newAttribute) {
                if ($newAttribute->attribute('contentclass_attribute_identifier') === 'spatial') {
                    $newAttribute->setAttribute('data_text', $comuneValue);
                    $newAttribute->store();
                }
            }

            $result = eZOperationHandler::execute('content', 'publish', [
                'object_id' => $newVersion->attribute('contentobject_id'),
                'version' => $newVersion->attribute('version'),
            ]);

            if ($result['status'] != eZModuleOperationInfo::STATUS_CONTINUE) {
                throw new Exception('Publish failed with status ' . var_export($result['status'], true));
            }
        }
    }

    /**
     * Risolve il codice ISTAT del comune trentino da usare nel campo `spatial`
     * (datatype `openpacomuniitaliani`) a partire da `SiteSettings.SiteName`.
     *
     * Restituisce il CODICE ISTAT (non il nome): il converter del datatype
     * prova prima i codici e solo dopo i nomi, quindi con il codice non c'e'
     * ambiguita' sugli omonimi di comuni di altre province (nella tabella ce
     * ne sono alcuni). La ricerca per nome e' ristretta alla provincia di Trento.
     *
     * Gestisce il prefisso ente ("Comune di ...") e i nomi bilingui nel
     * formato "Nome italiano - Nome ladino".
     *
     * Se nessun candidato produce un comune univoco in provincia di Trento,
     * ripiega sul comune di Trento: il fallback viene scritto nel log
     * `cct_opendata_spatial_fallback.log` (e su STDERR da CLI) per poter
     * individuare i tenant da correggere.
     *
     * Non sostituisce `resolveComuneSpatialName()`, usata dai moduli ANAC su
     * tenant di tutta Italia con fallback diverso.
     *
     * steps:
     *     variables:
     *         -   name: comune_codice
     *             value: 'BootstrapItaliaInstallerUtils::resolveTrentinoComuneCode'
     *
     * @return string
     * @throws Exception se non e' possibile risolvere nemmeno il fallback
     */
    public static function resolveTrentinoComuneCode()
    {
        $province = 'TN';
        $siteaccess = eZSiteAccess::current();
        $siteaccessName = str_replace('_backend', '_frontend', $siteaccess['name']);
        $siteName = trim((string)eZSiteAccess::getIni($siteaccessName)->variable('SiteSettings', 'SiteName'));

        foreach (self::getComuneNameCandidates($siteName) as $candidate) {
            $codes = self::filterComuneCodesByProvince(
                OpenPAComuniItaliani::getCodesFromNames([$candidate]),
                $province
            );
            if (count($codes) === 1) {
                return $codes[0];
            }
        }

        $fallbackName = 'Trento';
        $fallbackCodes = self::filterComuneCodesByProvince(
            OpenPAComuniItaliani::getCodesFromNames([$fallbackName]),
            $province
        );
        if (count($fallbackCodes) !== 1) {
            throw new Exception(
                "Impossibile risolvere un comune trentino da SiteName '$siteName' e nemmeno il fallback '$fallbackName'"
            );
        }

        $message = "Comune non risolto da SiteSettings.SiteName ('$siteName'), uso '$fallbackName' come fallback per il campo spatial";
        eZDebug::writeWarning($message, __METHOD__);
        eZLog::write($message, 'cct_opendata_spatial_fallback.log');
        if (PHP_SAPI === 'cli') {
            fwrite(STDERR, "[cct-opendata] $message\n");
        }

        return $fallbackCodes[0];
    }

    /**
     * Varianti del nome da provare, dalla piu' completa alla piu' ridotta:
     * nome intero, senza prefisso ente, e per entrambi la sola parte prima
     * di un separatore " - " o " / " (nomi bilingui).
     *
     * @param string $siteName
     * @return string[]
     */
    private static function getComuneNameCandidates($siteName)
    {
        $stripped = trim((string)preg_replace(
            '/^(Comune|Citt[aà]\s+Metropolitana|Provincia)\s+di\s+/iu',
            '',
            $siteName
        ));

        $names = [];
        foreach ([$siteName, $stripped] as $name) {
            $names[] = $name;
            $parts = preg_split('/\s+[-–\/]\s+/u', $name);
            $names[] = trim((string)$parts[0]);
        }

        return array_values(array_filter(array_unique($names), 'strlen'));
    }

    /**
     * Tiene solo i codici ISTAT dei comuni della provincia indicata (sigla).
     *
     * @param string[] $codes
     * @param string $province sigla, es. 'TN'
     * @return string[]
     */
    private static function filterComuneCodesByProvince(array $codes, $province)
    {
        if (empty($codes)) {
            return [];
        }

        $filtered = [];
        foreach (OpenPAComuniItaliani::fetchByCodes($codes) as $comune) {
            if (strtoupper((string)$comune->attribute('sigla')) === $province) {
                $filtered[] = (string)$comune->attribute('pro_com_t');
            }
        }

        return array_values(array_unique($filtered));
    }

    /**
     * Cerca tra i contenuti di classe `organization` quello il cui nome
     * coincide (senza distinzione tra maiuscole e minuscole) con
     * `SiteSettings.SiteName` e ne restituisce il remote_id, da usare come
     * titolare (`rights_holder`) dei dataset.
     *
     * Se esiste esattamente un'organization con quel nome restituisce il suo
     * remote_id. Se non ne esiste nessuna, o ce n'e' piu' di una (ambiguo),
     * restituisce `$fallbackRemoteId` ('site-link'): il contenuto di classe
     * `link` creato dal modulo con il nome e l'URL del sito, gia' usato come
     * titolare dai dataset ANAC. Il ripiego viene scritto nel log
     * `cct_opendata_rights_holder_fallback.log` (e su STDERR da CLI).
     *
     * Per i nomi bilingui "Nome italiano - Nome ladino" prova anche la sola
     * parte prima del separatore.
     *
     * steps:
     *     variables:
     *         -   name: titolare_remote_id
     *             value: 'BootstrapItaliaInstallerUtils::resolveSiteOrganizationRemoteId'
     *
     * @return string
     */
    public static function resolveSiteOrganizationRemoteId()
    {
        $fallbackRemoteId = 'site-link';
        $siteaccess = eZSiteAccess::current();
        $siteaccessName = str_replace('_backend', '_frontend', $siteaccess['name']);
        $siteName = trim((string)eZSiteAccess::getIni($siteaccessName)->variable('SiteSettings', 'SiteName'));

        $names = [$siteName];
        $parts = preg_split('/\s+[-–\/]\s+/u', $siteName);
        $names[] = trim((string)$parts[0]);
        $names = array_values(array_filter(array_unique($names), 'strlen'));

        $reason = "nessuna organization con nome '$siteName'";
        $classId = eZContentClass::classIDByIdentifier('organization');
        if (empty($names)) {
            $reason = 'SiteName vuoto';
        } elseif (!$classId) {
            $reason = 'classe organization non trovata';
        } else {
            $db = eZDB::instance();
            foreach ($names as $name) {
                $rows = $db->arrayQuery(
                    'SELECT remote_id FROM ezcontentobject'
                    . ' WHERE contentclass_id = ' . (int)$classId
                    . ' AND status = ' . eZContentObject::STATUS_PUBLISHED
                    . " AND LOWER(TRIM(name)) = LOWER('" . $db->escapeString($name) . "')"
                );
                if (count($rows) === 1) {
                    return (string)$rows[0]['remote_id'];
                }
                if (count($rows) > 1) {
                    $reason = "piu' organization con lo stesso nome ('$name')";
                    break;
                }
            }
        }

        $message = "Titolare non risolto da SiteSettings.SiteName ('$siteName'): $reason, uso '$fallbackRemoteId'";
        eZDebug::writeNotice($message, __METHOD__);
        eZLog::write($message, 'cct_opendata_rights_holder_fallback.log');
        if (PHP_SAPI === 'cli') {
            fwrite(STDERR, "[cct-opendata] $message\n");
        }

        return $fallbackRemoteId;
    }
}
