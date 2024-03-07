<?php

use Opencontent\Opendata\Api\EnvironmentSettings;
use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\GeoJson\FeatureCollection;
use Opencontent\Opendata\GeoJson\Feature;
use Opencontent\Opendata\GeoJson\Geometry;
use Opencontent\Opendata\GeoJson\Properties;


class OpenPABootstrapItaliaExtrageoEnvironmentSettings extends EnvironmentSettings
{

    protected $maxSearchLimit = 500;

    protected $defaultSearchLimit = 500;

    public function filterContent(Content $content)
    {
        $language = isset( $this->request->get['language'] ) ? $this->request->get['language'] : null;

        return $this->geoJsonSerialize($content, $language);
    }

    private function geoJsonSerialize(Content $content, $defaultLanguage = null)
    {
        $defaultLanguage = !$defaultLanguage ? eZContentObject::defaultLanguage() : $defaultLanguage;
        $geometry = new Geometry();
        $properties = array();

        if (isset( $content->data[$defaultLanguage] )) {
            $extraData = $content->extradata[$defaultLanguage];
            $name = $content->metadata->name[$defaultLanguage];
        } else {
            $extraDataArray = $content->extradata->jsonSerialize();
            $nameArray = $content->metadata->name;
            $extraData = array_shift($extraDataArray);
            $name = array_shift($nameArray);
        }
        $properties['id'] = $content->metadata->id;
        $properties['name'] = $name;
        $properties['class_identifier'] = $content->metadata->classIdentifier;
        $properties['mainNodeId'] = $content->metadata->mainNodeId;

        $features = [];
        if (isset($extraData['geo'])){
            foreach ($extraData['geo'] as $geo){
                if (!empty($geo['longitude']) && !empty($geo['latitude'])) {
                    $geometry->type = 'Point';
                    $geometry->coordinates = [(float)$geo['longitude'], (float)$geo['latitude']];
                    $features[] = new Feature($content->metadata->id, $geometry, new Properties($properties));
                }
            }
        }

        return $features;
    }

    public function filterSearchResult(
        \Opencontent\Opendata\Api\Values\SearchResults $searchResults,
        \ArrayObject $query,
        \Opencontent\QueryLanguage\QueryBuilder $builder
    ) {

        $searchResults = parent::filterSearchResult( $searchResults, $query, $builder );

        $collection = new FeatureCollection();
        /** @var Feature[] $content */
        foreach ($searchResults->searchHits as $i => $features) {
            foreach ($features as $feature) {
                if ($this->issetGeoDistFilter($query)) {
                    $feature->properties->add('index', ++$i);
                }
                $collection->add($feature);
            }
        }
        $collection->query = $searchResults->query;
        $collection->nextPageQuery = $searchResults->nextPageQuery;
        $collection->totalCount = $searchResults->totalCount;
        $collection->facets = $searchResults->facets;

        return $collection;
    }

    protected function issetGeoDistFilter(\ArrayObject $query)
    {
        if (isset( $query['ExtendedAttributeFilter'] )) {
            foreach ($query['ExtendedAttributeFilter'] as $filter) {
                if ($filter['id'] == 'geodist') {
                    return true;
                }
            }
        }

        return false;
    }

    public function filterQuery(\ArrayObject $query, \Opencontent\QueryLanguage\QueryBuilder $builder)
    {
        if (!$this->issetGeoDistFilter($query)) {
            $field = ezfIndexSubAttributeGeo::FIELD;
            $filter = "{$field}:[-90,-90 TO 90,90]";

            if (!isset( $query['Filter'] )) {
                $query['Filter'] = array();
            }
            $query['Filter'][] = $filter;
        }

        return parent::filterQuery($query, $builder);
    }
}