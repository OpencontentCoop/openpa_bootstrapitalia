<?php

use Opencontent\Opendata\Api\ClassRepository;
use Opencontent\Opendata\Api\ContentSearch;

class ObjectHandlerServiceContentTrasparenza extends ObjectHandlerServiceBase
{
    const PAGINA_TRASPARENZA_CLASS = 'pagina_trasparenza';

    const NOTA_TRASPARENZA_CLASS = 'nota_trasparenza';

    const FOLDER_CLASS = 'folder';

    const BLOCKS_ATTRIBUTE = 'fields_blocks';

    const TABLE_FIELDS_ATTRIBUTE = 'fields';

    const SUGGESTED_CLASSES_ATTRIBUTE = 'suggested_classes';

    function run()
    {
        $this->fnData['has_nota_trasparenza'] = 'hasNotaTrasparenza';
        $this->fnData['nota_trasparenza'] = 'getNotaTrasparenza';

        $this->fnData['count_children_trasparenza'] = 'getCountTrasparenzaChildren';
        $this->fnData['children_trasparenza_fetch_parameters'] = 'getTrasparenzaChildrenFetchParameters';

        $this->fnData['count_children_folder'] = 'getCountFolderChildren';
        $this->fnData['children_folder_fetch_parameters'] = 'getFolderChildrenFetchParameters';

        $this->fnData['count_children'] = 'getCountChildren';
        $this->fnData['children_fetch_parameters'] = 'getChildrenFetchParameters';

        $this->fnData['has_blocks'] = 'hasBlocks';
        $this->fnData['blocks_attribute'] = 'getBlocksAttribute';

        $this->fnData['has_table_fields'] = 'hasTableFields';
        $this->fnData['table_fields_attribute'] = 'getTableFieldsAttribute';
        $this->fnData['table_fields'] = 'getTableFieldsParameters';

        $this->fnData['show_alert'] = 'showAlert';

        $this->fnData['count_children_extra'] = 'getCountExtraChildren';
        $this->fnData['children_extra_fetch_parameters'] = 'getExtraChildrenFetchParameters';
        $this->fnData['children_extra_exclude_classes'] = 'getExcludeClassesForExtraChildren';

        $this->fnData['remote_id_map'] = 'getRemoteIdMap';
    }

    protected function getRemoteIdMap()
    {
        $remoteIdMap = array(
            '5a2189cac55adf79ddfee35336e796fa' => 'rappresentazione_grafica',
            'b5df51b035ee30375db371af76c3d9fb' => 'consulenti_e_collaboratori',
            'efc995388bebdd304f19eef17aab7e0d' => 'incarichi_amministrativi_di_vertice',
            '9eed77856255692eca75cdb849540c23' => 'dirigenti',
            'c46fafba5730589c0b34a5fada7f3d07' => 'tassi_di_assenza',
            'b7286a151f027977fa080f78817c895a' => 'incarichi_conferiti',
            '90b631e882ab0f966d03aababf3d9f15' => 'atti_di_concessione',
        );

        return array_merge(
            $remoteIdMap,
            OpenPAINI::variable('Trasparenza', 'RemoteIdMap', array())
        );
    }

    protected function getRemoteIdMapItem($remoteId)
    {
        $remoteIdMap = $this->getRemoteIdMap();
        if (isset($remoteIdMap[$remoteId])) {
            return $remoteIdMap[$remoteId];
        }

        return false;
    }

    protected function isPaginaTrasparenza()
    {
        if ($this->container->hasContentNode()) {
            return $this->container->getContentNode()->attribute('class_identifier') == self::PAGINA_TRASPARENZA_CLASS;
        }

        return false;
    }

    protected function hasNotaTrasparenza()
    {
        if ($this->isPaginaTrasparenza()) {
            return $this->container->getContentNode()->subTreeCount(array(
                    'ClassFilterType' => 'include',
                    'ClassFilterArray' => array(self::NOTA_TRASPARENZA_CLASS),
                    'Depth' => 1,
                    'DepthOperator' => 'eq',
                )) > 0;
        }

        return false;
    }

    protected function getCountTrasparenzaChildren()
    {
        if ($this->isPaginaTrasparenza()) {
            return $this->container->getContentNode()->subTreeCount(array(
                'ClassFilterType' => 'include',
                'ClassFilterArray' => array(self::PAGINA_TRASPARENZA_CLASS),
                'Depth' => 1,
                'DepthOperator' => 'eq',
            ));
        }

        return false;
    }

