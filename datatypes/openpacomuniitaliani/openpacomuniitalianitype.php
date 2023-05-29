<?php

class OpenPAComuniItalianiType extends eZDataType
{
    const DATA_TYPE_STRING = 'openpacomuniitaliani';

    const MULTIPLE_CHOICE_FIELD = 'data_int1';

    const DEFAULT_LIST_FIELD = 'data_text5';

    public function __construct()
    {
        parent::__construct(
            self::DATA_TYPE_STRING,
            'Comuni italiani',
            ['serialize_supported' => true]
        );
    }

    /**
     * @param eZHTTPTool $http
     * @param string $base
     * @param eZContentClassAttribute $classAttribute
     * @return bool
     */
    function fetchClassAttributeHTTPInput($http, $base, $classAttribute)
    {
        $classAttributeID = $classAttribute->attribute('id');
        /** @var array $content */
        $content = $classAttribute->content();

        $postNameExists = $base . '_opcom_multiple_choice_' . $classAttribute->attribute('id') . '_exists';
        if ($http->hasPostVariable($postNameExists)) {
            $content['multiple_choice'] = (int)$http->hasPostVariable(
                $base . "_opcom_ismultiple_" . $classAttributeID
            );
        }

        $postNameDefaultExists = $base . '_opcom_default_selection_' . $classAttribute->attribute('id') . '_exists';
        if ($http->hasPostVariable($postNameDefaultExists)) {
            if ($http->hasPostVariable($base . "_opcom_default_list_" . $classAttributeID)) {
                $defaultValues = $http->postVariable($base . "_opcom_default_list_" . $classAttributeID);
                $content['default_list'] = (array)$defaultValues;
            } else {
                $content['default_list'] = [];
            }
        }
        $classAttribute->setContent($content);
        $classAttribute->store();

        return true;
    }

    function preStoreClassAttribute($classAttribute, $version)
    {
        $content = $classAttribute->content();
        return self::storeClassAttributeContent($classAttribute, $content);
    }

    function storeClassAttributeContent($classAttribute, $content)
    {
        if (is_array($content)) {
            $multipleChoice = $content['multiple_choice'];
            $defaultList = $content['default_list'];
            $default = implode('#', $defaultList);

            $classAttribute->setAttribute(self::DEFAULT_LIST_FIELD, $default);
            $classAttribute->setAttribute(self::MULTIPLE_CHOICE_FIELD, $multipleChoice);
        }
        return false;
    }

    function classAttributeContent($classAttribute)
    {
        $defaultList = $classAttribute->attribute(self::DEFAULT_LIST_FIELD);
        $multipleChoice = $classAttribute->attribute(self::MULTIPLE_CHOICE_FIELD);
        $defaultList = $this->explode($defaultList);
        $defaultList = OpenPAComuniItaliani::getCodesFromCodes($defaultList);
        $content = [
            'default_list' => $defaultList,
            'multiple_choice' => $multipleChoice,
        ];

        return $content;
    }

    /**
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @param mixed $currentVersion
     * @param eZContentObjectAttribute $originalContentObjectAttribute
     * @return void
     */
    function initializeObjectAttribute($contentObjectAttribute, $currentVersion, $originalContentObjectAttribute)
    {
        if ($currentVersion != false) {
            $dataText = $originalContentObjectAttribute->content();
            $contentObjectAttribute->setContent($dataText);
        } else {
            $default = $contentObjectAttribute->contentClassAttribute()->attribute(self::DEFAULT_LIST_FIELD);
            $contentObjectAttribute->setAttribute('data_text', $default);
        }
    }

    function validateObjectAttributeHTTPInput($http, $base, $contentObjectAttribute)
    {
        $validation = eZInputValidator::STATE_ACCEPTED;
        $postName = $base . '_opcom_selection_' . $contentObjectAttribute->attribute('id');
        if ($http->hasPostVariable($postName)) {
            $data = $http->postVariable($postName);
            if (empty($data) && $contentObjectAttribute->validateIsRequired()) {
                $validation = eZInputValidator::STATE_INVALID;
            }
        } elseif ($contentObjectAttribute->validateIsRequired()) {
            $validation = eZInputValidator::STATE_INVALID;
        }

        if ($validation === eZInputValidator::STATE_INVALID) {
            $contentObjectAttribute->setValidationError(
                ezpI18n::tr('kernel/classes/datatypes', 'Input required.')
            );

            return eZInputValidator::STATE_INVALID;
        }

        return eZInputValidator::STATE_ACCEPTED;
    }

