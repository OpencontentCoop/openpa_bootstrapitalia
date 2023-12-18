<?php

class OpenPABootstrapItaliaIcon extends eZPersistentObject
{
    private $node;

    public static function definition()
    {
        static $def = [
            "fields" => [
                'node_id' => [
                    'name' => 'node_id',
                    'datatype' => 'integer',
                    'default' => 0,
                    'required' => true,
                    'foreign_class' => 'eZContentObjectTreeNode',
                    'foreign_attribute' => 'node_id',
                    'multiplicity' => '0..1',
                ],
                'contentobject_attribute_id' => [
                    'name' => 'contentobject_attribute_id',
                    'datatype' => 'integer',
                    'default' => 0,
                    'required' => true,
                    'foreign_class' => 'eZContentObjectAttribute',
                    'foreign_attribute' => 'id',
                    'multiplicity' => '1..*',
                ],
                'icon_text' => [
                    'name' => 'icon_text',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => true,
                ],
            ],
            'keys' => ['node_id', 'icon_text'],
            'function_attributes' => [
                'node' => 'getNode',
                'full_label' => 'getFullLabel',
            ],
            'class_name' => 'OpenPABootstrapItaliaIcon',
            'name' => 'openpabootstrapitaliaicon',
        ];

        return $def;
    }

    public static function createWithNodeList(array $nodeList, $iconText, $attributeId)
    {
        eZDB::instance()->begin();
        foreach ($nodeList as $nodeId) {
            $item = new OpenPABootstrapItaliaIcon([
                'node_id' => $nodeId,
                'contentobject_attribute_id' => $attributeId,
                'icon_text' => $iconText,
            ]);
            $item->store();
        }
        eZDB::instance()->commit();
    }

    public static function removeByContentObjectAttributeId($attributeId)
    {
        $conds = ['contentobject_attribute_id' => (int)$attributeId];
        eZPersistentObject::removeObject(self::definition(), $conds, null);
    }

    /**
     * @param eZContentObjectTreeNode $node
     * @param bool $asObject
     * @return OpenPABootstrapItaliaIcon[]|null
     */
    public static function fetchByNode(eZContentObjectTreeNode $node, $asObject = true)
    {
        $pathArray = $node->pathArray();
        $conds = ['node_id' => [$pathArray]];
        return parent::fetchObjectList(
            self::definition(),
            null,
            $conds,
            null,
            null,
            $asObject
        );
    }

    public function setNode($node)
    {
        $this->node = $node;
    }

    public function getNode()
    {
        if ($this->node === null) {
            $this->node = eZContentObjectTreeNode::fetch((int)$this->attribute('node_id'));
        }

        return $this->node;
    }

    public function getFullLabel(): string
    {
        $this->node = $this->getNode();
        $nameParts = [];
        if (is_array($this->node)) {
            $node = eZContentObjectTreeNode::fetch((int)$this->attribute('node_id'));
            if ($node instanceof eZContentObjectTreeNode){
                $nameParts[] = $node->attribute('name');
            }
            $nameParts[] = $this->node['name'];
        }
        if ($this->node instanceof eZContentObjectTreeNode) {
            $nameParts[] = $this->node->attribute('name');
        }
        $nameParts = array_unique($nameParts);

        return implode(' - ', $nameParts);
    }
}