    protected function getCountFolderChildren()
    {
        if ($this->isPaginaTrasparenza()) {
            return $this->container->getContentNode()->subTreeCount(array(
                'ClassFilterType' => 'include',
                'ClassFilterArray' => array(self::FOLDER_CLASS),
                'Depth' => 1,
                'DepthOperator' => 'eq',
            ));
        }

        return false;
    }

    protected function getCountChildren()
    {
        if ($this->isPaginaTrasparenza()) {
            $suggestedClasses = $this->getSuggestedClasses();
            if (!empty($suggestedClasses)) {
                $parameters = array(
                    'ClassFilterType' => 'include',
                    'ClassFilterArray' => $suggestedClasses,
                    'Depth' => 1,
                    'DepthOperator' => 'eq',
                );
            } else {
                $parameters = array(
                    'ClassFilterType' => 'exclude',
                    'ClassFilterArray' => array(self::PAGINA_TRASPARENZA_CLASS, self::NOTA_TRASPARENZA_CLASS, self::FOLDER_CLASS),
                    'Depth' => 1,
                    'DepthOperator' => 'eq',
                );
            }
            return $this->container->getContentNode()->subTreeCount($parameters);
        }

        return false;
    }

    protected function hasBlocks()
    {
        if ($this->isPaginaTrasparenza()) {
            return isset($this->container->attributesHandlers[self::BLOCKS_ATTRIBUTE])
                && $this->container->attributesHandlers[self::BLOCKS_ATTRIBUTE]->attribute('contentobject_attribute')->attribute('has_content');
        }

        return false;
    }

    protected function hasTableFields()
    {
        if ($this->isPaginaTrasparenza()) {
            return isset($this->container->attributesHandlers[self::TABLE_FIELDS_ATTRIBUTE])
                && $this->container->attributesHandlers[self::TABLE_FIELDS_ATTRIBUTE]->attribute('contentobject_attribute')->attribute('has_content');
        }

        return false;
    }

    protected function showAlert()
    {
        if ($this->isPaginaTrasparenza()) {
            return $this->getCountTrasparenzaChildren() == 0
                && $this->getCountChildren() == 0
                && !$this->hasNotaTrasparenza()
                && !$this->hasBlocks()
                && 'rappresentazione_grafica' !== $this->getRemoteIdMapItem($this->container->getContentObject()->attribute('remote_id'))
                && OpenPAINI::variable('Trasparenza', 'MostraAvvisoPaginaVuota', 'disabled') == 'enabled';
        }

        return false;
    }

    protected function getNotaTrasparenza()
    {
        if ($this->isPaginaTrasparenza()) {
            $children = $this->container->getContentNode()->subTree(array(
                'ClassFilterType' => 'include',
                'ClassFilterArray' => array(self::NOTA_TRASPARENZA_CLASS),
                'Depth' => 1,
                'DepthOperator' => 'eq',
                'Limit' => 1,
                'SortBy' => array('published', false)
            ));

            return isset($children[0]) ? $children[0] : false;
        }

        return false;
    }

    private function getOffset()
    {
        $uri = $GLOBALS['eZRequestedURI'];
        $userParameters = $uri instanceof eZURI ? $uri->userParameters() : array();

        return isset($userParameters['offset']) ? $userParameters['offset'] : 0;
    }

    protected function getTrasparenzaChildrenFetchParameters()
    {
        if ($this->isPaginaTrasparenza()) {
            return array(
                'parent_node_id' => $this->container->getContentNode()->attribute('node_id'),
                'class_filter_type' => 'include',
                'class_filter_array' => array(self::PAGINA_TRASPARENZA_CLASS),
                'limit' => OpenPAINI::variable('GestioneFigli', 'limite_paginazione', '25'),
                'offset' => $this->getOffset(),
                'sort_by' => $this->container->getContentNode()->attribute('sort_array')
            );
        }

        return false;
    }

    protected function getFolderChildrenFetchParameters()
    {
        if ($this->isPaginaTrasparenza()) {
            return array(
                'parent_node_id' => $this->container->getContentNode()->attribute('node_id'),
                'class_filter_type' => 'include',
                'class_filter_array' => array(self::FOLDER_CLASS),
                'limit' => OpenPAINI::variable('GestioneFigli', 'limite_paginazione', '25'),
                'offset' => $this->getOffset(),
                'sort_by' => $this->container->getContentNode()->attribute('sort_array')
            );
        }

        return false;
    }

