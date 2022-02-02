<?php

class openpa_bootstrapitaliaHandler extends eZContentObjectEditHandler
{
    const FILE_ERROR_MESSAGE = "Popolare almeno un campo tra '%s', '%s' e '%s'";

    const CODE_ERROR_MESSAGE = "Il valore del campo '%s' è già presente a sistema (%s)";

    /**
     * @param eZHTTPTool $http
     * @param eZModule $module
     * @param eZContentClass $class
     * @param eZContentObject $object
     * @param eZContentObjectVersion $version
     * @param eZContentObjectAttribute[] $contentObjectAttributes
     * @param int $editVersion
     * @param string $editLanguage
     * @param string $fromLanguage
     * @param array $validationParameters
     * @return array
     */
    function validateInput($http, &$module, &$class, $object, &$version, $contentObjectAttributes, $editVersion, $editLanguage, $fromLanguage, $validationParameters)
    {
        $base = 'ContentObjectAttribute';
        $result = parent::validateInput($http, $module, $class, $object, $version, $contentObjectAttributes, $editVersion, $editLanguage, $fromLanguage, $validationParameters);

        if ($class->attribute('identifier') == 'document') {
            $file = eZHTTPFile::UPLOADEDFILE_OK;
            $link = true;
            $attachments = true;
            $hasUniqueCode = true;
            $duplicates = [];

            $fileName = 'file';
            $linkName = 'link';
            $attachmentsName = 'attachments';
            $documentCodeName = 'has_code';

            foreach ($contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') == 'file') {
                    if ($contentObjectAttribute->hasContent()) {
                        $file = eZHTTPFile::UPLOADEDFILE_OK;
                    } else {
                        $httpFileName = $base . "_data_binaryfilename_" . $contentObjectAttribute->attribute("id");
                        $maxSize = 1024 * 1024 * $contentClassAttribute->attribute(eZBinaryFileType::MAX_FILESIZE_FIELD);
                        $file = eZHTTPFile::canFetch($httpFileName, $maxSize);
                    }
                    $fileName = $contentClassAttribute->attribute('name');

                } elseif ($contentClassAttribute->attribute('identifier') == 'link') {
                    $link = false;
                    if ($contentObjectAttribute->hasContent()) {
                        $link = $contentObjectAttribute->content();
                    } elseif ($http->hasPostVariable($base . "_ezurl_url_" . $contentObjectAttribute->attribute("id"))) {
                        $link = $http->postVariable($base . "_ezurl_url_" . $contentObjectAttribute->attribute("id"));
                    }
                    $linkName = $contentClassAttribute->attribute('name');

                } elseif ($contentClassAttribute->attribute('identifier') == 'attachments') {
                    if ($contentClassAttribute->attribute('data_type_string') == OCMultiBinaryType::DATA_TYPE_STRING) {
                        $attachments = eZMultiBinaryFile::fetch($contentObjectAttribute->attribute('id'), $contentObjectAttribute->attribute('version'));
                    } else {
                        $attachments = $contentObjectAttribute->toString();
                    }
                    $attachmentsName = $contentClassAttribute->attribute('name');

                } elseif ($contentClassAttribute->attribute('identifier') == 'has_code') {
                    $inputData = $http->postVariable('ContentObjectAttribute_ezstring_data_text_' . $contentObjectAttribute->attribute('id'));
                    $duplicates = $this->getObjectIdListByAttributeDataText($contentObjectAttribute, $inputData);
                    if ($contentObjectAttribute->hasContent() && count($duplicates) > 0) {
                        $hasUniqueCode = false;
                    }
                    $documentCodeName = $contentClassAttribute->attribute('name');
                }
            }

            if ($file == eZHTTPFile::UPLOADEDFILE_DOES_NOT_EXIST && empty($link) && empty($attachments)) {
                $result = ['is_valid' => false, 'warnings' => [
                    ['text' => sprintf(self::FILE_ERROR_MESSAGE, $fileName, $linkName, $attachmentsName)],
                ]];
            }
            if (!$hasUniqueCode){
                $duplicateLinks = [];
                foreach ($duplicates as $duplicate){
                    $duplicateObject = eZContentObject::fetch((int)$duplicate);
                    $duplicateName = $duplicateObject instanceof eZContentObject ? $duplicateObject->attribute('name') : $duplicate;
                    $duplicateLinks[] = '<a href="/openpa/object/' . $duplicate . '" target="_blank">' . $duplicateName . '</a>';
                }
                $result['is_valid'] = false;
                $result['warnings'][] = [
                    'text' => sprintf(self::CODE_ERROR_MESSAGE, $documentCodeName, implode(', ', $duplicateLinks))
                ];
            }
        }

        return $result;
    }

    private function getObjectIdListByAttributeDataText(eZContentObjectAttribute $contentObjectAttribute, $inputData)
    {
        if (OpenPAINI::variable('AttributeHandlers', 'DocumentHasCodeUniqueCheck', 'disabled') == 'enabled') {
            $contentObjectID = $contentObjectAttribute->attribute('contentobject_id');
            $contentClassAttributeID = $contentObjectAttribute->attribute('contentclassattribute_id');
            $db = eZDB::instance();
            $query = "SELECT coa.contentobject_id as id
				FROM ezcontentobject co, ezcontentobject_attribute coa
				WHERE co.id = coa.contentobject_id
				AND co.current_version = coa.version
				AND co.status = " . eZContentObject::STATUS_PUBLISHED . "
				AND coa.contentobject_id <> " . $db->escapeString($contentObjectID) . "
				AND coa.contentclassattribute_id = " . $db->escapeString($contentClassAttributeID) . "
				AND coa.data_text = '" . $db->escapeString($inputData) . "'";


            $results = $db->arrayQuery($query);
            if (count($results) > 0) {
                return array_column($results, 'id');
            }
        }
        return [];
    }
}
