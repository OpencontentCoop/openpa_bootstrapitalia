<?php

class OpenPARoleType extends eZDataType
{
    const DATA_TYPE_STRING = 'openparole';

    const ROOT_TAG = 'Persone/Ruoli';

    const SELECT_PERSON = 1;
    const SELECT_ENTITY = 2;

    const SORT_PERSON_NAME = 1;
    const SORT_ENTITY_NAME = 2;
    const SORT_ROLE_NAME = 3;

    const SORT_START_TIME = 4;

    const FETCH_LIMIT = 500;

    private static $timeIndexedRolePersonClassAttribute;

    public function __construct()
    {
        parent::__construct(
            self::DATA_TYPE_STRING,
            'Ruolo OpenPA',
            array('serialize_supported' => true)
        );
    }

    /**
     * @param eZHTTPTool $http
     * @param string $base
     * @param eZContentClassAttribute $classAttribute
     * @return true if fetching of class attributes are successfull, false if not
     */
    function fetchClassAttributeHTTPInput($http, $base, $classAttribute)
    {
        $data = $this->getEmptyClassAttributeContent();
        $base = $base . '_openparole_';
        $store = false;

        $selectName = $base . 'select' . '_' . $classAttribute->attribute('id');
        if ($http->hasPostVariable($selectName)) {
            $data['select'] = (int)$http->postVariable($selectName);
            $store = true;
        }

        $viewName = $base . 'view' . '_' . $classAttribute->attribute('id');
        if ($http->hasPostVariable($viewName)) {
            $data['view'] = (int)$http->postVariable($viewName);
            $store = true;
        }

        $sortName = $base . 'sort' . '_' . $classAttribute->attribute('id');
        if ($http->hasPostVariable($sortName)) {
            $data['sort'] = (int)$http->postVariable($sortName);
            $store = true;
        }

        $filterName = $base . 'filter' . '_' . $classAttribute->attribute('id');
        if ($http->hasPostVariable($filterName)) {
            $data['filter'] = $http->postVariable($filterName);
            $store = true;
        }

        if ($store) {
            $classAttribute->setContent($data);
            $classAttribute->setAttribute('data_text5', json_encode($data));
        }

        return true;
    }

    function classAttributeContent($classAttribute)
    {
        return (array)json_decode($classAttribute->attribute('data_text5'), true);
    }

    public function initializeClassAttribute($classAttribute)
    {
        if ($classAttribute->attribute('data_text5') == '') {
            $classAttribute->setAttribute('data_text5', json_encode($this->getEmptyClassAttributeContent()));
        }
        $classAttribute->store();
    }

    function initializeObjectAttribute($contentObjectAttribute, $currentVersion, $originalContentObjectAttribute)
    {
        if ($currentVersion != false) {
            $dataText = $originalContentObjectAttribute->attribute("data_text");
            $contentObjectAttribute->setAttribute("data_text", $dataText);
        } else {
            $contentObjectAttribute->setAttribute('data_text', json_encode(['pagination' => 6]));
        }
    }

    /**
     * Fetches all variables from the object and handles them
     * Data store can be done here
     * @param eZHTTPTool $http
     * @param string $base POST variable name prefix (Always "ContentObjectAttribute")
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return boolean if fetching of class attributes are successfull, false if not
     */
    public function fetchObjectAttributeHTTPInput($http, $base, $contentObjectAttribute)
    {
        $paginationVarName = "{$base}_openparole_pagination_" . $contentObjectAttribute->attribute('id');
        $filtersVarName = "{$base}_openparole_filters_" . $contentObjectAttribute->attribute('id');
        $sortVarName = "{$base}_openparole_sort_" . $contentObjectAttribute->attribute('id');
        if ($http->hasPostVariable($paginationVarName)
            || $http->hasPostVariable($filtersVarName)
            || $http->hasPostVariable($sortVarName)){
            $settings = (array)json_decode($contentObjectAttribute->attribute('data_text'), true);
            if ($http->hasPostVariable($paginationVarName)) {
                $pagination = (int)$http->postVariable($paginationVarName);
                $settings['pagination'] = $pagination;
            }
            if ($http->hasPostVariable($filtersVarName)) {
                $filters = $http->postVariable($filtersVarName);
                $settings['filters'] = $filters;
            }else{
                $settings['filters'] = [];
            }
            if ($http->hasPostVariable($sortVarName)) {
                $sort = $http->postVariable($sortVarName);
                $settings['sort'] = $sort;
            }else{
                $settings['sort'] = null;
            }
            $contentObjectAttribute->setAttribute('data_text', json_encode($settings));
            $contentObjectAttribute->store();

            return true;
        }

        return false;
    }

    function fromString($objectAttribute, $string)
    {
        if (is_numeric($string)) {
            $objectAttribute->setAttribute('data_text', json_encode(['pagination' => (int)$string]));
            $objectAttribute->store();
        }
    }

    /**
     * Deletes $objectAttribute datatype data, optionally in version $version.
     *
     * @param eZContentObjectAttribute $objectAttribute
     * @param int $version
     */
    public function deleteStoredObjectAttribute($objectAttribute, $version = null)
    {
        //@todo eliminare i ruoli?
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
        return OpenPARoles::instance($contentObjectAttribute)->hasContent();
    }

    /**
     * Returns the content.
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return OpenPARoles
     */
    public function objectAttributeContent($contentObjectAttribute)
    {
        return OpenPARoles::instance($contentObjectAttribute);
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
        $dataKeyNode->appendChild($dom->createTextNode($data));
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

    private function getEmptyClassAttributeContent()
    {
        return array(
            'roletype_root_tag' => self::ROOT_TAG,
            'select' => 0,
            'view' => 0,
            'filter' => array(),
            'sort' => 0,
        );
    }

    function isIndexable()
    {
        return true;
    }

    /**
     * @param eZContentObjectAttribute $attribute
     * @return string|void
     */
    function metaData($attribute)
    {
        $data = [];
        $classAttribute = $this->getTimeIndexedRolePersonClassAttribute();
        if ($classAttribute instanceof eZContentClassAttribute){
            /** @var array $classContent */
            $classContent = $classAttribute->content();
            if (isset($classContent['class_constraint_list'])
                && in_array($attribute->object()->attribute('class_identifier'), $classContent['class_constraint_list'])){
                $roles = $attribute->object()->reverseRelatedObjectList(false, $classAttribute->attribute('id'));
                foreach ($roles as $role){
                    $dataMap = $role->dataMap();
                    $data[] = $role->attribute('name');
                    if (isset($dataMap['label']) && $dataMap['label'] instanceof eZContentObjectAttribute
                        && $dataMap['label']->hasContent()){
                        $data[] = $dataMap['label']->toString();
                    }
                }
            }
        }

        return implode(', ', $data);
    }

    private function getTimeIndexedRolePersonClassAttribute()
    {
        if (self::$timeIndexedRolePersonClassAttribute === null) {
            self::$timeIndexedRolePersonClassAttribute = false;
            $class = eZContentClass::fetchByIdentifier('time_indexed_role');
            if ($class instanceof eZContentClass) {
                /** @var eZContentClassAttribute $classAttribute */
                foreach ($class->dataMap() as $classAttribute) {
                    if ($classAttribute->attribute('identifier') == 'person') {
                        self::$timeIndexedRolePersonClassAttribute = $classAttribute;
                    }
                }
            }
        }

        return self::$timeIndexedRolePersonClassAttribute;
    }
}

eZDataType::register(OpenPARoleType::DATA_TYPE_STRING, 'OpenPARoleType');
