<?php

use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\Values\Content;

class OpenPAReverseRelationListType extends eZDataType
{
    const DATA_TYPE_STRING = 'openpareverserelationlist';

    private $relationsListClassAttributes;

    private $language;

    private static $hasContent = array();

    private static $countContent = array();

    private static $content = array();

    public function __construct()
    {
        parent::__construct(
            self::DATA_TYPE_STRING,
            'Visualizzazione degli oggetti correlati inversi',
            array('serialize_supported' => true)
        );
        $this->language = eZLocale::currentLocaleCode();
    }

    /**
     * @param eZHTTPTool $http
     * @param string $base
     * @param eZContentClassAttribute $classAttribute
     * @return boolean true if fetching of class attributes are successfull, false if not
     */
    function fetchClassAttributeHTTPInput($http, $base, $classAttribute)
    {
        $content = (array)$classAttribute->content();
        $base = $base . '_openpareverserelationlist_';
        $store = false;        

		$sortName = $base . 'sort' . '_' . $classAttribute->attribute('id');
        if ($http->hasPostVariable($sortName)) {
            $content['sort'] = $http->postVariable($sortName);
            $store = true;
        }

        $orderName = $base . 'order' . '_' . $classAttribute->attribute('id');
        if ($http->hasPostVariable($orderName)) {
            $content['order'] = $http->postVariable($orderName);
            $store = true;
        }

        $limitName = $base . 'limit' . '_' . $classAttribute->attribute('id');
        if ($http->hasPostVariable($limitName)) {
            $content['limit'] = (int)$http->postVariable($limitName);
            $store = true;
        }

        $customQueryName = $base . 'customquery' . '_' . $classAttribute->attribute('id');
        if ($http->hasPostVariable($customQueryName)) {
            $content['custom_query'] = $http->postVariable($customQueryName);
            $store = true;
        }

        if ($store) {
            $classAttribute->setContent($content);
            $this->storeClassAttributeContent($classAttribute, $content);
            return true;
        }
		
		return false;
    }

    /**
     * @param eZHTTPTool $http
     * @param string $action
     * @param eZContentClassAttribute $classAttribute
     */
    function customClassAttributeHTTPAction($http, $action, $classAttribute)
    {
        switch ($action) {
            case 'add_attribute':
                {
                    $postName = 'RelationClassAttribute_' . $classAttribute->attribute('id');
                    $subtreePostName = 'RelationClassAttributeSubtree_' . $classAttribute->attribute('id');
                    if ($http->hasPostVariable($postName)) {
                        $attributeId = (int)$http->postVariable($postName);
                        $content = (array)$classAttribute->content();
                        $content['attribute_id_list'][] = $attributeId;
                        if ($http->hasPostVariable($subtreePostName)) {
                            $attributeIdSubtree = (int)$http->postVariable($subtreePostName);
                            $content['attribute_id_subtree'][$attributeId] = $attributeIdSubtree;
                        }
                        $classAttribute->setContent($content);
                        $this->storeClassAttributeContent($classAttribute, $content);
                    }
                }
                break;

            case 'remove_attribute':
                {
                    $postName = 'RemoveRelationClassAttribute_' . $classAttribute->attribute('id');
                    if ($http->hasPostVariable($postName)) {
                        $removeAttributeIdList = (array)$http->postVariable($postName);
                        $content = (array)$classAttribute->content();
                        $attributeIdList = array();
                        foreach ($content['attribute_id_list'] as $id) {
                            if (!in_array($id, $removeAttributeIdList)) {
                                $attributeIdList[] = $id;
                            }elseif (isset($content['attribute_id_subtree'][$id])){
                                unset($content['attribute_id_subtree'][$id]);
                            }
                        }

                        $content['attribute_id_list'] = $attributeIdList;
                        $classAttribute->setContent($content);
                        $this->storeClassAttributeContent($classAttribute, $content);
                    }
                }
                break;

            default:
                {
                    eZDebug::writeError("Unknown action '$action'", __METHOD__);
                }
                break;
        }
    }

