<?php

use Opencontent\Opendata\Api\Values\Content;

class ObjectHandlerServiceContentAnalytics extends ObjectHandlerServiceBase
{
    function run()
    {
        $this->fnData['service_identifier'] = 'getServiceIdentifier';
        $this->fnData['organization_name_list'] = 'getOrganizationNameList';
    }

    protected function getServiceIdentifier(): ?string
    {
        if ($this->container->hasContentNode()
            && $this->container->getContentNode()->attribute('class_identifier') == 'public_service'
            && isset($this->container->attributesHandlers['identifier'])
            && $this->container->attributesHandlers['identifier']->attribute('contentobject_attribute')->attribute('has_content')) {
            return $this->container->attributesHandlers['identifier']->attribute('contentobject_attribute')->attribute('content');
        }

        return null;
    }

    protected function getOrganizationNameList(): array
    {
        $locale = 'ita-IT';
        $nameList = [];
        if ($this->container->hasContentObject()) {
            $content = Content::createFromEzContentObject(
                $this->container->getContentObject()
            );
            foreach ($content->data[$locale] as $field) {
                $field = json_decode(json_encode($field), true);
                if (!empty($field['content']) && $field['datatype'] === 'ezobjectrelationlist') {
                    $classes = array_column($field['content'], 'classIdentifier');
                    if (in_array('organization', $classes)) {
                        foreach ($field['content'] as $relation) {
                            $suffix = '';
                            if (strpos($relation['remoteId'], 'structure') !== false){
                                $suffix = ' - ' . str_replace('structure', '', $relation['remoteId']);
                            }
                            $nameList[] = $relation['name'][$locale] . $suffix;
                        }
                    }
                }
            }
        }

        return array_unique($nameList);
    }

}