    function fetchObjectAttributeHTTPInput($http, $base, $contentObjectAttribute)
    {
        $postName = $base . '_opcom_selection_' . $contentObjectAttribute->attribute('id');
        if ($http->hasPostVariable($postName)) {
            $data = (array)$http->postVariable($postName);
            $data = OpenPAComuniItaliani::getCodesFromCodes($data);
            $contentObjectAttribute->setAttribute('data_text', implode('#', $data));

            return true;
        }

        return false;
    }

    function objectAttributeContent($contentObjectAttribute)
    {
        $data = $this->explode($contentObjectAttribute->attribute('data_text'));

        return OpenPAComuniItaliani::fetchByCodes($data);
    }

    function getContentNameList($contentObjectAttribute)
    {
        $data = $this->explode($contentObjectAttribute->attribute('data_text'));
        return OpenPAComuniItaliani::getNamesFromCodes($data);
    }

    function metaData($contentObjectAttribute)
    {
        return implode(',', $this->getContentNameList($contentObjectAttribute));
    }

    function toString($contentObjectAttribute)
    {
        $string = $contentObjectAttribute->attribute('data_text');
        $data = OpenPAComuniItaliani::getCodesFromCodes($this->explode($string));
        return implode('#', $data);
    }

    function fromString($contentObjectAttribute, $string)
    {
        $data = OpenPAComuniItaliani::getCodesFromCodes($this->explode($string));
        return $contentObjectAttribute->setAttribute('data_text', implode('#', $data));
    }

    function title($contentObjectAttribute, $name = null)
    {
        return $this->getContentNameList($contentObjectAttribute)[0];
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
        $data = $this->getContentNameList($contentObjectAttribute);
        if (isset($data[0])) {
            $trans = eZCharTransform::instance();
            return $trans->transformByGroup($data[0], 'lowercase');
        }
        return '';
    }

    function sortKeyType()
    {
        return 'string';
    }

    function serializeContentClassAttribute($classAttribute, $attributeNode, $attributeParametersNode)
    {
        $multiple = $classAttribute->attribute(self::MULTIPLE_CHOICE_FIELD);
        $defaultList = $classAttribute->attribute(self::DEFAULT_LIST_FIELD);
        $dom = $attributeParametersNode->ownerDocument;
        $multipleNode = $dom->createElement('multiple');
        $multipleNode->appendChild($dom->createTextNode($multiple));
        $attributeParametersNode->appendChild($multipleNode);
        $defaultListNode = $dom->createElement('default-list');
        if ($defaultList) {
            $defaultListNode->appendChild($dom->createTextNode($defaultList));
        }
        $attributeParametersNode->appendChild($defaultListNode);
    }

    function unserializeContentClassAttribute($classAttribute, $attributeNode, $attributeParametersNode)
    {
        $multiple = $attributeParametersNode->getElementsByTagName('multiple')->item(0)->textContent;
        $defaultString = $attributeParametersNode->getElementsByTagName('default-list')->item(0)->textContent;
        $classAttribute->setAttribute(self::MULTIPLE_CHOICE_FIELD, $multiple);
        $classAttribute->setAttribute(self::DEFAULT_LIST_FIELD, $defaultString);
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
        $default = $classAttribute->attribute(self::DEFAULT_LIST_FIELD);
        if ($default !== '' && $default !== null) {
            $db = eZDB::instance();
            $default = "'" . $db->escapeString($default) . "'";
            $trans = eZCharTransform::instance();
            $defaultList = $this->explode($default);
            $lowerCasedDefault = $trans->transformByGroup($defaultList[0], 'lowercase');

            return ['data_text' => $default, 'sort_key_string' => $lowerCasedDefault];
        }

        return [];
    }

    function isSimpleStringInsertionSupported()
    {
        return true;
    }

    function insertSimpleString($object, $objectVersion, $objectLanguage, $objectAttribute, $string, &$result) {
        $result = [
            'errors' => [],
            'require_storage' => true,
        ];
        $data = OpenPAComuniItaliani::getCodesFromCodes($this->explode($string));
        $string = implode('#', $data);
        $objectAttribute->setAttribute('data_text', $string);
        $objectAttribute->setContent('data_text', $string);
        return true;
    }

    private function explode($string)
    {
        $list = explode('#', trim($string));
        if ($list[0] === ''){
            unset($list[0]);
        }

        return $list;
    }
}

eZDataType::register(OpenPAComuniItalianiType::DATA_TYPE_STRING, 'OpenPAComuniItalianiType');