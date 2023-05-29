<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\RelationField as BaseRelationField;

class RelationField extends BaseRelationField
{
    public function getSchema()
    {
        $title = $this->attribute->attribute('name');
        if ($this->attribute->attribute('is_required')){
            $title .= ' *';
        }
        $schema = parent::getSchema();
        $schema['title'] = $title;

        return $schema;
    }

    public function getOptions()
    {
        $options = parent::getOptions();

        $classContent = $this->attribute->dataType()->classAttributeContent($this->attribute);
        $classConstraintList = (array)$classContent['class_constraint_list'];
        if (!empty($classConstraintList) && isset($options["browse"])){
            $options["browse"]["classes"] = $classConstraintList;
        }

        return $options;
    }


}