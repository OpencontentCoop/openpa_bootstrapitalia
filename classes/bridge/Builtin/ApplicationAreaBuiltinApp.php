<?php

class ApplicationAreaBuiltinApp extends BuiltinApp
{
    public function __construct()
    {
        parent::__construct('applications-area', 'Pratiche');
    }

    protected function getAppRootId(): string
    {
        return 'ap-applications';
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

    public function getParentApp(): ?BuiltinApp
    {
        return new PersonalAreaBuiltinApp();
    }

    public function getProductionUrl(): ?string
    {
        return '/pratiche';
    }
}