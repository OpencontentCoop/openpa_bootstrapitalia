<?php

class PersonalAreaBuiltinApp extends BuiltinApp
{
    public function __construct()
    {
        parent::__construct('personal-area', 'Area personale');
    }

    protected function getAppRootId(): string
    {
        return 'ap-applications';
    }

    protected function isAppEnabled(): bool
    {
        return false;
    }

    protected function getTemplate(): string
    {
        return 'openpa/built_in_app_personal-area.tpl';
    }

    public function getAppPath(): ?string
    {
        return '/bootstrapitalia/widget/' . $this->getAppIdentifier();
    }


}