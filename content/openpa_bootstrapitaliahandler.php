<?php

class openpa_bootstrapitaliaHandler extends eZContentObjectEditHandler
{
    const ERROR_MESSAGE = "Popolare almeno un campo tra '%s' e '%s'";

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
            $fileName = 'file';
            $linkName = 'link';
            foreach ($contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') == 'file') {
                    if ($contentObjectAttribute->hasContent()){
                        $file = eZHTTPFile::UPLOADEDFILE_OK;
                    }else {
                        $httpFileName = $base . "_data_binaryfilename_" . $contentObjectAttribute->attribute("id");
                        $maxSize = 1024 * 1024 * $contentClassAttribute->attribute(eZBinaryFileType::MAX_FILESIZE_FIELD);
                        $file = eZHTTPFile::canFetch($httpFileName, $maxSize);
                    }
                    $fileName = $contentClassAttribute->attribute('name');
                } elseif ($contentClassAttribute->attribute('identifier') == 'link') {
                    $link = false;
                    if ($contentObjectAttribute->hasContent()){
                        $link = $contentObjectAttribute->content();
                    }elseif ($http->hasPostVariable($base . "_ezurl_url_" . $contentObjectAttribute->attribute("id"))) {
                        $link = $http->postVariable($base . "_ezurl_url_" . $contentObjectAttribute->attribute("id"));
                    }
                    $linkName = $contentClassAttribute->attribute('name');
                }
            }

            if ($file == eZHTTPFile::UPLOADEDFILE_DOES_NOT_EXIST && empty($link)) {
                $result = array('is_valid' => false, 'warnings' => [
                    ['text' => sprintf(self::ERROR_MESSAGE, $fileName, $linkName)]
                ]);
            }
        }

        return $result;
    }
}