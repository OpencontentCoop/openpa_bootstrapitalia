<?php

use Opencontent\Easyontology\ConverterHelper;

class BootstrapItaliaPlaceConverter extends \Opencontent\Easyontology\AbstractConverter
{
    /**
     * @var eZContentObject
     */
    private $content;

    private $concept;

    public function __construct($concept, $id)
    {
        $this->concept = $concept;
        $this->content = eZContentObject::fetch((int)$id);
    }

    private function getId()
    {
        return ConverterHelper::generateId($this->concept, $this->content->ID);
    }

    public function getContext()
    {
        return false;
    }

    protected function convert()
    {
        $this->doc = [
            "@context" => "https://schema.org",
            "@id" => $this->getId(),
            "@type" => "Place",
            "name" => '',
        ];

        if ($this->content instanceof eZContentObject
            && $this->content->attribute('class_identifier') === 'place') {
            $this->doc['name'] = $this->content->attribute('name');
            $dataMap = $this->content->dataMap();
            if (isset($dataMap['has_address']) && $dataMap['has_address']->hasContent()) {
                /** @var eZGmapLocation $hasAddress */
                $hasAddress = $dataMap['has_address']->content();
                $this->doc['geo'] = [
                    '@type' => 'GeoCoordinates',
                    'latitude' => (float)$hasAddress->attribute('latitude'),
                    'longitude' => (float)$hasAddress->attribute('longitude'),
                ];
                $this->doc['address'] = $hasAddress->attribute('address');
            }
            if (isset($dataMap['image']) && $dataMap['image']->hasContent()) {
                if ($dataMap['image']->attribute('data_type_string') === eZObjectRelationListType::DATA_TYPE_STRING) {
                    $relatedIdList = explode('-', $dataMap['image']->toString());
                    $related = eZContentObject::fetch((int)$relatedIdList[0]);
                    if ($related instanceof eZContentObject) {
                        $relatedDataMap = $related->dataMap();
                        if (isset($relatedDataMap['image']) && $relatedDataMap['image']->hasContent()) {
                            /** @var \eZImageAliasHandler $attributeContent */
                            $attributeContent = $relatedDataMap['image']->content();
                            $image = $attributeContent->attribute('original');
                            $url = $image['full_path'];
                            eZURI::transformURI($url, true, 'full');
                            $this->doc['image'] = [
                                '@type' => ConverterHelper::compactUri('http://schema.org/URL', $this->context),
                                '@id' => $url,
                            ];
                        }
                    }
                }
            }
        }
    }
}