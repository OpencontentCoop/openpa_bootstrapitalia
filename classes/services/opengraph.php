<?php

class ObjectHandlerServiceOpengraph extends ObjectHandlerServiceBase
{
    function run()
    {
        $this->fnData['generate_data'] = 'generateData';
    }

    protected function generateData()
    {
        $returnArray = array();
        $contentNode = $this->container->getContentNode();

        if ($contentNode instanceof eZContentObjectTreeNode) {
            $dataMap = $contentNode->dataMap();
            $siteName = trim(eZINI::instance()->variable('SiteSettings', 'SiteName'));
            $returnArray['og:site_name'] = $siteName;

            $urlAlias = $contentNode->urlAlias();
            eZURI::transformURI($urlAlias, false, 'full');
            $returnArray['og:url'] = $urlAlias;

            $returnArray['og:type'] = 'article';
            $returnArray['article:published_time'] = date('c', $contentNode->object()->attribute('published'));
            $returnArray['article:modified_time'] = date('c', $contentNode->object()->attribute('modified'));
            if ($contentNode->object()->attribute('owner_id') != eZINI::instance()->variable("UserSettings", "UserCreatorID")) {
                if ($owner = $contentNode->object()->attribute('owner')) {
                    $returnArray['article:author'] = $owner->attribute('name');
                }
            }else{
                $returnArray['article:author'] = $siteName;
            }

            $tags = [];
            foreach ($dataMap as $identifier => $attribute) {
                if ($attribute->attribute('data_type_string') == eZTagsType::DATA_TYPE_STRING && $attribute->hasContent()) {
                    /** @var eZTags $attributeContent */
                    $attributeContent = $attribute->content();
                    $tags = array_merge($tags, $attributeContent->attribute('keywords'));
                }
                if ($attribute->attribute('data_type_string') == eZGmapLocationType::DATA_TYPE_STRING && $attribute->hasContent()) {
                    /** @var eZGmapLocation $attributeContent */
                    $attributeContent = $attribute->content();
                    $returnArray['og:street-address'] = $attributeContent->attribute('address');
                    $returnArray['og:latitude'] = $attributeContent->attribute('latitude');
                    $returnArray['og:longitude'] = $attributeContent->attribute('longitude');
                }
                if (!isset($returnArray['og:description'])
                    && in_array($attribute->attribute('data_type_string'), [eZTextType::DATA_TYPE_STRING, eZXMLTextType::DATA_TYPE_STRING])
                    && $attribute->hasContent()) {
                    $returnArray['og:description'] = $this->cleanText($attribute->attribute('data_text'));
                }
                if ($identifier == 'reading_time' && $attribute->content() != 0) {
                    $returnArray['twitter:label1'] = $attribute->attribute('contentclass_attribute_name');
                    $returnArray['twitter:data1'] = $attribute->content() . ' mins';
                }
            }
            if (!empty($tags)) {
                $returnArray['article:tag'] = array_unique($tags);
            }

            $returnArray['og:title'] = $contentNode->attribute('name');
            $returnArray['twitter:title'] = $returnArray['og:title'];
            try {
                $tableView = OCClassExtraParametersManager::instance($contentNode->object()->contentClass())->getHandler('table_view');
                $mainImages = $tableView->attribute('main_image');
                $image = $this->loadImage($mainImages, $dataMap);
                if ($image) {
                    $alias = $image->attribute('large');
                    $returnArray['og:image'] = $alias['url'];
                }

                $inOverview = $tableView->attribute('in_overview');
                foreach ($inOverview as $identifier) {
                    if (isset($dataMap[$identifier])
                        && in_array($dataMap[$identifier]->attribute('data_type_string'), [eZTextType::DATA_TYPE_STRING, eZXMLTextType::DATA_TYPE_STRING])
                        && $dataMap[$identifier]->hasContent()) {
                        $returnArray['og:description'] = $this->cleanText($dataMap[$identifier]->attribute('data_text'));
                    }
                }
            } catch (Exception $e) {
                eZDebug::writeError($e->getMessage(), __METHOD__);
            }

            $pagedata = new \OpenPAPageData();
            $contacts = $pagedata->getContactsData();
            if (isset($contacts['email'])) {
                $returnArray['og:email'] = $contacts['email'];
            }
            if (isset($contacts['telefono'])) {
                $returnArray['og:phone_number'] = $contacts['telefono'];
            }
            if (isset($contacts['fax'])) {
                $returnArray['og:fax_number'] = $contacts['fax'];
            }
            if (!isset($returnArray['og:image'])) {
                $logo = (array)OpenPaFunctionCollection::fetchHeaderLogo();
                if (isset($logo['url'])) {
                    $returnArray['og:image'] = $logo['url'];
                }
            }

            if (isset($returnArray['og:image'])) {
                $file = eZClusterFileHandler::instance($returnArray['og:image']);
                if ($file->exists()) {
                    $file->fetch();
                    $returnArray['og:image:type'] = $file->dataType();
                    $info = getimagesize($returnArray['og:image']);
                    if ($info) {
                        $returnArray['og:image:width'] = $info[0];
                        $returnArray['og:image:height'] = $info[1];
                    }
                    $file->deleteLocal();
                }
                eZURI::transformURI($returnArray['og:image'], true, 'full');

            }

            $returnArray['og:locale'] = str_replace('-', '_', eZLocale::instance()->httpLocaleCode());

            if (isset($returnArray['og:description'])) {
                $returnArray['twitter:card'] = 'summary';
                $returnArray['twitter:description'] = $returnArray['og:description'];
            }
            if (isset($returnArray['og:image'])) {
                $returnArray['twitter:image'] = $returnArray['og:image'];
            }
            if (isset($returnArray['og:url'])) {
                $returnArray['twitter:url'] = $returnArray['og:url'];
            }
        }

        return $returnArray;
    }

    private function cleanText($text)
    {
        $text = strip_tags(trim($text));
        $text = str_replace("\n", " ", $text);
        if (strpos($text, 'script') !== false) {
            $text = html_entity_decode($text);
            $doc = new DOMDocument();
            if ($doc->loadHTML($text, LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD)) {
                $scripts = $doc->getElementsByTagName('script');
                $length = $scripts->length;
                for ($i = 0; $i < $length; $i++) {
                    if ($scripts->item($i)->parentNode) {
                        $scripts->item($i)->parentNode->removeChild($scripts->item($i));
                    }
                }
                $text = $doc->saveHTML();
            }
        }

        return $text;
    }

    /**
     * @param string[] $mainImages
     * @param eZContentObjectAttribute[] $dataMap
     *
     * @return eZImageAliasHandler|false
     */
    private function loadImage($mainImages, $dataMap)
    {
        foreach ($mainImages as $mainImage) {
            if (isset($dataMap[$mainImage]) && $dataMap[$mainImage]->hasContent()) {
                if ($dataMap[$mainImage]->attribute('data_type_string') == eZImageType::DATA_TYPE_STRING) {

                    return $dataMap[$mainImage]->content();

                } elseif ($dataMap[$mainImage]->attribute('data_type_string') == eZObjectRelationListType::DATA_TYPE_STRING) {
                    $imagesIdList = explode('-', $dataMap[$mainImage]->toString());
                    foreach ($imagesIdList as $id) {
                        $object = eZContentObject::fetch((int)$id);
                        if ($object instanceof eZContentObject) {
                            $dataMap = $object->dataMap();
                            $image = $this->loadImage(['image'], $dataMap);
                            if ($image) {
                                return $image;
                            }
                        }
                    }
                }
            }
        }

        return false;
    }
}
