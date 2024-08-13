<?php

use Opencontent\Opendata\Api\ContentSearch;

class OpenPARoles
{
    private static $instances = [];

    private static $filter = [];

    private $contentObjectAttribute;

    private $attributeSettings;

    private $classSettings;

    private $searchQuery;

    private $searchData;

    private $language;

    private $roles;

    private $people;

    private $entities;

    private $rolesPerPerson;

    private $rolesPerEntity;

    private $typePerEntities;

    private $includeExpired = false;

    private function __construct(eZContentObjectAttribute $contentObjectAttribute, $includeExpired = false)
    {
        $this->contentObjectAttribute = $contentObjectAttribute;
        $this->attributeSettings = (array)json_decode($contentObjectAttribute->attribute('data_text'), true);
        $this->classSettings = $this->contentObjectAttribute->attribute('class_content');
        $this->language = eZLocale::currentLocaleCode();
        $this->includeExpired = $includeExpired;
    }

    public static function instance(eZContentObjectAttribute $contentObjectAttribute, $includeExpired = false)
    {
        if (!isset(self::$instances[$contentObjectAttribute->attribute('id')][$includeExpired])) {
            self::$instances[$contentObjectAttribute->attribute('id')][$includeExpired] = new OpenPARoles($contentObjectAttribute, $includeExpired);
        }

        return self::$instances[$contentObjectAttribute->attribute('id')][$includeExpired];
    }

    public function attributes()
    {
        return [
            'roles',
            'roles_history',
            'roles_per_person',
            'roles_per_entity',
            'people',
            'entities',
            'main_type_per_entities',
            'settings',
            'query',
        ];
    }

    /**
     * @param $name
     * @return bool
     */
    public function hasAttribute($name)
    {
        return in_array($name, $this->attributes());
    }

    public function attribute($name)
    {
        switch ($name) {
            case 'roles':
                return $this->getRoles();

            case 'roles_history':
                return self::instance($this->contentObjectAttribute, true);

            case 'roles_per_person':
                return $this->getRolesPerPerson();

            case 'roles_per_entity':
                return $this->getRolesPerEntity();

            case 'people':
                return $this->getPeople();

            case 'entities':
                return $this->getEntities();

            case 'main_type_per_entities':
                return $this->getTypesPerEntity();

            case 'settings':
                return $this->attributeSettings;

            case 'query':
                return $this->buildQuery(false);
        }

        eZDebug::writeError("Attribute $name does not exixts", __METHOD__);
        return null;
    }

    public function getPagination()
    {
        if (isset($this->attributeSettings['pagination']) && is_numeric($this->attributeSettings['pagination'])){
            return $this->attributeSettings['pagination'];
        }

        return 6;
    }

    /**
     * @return bool
     */
    public function hasContent()
    {
        if ($this->getPagination() == 0){
            return false;
        }

        try {
            $contentSearch = new ContentSearch();
            $contentSearch->setEnvironment(new FullEnvironmentSettings());
            $data = (array)$contentSearch->search($this->buildQuery());
            return $data['totalCount'] > 0;

        } catch (Exception $e) {
            eZDebug::writeError($e->getMessage(), __METHOD__);
            return false;
        }
    }

    public function getContent()
    {
        if ($this->getPagination() == 0){
            return false;
        }
        
        if ($this->searchData === null) {
            $contentSearch = new ContentSearch();
            try {
                $contentSearch->setEnvironment(new FullEnvironmentSettings(['maxSearchLimit' => OpenPARoleType::FETCH_LIMIT]));
                $data = $contentSearch->search($this->buildQuery(OpenPARoleType::FETCH_LIMIT));
            } catch (Exception $e) {
                $data = new stdClass();
                $data->searchHits = [];
                eZDebug::writeError($e->getMessage(), __METHOD__);
            }
            $this->searchData = $this->sortRoles($data->searchHits);
        }
        return $this->searchData;
    }

    public function getRoles()
    {
        if ($this->getPagination() == 0){
            return [];
        }
        if ($this->roles === null) {
            $this->roles = [];
            $idList = [];
            $contents = $this->getContent();
            foreach ($contents as $hit) {
                $idList[] = (int)$hit['metadata']['id'];
            }

            $roles = OpenPABase::fetchObjects($idList);
            foreach ($roles as $role) {
                $this->roles[$role->attribute('id')] = $role;
            }
            $this->roles = array_replace(array_flip($idList), $this->roles);
        }

        return $this->roles;
    }

    /**
     * @param $id
     * @return eZContentObject|null
     */
    private function getRole($id)
    {
        $this->getRoles();
        return isset($this->roles[$id]) ? $this->roles[$id] : null;
    }

