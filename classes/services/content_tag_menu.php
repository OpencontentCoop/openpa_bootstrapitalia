<?php

class ObjectHandlerServiceContentTagMenu extends ObjectHandlerServiceBase
{
	private $hasTagMenu;

    private $tagMenuRootTag;

    private $tagMenuRootNode;

    private $currentViewTag;

    private $currentViewTagSubtree;

    private $showTagCards;

    function run()
    {
        $this->fnData['has_tag_menu'] = 'hasTagMenu';
        $this->fnData['tag_menu_root'] = 'getTagMenuRootTag';
        $this->fnData['tag_menu_root_node'] = 'getTagMenuRootNode';
        $this->fnData['current_view_tag'] = 'getCurrentViewTag';
        $this->fnData['current_view_tag_tree_list'] = 'getCurrentViewTagTreeIdList';
        $this->fnData['current_view_tag_subtree'] = 'getCurrentViewTagSubtree';
        $this->fnData['current_view_keywords_subtree'] = 'getCurrentViewKeywordsSubtree';
        $this->fnData['show_tag_cards'] = 'showTagCards';
    }

    protected function hasTagMenu()
    {
    	if ($this->hasTagMenu === null){
            $this->hasTagMenu = $this->getTagMenuRootTag() instanceof eZTagsObject;
        }
        return $this->hasTagMenu;
    }

    protected function getTagMenuRootNode()
    {
        $this->getTagMenuRootTag();
        return $this->tagMenuRootNode;
    }

    protected function getTagMenuRootTag()
    {
    	if ($this->tagMenuRootTag === null){
            $this->tagMenuRootTag = false;
            
            $currentObject = $this->container->getContentObject();
            if ($currentObject instanceof eZContentObject){
                $this->tagMenuRootNode = $currentObject->mainNode();
                /** @var eZContentObjectAttribute[] $dataMap */
                $dataMap = $currentObject->attribute('data_map');
                if (isset($dataMap['tag_menu'])
                    && $dataMap['tag_menu']->attribute('data_type_string') == eZTagsType::DATA_TYPE_STRING
                    && $dataMap['tag_menu']->hasContent()){
                    $tags = $dataMap['tag_menu']->content()->attribute('tags');
                    if ($tags[0]->attribute('children_count') > 0){
                        $this->tagMenuRootTag = $tags[0];
                    }
                    if (isset($dataMap['show_tag_cards']) && $dataMap['show_tag_cards']->attribute('data_int') == 1){
                        $this->showTagCards = true;
                    }
                }
            }
        }

    	return $this->tagMenuRootTag;
    }

    protected function getCurrentViewTag()
    {
        if ($this->currentViewTag === null){
            $this->currentViewTag = false;
            $userView = false;
            $currentUri = eZURI::instance(eZSys::requestURI());
            if (isset($currentUri->UserArray['view'])){
                $userView = $currentUri->UserArray['view'];            
            }

            if ($this->hasTagMenu() && $userView){
                $rootTag = $this->getTagMenuRootTag();
                if ($rootTag instanceof eZTagsObject) {
                    $userView = str_replace(' / ', '$', $userView);
                    $url = explode('/', $userView);
                    foreach ($url as $index => $item){
                        $url[$index] = str_replace('$', ' / ', $item);
                    }
                    $rootUrl = array_reverse(explode('/', $rootTag->getCleanUrl()));
                    foreach ($rootUrl as $item){
                        array_unshift($url, $item);
                    }
                    $currentViewTag = eZTagsObject::fetchByUrl($url);
                    if ($currentViewTag instanceof eZTagsObject){
                        $pathArray = explode('/', trim($currentViewTag->attribute('path_string'), '/'));
                        if (in_array($rootTag->attribute('id'), $pathArray)){
                            $this->currentViewTag = $currentViewTag;
                        }
                    }
                }
            }
        }

        return $this->currentViewTag;
    }

    protected function getCurrentViewTagTreeIdList()
    {
        $idList = false;
        if ($this->currentViewTag instanceof eZTagsObject) {
            $tagId = (int)$this->currentViewTag->attribute('id');
            $path = $this->currentViewTag->attribute('path_string');
            $db = eZDB::instance();
            $result = $db->arrayQuery("SELECT id FROM eztags WHERE id = $tagId OR path_string LIKE '{$path}%'");

            $idList = array_column($result, 'id');
        }

        return $idList;
    }

    protected function getCurrentViewTagSubtree()
    {
        if ($this->currentViewTagSubtree === null) {
            $this->currentViewTagSubtree = false;

            $rootTag = $this->getTagMenuRootTag();
            $currentViewTag = $this->getCurrentViewTag();
            if ($rootTag instanceof eZTagsObject && $currentViewTag instanceof eZTagsObject) {
                $this->currentViewTagSubtree = [];
                if ($currentViewTag->attribute( 'parent_id' ) == $rootTag->attribute('id')){
                    $this->currentViewTagSubtree = [$currentViewTag];
                }else{
                    $path = $currentViewTag->getPath();
                    $collect = false;
                    foreach ($path as $item){
                        if ($collect){
                            $this->currentViewTagSubtree[] = $item;
                        }
                        if ($item->attribute('id') == $rootTag->attribute('id')){
                            $collect = true;
                        }
                    }
                    $this->currentViewTagSubtree[] = $currentViewTag;
                }
            }
        }

        return $this->currentViewTagSubtree;
    }

    protected function getCurrentViewKeywordsSubtree()
    {
        $data = [];
        $currentViewTagSubtree = $this->getCurrentViewTagSubtree();
        if ($currentViewTagSubtree){
            foreach ($currentViewTagSubtree as $item){
                $data[] = $item->attribute('keyword');
            }
        }

        return $data;
    }

    protected function showTagCards()
    {
        if ($this->showTagCards === null){
            $this->showTagCards = false;
            $this->getTagMenuRootTag();
        }
        if ($this->showTagCards && $this->getCurrentViewTag()){
            $this->showTagCards = $this->getCurrentViewTag()->attribute('children_count') > 1;
        }
        return $this->showTagCards;
    }
}