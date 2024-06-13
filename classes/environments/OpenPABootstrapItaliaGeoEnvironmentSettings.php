<?php

use Opencontent\Opendata\GeoJson\Feature;
use Opencontent\Opendata\GeoJson\Geometry;
use Opencontent\Opendata\GeoJson\Properties;
use Opencontent\Opendata\Api\Values\Content;

class OpenPABootstrapItaliaGeoEnvironmentSettings extends GeoEnvironmentSettings
{
    public function filterContent(Content $content)
    {
        $language = isset( $this->request->get['language'] ) ? $this->request->get['language'] : null;

        return $this->serializeContent($content, $language);
    }
    private function serializeContent(Content $content, $defaultLanguage = null): Feature
    {
        $defaultLanguage = !$defaultLanguage ? eZContentObject::defaultLanguage() : $defaultLanguage;
        $geometry = new Geometry();
        $properties = [];

        if (isset($content->data[$defaultLanguage])) {
            $data = $content->data[$defaultLanguage];
            $name = $content->metadata->name[$defaultLanguage];
        } else {
            $dataArray = $content->data->jsonSerialize();
            $nameArray = $content->metadata->name;
            $data = array_shift($dataArray);
            $name = array_shift($nameArray);
        }

        $properties['id'] = $content->metadata->id;
        $properties['name'] = $name;
        $properties['class_identifier'] = $content->metadata->classIdentifier;

        $NodeID = null;
        if (isset($this->request->get['context'])) {
            foreach ($content->metadata->assignedNodes as $assignedNode) {
                if (strpos($assignedNode['path_string'], '/' . $this->request->get['context'] . '/') !== false) {
                    $NodeID = $assignedNode['id'];
                }
            }
        }
        $NodeID = $NodeID ?? $content->metadata->mainNodeId;
        $properties['mainNodeId'] = $NodeID;

        $filter = new eZURLAliasQuery();
        $filter->actions = array( 'eznode:' . $NodeID );
        $filter->type = 'name';
        $filter->limit = false;
        $elements = $filter->fetchAll();
        $properties['urlAlias'] = isset($elements[0]) ?
            '/' . $elements[0]->getPath()
            : eZURLAliasML::actionToUrl('eznode:' . $NodeID);
        eZURI::transformURI($properties['urlAlias']);

        foreach ($data as $identifier => $attribute) {
            if ($attribute['datatype'] == 'ezgmaplocation') {
                $geometry->type = 'Point';
                $geometry->coordinates = [
                    isset($attribute['content']['longitude']) ? $attribute['content']['longitude'] : 0,
                    isset($attribute['content']['latitude']) ? $attribute['content']['latitude'] : 0,
                ];
                if (!empty($attribute['content']['address'])) {
                    $properties[$identifier] = $attribute['content']['address'];
                    $properties['address'] = $attribute['content']['address'];
                }
            }
        }

        return new Feature($content->metadata->id, $geometry, new Properties($properties));
    }
}