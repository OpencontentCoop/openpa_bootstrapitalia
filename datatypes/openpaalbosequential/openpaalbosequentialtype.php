<?php

class OpenPAAlboSequentialType extends eZDataType
{
    const DATA_TYPE_STRING = "openpaalbosequential";

    private static $settings = [
        'tag_subtree_remote_id' => '984c6235761dac258fe8c245541095fa', // remote id of tag "Documenti Albo Pretorio"
        'tag_identifier' => 'document_type', // attribute identifier for tag
        'start_time_identifier' => 'publication_start_time', // attribute identifier for start time
        'end_time_identifier' => 'publication_end_time', // attribute identifier for end time
    ];

    public function __construct()
    {
        parent::__construct(
            self::DATA_TYPE_STRING,
            ezpI18n::tr('kernel/classes/datatypes', "Albo pretorio checkbox", 'Datatype name'),
            [
                'serialize_supported' => true,
                'object_serialize_map' => ['data_int' => 'value'],
                'translation_allowed' => false,
            ]
        );
    }

    function initializeObjectAttribute($contentObjectAttribute, $currentVersion, $originalContentObjectAttribute)
    {
        if ($currentVersion !== false) {
            $contentObjectAttribute->setAttribute("data_int", $originalContentObjectAttribute->attribute("data_int"));
            $contentObjectAttribute->setAttribute("data_text", $originalContentObjectAttribute->attribute("data_text"));
            $contentObjectAttribute->setAttribute(
                "data_float",
                $originalContentObjectAttribute->attribute("data_float")
            );
        }
    }

    private function getSequentialId($contentObjectAttribute): string
    {
        return $contentObjectAttribute->attribute("data_text");
    }

    private function hasSequentialId($contentObjectAttribute): string
    {
        return $contentObjectAttribute->attribute("data_text") !== '' &&
            $contentObjectAttribute->attribute("data_text") !== 'pending';
    }

    private function getValidationErrors(
        eZContentObjectAttribute $contentObjectAttribute,
        eZHTTPTool $http,
        string $base
    ): array {
        $errors = [];
        $object = $contentObjectAttribute->object();
        $dataMap = $object->dataMap();
        $tagAttribute = $dataMap[self::$settings['tag_identifier']] ?? null;
        try {
            $this->validateInputTag($tagAttribute, $http, $base);
        } catch (InvalidArgumentException $e) {
            $errors[] = $e->getMessage();
        }

        $startAttribute = $dataMap[self::$settings['start_time_identifier']] ?? null;
        $startTime = $endTime = null;
        try {
            $startTime = $this->validateInputDate($startAttribute, $http, $base);
        } catch (InvalidArgumentException $e) {
            $errors[] = 'start-time-' . $e->getMessage();
        }
        if ($startTime) {
            $endAttribute = $dataMap[self::$settings['end_time_identifier']] ?? null;
            try {
                $endTime = $this->validateInputDate($endAttribute, $http, $base);
            } catch (InvalidArgumentException $e) {
                $errors[] = 'end-time-' . $e->getMessage();
            }
            if ($endTime && $startTime >= $endTime) {
                $errors[] = 'end-date-before-start-date';
            }
        }
        return $errors;
    }

