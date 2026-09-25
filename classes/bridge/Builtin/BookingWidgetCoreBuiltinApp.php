<?php

class BookingWidgetCoreBuiltinApp extends BuiltinApp
{
    public function __construct()
    {
        parent::__construct('service-form-core', (new BookingBuiltinApp())->getAppLabel());
    }

    protected function getAppRootId(): string
    {
        return '';
    }

    protected function getTemplate(): string
    {
        return 'openpa/built_in_app_service_form.tpl';
    }

    protected function getServiceId(): ?string
    {
        // Il template condiviso usa $service_id come gate di visibilità del widget;
        // <widget-core> non ha un concetto di service_id (nessun instradamento server-side),
        // quindi qui è solo un valore fisso non vuoto per superare il gate.
        return 'booking-widget-core';
    }

    protected function isAppEnabled(): bool
    {
        return (bool)self::getCurrentOptions('EnableBookingWidgetCore')
            && (bool)self::getCurrentOptions('TenantUrl')
            && (bool)$this->getBookingWidgetCoreDestinationUrl()
            && (bool)$this->getBookingWidgetCoreFormServerUrl();
    }

    protected function getBookingWidgetCoreDestinationUrl(): ?string
    {
        return OpenPAINI::variable('StanzaDelCittadinoBridge', 'BookingWidgetCoreDestinationUrl') ?: null;
    }

    protected function getBookingWidgetCoreFormServerUrl(): ?string
    {
        return OpenPAINI::variable('StanzaDelCittadinoBridge', 'BookingWidgetCoreFormServerUrl') ?: null;
    }

    protected function getBookingWidgetCoreAuthParamsJson(): ?string
    {
        $host = self::getCurrentOptions('TenantUrl');
        if (!$host) {
            return null;
        }

        return json_encode([
            'type' => 'sdc',
            'host' => $host,
            'skipLogin' => (bool)self::getCurrentOptions('BookingWidgetCoreSkipLogin'),
            'loginProvidersLabel' => $this->getLoginProvidersLabel(),
        ]);
    }

    protected function getBookingWidgetCoreFormIoParamsJson(): ?string
    {
        $host = self::getCurrentOptions('TenantUrl');
        if (!$host) {
            return null;
        }

        $siteUrl = eZINI::instance()->variable('SiteSettings', 'SiteURL');

        return json_encode([
            'first-availability' => $host,
            'booking-config' => 'https://' . $siteUrl . '/api/openapi/booking-config?limit=99',
        ]);
    }

    private function getLoginProvidersLabel(): string
    {
        $labels = [];
        $providers = [
            'spid' => 'SPID',
            'cie' => 'CIE',
            'eidas' => 'eIDAS',
            'cns' => 'CNS',
        ];
        foreach ($providers as $key => $label) {
            if (PersonalAreaLogin::instance()->hasAccess($key)) {
                $labels[] = $label;
            }
        }

        return implode(', ', $labels);
    }

    protected function getDescriptionListItem(): array
    {
        if (!self::getCurrentOptions('TenantUrl')) {
            return [
                'is_enabled' => false,
                'text' => 'Widget core con <a href="/bootstrapitalia/info#Builtin" target="_blank">configurazione</a> mancante: manca l\'url del tenant',
            ];
        }
        if (!$this->getBookingWidgetCoreDestinationUrl() || !$this->getBookingWidgetCoreFormServerUrl()) {
            return [
                'is_enabled' => false,
                'text' => 'Widget core non disponibile in questo ambiente: manca la configurazione ini <code>BookingWidgetCoreDestinationUrl</code>/<code>BookingWidgetCoreFormServerUrl</code>',
            ];
        }

        return [
            'is_enabled' => $this->isAppEnabled(),
            'text' => 'Widget core<br><a href="/bootstrapitalia/info#Builtin" target="_blank">Attiva/disattiva versione</a>',
        ];
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
