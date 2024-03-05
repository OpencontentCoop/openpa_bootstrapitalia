<?php

class ObjectHandlerServiceEventLink extends ObjectHandlerServiceAttribute
{
    private $alwaysAvailable = true;

    private $type;

    private $topic;

    private $place;

    private $geo;

    private $contact;

    function run()
    {
        $this->fnData['has_public_event_typology'] = 'getPublicEventTypology';
        $this->fnData['has_public_event_typology_name'] = 'getPublicEventTypologyName';
        $this->fnData['topic'] = 'getTopic';
        $this->fnData['topic_name'] = 'getTopicName';
        $this->fnData['image'] = 'getImage';
        $this->fnData['takes_place_in'] = 'getTakesPlaceIn';
        $this->fnData['geo'] = 'getGeo';
        $this->fnData['has_online_contact_point'] = 'getHasOnlineContactPoint';
        $this->fnData['has_online_contact_info'] = 'getHasOnlineContactInfo';
        $this->fnData['has_offer'] = 'getHasOffer';
    }

    protected function getHasOffer()
    {
        return $this->getMatrixAsHash('virtual_has_offer');
    }

    protected function getHasOnlineContactPoint()
    {
        if ($this->contact === null) {
            $this->contact = false;
            $data = $this->getMatrixAsHash('virtual_has_online_contact_point');
            foreach ($data as $item) {
                if (!empty($item['id'])) {
                    $this->contact = eZContentObject::fetchByRemoteID($item['id']);
                    if ($this->contact instanceof eZContentObject) {
                        break;
                    }
                }
            }
        }

        return $this->contact;
    }

    protected function getHasOnlineContactInfo()
    {
        $data = $this->getMatrixAsHash('virtual_has_online_contact_point');
        return $data[0] && (!empty($data[0]['phone']) || !empty($data[0]['email']) || !empty($data[0]['website'])) ? $data[0] : null;
    }

    protected function getImage()
    {
        $data = $this->getMatrixAsHash('virtual_image');
        foreach ($data as $index => $image) {
            $data[$index]['url'] = OpenAgendaBridge::factory()->getOpenAgendaUrl() . $image['url'];
            if (OpenPAINI::variable('ImageSettings', 'FlyImgBaseUrl', '') !== '') {
                $baseUrl = rtrim(OpenPAINI::variable('ImageSettings', 'FlyImgBaseUrl'), '/') . '/';
                $filter = OpenPAINI::variable('ImageSettings', 'FlyImgDefaultFilter') . '/';
                $data[$index]['url'] = $baseUrl . $filter . $data[$index]['url'];
            }
        }

        return $data[0] ?? null;
    }

    protected function getTakesPlaceIn()
    {
        if ($this->place === null) {
            $this->place = false;
            $data = $this->getMatrixAsHash('virtual_takes_place_in');
            foreach ($data as $item) {
                if (!empty($item['id'])) {
                    $this->place = eZContentObject::fetchByRemoteID($item['id']);
                    if ($this->place instanceof eZContentObject) {
                        $this->geo = $item;
                        break;
                    }
                }
            }
        }

        return $this->place;
    }

    protected function getGeo()
    {
        if ($this->geo === null) {
            $data = $this->getMatrixAsHash('virtual_takes_place_in');
            $this->geo = $data[0] ?? null;
        }
        return $this->geo;
    }

    private function getMatrixAsHash($attributeIdentifier)
    {
        $headers = $data = [];
        if ($this->container->hasAttribute($attributeIdentifier)) {
            $matrix = $this->container->attribute($attributeIdentifier)
                ->attribute('contentobject_attribute')->content()->attribute('matrix');

            foreach ($matrix['columns']['sequential'] as $column) {
                $headers[] = $column['identifier'];
            }

            foreach ($matrix['rows']['sequential'] as $row) {
                $item = [];
                $columns = $row['columns'];
                foreach ($headers as $index => $header) {
                    $item[$header] = $columns[$index];
                }
                if (!$this->alwaysAvailable && isset($item['language'])
                    && $item['language'] != eZLocale::currentLocaleCode()) {
                    continue;
                }
                $data[] = $item;
            }
        }
        return $data;
    }

    protected function getPublicEventTypologyName()
    {
        $data = $this->getMatrixAsHash('virtual_has_public_event_typology');
        return $data[0]['name'] ?? null;
    }

    protected function getPublicEventTypology()
    {
        if ($this->type === null) {
            $this->type = false;
            $data = $this->getMatrixAsHash('virtual_has_public_event_typology');
            foreach ($data as $item) {
                $name = $item['name'];
                $tags = eZTagsObject::fetchByKeyword($name);
                if (count($tags)) {
                    $this->type = $tags[0];
                }
                break;
            }
        }

        return $this->type;
    }

    protected function getTopicName()
    {
        $data = $this->getMatrixAsHash('virtual_topic');
        return $data['name'] ?? null;
    }

    protected function getTopic()
    {
        if ($this->topic === null) {
            $this->topic = false;
            $data = $this->getMatrixAsHash('virtual_topic');
            foreach ($data as $item) {
                if (!empty($item['id'])) {
                    $this->topic = eZContentObject::fetchByRemoteID($item['id']);
                    if ($this->topic instanceof eZContentObject) {
                        break;
                    }
                }
            }
        }

        return $this->topic;
    }
}