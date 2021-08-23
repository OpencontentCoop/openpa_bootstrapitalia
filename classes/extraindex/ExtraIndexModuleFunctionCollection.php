<?php


class ExtraIndexModuleFunctionCollection
{
    /**
     * Search function
     *
     * @param string Query string
     * @param int Offset
     * @param int Limit
     * @param array Facet definition
     * @param array Filter parameters
     * @param array Sort by parameters
     * @param mixed Content class ID or list of content class IDs
     * @param array list of subtree limitation node IDs
     * @param boolean $enableElevation Controls whether elevation should be enabled or not
     * @param boolean $forceElevation Controls whether elevation is forced. Applies when the srt criteria is NOT the default one ( 'score desc' ).
     *
     * @return array Search result
     */
    public function searchWithExternalData($query, $offset = 0, $limit = 10, $facets = null,
                           $filters = null, $sortBy = null, $classID = null, $sectionID = null,
                           $subtreeArray = null, $ignoreVisibility = null, $limitation = null, $asObjects = true, $spellCheck = null, $boostFunctions = null, $queryHandler = 'ezpublish',
                           $enableElevation = true, $forceElevation = false, $publishDate = null, $distributedSearch = null, $fieldsToReturn = null, $searchResultClustering = null, $extendedAttributeFilter = array())
    {
        $solrSearch = new eZSolrExternalDataAware();
        $params = array(
            'SearchOffset' => $offset,
            'SearchLimit' => $limit,
            'Facet' => $facets,
            'SortBy' => $sortBy,
            'Filter' => $filters,
            'SearchContentClassID' => $classID,
            'SearchSectionID' => $sectionID,
            'SearchSubTreeArray' => $subtreeArray,
            'AsObjects' => $asObjects,
            'SpellCheck' => $spellCheck,
            'IgnoreVisibility' => $ignoreVisibility,
            'Limitation' => $limitation,
            'BoostFunctions' => $boostFunctions,
            'QueryHandler' => $queryHandler,
            'EnableElevation' => $enableElevation,
            'ForceElevation' => $forceElevation,
            'SearchDate' => $publishDate,
            'DistributedSearch' => $distributedSearch,
            'FieldsToReturn' => $fieldsToReturn,
            'SearchResultClustering' => $searchResultClustering,
            'ExtendedAttributeFilter' => $extendedAttributeFilter
        );
        return array('result' => $solrSearch->search($query, $params));
    }
}