    private function validateInputTag($tagAttribute, eZHTTPTool $http, string $base): eZTags
    {
        if (!$tagAttribute) {
            throw new InvalidArgumentException('missing-tag-attribute');
        }
        if (
            !$http->hasPostVariable($base . '_eztags_data_text_' . $tagAttribute->attribute('id')) ||
            !$http->hasPostVariable($base . '_eztags_data_text2_' . $tagAttribute->attribute('id')) ||
            !$http->hasPostVariable($base . '_eztags_data_text3_' . $tagAttribute->attribute('id')) ||
            !$http->hasPostVariable($base . '_eztags_data_text4_' . $tagAttribute->attribute('id'))
        ) {
            throw new InvalidArgumentException('missing-tag-content');
        }
        $keywordString = trim(
            $http->postVariable($base . '_eztags_data_text_' . $tagAttribute->attribute('id'))
        );
        $parentString = trim(
            $http->postVariable($base . '_eztags_data_text2_' . $tagAttribute->attribute('id'))
        );
        $idString = trim(
            $http->postVariable($base . '_eztags_data_text3_' . $tagAttribute->attribute('id'))
        );
        $localeString = trim(
            $http->postVariable($base . '_eztags_data_text4_' . $tagAttribute->attribute('id'))
        );
        $tagsContent = eZTags::createFromStrings(
            $tagAttribute,
            $idString,
            $keywordString,
            $parentString,
            $localeString
        );
        $this->validateTagContent($tagsContent);

        return $tagsContent;
    }

    private function validateTagContent(eZTags $tags)
    {
        if ($tags->tagsCount() === 0) {
            throw new InvalidArgumentException('missing-tag-content');
        }
        $mainTag = eZTagsObject::fetchByRemoteID(self::$settings['tag_subtree_remote_id']);
        if (!$mainTag instanceof eZTagsObject) {
            throw new InvalidArgumentException('wrong-tag-configuration');
        }
        $countByPath = (int)eZTagsObject::count(eZTagsObject::definition(), [
            'id' => [$tags->attribute('parent_ids')],
            'path_string' => ['like', $mainTag->attribute('path_string') . '%'],
        ]);
        if ($countByPath === 0) {
            throw new InvalidArgumentException('wrong-child-tag');
        }
    }

    private function validateInputDate(
        $dateAttribute,
        eZHTTPTool $http,
        string $base,
        callable $callback = null
    ): ?string {
        if (!$dateAttribute) {
            throw new InvalidArgumentException('missing-date-attribute');
        }
        if ($http->hasPostVariable($base . '_date_year_' . $dateAttribute->attribute('id')) and
            $http->hasPostVariable($base . '_date_month_' . $dateAttribute->attribute('id')) and
            $http->hasPostVariable($base . '_date_day_' . $dateAttribute->attribute('id'))) {
            $year = $http->postVariable($base . '_date_year_' . $dateAttribute->attribute('id'));
            $month = $http->postVariable($base . '_date_month_' . $dateAttribute->attribute('id'));
            $day = $http->postVariable($base . '_date_day_' . $dateAttribute->attribute('id'));

            $state = eZDateTimeValidator::validateDate($day, $month, $year);
            if ($state == eZInputValidator::STATE_INVALID) {
                throw new InvalidArgumentException('invalid-date-format');
            }
            return mktime(0, 0, 0, $month, $day, $year);
        } else {
            throw new InvalidArgumentException('missing-date');
        }
    }

    private function formatError(array $errors)
    {
        $errorMap = [
            'missing-tag-attribute' => "Attributo tipologia di documento mancante",
            'missing-tag-content' => "Tipologia di documento non selezionata",
            'end-date-before-start-date' => "La data di fine pubblicazione deve essere successiva alla data di inizio pubblicazione",
            'invalid-year' => "Anno di pubblicazione non valido",
            'end-time-missing-date-attribute' => "Attributo data di fine pubblicazione mancante",
            'end-time-invalid-date-format' => "Formato data di fine pubblicazione non valido",
            'end-time-missing-date' => "Data di fine pubblicazione mancante",
            'start-time-missing-date-attribute' => "Attributo data di inizio pubblicazione mancante",
            'start-time-invalid-date-format' => "Formato data di inizio pubblicazione non valido",
            'start-time-missing-date' => "Data di inizio pubblicazione mancante",
            'wrong-tag-configuration' => "Configurazione tipologia di documento non valida",
            'wrong-child-tag' => "La tipologia di documento selezionata non è valida",
        ];
        $errorTexts = [];
        foreach ($errors as $error) {
            $errorTexts[] = ezpI18n::tr('openpa_bootstrapitalia/albo_pretorio/datatype', $errorMap[$error] ?? $error);
        }
        return implode(', ', $errorTexts);
    }

