<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector;

class UrlFieldConnector extends FieldConnector
{
	public function getData()
    {
        $data = [
        	'url' => '',
        	'text' => '',
        ];
        
        $content = parent::getData();
        if (!empty($content)){
			$parts = explode('|', $content);
			$data = [
				'url' => $parts[0],
				'text' => isset($parts[1]) ? $parts[1] : '',
			];
        }

        return $data;
    }

	public function getSchema()
    {
        return [
            "type" => "object",
            "title" => $this->attribute->attribute('name'),
            "properties" => [
                "url" => [
                    "format" => "uri",
                    "type" => "string",
                    'required' => (bool)$this->attribute->attribute('is_required'),
                    'title' => ezpI18n::tr( 'design/standard/content/datatype', 'URL' ),
                ],
                "text" => [
                    'title' => ezpI18n::tr( 'design/standard/content/datatype', 'Text' ),
                    "type" => "string",
                ]
            ]
        ];
    }

    public function getOptions()
    {
        return [
            "helper" => $this->attribute->attribute('description'),
            "fields" => [
            	"url" => ["type" => "url"]            
            ]
        ];
    }

    public function setPayload($postData)
    {
    	$url = isset($postData['url']) ? $postData['url'] : '';
    	$text = isset($postData['text']) ? '|' . $postData['text'] : '';

    	return $url.$text;
    }
}
