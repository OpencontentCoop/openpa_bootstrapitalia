<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\RelationsField as BaseRelationsField;

class RelationsField extends BaseRelationsField
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