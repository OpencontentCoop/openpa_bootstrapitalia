<?php

use Opencontent\Opendata\Api\AttributeConverter\Relations;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;

class FullRelationsAttributeConverter extends Relations
{
    public function get(eZContentObjectAttribute $attribute)
    {
        $contentRepository = new ContentRepository();
        $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));

        $data = array();
        $idList = explode('-', $attribute->toString());
        foreach ($idList as $id) {
            try {
                $data[] = (array)$contentRepository->read($id);
            } catch (Exception $e) {
                //eZDebug::writeNotice($e->getMessage(), __METHOD__);
            }
        }


        $content = parent::get($attribute);
        $content['datatype'] = 'ezobjectrelationlist';
        $content['content'] = $data;

        return $content;
    }
}
