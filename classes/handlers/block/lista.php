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

    private static $cache = [];

    protected function run()
    {
        if (!isset(self::$cache[$this->currentBlock->id()])) {
            $this->build();
            $this->data['root_node'] = $this->rootNode;
            $this->data['fetch_parameters'] = $this->query;

            $content = $this->getContent();
            $this->data['has_content'] = $content['SearchCount'] > 0;
            $this->data['content'] = $content['SearchResult'];
            $this->data['search_parameters'] = $content['SearchParams'];
            self::$cache[$this->currentBlock->id()] = $this->data;
        }else{
            $this->data = self::$cache[$this->currentBlock->id()];
        }
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
                        $query['state'] = 'raw[' . ezfSolrDocumentFieldBase::generateMetaFieldName('object_states', 'filter') . '] in [' . $value . ']';

                    }elseif ($key == 'node_id'){
                        $query['node_id'] = 'subtree [' . $value . '] and raw[meta_node_id_si] != \'' . $value . '\'';

                    }elseif ($key == 'includi_classi'){
                        $query['classes'] = 'classes [' . $value . ']';

                    }elseif ($key == 'escludi_classi'){
                        $query['classes'] = 'class !in [' . $value . ']';

                    }elseif ($key == 'tags'){
                        $query['tags'] = $this->getTagQuery($value);

                    }elseif ($key == 'ordinamento'){
                        if ($value == 'name'){
                            $query['sort'] = 'sort [name=>asc]';
                        }elseif ($value == 'pubblicato'){
                            $query['sort'] = 'sort [published=>desc,raw[meta_main_node_id_si]=>desc]';
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
            if ($this->rootNode instanceof eZContentObjectTreeNode && isset($query['depth']) && (int)$query['depth'] > 0){
                $startDepth = (int)$this->rootNode->attribute('depth');
                $depth = $startDepth + (int) $query['depth'];
                $query['depth'] = 'raw[' . ezfSolrDocumentFieldBase::generateMetaFieldName('depth', 'filter') . '] range [' . $startDepth . ',' . $depth . ']';
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

            $env = new OpenPABootstrapItaliaContentEnvironmentSettings();
            $ezFindQueryObject = $env->filterQuery($ezFindQueryObject, $queryBuilder);
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

    protected function getTagQuery($value)
    {
        if (!empty($value)){
            $tagUrls = explode(',', $value);
            $tagIdList = [];
            foreach ($tagUrls as $tagUrl) {
                if (is_numeric($tagUrl)){
                    $tag = eZTagsObject::fetch((int)$tagUrl);
                }else {
                    $tag = eZTagsObject::fetchByUrl($tagUrl);
                    if (!$tag instanceof eZTagsObject){
                        $tagUrl = $this->fixSlashedTagName((string)$tagUrl);
                        $tag = eZTagsObject::fetchByUrl($tagUrl);
                    }
                    if (!$tag instanceof eZTagsObject){
                        $tag = eZTagsObject::fetchByUrl($tagUrl, true);
                    }
                }
                if ($tag instanceof eZTagsObject){
                    $tagIdList[] = $tag->attribute('id');
                }
            }
            if (count($tagIdList) > 0){
                return 'raw[ezf_df_tag_ids] in [' . implode(',', $tagIdList) . ']';
            }
        }

        return '';
    }

    private function fixSlashedTagName(string $tagUrl): string
    {
        $slashedKeyword = eZDB::instance()
            ->arrayQuery("SELECT keyword, REPLACE(keyword, '/', '%2F') AS keyword_encoded FROM eztags_keyword WHERE keyword LIKE '%/%' AND locale != 'ita-PA';");
        $search = array_column($slashedKeyword, 'keyword');
        $replace = array_column($slashedKeyword, 'keyword_encoded');

        return str_replace($search, $replace, $tagUrl);
    }
}
