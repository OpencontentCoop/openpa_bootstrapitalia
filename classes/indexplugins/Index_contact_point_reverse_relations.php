<?php

class ezfIndexContactPointReverseRelations implements ezfIndexPlugin
{
    private static $defaultSubAttribute = 'type';

    public function modify(eZContentObject $contentObject, &$docList)
    {
        $version = $contentObject->currentVersion();
        if ($version === false) {
            return;
        }
        $availableLanguages = $version->translationList(false, false);
        if ($contentObject->attribute('class_identifier') == 'online_contact_point') {
            $attribute = $this->getReverseAttributeByObjectOrVersion($version);
            if ($attribute) {
                foreach ($availableLanguages as $languageCode) {
                    $data = $this->getData($attribute, $languageCode);
                    if (!empty($data)) {
                        if ($docList[$languageCode] instanceof eZSolrDoc) {
                            foreach ($data as $name => $value) {
                                $docList[$languageCode]->addField($name, $value);
                            }
                        }
                    }
                }
            }
        } elseif ($contentObject->attribute('class_identifier') == 'organization') {
            $dataMap = $version->dataMap();
            if (isset($dataMap['has_online_contact_point']) && $dataMap['has_online_contact_point']->hasContent()) {
                $objectList = OpenPABase::fetchObjects(explode('-', $dataMap['has_online_contact_point']->toString()));
                foreach ($objectList as $object) {
                    $attribute = $this->getReverseAttributeByObjectOrVersion($object);
                    if ($attribute) {
                        foreach ($availableLanguages as $languageCode) {
                            $data = $this->getData($attribute, $languageCode);
                            if (!empty($data)) {
                                BootstrapItaliaSolrTools::sendPatch(
                                    (int)$object->attribute('id'),
                                    [$languageCode],
                                    $data
                                );
                            }
                        }
                    }
                }
            }
        }
    }

    private function getReverseAttributeByObjectOrVersion($source): ?eZContentObjectAttribute
    {
        /** @var eZContentObjectAttribute[] $dataMap */
        $dataMap = $source->dataMap();
        foreach ($dataMap as $identifier => $attribute) {
            if ($identifier === 'is_contact_point_of_organizations'
                && $attribute->attribute('data_type_string') === OpenPAReverseRelationListType::DATA_TYPE_STRING) {
                return $attribute;
            }
        }

        return null;
    }

    private function getFieldName(eZContentObjectAttribute $attribute, string $typeAttributeIdentifier = 'type'): string
    {
        return ezfSolrDocumentFieldBase::getDocumentFieldName()->lookupSchemaName(
            'extra_' .
            $attribute->attribute('contentclass_attribute_identifier') . '_' .
            $typeAttributeIdentifier .
            ezfSolrDocumentFieldBase::SUBATTR_FIELD_SEPARATOR,
            'lckeyword'
        );
    }

    private function getData(eZContentObjectAttribute $attribute, string $locale, string $typeAttributeIdentifier = 'type'): array
    {
        $result = [];
        $toContentobjectId = (int)$attribute->attribute('contentobject_id');
        $data = (array)$attribute->attribute('class_content');
        $typeAttributeIdList = [];
        foreach ($data['attribute_list'] as $classAttributes) {
            foreach ($classAttributes as $classAttribute) {
                $classIdentifier = eZContentClass::classIdentifierByID($classAttribute->attribute('contentclass_id'));
                $typeAttributeId = eZContentClassAttribute::classAttributeIDByIdentifier(
                    $classIdentifier . '/' . $typeAttributeIdentifier
                );
                if ($typeAttributeId) {
                    $typeAttributeIdList[] = (int)$typeAttributeId;
                }
            }
        }
        if (empty($typeAttributeIdList)) {
            $typeAttributeIdList = [0]; //fallback
        }
        if (!empty($data['attribute_id_list'])) {
            $data['attribute_id_list'] = array_map('intval', $data['attribute_id_list']);
            $contentClassAttributeIdList = implode(',', $data['attribute_id_list']);
            $typeAttributeIdList = implode(',', $typeAttributeIdList);
            $query = "
                WITH relations AS (
                    SELECT ezcoa.id AS type_id, ezcc.identifier as class_identifier, ezco.* 
                        FROM ezcontentobject ezco
                        INNER JOIN ezcontentobject_link ezcol ON (
                          ezco.id = ezcol.from_contentobject_id 
                          AND ezco.current_version = ezcol.from_contentobject_version
                        )
                        INNER JOIN ezcontentclass ezcc ON (
                          ezcc.id = ezco.contentclass_id
                        )
                        FULL JOIN ezcontentobject_attribute ezcoa ON (
                          ezcoa.contentobject_id = ezco.id 
                          AND ezcoa.version = ezco.current_version
                          AND ezcoa.contentclassattribute_id in ($typeAttributeIdList)
                        )
                        WHERE 
                            ezco.status = 1
                            AND ezcol.to_contentobject_id = $toContentobjectId
                            AND ezcol.contentclassattribute_id in ($contentClassAttributeIdList)
                            AND ( ezcol.relation_type & 8 ) <> 0
                )
                SELECT eztags_keyword.keyword AS type, relations.class_identifier 
                  FROM relations
                  LEFT JOIN eztags_attribute_link ON (
                    eztags_attribute_link.objectattribute_id = relations.type_id 
                    AND eztags_attribute_link.objectattribute_version = relations.current_version
                  )
                  LEFT JOIN eztags_keyword ON (
                    eztags_keyword.keyword_id = eztags_attribute_link.keyword_id
                    AND eztags_keyword.locale = '$locale' 
                  )
                GROUP BY relations.class_identifier, eztags_keyword.keyword
                HAVING count(relations.id) > 0
            ";
            $res = (array)eZDB::instance()->arrayQuery($query);
            $types = array_unique(array_column($res, 'type'));
            $types = array_filter($types);
            if (!empty($types)) {
                $fieldName = $this->getFieldName($attribute, $typeAttributeIdentifier);
                $result = [$fieldName => $types];
            }
        }

        return $result;
    }
}
