<?php

use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\ContentSearch;

class DataHandlerAlboPretorioContents implements OpenPADataHandlerInterface
{

    public function __construct(array $Params)
    {
    }


    public function getData()
    {
        $http = eZHTTPTool::instance();

        $baseQuery = "classes [document] and id_albo_pretorio != null and facets [raw[subattr_document_type___tag_ids____si],raw[subattr_publication_start_time___year____dt],class]";

        if (empty($baseQuery)) {
            throw new Exception("Invalid block query settings");
        }

        $ignorePolicy = true;

        $parser = new ezpRestHttpRequestParser();
        /** @var ezpRestRequest $request */
        $request = $parser->createRequest();

        $contentSearch = new ContentSearch();
        $currentEnvironment = EnvironmentLoader::loadPreset('useraware');
        $currentEnvironment->__set('request', $request);
        $contentSearch->setEnvironment($currentEnvironment);

        $query = $baseQuery;

        $availableFilters = [
            'q' => function ($query, $value) {
                $query .= ' and q = "' . addcslashes($value, '\'()[]"') . '"';
                return $query;
            },
            'publication' => function ($query, $value) {
                if ($value === 'current') {
                    $query .= ' and (calendar[publication_start_time,publication_end_time] = [yesterday,now] )';
                }
                return $query;
            },
            'tag_id' => function ($query, $value) {
                $values = explode(',', $value);
                $values = array_map('intval', $values);
                $value = implode(',', $values);
                $query .= ' and raw[subattr_document_type___tag_ids____si] in [' . $value . ']';
                return $query;
            },
            'has_organization' => function ($query, $value) {
                $values = explode(',', $value);
                $values = array_map('intval', $values);
                $value = implode(',', $values);
                $query .= ' and has_organization.id in [' . $value . ']';
                return $query;
            },
            'has_code' => function ($query, $value) {
                $query .= ' and id_albo_pretorio = "' . str_replace('/', '-', addcslashes($value, '\'()[]"')) . '"';
                return $query;
            },
            'year' => function ($query, $value) {
                $query .= ' and raw[subattr_publication_start_time___year____dt] = "' .
                    intval($value) . '-01-01T00:00:00Z"';
                return $query;
            },
            'date_range' => function ($query, $value) {
                $range = explode(',', $value);
                $start = $range[0] ?? '*';
                if ($start !== '*') {
                    $start .= 'T00:00:00Z';
                }
                $end = $range[1] ?? '*';
                if ($end !== '*') {
                    $end .= 'T00:00:00Z';
                }
                $query .= ' and (calendar[publication_start_time,publication_end_time] = [' . $start . ',' . $end . '] )';
                return $query;
            },
        ];
        $filters = [];
        foreach ($availableFilters as $filterIdentifier => $queryModifier) {
            if ($http->hasGetVariable($filterIdentifier)) {
                $filters[$filterIdentifier] = $http->getVariable($filterIdentifier);
                $query = $queryModifier($query, $filters[$filterIdentifier]);
            }
        }

        $limit = $http->hasGetVariable('limit')
            ? (int)$http->getVariable('limit')
            : $currentEnvironment->getDefaultSearchLimit();
        $query .= ' and limit ' . $limit;
        if ($http->hasGetVariable('offset')) {
            $query .= ' and offset ' . (int)$http->getVariable('offset');
        }

        $queryBuilder = $contentSearch->getQueryBuilder();
        $queryObject = $queryBuilder->instanceQuery($query);

        $data = (array)$contentSearch->search($query, $ignorePolicy ? [] : null);

        if (!empty($data['nextPageQuery'])) {
            $ezFindQueryObject = $queryObject->convert();
            $ezFindQueryObject['SearchOffset'] = $ezFindQueryObject['SearchOffset'] ?? 0;
            $offset = $ezFindQueryObject['SearchLimit'] + $ezFindQueryObject['SearchOffset'];
            $limit = $ezFindQueryObject['SearchLimit'];
            $nextPageParams = array_merge($filters, [
                'limit' => $limit,
                'offset' => $offset,
            ]);
            $data['nextPageQuery'] = true;
        }

        return $data;
    }

}
