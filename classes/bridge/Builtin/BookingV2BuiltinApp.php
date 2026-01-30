<?php

class BookingV2BuiltinApp extends ServiceFormBuiltinApp
{
    protected $appStorageIdentifier = 'booking_v2';

    private $isAppEnabled;

    public function __construct()
    {
        $appLabel = (new BookingBuiltinApp())->getAppLabel();
        $serviceId = self::getCurrentOptions('BookingV2ServiceUuid');
        parent::__construct($appLabel, $serviceId);
    }

    protected function getAppRootId(): string
    {
        return '';
    }

    protected function isAppEnabled(): bool
    {
        if ($this->isAppEnabled === null) {
            $contacts = (new OpenPAPageData())->getContactsData();
            $this->isAppEnabled = !(!empty($contacts['link_prenotazione_appuntamento']))
                && self::getCurrentOptions('EnableBookingV2')
                && self::getCurrentOptions('TenantUrl');
        }


        return $this->isAppEnabled;
    }

    protected function getTemplate(): string
    {
        return 'openpa/built_in_app_service_form.tpl';
    }

    protected function getServiceId(): ?string
    {
        return $this->serviceId;
    }

    protected function getDescriptionListItem(): array
    {
        if (StanzaDelCittadinoBooking::factory()->isEnabled()
            && StanzaDelCittadinoBridge::factory()->getTenantUri()) {
            $isCurrentVersionActive = self::getCurrentOptions('EnableBookingV2');

            $text = 'Versione avanzata con formio';
            $configLink = '<br><a href="/bootstrapitalia/info#Builtin" target="_blank">Attiva/disattiva versione</a>';

            if (!$this->getServiceId() || !$isCurrentVersionActive) {
                if (!$isCurrentVersionActive){
                    return [
                        'is_enabled' => false,
                        'text' => $text.$configLink
                    ];
                }
                return [
                    'is_enabled' => false,
                    'text' => $text.'<br><b>Occorre <a href="/bootstrapitalia/info#Builtin" target="_blank">configurare</a> un <code>service_id</code></b>',
                ];
            }

            return [
                'is_enabled' => $this->isAppEnabled(),
                'text' => $text.$configLink,
            ];
        }
        return parent::getDescriptionListItem();
    }

    public function hasProductionUrl(): bool
    {
        $description = $this->getDescriptionListItem();
        return $description['is_enabled'];
    }

    public function getProductionUrl(): ?string
    {
        return '/prenota_appuntamento';
    }
}