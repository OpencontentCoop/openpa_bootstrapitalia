<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;

abstract class LockEditClassConnector extends ClassConnector
{
    /**
     * @var array
     */
    protected $sourceBlocks;

    /**
     * @var array
     */
    protected $currentBlocks;

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
        $this->installerDataDir = rtrim($installerDataDir, '/') . '/';
    }

    public function setOriginalObject(eZContentObject $object)
    {
        $this->originalObject = $object;
    }

    public function getSchema()
    {
        $schema = parent::getSchema();
        $schema['title'] = $this->originalObject->attribute('name');

        return $schema;
    }

    abstract protected function fetchSourceBlocks(): array;

    abstract protected function getLayout(): array;

    abstract public static function getContentClass(): eZContentClass;

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

    public function getView()
    {
        $view = parent::getView();
        $view['layout'] = $this->getLayout();
        return $view;
    }
}