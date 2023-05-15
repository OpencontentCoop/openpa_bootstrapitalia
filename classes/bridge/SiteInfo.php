<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;

class SiteInfo
{
    public static function importFromUrl($remoteUrl)
    {
        if (filter_var($remoteUrl, FILTER_VALIDATE_URL)) {
            $remoteHost = parse_url($remoteUrl, PHP_URL_HOST);
            $rootObjectId = false;
            $rootNode = json_decode(file_get_contents("https://$remoteHost/api/opendata/v2/content/browse/1"), true);
            if ($rootNode && isset($rootNode['children'])) {
                foreach ($rootNode['children'] as $child) {
                    if ($child['classIdentifier'] == 'homepage') {
                        $rootObjectId = $child['id'];
                        break;
                    }
                }
            }elseif (!$rootNode){
                $rootNode = json_decode(file_get_contents("https://$remoteHost/api/opendata/v2/content/browse/2"), true);
                if ($rootNode){
                    $rootObjectId = $rootNode['id'];
                }
            }
            if ($rootObjectId) {
                $rootObject = json_decode(
                    file_get_contents("https://$remoteHost/api/opendata/v2/content/read/" . (int)$rootObjectId),
                    true
                );
                if ($rootObject) {
                    $languages = $rootObject['metadata']['languages'];

                    $payload = new PayloadBuilder();
                    $payload->setId(OpenPaFunctionCollection::fetchHome()->attribute('contentobject_id'));
                    $payload->setLanguages($languages);
                    $syncFields = [
                        'contacts',
                        'logo',
                        'stemma',
                        'favicon',
                    ];
                    foreach ($languages as $language) {
                        $data = $rootObject['data'][$language] ?? $rootObject['data']['ita-IT'];
                        foreach ($syncFields as $syncField) {
                            if (isset($data[$syncField]) && !empty($data[$syncField])) {
                                $fieldValue = $data[$syncField];
                                if (isset($fieldValue['url']) && strpos($fieldValue['url'], 'http') === false) {
                                    $fieldValue['url'] = 'https://' . $remoteHost . $fieldValue['url'];
                                }
                                $payload->setData($language, $syncField, $fieldValue);
                            }
                        }
                    }

                    if (!empty($payload->getData())) {
                        $contentRepository = new ContentRepository();
                        $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));
                        $contentRepository->update($payload->getArrayCopy(), true);

                        return true;
                    }
                }
            }
        }

        return false;
    }
}