<?php

class OpenPABootstrapItaliaAttributeGroupExtraParameter extends OCClassExtraParametersHandlerBase
{

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
        foreach ($this->parameters as $parameter) {
            if ($parameter->attribute('attribute_identifier') == '*' && $parameter->attribute('key') != 'enabled') {
                $groupList[$parameter->attribute('key')] = $parameter->attribute('value');
            }
        }

        return $groupList;
    }

    public function attribute($key)
    {
        $groupList = $this->getGroupList();

        if ($key == 'group_list') {
            return $this->getGroupList();
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
        if (isset($data['class'][$this->class->attribute('identifier')]['add_group'])) {
            $newGroupName = $data['class'][$this->class->attribute('identifier')]['add_group'];
            $newGroupIdentifier = eZCharTransform::instance()->transformByGroup($newGroupName, 'identifier');
            if (!empty($newGroupIdentifier)) {
                $data['class'][$this->class->attribute('identifier')][$newGroupIdentifier] = $newGroupName;
            }
            unset($data['class'][$this->class->attribute('identifier')]['add_group']);
        }

        parent::storeParameters($data);
    }
}