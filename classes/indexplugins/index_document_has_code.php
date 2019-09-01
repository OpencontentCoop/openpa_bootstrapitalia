<?php

class ezfIndexHasCodeNormalized implements ezfIndexPlugin
{
    const FIELD = 'extra_has_code_sl';

    public function modify(eZContentObject $contentObject, &$docList)
    {
    	if ($contentObject->attribute('class_identifier') == 'document'){
    		$version = $contentObject->currentVersion();
            if($version === false){
                return;
            }
            $availableLanguages = $version->translationList(false, false);
            
            $hasCodeNormalized = self::normalizeHasCode($contentObject);
            
            foreach ($availableLanguages as $languageCode) {
                if ($docList[$languageCode] instanceof eZSolrDoc) {
                    if ($docList[$languageCode]->Doc instanceof DOMDocument) {
                        $xpath = new DomXpath($docList[$languageCode]->Doc);
                        $docList[$languageCode]->addField(self::FIELD, $hasCodeNormalized);
                    } elseif (is_array($docList[$languageCode]->Doc)) {
                        $docList[$languageCode]->addField(self::FIELD, $hasCodeNormalized);
                    }
                }
            }
    	}
    }

    private static function normalizeHasCode(eZContentObject $contentObject)
    {
    	$normalized = 0;
    	$dataMap = $contentObject->dataMap();
    	if (isset($dataMap['has_code'])){
    		$hasCode = $dataMap['has_code']->toString();
    		$normalized = self::normalizeString($hasCode);
    	}

    	return $normalized;
    }

    public static function normalizeString($string)
    {
		$code = strtolower($string);
		$year = false;

		$parts = explode('/', $string);    		
		if (count($parts) > 1){
			$year = array_pop($parts);
			$code = implode('', $parts);
		}
		
		$code = self::convertToNumber($code);
		
		if (strlen($year) == 4){
			$year = self::convertToNumber($year);
			$normalized = $year . $code;
		}else{
			$normalized = $code . $year;
		}
		$normalized = str_pad($normalized, 3, "0", STR_PAD_LEFT);

		return $normalized;
    }

    private static function convertToNumber($string)
    {
    	// Remove all but alphanumeric characters
		$string = preg_replace('/[^a-z\d ]/i', '', $string);

		$chars = [];
		$alphabet = range('a', 'z');
		for ($i = 0; $i < strlen($string); $i++){
			$char = $string[$i];
			if (!is_numeric($char)){
				//$char = array_search($char, $alphabet);
			}
			if (is_numeric($char)){
				$chars[] = $char;
			}
		}
		$string = implode('', $chars);

		return $string;
    }
}
