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

    public function getData()
    {
        $http = eZHTTPTool::instance();
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
        if (!empty($facetsSettings)) {
            $facetsSettingsParts = explode(',', $facetsSettings);
            foreach ($facetsSettingsParts as $facetsSettingsPart) {
                $parts = explode(':', $facetsSettingsPart);
                if (isset($parts[1])) {
                    $facets[] = $parts[1];
                }
            }
        }
        $view = $blockAttributes['view_api'];
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
        $currentEnvironment->__set('request', $request);
        $contentSearch->setEnvironment($currentEnvironment);

        $query = $baseQuery;
        $searchString = '';
        if ($http->hasGetVariable('search') && $queryStringIsAllowed) {
            $searchString = $http->getVariable('search');
            if (!empty($searchString)) {
                $query = 'q = \'' . addcslashes($searchString, '"()[]\'') . '\' and ' . $baseQuery;
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
        if ($http->hasGetVariable('id')) {
            $query .= ' and id = \'' . $http->getVariable('id') . '\'';
        }
        if ($http->hasGetVariable('f') && count($facets)) {
            $query .= ' facets [' . implode(',', $facets) . ']';
        }
        if ($http->hasGetVariable('limit')) {
            $limit = (int)$http->getVariable('limit');
            if ($limit > $maxLimit) {
                $limit = $maxLimit;
            }
            $query .= ' and limit ' . $limit;
        }
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
