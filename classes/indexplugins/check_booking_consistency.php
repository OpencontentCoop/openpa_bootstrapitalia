<?php

class CheckBookingConsistency implements ezfIndexPlugin
{
    public function modify(eZContentObject $contentObject, &$docList)
    {
        if (StanzaDelCittadinoBooking::factory()->isEnabled()) {
            switch ($contentObject->attribute('class_identifier')) {
                case 'organization':
                    if (StanzaDelCittadinoBooking::checkOfficePlaceConsistency(
                        (int)$contentObject->attribute('id')
                    )) {
                        StanzaDelCittadinoBooking::refreshView();
                    }
                    break;
                case 'public_service':
                    if (StanzaDelCittadinoBooking::checkServiceOfficeConsistency(
                        (int)$contentObject->attribute('id')
                    )) {
                        StanzaDelCittadinoBooking::refreshView();
                    }
                    break;
            }
        }
    }

}