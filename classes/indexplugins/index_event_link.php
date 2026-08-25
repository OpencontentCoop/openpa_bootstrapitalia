<?php

class ezfIndexEventLink implements ezfIndexPlugin
{
    public function modify(eZContentObject $contentObject, &$docList)
    {
        $version = $contentObject->currentVersion();
        if ($version === false) {
            return;
        }

        $virtualTopic = $virtualTag = [];
        $openpa = OpenPAObjectHandler::instanceFromObject($contentObject);
        if ($openpa->hasAttribute('event_link')) {
            $link = $openpa->attribute('event_link');
            $topics = $link->attribute('topics');
            if (!empty($topics)) {
                $ids = $contentclassIds = $remoteIds = $classIdentifiers = $mainNodeIds = $names = [];
                foreach ($topics as $topic) {
                    $ids[] = $topic->attribute('id');
                    $contentclassIds[] = $topic->attribute('contentclass_id');
                    $remoteIds[] = $topic->attribute('remote_id');
                    $classIdentifiers[] = $topic->attribute('class_identifier');
                    $mainNodeIds[] = $topic->attribute('main_node_id');
                    $names[] = $topic->attribute('name');
                }
                $virtualTopic = [
                    'submeta_topics___id____si' => $ids,
                    'submeta_topics___contentclass_id____si' => $contentclassIds,
                    'submeta_topics___remote_id____ms' => $remoteIds,
                    'submeta_topics___class_identifier____ms' => $classIdentifiers,
                    'submeta_topics___main_node_id____si' => $mainNodeIds,
                    'submeta_topics___name____t' => implode(' ', $names),
                    'subattr_topics___name____s' => $names,
                    'subattr_topics___name____t' => implode(' ', $names),
                    'attr_topics_t' => implode(' ', $names),
                    'attr_topics_s' => $names,
                ];
            }
            $type = $link->attribute('has_public_event_typology');
            if ($type instanceof eZTagsObject) {
                $tagIds = [$type->attribute('id')];
                $tree = [$type->attribute('keyword')];
                $parentTags = $type->getPath(true);
                foreach ($parentTags as $parentTag) {
                    $tagIds[] = $parentTag->attribute('id');
                    $tree[] = $parentTag->attribute('keyword');
                }
                $virtualTag = [
                    'attr_has_public_event_typology_lk' => $type->attribute('keyword'),
                    'subattr_has_public_event_typology___tree____lk' => implode(',', $tree),
                    'attr_has_public_event_typology_t' => implode(',', $tree),
                    'subattr_has_public_event_typology___tag_ids____si' => $tagIds,
                    'ezf_df_tag_ids' => $tagIds,
                ];
            }
        }
        $virtualIndex = array_merge($virtualTopic, $virtualTag);
        if (!empty($virtualIndex)) {
            $availableLanguages = $version->translationList(false, false);
            foreach ($availableLanguages as $languageCode) {
                if ($docList[$languageCode] instanceof eZSolrDoc) {
                    foreach ($virtualIndex as $field => $value){
                        if ($docList[$languageCode]->Doc instanceof DOMDocument) {
                            $docList[$languageCode]->addField($field, $value);
                        } elseif (is_array($docList[$languageCode]->Doc)) {
                            $docList[$languageCode]->addField($field, $value);
                        }
                    }
                }
            }
        }
    }

}