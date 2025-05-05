<?php

use Opencontent\OpenApi\EndpointFactoryCollection;
use Opencontent\OpenApi\EndpointFactoryProvider;
use Opencontent\OpenApi\OperationFactoryCollection;

class BookingEndpointFactoryProvider extends EndpointFactoryProvider
{

    public function getEndpointFactoryCollection()
    {
        $factories = [];
        if (StanzaDelCittadinoBooking::factory()->isEnabled()){
            $factories = [
                (new BookingEndpointFactory())
                    ->setPath('/booking-config')
                    ->setTags(['prenotazione-appuntamenti'])
                    ->setOperationFactoryCollection(
                        new OperationFactoryCollection([
                            new BookingOperationFactory(),
                        ])
                    ),
            ];
        }
        return new EndpointFactoryCollection($factories);
    }
}