    public function getRolesPerPerson()
    {
        if ($this->getPagination() == 0){
            return [];
        }
        if ($this->rolesPerPerson === null) {
            $this->rolesPerPerson = [];
            $contents = $this->getContent();
            foreach ($contents as $content) {
                $role = $this->getRole($content['metadata']['id']);
                if ($role instanceof eZContentObject) {
                    $roleDataMap = $role->dataMap();
                    $personIdList = isset($roleDataMap['person']) && $roleDataMap['person']->hasContent() ?
                        explode('-', $roleDataMap['person']->toString()) : [];
                    foreach ($personIdList as $person) {
                        $this->rolesPerPerson[$person][] = $role;
                    }
                }
            }
        }

        return $this->rolesPerPerson;
    }

    public function getPeople()
    {
        if ($this->getPagination() == 0){
            return [];
        }
        if ($this->people === null) {
            $this->people = [];
            $contents = $this->getContent();
            $idList = [];
            foreach ($contents as $content) {
                $role = $this->getRole($content['metadata']['id']);
                if ($role instanceof eZContentObject) {
                    $roleDataMap = $role->dataMap();
                    $personIdList = isset($roleDataMap['person']) && $roleDataMap['person']->hasContent() ?
                        explode('-', $roleDataMap['person']->toString()) : [];
                    $idList = array_unique(array_merge($idList, $personIdList));
                }
            }
            $people = OpenPABase::fetchObjects($idList);
            foreach ($people as $person) {
                $this->people[$person->attribute('id')] = $person;
            }
            $this->people = array_replace(array_flip($idList), $this->people);
        }

        return $this->people;
    }

    public function getEntities()
    {
        if ($this->getPagination() == 0){
            return [];
        }
        if ($this->entities === null) {
            $this->entities = [];
            $contents = $this->getContent();
            $idList = [];
            foreach ($contents as $content) {
                $role = $this->getRole($content['metadata']['id']);
                if ($role instanceof eZContentObject) {
                    $roleDataMap = $role->dataMap();
                    $entityIdList = isset($roleDataMap['for_entity']) && $roleDataMap['for_entity']->hasContent() ?
                        explode('-', $roleDataMap['for_entity']->toString()) : [];
                    $idList = array_unique(array_merge($idList, $entityIdList));
                }
            }
            $entities = OpenPABase::fetchObjects($idList);
            foreach ($entities as $entity) {
                $this->entities[$entity->attribute('id')] = $entity;
            }
            $this->entities = array_replace(array_flip($idList), $this->entities);
        }

        return $this->entities;
    }

    public function getRolesPerEntity()
    {
        if ($this->getPagination() == 0){
            return [];
        }
        if ($this->rolesPerEntity === null) {
            $this->rolesPerEntity = [];
            $contents = $this->getContent();
            foreach ($contents as $content) {
                $role = $this->getRole($content['metadata']['id']);
                if ($role instanceof eZContentObject) {
                    $roleDataMap = $role->dataMap();
                    $entityIdList = isset($roleDataMap['for_entity']) && $roleDataMap['for_entity']->hasContent() ?
                        explode('-', $roleDataMap['for_entity']->toString()) : [];
                    foreach ($entityIdList as $entity) {
                        $this->rolesPerEntity[$entity][] = $role;
                    }
                }
            }
        }

        return $this->rolesPerEntity;
    }

    public function getTypesPerEntity()
    {
        if ($this->getPagination() == 0){
            return [];
        }
        if ($this->typePerEntities === null) {
            $this->typePerEntities = [];
            $contents = $this->getContent();
            foreach ($contents as $content) {
                $role = $this->getRole($content['metadata']['id']);
                if ($role instanceof eZContentObject) {
                    $roleDataMap = $role->dataMap();
                    $type = $role->attribute('name');
                    if (isset($roleDataMap['label']) && $roleDataMap['label']->hasContent()) {
                        $type = '#' . $roleDataMap['label']->toString();
                    } elseif (isset($roleDataMap['role'])) {
                        $keywords = [];
                        $tags = $roleDataMap['role']->content();
                        if ($tags instanceof eZTags) {
                            foreach ($tags->attribute('tags') as $tag) {
                                $keywords[] = $tag->attribute('keyword');
                            }
                        }
                        $type = implode(', ', $keywords);
                    }
                    foreach ($content['data'][$this->language]['for_entity']['content'] as $entity) {
                        if (isset($content['data'][$this->language]['ruolo_principale']['content'])
                            && $content['data'][$this->language]['ruolo_principale']['content']) {
                            $this->typePerEntities[$type][$entity['id']] = $entity['name'][$this->language];
                        }
                    }
                }
            }
        }

        return $this->typePerEntities;
    }

