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
                $request->get['view'] = /*$http->hasGetVariable('view') ? $http->getVariable('view') :*/ 'card_teaser_info';
                $currentEnvironment = EnvironmentLoader::loadPreset('content');
                $currentEnvironment->__set('request', $request);
                $context = $http->hasGetVariable('context') ? $http->getVariable('context') : ($blockAttributes['context_api'] ?? null);
                if (!empty($context)){
                    $request->get['context'] = $context;
                }
                $request->get['view_params'] = [
                    'openparole' => $attributeId,
                    '_custom' => [
                        'context_object_id' => $attribute->attribute('contentobject_id'),
                    ]
                ];
                $currentEnvironment = EnvironmentLoader::loadPreset('content');
                $currentEnvironment->__set('request', $request);

                $peopleList = [];
                $roleHits = $result->searchHits;
                $locale = eZLocale::currentLocaleCode();
                foreach ($roleHits as $roleHit) {
                    $people = $roleHit['data'][$locale]['person']['content'] ?? $roleHit['data']['ita-IT']['person']['content'];
                    foreach ($people as $personRelated) {
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

        if (!in_array($this->api, ['search', 'geo', 'calendar'])) {
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
        $hasPublishedRange = false;
        if (!empty($facetsSettings)) {
            $facetsSettingsParts = explode(',', $facetsSettings);
            foreach ($facetsSettingsParts as $facetsSettingsPart) {
                $parts = explode(':', $facetsSettingsPart);
                if (isset($parts[1])) {
                    if ($parts[1] !== 'time_interval' && $parts[1] !== 'published_range') {
                        if (isset($parts[2])
                            && $parts[2] === 'tree'
                            && OpenPABootstrapItaliaOperators::getTagRootFromAttributeIdentifier($parts[1])){
                            $facets[] = 'raw[subattr_' . $parts[1] . '___tag_ids____si]';
                        } else {
                            $facets[] = $parts[1];
                        }
                    } elseif ($parts[1] === 'time_interval') {
                        $hasTimeInterval = true;
                    } elseif ($parts[1] === 'published_range') {
                        $hasPublishedRange = true;
                    }
                }
            }
        }

        $view = $http->hasGetVariable('view') ? $http->getVariable('view') : $blockAttributes['view_api'];
        $useSimpleGeoApi = (bool)$blockAttributes['simple_geo_api'];
        $queryStringIsAllowed = (bool)$blockAttributes['show_search'];
        $maxLimit = (int)$blockAttributes['limit'];
        $ignorePolicy = (bool)$blockAttributes['ignore_policy'];

        $parser = new ezpRestHttpRequestParser();
        /** @var ezpRestRequest $request */
        $request = $parser->createRequest();
        $request->get['view'] = $view;
        $context = $http->hasGetVariable('context') ? $http->getVariable('context') : ($blockAttributes['context_api'] ?? null);
        if (!empty($context)){
            $request->get['context'] = $context;
        }

        $contentSearch = new ContentSearch();
        if ($this->api === 'geo') {
            $currentEnvironment = EnvironmentLoader::loadPreset($useSimpleGeoApi ? 'geo' : 'extrageo');
        } elseif ($this->api === 'calendar') {
            $currentEnvironment = EnvironmentLoader::loadPreset('calendar');
            $request->get['start'] = $http->hasGetVariable('start') ? $http->getVariable('start') : 'now';
            $request->get['end'] = $http->hasGetVariable('end') ? $http->getVariable('end') : '*';
        } else {
            $currentEnvironment = EnvironmentLoader::loadPreset('content');
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
                $requestFacetsField = $requestFacets[$field] ?? null;
                if (!$requestFacetsField && strpos($field, 'raw[') !== false){
                    $requestFacetsField = $requestFacets[substr($field, 0, -1)] ?? null; //@workaround parsing error?
                }
                if (!empty($requestFacetsField)) {
                    $value = (array)$requestFacetsField;
                    $value = array_map(function ($item) {
                        return trim($item, '"');
                    }, $value);
                    $query = $field . ' in [\'"' . implode('"\',\'"', $value) . '"\'] and ' . $query;
                }
            }
        }

        if ($hasTimeInterval){
            $start = $http->hasGetVariable('start') ? $http->getVariable('start') : 'now';
            $end = $http->hasGetVariable('end') ? $http->getVariable('end') : '*';
            if ($http->hasGetVariable('interval')) {
                switch ($http->getVariable('interval')){
                    case 'today':
                        $end = (new DateTime())->setTime(23,59)->format('c');
                        break;
                    case 'weekend':
                    case 'nextweekend':
                        $now = time();
                        $saturday = DateTime::createFromFormat('Y-m-d', date('Y-m-',$now).(6+date('j',$now)-date('w',$now)));
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
        if ($hasPublishedRange){
            $range = $http->hasGetVariable('range') ? $http->getVariable('range') : '';
            if (!empty($range)){
                [$from, $to] = explode(',', $range);
                if (!empty($from) && !empty($to)){
                    $fromDate = DateTime::createFromFormat('Y-m-d', $from);
                    $toDate = DateTime::createFromFormat('Y-m-d', $to);
                    if ($fromDate instanceof DateTime && $toDate instanceof DateTime){
                        $start = $fromDate->setTime(0,0)->format('c');
                        $end = $toDate->setTime(23,59)->format('c');
                        $query .= " and published range ['$start','$end']";
                    }
                }
            }
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
