<?php

class OpenPAComuniItaliani extends eZPersistentObject implements JsonSerializable
{
    public static function definition()
    {
        static $def = [
            "fields" => [
                'comune' => [
                    'name' => 'comune',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => true,
                ],
                'name_normalized' => [
                    'name' => 'name_normalized',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => true,
                ],
                'pro_com_t' => [
                    'name' => 'pro_com_t',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => true,
                ],
                'den_prov' => [
                    'name' => 'den_prov',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => true,
                ],
                'sigla' => [
                    'name' => 'sigla',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => true,
                ],
                'den_reg' => [
                    'name' => 'den_reg',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => true,
                ],
                'cod_reg' => [
                    'name' => 'cod_reg',
                    'datatype' => 'integer',
                    'default' => '',
                    'required' => true,
                ],
            ],
            'keys' => ['pro_com_t'],
            'function_attributes' => [
                'code' => 'getCode',
                'name' => 'getName',
            ],
            'class_name' => 'OpenPAComuniItaliani',
            'sort' => ['den_reg' => 'asc', 'den_prov' => 'asc', 'comune' => 'asc'],
            'name' => 'openpacomuniitaliani',
        ];

        return $def;
    }

    public static function __set_state($data)
    {
        return new OpenPAComuniItaliani($data);
    }

    function getCode()
    {
        return $this->attribute('pro_com_t');
    }

    function getName()
    {
        return $this->attribute('comune');
    }

    public static function import()
    {
        $csvSource = 'https://raw.githubusercontent.com/opendatasicilia/comuni-italiani/main/dati/comuni.csv';
        $csvData = file_get_contents($csvSource);
        if (empty($csvData)) {
            throw new Exception("Data not found in $csvSource");
        }
        $csvFile = eZSys::cacheDirectory() . '/comuni.csv';
        file_put_contents($csvFile, $csvData);

        $headers = $values = [];
        $row = 1;
        if (($handle = fopen($csvFile, "r")) !== false) {
            while (($data = fgetcsv($handle, 100000, ",")) !== false) {
                if ($row === 1) {
                    $headers = $data;
                } else {
                    $value = [];
                    for ($j = 0, $jMax = count($headers); $j < $jMax; ++$j) {
                        $value[$headers[$j]] = $data[$j];
                    }
                    $value['name_normalized'] = eZCharTransform::instance()->transformByGroup(
                        $value['comune'],
                        'identifier'
                    );
                    $values[] = $value;
                }
                $row++;
            }
            fclose($handle);
        }

        foreach ($values as $item) {
            $po = new self($item);
            $po->store();
        }
    }

    public static function convertFromEzTags()
    {
        $tag = eZTagsObject::fetchByUrl('/Luoghi/Comuni italiani');
        if ($tag instanceof eZTagsObject) {
            $subTreeLimitations = $tag->getSubTreeLimitations();
            foreach ($subTreeLimitations as $attributeClass) {
                if ($attributeClass->attribute('data_type_string') == eZTagsType::DATA_TYPE_STRING) {
                    self::convertClassAttributeFromEzTags($attributeClass);
                    eZCache::clearAll();
                }
            }
        }
    }

    public static function convertClassAttributeFromEzTags(eZContentClassAttribute $attributeClass)
    {
        $db = eZDB::instance();
        /** @var eZContentObjectAttribute[] $attributeObjects */
        $attributeObjects = eZContentObjectAttribute::fetchObjectList(
            eZContentObjectAttribute::definition(),
            null,
            ['contentclassattribute_id' => $attributeClass->attribute('id')]
        );

        $db->begin();
        $attributeClass->setAttribute('data_type_string', OpenPAComuniItalianiType::DATA_TYPE_STRING);
        $attributeClass->setAttribute(OpenPAComuniItalianiType::MULTIPLE_CHOICE_FIELD, 0);
        $attributeClass->store();
        foreach ($attributeObjects as $attributeObject) {
            if ($attributeObject->hasContent()) {
                /** @var eZTags $content */
                $content = $attributeObject->attribute('content');
                $data = self::getCodesFromNames($content->attribute('keyword'));
                $attributeObject->setAttribute('data_text', implode('#', $data));
                $attributeObject->setAttribute(
                    'data_type_string',
                    OpenPAComuniItalianiType::DATA_TYPE_STRING
                );
                $attributeObject->store();
            }
        }
        $db->commit();
    }

    public static function getNamesFromCodes(array $data)
    {
        if (empty($data)) {
            return $data;
        }
        $list = self::fetchObjectList(
            self::definition(),
            'comune',
            ['pro_com_t' => [$data]],
            ['comune' => 'asc'],
            null,
            false
        );

        return array_column($list, 'comune');
    }

    public static function getCodesFromNames(array $data)
    {
        if (empty($data)) {
            return $data;
        }
        $data = array_map(function ($item) {
            return eZCharTransform::instance()->transformByGroup($item, 'identifier');
        }, $data);
        $list = self::fetchObjectList(self::definition(), 'pro_com_t', ['name_normalized' => [$data]], null, false);

        return array_column($list, 'pro_com_t');
    }

    public static function fetchByCodes(array $data)
    {
        if (empty($data)) {
            return $data;
        }
        $list = self::fetchObjectList(
            self::definition(),
            null,
            ['pro_com_t' => [$data]],
            ['comune' => 'asc'],
            null,
            true
        );

        return $list;
    }

    public static function getCodesFromCodes(array $data)
    {
        if (empty($data)) {
            return $data;
        }
        $list = self::fetchObjectList(self::definition(), 'pro_com_t', ['pro_com_t' => [$data]], null, false);

        return array_column($list, 'pro_com_t');
    }

    public static function fetchListForFunctions($grouped)
    {
        $list = self::fetchObjectList(self::definition());
        if ($grouped) {
            $groupList = [];
            foreach ($list as $item) {
                $groupList[$item->attribute('den_reg')][$item->attribute('den_prov')][] = $item;
            }
            return ['result' => $groupList];
        }

        return ['result' => $list];
    }

    public static function fetchItemForFunctions($code)
    {
        $item = self::fetchObject(self::definition(), null, ['pro_com_t' => $code]);

        return ['result' => $item ?? false];
    }

    public function jsonSerialize()
    {
        $data = [];
        $def = self::definition();
        $attrs = array_keys($def["function_attributes"]);
        foreach ($attrs as $identifier) {
            $data[$identifier] = $this->attribute($identifier);
        }

        return $data;
    }
}