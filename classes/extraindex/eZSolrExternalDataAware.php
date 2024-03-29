<?php

class eZSolrExternalDataAware extends eZSolr
{
    /*
     * <doc boost="1.000000">
     * <field name="meta_guid_ms">__642d2aba45d47d1e6c7ed5248612bc</field>
     * <field name="meta_installation_id_ms">419b36dea0c4931b959de53aab697c08</field>
     * <field name="meta_installation_url_ms">http://opencity.localtest.me/</field>
     * <field name="meta_path_string_ms">/0</field>
     * <field name="meta_is_invisible_b">false</field>
     * <field name="meta_contentclass_id_si">36</field>
     * <field name="meta_class_name_ms">Evento...</field>
     * <field name="meta_main_url_alias_ms">external</field>
     * <field name="meta_name_t">Nome sintetico del link </field>
     * <field name="meta_sort_name_ms">Nome sintetico del link </field>
     * <field name="meta_language_code_ms">ita-IT</field>
     * <field name="meta_available_language_codes_ms">ita-IT</field>
     * <field name="meta_modified_dt">2021-08-25T15:30:17Z</field>
     * <field name="meta_published_dt">2021-08-25T15:30:17Z</field>
     *
     * <field name="attr_name_t" boost="2.0">Nome del link</field>
     * <field name="attr_name_s" boost="2.0">Nome del link</field>
     *
     * <field name="attr_abstract_t" boost="1.5">Breve descrizione del link</field>
     *
     * <field name="attr_source_name_s">Google.it</field>
     * <field name="attr_source_uri_s">https://www.google.it</field>
     *
     * <field name="attr_uri_s">https://www.google.it</field>
     *
     * <field name="attr_expire_dt">2021-08-07T02:00:00Z</field>
     * </doc>
     */
    public function addExternalDataDocument(ExternalDataDocument $document)
    {
        $docList = array();
        $docBoost = 1.0;

        $doc = new eZSolrDoc($docBoost);

        if (is_numeric($document->getGuid())) {
            throw new Exception("OCCustomSearchableObjectInterface ID can must be an alphanumeric string");
        }

        $contentClassId = $contentClassName = false;
        if ($document->hasClassIdentifier()) {
            $class = eZContentClass::fetchByIdentifier($document->getClassIdentifier());
            if ($class instanceof eZContentClass) {
                $contentClassId = $class->attribute('id');
                $contentClassName = $class->attribute('name');
            }
        }
        if (!$contentClassId || !$contentClassName) {
            $link = eZContentClass::fetchByIdentifier('link');
            if ($link instanceof eZContentClass) {
                $contentClassId = $link->attribute('id');
                $contentClassName = $link->attribute('name');
            }
        }

        $publishDate = ezfSolrDocumentFieldBase::convertTimestampToDate($document->getPublished());
        $modifiedDate = ezfSolrDocumentFieldBase::convertTimestampToDate($document->getModified());

        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('guid'), 'ext_' . $document->getGuid());
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('installation_id'), eZSolr::installationID());
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('installation_url'),
            $this->FindINI->variable('SiteSettings', 'URLProtocol') . $this->SiteINI->variable('SiteSettings', 'SiteURL') . '/');
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('path_string'), '/0');
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('is_invisible'), false);
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('anon_access'), true);
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('contentclass_id'), $contentClassId);
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('class_name'), $contentClassName);
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('name'), $document->getName());
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('sort_name'), $document->getName());
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('language_code'), $document->getLanguage());
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('available_language_codes'), $document->getLanguage());
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('published'), $publishDate);
        $doc->addField(ezfSolrDocumentFieldBase::generateMetaFieldName('modified'), $modifiedDate);

        $doc->addField('meta_is_external_data_b', true);
        $doc->addField(ezfSolrDocumentFieldBase::ATTR_FIELD_PREFIX . 'name_t', $document->getName());
        $doc->addField(ezfSolrDocumentFieldBase::ATTR_FIELD_PREFIX . 'name_s', $document->getName());
        if ($document->getImage()) {
            $doc->addField(ezfSolrDocumentFieldBase::ATTR_FIELD_PREFIX . 'image_s', $document->getImage());
        }
        $doc->addField(ezfSolrDocumentFieldBase::ATTR_FIELD_PREFIX . 'abstract_t', $document->getAbstract());
        $doc->addField(ezfSolrDocumentFieldBase::ATTR_FIELD_PREFIX . 'description_t', $document->getAbstract());
        $doc->addField(ezfSolrDocumentFieldBase::ATTR_FIELD_PREFIX . 'source_name_s', $document->getSourceName());
        $doc->addField(ezfSolrDocumentFieldBase::ATTR_FIELD_PREFIX . 'source_uri_s', $document->getSourceUri());
        $doc->addField(ezfSolrDocumentFieldBase::ATTR_FIELD_PREFIX . 'uri_s', $document->getUri());
        foreach ($document->getAttachments() as $attachment) {
            $doc->addField(ezfSolrDocumentFieldBase::SUBATTR_FIELD_PREFIX . 'extradata__attachment_name____s', $attachment['name']);
            $doc->addField(ezfSolrDocumentFieldBase::SUBATTR_FIELD_PREFIX . 'extradata__attachment_uri____s', $attachment['uri']);
        }
        $docList[$document->getLanguage()] = $doc;

        $solr = new eZSolrBase();
        $result = $solr->addDocs($docList, true, $this->needOptimize(), $this->commitWithin(), false);
        if ($result){
            $this->storeInFileSystem($document);
        }
        return $result;
    }

    private function needOptimize()
    {
        $optimize = false;
        if (eZINI::instance('ezfind.ini')->hasVariable('IndexOptions', 'OptimizeOnCommit')
            && eZINI::instance('ezfind.ini')->variable('IndexOptions', 'OptimizeOnCommit') === 'enabled') {
            $optimize = true;
        }

        return $optimize;
    }

    private function commitWithin()
    {
        $commitWithin = 0;
        if (eZINI::instance('ezfind.ini')->hasVariable('IndexOptions', 'CommitWithin')
            && eZINI::instance('ezfind.ini')->variable('IndexOptions', 'CommitWithin') > 0) {
            $commitWithin = eZINI::instance('ezfind.ini')->variable('IndexOptions', 'CommitWithin');
        }

        return $commitWithin;
    }

    public function removeExternalDataDocument($guid)
    {
        $docList = array();
        $languageCode = eZLocale::currentLocaleCode();
        $originalGuid = $guid;
        if (strpos($guid, 'ext_') === false) {
            $guid = 'ext_' . $guid;
        }
        $docList[$languageCode] = $guid;

        $solr = new eZSolrBase();
        $result = $solr->deleteDocs($docList, false, true, $this->needOptimize(), $this->commitWithin());
        if ($result){
            $this->removeFromFileSystem($originalGuid);
        }
        return $result;
    }

    private function storeInFileSystem(ExternalDataDocument $document)
    {
        $filepath = $this->getFilepath($document->getGuid());
        eZClusterFileHandler::instance($filepath)
            ->storeContents(json_encode($document), 'extraindex', 'json');
    }

    private function removeFromFileSystem($guid)
    {
        $filepath = $this->getFilepath($guid);
        eZClusterFileHandler::instance($filepath)->delete();
        eZClusterFileHandler::instance($filepath)->purge();
    }

    private function getFilepath($guid)
    {
        $guid = eZCharTransform::instance()->transformByGroup($guid, 'identifier');
        $extraPath = eZDir::filenamePath($guid);
        $cacheDir = eZDir::path(array(eZSys::storageDirectory(), 'extraindex', $extraPath));
        return eZDir::path(array($cacheDir, $guid . '.json'));
    }

    public function findExternalDocumentByGuid($guid)
    {
        $filterQuery = array();
        $filterQuery[] = ezfSolrDocumentFieldBase::generateMetaFieldName('installation_id') . ':' . eZSolr::installationID();
        $originalGuid = $guid;
        if (strpos($guid, 'ext_') === false) {
            $guid = 'ext_' . $guid;
        }
        $filterQuery[] = ezfSolrDocumentFieldBase::generateMetaFieldName('guid') . ':' . $guid;
        $fieldsToReturnString = 'score, *';

        $queryParams = array(
            'q' => false,
            'qf' => ezfSolrDocumentFieldBase::generateMetaFieldName('guid'),
            'qt' => 'ezpublish',
            'start' => 0,
            'rows' => 1,
            'sort' => 'score desc',
            'indent' => 'on',
            'version' => '2.2',
            'fl' => 'score, *',
            'fq' => $filterQuery,
            'wt' => 'php'
        );

        $solr = new eZSolrBase();
        $resultArray = $solr->rawSearch($queryParams);

        if (!isset($resultArray['response']['docs'][0])){
            throw new \Opencontent\OpenApi\Exceptions\NotFoundException($originalGuid);
        }

        return $resultArray['response']['docs'][0];
    }

    protected function buildResultObjects($resultArray, &$searchCount, $asObjects = true, $params = array())
    {
        $objectRes = array();
        $highLights = array();
        if (!empty($resultArray['highlighting'])) {
            foreach ($resultArray['highlighting'] as $id => $highlight) {
                $highLightStrings = array();
                //implode apparently does not work on associative arrays that contain arrays
                //$element being an array as well
                foreach ($highlight as $key => $element) {
                    $highLightStrings[] = implode(' ', $element);
                }
                $highLights[$id] = implode(' ...  ', $highLightStrings);
            }
        }

        if (!empty($resultArray)) {
            $result = $resultArray['response'];
            if (!is_array($result) ||
                !isset($result['maxScore']) ||
                !isset($result['docs']) ||
                !is_array($result['docs'])) {
                eZDebug::writeError('Unexpected response from Solr: ' . var_export($result, true), __METHOD__);
                return $objectRes;
            }

            $maxScore = $result['maxScore'];
            $docs = $result['docs'];
            $localNodeIDList = array();
            $nodeRowList = array();

            // Loop through result, and get eZContentObjectTreeNode ID
            foreach ($docs as $idx => $doc) {
                if ($doc[ezfSolrDocumentFieldBase::generateMetaFieldName('installation_id')] == self::installationID()) {
                    $localNodeIDList[] = $this->getNodeID($doc);
                }
            }

            $localNodeIDList = array_unique($localNodeIDList);

            if (!empty($localNodeIDList)) {
                $tmpNodeRowList = eZContentObjectTreeNode::fetch($localNodeIDList, false, false);
                // Workaround for eZContentObjectTreeNode::fetch behaviour
                if (count($localNodeIDList) === 1) {
                    $tmpNodeRowList = array($tmpNodeRowList);
                }
                if (count($tmpNodeRowList) > 0 && isset($tmpNodeRowList['node_id'])){
                    $tmpNodeRowList = [$tmpNodeRowList];
                }
                if ($tmpNodeRowList) {
                    foreach ($tmpNodeRowList as $nodeRow) {
                        $nodeRowList[$nodeRow['node_id']] = $nodeRow;
                    }
                }
                unset($tmpNodeRowList);
            }
            //need refactoring from the moment Solr has globbing in fl parameter
            foreach ($docs as $idx => $doc) {
                /* override start */
                if (strpos($doc['meta_guid_ms'], 'ext_') !== false) {
                    $objectRes[] = ExternalDataDocument::fromSolrResult($doc);
                    continue;
                    /* override end */
                } elseif (!$asObjects) {
                    $emit = array();
                    foreach ($doc as $fieldName => $fieldValue) {
                        // check if fieldName contains an _, to keep list() from generating notices.
                        if (strpos($fieldName, '_') !== false) {
                            list($prefix, $rest) = explode('_', $fieldName, 2);
                            // get the identifier for meta, binary fields
                            $inner = implode('_', explode('_', $rest, -1));
                            if ($prefix === 'meta') {
                                $emit[$inner] = $fieldValue;
                            } elseif ($prefix === 'as') {
                                $emit['data_map'][$inner] = ezfSolrStorage::unserializeData($fieldValue);
                            }

                            // it may be a field originating from the explicit fieldlist to return, so it should be added for template consumption
                            // note that the fieldname will be kept verbatim in a substructure 'fields'
                            elseif (in_array($fieldName, $params['FieldsToReturn'])) {
                                $emit['fields'][$fieldName] = $fieldValue;
                            }
                        }
                    }
                    $emit['highlight'] = isset($highLights[$doc[ezfSolrDocumentFieldBase::generateMetaFieldName('guid')]]) ?
                        $highLights[$doc[ezfSolrDocumentFieldBase::generateMetaFieldName('guid')]] : null;
                    $emit['elevated'] = (isset($doc['[elevated]']) ? $doc['[elevated]'] === true : false);
                    $objectRes[] = $emit;
                    unset($emit);
                    continue;
                } elseif ($doc[ezfSolrDocumentFieldBase::generateMetaFieldName('installation_id')] == self::installationID()) {
                    // Search result document is from current installation
                    $nodeID = $this->getNodeID($doc);

                    // no actual $nodeID, may ocurr due to subtree/visibility limitations.
                    if ($nodeID === null)
                        continue;

                    // Invalid $nodeID
                    // This can happen if a content has been deleted while Solr was not running, provoking desynchronization
                    if (!isset($nodeRowList[$nodeID])) {
                        $searchCount--;
                        eZDebug::writeError("Node #{$nodeID} (/{$doc[ezfSolrDocumentFieldBase::generateMetaFieldName( 'main_url_alias' )]}) returned by Solr cannot be found in the database. Please consider reindexing your content", __METHOD__);
                        continue;
                    }

                    $resultTree = new eZFindResultNode($nodeRowList[$nodeID]);
                    $node = $nodeRowList[$nodeID];
                    $resultTree->setContentObject(
                        new eZContentObject(
                            array(
                                "id" => $node["id"],
                                "section_id" => $node["section_id"],
                                "owner_id" => $node["owner_id"],
                                "contentclass_id" => $node["contentclass_id"],
                                "name" => $node["name"],
                                "published" => $node["published"],
                                "modified" => $node["modified"],
                                "current_version" => $node["current_version"],
                                "status" => $node["status"],
                                "remote_id" => $node["object_remote_id"],
                                "language_mask" => $node["language_mask"],
                                "initial_language_id" => $node["initial_language_id"],
                                "class_identifier" => $node["class_identifier"],
                                "serialized_name_list" => $node["class_serialized_name_list"],
                            )
                        )
                    );
                    $resultTree->setAttribute('is_local_installation', true);
                    // can_read permission must be checked as they could be out of sync in Solr, however, when called from template with:
                    // limitation, hash( 'accessWord', ... ) this check should not be performed as it has precedence.
                    // See: http://issues.ez.no/15978
                    if (!isset($params['Limitation'], $params['Limitation']['accessWord']) && !$resultTree->attribute('object')->attribute('can_read')) {
                        $searchCount--;
                        eZDebug::writeNotice('Access denied for eZ Find result, node_id: ' . $nodeID, __METHOD__);
                        continue;
                    }

                    $urlAlias = $this->getUrlAlias($doc);
                    $globalURL = $urlAlias . '/(language)/' . $doc[ezfSolrDocumentFieldBase::generateMetaFieldName('language_code')];
                    eZURI::transformURI($globalURL);
                } else {
                    $resultTree = new eZFindResultNode();
                    $resultTree->setAttribute('is_local_installation', false);
                    $globalURL = $doc[ezfSolrDocumentFieldBase::generateMetaFieldName('installation_url')] .
                        $doc[ezfSolrDocumentFieldBase::generateMetaFieldName('main_url_alias')] .
                        '/(language)/' . $doc[ezfSolrDocumentFieldBase::generateMetaFieldName('language_code')];
                }

                $resultTree->setAttribute('name', $doc[ezfSolrDocumentFieldBase::generateMetaFieldName('name')]);
                $resultTree->setAttribute('published', $doc[ezfSolrDocumentFieldBase::generateMetaFieldName('published')]);
                $resultTree->setAttribute('global_url_alias', $globalURL);
                $resultTree->setAttribute('highlight', isset($highLights[$doc[ezfSolrDocumentFieldBase::generateMetaFieldName('guid')]]) ?
                    $highLights[$doc[ezfSolrDocumentFieldBase::generateMetaFieldName('guid')]] : null);
                /**
                 * $maxScore may be equal to 0 when the QueryElevationComponent is used.
                 * It returns as first results the elevated documents, with a score equal to 0. In case no
                 * other document than the elevated ones are returned, maxScore is then 0 and the
                 * division below raises a warning. If maxScore is equal to zero, we can safely assume
                 * that only elevated documents were returned. The latter have an articifial relevancy of 100%,
                 * which must be reflected in the 'score_percent' attribute of the result node.
                 */
                $maxScore != 0 ? $resultTree->setAttribute('score_percent', (int)(($doc['score'] / $maxScore) * 100)) : $resultTree->setAttribute('score_percent', 100);
                $resultTree->setAttribute('language_code', $doc[ezfSolrDocumentFieldBase::generateMetaFieldName('language_code')]);
                $resultTree->setAttribute('elevated', (isset($doc['[elevated]']) ? $doc['[elevated]'] === true : false));
                $objectRes[] = $resultTree;
            }
        }
        return $objectRes;
    }
}