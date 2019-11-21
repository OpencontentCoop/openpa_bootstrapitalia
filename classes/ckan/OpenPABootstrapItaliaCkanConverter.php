<?php

use Opencontent\Ckan\DatiTrentinoIt\Converter\OpenPA as BaseConverter;
use Opencontent\Ckan\DatiTrentinoIt\CkanResource;

class OpenPABootstrapItaliaCkanConverter extends BaseConverter
{
	private $mainOrganization;

	private $mainContactPoint;

	protected function getMainOrganization()
	{
		if ($this->mainOrganization === null){
			if (isset($this->dataMap['rights_holder']) && $this->dataMap['rights_holder']->hasContent()){
				$idList = explode('-', $this->dataMap['rights_holder']->toString());
				$this->mainOrganization = eZContentObject::fetch((int)$idList[0]);
			}else{
				$this->mainOrganization = false;
			}
		}

		return $this->mainOrganization;
	}

	protected function getMainContactPoint()
	{
		if ($this->mainContactPoint === null){
			if (isset($this->dataMap['contact_point']) && $this->dataMap['contact_point']->hasContent()){
				$idList = explode('-', $this->dataMap['contact_point']->toString());
				$this->mainContactPoint = eZContentObject::fetch((int)$idList[0]);
			}else{
				$this->mainContactPoint = false;
			}
		}

		return $this->mainContactPoint;
	}

	protected function getAuthorName()
    {
    	if ($this->getMainOrganization() instanceof eZContentObject){
        	return $this->getMainOrganization()->attribute('name');
        }
    }

	protected function getAuthorEmail()
    {
        if ($this->getMainContactPoint() instanceof eZContentObject){
        	$dataMap = $this->getMainContactPoint()->attribute('data_map');
        	if (isset($dataMap['contact']) && $dataMap['contact']->hasContent()){
		        $data = $this->getMatrixHashList($dataMap['contact']->content());
		        
		        foreach ($data as $item) {
		        	if (strpos($item['type'], 'mail') !== false){
		        		return $item['value'];
		        	}
		        }
        	}
        }

        return '';
    }

    protected function getMaintainerName()
    {
    	return $this->getAuthorName();
    }

    protected function getMaintainerEmail()
    {
    	return $this->getAuthorEmail();
    }

    protected function getLicenseId()
    {
    	return 'cc-by'; //@todo
        
        if (isset( $this->dataMap['license'] ) && $this->dataMap['license']->hasContent()) {
            return strtolower($this->dataMap['license']->toString());
        }

        return null;
    }

    protected function getNotes()
    {
    	if (isset( $this->dataMap['description'] ) && $this->dataMap['description']->hasContent()) {
            return $this->dataMap['description']->toString();
        }

        return null;
    }

    protected function getVersion()
    {
    	if (isset( $this->dataMap['version_info'] )) {
            if ($this->dataMap['version_info']->hasContent()) {
                return $this->dataMap['version_info']->toString();
            }
        }

        return $this->object->attribute('current_version');
    }

    protected function getResources()
    {
        $distribuzioni = array();
        if (isset($this->dataMap['distribuzione']) && $this->dataMap['distribuzione']->hasContent()){
	        $distribuzioni = $this->getMatrixHashList($this->dataMap['distribuzione']->content());
	    }

        $resourceAttributes = array(
            "url" => null,
            "name" => null,
            "description" => null,
            "format" => null,
            "mimetype" => null,
            "mimetype_inner" => null,
            "size" => null,
            "last_modified" => null,
            "hash" => null,
            "resource_type" => null
        );

        $resourceList = array();
        foreach ($distribuzioni as $index => $distribuzione) {
            $data = $resourceAttributes;
            $data['hash'] = $this->getResourceGuid($index);
            $data["url"] = $this->fixUrl($distribuzione['url_download']);
            $data["resource_type"] = 'api';
            $data["format"] = $distribuzione['format'];
            $data["name"] = str_replace(";", "", $distribuzione['title']);            
            $resourceList[] = CkanResource::fromArray($data);
        }

        return $resourceList;
    }

    protected function getTags()
    {
        if (isset( $this->dataMap['tags'] ) && $this->dataMap['tags']->attribute('has_content')) {
            $tagList = array();
            $tags = explode(', ', $this->dataMap['tags']->toString());
            foreach ($tags as $tag) {
                $tagList[] = array(
                    'vocabulary_id' => null,
                    'name' => $tag
                );
            }

            return $tagList;
        }

        return null;
    }

    protected function getTemporalEnd()
    {
        if (isset( $this->dataMap['from_time'] ) && $this->dataMap['from_time']->hasContent()) {
            return date(DATE_ISO8601, $this->dataMap['from_time']->toString());
        }

        return null;
    }

    protected function getTemporalStart()
    {
        if (isset( $this->dataMap['to_time'] ) && $this->dataMap['to_time']->hasContent()) {
            return date(DATE_ISO8601, $this->dataMap['to_time']->toString());
        }

        return null;
    }

    protected function getSiterUrl()
    {
        if (isset( $this->dataMap['url_website'] ) && $this->dataMap['url_website']->hasContent()) {
            $url = explode('|', $this->dataMap['url_website']->toString());
            $url = $url[0];

            return $this->fixUrl($url);
        }

        return null;
    }

    private function getMatrixHashList($matrix)
    {
		$columns = (array) $matrix->attribute( 'columns' );
        $rows = (array) $matrix->attribute( 'rows' );

        $keys = array();
        foreach( $columns['sequential'] as $column ){
            $keys[] = $column['identifier'];
        }
        $data = array();
        foreach( $rows['sequential'] as $row ){
            $data[] = array_combine( $keys, $row['columns'] );
        }

        return $data;
    }
}