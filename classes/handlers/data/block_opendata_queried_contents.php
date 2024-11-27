<?php

use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\ContentSearch;

class DataHandlerOpendataQueriedContents implements OpenPADataHandlerInterface
{
    const BLOCK_TYPE = 'OpendataQueriedContents';

    private $blockId;

    private $api;

    public function __construct(array $Params)
    {
        $this->blockId = $Params['Parameters'][1];
        $this->api = $Params['Parameters'][2];
    }

    private function getDataByAttribute($attributeId, $version)
    {
        $attribute = eZContentObjectAttribute::fetch((int)$attributeId, (int)$version);
        if (!$attribute instanceof eZContentObjectAttribute) {
            throw new Exception("Attribute $this->blockId not found");
        }

        $result = new \Opencontent\Opendata\Api\Values\SearchResults();
        if ($attribute->attribute('data_type_string') === OpenPARoleType::DATA_TYPE_STRING)
        {
            $http = eZHTTPTool::instance();
            $openpaRoles = OpenPARoles::instance($attribute);
            $limit = intval($openpaRoles->getPagination());
            if ($limit <= 0) {
                return $result;
            }
            $offset = $http->hasGetVariable('offset') ? (int)$http->getVariable('offset') : 0;
            $contentSearch = new ContentSearch();
            try {
                $contentSearch->setEnvironment(
                    new FullEnvironmentSettings(['maxSearchLimit' => OpenPARoleType::FETCH_LIMIT])
                );
                $result = $contentSearch->search($openpaRoles->buildQuery($limit, $offset));

                $parser = new ezpRestHttpRequestParser();
                /** @var ezpRestRequest $request */
                $request = $parser->createRequest();
                $request->get['view'] = /*$http->hasGetVariable('view') ? $http->getVariable('view') :*/ 'card_teaser';
                $currentEnvironment = EnvironmentLoader::loadPreset('content');
                $currentEnvironment->__set('request', $request);
                $context = $http->hasGetVariable('context') ? $http->getVariable('context') : ($blockAttributes['context_api'] ?? null);
                if (!empty($context)){
                    $request->get['context'] = $context;
                }
                $currentEnvironment = EnvironmentLoader::loadPreset('content');
                $currentEnvironment->__set('request', $request);

                $peopleList = [];
                $roleHits = $result->searchHits;
                $locale = eZLocale::currentLocaleCode();
                foreach ($roleHits as $roleHit) {
                    foreach ($roleHit['data'][$locale]['person']['content'] as $personRelated) {
                        $person = eZContentObject::fetch((int)$personRelated['id']);
                        if ($person instanceof eZContentObject) {
                            $personContent = \Opencontent\Opendata\Api\Values\Content::createFromEzContentObject($person);
                            $peopleList[$personRelated['id']] = $currentEnvironment->filterContent($personContent);
                        }
                    }
                }
                $result->searchHits = array_values($peopleList);

            } catch (Exception $e) {
                $result = new stdClass();
                $result->searchHits = [];
                eZDebug::writeError($e->getMessage(), __METHOD__);
            }
        }


        return $result;
    }

