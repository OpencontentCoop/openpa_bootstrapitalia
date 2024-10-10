<?php

class LoginBoxBuiltinApp extends BuiltinApp
{
    private $isAppEnabled;

    public function __construct()
    {
        parent::__construct('login', 'Login');
    }

    protected function getAppRootId(): string
    {
        return 'oc-login-box';
    }

    protected function isAppEnabled(): bool
    {
        return OpenPAINI::variable('StanzaDelCittadinoBridge', 'UseLoginBox', 'disabled') === 'enabled';
    }

}