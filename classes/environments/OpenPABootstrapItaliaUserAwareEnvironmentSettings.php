<?php

use Opencontent\Opendata\Api\AttributeConverterLoader;
use Opencontent\Opendata\Api\EnvironmentSettings;
use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\Api\Values\ContentData;
use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\ClassRepository;

class OpenPABootstrapItaliaUserAwareEnvironmentSettings extends OpenPABootstrapItaliaContentEnvironmentSettings
{
    public function filterContent( Content $content )
    {
        $language = \eZLocale::currentLocaleCode();
        $object = $content->getContentObject($language);

        $content = parent::filterContent($content);
        $content['metadata']['userAccess'] = $this->getObjectAccess($object);

        return $content;
    }

    private function getObjectAccess(eZContentObject $object)
    {
        return array(
            'canRead' => $object->canRead(),
            'canEdit' => $object->canEdit(),
            'canRemove' => $object->canRemove(),
            'canTranslate' => $object->canTranslate(),
        );
    }
}
