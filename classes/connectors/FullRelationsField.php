<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector;

class FullRelationsField extends FieldConnector
{
    const MODE_LIST_BROWSE = 0;
    const MODE_LIST_DROP_DOWN = 1;
    const MODE_LIST_RADIO = 2;
    const MODE_LIST_CHECKBOX = 3;
    const MODE_LIST_MULTIPLE = 4;
    const MODE_LIST_TEMPLATE_MULTIPLE = 5;
    const MODE_LIST_TEMPLATE_SINGLE = 6;

    protected $selectionType;

    protected $classConstraintList;

    protected $defaultPlacement;

    protected $isSelect;

    public function __construct($attribute, $class, $helper)
    {
        parent::__construct($attribute, $class, $helper);

        $classContent = $this->attribute->dataType()->classAttributeContent($this->attribute);
        $this->selectionType = (int)$classContent['selection_type'];
        $this->classConstraintList = (array)$classContent['class_constraint_list'];
        $this->defaultPlacement = isset($classContent['default_placement']['node_id']) ? $classContent['default_placement']['node_id'] : null;

        if ($this->selectionType == self::MODE_LIST_DROP_DOWN
            || $this->selectionType == self::MODE_LIST_MULTIPLE
            || $this->selectionType == self::MODE_LIST_TEMPLATE_SINGLE
            || $this->selectionType == self::MODE_LIST_TEMPLATE_MULTIPLE
        ) {
            $this->isSelect = true;
        }
    }

    public function getData()
    {
        $data = array();
        if ($this->getContent()) {
            $rawContent = $this->getContent();
            foreach ($rawContent['content'] as $content) {

                $item = $content['metadata'];
                $language = $this->getHelper()->getSetting('language');
                $itemName = $item['name'];
                $name = isset($itemName[$language]) ? $itemName[$language] : current($itemName);

                if ($this->selectionType == self::MODE_LIST_BROWSE) {
                    $data[] = array(
                        'id' => $item['id'],
                        'name' => $name,
                        'class' => $item['classIdentifier'],
                    );
                } elseif ($this->isSelect) {
                    $data[] = (string)$item['id'];
                } else {
                    $data[] = $item['id'];
                }
            }
        }

        return empty($data) ? null : $data;
    }

    public function getSchema()
    {
        $title = $this->attribute->attribute('name');
        if ($this->attribute->attribute('is_required')){
            $title .= ' *';
        }

        $schema = array(
            "title" => $title,
            'required' => (bool)$this->attribute->attribute('is_required'),
            'relation_mode' => $this->selectionType
        );

        if ($this->selectionType !== self::MODE_LIST_DROP_DOWN) {
            $schema['type'] = 'array';
        }

        if ($this->selectionType == self::MODE_LIST_CHECKBOX || $this->isSelect) {
            $schema['enum'] = array();
        }

        if ($this->selectionType == self::MODE_LIST_BROWSE) {
            $schema['minItems'] = (bool)$this->attribute->attribute('is_required') ? 1 : 0;
        }

        return $schema;
    }

    public function getOptions()
    {
        $options = array(
            "helper" => $this->attribute->attribute('description'),
        );
        if ($this->isSelect) {
            $options["label"] = $this->attribute->attribute('name');
            $options["type"] = "select";
            //            $options["useDataSourceAsEnum"] = true;
            $options["showMessages"] = false;
            $options["hideNone"] = false;
            $options["dataSource"] = $this->getDataSourceUrl();
            $options["multiple"] = $this->selectionType !== self::MODE_LIST_DROP_DOWN && ( $this->selectionType == self::MODE_LIST_MULTIPLE || $this->selectionType == self::MODE_LIST_TEMPLATE_MULTIPLE );

        } elseif ($this->selectionType == self::MODE_LIST_CHECKBOX || $this->selectionType == self::MODE_LIST_RADIO) {
            $options["label"] = $this->attribute->attribute('name');
            $options["name"] = $this->getIdentifier();
            $options["dataSource"] = $this->getDataSourceUrl();
            $options["multiple"] = $this->selectionType == self::MODE_LIST_CHECKBOX;
            $options["type"] = $this->selectionType == self::MODE_LIST_CHECKBOX ? "checkbox" : "radio";

        } elseif ($this->selectionType == self::MODE_LIST_BROWSE) {
            $options["type"] = 'relationbrowse';
            $options["browse"] = array(
                "subtree" => $this->defaultPlacement,
                "classes" => $this->classConstraintList,
                "selectionType" => 'multiple',
                "i18n" => FieldConnector\RelationField::i18n()
            );
        }


        return $options;
    }

    protected function getDataSourceUrl($fields = '[metadata.id=>metadata.name]')
    {
        $query = "select-fields $fields";
        if (is_array($this->classConstraintList) && !empty($this->classConstraintList)) {
            $query .= " classes [" . implode(',', $this->classConstraintList) . "]";
        }
        if ($this->defaultPlacement) {
            $query .= " subtree [" . $this->defaultPlacement . "]";
        }

        $query .= " sort [name=>asc] limit 3000";

        return "/opendata/api/content/search/?q=" . $query;
    }

    public function setPayload($postData)
    {
        $data = array();
        $postData = (array)$postData;
        foreach ($postData as $item) {
            if (is_numeric($item)) {
                $data[] = (int)$item;
            } elseif (is_array($item) && isset($item['id'])) {
                $data[] = (int)$item['id'];
            }
        }

        return empty($data) ? null : $data;
    }
}
