<?php

use Opencontent\Opendata\Api\ContentSearch;

class OpenPARolesFunctionCollection
{
    public static function fetchPeopleCount($attribute)
    {
        $result = ['result' => 0];
        if (!$attribute instanceof eZContentObjectAttribute) {
            return $result;
        }
        $openpaRoles = OpenPARoles::instance($attribute);
        try {
            $contentSearch = new ContentSearch();
            $contentSearch->setEnvironment(
                new DefaultEnvironmentSettings()
            );
            $data = $contentSearch->search($openpaRoles->buildQuery());
        } catch (Exception $e) {
            $data = new stdClass();
            $data->totalCount = 0;
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }

        $result['result'] = (int)$data->totalCount;

        return $result;
    }

    public static function fetchPeople($attribute, $offset, $limit)
    {
        $result = ['result' => []];
        if (!$attribute instanceof eZContentObjectAttribute) {
            return $result;
        }
        $openpaRoles = OpenPARoles::instance($attribute);
        $limit = intval($limit ?? $openpaRoles->getPagination());
        if ($limit <= 0) {
            return $result;
        }
        $offset = (int)$offset;
        $contentSearch = new ContentSearch();
        try {
            $contentSearch->setEnvironment(
                new FullEnvironmentSettings(['maxSearchLimit' => OpenPARoleType::FETCH_LIMIT])
            );
            $data = $contentSearch->search($openpaRoles->buildQuery($limit, $offset));
        } catch (Exception $e) {
            $data = new stdClass();
            $data->searchHits = [];
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }
        $peopleList = [];
        $roleHits = $data->searchHits;
        foreach ($roleHits as $roleHit) {
            $role = eZContentObject::fetch((int)$roleHit['metadata']['id']);
            if ($role instanceof eZContentObject) {
                $roleDataMap = $role->dataMap();
                if (isset($roleDataMap['person']) && $roleDataMap['person']->hasContent()) {
                    $relationList = (array)$roleDataMap['person']->content();
                    foreach ($relationList['relation_list'] as $relation) {
                        $person = eZContentObjectTreeNode::fetch((int)$relation['node_id']);
                        if ($person instanceof eZContentObjectTreeNode) {
                            $peopleList[$relation['contentobject_id']] = $person;
                        }
                    }
                }
            }
        }
        $result['result'] = array_values($peopleList);

        return $result;
    }
}