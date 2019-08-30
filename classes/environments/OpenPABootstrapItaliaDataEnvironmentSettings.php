<?php

use Opencontent\Opendata\Api\Values\SearchResults;
use Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder;
use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\Api\Values\ContentData;

class OpenPABootstrapItaliaDataEnvironmentSettings extends DefaultEnvironmentSettings
{
    public function filterContent(Content $content)
    {
        header("Expires: on, 01 Jan 1970 00:00:00 GMT");
        header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
        header("Cache-Control: no-store, no-cache, must-revalidate");
        header("Cache-Control: post-check=0, pre-check=0", false);
        header("Pragma: no-cache");

        $this->blockBlackListedContent($content);
        $content = $this->removeBlackListedAttributes($content);
        $content = $this->overrideIdentifier($content);
        
        return $this->flatData($content);
    }

    protected function flatData(Content $content)
    {
        $locale =  eZLocale::currentLocaleCode();
        
        $flatData = array();        
        $flatData['_id'] = $this->requestBaseUri . 'read/' . $content->metadata->id;
        $flatData['_link'] = $this->request->getHostURI() . '/openpa/object/' . $content->metadata->id;
        $flatData['_class'] = $this->camelize($content->metadata->classIdentifier);

        foreach ($content->data[$locale] as $identifier => $value) {
            
            if ($value['datatype'] == 'ezobjectrelationlist' || $value['datatype'] == 'ezobjectrelation') {
                $valueContent = array();
                if (is_array($value['content'])) {
                    foreach ($value['content'] as $item) {
                        if (is_array($item) || $item instanceof ArrayAccess) {                            
                            $valueContent[] = $this->requestBaseUri . 'read/' . $item['id'];
                        }
                    }
                }

            } elseif ($value['datatype'] == 'ezbinaryfile' && is_array($value['content'])) {
                $valueContent = $value['content']['url'];

            } elseif ($value['datatype'] == 'ezimage' && is_array($value['content'])) {
                $valueContent = $this->request->getHostURI() . $value['content']['url'];
            
            } elseif ($value['datatype'] == 'ocevent' && is_array($value['content'])) { 
                $valueContent = [
                    'startDateTime' => $value['content']['startDateTime'],
                    'endDateTime' => $value['content']['endDateTime'],
                    'recurrencePattern' => $value['content']['recurrencePattern'],
                ];
            
            } elseif ($value['datatype'] == 'ocmultibinary') {
                $valueContent = array_column($value['content'], 'url');

            } elseif ($value['datatype'] == 'ezboolean') {
                $valueContent = (bool)$value['content'];

            } elseif ($value['datatype'] == 'eztags') {
                $valueContent = $this->getTagLinks($value, $content, $locale);

            } elseif (is_numeric($value['content'])) {
                $valueContent = (float)$value['content'];
            
            } elseif (is_string($value['content']) && empty($value['content'])) {
                $valueContent = null;
            
            } else {                
                $valueContent = $value['content'];
            }    

            $flatData[$this->camelize($identifier)] = $valueContent;
        }
        
        return $flatData;        
    }

    private function getTagLinks($value, $content, $locale)
    {
        if (!empty($value['content'])){
            $data = $value;
            unset($value['content']);
            $data['contentobject_id'] = $content->metadata->id;
            $data['language_code'] = $locale;

            $attribute = new eZContentObjectAttribute($data);
            $tags = eZTags::createFromAttribute($attribute, 'ita-PA');
    
            return $tags->attribute('keywords');
        }

        return array();
    }

    private function camelize($string, $delimiter = '_')
    {
        $exploded = explode($delimiter, $string);
        $explodedCamelized = array_map('ucwords', $exploded);

        return implode('', $explodedCamelized);
    }

    public function isDebug()
    {
        return false;
    }

}
