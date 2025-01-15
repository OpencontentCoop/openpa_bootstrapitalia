<?php

class BootstrapItaliaLoginOauth
{
    const CURRENT_SESSION_VARNAME = 'OauthUserLoggedIn';

    private static $currentOptions;

    private static $instance;

    public static function instance(): BootstrapItaliaLoginOauth
    {
        if (self::$instance === null) {
            self::$instance = new BootstrapItaliaLoginOauth;
        }
        return self::$instance;
    }

    public function isEnabled(): bool
    {
        $current = $this->getCurrentOptions();
        return $current['enabled'] ?? false;
    }

    public function setCurrentOptions(array $options): void
    {
        if (isset($options['enabled'])) {
            $this->allowAccess();
            $options['enabled'] = true;
        } else {
            $this->disallowAccess();
            $options['enabled'] = false;
        }
        $locale = eZLocale::currentLocaleCode();
        $newOptions = [];
        foreach ($this->getOptionsDefinition() as $definition) {
            if (!isset($definition['localized']) || $definition['localized'] === false) {
                $newOptions[$definition['identifier']] = $options[$definition['identifier']] ?? null;
            } else {
                $newOptions[$definition['identifier']][$locale] = $options[$definition['identifier']] ?? null;
            }
        }
        $siteData = eZSiteData::fetchByName('login_oauth');
        if (!$siteData instanceof eZSiteData) {
            $siteData = eZSiteData::create('login_oauth', json_encode([]));
        }
        $data = json_decode($siteData->attribute('value'), true);
        $data = array_merge($data, $newOptions);
        $siteData->setAttribute('value', json_encode($data));
        $siteData->store();
    }

    private function getCurrentOptions()
    {
        if (self::$currentOptions === null) {
            $siteData = eZSiteData::fetchByName('login_oauth');
            if (!$siteData instanceof eZSiteData) {
                $siteData = eZSiteData::create('login_oauth', json_encode([]));
            }
            $data = json_decode($siteData->attribute('value'), true);
            $locale = eZLocale::currentLocaleCode();
            foreach ($this->getOptionsDefinition() as $definition) {
                if (isset($definition['localized']) && $definition['localized'] === true) {
                    $data[$definition['identifier']] = $data[$definition['identifier']][$locale] ?? null;
                }
            }
            self::$currentOptions = $data;
        }

        return self::$currentOptions;
    }

    private function allowAccess()
    {
        OpenPABase::initRole('Accesso oAuth', [
            [
                'ModuleName' => 'login-oauth',
                'FunctionName' => '*',
            ],
        ], true)->assignToUser(
            (int)eZINI::instance()->variable('UserSettings', 'AnonymousUserID')
        );
    }

    private function disallowAccess()
    {
        OpenPABase::initRole('Accesso oAuth', [
            'ModuleName' => 'content',
            'FunctionName' => '*',
        ])->removeThis();
    }

    public function getOptionsDefinitionWithCurrentData(): array
    {
        $current = $this->getCurrentOptions();
        return $this->getOptionsDefinition($current);
    }