    public function getData()
    {
        $http = eZHTTPTool::instance();
        if (strpos($this->blockId, 'a-') !== false){
            [, $attributeId, $version] = explode('-', $this->blockId);
            return $this->getDataByAttribute($attributeId, $version);
        }
        if (!in_array($this->api, ['search', 'geo'])) {
            throw new Exception("Api $this->api not allowed");
        }
        $block = eZPageBlock::fetch($this->blockId);
        if (empty($block->attribute('id'))) {
            throw new Exception("Block not found");
        }
        if ($block->attribute('type') !== self::BLOCK_TYPE) {
            throw new Exception("Invalid block type");
        }
        $blockAttributes = $block->attribute('custom_attributes');
        $baseQuery = $blockAttributes['query'];
        if (empty($baseQuery)) {
            throw new Exception("Invalid block query settings");
        }
        $facetsSettings = $blockAttributes['facets'];
        $facets = [];
        $hasTimeInterval = false;
        if (!empty($facetsSettings)) {
            $facetsSettingsParts = explode(',', $facetsSettings);
            foreach ($facetsSettingsParts as $facetsSettingsPart) {
                $parts = explode(':', $facetsSettingsPart);
                if (isset($parts[1])) {
                    if ($parts[1] !== 'time_interval') {
                        $facets[] = $parts[1];
                    } else {
                        $hasTimeInterval = true;
                    }
                }
            }
        }
        $view = $http->hasGetVariable('view') ? $http->getVariable('view') : $blockAttributes['view_api'];
        $useSimpleGeoApi = (bool)$blockAttributes['simple_geo_api'];
        $queryStringIsAllowed = (bool)$blockAttributes['show_search'];
        $maxLimit = (int)$blockAttributes['limit'];
        $ignorePolicy = (bool)$blockAttributes['ignore_policy'];

        $contentSearch = new ContentSearch();
        if ($this->api === 'geo') {
            $currentEnvironment = EnvironmentLoader::loadPreset($useSimpleGeoApi ? 'geo' : 'extrageo');
        } else {
            $currentEnvironment = EnvironmentLoader::loadPreset('content');
        }
        $parser = new ezpRestHttpRequestParser();
        /** @var ezpRestRequest $request */
        $request = $parser->createRequest();
        $request->get['view'] = $view;
        $context = $http->hasGetVariable('context') ? $http->getVariable('context') : ($blockAttributes['context_api'] ?? null);
        if (!empty($context)){
            $request->get['context'] = $context;
        }
        $currentEnvironment->__set('request', $request);
        $contentSearch->setEnvironment($currentEnvironment);

        $query = $baseQuery;
        $searchString = '';
        if ($http->hasGetVariable('search') && $queryStringIsAllowed) {
            $searchString = $http->getVariable('search');
            if (!empty($searchString)) {
                $encodedString = trim(addcslashes($searchString, '"()[]\''));
                if ($this->api === 'geo') {
                    $strings = explode(' ', $encodedString);
                    $conditions = '[\'"' . implode('"\',\'"', $strings) . '"\']';
                    $query = '(raw[meta_name_t] contains ' . $conditions . ' or raw[attr_alternative_name_t] contains ' . $conditions . ') and ' . $baseQuery;
                } else {
                    $query = 'q = \'' . $encodedString . '\' and ' . $baseQuery;
                }

            }
        }
        $requestFacets = [];
        if ($http->hasGetVariable('facets')) {
            $requestFacets = (array)$http->getVariable('facets');
            foreach ($facets as $facet) {
                $parts = explode('|', $facet);
                $field = array_shift($parts);
                if (isset($requestFacets[$field]) && !empty($requestFacets[$field])) {
                    $value = (array)$requestFacets[$field];
                    $query = $field . ' in [\'"' . implode('"\',\'"', $value) . '"\'] and ' . $query;
                }
            }
        }

        if ($hasTimeInterval){
            $queryInterval = ' and calendar[time_interval] = [now,*]';
            if ($http->hasGetVariable('interval')) {
                $now = new DateTime();
                $start = 'now';
                $end = '*';
                switch ($http->getVariable('interval')){
                    case 'today':
                        $end = (new DateTime())->setTime(23,59)->format('c');
                        break;
                    case 'weekend':
                    case 'nextweekend':
                        $now = time();
                        $saturday = DateTime::createFromFormat('Y-m-d', date('Y-m-',$now).(6+date('j',$now)-date('w',$dt)));
                        $start = $saturday->setTime(0,0)->format('c');
                        $end = $saturday->add(new DateInterval('P1D'))->setTime(23,59)->format('c');
                        break;
                    case 'next7days':
                        $end = (new DateTime())->add(new DateInterval('P7D'))->setTime(23,59)->format('c');
                        break;
                    case 'next30days':
                        $end = (new DateTime())->add(new DateInterval('P30D'))->setTime(23,59)->format('c');
                        break;
                }
            }
            $query .= " and calendar[time_interval] = ['$start','$end']";
        }


        if ($http->hasGetVariable('id')) {
            $query .= ' and id = \'' . $http->getVariable('id') . '\'';
        }
        if ($http->hasGetVariable('f') && count($facets)) {
            $query .= ' facets [' . implode(',', $facets) . ']';
        }
        $limit = $http->hasGetVariable('limit')
            ? (int)$http->getVariable('limit')
            : $currentEnvironment->getDefaultSearchLimit();
        if ($limit > $maxLimit && $this->api !== 'geo') {
            $limit = $maxLimit;
        }
        $query .= ' and limit ' . $limit;
        if ($http->hasGetVariable('offset')) {
            $query .= ' and offset ' . (int)$http->getVariable('offset');
        }

        $queryBuilder = $contentSearch->getQueryBuilder();
        $queryObject = $queryBuilder->instanceQuery($query);
        if ($http->hasGetVariable('search') && $queryStringIsAllowed && $this->api === 'search') {
            $sortQuery = $queryBuilder->instanceQuery('sort [score=>desc]');
            $sortQuery->merge($queryObject);
            $query = (string)$sortQuery;
        }

        OpenPABootstrapItaliaNodeViewFunctions::setIgnorePolicy($ignorePolicy);
        $data = (array)$contentSearch->search($query, $ignorePolicy ? [] : null);

        if (!empty($data['nextPageQuery'])){
            $ezFindQueryObject = $queryObject->convert();
            $ezFindQueryObject['SearchOffset'] = $ezFindQueryObject['SearchOffset'] ?? 0;
            $offset = $ezFindQueryObject['SearchLimit'] + $ezFindQueryObject['SearchOffset'];
            $limit = $ezFindQueryObject['SearchLimit'];
            $nextPageParams = [
                'limit' => $limit,
                'offset' => $offset,
                'facets' => $requestFacets,
            ];
            if (!empty($searchString)){
                $nextPageParams['search'] = $searchString;
            }
            $data['nextPageQuery'] = '?' . http_build_query($nextPageParams);
        }
        if ($ignorePolicy && !empty($view)){
            //workaround de merd... @todo
            $string = json_encode($data);
            $string = str_replace('no-sezioni_per_tutti', '', $string);
            $data = json_decode($string, true);
        }

        return $data;
    }

}
