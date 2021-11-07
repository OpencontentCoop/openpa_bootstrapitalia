<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\RelationsField as BaseRelationsField;

class SingleRelationsField extends BaseRelationsField
{
    public function getSchema()
    {
        $title = $this->attribute->attribute('name');
        if ($this->attribute->attribute('is_required')){
            $title .= ' *';
        }

        return [
            "title" => $title,
            'required' => (bool)$this->attribute->attribute('is_required'),
            'relation_mode' => BaseRelationsField::MODE_LIST_BROWSE,
            'minItems' => 0,
            'maxItems' => 1,
        ];
    }

    public function getData()
    {
        $data = array();
        if ($rawContent = $this->getContent()) {
            foreach ($rawContent['content'] as $item) {
                $language = $this->getHelper()->getSetting('language');
                $itemName = $item['name'];
                $name = isset($itemName[$language]) ? $itemName[$language] : current($itemName);
                $data[] = array(
                    'id' => $item['id'],
                    'name' => $name,
                    'class' => $item['classIdentifier'],
                );
            }
        }

        return $data;
    }

    public function getOptions()
    {
        /** @var array $classContent */
        $classContent = $this->attribute->dataType()->classAttributeContent($this->attribute);
        $classConstraintList = (array)$classContent['class_constraint_list'];
        $defaultPlacement = isset( $classContent['default_placement']['node_id'] ) ? $classContent['default_placement']['node_id'] : null;

        return array(
            'helper' => $this->attribute->attribute('description'),
            'type' => 'relationbrowse',
            'browse' => [
                'subtree' => $defaultPlacement,
                'classes' => $classConstraintList,
                'selectionType' => 'single',
                'addCloseButton' => true,
                'addCreateButton' => false,
                'language' => \eZLocale::currentLocaleCode(),
                'i18n' => RelationField::i18n()
            ]
        );
    }
}
