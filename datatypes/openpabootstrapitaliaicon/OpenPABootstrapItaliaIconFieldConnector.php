<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector;

class OpenPABootstrapItaliaIconFieldConnector extends FieldConnector
{
    private $iconList;

    public function __construct($attribute, $class, $helper)
    {
        parent::__construct($attribute, $class, $helper);
        $this->iconList = OpenPABootstrapItaliaIconType::getIconList();
    }

    public function getSchema()
    {
        $schema = array(
            "enum" => array_column($this->iconList, 'value'),
            "title" => $this->attribute->attribute('name'),
            'required' => (bool)$this->attribute->attribute('is_required')
        );

        if ($schema['required']){
            $schema['default'] = current($this->iconList);
        }

        return $schema;
    }

    public function getOptions()
    {
        return array(
            "label" => $this->attribute->attribute('name'),
            "helper" => $this->attribute->attribute('description'),
            "hideNone" => (bool)$this->attribute->attribute('is_required'),
            "optionLabels" => array_column($this->iconList, 'name'),
            "type" => "select",
            "multiple" => false,
        );
    }
}