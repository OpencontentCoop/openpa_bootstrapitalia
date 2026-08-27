<?php

use Opencontent\Opendata\Api\AttributeConverter\Base;

class OpenPARoleAttributeConverter extends Base
{
    public function get(eZContentObjectAttribute $attribute)
    {
        $data = [
            'id' => intval($attribute->attribute('id')),
            'version' => intval($attribute->attribute('version')),
            'identifier' => $this->classIdentifier . '/' . $this->identifier,
            'datatype' => $attribute->attribute('data_type_string'),
            'contentclassattribute_id' => $attribute->attribute('contentclassattribute_id'),
            'sort_key_int' => $attribute->attribute('sort_key_int'),
            'sort_key_string' => $attribute->attribute('sort_key_string'),
            'data_text' => $attribute->attribute('data_text'),
            'data_int' => $attribute->attribute('data_int'),
            'data_float' => $attribute->attribute('data_float'),
            'is_information_collector' => $attribute->attribute('is_information_collector'),
        ];

        $roles = [];
        foreach (OpenPARoles::instance($attribute)->attribute('roles') as $role) {
            if ($role instanceof eZContentObject) {
                $roles[] = self::serializeRole($role);
            }
        }
        $data['content'] = $roles;

        return $data;
    }

    /**
     * @param eZContentObject $role time_indexed_role object
     * @return array
     */
    private static function serializeRole(eZContentObject $role)
    {
        $dataMap = $role->dataMap();
        $mainNode = $role->mainNode();

        $item = [
            'id' => (int)$role->attribute('id'),
            'remoteId' => $role->attribute('remote_id'),
            'classIdentifier' => 'time_indexed_role',
            'mainNodeId' => $mainNode instanceof eZContentObjectTreeNode ? (int)$mainNode->attribute('node_id') : null,
            'name' => $role->name(),
            'role' => self::tagKeywords($dataMap, 'role'),
            'type' => self::tagKeywords($dataMap, 'type'),
            'for_entity' => self::relatedContentItems($dataMap, 'for_entity'),
            'start_date' => self::dateValue($dataMap, 'start_time'),
            'end_date' => self::dateValue($dataMap, 'end_time'),
        ];

        return $item;
    }

    /**
     * Resolve an eztags attribute to a plain array of keywords.
     */
    private static function tagKeywords(array $dataMap, $identifier)
    {
        if (!isset($dataMap[$identifier]) || !$dataMap[$identifier]->hasContent()) {
            return [];
        }
        $tags = $dataMap[$identifier]->content();
        if (!$tags instanceof eZTags) {
            return [];
        }
        $keywords = [];
        foreach ($tags->attribute('tags') as $tag) {
            $keywords[] = $tag->attribute('keyword');
        }
        return $keywords;
    }

    /**
     * Resolve an ezobjectrelation/ezobjectrelationlist attribute ("-"-separated ids)
     * to a list of minimal relation-item arrays (id/remoteId/classIdentifier/mainNodeId/name),
     * the same shape expected by OCWebHookKafkaPayloadFormatter::normalizeRelationItem()
     * and OCWebHookPayloadBuilder::enrichRelationContentUrls() for standard relations.
     */
    private static function relatedContentItems(array $dataMap, $identifier)
    {
        $items = [];
        if (!isset($dataMap[$identifier]) || !$dataMap[$identifier]->hasContent()) {
            return $items;
        }
        $idList = array_filter(array_map('intval', explode('-', $dataMap[$identifier]->toString())));
        foreach ($idList as $id) {
            $relatedObject = eZContentObject::fetch($id);
            if ($relatedObject instanceof eZContentObject) {
                $relatedNode = $relatedObject->mainNode();
                $items[] = [
                    'id' => (int)$relatedObject->attribute('id'),
                    'remoteId' => $relatedObject->attribute('remote_id'),
                    'classIdentifier' => $relatedObject->attribute('class_identifier'),
                    'mainNodeId' => $relatedNode instanceof eZContentObjectTreeNode ? (int)$relatedNode->attribute('node_id') : null,
                    'name' => $relatedObject->name(),
                ];
            }
        }
        return $items;
    }

    /**
     * Resolve an ezdate attribute to an ISO 8601 string (or null).
     * ezdate stores a Unix timestamp (data_int) — day/month/year is the meaningful
     * part, the time-of-day component is an artifact of eZ Publish's "default to
     * now()" behavior on creation and carries no editorial meaning.
     */
    private static function dateValue(array $dataMap, $identifier)
    {
        if (!isset($dataMap[$identifier]) || !$dataMap[$identifier]->hasContent()) {
            return null;
        }
        $timestamp = (int)$dataMap[$identifier]->toString();
        return $timestamp > 0 ? date('c', $timestamp) : null;
    }
}