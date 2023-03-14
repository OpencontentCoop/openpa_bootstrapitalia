<?php

class StanzaDelCittadinoBridge
{
    private static $instanceByPal;

    /**
     * @var ?string
     */
    private $apiBaseUrl;

    private $accessUrl;

    private $prefix = 'lang';

    private function __construct()
    {
    }

    public static function factory(): StanzaDelCittadinoBridge
    {
        return static::instanceByPersonalAreaLogin(PersonalAreaLogin::instance());
    }

    protected static function instanceByPersonalAreaLogin(PersonalAreaLogin $pal): StanzaDelCittadinoBridge
    {
        if (self::$instanceByPal === null) {
            self::$instanceByPal = new static();
            if ($pal->getUri()) {
                self::$instanceByPal->setUserLoginUri($pal->getUri());
            }
        }

        return self::$instanceByPal;
    }

    /**
     * @return StanzaDelCittadinoClient
     * @throws Exception
     */
    public function instanceNewClient(): StanzaDelCittadinoClient
    {
        $url = $this->getApiBaseUri();
        if (!$url){
            throw new Exception('Can not instantiate a client with empty server url');
        }

        return new StanzaDelCittadinoClient($url);
    }

    public function getProfileUri(): ?string
    {
        return $this->buildApiUrl('/api/users');
    }

    public function getTokenUri(): ?string
    {
        return $this->buildApiUrl('/api/session-auth?with-cookie=1');
    }

    public function getApiBaseUri(): ?string
    {
        if ($this->apiBaseUrl === null && OpenPAINI::variable('StanzaDelCittadinoBridge', 'AutoDiscover', 'disabled') === 'enabled') {
            $this->discoverApiBaseUrl();
        }
        return $this->apiBaseUrl;
    }

    public function buildApiUrl(string $path): ?string
    {
        $base = $this->getApiBaseUri();
        return $base ? $base . $path : null;
    }
    public function discoverApiBaseUrl(): void
    {
        $userLoginUri = $this->getUserLoginUri();
        $url = parse_url($userLoginUri, PHP_URL_HOST);
        if (strpos($userLoginUri, $this->prefix) !== false){
            $this->apiBaseUrl = 'https://' . $url . '/' . $this->prefix;
        }else{
            $cacheKey = 'sdc_api_base_url_for_' . md5($userLoginUri);
            $siteData = eZSiteData::fetchByName($cacheKey);
            if (!$siteData instanceof eZSiteData) {
                $path = parse_url($userLoginUri, PHP_URL_PATH);
                if ($path) {
                    $parts = explode('/', trim($path, '/'));
                    if (isset($parts[0])) {
                        $prefix = $parts[0];
                        $apiBaseUrl = 'https://' . $url . '/' . $prefix;
                        try {
                            if ((new StanzaDelCittadinoClient($apiBaseUrl))->getTenantInfo()) {
                                $siteData = eZSiteData::create($cacheKey, $apiBaseUrl);
                                $siteData->store();
                            }
                        }catch (Exception $e){
                            eZDebug::writeError($e->getMessage(), __METHOD__);
                            $siteData = eZSiteData::create($cacheKey, '');
                            $siteData->store();
                        }
                    }
                }
            }
            if ($siteData instanceof eZSiteData){
                $this->apiBaseUrl = $siteData->attribute('value');
            }
        }

        eZDebug::writeDebug('Get api base url: ' .  $this->apiBaseUrl, __METHOD__);
    }

    public function getUserLoginUri(): ?string
    {
        return $this->accessUrl;
    }

    public function setUserLoginUri(?string $accessUrl): void
    {
        eZDebug::writeDebug('Set access url: ' .  $accessUrl, __METHOD__);
        $this->accessUrl = $accessUrl;
    }

    public function getOperatorLoginUri(): ?string
    {
        $userAccessUrl = $this->getUserLoginUri();
        return $userAccessUrl ? str_replace('/user', '/operatori', $userAccessUrl) : null;
    }
}