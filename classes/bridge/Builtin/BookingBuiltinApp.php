<?php

class BookingBuiltinApp extends BuiltinApp
{
    private $isAppEnabled;

    public function __construct()
    {
        parent::__construct('booking', 'Book an appointment');
    }

    protected function getAppRootId(): string
    {
        return 'oc-bookings';
    }

    protected function getServiceObject(): ?eZContentObject
    {
        if ($this->serviceObject === null) {
            $this->serviceObject = eZContentObject::fetchByRemoteID('bookings');
        }

        return $this->serviceObject;
    }

    protected function isAppEnabled(): bool
    {
        if ($this->isAppEnabled === null) {
            $contacts = (new OpenPAPageData())->getContactsData();
            $this->isAppEnabled = !(!empty($contacts['link_prenotazione_appuntamento'])) && self::getCurrentOptions('TenantUrl');
        }

        return $this->isAppEnabled;
    }

    protected function getDescriptionListItem(): array
    {
        if (StanzaDelCittadinoBooking::factory()->isEnabled() && StanzaDelCittadinoBridge::factory()->getTenantUri()) {
            return [
                'is_enabled' => false,
                'text' => 'È attivo il <b>widget di prenotazione del cms</b>: per mettere in produzione questa versione occorre <a href="/bootstrapitalia/info#Booking" target="_blank">disattivare</a> il widget di prenotazione del cms',
            ];
        }
        return parent::getDescriptionListItem();
    }

}
