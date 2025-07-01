<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;
use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnectorFactory;

class ImageClassConnector extends ClassConnector
{
    private $folders = [];

    public function __construct(eZContentClass $class, $helper)
    {
        parent::__construct($class, $helper);
        if (OpenPAINI::variable('EditSettings', 'SelectImageFolder', 'disabled') !== 'disabled') {
            $rootNodeId = (int)OpenPAINI::variable('EditSettings', 'SelectImageFolder');
            if ($rootNodeId === 0) {
                $rootNodeId = 51;
            }
            /** @var eZContentObjectTreeNode[] $folderList */
            $folderList = eZContentObjectTreeNode::subTreeByNodeID([
                'ClassFilterType' => 'include',
                'ClassFilterArray' => ['folder'],
                'SortBy' => ['name', true],
            ], $rootNodeId);
            $this->folders['node-' . $rootNodeId] = 'Default';
            foreach ($folderList as $folder) {
                $this->folders['node-' . $folder->attribute('node_id')] = $folder->attribute('name');
            }
        }
    }


    public function getSchema()
    {
        $schema = parent::getSchema();
        $schema['properties']['proprietary_license']['required'] = true;
        $schema['dependencies'] = [
            'proprietary_license' => ['license'],
            'proprietary_license_source' => ['license'],
        ];

        if ($this->isCreate() && count($this->folders) > 0) {
            $schema["properties"][self::SELECT_PARENT_FIELD_IDENTIFIER] = [
                "title" => ezpI18n::tr('design/admin/node/view/full', 'Location'),
                "enum" => array_keys($this->folders),
            ];
        }

        return $schema;
    }

    public function getOptions()
    {
        $options = parent::getOptions();

        $options['fields']['proprietary_license']['dependencies'] = ['license' => 'Licenza proprietaria'];
        $options['fields']['proprietary_license_source']['dependencies'] = ['license' => 'Licenza proprietaria'];

        if ($this->isCreate() && count($this->folders) > 0) {
            $options["fields"][self::SELECT_PARENT_FIELD_IDENTIFIER] = [
                "helper" => ezpI18n::tr('design/standard/class/datatype', 'Select location'),
                "optionLabels" => array_values($this->folders),
                "hideNone" => true,
                "type" => "select",
                "multiple" => false,
            ];
        }
        return $options;
    }

    public function getFieldConnectors()
    {
        if ($this->fieldConnectors === null) {
            /** @var \eZContentClassAttribute[] $classDataMap */
            $classDataMap = $this->class->dataMap();
            $defaultCategory = \eZINI::instance('content.ini')->variable('ClassAttributeSettings', 'DefaultCategory');
            foreach ($classDataMap as $identifier => $attribute) {
                $category = $attribute->attribute('category');
                if (empty($category)) {
                    $category = $defaultCategory;
                }

                $add = true;

                if (!in_array($identifier, ['proprietary_license', 'proprietary_license_source'])) {
                    if ((bool)$this->getHelper()->getSetting('OnlyRequired')) {
                        $add = (bool)$attribute->attribute('is_required');
                    }

                    if ($add == true && $this->getHelper()->hasSetting('ShowCategories')) {
                        $add = in_array($category, (array)$this->getHelper()->getSetting('Categories'));
                    }

                    if ($add == true && $this->getHelper()->hasSetting('HideCategories')) {
                        $add = !in_array($category, (array)$this->getHelper()->getSetting('HideCategories'));
                    }
                }

                if ($add) {
                    $this->fieldConnectors[$identifier] = FieldConnectorFactory::load(
                        $attribute,
                        $this->class,
                        $this->getHelper()
                    );
                } else {
                    $this->copyFieldFromPrevVersion($identifier);
                }
            }
        }

        return $this->fieldConnectors;
    }

    protected function getPayloadFromArray(array $data)
    {
        if ($this->isCreate()
            && count($this->folders) > 0
            && isset($data[self::SELECT_PARENT_FIELD_IDENTIFIER])
            && isset($this->folders[$data[self::SELECT_PARENT_FIELD_IDENTIFIER]])
        ) {
            $nodeId = str_replace('node-', '', $data[self::SELECT_PARENT_FIELD_IDENTIFIER]);
            if (!eZContentObjectTreeNode::fetch((int)$nodeId)) {
                throw new \Exception(
                    "Error parsing node " . $data[self::SELECT_PARENT_FIELD_IDENTIFIER]
                    . var_export(eZContentObjectTreeNode::fetch((int)$nodeId), true)
                );
            }
            $this->getHelper()->setParameter('parent', $nodeId);
        }
        return parent::getPayloadFromArray($data);
    }
}