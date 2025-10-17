<?php

use Opencontent\Opendata\Api\AttributeConverter\Base;

class OpenPARoleAttributeConverter extends Base
{
    public function get(eZContentObjectAttribute $attribute)
    {
        return [
            'id' => intval($attribute->attribute('id')),
            'version' => intval($attribute->attribute('version')),
            'identifier' => $this->classIdentifier . '/' . $this->identifier,
            'datatype' => $attribute->attribute('data_type_string'),
            'contentclassattribute_id' => $attribute->attribute('contentclassattribute_id'),
            'sort_key_int' => $attribute->attribute('sort_key_int'),
            'sort_key_string' => $attribute->attribute('sort_key_string'),
            'data_text' => $attribute->attribute('data_text'),
            'data_int' => $attribute->attribute('data_int'),
            'data_float' => $attribute->attribute('data_float'),
            'is_information_collector' => $attribute->attribute('is_information_collector'),
            'content' => '(calculated)',
        ];
    }
}