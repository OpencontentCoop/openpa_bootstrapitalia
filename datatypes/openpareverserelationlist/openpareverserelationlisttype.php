<?php

use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\Values\Content;

class OpenPAReverseRelationListType extends eZDataType
{
    const DATA_TYPE_STRING = 'openpareverserelationlist';

    private $relationsListClassAttributes;

    private $language;

    private static $hasContent = array();

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
     * @return true if fetching of class attributes are successfull, false if not
     */
    function fetchClassAttributeHTTPInput($http, $base, $classAttribute)
    {
        $content = $classAttribute->content();
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

        if ($store) {            
            $classAttribute->setContent($content);
            $this->storeClassAttributeContent($classAttribute, $content);
            return true;
        }
		
		return false;        
    }

    /**
     * @param eZHTTPTool $http
     * @param string $base
     * @param eZContentClassAttribute $classAttribute
     */
    function customClassAttributeHTTPAction($http, $action, $classAttribute)
    {
        switch ($action) {
            case 'add_attribute':
                {
                    $postName = 'RelationClassAttribute_' . $classAttribute->attribute('id');
                    if ($http->hasPostVariable($postName)) {
                        $attributeId = (int)$http->postVariable($postName);
                        $content = $classAttribute->content();
                        $content['attribute_id_list'][] = $attributeId;
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
                        $content = $classAttribute->content();
                        $attributeIdList = array();
                        foreach ($content['attribute_id_list'] as $id) {
                            if (!in_array($id, $removeAttributeIdList)) {
                                $attributeIdList[] = $id;
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

            $query = $this->buildQuery($contentObjectAttribute, 1);
            eZDebug::writeDebug($query, __METHOD__);

            if (!$query) {
                self::$hasContent[$contentObjectAttribute->attribute('id')] = false;
            } else {
                try {
                    $contentSearch = new ContentSearch();
                    $contentSearch->setEnvironment(new FullEnvironmentSettings());

                    $data = (array)$contentSearch->search($query);

                    self::$hasContent[$contentObjectAttribute->attribute('id')] = $data['totalCount'] > 0;
                } catch (Exception $e) {

                    eZDebug::writeError($e->getMessage(), __METHOD__);
                    self::$hasContent[$contentObjectAttribute->attribute('id')] = false;
                }
            }
        }

        return self::$hasContent[$contentObjectAttribute->attribute('id')];
    }

    /**
     * Returns the content.
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return string
     */
    public function objectAttributeContent($contentObjectAttribute)
    {
        if (!isset(self::$content[$contentObjectAttribute->attribute('id')])) {

            $classContent = $contentObjectAttribute->attribute('class_content');

            $uri = eZURI::instance(eZSys::requestURI());
            if (isset($uri->UserArray[$contentObjectAttribute->attribute('contentclass_attribute_identifier')])){
            	$currentPage = $uri->UserArray[$contentObjectAttribute->attribute('contentclass_attribute_identifier')];
            }else{
            	$currentPage = 1;
            }
            $limit = $classContent['limit'];
            $offset = $currentPage == 1 ? 0 : $limit * ($currentPage - 1);
            $query = $this->buildQuery($contentObjectAttribute, $limit, $offset);

            self::$content[$contentObjectAttribute->attribute('id')]['query'] = $query;
            self::$content[$contentObjectAttribute->attribute('id')]['limit'] = $limit;
            self::$content[$contentObjectAttribute->attribute('id')]['offset'] = $offset;
            self::$content[$contentObjectAttribute->attribute('id')]['pages'] = 0;
            self::$content[$contentObjectAttribute->attribute('id')]['current_page'] = $currentPage;

            if (!$query) {
                self::$content[$contentObjectAttribute->attribute('id')]['objects'] = array();
                self::$content[$contentObjectAttribute->attribute('id')]['count'] = 0;
            } else {
                $contentSearch = new ContentSearch();
                $contentSearch->setEnvironment(new FullEnvironmentSettings());
                $data = $contentSearch->search($query);

                $contents = $data->searchHits;
                $objects = array();
                foreach ($contents as $content) {
                    try {
                        $apiContent = new Content($content);
                        $language = $this->language;
                        if (!in_array($language, $apiContent->metadata->languages)){
                            $language = $apiContent->metadata->languages[0];
                        }
                        $objects[] = $apiContent->getContentObject($language);
                    } catch (Exception $e) {
                        eZDebug::writeError($e->getMessage(), __METHOD__);
                    }
                }
                self::$content[$contentObjectAttribute->attribute('id')]['objects'] = $objects;
                self::$content[$contentObjectAttribute->attribute('id')]['count'] = $data->totalCount;
                self::$content[$contentObjectAttribute->attribute('id')]['pages'] = ceil($data->totalCount/$limit);
            }
        }

        return self::$content[$contentObjectAttribute->attribute('id')];
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

        $data = $classAttribute->attribute('data_text5');
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

    private function buildQuery($contentObjectAttribute, $limit, $offset = 0)
    {
        $data = $contentObjectAttribute->attribute('class_content');
        if (count($data['attribute_id_list']) > 0) {
            if (count($data['attribute_list']) > 0) {
                $queryParts = array();
                $attributeQueryParts = array();
                foreach ($data['attribute_list'] as $className => $attributes) {
                    foreach ($attributes as $attribute) {
                        $attributeQueryParts[] = "(raw[meta_contentclass_id_si] = " . $attribute->attribute('contentclass_id') . " and " . $attribute->attribute('identifier') . ".id = " . $contentObjectAttribute->attribute('contentobject_id') . ")";
                    }
                }
                $queryParts[] = '(' . implode(' or ', $attributeQueryParts) . ')';

                $sort = $data['sort'];
                $order = $data['order'] == 'desc' ? 'desc' : 'asc';
                $queryParts[] = "sort [{$sort}=>{$order}]";
                $queryParts[] = 'limit ' . $limit;
                $queryParts[] = 'offset ' . $offset;

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
}

eZDataType::register(OpenPAReverseRelationListType::DATA_TYPE_STRING, 'OpenPAReverseRelationListType');