    function classAttributeContent($classAttribute)
    {
        $relationAttributeList = $this->getRelationsListClassAttributes();
        $data = array(
            'attribute_id_list' => array(),
            'attribute_list' => array(),
            'available_class_attributes' => array(),
            'sort' => 'name',
            'order' => 'asc',
            'limit' => 4,
            'attribute_id_subtree' => [],
            'custom_query' => false,
        );
        $data = array_merge($data, (array)json_decode($classAttribute->attribute('data_text5'), true));

        foreach ($relationAttributeList as $className => $relationAttributes) {
            foreach ($relationAttributes as $relationAttribute) {
                if (in_array($relationAttribute->attribute('id'), $data['attribute_id_list'])) {
                    $data['attribute_list'][$className][$relationAttribute->attribute('id')] = $relationAttribute;
                } else {
                    $data['available_class_attributes'][$className][$relationAttribute->attribute('id')] = $relationAttribute;
                }
            }
        }

        if (empty($data['custom_query'])){
            $data['custom_query'] = false;
        }
        $data['query'] = self::composeQuery($data, '$id');

        return $data;
    }

    function storeClassAttributeContent($classAttribute, $content)
    {
    	if (is_array($content)) {
            unset($content['available_class_attributes']);
            unset($content['attribute_list']);
            $classAttribute->setAttribute('data_text5', json_encode($content));
        }
    }

    /**
     * Checks if current content object attribute has content
     * Returns true if it has content
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return bool
     * @see eZDataType::hasObjectAttributeContent()
     */
    public function hasObjectAttributeContent($contentObjectAttribute)
    {
        if (!isset(self::$hasContent[$contentObjectAttribute->attribute('id')])) {
            self::$hasContent[$contentObjectAttribute->attribute('id')] = self::fetchCount($contentObjectAttribute) > 0;
        }
        return self::$hasContent[$contentObjectAttribute->attribute('id')];
    }

    public static function fetchCount(eZContentObjectAttribute $attribute): int
    {
        if (!isset(self::$countContent[$attribute->attribute('id')])) {
            $query = self::buildQuery($attribute, 1);
            try {
                $contentSearch = new ContentSearch();
                $contentSearch->setEnvironment(new FullEnvironmentSettings());
                $data = $contentSearch->search($query);
            } catch (Exception $e) {
                $data = new stdClass();
                $data->totalCount = 0;
                eZDebug::writeError($e->getMessage(), __METHOD__);
            }

            self::$countContent[$attribute->attribute('id')] = (int)$data->totalCount;
            eZDebug::writeDebug($query, $attribute->attribute('id') . ' ' . $data->totalCount . ' ' . __METHOD__);
        }

        return self::$countContent[$attribute->attribute('id')];
    }

    /**
     * Returns the content.
     * @param eZContentObjectAttribute $objectAttribute
     * @return string
     */
    public function objectAttributeContent($objectAttribute)
    {
        $objectAttributeId = $objectAttribute->attribute('id');
        if (!isset(self::$content[$objectAttributeId])) {

            $classContent = $objectAttribute->attribute('class_content');

            $uri = eZURI::instance(eZSys::requestURI());
            if (isset($uri->UserArray[$objectAttribute->attribute('contentclass_attribute_identifier')])){
                $offset = $uri->UserArray[$objectAttribute->attribute('contentclass_attribute_identifier')];
            }else{
                $offset = 1;
            }
            $limit = $classContent['limit'];
            $query = self::buildQuery($objectAttribute, $limit, $offset);
            eZDebug::writeDebug($query, $objectAttribute->attribute('id') . ' ' . __METHOD__);

            self::$content[$objectAttributeId]['query'] = $query;
            self::$content[$objectAttributeId]['limit'] = $limit;
            self::$content[$objectAttributeId]['offset'] = $offset;
            self::$content[$objectAttributeId]['pages'] = 0;

            if (!$query) {
                self::$content[$objectAttributeId]['objects'] = array();
                self::$content[$objectAttributeId]['count'] = 0;
            } else {
                $contentSearch = new ContentSearch();
                $contentSearch->setEnvironment(new FullEnvironmentSettings());
                $data = $contentSearch->search($query);

                $contents = $data->searchHits;
                $objects = array();
                foreach ($contents as $content) {
                    try {
                        $apiContent = new Content((array)$content);
                        $language = $this->language;
                        if (!in_array($language, $apiContent->metadata->languages)){
                            $language = $apiContent->metadata->languages[0];
                        }
                        $objects[] = $apiContent->getContentObject($language);
                    } catch (Exception $e) {
                        eZDebug::writeError($e->getMessage(), __METHOD__);
                    }
                }
                self::$content[$objectAttributeId]['objects'] = $objects;
                self::$content[$objectAttributeId]['count'] = $data->totalCount;
                self::$content[$objectAttributeId]['pages'] = ceil($data->totalCount/$limit);
                self::$content[$objectAttributeId]['items_per_page'] = $limit;
            }
        }

        return self::$content[$objectAttributeId];
    }

