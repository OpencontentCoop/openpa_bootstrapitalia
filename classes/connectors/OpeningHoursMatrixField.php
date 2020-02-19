<?php

class OpeningHoursMatrixField extends \Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\MatrixField
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
                "title" => ucfirst(ezpI18n::tr('bootstrapitalia/opening_hours_matrix', $column['identifier'])),
                "type" => "string"
            );
        }
        return $schema;
    }
}