    private function getOptionsDefinition(array $current = []): array
    {
        return [
            [
                'identifier' => 'enabled',
                'name' => 'Abilita accesso tramite oAuth',
                'type' => 'boolean',
                'localized' => true,
                'current_value' => $current['enabled'] ?? null,
            ],
//            [
//                'identifier' => 'buttonLabel',
//                'name' => 'Bottone visualizzato in accesso redazione',
//                'placeholder' => 'Accedi tramite oAuth',
//                'type' => 'string',
//                'localized' => true,
//                'current_value' => $current['buttonLabel'] ?? null,
//            ],
            [
                'identifier' => 'clientId',
                'name' => 'Client Id',
                'placeholder' => '',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['clientId'] ?? null,
            ],
            [
                'identifier' => 'clientSecret',
                'name' => 'Client Secret',
                'placeholder' => '',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['clientSecret'] ?? null,
            ],
            [
                'identifier' => 'urlAuthorize',
                'name' => 'Authorize url',
                'placeholder' => 'https://example.com/authorize',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['urlAuthorize'] ?? null,
            ],
            [
                'identifier' => 'urlAccessToken',
                'name' => 'AccessToken url',
                'placeholder' => 'https://example.com/token',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['urlAccessToken'] ?? null,
            ],
            [
                'identifier' => 'urlResourceOwnerDetails',
                'name' => 'ResourceOwnerDetails url',
                'placeholder' => 'https://example.com/api/profile',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['urlResourceOwnerDetails'] ?? null,
            ],
            [
                'identifier' => 'scopes',
                'name' => 'Scopes',
                'placeholder' => 'profile',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['scopes'] ?? null,
            ],
            [
                'identifier' => 'logoutUrl',
                'name' => 'Single logout url',
                'placeholder' => 'https://example.com/slo',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['logoutUrl'] ?? null,
            ],
            [
                'identifier' => 'firstNameMap',
                'name' => 'Mappatura per il nome',
                'placeholder' => '',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['firstNameMap'] ?? null,
            ],
            [
                'identifier' => 'lastNameMap',
                'name' => 'Mappatura per il cognome',
                'placeholder' => '',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['lastNameMap'] ?? null,
            ],
            [
                'identifier' => 'loginMap',
                'name' => 'Mappatura per il nome utente',
                'placeholder' => '',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['loginMap'] ?? null,
            ],
            [
                'identifier' => 'emailMap',
                'name' => 'Mappatura per l\'indirizzo email',
                'placeholder' => '',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['emailMap'] ?? null,
            ],
            [
                'identifier' => 'canCreateUser',
                'name' => 'Crea nuovi utenti se non presenti nel sistema',
                'type' => 'boolean',
                'localized' => true,
                'current_value' => $current['canCreateUser'] ?? null,
            ],
            [
                'identifier' => 'allowedEmails',
                'name' => 'Abilita l\'accesso solo agli indirizzi email',
                'placeholder' => 'info@example.com,admin@example.com,...',
                'type' => 'string',
                'localized' => true,
                'current_value' => $current['allowedEmails'] ?? null,
            ],
        ];
    }

    public function getProviderSettings(): array
    {
        $current = $this->getCurrentOptions();
        $redirectUri = '/login-oauth';
        eZURI::transformURI($redirectUri, true, 'full');
        return [
            'clientId' => $current['clientId'] ?? null,
            'clientSecret' => $current['clientSecret'] ?? null,
            'redirectUri' => $redirectUri,
            'urlAuthorize' => $current['urlAuthorize'] ?? null,
            'urlAccessToken' => $current['urlAccessToken'] ?? null,
            'urlResourceOwnerDetails' => $current['urlResourceOwnerDetails'] ?? null,
            'scopes' => $current['scopes'] ?? null,
            'scopeSeparator' => ',',
        ];
    }

    public function getAttributesMap(): array
    {
        $current = $this->getCurrentOptions();
        return [
            'first_name' => $current['firstNameMap'] ?? null,
            'last_name' => $current['lastNameMap'] ?? null,
            'login' => $current['loginMap'] ?? null,
            'email' => $current['emailMap'] ?? null,
        ];
    }

    public function canCreateUserIfNeeded(): bool
    {
        $current = $this->getCurrentOptions();
        return boolval($current['canCreateUser'] ?? null);
    }

    public function getAllowedEmailList(): array
    {
        $current = $this->getCurrentOptions();
        $allowedEmails = $current['allowedEmails'] ?? '';
        if (!empty($allowedEmails)) {
            $allowedEmails = trim($allowedEmails);
            return explode(',', $allowedEmails);
        }
        return [];
    }

    public static function interceptLogout()
    {
        if (
            eZHTTPTool::instance()->hasGetVariable('logout') &&
            eZHTTPTool::instance()->hasSessionVariable(self::CURRENT_SESSION_VARNAME) &&
            self::instance()->isEnabled()
        ) {
            eZHTTPTool::instance()->removeSessionVariable(self::CURRENT_SESSION_VARNAME);
            $options = self::instance()->getCurrentOptions();
            if (!empty($options['logoutUrl'])) {
                header('Location: ' . $options['logoutUrl']);
                eZExecution::cleanExit();
            }
        }
        eZHTTPTool::instance()->removeSessionVariable(self::CURRENT_SESSION_VARNAME);
    }
}