<?php

class OpenPAMaskedStringType extends eZDataType
{
    const DATA_TYPE_STRING = 'openpamaskedstring';

    const MASK_FIELD = "data_text5";

    const MASK_VARIABLE = "_openpamaskedstring_mask_";

    public function __construct()
    {
        parent::__construct(
            self::DATA_TYPE_STRING, ezpI18n::tr('kernel/classes/datatypes', 'Mask text line', 'Datatype name'),
            array('serialize_supported' => true, 'object_serialize_map' => array('data_text' => 'text'))
        );
    }

    function initializeObjectAttribute($contentObjectAttribute, $currentVersion, $originalContentObjectAttribute)
    {
        if ($currentVersion != false) {
            $dataText = $originalContentObjectAttribute->attribute("data_text");
            $contentObjectAttribute->setAttribute("data_text", $dataText);
        }
    }

    function validateObjectAttributeHTTPInput($http, $base, $contentObjectAttribute)
    {
        $classAttribute = $contentObjectAttribute->contentClassAttribute();

        if ($http->hasPostVariable($base . '_openpamaskedstring_data_text_' . $contentObjectAttribute->attribute('id'))) {
            $data = trim($http->postVariable($base . '_openpamaskedstring_data_text_' . $contentObjectAttribute->attribute('id')));

            if ($data == "") {
                if (!$classAttribute->attribute('is_information_collector') and $contentObjectAttribute->validateIsRequired()) {
                    $contentObjectAttribute->setValidationError(
                        ezpI18n::tr('kernel/classes/datatypes', 'Input required.')
                    );

                    return eZInputValidator::STATE_INVALID;
                }
            }
        } else if (!$classAttribute->attribute('is_information_collector') and $contentObjectAttribute->validateIsRequired()) {
            $contentObjectAttribute->setValidationError(
                ezpI18n::tr('kernel/classes/datatypes', 'Input required.')
            );

            return eZInputValidator::STATE_INVALID;
        }

        return eZInputValidator::STATE_ACCEPTED;
    }

    function fetchObjectAttributeHTTPInput($http, $base, $contentObjectAttribute)
    {
        if ($http->hasPostVariable($base . '_openpamaskedstring_data_text_' . $contentObjectAttribute->attribute('id'))) {
            $data = $http->postVariable($base . '_openpamaskedstring_data_text_' . $contentObjectAttribute->attribute('id'));
            $contentObjectAttribute->setAttribute('data_text', $data);

            return true;
        }

        return false;
    }

    function isSimpleStringInsertionSupported()
    {
        return true;
    }

    function insertSimpleString($object, $objectVersion, $objectLanguage,
                                $objectAttribute, $string,
                                &$result)
    {
        $result = array(
            'errors' => array(),
            'require_storage' => true
        );
        $objectAttribute->setContent($string);
        $objectAttribute->setAttribute('data_text', $string);
        return true;
    }

    function fetchClassAttributeHTTPInput($http, $base, $classAttribute)
    {
        $maskValueName = $base . self::MASK_VARIABLE . $classAttribute->attribute('id');
        if ($http->hasPostVariable($maskValueName)) {
            $maskValueValue = $http->postVariable($maskValueName);

            $classAttribute->setAttribute(self::MASK_FIELD, $maskValueValue);
        }
        return true;
    }

    private function maskString(eZContentObjectAttribute $contentObjectAttribute)
    {
        $string = $contentObjectAttribute->attribute('data_text');
        $format = $contentObjectAttribute->contentClassAttribute()->attribute(self::MASK_FIELD);

        return sprintf($format, $string);
    }

    function objectAttributeContent($contentObjectAttribute)
    {
        return $this->maskString($contentObjectAttribute);
    }

    function metaData($contentObjectAttribute)
    {
        return $this->maskString($contentObjectAttribute);
    }

    function toString($contentObjectAttribute)
    {
        return $this->maskString($contentObjectAttribute);
    }

    function fromString($contentObjectAttribute, $string)
    {
        return $contentObjectAttribute->setAttribute('data_text', $string);
    }

    function title($contentObjectAttribute, $name = null)
    {
        return $this->maskString($contentObjectAttribute);
    }

    function hasObjectAttributeContent($contentObjectAttribute)
    {
        return trim($contentObjectAttribute->attribute('data_text')) != '';
    }

    function isIndexable()
    {
        return true;
    }

    function isInformationCollector()
    {
        return false;
    }

    function sortKey($contentObjectAttribute)
    {
        $trans = eZCharTransform::instance();
        return $trans->transformByGroup($contentObjectAttribute->attribute('data_text'), 'lowercase');
    }

    function sortKeyType()
    {
        return 'string';
    }

    function serializeContentClassAttribute($classAttribute, $attributeNode, $attributeParametersNode)
    {
        $maskString = $classAttribute->attribute(self::MASK_FIELD);
        $dom = $attributeParametersNode->ownerDocument;
        $maskStringNode = $dom->createElement('mask-string');
        if ($maskString) {
            $maskStringNode->appendChild($dom->createTextNode($maskString));
        }
        $attributeParametersNode->appendChild($maskStringNode);
    }

    function unserializeContentClassAttribute($classAttribute, $attributeNode, $attributeParametersNode)
    {
        $maskString = $attributeParametersNode->getElementsByTagName('mask-string')->item(0)->textContent;
        $classAttribute->setAttribute(self::MASK_FIELD, $maskString);
    }

    function diff($old, $new, $options = false)
    {
        $diff = new eZDiff();
        $diff->setDiffEngineType($diff->engineType('text'));
        $diff->initDiffEngine();
        $diffObject = $diff->diff($old->content(), $new->content());

        return $diffObject;
    }

    function supportsBatchInitializeObjectAttribute()
    {
        return true;
    }

    function batchInitializeObjectAttributeData($classAttribute)
    {
        return array();
    }
}

eZDataType::register(OpenPAMaskedStringType::DATA_TYPE_STRING, 'OpenPAMaskedStringType');