<?php

class InefficiencyV2BuiltinApp extends ServiceFormBuiltinApp
{
    public function __construct()
    {
        $appLabel = (new InefficiencyBuiltinApp())->getAppLabel();
        $serviceId = self::getCurrentOptions('InefficiencyV2ServiceUuid');
        parent::__construct($appLabel, $serviceId);
    }

    protected function getAppRootId(): string
    {
        return '';
    }

    protected function isAppEnabled(): bool
    {
        return self::getCurrentOptions('EnableInefficiencyV2') && self::getCurrentOptions('TenantUrl');
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
        $isCurrentVersionActive = self::getCurrentOptions('EnableInefficiencyV2');

        $text = 'Versione con formio';
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
}