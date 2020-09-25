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
}