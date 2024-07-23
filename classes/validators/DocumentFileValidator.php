<?php

class DocumentFileValidator extends AbstractBootstrapItaliaInputValidator
{
    public function validate(): array
    {
        if ($this->class->attribute('identifier') == 'document') {
            $file = eZHTTPFile::UPLOADEDFILE_OK;
            $link = true;
            $attachments = true;

            $fileName = 'file';
            $linkName = 'link';
            $attachmentsName = 'attachments';

            foreach ($this->contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();

                if ($contentClassAttribute->attribute('identifier') == 'file') {
                    $file = $this->hasBinary($contentClassAttribute, $contentObjectAttribute);
                    $fileName = $contentClassAttribute->attribute('name');
                } elseif ($contentClassAttribute->attribute('identifier') == 'link') {
                    $link = $this->hasUrl($contentObjectAttribute);
                    $linkName = $contentClassAttribute->attribute('name');
                } elseif ($contentClassAttribute->attribute('identifier') == 'attachments') {
                    $attachments = $this->hasMultiBinary($contentClassAttribute, $contentObjectAttribute);
                    $attachmentsName = $contentClassAttribute->attribute('name');
                }
            }

            if ($file == eZHTTPFile::UPLOADEDFILE_DOES_NOT_EXIST && empty($link) && empty($attachments)) {
                return [
                    'identifier' => 'file',
                    'text' => sprintf(self::MULTIFIELD_ERROR_MESSAGE, $fileName, $linkName, $attachmentsName),
                ];
            }
        }

        return [];
    }
}