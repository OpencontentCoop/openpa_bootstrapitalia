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

    public function getOptions()
    {
        $options = parent::getOptions();
        if (isset($options['browse']['addCreateButton'])) {
            $options['browse']['addCreateButton'] = false;
        }

        return $options;
    }
}