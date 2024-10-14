<?php

class ServiceFormBuiltinApp extends BuiltinApp
{
    protected $serviceId;

    public function __construct(string $appLabel, string $serviceId = null)
    {
        $this->serviceId = $serviceId;
        parent::__construct('service-form', $appLabel);
    }

    protected function getAppRootId(): string
    {
        return '';
    }

    protected function isAppEnabled(): bool
    {
        return self::getCurrentOptions('TenantUrl') && $this->getServiceId();
    }

    protected function getTemplate(): string
    {
        return 'openpa/built_in_app_service_form.tpl';
    }

    protected function getServiceId(): ?string
    {
        return $this->serviceId ?? parent::getServiceId();
    }

    protected function getDescriptionListItem(): array
    {
        if (!$this->getServiceId()) {
            return [
                'is_enabled' => false,
                'text' => 'Per eseguire il test occorre specificare un valore <code>service_id</code> come parametro dell\'url',
            ];
        }

        return [
            'is_enabled' => false, //@todo
            'text' => '',
        ];
    }

}