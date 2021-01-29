<?php

use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\Values\Content;

class OpenPARoleType extends eZDataType
{
    const DATA_TYPE_STRING = 'openparole';

    const ROOT_TAG = 'Persone/Ruoli';

    const SELECT_PERSON = 1;
    const SELECT_ENTITY = 2;

    const SORT_PERSON_NAME = 1;
    const SORT_ENTITY_NAME = 2;
    const SORT_TYPE = 3;

    const FETCH_LIMIT = 500;

    private $language;

    private static $hasContent;

    private static $content;

    private static $timeIndexedRolePersonClassAttribute;

    public function __construct()
    {
        parent::__construct(
            self::DATA_TYPE_STRING,
            'Ruolo OpenPA',
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

    /**
     * Fetches all variables from the object and handles them
     * Data store can be done here
     * @param eZHTTPTool $http
     * @param string $base POST variable name prefix (Always "ContentObjectAttribute")
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return true if fetching of class attributes are successfull, false if not
     */
    public function fetchObjectAttributeHTTPInput($http, $base, $contentObjectAttribute)
    {
        return true;
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
        if (!isset(self::$hasContent[$contentObjectAttribute->attribute('id')])){
            try {
                $contentSearch = new ContentSearch();
                $contentSearch->setEnvironment(new FullEnvironmentSettings());
                eZDebug::writeDebug($this->buildQuery($contentObjectAttribute, 1), __METHOD__);
                $data = (array)$contentSearch->search($this->buildQuery($contentObjectAttribute, 1));

                self::$hasContent[$contentObjectAttribute->attribute('id')] = $data['totalCount'] > 0;
            } catch (Exception $e) {

                eZDebug::writeError($e->getMessage(), __METHOD__);
                self::$hasContent[$contentObjectAttribute->attribute('id')] = false;
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
        if (!isset(self::$content[$contentObjectAttribute->attribute('id')])){
            $contentSearch = new ContentSearch();
            $contentSearch->setEnvironment(new FullEnvironmentSettings(['maxSearchLimit' => self::FETCH_LIMIT]));
            try {
                $data = $contentSearch->search($this->buildQuery($contentObjectAttribute, self::FETCH_LIMIT));
            }catch (Exception $e){
                $data = new stdClass();
                $data->searchHits = [];
                eZDebug::writeError($e->getMessage(), __METHOD__);
            }

            $classContent = $contentObjectAttribute->attribute('class_content');
            $sort = $classContent['sort'];
            $contents = $this->sortContents($data->searchHits, $sort);
            $roles = array();
            $rolesPerPerson = array();
            $rolesPerEntity = array();
            $typePerEntities = array();
            $people = [];
            $entities = [];
            foreach ($contents as $content) {
                try {
                    $apiContent = new Content($content);
                    $language = $this->language;
                    if (!in_array($language, $apiContent->metadata->languages)){
                        $language = $apiContent->metadata->languages[0];
                    }
                    $role = $apiContent->getContentObject($language);
                    foreach ($apiContent->data[$language]['person']['content'] as $person) {
                        if (!isset($people[$person['id']])) {
                            $people[$person['id']] = eZContentObject::fetch((int)$person['id']);
                        }
                        $rolesPerPerson[$person['id']][] = $role;
                    }
                    $type = implode(', ', $apiContent->data[$language]['role']['content']);
                    foreach ($apiContent->data[$language]['for_entity']['content'] as $entity) {
                        if (!isset($entities[$entity['id']])) {
                            $entities[$entity['id']] = eZContentObject::fetch((int)$entity['id']);
                        }
                        $rolesPerEntity[$entity['id']][] = $role;
                        if (isset($apiContent->data[$language]['ruolo_principale']['content'])
                            && $apiContent->data[$language]['ruolo_principale']['content']) {
                            $typePerEntities[$type][$entity['id']] = $entities[$entity['id']] instanceof eZContentObject ?
                                $entities[$entity['id']]->attribute('name') :
                                $entity['name'][$language];
                        }
                    }
                    $roles[] = $role;
                } catch (Exception $e) {
                    eZDebug::writeError($e->getMessage(), __METHOD__);
                }
            }

            self::$content[$contentObjectAttribute->attribute('id')] = [
                'roles' => $roles,
                'roles_per_person' => $rolesPerPerson,
                'roles_per_entity' => $rolesPerEntity,
                'people' => $people,
                'entities' => $entities,
                'main_type_per_entities' => $typePerEntities,
            ];
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

    private function buildQuery($contentObjectAttribute, $limit = 1)
    {
        $queryParts = array();
        $data = $contentObjectAttribute->attribute('class_content');

        $queryParts[] = "classes [time_indexed_role]";
        $queryParts[] = "subtree [" . OpenPABootstrapItaliaOperators::getOpenpaRolesParentNodeId() . "]";

        if ($data['select'] == self::SELECT_PERSON) {
            $queryParts[] = "person.id = " . $contentObjectAttribute->attribute('contentobject_id');
        } elseif ($data['select'] == self::SELECT_ENTITY) {
            $queryParts[] = "for_entity.id = " . $contentObjectAttribute->attribute('contentobject_id');
        } else {
            throw new Exception("La configurazione dell'attributo openpa role non è valida", 1);
        }

        if (!empty($data['filter'])) {
            $filterList = [];
            foreach ($data['filter'] as $filter){
                $filterList[] = addcslashes($filter, "')(][");
            }
            $queryParts[] = "role in ['\"" . implode("\"','\"", $filterList) . "\"']";
        }

        $queryParts[] = 'calendar[start_time,end_time] = [now,*]';
        $queryParts[] = 'sort [raw[attr_priorita_si]=>desc,person.name=>asc]';
        $queryParts[] = 'limit ' . (int)$limit;

        return implode(' and ', $queryParts);
    }

    private function sortContents($contents, $sortValue)
    {
        if (count($contents) > 1) {
            $attributeIdentifier = false;
            if ($sortValue == self::SORT_ENTITY_NAME) {
                $attributeIdentifier = 'for_entity';
            } elseif ($sortValue == self::SORT_PERSON_NAME) {
                $attributeIdentifier = 'person';
            } /*elseif ($sortValue == self::SORT_TYPE) {
                $attributeIdentifier = 'role';
            }*/
            if ($attributeIdentifier) {
                $language = $this->language;
                usort($contents, function ($a, $b) use ($attributeIdentifier, $language) {
                    $aLanguage = $language;
                    if (!in_array($language, $a['metadata']['languages'])){
                        $aLanguage = $a['metadata']['languages'][0];
                    }
                    $bLanguage = $language;
                    if (!in_array($language, $b['metadata']['languages'])){
                        $bLanguage = $a['metadata']['languages'][0];
                    }

                    if ($attributeIdentifier !== 'role'
                        && isset($a['data'][$aLanguage][$attributeIdentifier]['content'][0]['name'])
                        && isset($b['data'][$bLanguage][$attributeIdentifier]['content'][0]['name'])
                    ) {
                        $aName = isset($a['data'][$aLanguage][$attributeIdentifier]['content'][0]['name'][$aLanguage]) ?
                            $a['data'][$aLanguage][$attributeIdentifier]['content'][0]['name'][$aLanguage] :
                            current($a['data'][$aLanguage][$attributeIdentifier]['content'][0]['name']);
                        $bName = isset($b['data'][$bLanguage][$attributeIdentifier]['content'][0]['name'][$bLanguage]) ?
                            $b['data'][$bLanguage][$attributeIdentifier]['content'][0]['name'][$bLanguage] :
                            current($b['data'][$bLanguage][$attributeIdentifier]['content'][0]['name']);

                        return strcmp($aName, $bName);
                    } elseif (isset($a['data'][$aLanguage][$attributeIdentifier]['content'][0])
                        && isset($b['data'][$bLanguage][$attributeIdentifier]['content'][0])
                    ) {
                        return strcmp(
                            $a['data'][$aLanguage][$attributeIdentifier]['content'][0],
                            $b['data'][$bLanguage][$attributeIdentifier]['content'][0]
                        );
                    }

                    return 0;
                });
            }
        }

        return $contents;
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
        $definition = $attribute->attribute('class_content');
        $classAttribute = $this->getTimeIndexedRolePersonClassAttribute();
        if ($classAttribute instanceof eZContentClassAttribute){
            /** @var array $classContent */
            $classContent = $classAttribute->content();
            if (isset($classContent['class_constraint_list'])
                && in_array($attribute->object()->attribute('class_identifier'), $classContent['class_constraint_list'])){
                $roles = $attribute->object()->reverseRelatedObjectList(false, $classAttribute->attribute('id'));
                foreach ($roles as $role){
                    if (!empty($definition['filter'])) {
                        $dataMap = $role->dataMap();
                        if (isset($dataMap['role']) && $dataMap['role']->hasContent()){
                            $roleContent = $dataMap['role']->content();
                            if ($roleContent instanceof eZTags) {
                                foreach ($roleContent->attribute('keywords') as $keyword) {
                                    if (in_array($keyword, $definition['filter'])) {
                                        $data[] = $role->attribute('name');
                                    }
                                }
                            }
                        }
                    }else {
                        $data[] = $role->attribute('name');
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
