<?php

class PaymentsAreaBuiltinApp extends BuiltinApp
{
    public function __construct()
    {
        parent::__construct('payments-area', 'Pagamenti');
    }

    protected function getAppRootId(): string
    {
        return 'ap-payments';
    }

    protected function isAppEnabled(): bool
    {
        return false;
    }

    protected function getTemplate(): string
    {
        return 'openpa/built_in_app_personal-area.tpl';
    }

    public function getParentApp(): ?BuiltinApp
    {
        return new PersonalAreaBuiltinApp();
    }
}