<?php

class InefficiencyBuiltinApp extends BuiltinApp
{
    private $serviceObject;

    private $isAppEnabled;

    public function __construct()
    {
        parent::__construct('inefficiency', 'Report a inefficiency');
    }

    protected function getAppRootId(): string
    {
        return 'oc-inefficiencies';
    }

    protected function getServiceObject(): ?eZContentObject
    {
        return null;
    }

    protected function getServiceId(): ?string
    {
        return 'inefficiency';
    }

    protected function isAppEnabled(): bool
    {
        if ($this->isAppEnabled === null) {
            $contacts = (new OpenPAPageData())->getContactsData();
            $this->isAppEnabled = !(!empty($contacts['link_segnalazione_disservizio'])) && self::getCurrentOptions('TenantUrl');
        }

        return $this->isAppEnabled;
    }

    protected function getDescriptionListItem(): array
    {
        return [
            'is_enabled' => $this->isAppEnabled(),
            'text' => $this->isAppEnabled() ?
                '<a href="/bootstrapitalia/info#Builtin" target="_blank">È possibile configurare l\'url custom delle categorie di segnalazione, il bounding box e il campo "Valuta l\'importanza del problema"</a>' :
                '',
        ];
    }
}