<?php

use Opencontent\Opendata\Api\AttributeConverter\Relations;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;

class FullRelationAttributeConverter extends Relations
{
    public function get(eZContentObjectAttribute $attribute)
    {
        $contentRepository = new ContentRepository();
        $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));
        try {
            $data = (array)$contentRepository->read($attribute->toString());
        } catch (Exception $e) {
            eZDebug::writeError($e->getMessage(), __METHOD_);
            $data = null;
        }

        $content = parent::get($attribute);
        $content['datatype'] = 'ezobjectrelation';
        $content['content'] = $data;

        return $content;
    }
}