    function validateObjectAttributeHTTPInput($http, $base, $contentObjectAttribute)
    {
        $hasSequentialId = $this->hasSequentialId($contentObjectAttribute);
        $requireSequentialId = $http->hasPostVariable(
            $base . "_data_openpaalbo_" . $contentObjectAttribute->attribute("id")
        );

        if (!$hasSequentialId && $requireSequentialId) {
            $errors = $this->getValidationErrors($contentObjectAttribute, $http, $base);
            if (count($errors) > 0) {
                $contentObjectAttribute->setValidationError($this->formatError($errors));
                return eZInputValidator::STATE_INVALID;
            }
        }

        return eZInputValidator::STATE_ACCEPTED;
    }


    function fetchObjectAttributeHTTPInput($http, $base, $contentObjectAttribute)
    {
        $hasSequentialId = $this->hasSequentialId($contentObjectAttribute);
        $requireSequentialId = $http->hasPostVariable(
            $base . "_data_openpaalbo_" . $contentObjectAttribute->attribute("id")
        );
        if (!$hasSequentialId) {
            if (!$requireSequentialId) {
                $contentObjectAttribute->setAttribute("data_int", 0);
                $contentObjectAttribute->setAttribute("data_text", '');
                return true;
            } else {
                $contentObjectAttribute->setAttribute("data_int", 1);
                if (empty($this->getValidationErrors($contentObjectAttribute, $http, $base))) {
                    $contentObjectAttribute->setAttribute("data_text", 'pending');
                }
                return true;
            }
        }
        return false;
    }

    function metaData($contentObjectAttribute)
    {
        return $contentObjectAttribute->attribute("data_text");
    }

    function toString($contentObjectAttribute)
    {
        return $contentObjectAttribute->attribute('data_text');
    }

    function fromString($contentObjectAttribute, $string)
    {
        if (!empty($string) && !$this->hasSequentialId($contentObjectAttribute)) {
            $contentObjectAttribute->setAttribute('data_int', 1);
            $contentObjectAttribute->setAttribute('data_text', 'pending');
        }
    }

    function isIndexable()
    {
        return true;
    }

    function isInformationCollector()
    {
        return false;
    }

    function isTranslatable()
    {
        return false;
    }

    function sortKey($contentObjectAttribute)
    {
        return $contentObjectAttribute->attribute('data_text');
    }

    function sortKeyType()
    {
        return 'string';
    }

    function objectAttributeContent($contentObjectAttribute)
    {
        return $this->getSequentialId($contentObjectAttribute);
    }

    function title($contentObjectAttribute, $name = null)
    {
        return $contentObjectAttribute->attribute("data_int");
    }

    function hasObjectAttributeContent($contentObjectAttribute)
    {
        return $contentObjectAttribute->attribute("data_int") > 0;
    }

    function serializeContentClassAttribute($classAttribute, $attributeNode, $attributeParametersNode)
    {
        $defaultValue = (int)$classAttribute->attribute('data_int3');
        $dom = $attributeParametersNode->ownerDocument;
        $defaultValueNode = $dom->createElement('default-value');
        $defaultValueNode->setAttribute('is-set', $defaultValue ? 'true' : 'false');
        $attributeParametersNode->appendChild($defaultValueNode);
    }

    function unserializeContentClassAttribute($classAttribute, $attributeNode, $attributeParametersNode)
    {
        $defaultValue = strtolower(
                $attributeParametersNode->getElementsByTagName('default-value')->item(0)->getAttribute('is-set')
            ) == 'true';
        $classAttribute->setAttribute('data_int3', $defaultValue);
    }

    function supportsBatchInitializeObjectAttribute()
    {
        return true;
    }

