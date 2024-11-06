<?php

use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\Values\Content;

class OpenPAReverseRelationListFunctionCollection
{

    public static function fetchCount($attribute)
    {
        $result = ['result' => 0];
        if (!$attribute instanceof eZContentObjectAttribute) {
            return $result;
        }

        $result['result'] = OpenPAReverseRelationListType::fetchCount($attribute);

        return $result;
    }

    public static function fetch($attribute, $offset, $limit)
    {
        $result = ['result' => []];
        if (!$attribute instanceof eZContentObjectAttribute) {
            return $result;
        }

        $query = OpenPAReverseRelationListType::buildQuery($attribute, (int)$limit, (int)$offset);
        eZDebug::writeDebug($query, $attribute->attribute('id') . ' ' . __METHOD__);
        try {
            $contentSearch = new ContentSearch();
            $contentSearch->setEnvironment(new FullEnvironmentSettings());
            $data = $contentSearch->search($query);
            $contents = $data->searchHits;
            $nodes = [];
            foreach ($contents as $content) {
                try {
                    $apiContent = new Content((array)$content);
                    $nodeId = (int)$apiContent->metadata->mainNodeId;
                    if ($nodeId > 0) {
                        $nodes[] = $nodeId;
                    }
                } catch (Exception $e) {
                    eZDebug::writeError($e->getMessage(), __METHOD__);
                }
            }
            $nodes = array_unique($nodes);
            $result['result'] = count($nodes) ? self::fetchNodes($nodes) : [];
        } catch (Exception $e) {
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }

        return $result;
    }

    private static function fetchNodes(array $nodeIdList = []): array
    {
        $db = eZDB::instance();
        $versionNameJoins = " AND " . eZContentLanguage::sqlFilter('ezcontentobject_name', 'ezcontentobject');
        $languageFilter = ' AND ' . eZContentLanguage::languagesSQLFilter('ezcontentobject');
        $nodeIdListAsString = implode(',', $nodeIdList);
        $sqlCondition = $db->generateSQLINStatement($nodeIdList, 'node_id', false, true, 'int') . ' AND ';
        $query = "SELECT " .
            "ezcontentobject.contentclass_id, ezcontentobject.current_version, ezcontentobject.id, ezcontentobject.initial_language_id, ezcontentobject.language_mask, " .
            "ezcontentobject.modified, ezcontentobject.owner_id, ezcontentobject.published, ezcontentobject.remote_id AS object_remote_id, ezcontentobject.section_id, " .
            "ezcontentobject.status, ezcontentobject_tree.contentobject_is_published, ezcontentobject_tree.contentobject_version, " .
            "ezcontentobject_tree.depth, ezcontentobject_tree.is_hidden, ezcontentobject_tree.is_invisible, ezcontentobject_tree.main_node_id, ezcontentobject_tree.modified_subnode, " .
            "ezcontentobject_tree.node_id, ezcontentobject_tree.parent_node_id, ezcontentobject_tree.path_identification_string, ezcontentobject_tree.path_string, ezcontentobject_tree.priority, " .
            "ezcontentobject_tree.remote_id, ezcontentobject_tree.sort_field, ezcontentobject_tree.sort_order, ezcontentclass.serialized_name_list as class_serialized_name_list, " .
            "ezcontentclass.identifier as class_identifier, ezcontentclass.is_container, ezcontentobject_name.name, ezcontentobject_name.real_translation " .
            "FROM ezcontentobject_tree " .
            "INNER JOIN ezcontentobject ON (ezcontentobject.id = ezcontentobject_tree.contentobject_id) " .
            "INNER JOIN ezcontentclass ON (ezcontentclass.id = ezcontentobject.contentclass_id) " .
            "INNER JOIN ezcontentobject_name ON ( " .
            "    ezcontentobject_name.contentobject_id = ezcontentobject_tree.contentobject_id AND " .
            "    ezcontentobject_name.content_version = ezcontentobject_tree.contentobject_version " .
            ") " .
            "JOIN   unnest('{" . $nodeIdListAsString . "}'::int[]) WITH ORDINALITY t(node_id, ord) USING (node_id)" .
            "WHERE $sqlCondition " .
            "ezcontentclass.version = 0 " .
            "$languageFilter " .
            $versionNameJoins .
            "ORDER  BY t.ord";

        $nodeListArray = $db->arrayQuery($query);
        return eZContentObjectTreeNode::makeObjectsArray($nodeListArray);
    }

    public function buildQuery($attribute)
    {
        if (!$attribute instanceof eZContentObjectAttribute) {
            return $result = [
                'error' => [
                    'error_type' => 'kernel',
                    'error_code' => eZError::KERNEL_NOT_FOUND,
                ],
            ];
        }

        return ['result' => OpenPAReverseRelationListType::buildQuery($attribute, null)];
    }
}