<?php

class OperatorsAreaBuiltinApp extends BuiltinApp
{
    public function __construct()
    {
        parent::__construct('operators-area', 'Area operatori');
    }

    protected function getAppRootId(): string
    {
        return 'ap-documents-operator';
    }

    protected function isAppEnabled(): bool
    {
        return true;
    }

    protected function getTemplate(): string
    {
        return 'openpa/built_in_app_personal-area.tpl';
    }

    public function getAppPath(): ?string
    {
        return '/bootstrapitalia/widget/' . $this->getAppIdentifier();
    }

    public function hasProductionUrl(): bool
    {
        return $this->isAppEnabled();
    }

    public function getProductionUrl(): ?string
    {
        return '/operatori_area';
    }
}