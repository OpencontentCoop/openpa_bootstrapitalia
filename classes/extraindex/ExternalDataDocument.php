<?php

use Opencontent\OpenApi\Exceptions\NotFoundException;
use Opencontent\Opendata\Api\EnvironmentSettings;
use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\Api\Values\ContentData;
use Opencontent\Opendata\Api\Values\ExtraData;
use Opencontent\Opendata\Api\Values\Metadata;

class ExternalDataDocument extends OpenPATempletizable implements JsonSerializable
{
    private $isExternalData = true;

    /**
     * @var string
     */
    private $language = 'ita-IT';

    private $isValid = true;

    private $version;

    private $raw;

    public function __construct($data = null, $raw = null)
    {
        $this->raw = $raw;
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

        if (!is_numeric($this->data['published_at'])){
            $this->data['published_at'] = strtotime($this->data['published_at']);
        }

        if (!isset($this->data['modified_at'])) {
            $this->data['modified_at'] = time();
        }

        if (!is_numeric($this->data['modified_at'])){
            $this->data['modified_at'] = strtotime($this->data['modified_at']);
        }

        // validate $data['attachments']
        if (isset($this->data['attachments'])) {
            $this->setAttachments($this->data['attachments']);
        }

        if (isset($this->data['types'])) {

        }

        if (isset($this->data['topics'])) {

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

    public static function filterEngineClass(string $className): string
    {
        return $className === eZSolr::class ? eZSolrExternalDataAware::class : $className;
    }

    public static function filterOpendataSearchResult($extraDocument, $limitation): ?Content
    {
        if ($extraDocument instanceof ExternalDataDocument){
            $locale = $extraDocument->getLanguage();
            $content = new Content();
            $content->metadata = new Metadata([
                'id' => 0,
                'currentVersion' => 0,
                'remoteId' => $extraDocument->getGuid(),
                'classIdentifier' => $extraDocument->getClassIdentifier(),
                'languages' => [$locale],
                'name' => [$locale => $extraDocument->getName()],
                'ownerId' => 0,
                'ownerName' => 'External',
                'mainNodeId' => 0,
                'mainNodeRemoteId' => '',
                'parentNodes' => [],
                'assignedNodes' => [],
                'sectionIdentifier' => 'standard',
                'sectionId' => '1',
                'stateIdentifiers' => [],
                'stateIds' => [],
                'published' => date( 'c', (int)$extraDocument->getPublished()),
                'modified' => date( 'c', (int)$extraDocument->getModified()),
            ]);
            $extraDocumentArray = (array)$extraDocument->jsonSerialize();
            $extraContent = [];
            $class = $extraDocument->getClass();
            if ($class instanceof eZContentClass){
                foreach ($class->dataMap() as $identifier => $attribute){
                    $extraContent[$identifier] = [
                        'identifier' => $extraDocument->getClassIdentifier() . '/' . $identifier,
                        'content' => null,
                        'datatype' => $attribute->attribute('data_type_string'),
                    ];
                }
            }
            $extraContent['external-document'] = [
                'identifier' => $extraDocument->getClassIdentifier() . '/external-document',
                'content' => $extraDocumentArray,
                'datatype' => 'object',
            ];
            $content->data = new ContentData([
                $locale => $extraContent
            ]);
            $content->extradata = new ExtraData(['is_external_document' => $extraDocument]);
            return $content;
        }

        return null;
    }

    public static function filterSearchContent(Content $content, EnvironmentSettings $environmentSettings)
    {
        return $environmentSettings instanceof EnvironmentExternalDataAwareInterface ?
            $environmentSettings->filterContent($content) :
            $content;
    }

    public static function generateView($content, $ViewMode): string
    {
        $currentErrorReporting = error_reporting();
        $templateUri = "design:extraindex/{$ViewMode}.tpl";
        $tpl = eZTemplate::factory();
        $tpl->setVariable('content', $content->jsonSerialize());
//        echo '<pre>';echo $tpl->fetch($templateUri);eZDisplayDebug();eZExecution::cleanExit();
        return $tpl->fetch($templateUri);
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
        return $this->data['class_identifier'] ?? '';
    }

    /**
     * @param string $sourceName
     */
    public function setClassIdentifier($sourceName)
    {
        $this->data['class_identifier'] = $sourceName;
    }

    public function getClass()
    {
        $identifier = $this->getClassIdentifier();

        return !empty($identifier) ? eZContentClass::fetch(eZContentClass::classIDByIdentifier($identifier)) : null;
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
        $this->data['language'] = $this->getLanguage();
        $this->data['published_at'] = date('c', $this->getPublished());
        $this->data['modified_at'] = date('c', $this->getModified());
        return $this->data;
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

    /**
     * @return mixed|null
     */
    public function getRaw()
    {
        return $this->raw;
    }

    /**
     * @param mixed $raw
     */
    public function setRaw($raw): void
    {
        $this->raw = $raw;
    }

    public function getTypes()
    {
        return $this->data['types'] ?? [];
    }

    public function getTopics()
    {
        return $this->data['topics'] ?? [];
    }
}