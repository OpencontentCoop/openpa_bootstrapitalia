<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\TagsField;

class SelectTagsFieldConnector extends TagsField
{
    private $tagChildren;

    public function getData()
    {
        $rawContent = $this->getContent();
        if (empty($rawContent)){
            return null;
        }

        $data = [];
        $attribute = eZContentObjectAttribute::fetch((int)$rawContent['id'], (int)$rawContent['version']);
        if ($attribute instanceof eZContentObjectAttribute && $attribute->hasContent()) {
            $tags = $attribute->content();
            if ($tags instanceof eZTags) {
                $data = $tags->attribute('tag_ids');
                $data = array_map(function ($id){
                    return 'role_' . $id;
                }, $data);
            }
        }

        return $data;
    }

    public function getSchema()
    {
        $tagList = $this->getTagChildren($this->attribute->attribute(self::SUBTREE_LIMIT_FIELD));
        $schema =  array(
            'title'    => $this->attribute->attribute('name'),
            'required' => (bool)$this->attribute->attribute('is_required'),
            'enum' => array_keys($tagList)
        );

        if ($schema['required']){
            $schema['default'] = current($tagList);
        }

        return $schema;
    }

    public function getOptions()
    {
        $tagList = $this->getTagChildren($this->attribute->attribute(self::SUBTREE_LIMIT_FIELD));
        $options = array(
            "helper" => $this->attribute->attribute('description'),
        );
        $options["label"] = $this->attribute->attribute('name');
        $options["name"] = $this->getIdentifier();
        $options["optionLabels"] = array_values($tagList);
        $options["subtree_limit"] = $this->attribute->attribute(self::SUBTREE_LIMIT_FIELD);
        $options["multiple"] = false;
        $options["type"] = "select";
        $options["sort"] = false;

        return $options;
    }

    private function getTagChildren($tagID)
    {
        if ($this->tagChildren === null) {
            $result = array();
            $tag = eZTagsObject::fetch($tagID);
            if (!$tag instanceof eZTagsObject) {
                return $result;
            }

            $lastModified = $tag->attribute('modified');
            $prioritizedLanguages = eZContentLanguage::prioritizedLanguages();
            $locale = 'ita-IT';
            if (count($prioritizedLanguages) > 0) {
                $locale = $prioritizedLanguages[0]->Locale;
            }
            $cacheFilePath = eZSys::cacheDirectory() . '/openpa/tags_select/' . $tag->attribute('id') . '-' . $locale . '.cache';
            $result = eZClusterFileHandler::instance($cacheFilePath)->processCache(
                function ($file) {
                    $content = include($file);

                    return $content;
                },
                function () use ($tag, $locale) {
                    $content = [];
                    foreach ($tag->getChildren() as $child) {
                        $content ['role_' . $child->attribute('id')] = $child->getKeyword();
                        $synonyms = eZTagsObject::fetchList(
                            ['main_tag_id' => $child->attribute('id')],
                            null,
                            null,
                            false,
                            $locale
                        );
                        foreach ($synonyms as $synonym){
                            $content ['role_' . $synonym->attribute('id')] = $synonym->getKeyword();
                        }
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

            $this->tagChildren = $result;
        }

        return $this->tagChildren;
    }

    public function setPayload($postData)
    {
        $tagList = $this->getTagChildren($this->attribute->attribute(self::SUBTREE_LIMIT_FIELD));

        if (is_array($postData)) {
            $data = empty($postData) ? null : $postData;
        }else{
            $data = explode(',', $postData);
        }

        if ($data === null){
            return null;
        }

        $keywords = [];
        foreach ($data as $id){
            if (isset($tagList[$id])){
                $keywords[] = $tagList[$id];
            }
        }

        return empty($keywords) ? null : $keywords;
    }
}