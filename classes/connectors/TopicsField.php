<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\RelationsField;

class TopicsField extends RelationsField
{
    private static $childrenCache = [];

    private $showAsTree = false;

    private $tree;

    private $treePath = [];
    /**
     * @var eZContentObjectTreeNode
     */
    private $topics;

    public function __construct($attribute, $class, $helper)
    {
        parent::__construct($attribute, $class, $helper);

        /** @var array $classContent */
        $classContent = $this->attribute->dataType()->classAttributeContent($this->attribute);
        $selectionType = (int)$classContent['selection_type'];

        $topicsContainer = eZContentObject::fetchByRemoteID('topics');
        if ($topicsContainer instanceof eZContentObject) {
            $this->topics = $topicsContainer->mainNode();
        }
        $topicClass = eZContentClass::fetchByIdentifier('topic');
        $this->showAsTree = $topicClass instanceof eZContentClass
            && $topicClass->attribute('is_container')
            && $selectionType == self::MODE_LIST_CHECKBOX
            && $this->topics instanceof eZContentObjectTreeNode;
    }

    public function getSchema()
    {
        if (!$this->showAsTree) {
            $schema = parent::getSchema();
        } else {
            $schema = array(
                'title' => $this->attribute->attribute('name'),
                'required' => (bool)$this->attribute->attribute('is_required')
            );
        }

        return $schema;
    }

    public function getOptions()
    {
        if (!$this->showAsTree) {
            $options = parent::getOptions();
        } else {
            $options = [
                "helper" => $this->attribute->attribute('description'),
                "label" => $this->attribute->attribute('name'),
                "name" => $this->getIdentifier(),
                "type" => 'tree',
            ];
            $options["tree"] = [
                'property_value' => 'id',
                'core' => array(
                    'data' => $this->getTree(),
                    'multiple' => true,
                    'themes' => [
                        'variant' => 'large'
                    ]
                ),
                'plugins' => array('search', 'checkbox'),
                'checkbox' => [
                    'keep_selected_style' => false,
                    'three_state' => false,
                    'cascade' => 'up+undetermined',
                ],
                'i18n' => [
                    'search' => \ezpI18n::tr('opendata_forms', "Search"),
                ]
            ];

            return $options;
        }

        return $options;
    }

    public function setPayload($postData)
    {
        if (!$this->showAsTree) {
            $payload = parent::setPayload($postData);
        } else {
            $this->getTree();
            $payload = [];
            $postData = explode(',', $postData);
            foreach ($postData as $item){
                $payload[] = $item;
                if (isset($this->treePath[$item])) {
                    $payload = array_merge($payload, $this->treePath[$item]);
                }
            }
            $payload = array_unique($payload);
        }

        return $payload;
    }

    private function getTree()
    {
        if ($this->tree === null) {
            $this->tree = [];

            /** @var eZContentObjectTreeNode $child */
            foreach ($this->getItemChildren($this->topics) as $child) {
                $this->tree[] = $this->createTreeItem($child);
            }
        }

        return $this->tree;
    }

    private function getItemChildren(eZContentObjectTreeNode $node)
    {
        if (!isset(self::$childrenCache[$node->attribute('node_id')])) {
            self::$childrenCache[$node->attribute('node_id')] = $node->childrenCount() > 0 ? $node->subTree([
                'Depth' => 1,
                'DepthOperator' => 'eq',
                'SortBy' => ['name', true]
            ]) : [];
        }

        return self::$childrenCache[$node->attribute('node_id')];
    }

    private function createTreeItem(eZContentObjectTreeNode $node, $parentIdList = [])
    {
        $this->treePath[$node->attribute('contentobject_id')] = $parentIdList;
        $childrenNodes = $this->getItemChildren($node);
        $item = array(
            'id' => $node->attribute('contentobject_id'),
            'text' => $node->attribute('name'),
            'state' => array(
                'selected' => in_array($node->attribute('contentobject_id'), $this->getData()),
                'opened' => in_array($node->attribute('contentobject_id'), $this->getData()) && count($childrenNodes),
                'disabled' => false
            ),
        );

        if (count($childrenNodes)) {
            $children = [];
            foreach ($childrenNodes as $childNode) {
                $children[] = $this->createTreeItem($childNode, array_merge($parentIdList, [$node->attribute('contentobject_id')]));
            }
            $item['children'] = $children;
        }

        return $item;
    }

}