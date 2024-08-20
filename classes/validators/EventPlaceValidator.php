<?php

class EventPlacesValidator extends AbstractBootstrapItaliaInputValidator
{
    const MULTIFIELD_ERROR_MESSAGE = "Popolare almeno un campo tra '%s' e '%s'";

    public function validate(): array
    {
        if ($this->class->attribute('identifier') == 'event') {
            if (
                eZContentObject::fetchByRemoteID('all-events')
                || eZContentObject::fetchByRemoteID(OpenPABase::getCurrentSiteaccessIdentifier() . '_openpa_agenda')
            ) {
                $takePlaceIn = false;
                $geo = false;

                $takePlaceInName = 'takes_place_in';
                $geoName = 'geo';
                $countExisting = 0;

                foreach ($this->contentObjectAttributes as $contentObjectAttribute) {
                    $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                    if ($contentClassAttribute->attribute('identifier') == 'takes_place_in') {
                        $countExisting++;
                        $takePlaceIn = $this->hasRelations($contentObjectAttribute);
                        $takePlaceInName = $contentClassAttribute->attribute('name');
                    } elseif ($contentClassAttribute->attribute('identifier') == 'geo') {
                        $countExisting++;
                        $geo = $this->hasGeo($contentObjectAttribute);
                        $geoName = $contentClassAttribute->attribute('name');
                    }
                }
                if ($countExisting === 2 && !$takePlaceIn && !$geo) {
                    return [
                        'identifier' => 'takes_place_in',
                        'text' => sprintf(
                            self::MULTIFIELD_ERROR_MESSAGE,
                            $takePlaceInName,
                            $geoName
                        ),
                    ];
                }
            }
        }

        return [];
    }
}