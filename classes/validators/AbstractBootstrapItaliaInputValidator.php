<?php

abstract class AbstractBootstrapItaliaInputValidator implements BootstrapItaliaInputValidatorInterface
{
    const MULTIFIELD_ERROR_MESSAGE = "Popolare almeno un campo tra '%s', '%s' e '%s'";

    /**
     * @var eZHTTPTool
     */
    protected $http;

    /**
     * @var eZModule|null
     */
    protected $module;

    /**
     * @var eZContentClass
     */
    protected $class;

    /**
     * @var eZContentObject
     */
    protected $object;

    /**
     * @var eZContentObjectVersion
     */
    protected $version;

    /**
     * @var array
     */
    protected $contentObjectAttributes;

    /**
     * @var int
     */
    protected $editVersion;

    /**
     * @var string|null
     */
    protected $editLanguage;

    /**
     * @var string|null
     */
    protected $fromLanguage;

    /**
     * @var array
     */
    protected $validationParameters;

    /**
     * @var string
     */
    protected $base;

    public function initValidator(
        eZHTTPTool $http,
        ?eZModule $module,
        eZContentClass $class,
        eZContentObject $object,
        eZContentObjectVersion $version,
        array $contentObjectAttributes,
        $editVersion,
        $editLanguage,
        $fromLanguage,
        array $validationParameters,
        string $base
    ) {
        $this->http = $http;
        $this->module = $module;
        $this->class = $class;
        $this->object = $object;
        $this->version = $version;
        $this->contentObjectAttributes = $contentObjectAttributes;
        $this->editVersion = $editVersion;
        $this->editLanguage = $editLanguage;
        $this->fromLanguage = $fromLanguage;
        $this->validationParameters = $validationParameters;
        $this->base = $base;
    }

    abstract public function validate(): array;

    /**
     * @return bool|int
     */
    protected function hasBinary(
        eZContentClassAttribute $contentClassAttribute,
        eZContentObjectAttribute $contentObjectAttribute
    ) {
        if ($contentObjectAttribute->hasContent()) {
            return eZHTTPFile::UPLOADEDFILE_OK;
        } else {
            $httpFileName = $this->base . "_data_binaryfilename_" . $contentObjectAttribute->attribute("id");
            $maxSize = 1024 * 1024 * $contentClassAttribute->attribute(
                    eZBinaryFileType::MAX_FILESIZE_FIELD
                );
            return eZHTTPFile::canFetch($httpFileName, $maxSize);
        }
    }

    /**
     * @return mixed|string|void|null
     */
    protected function hasUrl(
        eZContentObjectAttribute $contentObjectAttribute
    ) {
        if ($contentObjectAttribute->hasContent()) {
            return $contentObjectAttribute->content();
        } elseif ($this->http->hasPostVariable(
            $this->base . "_ezurl_url_" . $contentObjectAttribute->attribute("id")
        )) {
            return $this->http->postVariable(
                $this->base . "_ezurl_url_"
                . $contentObjectAttribute->attribute("id")
            );
        }
    }

    /**
     * @return eZPersistentObject[]|false|string
     */
    protected function hasMultiBinary(
        eZContentClassAttribute $contentClassAttribute,
        eZContentObjectAttribute $contentObjectAttribute
    ) {
        if ($contentClassAttribute->attribute('data_type_string') == OCMultiBinaryType::DATA_TYPE_STRING) {
            return eZMultiBinaryFile::fetch(
                $contentObjectAttribute->attribute('id'),
                $contentObjectAttribute->attribute('version')
            );
        } else {
            return $contentObjectAttribute->toString();
        }
    }

    protected function hasBoolean(
        eZContentObjectAttribute $contentObjectAttribute
    ): bool {
        return $this->http->hasPostVariable(
            $this->base . "_data_boolean_" . $contentObjectAttribute->attribute("id")
        );
    }

    protected function hasText(
        eZContentObjectAttribute $contentObjectAttribute
    ): bool {
        $varName = $this->base . "_data_text_" . $contentObjectAttribute->attribute("id");
        $text = $this->http->hasPostVariable($varName) ? $this->http->postVariable($varName) : '';
        $text = strip_tags($text);
        $text = trim($text);
        return !empty($text);
    }

