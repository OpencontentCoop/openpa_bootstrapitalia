<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\TagsField;

class TreeTagsFieldConnector extends TagsField
{
    public function getSchema()
    {        
        $schema =  array(
            'title'    => $this->attribute->attribute('name'),
            'required' => (bool)$this->attribute->attribute('is_required')            
        );

        return $schema;

    }

    public function getOptions()
    {
        $options = array(
            "helper" => $this->attribute->attribute('description'),
        );
        $options["label"] = $this->attribute->attribute('name');
        $options["name"] = $this->getIdentifier();
        $options["subtree_limit"] = $this->attribute->attribute(self::SUBTREE_LIMIT_FIELD);        
        $options["type"] = "tree";
        $options["tree"] = array(
            'property_value' => 'text',
            'core' => array(
                'data' => $this->getTagTree($this->attribute->attribute(self::SUBTREE_LIMIT_FIELD)),
                'multiple' => $this->attribute->attribute(self::MAX_TAGS_FIELD) != 1,
                'themes' => [
                    'variant' => 'large'
                ]
            ),
            'plugins' => array('search'),
            'i18n' => [
                'search' => \ezpI18n::tr('opendata_forms', "Search"),
            ]
        );

        return $options;

    }

    private function getTagTree($tagID)
    {        
        $result = array();
        $tag = eZTagsObject::fetch($tagID);
        if (!$tag instanceof eZTagsObject) {
            return $result;
        }

        $lastModified = $tag->attribute('modified');
        $cacheFilePath = eZSys::cacheDirectory() . '/openpa/tags_tree/' . $tag->attribute('id') . '.cache';
        $result = eZClusterFileHandler::instance($cacheFilePath)->processCache(
            function ($file) {
                $content = include($file);

                return $content;
            },
            function () use ($tag) {
                $content = [];
                foreach ($tag->getChildren() as $child) {
                    $item = $this->getTreeItem($child);
                    $content[] = $item;
                }

                return array(
                    'content' => $content,
                    'scope' => 'cache',
                    'datatype' => 'php',
                    'store' => true
                );
            },
            null,
            $lastModified
        );

        $selected = $this->getData();
        if (!empty($selected)){            
            foreach ($result as &$item) {                
                if ($this->hasSelectedText($item, $selected)){                    
                    $this->setSelected($item, $selected);
                }
            }
        }

        return $result;
    }

    private function getTreeItem(eZTagsObject $tag)
    {
        $item = array(
            'text' => $tag->getKeyword(),
            'state' => array(
               'opened' => false,
               'disabled' => false
            ),
        );
        if ($tag->getChildrenCount()){
            $children = array();
            foreach ($tag->getChildren() as $child) {
                $children[] = $this->getTreeItem($child);
            }
            $item['state']['disabled'] = true;
            $item['children'] = $children;
        }

        return $item;
    }

    private function hasSelectedText($item, $selected)
    {
        if (in_array($item['text'], $selected)){      
            return true;
        }

        if (isset($item['children'])){            
            foreach ($item['children'] as $child) {
                $hasSelectedText = $this->hasSelectedText($child, $selected);
                if ($hasSelectedText){
                    return true;
                }
            }
        }

        return false;
    }

    private function setSelected(&$item, $selected)
    {
        if (in_array($item['text'], $selected)){
            $item['state']['selected'] = true;
        }
        $item['state']['opened'] = true;
        foreach ($item['children'] as &$child) {
            $this->setSelected($child, $selected);
        }
    }
}