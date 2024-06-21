<?php

use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\ContentSearch;

class OpenPABootstrapItaliaBlockHandlerListaPaginata extends OpenPABootstrapItaliaBlockHandlerLista
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
     * @var array
     */
    protected $facets;

    /**
     * @var eZContentObjectTreeNode
     */
    protected $rootNode;

    protected $subTreeFilter = 'raw[meta_path_si]';

    protected $totalCount = 0;

    private static $cache = [];

    protected function run()
    {
        if (!isset(self::$cache[$this->currentBlock->id()])) {
            $this->build();
            $this->data['root_node'] = $this->rootNode;
            $this->data['query'] = $this->query;
            $this->data['tree_facets'] = $this->getTreeFacets();
            $this->data['has_content'] = $this->totalCount;
            $this->data['subtree_facet_filter'] = $this->subTreeFilter;
            $this->data['limit'] = isset($this->currentCustomAttributes['limite']) ? (int)$this->currentCustomAttributes['limite'] : 5;
            self::$cache[$this->currentBlock->id()] = $this->data;
        } else {
            $this->data = self::$cache[$this->currentBlock->id()];
        }
    }

    protected function build()
    {
        if ($this->query === null) {
            $query = [];
            foreach ($this->currentCustomAttributes as $key => $value) {
                if (!empty($value)) {

                    if ($key == 'topic_node_id') {
                        $query['topic'] = 'raw[' . OpenPASolr::generateSolrSubMetaField('topics', 'main_node_id', 'sint') . '] in [' . $value . ']';

                    } elseif ($key == 'state_id') {
                        $query['state'] = 'raw[' . ezfSolrDocumentFieldBase::generateMetaFieldName('object_states', 'filter') . '] in [' . $value . ']';

                    } elseif ($key == 'node_id') {
                        $query['subtree'] = 'subtree [' . $value . ']';

                    } elseif ($key == 'includi_classi') {
                        $query['classes'] = 'classes [' . $value . ']';

                    } elseif ($key == 'tags') {
                        $query['tags'] = $this->getTagQuery($value);

                    } elseif ($key == 'ordinamento') {
                        if ($value == 'name') {
                            $query['sort'] = 'sort [name=>asc]';
                        } elseif ($value == 'pubblicato') {
                            $query['sort'] = 'sort [published=>desc,raw[meta_main_node_id_si]=>desc]';
                        } elseif ($value == 'modificato') {
                            $query['sort'] = 'sort [modified=>desc]';
                        }
                    }
                }
            }

            $rootNodeId = isset($this->currentCustomAttributes['node_id']) && !empty($this->currentCustomAttributes['node_id']) ?
                $this->currentCustomAttributes['node_id'] :
                eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');

            $this->rootNode = eZContentObjectTreeNode::fetch((int)$rootNodeId);
            if ($this->rootNode instanceof eZContentObjectTreeNode) {
                $query[] = 'raw[' . ezfSolrDocumentFieldBase::generateMetaFieldName('depth', 'filter') . '] range [' . ($this->rootNode->attribute('depth') + 1) . ',*]';
            }

            $this->queryArray = $query;

            $this->query = implode(' and ', $this->queryArray);
            eZDebug::writeDebug($this->query, $this->currentBlock->attribute('type') . ' (' . $this->currentBlock->attribute('view') . '): ' . $this->currentBlock->attribute('name'));
        }

        return $this->query;
    }

    protected function getTreeFacets()
    {
        if ($this->facets === null) {
            $this->build();

            $contentSearch = new ContentSearch();
            $currentEnvironment = EnvironmentLoader::loadPreset('content');
            $contentSearch->setEnvironment($currentEnvironment);
            $parser = new ezpRestHttpRequestParser();
            $request = $parser->createRequest();
            $currentEnvironment->__set('request', $request);

            $queryArray = $this->queryArray;
            $queryArray['limit'] = 'limit 1';
            $query = implode(' and ', $queryArray) . ' facets [' . $this->subTreeFilter . '|count,raw[meta_class_identifier_ms]]';

            $data = (array)$contentSearch->search($query);

            $this->totalCount = $data['totalCount'];
            $facets = array(
                'subtree' => array(),
                'class_identifier' => array(),
            );
            foreach ($data['facets'] as $facet) {
                if ($facet['name'] == $this->subTreeFilter) {
                    $facets['subtree'] = array_keys($facet['data']);
                }
                if ($facet['name'] == 'raw[meta_class_identifier_ms]') {
                    $facets['class_identifier'] = array_keys($facet['data']);
                }
            }

            $this->facets = $facets;
        }

        return $this->facets;
    }
}