    protected function getChildrenFetchParameters()
    {
        if ($this->isPaginaTrasparenza()) {
            $suggestedClasses = $this->getSuggestedClasses();
            if (!empty($suggestedClasses)) {
                $parameters = array(
                    'parent_node_id' => $this->container->getContentNode()->attribute('node_id'),
                    'class_filter_type' => 'include',
                    'class_filter_array' => $suggestedClasses,
                    'limit' => OpenPAINI::variable('GestioneFigli', 'limite_paginazione', '25'),
                    'offset' => $this->getOffset(),
                    'sort_by' => $this->container->getContentNode()->attribute('sort_array')
                );
            } else {
                $parameters = array(
                    'parent_node_id' => $this->container->getContentNode()->attribute('node_id'),
                    'class_filter_type' => 'exclude',
                    'class_filter_array' => array(self::PAGINA_TRASPARENZA_CLASS, self::NOTA_TRASPARENZA_CLASS, self::FOLDER_CLASS),
                    'limit' => OpenPAINI::variable('GestioneFigli', 'limite_paginazione', '25'),
                    'offset' => $this->getOffset(),
                    'sort_by' => $this->container->getContentNode()->attribute('sort_array')
                );
            }

            return $parameters;
        }

        return false;
    }

    protected function getCountExtraChildren()
    {
        if ($this->isPaginaTrasparenza()) {
            $excludeClasses = $this->getExcludeClassesForExtraChildren();
            if (is_array($excludeClasses) && count($excludeClasses) > 0) {
                return $this->container->getContentNode()->subTreeCount(array(
                    'ClassFilterType' => 'exclude',
                    'ClassFilterArray' => $excludeClasses,
                    'Depth' => 1,
                    'DepthOperator' => 'eq',
                ));
            }
        }

        return false;
    }

    protected function getExtraChildrenFetchParameters()
    {
        if ($this->isPaginaTrasparenza()) {
            $excludeClasses = $this->getExcludeClassesForExtraChildren();
            if (is_array($excludeClasses) && count($excludeClasses) > 0) {
                return array(
                    'parent_node_id' => $this->container->getContentNode()->attribute('node_id'),
                    'class_filter_type' => 'exclude',
                    'class_filter_array' => $excludeClasses,
                    'limit' => OpenPAINI::variable('GestioneFigli', 'limite_paginazione', '25'),
                    'offset' => $this->getOffset(),
                    'sort_by' => array('published', false)
                );
            }
        }

        return false;
    }

    protected function getSuggestedClasses()
    {
        $classes = array();
        if (isset($this->container->attributesHandlers[self::SUGGESTED_CLASSES_ATTRIBUTE])
            && $this->container->attributesHandlers[self::SUGGESTED_CLASSES_ATTRIBUTE]->attribute('contentobject_attribute')->attribute('has_content')) {
            $stringClasses = $this->container->attributesHandlers[self::SUGGESTED_CLASSES_ATTRIBUTE]->attribute('contentobject_attribute')->toString();
            $listClasses = explode(',', $stringClasses);
            foreach ($listClasses as $listClass) {
                $classes[] = trim($listClass);
            }
        }

        return array_unique($classes);
    }

    protected function getExcludeClassesForExtraChildren()
    {
        if ($this->isPaginaTrasparenza()) {

            $baseClasses = array(self::PAGINA_TRASPARENZA_CLASS, self::NOTA_TRASPARENZA_CLASS, self::FOLDER_CLASS);

            $excludeClasses = array();
            if ($this->hasBlocks()) {
                /** @var eZContentObjectAttribute $blockAttributeContent */
                $blockAttributeContent = $this->getBlocksAttribute()->content();
                /** @var eZPageZone $zone */
                foreach ($blockAttributeContent->attribute('zones') as $zone) {
                    /** @var eZPageBlock $block */
                    foreach ($zone->attribute('blocks') as $block) {
                        $customAttributes = $block->attribute('custom_attributes');
                        if (isset($customAttributes['class'])) {
                            $excludeClasses[] = $customAttributes['class'];
                        }
                    }
                }
            } elseif ($this->hasTableFields()) {
                $tableFieldsParameters = $this->getTableFieldsParameters();
                foreach ($tableFieldsParameters as $tableFieldsParameter) {
                    if (isset($tableFieldsParameter['class_identifier'])) {
                        $excludeClasses[] = $tableFieldsParameter['class_identifier'];
                    }
                }
            }

            $excludeClasses = array_merge($excludeClasses, $this->getSuggestedClasses());

            if (!empty($excludeClasses)) {
                $excludeClasses = array_merge($baseClasses, $excludeClasses);

                return array_unique($excludeClasses);
            }

            return array();
        }

        return false;
    }

