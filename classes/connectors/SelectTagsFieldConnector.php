<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\TagsField;

class SelectTagsFieldConnector extends TagsField
{
    public function getSchema()
    {
        $tagList = $this->getTagChildren($this->attribute->attribute(self::SUBTREE_LIMIT_FIELD));
        $schema =  array(
            'title'    => $this->attribute->attribute('name'),
            'required' => (bool)$this->attribute->attribute('is_required'),
            'enum' => $tagList
        );

        if ($schema['required']){
            $schema['default'] = current($tagList);
        }

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
        $options["multiple"] = false;
        $options["type"] = "select";

        return $options;

    }

    private function getTagChildren($tagID)
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
                    $content [] = $child->getKeyword();
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

        return $result;
    }
}