    function batchInitializeObjectAttributeData($classAttribute)
    {
        $default = (int)$classAttribute->attribute("data_int3");
        return [
            'data_int' => $default,
            'sort_key_int' => $default,
        ];
    }

    function onPublish($contentObjectAttribute, $contentObject, $publishedNodes)
    {
        if ($contentObjectAttribute->attribute("data_int") > 0 &&
            $contentObjectAttribute->attribute("data_text") === 'pending') {
            try {
                $year = null;
                /** @var eZContentObjectVersion $version */
                $version = $contentObject->version($contentObjectAttribute->attribute('version'));
                if (!$version instanceof eZContentObjectVersion) {
                    throw new InvalidArgumentException('invalid-version ' . $contentObject->attribute('version'));
                }
                $dataMap = $version->dataMap();

                $tagAttribute = $dataMap[self::$settings['tag_identifier']] ?? null;
                if (!$tagAttribute instanceof eZContentObjectAttribute) {
                    throw new InvalidArgumentException('missing-tag-attribute');
                }
                $this->validateTagContent($tagAttribute->content());

                $startAttribute = $dataMap[self::$settings['start_time_identifier']] ?? null;
                if (!$startAttribute instanceof eZContentObjectAttribute || !$startAttribute->hasContent()) {
                    throw new InvalidArgumentException('start-time-missing-date-attribute');
                }
                $endAttribute = $dataMap[self::$settings['end_time_identifier']] ?? null;
                if (!$endAttribute instanceof eZContentObjectAttribute || !$endAttribute->hasContent()) {
                    throw new InvalidArgumentException('end-time-missing-end-attribute');
                }
                if ($startAttribute->toString() >= $endAttribute->toString()) {
                    throw new InvalidArgumentException('end-date-before-start-date');
                }
                $date = $startAttribute->content();
                if ($date instanceof eZDate) {
                    $year = (int)$date->attribute('year');
                }
                if ($year) {
                    self::createSequentialId($contentObjectAttribute, $year);
                } else {
                    throw new InvalidArgumentException('invalid-year');
                }
            } catch (Throwable $t) {
                eZDebug::writeError($t->getMessage() . ' in ' . $contentObject->attribute('id'), __METHOD__);
                $contentObjectAttribute->setAttribute("data_float", null);
                $contentObjectAttribute->setAttribute("data_text", null);
                $contentObjectAttribute->setAttribute("data_int", 0);
                $contentObjectAttribute->store();
            }
        }
    }

    private static function createSequentialId(eZContentObjectAttribute $contentObjectAttribute, int $year)
    {
        eZDB::instance()->lock('ezcontentobject_attribute');
        $contentClassAttributeId = intval($contentObjectAttribute->attribute('contentclassattribute_id'));
        $latest = floatval(
            eZDB::instance()->arrayQuery(
                "SELECT data_float FROM ezcontentobject_attribute 
            WHERE contentclassattribute_id = $contentClassAttributeId 
            AND data_type_string = 'openpaalbosequential'
            AND data_float > $year AND data_float < " . ($year + 1) . "
            ORDER BY data_float DESC LIMIT 1
        "
            )[0]['data_float'] ?? "$year.000000"
        );
        [$year, $latestSeq] = explode('.', $latest);
        $latestSeq = (int)$latestSeq;
        $next = $latestSeq + 1;
        $sequentialId = floatval($year . '.' . str_pad($next, 6, '0', STR_PAD_LEFT));
        eZDebug::writeDebug($contentObjectAttribute->attribute('contentobject_id') . " -> " . $sequentialId, __METHOD__);
        $contentObjectAttribute->setAttribute("data_float", $sequentialId);
        $contentObjectAttribute->setAttribute("data_text", $year . '/' . $next);
        $contentObjectAttribute->store();
        eZDB::instance()->unlock();
    }
}

eZDataType::register(OpenPAAlboSequentialType::DATA_TYPE_STRING, "OpenPAAlboSequentialType");