    protected function getTableFieldsAttribute()
    {
        if ($this->isPaginaTrasparenza() && $this->hasTableFields()) {
            return $this->container->attributesHandlers[self::TABLE_FIELDS_ATTRIBUTE]->attribute('contentobject_attribute');
        }

        return false;
    }

    protected function getBlocksAttribute()
    {
        if ($this->isPaginaTrasparenza() && $this->hasBlocks()) {
            return $this->container->attributesHandlers[self::BLOCKS_ATTRIBUTE]->attribute('contentobject_attribute');
        }

        return false;
    }

    /*
     * [group_by:<identifier>|]<class>|<identifier>[,<identifier>]|<depth[&...]>
     */
    protected function getTableFieldsParameters()
    {
        if ($this->hasTableFields()) {
            $string = $this->getTableFieldsAttribute()->toString();
            $parameters = explode('&', $string);

            $data = array();
            foreach ($parameters as $parameter){
                $data[] = $this->getTableFieldsParameter($parameter);
            }

            return $data;
        }

        return array(
            array(
                'error' => "Configurazioni di visualizzazione non trovate"
            )
        );
    }

    protected function getTableFieldsParameter($string)
    {
        $index = 0;
        $fieldsParts = explode('|', $string);
        $facetField = null;
        if (strpos($fieldsParts[0], 'group_by') === 0) {
            $index = 1;
            $groupParts = explode(':', $fieldsParts[0]);
            $facetField = $groupParts[1];
        }

        $classIdentifier = $fieldsParts[$index];
        $index++;

        $identifiers = explode(',', $fieldsParts[$index]);
        $index++;

        $depth = isset($fieldsParts[$index]) ? $fieldsParts[$index] : false;

        $facets = array();

        try {
            $classRepository = new ClassRepository();
            $class = (array)$classRepository->load($classIdentifier);

            $classFields = array();
            foreach ($identifiers as $identifier) {
                $identifierParts = explode('.', $identifier);
                foreach ($class['fields'] as $field) {
                    if ($field['identifier'] == $identifierParts[0]) {
                        if ($field['dataType'] == 'ezmatrix' && isset($identifierParts[1])) {
                            $field['matrix_column'] = $identifierParts[1];
                        }
                        $classFields[] = $field;
                    }
                }
            }

            $node = $this->container->getContentNode();
            $nodeId = $node->attribute('node_id');

            $depthQueryPart = '';
            if (is_numeric($depth)) {
                $nodeDepth = (int)$node->attribute('depth');
                $queryDepth = $nodeDepth + $depth;
                $depthQueryPart = "raw[meta_depth_si] range [{$nodeDepth},{$queryDepth}] and ";
            }

            $query = "{$depthQueryPart} classes [{$classIdentifier}] subtree [{$nodeId}]";
            $facetQuery = null;
            if ($facetField) {
                $contentSearch = new ContentSearch();
                $contentSearch->setEnvironment(new DefaultEnvironmentSettings());
                $facetQuery = $query . " limit 1 facets [{$facetField}|alpha|100]";
                $facetSearch = $contentSearch->search($facetQuery);
                $facets = array();
                if (isset($facetSearch->facets[0]['data'])) {
                    foreach ($facetSearch->facets[0]['data'] as $key => $value) {
                        $facetKey = $key;
                        if (strpos($facetField, 'year____dt') !== false) {
                            $facetKey = str_replace('-01-01T00:00:00Z', '', $key);
                        }
                        $facets[] = $facetKey;
                    }
                    if (strpos($facetField, 'dt') !== false || $facetField == 'anno') {
                        $facets = array_reverse($facets);
                    }
                }
            }

            return array(
                'query' => $query,
                'facet_query' => $facetQuery,
                'class_fields' => $classFields,
                'group_by' => $facetField,
                'class_identifier' => $classIdentifier,
                'facets' => $facets,
            );


        } catch (Exception $e) {
            $class = null;
            $error = $e->getMessage();

            return array(
                'error' => $error
            );
        }
    }

}
