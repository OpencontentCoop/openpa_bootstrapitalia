<?php

use Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder;

class OpenPABootstrapItaliaBlockHandlerLista extends OpenPABlockHandler
{
    /**
     * @var string
     */
    protected $query;

    /**
     * @var array
     */
    protected $queryArray;

    /**
     * @var eZContentObjectTreeNode
     */
    protected $rootNode;

    protected function run()
    {
        $this->build();
        $this->data['root_node'] = $this->rootNode;        
        $this->data['fetch_parameters'] = $this->query;
        
        $content = $this->getContent();
        $this->data['has_content'] = $content['SearchCount'] > 0;
        $this->data['content'] = $content['SearchResult'];
        $this->data['search_parameters'] = $content['SearchParams'];
    }

    protected function build()
    {
        if ($this->query === null){
            $query = [];
            foreach ($this->currentCustomAttributes as $key => $value){
                if (!empty($value)){

                    if ($key == 'topic_node_id'){
                        $query['topic'] = 'raw[' . OpenPASolr::generateSolrSubMetaField('topics', 'main_node_id', 'sint') . '] in [' . $value . ']';

                    }elseif ($key == 'state_id'){
                        $query['topic'] = 'raw[' . ezfSolrDocumentFieldBase::generateMetaFieldName('object_states', 'filter') . '] in [' . $value . ']';

                    }elseif ($key == 'node_id'){
                        $query['node_id'] = 'subtree [' . $value . ']';

                    }elseif ($key == 'includi_classi'){
                        $query['classes'] = 'classes [' . $value . ']';

                    }elseif ($key == 'escludi_classi'){
                        $query['classes'] = 'class !in [' . $value . ']';

                    }elseif ($key == 'ordinamento'){
                        if ($value == 'name'){
                            $query['sort'] = 'sort [name=>asc]';
                        }elseif ($value == 'pubblicato'){
                            $query['sort'] = 'sort [published=>desc]';
                        }elseif ($value == 'modificato'){
                            $query['sort'] = 'sort [modified=>desc]';
                        }elseif ($value == 'priority'){
                            $query['sort'] = 'sort [raw[' . ObjectHandlerServiceContentVirtual::SORT_FIELD_PRIORITY . ']=>desc]';
                        }

                    }elseif ($key == 'limite'){
                    	$query['limit'] = 'limit ' . (int)$value;

                    }elseif ($key == 'livello_profondita'){
                        $query['depth'] = (int)$value;

                    }
                }
            }

            $rootNodeId = isset($this->currentCustomAttributes['node_id']) && !empty($this->currentCustomAttributes['node_id']) ?
                $this->currentCustomAttributes['node_id'] :
                eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');

            $this->rootNode = eZContentObjectTreeNode::fetch((int)$rootNodeId);
            if ($this->rootNode instanceof eZContentObjectTreeNode && isset($query['depth'])){
                $query['depth'] = 'raw[' . ezfSolrDocumentFieldBase::generateMetaFieldName('depth', 'filter') . '] range [' . ( $this->rootNode->attribute('depth') + $query['depth'] ) . ',*]';
            }

            $this->queryArray = $query;

            $this->query = implode(' and ', $this->queryArray);            
            eZDebug::writeDebug( $this->query, $this->currentBlock->attribute('type') . ' (' . $this->currentBlock->attribute('view') . '): ' . $this->currentBlock->attribute('name'));
        }

        return $this->query;
    }    

    protected function getContent()
    {
        try{
            $queryBuilder = new QueryBuilder();
            $queryObject = $queryBuilder->instanceQuery($this->query);
            $ezFindQueryObject = $queryObject->convert();

            if (!$ezFindQueryObject instanceof ArrayObject) {
                throw new \RuntimeException("Query builder did not return a valid query");
            }
            if ($ezFindQueryObject->getArrayCopy() === array("_query" => null) && !empty($this->query)){
                throw new \RuntimeException("Inconsistent query");
            }
            $ezFindQuery = $ezFindQueryObject->getArrayCopy();

            $solr = new eZSolr();
            $results = @$solr->search(
                $ezFindQuery['_query'],
                $ezFindQuery
            );
            $results['SearchParams'] = $ezFindQuery;

        }catch(Exception $e){
            eZDebug::writeError($e->getMessage(), $this->currentBlock->attribute('type') . ' (' . $this->currentBlock->attribute('view') . '): ' . $this->currentBlock->attribute('name'));
            $results = array(
                'SearchCount' => 0,
                'SearchResult' => [],
                'SearchParams' => $this->query
            );
        }

        return $results;
    }
}