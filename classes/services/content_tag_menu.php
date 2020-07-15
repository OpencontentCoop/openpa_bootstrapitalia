<?php

class ObjectHandlerServiceContentTagMenu extends ObjectHandlerServiceBase
{
	private $hasTagMenu;

    private $tagMenuRootTag;

    private $currentViewTag;

    private $showTagCards;

    function run()
    {
        $this->fnData['has_tag_menu'] = 'hasTagMenu';
        $this->fnData['tag_menu_root'] = 'getTagMenuRootTag';
        $this->fnData['current_view_tag'] = 'getCurrentViewTag';
        $this->fnData['show_tag_cards'] = 'showTagCards';
    }

    protected function hasTagMenu()
    {
    	if ($this->hasTagMenu === null){
            $this->hasTagMenu = $this->getTagMenuRootTag() instanceof eZTagsObject;
        }
        return $this->hasTagMenu;
    }

    protected function getTagMenuRootTag()
    {
    	if ($this->tagMenuRootTag === null){
            $this->tagMenuRootTag = false;
            
            $sideMenu = false;
        	if ($this->container->hasAttribute('control_menu')){
    			$sideMenu = $this->container->attribute('control_menu')->attribute('side_menu');
        	}

        	if ($sideMenu){
        		$sideMenuRootNode = $sideMenu->attribute('root_node');
        		if ($sideMenuRootNode instanceof eZContentObjectTreeNode){
        			/** @var eZContentObjectAttribute[] $dataMap */
        		    $dataMap = $sideMenuRootNode->attribute('data_map');
        			if (isset($dataMap['tag_menu']) && $dataMap['tag_menu']->attribute('data_type_string') == eZTagsType::DATA_TYPE_STRING && $dataMap['tag_menu']->hasContent()){
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
                    foreach ($rootTag->attribute('children') as $child) {
                        if ($child->attribute('keyword') == $userView) {
                            $this->currentViewTag = $child;
                            break;
                        }
                    }
                }
            }
        }

        return $this->currentViewTag;
    }

    protected function showTagCards()
    {
        if ($this->showTagCards === null){
            $this->showTagCards = false;
            $this->getTagMenuRootTag();
        }
        if ($this->showTagCards && $this->getCurrentViewTag()){
            $this->showTagCards = false;
        }
        return $this->showTagCards;
    }
}