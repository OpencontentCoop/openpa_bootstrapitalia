<?php

use Opencontent\Opendata\Api\AttributeConverter\Base;
use Opencontent\Opendata\Api\Exception\InvalidInputException;
use Opencontent\Opendata\Api\PublicationProcess;

class OpenPAComuniItalianiAttributeConverter extends Base
{
    public function get(eZContentObjectAttribute $attribute)
    {
        $content = parent::get($attribute);
        $list = \eZStringUtils::explodeStr($content['content'], '#');
        $content['content'] = OpenPAComuniItaliani::fetchByCodes($list);
        return $content;
    }

    public function set($data, PublicationProcess $process)
    {
        $data = array_unique((array)$data);
        $codes = OpenPAComuniItaliani::getCodesFromCodes($data);
        if (empty($codes)){
            $codes = OpenPAComuniItaliani::getCodesFromNames((array)$data);
        }
        return \eZStringUtils::implodeStr($codes, '#');
    }

    public static function validate($identifier, $data, eZContentClassAttribute $attribute)
    {
        if (is_array($data) && !empty($data)) {
            $data = array_unique($data);
            $validData = OpenPAComuniItaliani::getCodesFromCodes((array)$data);
            if (empty($validData) || count($data) !== count($validData)){
                $testWithNames = OpenPAComuniItaliani::getCodesFromNames((array)$data);
                if (empty($testWithNames) || count($data) !== count($testWithNames)) {
                    throw new InvalidInputException('Invalid selection', $identifier, $data);
                }
            }
        }
    }

    public function type(eZContentClassAttribute $attribute)
    {
        return array(
            'identifier' => 'selection',
            'format' => 'array',
            'allowed_values' => 'Codici istat dei comuni italiani'
        );
    }

    public function toCSVString($content, $params = null)
    {
        if (is_array($content)) {
            $data = OpenPAComuniItaliani::getNamesFromCodes($content);
            return \eZStringUtils::implodeStr($data, '|');
        }

        return '';
    }
}