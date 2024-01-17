<?php

use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\ContentSearch;

class BuiltinApp extends OpenPATempletizable
{
    private $appIdentifier;

    private $appLabel;

    private $siteData;

    public function __construct(string $appName, string $appLabel)
    {
        $this->appIdentifier = $appName;
        $this->appLabel = $appLabel;

        parent::__construct([
            'src' => $this->getWidgetSrc()
        ]);
    }

    /**
     * @return string
     */
    protected function getAppIdentifier(): string
    {
        return $this->appIdentifier;
    }

    /**
     * @return string
     */
    public function getAppLabel(): string
    {
        return $this->appLabel;
    }

    private function getSiteData(string $config = null): ?eZPersistentObject
    {
        if ($this->siteData === null || $config) {
            $name = "built_in_{$this->appIdentifier}_config";
            $this->siteData = eZSiteData::fetchByName($name) ?? null;
            if ($config !== null) {
                if (!$this->siteData instanceof eZSiteData) {
                    $this->siteData = eZSiteData::create($name, '');
                }
                $this->siteData->setAttribute('value', $config);
                $this->siteData->store();
            }
        }

        return $this->siteData;
    }

    protected function hasCustomConfig(): bool
    {
        return $this->getSiteData() instanceof eZSiteData && !empty($this->getSiteData()->attribute('value'));
    }

    protected function getCustomConfig(): string
    {
        return $this->hasCustomConfig() ? $this->getSiteData()->attribute('value') : '';
    }

    public function setCustomConfig(string $config): void
    {
        if (eZUser::currentUser()->hasAccessTo(
                'bootstrapitalia',
                'config_built_in_apps'
            )['accessWord'] === 'yes') {
            $this->getSiteData($config);
        }
    }

    public static function getWindowVariables(): array
    {
//        $privacy = eZContentObject::fetchByRemoteID('privacy-policy-link');
//        $privacyUrl = $privacy ? $privacy->mainNode()->attribute('url_alias') : '/Privacy';
        $privacyUrl = '/Privacy';
        eZURI::transformURI($privacyUrl, false, 'full');
        $baseUrl = StanzaDelCittadinoBridge::factory()->getApiBaseUri();
        $authUrl = StanzaDelCittadinoBridge::factory()->buildApiUrl('/login');
        $window = [
            'OC_BASE_URL' => $baseUrl,
            'OC_PRIVACY_URL' => $privacyUrl,
            'OC_AUTH_URL' => $authUrl,
        ];
        if (OpenPAINI::variable('StanzaDelCittadinoBridge', 'UseLoginBox', 'disabled') !== 'modal'){
            $window['OC_SPID_BUTTON'] = 'true';
        }

        return $window;
    }

    protected function getWidgetSrc(): string
    {
        $path = OpenPAINI::variable('StanzaDelCittadinoBridge', 'BuiltInWidgetSource_' . $this->getAppIdentifier(), '');
        if (empty($path)){
            return '';
        }
        $host = StanzaDelCittadinoBridge::factory()->getHost();
        return str_replace('%host%', $host, $path);
    }

    protected function getWidgetStyle(): string
    {
        $path = OpenPAINI::variable('StanzaDelCittadinoBridge', 'BuiltInWidgetStyle_' . $this->getAppIdentifier(), '');
        if (empty($path)){
            return '';
        }
        $host = StanzaDelCittadinoBridge::factory()->getHost();
        return str_replace('%host%', $host, $path);
    }

    protected function getAppRootId(): string
    {
        return OpenPAINI::variable('StanzaDelCittadinoBridge', 'RootId_' . $this->getAppIdentifier(), 'root');
    }

    protected function isAppEnabled(): bool
    {
        $pagedata = new \OpenPAPageData();
        $contacts = $pagedata->getContactsData();
        $field = OpenPAINI::variable('StanzaDelCittadinoBridge', 'ContactsField_' . $this->getAppIdentifier(), 'empty');

        return !(isset($contacts[$field]) && !empty($contacts[$field]));
    }

    protected function getCategory(): ?string
    {
        $identifier = OpenPAINI::variable('StanzaDelCittadinoBridge', 'ServiceIdentifier_' . $this->getAppIdentifier(), '');
        if (empty($identifier)){
            return null;
        }

        $contentSearch = new ContentSearch();
        $currentEnvironment = EnvironmentLoader::loadPreset('content');
        $contentSearch->setEnvironment($currentEnvironment);
        try{
            $data = (array)$contentSearch->search(
                'select-fields [data.type] classes [public_service] ' .
                'and identifier = "' . $identifier . '" ' .
                'and raw[meta_language_code_ms] = "' . eZLocale::currentLocaleCode() . '" ' .
                'limit 1',
                []
            );
        }catch (Exception $e){
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }

        return $data[0][0] ?? null;
    }

    public function getModuleResult(): array
    {
        $tpl = eZTemplate::factory();
        $tpl->setVariable('built_in_app_is_enabled', $this->isAppEnabled());
        $tpl->setVariable('built_in_app', $this->getAppIdentifier());
        $tpl->setVariable('built_in_app_root_id', $this->getAppRootId());
        $tpl->setVariable('built_in_app_script', $this->getCustomConfig());
        $tpl->setVariable('built_in_app_src', $this->getWidgetSrc());
        $tpl->setVariable('built_in_app_style', $this->getWidgetStyle());
        $tpl->setVariable('built_in_app_api_base_url', StanzaDelCittadinoBridge::factory()->getApiBaseUri());

        $Result = [];
        $Result['content'] = $tpl->fetch('design:openpa/built_in_app.tpl');
        $path = [];
        $homeUrl = '/';
        eZURI::transformURI($homeUrl);
        $path[] = [
            'text' => OpenPAINI::variable('GeneralSettings','ShowMainContacts', 'enabled') == 'enabled' ? 'Home' : OpenPaFunctionCollection::fetchHome()->getName(),
            'url' => $homeUrl,
        ];
        $allServices = eZContentObject::fetchByRemoteID('all-services');
        if ($allServices instanceof eZContentObject) {
            $allServiceUrl = $allServices->mainNode()->urlAlias();
            eZURI::transformURI($allServiceUrl);
            $path[] = [
                'text' => $allServices->attribute('name'),
                'url' => $allServiceUrl,
            ];
            $category = $this->getCategory();
            if ($category){
                $path[] = [
                    'text' => $category,
                    'url' => $allServiceUrl . '/(view)/' . $category,
                ];
            }
        }
        $path[] = [
            'text' => ezpI18n::tr('bootstrapitalia', $this->getAppLabel()),
            'url' => false,
        ];
        $Result['path'] = $path;
        $contentInfoArray = [
            'node_id' => null,
            'class_identifier' => null,
        ];
        $contentInfoArray['persistent_variable'] = [
            'show_path' => true,
            'built_in_app' => $this->getAppIdentifier(),
        ];
        if (is_array($tpl->variable('persistent_variable'))) {
            $contentInfoArray['persistent_variable'] = array_merge(
                $contentInfoArray['persistent_variable'],
                $tpl->variable('persistent_variable')
            );
        }
        $Result['content_info'] = $contentInfoArray;

        return $Result;
    }
}