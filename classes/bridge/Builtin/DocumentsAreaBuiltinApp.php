<?php

class DocumentsAreaBuiltinApp extends BuiltinApp
{
    public function __construct()
    {
        parent::__construct('documents-area', 'Documenti');
    }

    protected function getAppRootId(): string
    {
        return 'ap-documents';
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