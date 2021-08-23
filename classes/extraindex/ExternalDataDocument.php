<?php

use Opencontent\OpenApi\Exceptions\NotFoundException;

class ExternalDataDocument extends OpenPATempletizable implements JsonSerializable
{
    private $isExternalData = true;

    /**
     * @var string
     */
    private $language = 'ita-IT';

    private $isValid = true;

    private $version;

    public function __construct($data = null)
    {
        if (isset($data['version'])) {
            $this->version = $data['version'];
            unset($data['version']);
        }

        parent::__construct($data);

        $keys = array_keys($this->data);
        if (!empty(array_diff([
            'guid',
            'source_name',
            'source_uri',
            'uri',
            'name',
            'abstract'
        ], $keys))) {
            $this->isValid = false;
        }

        if (empty($this->data['guid'])) {
            $this->isValid = false;
        }
        if (empty($this->data['source_name'])) {
            $this->isValid = false;
        }
        if (empty($this->data['source_uri'])) {
            $this->isValid = false;
        }
        if (empty($this->data['name'])) {
            $this->isValid = false;
        }
        if (empty($this->data['uri'])) {
            $this->isValid = false;
        }

        if (!isset($this->data['published_at'])) {
            $this->data['published_at'] = time();
        }

        if (!isset($this->data['modified_at'])) {
            $this->data['modified_at'] = time();
        }

        // validate $data['attachments']
        if (isset($this->data['attachments'])) {
            $this->setAttachments($this->data['attachments']);
        }

        $this->data['abstract'] = $this->cleanHtml($this->data['abstract']);
        $this->data['is_external_data'] = true;
    }

    /**
     * @param array $attachments
     */
    public function setAttachments($attachments)
    {
        $this->data['attachments'] = [];
        foreach ($attachments as $attachment) {
            if (isset($attachment['name'], $attachment['uri'])) {
                $this->data['attachments'][] = $attachment;
            }
        }
    }

    private function cleanHtml($htmlContent)
    {
        $htmlContent = strip_tags(trim($htmlContent), '<p><a><i><b><strong><em>');

        $htmlParser = new SQLIXMLInputParser();
        $htmlParser->setParseLineBreaks(true);
        $document = $htmlParser->process($htmlContent);

        $outputHandler = new eZXHTMLXMLOutput($document->saveXML(), false);
        $richContent = $outputHandler->outputText();

        return $richContent;
    }

    public static function fromSolrResult($resultArray)
    {
        if (!isset($resultArray['attr_source_name_s'])) {
            try {
                $resultArray = (new eZSolrExternalDataAware())->findExternalDocumentByGuid($resultArray['meta_guid_ms']);
            } catch (NotFoundException $e) {
            }
        }

        $data = [
            'guid' => str_replace('ext_', '', $resultArray['meta_guid_ms']),
            'published_at' => strtotime($resultArray['meta_published_dt']),
            'modified_at' => strtotime($resultArray['meta_modified_dt']),
            'image' => isset($resultArray['attr_image_s']) ? $resultArray['attr_image_s'] : '',
            'source_name' => $resultArray['attr_source_name_s'],
            'source_uri' => $resultArray['attr_source_uri_s'],
            'uri' => $resultArray['attr_uri_s'],
            'name' => $resultArray['meta_name_t'],
            'abstract' => $resultArray['attr_abstract_t'],
            'attachments' => [],
        ];

        if (isset($resultArray['meta_contentclass_id_si'])) {
            $data['class_identifier'] = eZContentClass::classIdentifierByID((int)$resultArray['meta_contentclass_id_si']);
        }

        if (isset($resultArray['subattr_extradata__attachment_uri____s'])) {
            foreach ($resultArray['subattr_extradata__attachment_uri____s'] as $index => $url) {
                $data['attachments'][] = [
                    'name' => $resultArray['subattr_extradata__attachment_name____s'][$index],
                    'uri' => $url
                ];
            }
        }

        if (isset($resultArray['_version_'])) {
            $data['version'] = $resultArray['_version_'];
        }

        return new ExternalDataDocument($data);
    }

    public function hasValidData()
    {
        return $this->isValid;
    }

    /**
     * @return string
     */
    public function getGuid()
    {
        return $this->data['guid'];
    }

    /**
     * @param string $guid
     */
    public function setGuid($guid)
    {
        $this->data['guid'] = $guid;
    }

    /**
     * @return bool
     */
    public function isExternalData()
    {
        return $this->isExternalData;
    }

    /**
     * @return string
     */
    public function getImage()
    {
        return isset($this->data['image']) ? $this->data['image'] : null;
    }

    /**
     * @param string $image
     */
    public function setImage($image)
    {
        $this->data['image'] = $image;
    }

    /**
     * @return string
     */
    public function getSourceName()
    {
        return $this->data['source_name'];
    }

    /**
     * @param string $sourceName
     */
    public function setSourceName($sourceName)
    {
        $this->data['source_name'] = $sourceName;
    }

    /**
     * @return string
     */
    public function getClassIdentifier()
    {
        return $this->data['class_identifier'];
    }

    /**
     * @param string $sourceName
     */
    public function setClassIdentifier($sourceName)
    {
        $this->data['class_identifier'] = $sourceName;
    }

    public function hasClassIdentifier()
    {
        return isset($this->data['class_identifier']) && !empty($this->data['class_identifier']);
    }

    /**
     * @return string
     */
    public function getSourceUri()
    {
        return $this->data['source_uri'];
    }

    /**
     * @param string $sourceUri
     */
    public function setSourceUri($sourceUri)
    {
        $this->data['source_uri'] = $sourceUri;
    }

    /**
     * @return string
     */
    public function getUri()
    {
        return $this->data['uri'];
    }

    /**
     * @param string $uri
     */
    public function setUri($uri)
    {
        $this->data['uri'] = $uri;
    }

    /**
     * @return string
     */
    public function getName()
    {
        return $this->data['name'];
    }

    /**
     * @param string $name
     */
    public function setName($name)
    {
        $this->data['name'] = $name;
    }

    /**
     * @return string
     */
    public function getAbstract()
    {
        return $this->data['abstract'];
    }

    /**
     * @param string $abstract
     */
    public function setAbstract($abstract)
    {
        $this->data['abstract'] = $abstract;
    }

    /**
     * @return array
     */
    public function getAttachments()
    {
        return isset($this->data['attachments']) ? (array)$this->data['attachments'] : [];
    }

    /**
     * @return string
     */
    public function getLanguage()
    {
        return $this->language;
    }

    /**
     * @param string $language
     */
    public function setLanguage($language)
    {
        $this->language = $language;
    }

    public function jsonSerialize()
    {
        $data = $this->data;
        unset($data['is_external_data']);

        return $data;
    }

    /**
     * @return int
     */
    public function getPublished()
    {
        return $this->data['published_at'];
    }

    /**
     * @param int $published
     */
    public function setPublished($published)
    {
        $this->data['published_at'] = $published;
    }

    /**
     * @return int
     */
    public function getModified()
    {
        return $this->data['modified_at'];
    }

    /**
     * @param int $modified
     */
    public function setModified($modified)
    {
        $this->data['modified_at'] = $modified;
    }

    public function getVersion()
    {
        return (string)$this->version;
    }
}