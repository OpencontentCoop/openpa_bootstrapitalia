<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;
use Opencontent\Opendata\Rest\Client\HttpClient;

class SharedLinkedPayloadBuilder
{
    const IMAGES_PARENT_NODE_ID = 51;

    private $targetUrl;

    private $targetClient;

    private $targetClasses = [];

    private $fallbackValues = [];

    private $payloads = [];

    private $remoteParentNodeId;

    public function __construct($targetUrl, $localContentId, $remoteParentNodeId)
    {
        $this->targetUrl = rtrim($targetUrl, '/');
        $this->targetClient = new HttpClient($this->targetUrl);
        $this->fallbackValues['image'] = [
            'license' => 'Licenza proprietaria',
            'proprietary_license' => 'Licenza proprietaria',
            'author' => 'Sconosciuto',
        ];
        $this->sourceData = $this->getLocalContent($localContentId);
        $this->remoteParentNodeId = $remoteParentNodeId;
    }

    /**
     * @return PayloadBuilder[]
     * @throws Exception
     */
    public function build(): array
    {
        $this->payloads[] = [
            $this->buildPayload($this->sourceData, $this->remoteParentNodeId),
        ];

        return $this->payloads;
    }

    private function buildPayload($sourceData, $parentNodeId): PayloadBuilder
    {
        $builder = new PayloadBuilder();
        $remoteId = $sourceData['metadata']['remoteId'];
        $languages = $sourceData['metadata']['languages'];
        $classIdentifier = $sourceData['metadata']['classIdentifier'];
        $data = $sourceData['data'];
        $targetClass = $this->getTargetClass($classIdentifier);
        $builder->setRemoteId($remoteId);
        $builder->setClassIdentifier($classIdentifier);
        $builder->setLanguages($languages);
        if (!is_numeric($parentNodeId)) {
            $parentNodeId = $this->getParentNodeId($parentNodeId);
        }
        $builder->setParentNode($parentNodeId);

        $errors = [];
        foreach ($targetClass['fields'] as $field) {
            $identifier = $field['identifier'];
            $dataType = $field['dataType'];
            $isRequired = $field['isRequired'];
            foreach ($languages as $language) {
                if (!empty($data[$language][$identifier])) {
                    $attributeData = $data[$language][$identifier];

                    if ($dataType === 'ezobjectrelationlist' || $dataType === 'ezobjectrelation') {
                        $relations = [];
                        foreach ($attributeData as $item) {
                            $relation = $this->buildRelationPayload($item);
                            if ($relation) {
                                $relations[] = $relation;
                            }
                        }
                        $builder->setData($language, $identifier, $relations);
                    } elseif ($dataType === 'ezimage') {
                        $builder->setData($language, $identifier, [
                            'url' => $this->getSourceUrl() . $attributeData['url'],
                            'filename' => $attributeData['filename'],
                        ]);
                    } elseif ($dataType === 'ocmultibinary') {
                        $fixAttributeData = [];
                        foreach ($attributeData as $datum) {
                            $url = $datum['url'];
                            $datum['filename'] = basename($url);
                            $datum['url'] = str_replace(basename($url), urlencode($datum['filename']), $url);
                            $fixAttributeData[] = $datum;
                        }
                        $builder->setData($language, $identifier, $fixAttributeData);
                    } else {
                        $builder->setData($language, $identifier, $attributeData);
                    }
                } elseif ($isRequired) {
                    if (isset($this->fallbackValues[$classIdentifier][$identifier])) {
                        $builder->setData($language, $identifier, $this->fallbackValues[$classIdentifier][$identifier]);
                    } else {
                        $errors[] = "Missing value for required field $identifier in $classIdentifier cloned from $remoteId";
                    }
                }
            }
        }

        if (count($errors)) {
            throw new Exception(implode(', ', $errors));
        }

        $builder->setOption('update_null_field', true);

        return $builder;
    }

    private function getLocalContent($id): array
    {
        $repository = new ContentRepository();
        $repository->setEnvironment(EnvironmentLoader::loadPreset('content'));
        return $repository->read($id, true);
    }

    private function getSourceUrl(): string
    {
        return 'https://' . eZINI::instance()->variable('SiteSettings', 'SiteURL');
    }

    private function getTargetClass($classIdentifier)
    {
        if (!isset($this->targetClasses[$classIdentifier])) {
            $this->targetClasses[$classIdentifier] = $this->targetClient->request(
                'GET',
                $this->targetUrl . '/api/opendata/v2/classes/' . $classIdentifier
            );
        }

        return $this->targetClasses[$classIdentifier];
    }

    private function getParentNodeId($objectRemoteId)
    {
        $targetContent = $this->targetClient->read($objectRemoteId);
        return $targetContent['metadata']['mainNodeId'];
    }

    private function buildRelationPayload($item)
    {
        $remoteId = $item['remoteId'];
        try {
            $this->targetClient->read($remoteId);
            return $remoteId;
        } catch (Exception $e) {
        }

        $classIdentifier = $item['classIdentifier'] ?? '?';
        if ($classIdentifier == 'image') {
            $remoteImage = $this->getLocalContent($remoteId);
            $this->payloads[] = [
                $this->buildPayload(
                    $remoteImage,
                    self::IMAGES_PARENT_NODE_ID
                ),
            ];
        } else {
            $payload = $this->buildSharedLinkPayload($item);
            $remoteId = $payload['metadata']['remoteId'];
            $this->payloads[] = [
                $payload,
            ];
        }

        return $remoteId;
    }

    private function buildSharedLinkPayload($item): PayloadBuilder
    {
        $builder = new PayloadBuilder();
        $builder->setParentNode($this->getParentNodeId('shared_links'));
        $builder->setClassIdentifier('shared_link');
        $remoteId = 'link-to-' . $item['remoteId'];
        $builder->setRemoteId($remoteId);
        $builder->setLanguages($item['languages']);
        foreach ($item['name'] as $language => $name) {
            $builder->setData($language, 'name', $name);
            $builder->setData($language, 'location', $this->getSourceUrl() . '/openpa/object/' . $item['remoteId']);
        }

        return $builder;
    }
}