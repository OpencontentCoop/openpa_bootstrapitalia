<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;

class AddPlaceClassConnector extends ClassConnector
{
    private $latitude;

    private $longitude;

    private $address = '';

    private $osmData;

    public function __construct(eZContentClass $class, $helper)
    {
        parent::__construct($class, $helper);

        $this->latitude = $_GET['lat'];
        $this->longitude = $_GET['lon'];
    }

    private function loadOsmData()
    {
        $reverseParams = [
            'lat' => $this->latitude,
            'lon' => $this->longitude,
            'addressdetails' => 1,
            'zoom' => 18,
            'format' => 'json',
        ];
        $userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:73.0) Gecko/20100101 Firefox/73.0";
        $this->osmData['reverse_link'] = 'https://nominatim.openstreetmap.org/reverse?' . http_build_query($reverseParams);
        $this->osmData['reverse'] = json_decode(eZHTTPTool::getDataByURL($this->osmData['reverse_link'], false, $userAgent), true);
        if (isset($this->osmData['reverse']['place_id'])){
            $detailParams = [
                'place_id' => $this->osmData['reverse']['place_id'],
                'format' => 'json',
            ];
            $this->osmData['details_link'] = 'https://nominatim.openstreetmap.org/details?' . http_build_query($detailParams);
            $this->osmData['details'] = json_decode(eZHTTPTool::getDataByURL($this->osmData['details_link'], false, $userAgent), true);
        }

        if (isset($this->osmData['reverse']['address'])){
            $addressParts = [];
            if (isset($this->osmData['reverse']['address']['road'])){
                $addressParts[] = $this->osmData['reverse']['address']['road'];
            }elseif (isset($this->osmData['reverse']['address']['pedestrian'])){
                $addressParts[] = $this->osmData['reverse']['address']['pedestrian'];
            }elseif (isset($this->osmData['reverse']['address']['suburb'])){
                $addressParts[] = $this->osmData['reverse']['address']['suburb'];
            }

            if (isset($this->osmData['reverse']['address']['postcode'])){
                $addressParts[] = ', ' . $this->osmData['reverse']['address']['postcode'];
            }

            if (isset($this->osmData['reverse']['address']['town'])){
                $addressParts[] = $this->osmData['reverse']['address']['town'];
            }elseif (isset($this->osmData['reverse']['address']['city'])){
                $addressParts[] = $this->osmData['reverse']['address']['city'];
            }elseif (isset($this->osmData['reverse']['address']['village'])){
                $addressParts[] = $this->osmData['reverse']['address']['village'];
            }

            if (isset($this->osmData['reverse']['address']['country'])){
                $addressParts[] = $this->osmData['reverse']['address']['country'];
            }

            $this->address = implode(' ', $addressParts);
        }
    }

    public function getSchema()
    {
        $this->loadOsmData();
        $schema = parent::getSchema();
        $schema['title'] = \ezpI18n::tr('add_place_gui', "Fill some information about your place");

        if (isset($this->osmData['details']['names']['name'])){
            $schema['properties']['name']['default'] = $this->osmData['details']['names']['name'];
        }

        $schema['properties']['has_address']['type'] = 'hidden';
        $schema['properties']['has_address']['default'] = json_encode([
            'latitude' =>  $this->latitude,
            'longitude' =>  $this->longitude,
            'address' => $this->address
        ]);

        return $schema;
    }

    public function getOptions()
    {
        $options = parent::getOptions();
        $options['fields']['has_address']['type'] = 'hidden';
        $options['fields']['topics']['hideNone'] = true;

        return $options;
    }


    protected function getPayloadFromArray(array $data)
    {
        $payload = parent::getPayloadFromArray($data);

        $payload->setData(
            $this->getHelper()->getSetting('language'),
            'has_address',
            json_decode($data['has_address'], true)
        );

        return $payload;
    }

    public function submit()
    {
        $result = parent::submit();

        $states = OpenPABase::initStateGroup('privacy', ['public', 'private']);
        $object = eZContentObject::fetch((int)$result['content']['metadata']['id']);
        if ($object instanceof eZContentObject){
            $object->assignState($states['privacy.private']);
            eZSearch::addObject($object);
        }

        return $result;
    }


}