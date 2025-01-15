<?php

class BootstrapItaliaSolrTools
{
    public static function sendPatch(int $objectId, array $languages, array $data): void
    {
        $solr = new eZSolr();
        $collectedData = [];
        foreach ($languages as $languageCode) {
            $collectedData[$languageCode] = [
                'meta_guid_ms' => $solr->guid($objectId, $languageCode),
            ];
            foreach ($data as $key => $value) {
                $collectedData[$languageCode][$key] = [
                    'set' => $value,
                ];
            }
        }
        $postData = json_encode(array_values($collectedData));

        $solrBase = new eZSolrBase();
        $maxRetries = (int)eZINI::instance('solr.ini')->variable('SolrBase', 'ProcessMaxRetries');
        eZINI::instance('solr.ini')->setVariable('SolrBase', 'ProcessTimeout', 60);
        if ($maxRetries < 1) {
            $maxRetries = 1;
        }
        $commitParam = 'true';
        $tries = 0;
        while ($tries < $maxRetries) {
            try {
                $tries++;
                $solrBase->sendHTTPRequest(
                    $solrBase->SearchServerURI . '/update?commit=' . $commitParam,
                    $postData,
                    'application/json',
                    'OpenAgenda'
                );
                eZDebug::writeDebug('Patch object ' . $objectId, __METHOD__ . ' at retry ' . $tries);
                break;
            } catch (ezfSolrException $e) {
                $doRetry = false;
                $errorMessage = $e->getMessage();
                switch ($e->getCode()) {
                    case ezfSolrException::REQUEST_TIMEDOUT : // Code error 28. Server is most likely overloaded
                    case ezfSolrException::CONNECTION_TIMEDOUT : // Code error 7, same thing
                        $errorMessage .= ' // Retry #' . $tries;
                        $doRetry = true;
                        break;
                }

                if (!$doRetry) {
                    break;
                }
                eZDebug::writeError($errorMessage, __METHOD__ . ' at retry ' . $tries);
            }
        }
    }

    public static function getObjectIndexDataAsSubAttribute(
        eZContentObject $contentObject,
        eZContentObjectVersion $version,
        array $availableLanguages,
        string $contentClassAttributeIdentifier
    ): array {
        $metaData = [];
        $metaAttributeValues = eZSolr::getMetaAttributesForObject($contentObject);
        foreach ($metaAttributeValues as $metaInfo) {
            $subMetaFieldName = self::generateSubMetaFieldName(
                $contentClassAttributeIdentifier,
                $metaInfo['name']
            );
            $value = ezfSolrDocumentFieldBase::preProcessValue(
                $metaInfo['value'],
                $metaInfo['fieldType']
            );
            if (!is_array($value)) {
                $value = [$value];
            }
            $metaData[$subMetaFieldName] = $value;
        }

        /** @var eZContentObjectTreeNode $contentNode */
        foreach ($contentObject->attribute('assigned_nodes') as $contentNode) {
            $subMetaFieldName = self::generateSubMetaFieldName(
                $contentClassAttributeIdentifier,
                'path'
            );
            $metaData[$subMetaFieldName] = $contentNode->attribute('path_array');
        }

        $data = [];
        foreach ($availableLanguages as $language) {
            $data[$language] = $metaData;
            $contentObjectName = $contentObject->name(false, $language);
            foreach (
                [
                    self::generateSubMetaFieldName($contentClassAttributeIdentifier, 'name'),
                    self::generateSubattributeFieldName($contentClassAttributeIdentifier, 'name', 'string'),
                    self::generateAttributeFieldName($contentClassAttributeIdentifier, 'text'),
                    self::generateAttributeFieldName($contentClassAttributeIdentifier, 'string'),
                ] as $subFieldName
            ) {
                $data[$language][$subFieldName] = $contentObjectName;
            }
            /** @var eZContentObjectAttribute $attribute */
            foreach ($version->contentObjectAttributes($language) as $attribute) {
                $classAttribute = $attribute->attribute('contentclass_attribute');
                if ($classAttribute->attribute('is_searchable') && $attribute->hasContent()) {
                    $fieldNameArray = [];
                    foreach (array_keys(eZSolr::$fieldTypeContexts) as $context) {
                        $fieldNameArray[] = self::generateSubattributeFieldName(
                            $contentClassAttributeIdentifier,
                            $classAttribute->attribute('identifier'),
                            ezfSolrDocumentFieldBase::getClassAttributeType($classAttribute, null, $context)
                        );
                    }
                    switch ($attribute->attribute('data_type_string')) {
                        case eZObjectRelationListType::DATA_TYPE_STRING:
                        case eZObjectRelationType::DATA_TYPE_STRING:
                            $relationIdList = explode(',', $attribute->toString());
                            $relationIdList = implode(',', array_map('intval', $relationIdList));
                            $names = [];
                            if (!empty($relationIdList)) {
                                $nameRows = (array)eZDB::instance()->arrayQuery(
                                    "SELECT ezcontentobject_name.name 
                                    FROM ezcontentobject_name 
                                        INNER JOIN ezcontentobject ON(
                                            ezcontentobject_name.contentobject_id = ezcontentobject.id
                                            AND ezcontentobject_name.content_version = ezcontentobject.current_version
                                        )
                                    WHERE ezcontentobject_name.contentobject_id in ($relationIdList)
                                "
                                );
                                $names = array_column($nameRows, 'name');
                            }
                            $value = implode(',', $names);
                            break;
                        default:
                            $value = ezfSolrDocumentFieldBase::preProcessValue(
                                $attribute->metaData(),
                                ezfSolrDocumentFieldBase::getClassAttributeType($classAttribute)
                            );
                    }
                    if (!empty($value)) {
                        foreach ($fieldNameArray as $fieldName) {
                            if (!is_array($value)) {
                                $value = [$value];
                            }
                            $data[$language][$fieldName] = $value;
                        }
                    }
                }
            }
        }

        return $data;
    }

