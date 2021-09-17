<?php

class PartecipanteLottoMatrixField extends \Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\MatrixField
{
    public function getSchema()
    {
        $schema = array(
            "type" => "array",
            "title" => $this->attribute->attribute('name'),
            "items" => array(
                "type" => "object",
                "properties" => array()
            ),
            'minItems' => (bool)$this->attribute->attribute('is_required') ? 1 : 0
        );

        /** @var \eZMatrixDefinition $definition */
        $definition = $this->attribute->attribute('content');
        $columns = $definition->attribute('columns');
        foreach ($columns as $column) {
            $schema["items"]["properties"][$column['identifier']] = array(
                "title" => $column['name'],
                "type" => "string"
            );
        }

        $schema['items']['properties']['ruolo']["enum"] = ['1', '2', '3', '4', '5'];

        return $schema;
    }

    public function getOptions()
    {
        $options = array(
            "helper" => $this->attribute->attribute('description'),
            "type" => "table"
        );
        $options['items']['fields']['ruolo']["type"] = "select";
        $options['items']['fields']['ruolo']["optionLabels"] = ['Mandante', 'Mandataria', 'Associata', 'Capogruppo', 'Consorziata'];

        return $options;
    }
}
