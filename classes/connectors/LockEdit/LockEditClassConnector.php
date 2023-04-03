<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;
use Symfony\Component\Yaml\Yaml;

abstract class LockEditClassConnector extends ClassConnector
{
    /**
     * @var array
     */
    protected $sourceBlocks;

    /**
     * @var array
     */
    protected $currentBlocks = [];

    /**
     * @var string
     */
    protected $installerDataDir;

    /**
     * @var eZContentObject
     */
    protected $originalObject;

    public function setInstallerDataDir($installerDataDir)
    {
        $this->installerDataDir = rtrim($installerDataDir, '/');
    }

    public function setOriginalObject(eZContentObject $object)
    {
        $this->originalObject = $object;
        $this->getHelper()->setParameter('parent', $this->originalObject->mainParentNodeID());
    }

    public function getSchema()
    {
        $schema = parent::getSchema();
        $schema['title'] = $this->originalObject->attribute('name');

        return $schema;
    }

    public function getView()
    {
        $view = parent::getView();
        $view['layout'] = $this->getLayout();
        return $view;
    }

    public function submit()
    {
        $contents = $this->mapSubmitData($this->getSubmitData());

        $contentRepository = new ContentRepository();
        $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));

        $payload = new PayloadBuilder();
        $payload->setId((int)$this->getHelper()->getParameter('object'));
        foreach ($contents as $identifier => $value) {
            $payload->setData($this->helper->getSetting('language'), $identifier, $value);
        }
        $result = $contentRepository->update($payload->getArrayCopy(), true);
        $this->cleanup();
        $result['conversion'] = $contents;

        return $result;
    }

    abstract protected function fetchSourcePathInfo(): array;

    abstract protected function cleanSourceBlocks($blocks): ?array;

    protected function fetchSourceBlocks(): array
    {
        $filePath = $this->fetchSourcePathInfo()['path'] ?? false;
        $identifier = $this->fetchSourcePathInfo()['identifier'] ?? 'layout';

        if (!$filePath){
            return [];
        }
        $data = file_get_contents($filePath);
        $sourceData = Yaml::parse($data);

        $blocks = [];
        if (isset($sourceData['data'][$this->helper->getSetting('language')][$identifier]['global']['blocks'])){
            $blocks = $sourceData['data'][$this->helper->getSetting('language')][$identifier]['global']['blocks'];
        }elseif (isset($sourceData['data']['ita-IT'][$identifier]['global']['blocks'])){
            $blocks = $sourceData['data']['ita-IT'][$identifier]['global']['blocks'];
        }

        $blocks = $this->cleanSourceBlocks($blocks);

        return $blocks ?? [];
    }

    abstract protected function getLayout(): array;

    abstract public static function getContentClass(): eZContentClass;

    abstract protected function mapSubmitData($data): array;

    protected function findBlockById($id, $strict = false): ?array
    {
        if ($this->sourceBlocks === null) {
            $this->sourceBlocks = $this->fetchSourceBlocks();
        }
        if ($strict) {
            foreach ($this->sourceBlocks as $block) {
                if ($block['block_id'] === $id) {
                    return $block;
                }
            }
        }else {
            foreach ($this->currentBlocks as $block) {
                if ($block['block_id'] === $id) {
                    return $block;
                }
            }
        }

        return null;
    }

    protected function mapSingoloToRelation($block): ?array
    {
        if (is_string($block)) {
            $block = $this->findBlockById($block);
        }
        if (isset($block['valid_items'][0]) && $block['type'] == 'Singolo') {
            $object = eZContentObject::fetchByRemoteID($block['valid_items'][0]);
            if ($object instanceof eZContentObject) {
                return [
                    [
                        'id' => $object->attribute('id'),
                        'name' => $object->attribute('name'),
                        'class' => $object->contentClassIdentifier(),
                    ],
                ];
            }
        }

        return null;
    }

    protected function mapListaManualeToRelations($block): ?array
    {
        if (is_string($block)) {
            $block = $this->findBlockById($block);
        }
        if (isset($block['valid_items'][0]) && $block['type'] == 'ListaManuale') {
            $data = [];
            foreach ($block['valid_items'] as $objectId) {
                $object = eZContentObject::fetchByRemoteID($objectId);
                if ($object instanceof eZContentObject) {
                    $data[] = [
                        'id' => $object->attribute('id'),
                        'name' => $object->attribute('name'),
                        'class' => $object->contentClassIdentifier(),
                    ];
                }
            }

            return $data;
        }

        return null;
    }

    protected function mapRicercaToRelations($block): ?array
    {
        if (is_string($block)) {
            $block = $this->findBlockById($block);
        }
        if (isset($block['valid_items'][0]) && $block['type'] == 'Ricerca') {
            $data = [];
            foreach ($block['valid_items'] as $objectId) {
                $object = eZContentObject::fetchByRemoteID($objectId);
                if ($object instanceof eZContentObject) {
                    $data[] = [
                        'id' => $object->attribute('id'),
                        'name' => $object->attribute('name'),
                        'class' => $object->contentClassIdentifier(),
                    ];
                }
            }

            return $data;
        }

        return null;
    }

    protected function mapListaAutomaticaToBoolean($block): bool
    {
        if (is_string($block)) {
            $block = $this->findBlockById($block);
        }
        return $block['type'] == 'ListaAutomatica';
    }

    protected function mapEventiToBoolean($block): bool
    {
        if (is_string($block)) {
            $block = $this->findBlockById($block);
        }
        return $block['type'] == 'Eventi';
    }

    protected function mapArgomentiToRelations($block): ?array
    {
        if (is_string($block)) {
            $block = $this->findBlockById($block);
        }
        if (isset($block['valid_items'][0]) && $block['type'] == 'Argomenti') {
            $data = [];
            foreach ($block['valid_items'] as $objectId) {
                $object = eZContentObject::fetchByRemoteID($objectId);
                if ($object instanceof eZContentObject) {
                    $data[] = [
                        'id' => $object->attribute('id'),
                        'name' => $object->attribute('name'),
                        'class' => $object->contentClassIdentifier(),
                    ];
                }
            }

            return $data;
        }

        return null;
    }

    protected function mapCustomAttributeImageToRelation($block): ?array
    {
        if (is_string($block)) {
            $block = $this->findBlockById($block);
        }
        if (isset($block['custom_attributes']['image'])){
            $node = eZContentObjectTreeNode::fetch((int)$block['custom_attributes']['image']);
            if ($node instanceof eZContentObjectTreeNode) {
                return [[
                    'id' => $node->attribute('contentobject_id'),
                    'name' => $node->attribute('name'),
                    'class' => $node->attribute('class_identifier'),
                ]];
            }
        }

        return null;
    }

    protected function fetchMainNodeIDByObjectRemoteID($remoteId): int
    {
        $object = eZContentObject::fetchByRemoteID($remoteId);
        return $object instanceof eZContentObject ? (int)$object->mainNodeID() : 1;
    }
}