<?php

use Opencontent\Opendata\Api\ClassRepository;
use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\Api\Values\ContentClass;

class OpenPABootstrapItaliaDatatableEnvironmentSettings extends OpenPABootstrapItaliaContentEnvironmentSettings
{

    public function filterSearchResult(
        \Opencontent\Opendata\Api\Values\SearchResults $searchResults,
        \ArrayObject $query,
        \Opencontent\QueryLanguage\QueryBuilder $builder
    ) {

        $parameters = $this->request->get;
        $columns = $parameters['columns'];
        $requestNames = array();
        foreach( $columns as $index => $column ){
            $requestNames[] = $column['name'];
        }

        foreach($searchResults->searchHits as &$content){
            $fixData = array();
            foreach($content['data'] as $language => $data){
                $diff = array_diff($requestNames, array_keys($data));
                $missing = array_intersect($builder->fields, $diff);
                if (!empty($missing)){
                    $data = array_merge($data, array_fill_keys($missing, null));
                }
                $fixData[$language] = $data;
                $content['data'] = $fixData;
            }
        }

        return array(
            'draw' => (int)( ++$this->request->get['draw']),
            'recordsTotal' => (int)$searchResults->totalCount,
            'recordsFiltered' => (int)$searchResults->totalCount,
            'data' => $searchResults->searchHits,
            'facets' => $searchResults->facets,
            'query' => $query
        );
    }
    
    protected function filterMetaData( Content $content )
    {
        return parent::filterMetaData($content);
    }

    /**
     * @param ArrayObject $query
     * @param \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder $builder
     *
     * @return ArrayObject
     */
    public function filterQuery(
        \ArrayObject $query,
        \Opencontent\QueryLanguage\QueryBuilder $builder
    ) {
        $parameters = $this->request->get;

        $forceAsAttributeFields = [];
        if (isset($query['SearchContentClassID']) && count($query['SearchContentClassID']) === 1){
            if (is_numeric($query['SearchContentClassID'][0])){
                try {
                    $class = (new ClassRepository)->load(
                        eZContentClass::classIdentifierByID($query['SearchContentClassID'][0])
                    );
                    if ($class instanceof ContentClass){
                        $fields = array_column($class->fields, 'identifier');
                        $overrideAttributeFields = array_intersect($fields, ['published', 'modified']);
                        foreach ($overrideAttributeFields as $overrideAttributeField) {
                            $forceAsAttributeFields[$overrideAttributeField] = ezfSolrDocumentFieldBase::generateAttributeFieldName(
                                new \eZContentClassAttribute(array('identifier' => $overrideAttributeField)),
                                'date'
                            );
                        }
                    }
                }catch (Exception $e){}
            }
        }

        $columns = $parameters['columns'];
        $order = $parameters['order'];
        $search = $parameters['search'];        
        foreach( $columns as $index => $column ){            
            if ( $column['searchable'] == 'true' || $column['searchable'] === true ){                
                $columns[$index]['fieldNames'] = $builder->getSolrNamesHelper()->generateFieldNames( $column['name'] );
                $columns[$index]['sortNames'] = isset($forceAsAttributeFields[$column['name']]) ?
                    [$column['name'] => $forceAsAttributeFields[$column['name']]] :
                    $builder->getSolrNamesHelper()->generateSortNames( $column['name'] );
            }
        }

        $query['SortBy'] = array();
        foreach( $order as $orderParam ){
            $column = $columns[$orderParam['column']];            
            if ( $column['orderable'] == 'true' || $column['orderable'] === true ){                
                foreach( $column['sortNames'] as $field){
                    $query['SortBy'][$field] = $orderParam['dir'];
                }
            }
        }

        if ( !empty($search['value']) ){
            $query['_query'] = $search['value'];
        }
        
        if (isset($parameters['length'])) {
            $query['SearchLimit'] = $parameters['length'];
        }
        if (isset($parameters['start'])) {
            $query['SearchOffset'] = $parameters['start'];
        }

        return parent::filterQuery($query, $builder);
    }
        
}
