<?php

class OpenPABootstrapItaliaAttributeGroupExtraParameter extends OCClassExtraParametersHandlerBase
{
    use OpenPABootstrapItaliaCustomAttributeTrait;

    public function getIdentifier()
    {
        return 'attribute_group';
    }

    public function getName()
    {
        return "Visualizzazione di attributi raggruppati";
    }

    public function attributes()
    {
        $attributes = parent::attributes();

        $attributes[] = 'group_list';
        $attributes[] = 'sort_list';

        $groupList = $this->getGroupList();
        foreach ($groupList as $identifier => $name) {
            $attributes[] = 'enable_' . $identifier;
            $attributes[] = $identifier;
        }

        return $attributes;
    }

    private function getGroupList()
    {
        $groupList = array();
        $sortList = array();
        foreach ($this->parameters as $parameter) {
            if ($parameter->attribute('attribute_identifier') == '*' && $parameter->attribute('key') != 'enabled') {
                $key = $parameter->attribute('key');
                if (strpos($key, 'sort:') === false) {
                    $groupList[$key] = $parameter->attribute('value');
                } else {
                    $key = str_replace('sort::', '', $key);
                    $sortList[$key] = $parameter->attribute('value');
                }
            }
        }

        $sortList = $this->getSortList();
        if (empty($sortList)){
            return $groupList;
        }
        $sortedGroupList = array();

        foreach ($sortList as $identifier => $sort) {
            if (isset($groupList[$identifier])) {
                $sortedGroupList[$identifier] = $groupList[$identifier];
            }
        }

        return $sortedGroupList;
    }

    private function getSortList()
    {
        $sortList = array();
        foreach ($this->parameters as $parameter) {
            if ($parameter->attribute('attribute_identifier') == '*' && $parameter->attribute('key') != 'enabled') {
                $key = $parameter->attribute('key');
                if (strpos($key, 'sort:') !== false) {
                    $key = str_replace('sort::', '', $key);
                    $sortList[$key] = $parameter->attribute('value');
                }
            }
        }
        asort($sortList);

        return $sortList;
    }

    public function attribute($key)
    {
        $groupList = $this->getGroupList();

        if ($key == 'group_list') {
            return $this->getGroupList();
        }

        if ($key == 'sort_list') {
            return $this->getSortList();
        }

        foreach ($groupList as $identifier => $name) {
            if ($key == $identifier) {
                return $this->getAttributeIdentifierListByParameter($identifier, 1, false);
            }
        }

        return parent::attribute($key);
    }

    protected function attributeEditTemplateUrl()
    {
        return 'design:openpa/extraparameters/' . $this->getIdentifier() . '/edit_attribute.tpl';
    }

    protected function classEditTemplateUrl()
    {
        return 'design:openpa/extraparameters/' . $this->getIdentifier() . '/edit_class.tpl';
    }

    protected function handleAttributes()
    {
        return count($this->getGroupList()) > 0;
    }

    public function storeParameters($data)
    {
        if ($data['class'][$this->class->attribute('identifier')]['generate_from_class']) {
            unset($data['class'][$this->class->attribute('identifier')]['add_group']);
            unset($data['class'][$this->class->attribute('identifier')]['generate_from_class']);

            $groupedAttributes = $this->createGroupedDataMap();
            foreach ($groupedAttributes as $identifierLabel => $attributeIdentifiers) {
                list($newGroupIdentifier, $newGroupName) = explode('::', $identifierLabel);
                $data['class'][$this->class->attribute('identifier')][$newGroupIdentifier] = $newGroupName;
                foreach ($attributeIdentifiers as $attributeIdentifier) {
                    $data['class_attribute'][$this->class->attribute('identifier')][$attributeIdentifier][$newGroupIdentifier] = 1;
                }
            }

        } elseif (isset($data['class'][$this->class->attribute('identifier')]['add_group'])) {
            $newGroupName = $data['class'][$this->class->attribute('identifier')]['add_group'];
            $newGroupIdentifier = eZCharTransform::instance()->transformByGroup($newGroupName, 'identifier');
            $sortList = $this->getSortList();
            $nextSort = array_pop($sortList) + 1;

            if (!empty($newGroupIdentifier)) {
                $data['class'][$this->class->attribute('identifier')][$newGroupIdentifier] = $newGroupName;
                $data['class'][$this->class->attribute('identifier')]['sort::' . $newGroupIdentifier] = $nextSort;
            }
            unset($data['class'][$this->class->attribute('identifier')]['add_group']);
        }

        parent::storeParameters($data);
        eZContentCacheManager::clearAllContentCache(true);
    }

    private function createGroupedDataMap()
    {
        /** @var eZContentClassAttribute[] $classAttributes */
        $classAttributes = $this->class->dataMap();
        $groupedDataMap = array();
        $contentINI = eZINI::instance('content.ini');
        $categories = $contentINI->variable('ClassAttributeSettings', 'CategoryList');
        $defaultCategory = $contentINI->variable('ClassAttributeSettings', 'DefaultCategory');
        foreach ($classAttributes as $classAttribute) {
            $attributeCategory = $classAttribute->attribute('category');
            if ($attributeCategory == 'hidden') {
                continue;
            }
            $attributeIdentifier = $classAttribute->attribute('identifier');
            if (!isset($categories[$attributeCategory]) || !$attributeCategory) {
                $attributeCategory = $defaultCategory;
            }

            $categoryLabel = $categories[$attributeCategory];

            if (!isset($groupedDataMap[$attributeCategory]))
                $groupedDataMap[$attributeCategory] = array();

            $groupedDataMap[$attributeCategory . '::' . $categoryLabel][] = $attributeIdentifier;

        }
        return $groupedDataMap;
    }
}