    private static function generateSubMetaFieldName(
        string $contentClassAttributeIdentifier,
        string $baseName,
        string $type = null
    ): string {
        $documentFieldName = ezfSolrDocumentFieldBase::getDocumentFieldName();
        return $documentFieldName->lookupSchemaName(
            ezfSolrDocumentFieldBase::SUBMETA_FIELD_PREFIX .
            $contentClassAttributeIdentifier .
            ezfSolrDocumentFieldBase::SUBATTR_FIELD_SEPARATOR .
            $baseName .
            ezfSolrDocumentFieldBase::SUBATTR_FIELD_SEPARATOR,
            $type ?? eZSolr::getMetaAttributeType($baseName)
        );
    }

    private static function generateSubAttributeFieldName(
        string $contentClassAttributeIdentifier,
        string $subfieldName,
        string $type
    ): string {
        $documentFieldName = ezfSolrDocumentFieldBase::getDocumentFieldName();
        return $documentFieldName->lookupSchemaName(
            ezfSolrDocumentFieldBase::SUBATTR_FIELD_PREFIX .
            $contentClassAttributeIdentifier .
            ezfSolrDocumentFieldBase::SUBATTR_FIELD_SEPARATOR .
            $subfieldName .
            ezfSolrDocumentFieldBase::SUBATTR_FIELD_SEPARATOR,
            $type
        );
    }

    private static function generateAttributeFieldName(string $contentClassAttributeIdentifier, string $type): string
    {
        $documentFieldName = ezfSolrDocumentFieldBase::getDocumentFieldName();
        return $documentFieldName->lookupSchemaName(
            ezfSolrDocumentFieldBase::ATTR_FIELD_PREFIX .
            $contentClassAttributeIdentifier,
            $type
        );
    }

    public static function getOpendataIndexData(int $contentObjectId): array
    {
        if (class_exists('\Opencontent\Opendata\Api\Gateway\SolrStorage')) {
            try {
                $dbGateway = new \Opencontent\Opendata\Api\Gateway\Database();
                $content = $dbGateway->loadContent($contentObjectId);
                $solrStorage = new ezfSolrStorage();
                $value = $solrStorage->serializeData($content->jsonSerialize());
                $identifier = $solrStorage->getSolrStorageFieldName('opendatastorage');
                return [$identifier => $value];
            } catch (Exception $e) {
                eZDebug::writeError($e->getMessage(), __METHOD__);
            }
        }
        return [];
    }
}