    /**
     * @param eZContentClassAttribute $classAttribute
     * @param DOMNode $attributeNode
     * @param DOMDocument $attributeParametersNode
     */
    public function serializeContentClassAttribute(
        $classAttribute,
        $attributeNode,
        $attributeParametersNode
    )
    {
        $dom = $attributeParametersNode->ownerDocument;

        $dataKey = $classAttribute->attribute('data_text5');
        $dataKeyNode = $dom->createElement('data');
        $dataKeyNode->appendChild($dom->createTextNode($dataKey));
        $attributeParametersNode->appendChild($dataKeyNode);
    }

    /**
     * @param eZContentClassAttribute $classAttribute
     * @param DOMNode $attributeNode
     * @param DOMDocument $attributeParametersNode
     */
    public function unserializeContentClassAttribute(
        $classAttribute,
        $attributeNode,
        $attributeParametersNode
    )
    {
        $dataKey = $attributeParametersNode->getElementsByTagName('data')->item(0)->textContent;
        $classAttribute->setAttribute('data_text5', $dataKey);
    }

    public static function buildQuery($contentObjectAttribute, $limit, $offset = 0)
    {
        $data = (array)$contentObjectAttribute->attribute('class_content');

        return self::composeQuery($data, $contentObjectAttribute->attribute('contentobject_id'), $limit, $offset);
    }

    private static function composeQuery($settings, $objectId, $limit = null, $offset = 0)
    {
        if (!empty($settings['custom_query'])){
            $customQuery = str_replace('$id', $objectId, $settings['custom_query']);
            $queryParts = [$customQuery];
            if ($limit !== null) {
                $queryParts[] = 'limit ' . (int)$limit;
                $queryParts[] = 'offset ' . (int)$offset;
            }
            return implode(' and ', $queryParts);
        }
        if (count($settings['attribute_id_list']) > 0) {
            if (count($settings['attribute_list']) > 0) {
                $queryParts = array();
                $attributeQueryParts = array();
                foreach ($settings['attribute_list'] as $className => $attributes) {
                    foreach ($attributes as $attribute) {
                        if (isset($settings['attribute_id_subtree'][$attribute->attribute('id')]) && intval($settings['attribute_id_subtree'][$attribute->attribute('id')]) > 0){
                            $attributeQueryParts[] = "(raw[meta_contentclass_id_si] = " . $attribute->attribute('contentclass_id') .
                                " and " . $attribute->attribute('identifier') . ".id = " . $objectId .
                                " and raw[meta_path_si] = " . (int)$settings['attribute_id_subtree'][$attribute->attribute('id')] . ")";
                        }else{
                            $attributeQueryParts[] = "(raw[meta_contentclass_id_si] = " . $attribute->attribute('contentclass_id') .
                                " and " . $attribute->attribute('identifier') . ".id = " . $objectId . ")";
                        }
                    }
                }
                $queryParts[] = '(' . implode(' or ', $attributeQueryParts) . ')';

                $sort = $settings['sort'];
                $order = $settings['order'] == 'desc' ? 'desc' : 'asc';
                $queryParts[] = "sort [{$sort}=>{$order}]";
                if ($limit !== null) {
                    $queryParts[] = 'limit ' . (int)$limit;
                    $queryParts[] = 'offset ' . (int)$offset;
                }
                return implode(' and ', $queryParts);
            }
        }

        return false;
    }

    private function getRelationsListClassAttributes()
    {
        if ($this->relationsListClassAttributes === null) {
            $this->relationsListClassAttributes = array();
            $relationsListClassAttributes = eZContentClassAttribute::fetchFilteredList(array('data_type_string' => 'ezobjectrelationlist'));
            foreach ($relationsListClassAttributes as $relationsListClassAttribute) {
                if (!$relationsListClassAttribute instanceof eZContentClassAttribute){
                    continue;
                }
                $contentClass = eZContentClass::fetch($relationsListClassAttribute->attribute('contentclass_id'));
                if ($contentClass instanceof eZContentClass) {
                    $className = $contentClass->attribute('name');
                    $this->relationsListClassAttributes[$className][] = $relationsListClassAttribute;
                    ksort($this->relationsListClassAttributes);
                }else{
                    eZDebug::writeError('Found zoumbie relation class attribute ' . $relationsListClassAttribute->attribute('id'), __METHOD__);
                }
            }
        }

        return $this->relationsListClassAttributes;
    }

    function viewTemplate( $contentObjectAttribute )
    {
        $suffix = '';
        return $this->DataTypeString . $suffix;
    }
}

eZDataType::register(OpenPAReverseRelationListType::DATA_TYPE_STRING, 'OpenPAReverseRelationListType');
