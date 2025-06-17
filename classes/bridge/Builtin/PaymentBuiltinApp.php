<?php

class PaymentBuiltinApp extends BuiltinApp
{
    public function __construct()
    {
        parent::__construct('payment', 'Make a payment');
    }

    protected function getAppRootId(): string
    {
        return 'oc-paymentsDue';
    }

    protected function isAppEnabled(): bool
    {
        return self::getCurrentOptions('TenantUrl') && $this->getServiceId();
    }

    protected function getDescriptionListItem(): array
    {
        return [
            'is_enabled' => $this->isAppEnabled(),
            'text' => 'Per eseguire il test occorre specificare un valore <code>service_id</code> come parametro dell\'url',
        ];
    }

    public function hasProductionUrl(): bool
    {
        return $this->isAppEnabled();
    }

    public function getProductionUrl(): ?string
    {
        return '/pagamento?service_id=' . $this->getServiceId();
    }

}