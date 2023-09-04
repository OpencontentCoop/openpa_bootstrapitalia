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

        $query = OpenPAReverseRelationListType::buildQuery($attribute, 1);
        try {
            $contentSearch = new ContentSearch();
            $contentSearch->setEnvironment(new FullEnvironmentSettings());
            $data = $contentSearch->search($query);
        } catch (Exception $e) {
            $data = new stdClass();
            $data->totalCount = 0;
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }

        $result['result'] = (int)$data->totalCount;

        return $result;
    }

    public static function fetch($attribute, $offset, $limit)
    {
        $result = ['result' => []];
        if (!$attribute instanceof eZContentObjectAttribute) {
            return $result;
        }

        $query = OpenPAReverseRelationListType::buildQuery($attribute, (int)$limit, (int)$offset);
        try {
            $contentSearch = new ContentSearch();
            $contentSearch->setEnvironment(new FullEnvironmentSettings());
            $data = $contentSearch->search($query);
            $contents = $data->searchHits;
            $nodes = array();
            foreach ($contents as $content) {
                try {
                    $apiContent = new Content((array)$content);
                    $language = eZLocale::currentLocaleCode();
                    if (!in_array($language, $apiContent->metadata->languages)){
                        $language = $apiContent->metadata->languages[0];
                    }
                    $object = $apiContent->getContentObject($language);
                    if ($object->mainNodeID()){
                        $nodes[] = $object->mainNode();
                    }
                } catch (Exception $e) {
                    eZDebug::writeError($e->getMessage(), __METHOD__);
                }
            }
            $result['result'] = $nodes;
        } catch (Exception $e) {

            eZDebug::writeError($e->getMessage(), __METHOD__);
        }

        return $result;
    }
}