    protected function hasInt(
        eZContentObjectAttribute $contentObjectAttribute
    ): bool {
        $varName = $this->base . "_data_integer_" . $contentObjectAttribute->attribute("id");
        $value = $this->http->hasPostVariable($varName) ? $this->http->postVariable($varName) : false;
        return !empty($value);
    }

    protected function hasRelations(
        eZContentObjectAttribute $contentObjectAttribute
    ): bool {
        $varName = $this->base . "_data_object_relation_list_" . $contentObjectAttribute->attribute("id");
        $hasData = $this->http->hasPostVariable($varName) ? $this->http->postVariable($varName) : false;
        return is_array($hasData)
            && (
                count($hasData) > 1
                || $hasData[0] !== 'no_relation'
            );
    }

    protected function hasGeo(
        eZContentObjectAttribute $contentObjectAttribute
    ): bool {
        $varName = $this->base . "_data_gmaplocation_address_" . $contentObjectAttribute->attribute("id");
        $value = $this->http->hasPostVariable($varName) ? $this->http->postVariable($varName) : false;
        return !empty($value);
    }

    protected function getTags(
        eZContentObjectAttribute $contentObjectAttribute
    ): ?eZTags {
        $contentObjectAttributeId = $contentObjectAttribute->attribute('id');

        if (!$this->http->hasPostVariable($this->base . '_eztags_data_text_' . $contentObjectAttributeId)) {
            return null;
        }
        if (!$this->http->hasPostVariable($this->base . '_eztags_data_text2_' . $contentObjectAttributeId)) {
            return null;
        }
        if (!$this->http->hasPostVariable($this->base . '_eztags_data_text3_' . $contentObjectAttributeId)) {
            return null;
        }
        if (!$this->http->hasPostVariable($this->base . '_eztags_data_text4_' . $contentObjectAttributeId)) {
            return null;
        }
        $keywordString = trim(
            $this->http->postVariable($this->base . '_eztags_data_text_' . $contentObjectAttributeId)
        );
        $parentString = trim(
            $this->http->postVariable($this->base . '_eztags_data_text2_' . $contentObjectAttributeId)
        );
        $idString = trim($this->http->postVariable($this->base . '_eztags_data_text3_' . $contentObjectAttributeId));
        $localeString = trim(
            $this->http->postVariable($this->base . '_eztags_data_text4_' . $contentObjectAttributeId)
        );

        return eZTags::createFromStrings(
            $contentObjectAttribute,
            $idString,
            $keywordString,
            $parentString,
            $localeString
        );
    }

    protected function hasInputData(
        eZContentClassAttribute $contentClassAttribute,
        eZContentObjectAttribute $contentObjectAttribute
    ): bool {
        switch ($contentClassAttribute->attribute('data_type_string')) {
            case eZBinaryFileType::DATA_TYPE_STRING:
                return $this->hasBinary($contentClassAttribute, $contentObjectAttribute);

            case eZURLType::DATA_TYPE_STRING:
                return $this->hasUrl($contentObjectAttribute);

            case OCMultiBinaryType::DATA_TYPE_STRING:
                return $this->hasMultiBinary($contentClassAttribute, $contentObjectAttribute);

            case eZBooleanType::DATA_TYPE_STRING:
                return $this->hasBoolean($contentObjectAttribute);

            case eZStringType::DATA_TYPE_STRING:
            case eZTextType::DATA_TYPE_STRING:
            case eZXMLTextType::DATA_TYPE_STRING:
                return $this->hasText($contentObjectAttribute);

            case eZIntegerType::DATA_TYPE_STRING:
                return $this->hasInt($contentObjectAttribute);

            case eZObjectRelationListType::DATA_TYPE_STRING:
                return $this->hasRelations($contentObjectAttribute);
        }

        eZDebug::writeError(
            sprintf(
                'Datatype %s of attribute %s is not handled by custom validator',
                $contentClassAttribute->attribute('data_type_string'),
                $contentClassAttribute->attribute('identifier')
            ),
            get_called_class()
        );
        return false;
    }
}