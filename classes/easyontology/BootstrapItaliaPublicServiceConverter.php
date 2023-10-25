<?php

use Opencontent\Easyontology\ConverterHelper;

class BootstrapItaliaPublicServiceConverter extends \Opencontent\Easyontology\AbstractConverter
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
        $pagedata = new \OpenPAPageData();
        $contacts = $pagedata->getContactsData();

        $this->doc = [
            "@context" => "https://schema.org",
            "@id" => $this->getId(),
            "@type" => "GovernmentService",
            "name" => '',
            "serviceType" => '',
            "serviceOperator" => [
                'name' => eZINI::instance()->variable('SiteSettings', 'SiteName'),
            ],
            "areaServed" => [
                'name' => '',
            ],
            "audience" => [
                'name' => '',
            ],
            "availableChannel" => [
                "serviceUrl" => '',
                "serviceLocation" => [
                    'name' => eZINI::instance()->variable('SiteSettings', 'SiteName'),
                    'address' => [
                        "streetAddress" => $contacts['indirizzo'] ?? '',
                        "postalCode" => $contacts['cap'] ?? '',
                        "addressLocality" => $contacts['comune'] ?? '',
                    ],
                ],
            ],
        ];

        if ($this->content instanceof eZContentObject
            && $this->content->attribute('class_identifier') === 'public_service') {
            $this->doc['name'] = $this->content->attribute('name');
            $dataMap = $this->content->dataMap();
            if (isset($dataMap['type']) && $dataMap['type']->hasContent()) {
                $this->doc['serviceType'] = $dataMap['type']->content()->attribute('keywords')[0];
            }
            if (isset($dataMap['has_online_contact_point']) && $dataMap['has_online_contact_point']->hasContent()) {
                $list = explode('-', $dataMap['has_online_contact_point']->toString());
                $item = eZContentObject::fetch((int)$list[0]);
                if ($item instanceof eZContentObject) {
                    $this->doc['serviceOperator']['name'] = $item->attribute('name');
                }
            }
            if (isset($dataMap['has_spatial_coverage']) && $dataMap['has_spatial_coverage']->hasContent()) {
                if ($dataMap['has_spatial_coverage']->attribute('data_type_string') === eZTagsType::DATA_TYPE_STRING) {
                    $this->doc['areaServed']['name'] = $dataMap['has_spatial_coverage']->content()->attribute('keywords')[0];
                }elseif ($dataMap['has_spatial_coverage']->attribute('data_type_string') === 'openpacomuniitaliani') {
                    $this->doc['areaServed']['name'] = implode(', ', $dataMap['has_spatial_coverage']->dataType()->getContentNameList($dataMap['has_spatial_coverage']));
                }else{
                    $this->doc['areaServed']['name'] = $dataMap['has_spatial_coverage']->toString();
                }
            }
            if (isset($dataMap['audience']) && $dataMap['audience']->hasContent()) {
                $this->doc['audience']['audienceType'] = trim(strip_tags($dataMap['audience']->toString()));
            }
            $this->doc['availableChannel']['serviceUrl'] = rtrim(\eZSys::serverURL(), '/')
                . '/' . $this->content->mainNode()->attribute('url_alias');

            if (isset($dataMap['is_physically_available_at']) && $dataMap['is_physically_available_at']->hasContent()) {
                $list = explode('-', $dataMap['is_physically_available_at']->toString());
                $item = eZContentObject::fetch((int)$list[0]);
                if ($item instanceof eZContentObject) {
                    $this->doc['availableChannel']['serviceLocation']['name'] = $item->attribute('name');
                    $itemDataMap = $item->dataMap();
                    if (isset($itemDataMap['has_address']) && $itemDataMap['has_address']->hasContent()) {
                        /** @var eZGmapLocation $address */
                        $address = $itemDataMap['has_address']->content();
                        $lng = number_format($address->attribute('longitude'), 8);
                        $lat = number_format($address->attribute('latitude'), 8);
                        $this->doc['availableChannel']['serviceLocation']['address']['streetAddress'] = $address->attribute('address');
//                        $this->doc['availableChannel']['serviceLocation']['geo']['longitude'] = $lng;
//                        $this->doc['availableChannel']['serviceLocation']['geo']['latitude'] = $lat;

                        $nominatimUrl = "https://nominatim.openstreetmap.org/reverse?lat={$lat}&lon={$lng}&format=json";
                        $userAgent = "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0";
                        $addressData = json_decode(
                            eZHTTPTool::instance()::getDataByURL($nominatimUrl, false, $userAgent),
                            true
                        );

                        if (isset($addressData['address']['postcode'])){
                            $this->doc['availableChannel']['serviceLocation']['address']['postalCode'] = $addressData['address']['postcode'];
                        }
                        if (isset($addressData['address']['county'])){
                            $addressLocality = '';
                            if (isset($addressData['address']['village'])){
                                $addressLocality = $addressData['address']['village'] . ' ';
                            }
                            $addressLocality .= $addressData['address']['county'];
                            $this->doc['availableChannel']['serviceLocation']['address']['addressLocality'] = $addressLocality;
                        }
                    }
                }
            }
        }
    }
}