    /**
     * @param ?int $limit
     * @param ?int $offset
     * @return string
     * @throws Exception
     */
    public function buildQuery($limit = 1, $offset = 0)
    {
        if ($this->searchQuery === null) {
            $this->searchQuery = array();

            $this->searchQuery[] = "classes [time_indexed_role]";
            $this->searchQuery[] = "subtree [" . OpenPABootstrapItaliaOperators::getOpenpaRolesParentNodeId() . "]";

            if ($this->classSettings['select'] == OpenPARoleType::SELECT_PERSON) {
                $this->searchQuery[] = "person.id = " . $this->contentObjectAttribute->attribute('contentobject_id');
            } elseif ($this->classSettings['select'] == OpenPARoleType::SELECT_ENTITY) {
                $this->searchQuery[] = "for_entity.id = " . $this->contentObjectAttribute->attribute('contentobject_id');
            } else {
                throw new Exception("La configurazione dell'attributo openpa role non è valida", 1);
            }

            $roleFilter = $this->getRoleFilter();
            if ($roleFilter) {
                $this->searchQuery[] = $roleFilter;
            }
            if (!$this->includeExpired){
                $this->searchQuery[] = 'calendar[start_time,end_time] = [now,*]';
            }
            $this->searchQuery[] = 'sort [raw[attr_priorita_si]=>desc,person.name=>asc]';
            eZDebug::writeDebug(implode(' and ', $this->searchQuery), $this->contentObjectAttribute->attribute('id') . ' ' . __METHOD__);
        }
        $queryParts = $this->searchQuery;
        $limit = (int)$limit;
        if ($limit > 0) $queryParts[] = 'limit ' . (int)$limit;
        if ($offset > 0) $queryParts[] = 'offset ' . (int)$offset;

        return implode(' and ', $queryParts);
    }

    /**
     * @return string
     */
    private function getRoleFilter()
    {
        if (isset($this->attributeSettings['filters']) && is_array($this->attributeSettings['filters']) && count($this->attributeSettings['filters']) > 0) {
            $tagsIdList = $this->attributeSettings['filters'];
            $synonyms = eZTagsObject::fetchObjectList(
                eZTagsObject::definition(), ['id'], ['main_tag_id' => [$tagsIdList]], null, null, false
            );
            if (is_array($synonyms) && !empty($synonyms)){
                $tagsIdList = array_unique(array_merge($tagsIdList, array_column($synonyms, 'id')));
            }

            return "raw[subattr_role___tag_ids____si] in [" . implode(',', $tagsIdList). "]";
        } else {
            $filters = $this->classSettings['filter'];
            $inMemoryId = $this->contentObjectAttribute->attribute('contentclassattribute_id');

            if (!isset(self::$filter[$inMemoryId])) {
                self::$filter[$inMemoryId] = [];
                if (!empty($filters)) {
                    $filterList = [];
                    foreach ($filters as $filter) {
                        $filterList[] = addcslashes($filter, "')(][");
                    }
                    foreach ($filters as $filter) {
                        $tags = eZTagsObject::fetchByKeyword($filter, true);
                        foreach ($tags as $tag) {
                            foreach ($tag->getTranslations() as $keyword) {
                                $filterList[] = addcslashes($keyword->attribute('keyword'), "')(][");
                            }
                            foreach ($tag->getSynonyms() as $keyword) {
                                $filterList[] = addcslashes($keyword->attribute('keyword'), "')(][");
                            }
                        }
                    }
                    self::$filter[$inMemoryId] = "role in ['\"" . implode("\"','\"", array_unique($filterList)) . "\"']";
                }else{
                    self::$filter[$inMemoryId] = false;
                }
            }

            return self::$filter[$inMemoryId];
        }
    }

    public function sortRoles($contents)
    {
        $sortValue = $this->classSettings['sort'];
        if (count($contents) > 1) {
            $attributeIdentifier = false;
            if ($sortValue == OpenPARoleType::SORT_ENTITY_NAME) {
                $attributeIdentifier = 'for_entity';
            } elseif ($sortValue == OpenPARoleType::SORT_PERSON_NAME) {
                $attributeIdentifier = 'person';
            } elseif ($sortValue == OpenPARoleType::SORT_START_TIME) {
                $attributeIdentifier = 'start_time';
            }

            if ($attributeIdentifier) {
                $language = $this->language;
                usort($contents, function ($a, $b) use ($attributeIdentifier, $language) {
                    $aLanguage = $language;
                    if (!in_array($language, $a['metadata']['languages'])) {
                        $aLanguage = $a['metadata']['languages'][0];
                    }
                    $bLanguage = $language;
                    if (!in_array($language, $b['metadata']['languages'])) {
                        $bLanguage = $a['metadata']['languages'][0];
                    }

                    if ($attributeIdentifier !== 'role' && $attributeIdentifier !== 'start_time'
                        && isset($a['data'][$aLanguage][$attributeIdentifier]['content'][0]['name'])
                        && isset($b['data'][$bLanguage][$attributeIdentifier]['content'][0]['name'])
                    ) {
                        $aName = $a['data'][$aLanguage][$attributeIdentifier]['content'][0]['name'][$aLanguage]
                            ?? current($a['data'][$aLanguage][$attributeIdentifier]['content'][0]['name']);
                        $bName = $b['data'][$bLanguage][$attributeIdentifier]['content'][0]['name'][$bLanguage]
                            ?? current($b['data'][$bLanguage][$attributeIdentifier]['content'][0]['name']);

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
}
