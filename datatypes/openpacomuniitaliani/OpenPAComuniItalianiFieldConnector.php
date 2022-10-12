<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector;

class OpenPAComuniItalianiFieldConnector extends FieldConnector
{
    private $values;

    public function __construct($attribute, $class, $helper)
    {
        parent::__construct($attribute, $class, $helper);

        $list = OpenPAComuniItaliani::fetchObjectList(OpenPAComuniItaliani::definition());
        $this->values = [];
        foreach ($list as $item) {
            $this->values[$item->attribute('code')] = $item->attribute('name') . ' (' . $item->attribute('sigla') . ')';
        }
    }

    public function getData()
    {
        $rawContent = $this->getContent();
        if ($rawContent && !empty($rawContent['content'])) {
            return $rawContent['content'];
        } elseif ($this->attribute->attribute('is_required')) {
            return explode('#', $this->attribute->attribute(OpenPAComuniItalianiType::DEFAULT_LIST_FIELD));
        }
        return null;
    }

    public function getSchema()
    {
        $schema = [
            "enum" => array_keys($this->values),
            "title" => $this->attribute->attribute('name'),
            'required' => (bool)$this->attribute->attribute('is_required')
        ];

        if ($schema['required']) {
            $schema['default'] = current($this->values);
        }

        return $schema;
    }

    public function getOptions()
    {
        return [
            "label" => $this->attribute->attribute('name'),
            "helper" => $this->attribute->attribute('description'),
            "hideNone" => (bool)$this->attribute->attribute('is_required'),
            "type" => "select",
            "optionLabels" => array_values($this->values),
            "multiple" => (bool)$this->attribute->attribute(OpenPAComuniItalianiType::MULTIPLE_CHOICE_FIELD),
        ];
    }
}
