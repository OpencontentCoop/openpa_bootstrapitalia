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
            'src' => $this->getWidgetSrc(),
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
        $privacy = eZContentObject::fetchByRemoteID('83c7315f6a2fd9cee569e4cf5e73139d');
        $privacyUrl = '/Privacy';
        if ($privacy) {
            $privacyNode = $privacy->mainNode();
            if ($privacyNode instanceof eZContentObjectTreeNode) {
                $privacyUrl = $privacyNode->attribute('url_alias');
            }
        }
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

    protected function getServicePath()
    {
        $path = [];
        $serviceId = eZHTTPTool::instance()->hasGetVariable('service_id') ? eZHTTPTool::instance()->getVariable('service_id') : null;
        if (!$serviceId) {
            $referrer = eZSys::serverVariable('HTTP_REFERER');
            if ($referrer && strpos($referrer, '?service_id=') !== false) {
                $referrerQuery = parse_url($referrer, PHP_URL_QUERY);
                parse_str($referrerQuery, $referrerQueryArray);
                $serviceId = $referrerQueryArray['service_id'] ?? null;
            }
        }
        if ($serviceId) {
            $service = null;
            if (ServiceSync::isUuid($serviceId)) {
                $escapedServiceId = eZDB::instance()->escapeString($serviceId);
                $relationType = eZContentObject::RELATION_ATTRIBUTE;
                $classAttributeId = eZContentClassAttribute::classAttributeIDByIdentifier('public_service/has_channel');
                $objectIdList = eZDB::instance()->arrayQuery(
                    "SELECT from_contentobject_id 
                        FROM ezcontentobject_link 
                        WHERE relation_type = $relationType AND contentclassattribute_id = $classAttributeId AND to_contentobject_id = (
                          SELECT DISTINCT contentobject_id
                            FROM ezcontentobject_attribute ezcoa
                            JOIN ezurl_object_link ezuol ON (ezuol.contentobject_attribute_id = ezcoa.id)
                            JOIN ezurl ezu ON (ezuol.url_id = ezu.id)
                            WHERE ezu.url like '%$escapedServiceId%'
                            LIMIT 1
                        )
                        LIMIT 1"
                );
                if (isset($objectIdList[0]['from_contentobject_id'])){
                    $service = eZContentObject::fetch((int)$objectIdList[0]['from_contentobject_id']);
                }
            } elseif (is_numeric($serviceId)) {
                $service = eZContentObject::fetch((int)$serviceId);
            }

            if ($service instanceof eZContentObject && $service->attribute('class_identifier') === 'public_service') {
                $serviceNode = $service->mainNode();
                if ($serviceNode instanceof eZContentObjectTreeNode){
                    $parent = $serviceNode->fetchParent();
                    $parentUrl = $parent->urlAlias();
                    eZURI::transformURI($parentUrl);
                    $path[] = [
                        'text' => $parent->attribute('name'),
                        'url' => $parentUrl,
                    ];
                    $dataMap = $service->dataMap();
                    if (isset($dataMap['type']) && $dataMap['type']->hasContent()){
                        $typeTags = $dataMap['type']->content();
                        if ($typeTags instanceof eZTags){
                            $type = $typeTags->attribute('keywords')[0];
                            $path[] = [
                                'text' => $type,
                                'url' => $parentUrl . '/(view)/' . urlencode($type),
                            ];
                        }
                    }
                    $serviceNodeUrl = $serviceNode->urlAlias();
                    eZURI::transformURI($serviceNodeUrl);
                    $path[] = [
                        'text' => $serviceNode->attribute('name'),
                        'url' => $serviceNodeUrl,
                    ];
                }
            }
        }

        return $path;
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
        $path = array_merge($path, $this->getServicePath());
        $path[] = [
            'text' => ezpI18n::tr('bootstrapitalia/footer', $this->getAppLabel()),
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