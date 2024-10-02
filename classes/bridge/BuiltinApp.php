<?php

use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\ContentSearch;

class BuiltinApp extends OpenPATempletizable
{
    private $appIdentifier;

    private $appLabel;

    private $siteData;

    private static $currentOptions;

    public function __construct(string $appName, string $appLabel)
    {
        $this->appIdentifier = $appName;
        $this->appLabel = $appLabel;

        parent::__construct([
            'src' => $this->getWidgetSrc(),
            'identifier' => $appName,
            'label' => $appLabel,
        ]);
    }

    public static function fetchIdentifierList(): array
    {
        return [
            'booking',
            'support',
            'inefficiency',
            'service-form',
            'payment',
        ];
    }

    public static function fetchList(): array
    {
        $list = [];
        foreach (self::fetchIdentifierList() as $identifier) {
            $list[] = BuiltinApp::instanceByIdentifier($identifier);
        }

        return $list;
    }

    public static function instanceByIdentifier(string $identifier): BuiltinApp
    {
        switch ($identifier) {
            case 'booking':
                $app = new BuiltinApp('booking', 'Book an appointment');
                break;
            case 'support':
                $app = new BuiltinApp('support', 'Request assistance');
                break;
            case 'inefficiency':
                $app = new BuiltinApp('inefficiency', 'Report a inefficiency');
                break;
            case 'service-form':
                $app = new BuiltinApp('service-form', 'Fill out the form');
                break;
            case 'payment':
                $app = new BuiltinApp('payment', 'Make a payment');
                break;
            default:
                throw new InvalidArgumentException("Unknown builtin identifier $identifier");
        }

        return $app;
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

    private static function getStanzaDelCittadinoBridge(): StanzaDelCittadinoBridge
    {
        return StanzaDelCittadinoBridge::instanceByTenantUrl(
            (string)self::getCurrentOptions('TenantUrl'),
            (string)self::getCurrentOptions('TenantLang') ?? 'it'
        );
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
        $baseUrl = self::getStanzaDelCittadinoBridge()->getApiBaseUri();
        $authUrl = self::getStanzaDelCittadinoBridge()->buildApiUrl('/login');
        $window = [
            'OC_BASE_URL' => $baseUrl,
            'OC_PRIVACY_URL' => $privacyUrl,
            'OC_AUTH_URL' => $authUrl,
        ];
        if (OpenPAINI::variable('StanzaDelCittadinoBridge', 'UseLoginBox', 'disabled') !== 'modal') {
            $window['OC_SPID_BUTTON'] = 'true';
        }
        if (self::getCurrentOptions('EnableSeverityField')) {
            $window['OC_SHOW_SEVERITY_FIELD'] = 'true';
        }
        if (self::getCurrentOptions('CategoriesUrl')) {
            $window['OC_CATEGORIES_URL'] = self::getCurrentOptions('CategoriesUrl');
        }
        if (self::getCurrentOptions('BoundingBox')) {
            $window['OC_BB'] = self::getCurrentOptions('BoundingBox');
        }

        return $window;
    }

    protected function getWidgetSrc(): string
    {
        $path = OpenPAINI::variable('StanzaDelCittadinoBridge', 'BuiltInWidgetSource_' . $this->getAppIdentifier(), '');
        if (empty($path)) {
            return '';
        }
        $host = self::getStanzaDelCittadinoBridge()->getHost();
        return str_replace('%host%', $host, $path);
    }

    protected function getWidgetStyle(): string
    {
        $path = OpenPAINI::variable('StanzaDelCittadinoBridge', 'BuiltInWidgetStyle_' . $this->getAppIdentifier(), '');
        if (empty($path)) {
            return '';
        }
        $host = self::getStanzaDelCittadinoBridge()->getHost();
        return str_replace('%host%', $host, $path);
    }

    protected function getAppRootId(): string
    {
        return OpenPAINI::variable('StanzaDelCittadinoBridge', 'RootId_' . $this->getAppIdentifier(), 'root');
    }

    protected function getTemplate(): string
    {
        return OpenPAINI::variable(
            'StanzaDelCittadinoBridge',
            'Template_' . $this->getAppIdentifier(),
            'openpa/built_in_app.tpl'
        );
    }

    protected function isAppEnabled(): bool
    {
        $pagedata = new \OpenPAPageData();
        $contacts = $pagedata->getContactsData();
        $field = OpenPAINI::variable('StanzaDelCittadinoBridge', 'ContactsField_' . $this->getAppIdentifier(), 'empty');

        return !(isset($contacts[$field]) && !empty($contacts[$field])) && self::getCurrentOptions('TenantUrl');
    }

    protected function getServicePath(?eZModule $module)
    {
        $path = [];
        $serviceId = eZHTTPTool::instance()->hasGetVariable('service_id') ?
            eZHTTPTool::instance()->getVariable('service_id') : null;
        if (!$serviceId) {
            if ($module instanceof eZModule && ServiceSync::isUuid($module->ViewParameters[0] ?? '')) {
                $serviceId = $module->ViewParameters[0];
            } else {
                $referrer = eZSys::serverVariable('HTTP_REFERER', true);
                if ($referrer && strpos($referrer, '?service_id=') !== false) {
                    $referrerQuery = parse_url($referrer, PHP_URL_QUERY);
                    parse_str($referrerQuery, $referrerQueryArray);
                    $serviceId = $referrerQueryArray['service_id'] ?? null;
                }
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
                if (isset($objectIdList[0]['from_contentobject_id'])) {
                    $service = eZContentObject::fetch((int)$objectIdList[0]['from_contentobject_id']);
                }
            } elseif (is_numeric($serviceId)) {
                $service = eZContentObject::fetch((int)$serviceId);
            }

            if ($service instanceof eZContentObject && $service->attribute('class_identifier') === 'public_service') {
                $serviceNode = $service->mainNode();
                if ($serviceNode instanceof eZContentObjectTreeNode) {
                    $parent = $serviceNode->fetchParent();
                    $parentUrl = $parent->urlAlias();
                    eZURI::transformURI($parentUrl);
                    $path[] = [
                        'text' => $parent->attribute('name'),
                        'url' => $parentUrl,
                    ];
                    $dataMap = $service->dataMap();
                    if (isset($dataMap['type']) && $dataMap['type']->hasContent()) {
                        $typeTags = $dataMap['type']->content();
                        if ($typeTags instanceof eZTags) {
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

    public function getModuleResult(?eZModule $module): array
    {
        $tpl = eZTemplate::factory();
        $tpl->setVariable('built_in_app_is_enabled', $this->isAppEnabled());
        $tpl->setVariable('built_in_app', $this->getAppIdentifier());
        $tpl->setVariable('built_in_app_root_id', $this->getAppRootId());
        $tpl->setVariable('built_in_app_script', $this->getCustomConfig());
        $tpl->setVariable('built_in_app_src', $this->getWidgetSrc());
        $tpl->setVariable('built_in_app_style', $this->getWidgetStyle());
        $tpl->setVariable('built_in_app_api_base_url', self::getStanzaDelCittadinoBridge()->getApiBaseUri());

        $Result = [];
        $Result['content'] = $tpl->fetch('design:' . $this->getTemplate());
        $path = [];
        $homeUrl = '/';
        eZURI::transformURI($homeUrl);
        $path[] = [
            'text' => OpenPAINI::variable(
                'GeneralSettings',
                'ShowMainContacts',
                'enabled'
            ) == 'enabled' ? 'Home' : OpenPaFunctionCollection::fetchHome()->getName(),
            'url' => $homeUrl,
        ];
        $path = array_merge($path, $this->getServicePath($module));
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
            'show_valuation' => true,
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

    public static function getOptionsDefinition(): array
    {
        $current = self::getCurrentOptions();
        return [
            [
                'identifier' => 'TenantUrl',
                'name' => 'Url del tenant',
                'placeholder' => 'https://servizi.comune.bugliano.pi.it/lang',
                'type' => 'string',
                'current_value' => $current['TenantUrl'],
            ],
            [
                'identifier' => 'TenantLang',
                'name' => 'Codice lingua del tenant',
                'placeholder' => 'it',
                'type' => 'string',
                'current_value' => $current['TenantLang'],
            ],
            [
                'identifier' => 'CategoriesUrl',
                'name' => '[Segnalazione disservizio] url custom delle categorie di segnalazione',
                'placeholder' => 'https://segnalazioni.comune.bugliano.pi.it/api/sensor/inefficiency/categories',
                'type' => 'string',
                'current_value' => $current['CategoriesUrl'],
            ],
            [
                'identifier' => 'EnableSeverityField',
                'name' => '[Segnalazione disservizio] abilita il campo "Valuta l\'importanza del problema"',
                'placeholder' => '',
                'type' => 'boolean',
                'current_value' => (bool)$current['EnableSeverityField'],
            ],
            [
                'identifier' => 'BoundingBox',
                'name' => '[Segnalazione disservizio] bounding box mappa',
                'placeholder' => '8.66272,44.52197,9.09805,44.37590',
                'type' => 'string',
                'current_value' => $current['BoundingBox'],
            ],
        ];
    }

    public static function getCurrentOptions(?string $optionName = null)
    {
        if (self::$currentOptions === null) {
            $siteData = eZSiteData::fetchByName('built_in_env');
            if (!$siteData instanceof eZSiteData) {
                $siteData = eZSiteData::create('built_in_env', json_encode([]));
            }
            $data = json_decode($siteData->attribute('value'), true);
            $locale = eZLocale::currentLocaleCode();
            self::$currentOptions = [
                'TenantUrl' => $data[$locale]['TenantUrl']
                    ?? StanzaDelCittadinoBridge::instanceByPersonalAreaLogin(
                        PersonalAreaLogin::instance()
                    )->getTenantUri(),
                'TenantLang' => $data[$locale]['TenantLang'] ?? 'it',
                'CategoriesUrl' => $data[$locale]['CategoriesUrl'] ?? null,
                'EnableSeverityField' => $data[$locale]['EnableSeverityField'] ?? $data['EnableSeverityField'] ?? false,
                'BoundingBox' => $data[$locale]['BoundingBox'] ?? null,
            ];
        }

        if ($optionName) {
            return self::$currentOptions[$optionName] ?? null;
        }
        return self::$currentOptions;
    }

    public static function setCurrentOptions(array $options = [])
    {
        $newOptions = [];
        $locale = eZLocale::currentLocaleCode();
        foreach (self::getOptionsDefinition() as $definition) {
            if (!empty($options[$definition['identifier']])) {
                $newOptions[$definition['identifier']] = $options[$definition['identifier']];
            }
        }
        $siteData = eZSiteData::fetchByName('built_in_env');
        if (!$siteData instanceof eZSiteData) {
            $siteData = eZSiteData::create('built_in_env', json_encode([]));
        }
        $data = json_decode($siteData->attribute('value'), true);
        $data[$locale] = $newOptions;
        $siteData->setAttribute('value', json_encode($data));
        $siteData->store();
    }

    public static function getWidgetUrlInfo($channelUrlAttribute, $serviceObject): array
    {
        $url = '/';
        $text = '?';
        $builtin = $serviceIdentifier = $serviceId = false;
        if (($channelUrlAttribute instanceof eZContentObjectAttribute
            && $channelUrlAttribute->attribute('data_type_string') === eZURLType::DATA_TYPE_STRING
            && $serviceObject instanceof eZContentObject
            && $serviceObject->attribute('class_identifier') === 'public_service'
            && $channelUrlAttribute->object()->attribute('class_identifier') === 'channel'
        )) {
            $url = $channelUrlAttribute->attribute('content');
            $urlQuery = parse_url($url, PHP_URL_QUERY);
            parse_str($urlQuery, $urlQueryHash);

            $text = $channelUrlAttribute->attribute('data_text');
            if (empty($text)) {
                $text = $url;
            }

            $serviceDataMap = $serviceObject->dataMap();
            $serviceIdentifier = isset($serviceDataMap['identifier']) ? $serviceDataMap['identifier']->content() : null;
            $serviceId = $urlQueryHash['service_id'] ?? '';

            if (in_array($serviceIdentifier, ['inefficiency', 'inefficiencies'])) {
                $builtin = 'inefficiency';
                $url = '/segnala_disservizio';
            } elseif (strpos($url, 'prenota_appuntamento') !== false) {
                $builtin = 'booking';
                if (StanzaDelCittadinoBooking::factory()->isEnabled()
                    && StanzaDelCittadinoBooking::factory()->isServiceRegistered(
                        (int)$serviceObject->attribute('id')
                    )) {
                    $url = '/prenota_appuntamento?service_id=' . $serviceObject->attribute('id');
                } elseif (ServiceSync::isUuid($serviceId)) {
                    $url = '/prenota_appuntamento?service_id=' . $serviceId;
                }
            } elseif (strpos($url, '/pagamento') !== false && ServiceSync::isUuid($serviceId)) {
                $builtin = 'payment';
                $url = '/pagamento?service_id=' . $serviceId;
            }
        }

        eZURI::transformURI($url);
        return [
            'builtin' => $builtin,
            'identifier' => $serviceIdentifier,
            'id' => $serviceId,
            'url' => $url,
            'text' => $text,
        ];
    }
}