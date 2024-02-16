<?php

use Opencontent\Opendata\Api\Exception\NotFoundException;
use Opencontent\Opendata\Rest\Client\HttpClient;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;

class StanzaDelCittadinoBridge
{
    use SiteDataStorageTrait;

    const RUNTIME_STATUS_CACHE_KEY = 'sdc_runtime_check_status';

    const CHANNELS_REMOTE_ID = '3bb4f45279e3c4efe2ac84630e53a7b4';

    const SERVICES_REMOTE_ID = 'all-services';

    const OUTPUTS_REMOTE_ID = 'f1c1c3e7404f162fa27d7accbe742f3d';

    const SERVICE_HOURS_REMOTE_ID = 'f10a85a4ddd1810f10f655785dd84e75';

    const PLACES_REMOTE_ID = 'all-places';

    const CONTACTS_REMOTE_ID = 'punti_di_contatto';

    const OFFICES_REMOTE_ID = 'a9d783ef0712ac3e37edb23796990714';

    private static $instance;

    /**
     * @var ?string
     */
    private $apiBaseUrl;

    private $accessUrl;

    private $prefix = 'lang';

    private $serviceList;

    private $enableRuntimeServiceStatusCheck;

    public static $mapServiceStatus = [
        0 => 'Servizio non attivo',
        1 => 'Servizio attivo',
        2 => 'Servizio non attivo',
        3 => 'In fase di sviluppo',
        4 => 'Servizio non attivo',
        'fallback' => 'Servizio non attivo',
        'active' => 'Servizio attivo',
    ];

    private $apiUrlDiscovered;

    private function __construct()
    {
    }

    public static function factory(): StanzaDelCittadinoBridge
    {
        if (self::$instance === null) {
            self::$instance = static::instanceByPersonalAreaLogin(PersonalAreaLogin::instance());
        }

        return self::$instance;
    }

    public function getEnableRuntimeServiceStatusCheck()
    {
        if ($this->enableRuntimeServiceStatusCheck === null) {
            $this->enableRuntimeServiceStatusCheck = $this->getStorage(self::RUNTIME_STATUS_CACHE_KEY);
        }
        return $this->enableRuntimeServiceStatusCheck;
    }

    public function setEnableRuntimeServiceStatusCheck($enableRuntimeServiceStatusCheck)
    {
        $this->enableRuntimeServiceStatusCheck = $enableRuntimeServiceStatusCheck;
        $this->setStorage(self::RUNTIME_STATUS_CACHE_KEY, (int)$enableRuntimeServiceStatusCheck);
    }

    public static function instanceByPersonalAreaLogin(PersonalAreaLogin $pal): StanzaDelCittadinoBridge
    {
        $instance = new StanzaDelCittadinoBridge();
        if ($pal->getUri()) {
            $instance->setUserLoginUri($pal->getUri());
        }

        return $instance;
    }

    /**
     * @return StanzaDelCittadinoClient
     * @throws Exception
     */
    public function instanceNewClient(): StanzaDelCittadinoClient
    {
        $url = $this->getApiBaseUri();
        if (!$url) {
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
        if ($this->apiBaseUrl === null && OpenPAINI::variable(
                'StanzaDelCittadinoBridge',
                'AutoDiscover',
                'disabled'
            ) === 'enabled') {
            $this->discoverApiBaseUrl();
        }
        return $this->apiBaseUrl;
    }

    public function getHost(): ?string
    {
        $url = $this->getApiBaseUri();
        return parse_url($url, PHP_URL_HOST);
    }

    public function buildApiUrl(string $path): ?string
    {
        $base = $this->getApiBaseUri();
        return $base ? $base . $path : null;
    }

    public function discoverApiBaseUrl(): void
    {
        if (!$this->apiUrlDiscovered) {
            $userLoginUri = $this->getUserLoginUri();
            $url = parse_url($userLoginUri, PHP_URL_HOST);
            if (strpos($userLoginUri, $this->prefix) !== false) {
                $this->apiBaseUrl = 'https://' . $url . '/' . $this->prefix;
            } else {
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
                            } catch (Exception $e) {
                                eZDebug::writeError($e->getMessage(), __METHOD__);
                                $siteData = eZSiteData::create($cacheKey, '');
                                $siteData->store();
                            }
                        }
                    }
                }
                if ($siteData instanceof eZSiteData) {
                    $this->apiBaseUrl = $siteData->attribute('value');
                }
            }

            eZDebug::writeDebug('Get api base url: ' . $this->apiBaseUrl, __METHOD__);
            $this->apiUrlDiscovered = true;
        }
    }

    public function getUserLoginUri(): ?string
    {
        return $this->accessUrl;
    }

    public function getTenantUri(): ?string
    {
        return rtrim(
            str_replace('/it/user', '', $this->accessUrl),
            '/'
        );
    }

    public function setUserLoginUri(?string $accessUrl): void
    {
        eZDebug::writeDebug('Set access url: ' . $accessUrl, __METHOD__);
        $this->accessUrl = $accessUrl;
    }

    public function getOperatorLoginUri(): ?string
    {
        $userAccessUrl = $this->getUserLoginUri();
        return $userAccessUrl ? str_replace('/user', '/operatori', $userAccessUrl) : null;
    }

    public function getServiceList()
    {
        if ($this->serviceList === null) {
            $this->serviceList = (array)$this->instanceNewClient()->getServiceList();
        }
        return $this->serviceList;
    }

    public function getServiceListMergedWithPrototypes()
    {
        $serviceList = $this->getServiceList();

//        $prototypeServiceList = (new StanzaDelCittadinoClient(self::getServiceOperationPrototypeBaseUrl()))->getServiceList();
//        $prototypeServiceListBySlug = [];
//        foreach ($prototypeServiceList as $prototypeService){
//            $prototypeServiceListBySlug[$prototypeService['slug']] = $prototypeService;
//        }
        $prototypeBaseUrl = self::getServiceContentPrototypeBaseUrl();
        $client = new HttpClient($prototypeBaseUrl);
        $contentServiceLists = $client->find(
            "select-fields [data.identifier => metadata.remoteId] classes [public_service] limit 100"
        );

        foreach ($serviceList as $index => $service) {
//            $identifier = $service['identifier'] ?? null;
//            if (!$identifier && isset($prototypeServiceListBySlug[$service['slug']])){
//                $serviceList[$index]['identifier'] = $prototypeServiceListBySlug[$service['slug']]['identifier'];
//                $serviceList[$index]['_is_prototype_identifier'] = true;
//                $serviceList[$index]['_prototype_id'] = $prototypeServiceListBySlug[$service['slug']]['id'];
//            }
            $serviceList[$index]['_content_prototype_remote_id'] = $contentServiceLists[$service['identifier']] ?? null;
        }

        return $serviceList;
    }

    public static function getServiceContentPrototypeBaseUrl()
    {
        return OpenPAINI::variable(
            'StanzaDelCittadinoBridge',
            'ServiceContentPrototypeBaseUrl',
            'https://www.comune.bugliano.pi.it'
        );
    }

    public static function getServiceOperationPrototypeBaseUrl()
    {
        return OpenPAINI::variable(
            'StanzaDelCittadinoBridge',
            'ServiceOperationPrototypeBaseUrl',
            'https://servizi.comune.bugliano.pi.it/lang'
        );
    }

    public function getServiceByIdentifier($identifier)
    {
        return $this->instanceNewClient()->getServiceByIdentifier($identifier);
    }

    public function getTenantInfo()
    {
        $client = $this->instanceNewClient();
        return $client->getTenantInfo();
    }

    public function setTenantByUrl(string $url): array
    {
        $loginUrl = rtrim($url, '/') . '/it/user/';
        $pal = PersonalAreaLogin::instance();
        $info = $pal->resetUriTo($loginUrl, false);
        self::$instance = static::instanceByPersonalAreaLogin($pal);

        return $info;
    }

    /**
     * @return void
     * @throws Exception
     */
    public function updateSiteInfo($user, $password): void
    {
        $client = $this->instanceNewClient();
        $client->setBearerToken($client->getBearerToken($user, $password));
        $info = $client->getTenantInfo();
        if (!isset($info['slug'])) {
            throw new Exception(
                "L'istanza collegata non espone lo slug nell'api tenant/info: non è possibile eseguire l'aggiornamento"
            );
        }

        $data = $this->getSiteInfoToUpdate();
        $client->patchTenant($info['slug'], $data);
    }

    public function getSiteInfoToUpdate()
    {
        StanzaDelCittadinoClient::$connectionTimeout = 60;
        StanzaDelCittadinoClient::$processTimeout = 60;
        $client = $this->instanceNewClient();
        $info = $client->getTenantInfo();
        $meta = isset($info['meta'][0]) ? json_decode($info['meta'][0], true) : null;
        if (!$meta) {
            throw new Exception(
                "L'istanza collegata non espone correttamente il campo meta: non è possibile eseguire l'aggiornamento"
            );
        }
        $data = SiteInfo::getCurrent();

        $preserveKeys = [
//            'tenant_type',
//            'enable_search_and_catalogue',
            'favicon',
            'logo',
            'theme',
        ];
        foreach ($preserveKeys as $preserveKey) {
            $data[$preserveKey] = $meta[$preserveKey] ?? '';
        }
        unset($data['theme_info']);
        unset($data['topics']); //@todo

        return [
            'site_url' => 'https://' . eZSiteAccess::getIni(
                    OpenPABase::getFrontendSiteaccessName()
                )->variable('SiteSettings', 'SiteURL'),
            'meta' => $data,
        ];
    }

    /**
     * @param $identifier
     * @param string $status
     * @param string|null $message
     * @return string
     * @throws ServiceToolsException
     */
    public function updateServiceStatusByIdentifier(
        $identifier,
        string $status,
        ?string $message = null,
        $locale = 'ita-IT'
    ) {
        $publicServiceObject = null;

        $parentIdentifier = $this->getParentServiceIdentifier($identifier);
        if ($parentIdentifier) {
            $publicServiceObject = eZContentObject::fetchByRemoteID($parentIdentifier);
            if (!$publicServiceObject instanceof eZContentObject) {
                throw new ServiceToolsException('Local parent service not found');
            }
            $url = $publicServiceObject->mainNode()->urlAlias();
            eZURI::transformURI($url, false, 'full');
            return $url;
        }

        if (!$publicServiceObject instanceof eZContentObject) {
            $publicServiceObject = eZContentObject::fetchByRemoteID($identifier);
        }
        if (!$publicServiceObject instanceof eZContentObject) {
            throw new ServiceToolsException('Local service not found');
        }

        if ($status !== self::$mapServiceStatus['active'] && empty($message)) {
            throw new ServiceToolsException('Message is required in inactive service');
        }

        $publicServiceObjectDataMap = $publicServiceObject->dataMap();

        $publicServicePayload = new PayloadBuilder();
        $publicServicePayload->setRemoteId($identifier);
        $publicServicePayload->setLanguages([$locale]);
        $publicServicePayload->setData($locale, 'has_service_status', [$status]);
        $publicServicePayload->setData($locale, 'status_note', $message);

        if (isset($publicServiceObjectDataMap['has_channel'])
            && !$publicServiceObjectDataMap['has_channel']->hasContent()) {
            $channels = [];
            $accessChannel = eZContentObject::fetchByRemoteID('access-' . $identifier);
            if ($accessChannel instanceof eZContentObject) {
                $channels[] = $accessChannel->attribute('id');
            }
            $bookingChannel = eZContentObject::fetchByRemoteID('booking-' . $identifier);
            if ($bookingChannel instanceof eZContentObject) {
                $channels[] = $bookingChannel->attribute('id');
            }
            $publicServicePayload->setData($locale, 'has_channel', $channels);
        }

        $repository = new ContentRepository();
        $repository->setEnvironment(new DefaultEnvironmentSettings());

        $repository->update((array)$publicServicePayload);
        $url = eZContentObject::fetchByRemoteID($publicServicePayload->getMetadaData('remoteId'))->mainNode()->urlAlias(
        );
        eZURI::transformURI($url, false, 'full');


        return $url;
    }

    /**
     * @param $identifier
     * @param string $status
     * @param string|null $message
     * @return string
     * @throws ServiceToolsException
     */
    public function updateServiceChannelByIdentifier(
        $identifier,
        string $type,
        string $url,
        ?string $label = null,
        $locale = 'ita-IT'
    ): string {
        $remoteId = $type . '-' . $identifier;
        $channelObject = null;
        if (!$channelObject instanceof eZContentObject) {
            $channelObject = eZContentObject::fetchByRemoteID($remoteId);
        }
        if (!$channelObject instanceof eZContentObject) {
            $parentIdentifier = $this->getParentServiceIdentifier($identifier);
            if ($parentIdentifier) {
                return "Warning: $type channel of $identifier (child of $parentIdentifier) service not found";
            }
//            throw new ServiceToolsException('Local service channel not found');
        }
        if (empty($label) && $channelObject instanceof eZContentObject) {
            $dataMap = $channelObject->dataMap();
            if (isset($dataMap['channel_url'])) {
                $label = $dataMap['channel_url']->attribute('data_text');
            }
        }

        if (empty($label)) {
            $label = $type === 'access' ? 'Accedi al servizio' : 'Prenota appuntamento';
        }

        $channelPayload = new PayloadBuilder();
        $channelPayload->setRemoteId($remoteId);
        $channelPayload->setLanguages([$locale]);
        $channelPayload->setClassIdentifier('channel');
        $channelPayload->setData($locale, 'channel_url', $url . '|' . $label);

        $repository = new ContentRepository();
        $repository->setEnvironment(new DefaultEnvironmentSettings());

        if (!$channelObject instanceof eZContentObject) {
            $channelPayload->setData($locale, 'object', $label);
            $channelPayload->setData($locale, 'abstract', $label);
            $channelPayload->setParentNodes(
                [eZContentObject::fetchByRemoteID(self::CHANNELS_REMOTE_ID)->mainNodeID()]
            );
            $channelPayload->setData(
                $locale,
                'has_channel_type',
                $type === 'access' ? ['Applicazione Web'] : ['Sportello Pubblica Amministrazione']
            );
            $channel = $repository->create((array)$channelPayload);
            $channelId = $channel['content']['metadata']['id'];
        } else {
            $repository->update((array)$channelPayload);
            $channelId = $channelObject->attribute('id');
        }

        $url = eZContentObject::fetchByRemoteID($channelPayload->getMetadaData('remoteId'))->mainNode()->urlAlias();
        eZURI::transformURI($url, false, 'full');

        $publicServiceObject = eZContentObject::fetchByRemoteID($identifier);
        if ($publicServiceObject instanceof eZContentObject) {
            $publicServiceObjectDataMap = $publicServiceObject->dataMap();
            if (isset($publicServiceObjectDataMap['has_channel'])) {
                $currentItems = explode('-', $publicServiceObjectDataMap['has_channel']->toString());
                if (!in_array($channelId, $currentItems)) {
                    $currentItems[] = $channelId;
                    $publicServiceObjectDataMap['has_channel']->fromString(
                        implode('-', array_unique($currentItems))
                    );
                    $publicServiceObjectDataMap['has_channel']->store();
                }
            }
        }

        return $url;
    }

    /**
     * @param string $identifier
     * @param bool $doUpdate
     * @param array $service
     * @return string
     * @throws ServiceToolsException
     */
    private function cloneServiceFromPrototype(string $identifier, bool $doUpdate = false, array $service = []): string
    {
        $publicServiceObject = eZContentObject::fetchByRemoteID($identifier);
        if ($publicServiceObject instanceof eZContentObject && !$doUpdate) {
            //throw new ServiceToolsException('Local service already exists');
            $url = $publicServiceObject->mainNode()->urlAlias();
            eZURI::transformURI($url, false, 'full');

            return $url;
        }

        $prototypeBaseUrl = self::getServiceContentPrototypeBaseUrl();
        $locale = 'ita-IT';
        $client = new HttpClient($prototypeBaseUrl);
        $publicServicePayload = $client->getPayload(
            $contentRemoteId ?? $this->getPrototypeServiceContent($identifier)
        );

        $publicServicePayload->setRemoteId($identifier);
        $publicServicePayload->setParentNodes(
            [eZContentObject::fetchByRemoteID(self::SERVICES_REMOTE_ID)->mainNodeID()]
        );
        $publicServicePayload->unSetData('image');
        $publicServicePayload->setData(
            null,
            'produces_output',
            $this->getIdListFromRemoteIdList(
                $client,
                $this->getIdList($publicServicePayload, 'produces_output', $locale),
                eZContentObject::fetchByRemoteID(self::OUTPUTS_REMOTE_ID)->mainNodeID()
            )
        );
        $publicServicePayload->setData(
            null,
            'has_temporal_coverage',
            $this->getIdListFromRemoteIdList(
                $client,
                $this->getIdList($publicServicePayload, 'has_temporal_coverage', $locale),
                eZContentObject::fetchByRemoteID(self::SERVICE_HOURS_REMOTE_ID)->mainNodeID()
            )
        );
        $publicServicePayload->setData(
            null,
            'has_channel',
            $this->getIdListFromRemoteIdList(
                $client,
                $this->getIdList($publicServicePayload, 'has_channel', $locale),
                eZContentObject::fetchByRemoteID(self::CHANNELS_REMOTE_ID)->mainNodeID(),
                function (PayloadBuilder $payload) use ($service, $locale, $identifier) {
                    $channelUrl = $payload->getData('channel_url', $locale);
                    $channelUrlParts = explode('|', $channelUrl);
                    $name = $channelUrlParts[1] ?? $payload->getData('object', $locale);
                    $link = $channelUrlParts[0] ?? '#';
                    if (stripos($name, 'online') !== false) {
                        $linkLabel = $channelUrlParts[1] ?? 'Accedi al servizio';
                        $payload->setRemoteId('access-' . $identifier);
                        $payload->setData(null, 'has_channel_type', ['Applicazione Web']);
                        $callToAction = isset($service['slug']) ?
                            $this->getApiBaseUri() . '/it/servizi/' . $service['slug'] . '/access' : $link;
                        $payload->setData(null, 'channel_url', $callToAction . '|' . $linkLabel);
                    }
                    if (stripos($name, 'prenota') !== false) {
                        $payload->setRemoteId('booking-' . $identifier);
                        $linkLabel = $channelUrlParts[1] ?? 'Prenota appuntamento';
                        $callToAction = '#';
                        if (!empty($service)) {
                            $callToAction = $service['booking_call_to_action'];
                            if (empty($callToAction)) {
                                $callToAction = '/prenota_appuntamento?service_id=' . $service['id'];
                            } else {
                                $callToActionParts = parse_url($callToAction);
                                $callToAction = $callToActionParts['path'] . '?' . $callToActionParts['query'];
                                eZURI::transformURI($callToAction, false, 'full');
                            }
                        }
                        $payload->setData(null, 'has_channel_type', ['Sportello Pubblica Amministrazione']);
                        $payload->setData(null, 'channel_url', $callToAction . '|' . $linkLabel);
                    }
                    return $payload;
                }
            )
        );

        $publicServicePayload->setData(
            null,
            'is_physically_available_at',
            $this->getIdListFromRemoteNameList(
                $client,
                $this->getNameList($publicServicePayload, 'is_physically_available_at', $locale),
                eZContentObject::fetchByRemoteID(self::PLACES_REMOTE_ID)->mainNodeID(),
                ['place'],
                '4c246236f96f06a1a73a8ca05ebf71e7'
            )
        );
        $publicServicePayload->setData(
            null,
            'has_online_contact_point',
            $this->getIdListFromRemoteNameList(
                $client,
                $this->getNameList($publicServicePayload, 'has_online_contact_point', $locale),
                eZContentObject::fetchByRemoteID(self::CONTACTS_REMOTE_ID)->mainNodeID(),
                ['online_contact_point'],
                '68aa77e31ed4a7483c13abb96454c24e'
            )
        );
        $publicServicePayload->setData(
            null,
            'holds_role_in_time',
            $this->getIdListFromRemoteNameList(
                $client,
                $this->getNameList($publicServicePayload, 'holds_role_in_time', $locale),
                eZContentObject::fetchByRemoteID(self::OFFICES_REMOTE_ID)->mainNodeID(),
                ['organization'],
                '7527419b2d5fde514875e35da20bfe1e'
            )
        );
        $pagedata = new \OpenPAPageData();
        $contacts = $pagedata->getContactsData();
        $spatialCoverage = eZINI::instance()->variable('SiteSettings', 'SiteName');
        if (isset($contacts['comune']) && !empty($contacts['comune'])) {
            $spatialCoverage = $contacts['comune'];
        }
        $publicServicePayload->setData(
            null,
            'has_spatial_coverage',
            $spatialCoverage
        );

        $publicServicePayload->setData(
            null,
            'has_service_status',
            [self::$mapServiceStatus[$service['status']] ?? self::$mapServiceStatus['fallback']]
        );

        $topicList = [];
        $topics = $publicServicePayload->getData('topics');
        foreach ($topics as $locale => $topicLocalized) {
            foreach ($topicLocalized as $topic) {
                $topicRemoteId = $topic['remoteId'];
                if (eZContentObject::fetchByRemoteID($topicRemoteId)) {
                    $topicList[$locale][] = $topicRemoteId;
                }
            }
        }

        foreach ($topicList as $locale => $topics) {
            $publicServicePayload->setData($locale, 'topics', $topics);
        }

        $repository = new ContentRepository();
        $repository->setEnvironment(new DefaultEnvironmentSettings());

        $repository->createUpdate((array)$publicServicePayload);
        $url = eZContentObject::fetchByRemoteID($publicServicePayload->getMetadaData('remoteId'))
            ->mainNode()->urlAlias();
        eZURI::transformURI($url, false, 'full');

        return $url;
    }

    public function hasServiceByIdentifier(string $identifier): string
    {
        if (empty($identifier)) {
            throw new ServiceToolsException('Missing identifier');
        }

        $parentIdentifier = $this->getParentServiceIdentifier($identifier);
        if ($parentIdentifier) {
            $identifier = $parentIdentifier;
        }
        $publicServiceObject = eZContentObject::fetchByRemoteID($identifier);
        if ($publicServiceObject instanceof eZContentObject) {
            $url = $publicServiceObject->mainNode()->urlAlias();
            eZURI::transformURI($url, false, 'full');
            return $url;
        }

        throw new NotFoundException('service', $identifier);
    }

    /**
     * @param string $identifier
     * @param bool $doUpdate
     * @return string
     * @throws ServiceToolsException
     */
    public function importServiceByIdentifier(string $identifier, bool $doUpdate = false): string
    {
        if (empty($identifier)) {
            throw new ServiceToolsException('Missing identifier');
        }
        try {
            $service = StanzaDelCittadinoBridge::factory()->getServiceByIdentifier($identifier);
        } catch (Throwable $e) {
            $service = [];
        }
        try {
            $response = $this->cloneServiceFromPrototype($identifier, $doUpdate, $service);
            if (isset($service['status']) && $service['status'] != 1) {
                $status = self::$mapServiceStatus[$service['status']] ?? self::$mapServiceStatus['fallback'];
                $response = $this->updateServiceStatusByIdentifier($identifier, $status, $status);
            }
        } catch (ServiceToolsException $e) {
            if ($parentIdentifier = $this->getParentServiceIdentifier($identifier)) {
                $response = $this->importPseudoServiceByIdentifier(
                    $identifier,
                    $parentIdentifier
                );
            } else {
                throw $e;
            }
        }
        return $response;
    }

    private function getParentServiceIdentifier($identifier)
    {
        if (strpos($identifier, 'bis') !== false) {
            return str_replace('bis', '', $identifier);
        }

        return null;
    }

    private function importPseudoServiceByIdentifier($identifier, $parentIdentifier)
    {
        $publicServiceObject = eZContentObject::fetchByRemoteID($parentIdentifier);
        if (!$publicServiceObject instanceof eZContentObject) {
            throw new ServiceToolsException(
                "Service $parentIdentifier not yet installed as parent service of $identifier"
            );
        }

        $url = $publicServiceObject->mainNode()->urlAlias();
        eZURI::transformURI($url, false, 'full');

        return $url;
    }

    private function getPrototypeServiceContent($identifier)
    {
        $prototypeBaseUrl = self::getServiceContentPrototypeBaseUrl();
        $client = new HttpClient($prototypeBaseUrl);
        $searchResponse = $client->find("classes [public_service] and identifier = '\"{$identifier}\"'");
        if ($searchResponse['totalCount'] > 0) {
            return $searchResponse['searchHits'][0];
        }

        throw new ServiceToolsException("Prototype service content not found");
    }

    private function getIdList(PayloadBuilder $payload, $identifier, $language): array
    {
        return array_column((array)$payload->getData($identifier, $language), 'remoteId');
    }

    private function getNameList(PayloadBuilder $payload, $identifier, $language): array
    {
        $data = array_column((array)$payload->getData($identifier, $language), 'name');
        $names = [];
        foreach ($data as $item) {
            $names[] = $item[$language];
        }

        return $names;
    }

    private function getIdListFromRemoteNameList(
        HttpClient $client,
        array $nameList,
        int $containerNodeId,
        array $classIdentifiers,
        $fallbackRemoteId
    ): array {
        $idList = [];
        foreach ($nameList as $name) {
            /** @var eZContentObjectTreeNode[] $nodeList */
            $nodeList = eZContentObjectTreeNode::subTreeByNodeID([
                'ClassFilterType' => 'include',
                'ClassFilterArray' => $classIdentifiers,
                'ObjectNameFilter' => $name,
            ], $containerNodeId);
            if (count($nodeList) > 0) {
                $idList[] = $nodeList[0]->attribute('contentobject_id');
            } else {
                $default = eZContentObject::fetchByRemoteID($fallbackRemoteId);
                if ($default instanceof eZContentObject) {
                    $idList[] = $default->attribute('id');
                } else {
                    $nodeList = eZContentObjectTreeNode::subTreeByNodeID([
                        'ClassFilterType' => 'include',
                        'ClassFilterArray' => $classIdentifiers,
                        'Limit' => 1,
                    ], $containerNodeId);
                    if (isset($nodeList[0]) && $nodeList[0] instanceof eZContentObjectTreeNode) {
                        $idList[] = $nodeList[0]->attribute('contentobject_id');
                    }
                }
            }
        }

        return $idList;
    }

    private function getIdListFromRemoteIdList(
        HttpClient $client,
        array $remoteIdList,
        int $containerNodeId,
        $payloadModifier = null
    ): array {
        $repository = new ContentRepository();
        $repository->setEnvironment(new DefaultEnvironmentSettings());
        $idList = [];
        foreach ($remoteIdList as $remoteId) {
            $payload = $client->getPayload($remoteId);
            $payload->setParentNodes([$containerNodeId]);
            if (is_callable($payloadModifier)) {
                $payload = call_user_func($payloadModifier, $payload);
            }
            $creationResult = $repository->createUpdate((array)$payload);
            $idList[] = $creationResult['content']['metadata']['remoteId'];
        }
        return $idList;
    }

    public function checkServiceSync(eZContentObjectTreeNode $service): array
    {
        $errors = $info = [];
        $info['name'] = $service->attribute('name');

        $object = $service->object();
        $dataMap = $object->dataMap();

        $serviceIdentifier = '';
        if (isset($dataMap['identifier']) && $dataMap['identifier']->hasContent()) {
            $serviceIdentifier = trim($dataMap['identifier']->toString());
        }
        $info['identifier'] = $serviceIdentifier;
        if ($object->remoteID() != $serviceIdentifier) {
            $errors['OBJECT_REMOTE_ID_MISMATCH'] = [
                'topic' => 'strict',
                'message' => 'Object remote_id does not match with attribute identifier: ' . $object->remoteID() . ' ' . $serviceIdentifier,
            ];
        }

        $channelsIdList = isset($dataMap['has_channel']) ? explode('-', $dataMap['has_channel']->toString()) : [];
        $channels = OpenPABase::fetchObjects($channelsIdList);
        if (count($channels) === 0) {
            $errors['EMPTY_CHANNELS'] = [
                'topic' => 'strict',
                'message' => 'HasChannel relation is empty',
            ];
        }

        $accessUrlList = $bookingUrlList = [];
        $channelUrls = [];
        foreach ($channels as $channel) {
            $channelRemoteId = $channel->remoteID();
            $channelDataMap = $channel->dataMap();
            $url = isset($channelDataMap['channel_url']) ? $channelDataMap['channel_url']->content() : '';
            $channelUrls[] = $url;
            if (strpos($channelRemoteId, 'access-') !== false) {
                $accessUrlList[] = $url;
                $info['access_url'][] = $url;
            } elseif (strpos($channelRemoteId, 'booking-') !== false) {
                $bookingUrlList[] = $url;
                $info['booking_url'][] = $url;
            } else {
                $info['channel_urls'][] = $url;
            }
        }

        StanzaDelCittadinoClient::$connectionTimeout = 10;
        StanzaDelCittadinoClient::$processTimeout = 10;
        $remoteService = false;
        try {
            $remoteService = $this->getServiceByIdentifier($serviceIdentifier);
        } catch (Throwable $e) {
            $errors['REMOTE_BY_IDENTIFIER_NOT_FOUND'] = [
                'topic' => 'strict',
                'message' => 'Remote service by identifier not found ' . $e->getMessage(),
            ];
        }

        if (!$remoteService) {
            try {
                foreach ($channelUrls as $url) {
                    if (strpos($url, 'prenota_appuntamento?service_id=') != false) {
                        $parts = explode('prenota_appuntamento?service_id=', $url);
                        if (isset($parts[1]) && preg_match(
                                '/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/',
                                $parts[1]
                            )) {
                            $remoteService = $this->instanceNewClient()->getService($parts[1]);
                        }
                    }
                }
            } catch (Throwable $e) {
                $errors['REMOTE_BY_ID_NOT_FOUND'] = [
                    'topic' => 'strict',
                    'message' => 'Remote service by booking url service_id not found ' . $e->getMessage(),
                ];
            }
        }
        if ($remoteService) {
            $remoteServiceUUID = $remoteService['id'];
            $info['digital_service_id'] = $remoteServiceUUID;

            if (!empty($remoteService['identifier']) && $serviceIdentifier != $remoteService['identifier']) {
                $errors['IDENTIFIER_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Service identifier does not match with remote service identifier',
                    'locale' => $serviceIdentifier,
                    'remote' => $remoteService['identifier'],
                ];
            }

            if ($service->remoteID() != $remoteServiceUUID) {
                $errors['NODE_REMOTE_ID_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Node remote_id does not match with remote service UUID',
                    'locale' => $service->remoteID(),
                    'remote' => $remoteServiceUUID,
                ];
            }

            if ($remoteService['name'] != $service->attribute('name')) {
                $errors['NAME_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Name does not match',
                    'locale' => $service->attribute('name'),
                    'remote' => $remoteService['name'],
                ];
            }

            $urlAlias = $service->attribute('url_alias');
            $availableUrls = [
                '/' . $urlAlias,
                '/openpa/object/' . $object->attribute('id'),
                '/openpa/object/' . $object->remoteID(),
            ];
            //external_card_url
            $externalCardPath = parse_url($remoteService['external_card_url'], PHP_URL_PATH);
            if (!in_array($externalCardPath, $availableUrls)) {
                $errors['EXTERNAL_CARD_URL_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'External card url does not match',
                    'locale' => implode(' or ', $availableUrls),
                    'remote' => $externalCardPath ?? $remoteService['external_card_url'],
                ];
            }

            //access_url
            if (!in_array($remoteService['access_url'], $accessUrlList)) {
                $errors['ACCESS_URL_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Access url does not match',
                    'locale' => implode(', ', $accessUrlList),
                    'remote' => $remoteService['access_url'],
                ];
            }

            //booking_call_to_action
            if (!in_array($remoteService['booking_call_to_action'], $bookingUrlList)) {
                $errors['BOOKING_URL_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Booking url does not match',
                    'locale' => implode(', ', $bookingUrlList),
                    'remote' => $remoteService['booking_call_to_action'],
                ];
            }

            $inSync = true;
            $remoteStatus = $remoteService['status'];
            $isActivePublicService = OpenPABootstrapItaliaOperators::isActivePublicService($object);
            $remoteIsActive = (isset(StanzaDelCittadinoBridge::$mapServiceStatus[$remoteStatus])
                && StanzaDelCittadinoBridge::$mapServiceStatus[$remoteStatus] == StanzaDelCittadinoBridge::$mapServiceStatus['active']);
            if (!$remoteIsActive && $isActivePublicService) {
                $inSync = false;
            }
            if (!$inSync) {
                $statusError[] = [
                    'topic' => 'sync',
                    'message' => 'Status does not match',
                    'locale' => '?',
                    'remote' => $remoteService['status'],
                ];
                if (isset($dataMap['has_service_status'])) {
                    $status = $dataMap['has_service_status']->content();
                    $statusError['locale'] = $status instanceof eZTags ? $status->keywordString(
                        ' '
                    ) : $dataMap['has_service_status']->toString();
                }
                $errors['STATUS_MISMATCH'] = $statusError;
            }

            $localMaxResponseTime = isset($dataMap['has_processing_time']) ?
                (int)$dataMap['has_processing_time']->toString() : 0;
            $remoteMaxResponseTime = (int)$remoteService['max_response_time'];
            if ($localMaxResponseTime != $remoteMaxResponseTime) {
                $errors['MAX_RESPONSE_TIME_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Max response time does not match',
                    'locale' => $localMaxResponseTime,
                    'remote' => $remoteMaxResponseTime,
                ];
            }

            $messages = $remoteService['feedback_messages'];
            foreach ($messages as $messageId => $values) {
                $text = $values['message'] ?? false;
                $isActive = $values['is_active'] ?? false;
                if ($isActive && strpos($text, 'Entro 30 giorni') !== false && $localMaxResponseTime != 30) {
                    $errors['WRONG_NOTIFICATION:' . strtoupper($messageId)] = [
                        'topic' => 'strict',
                        'message' => "Notification text for status change \"$messageId\" contains wrong max response time",
                    ];
                }
            }

            $topicId = $remoteService['topics_id'];
            $remoteCategory = $this->instanceNewClient()->getCategory($topicId);
            $categoryName = $remoteCategory['name'];
            $type = isset($dataMap['type']) ? $dataMap['type']->content()->keywordString(' ') : '?';
            if ($categoryName !== $type) {
                $errors['CATEGORY_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Service category does not match',
                    'locale' => $type,
                    'remote' => $categoryName,
                ];
            }
        }

        return [
            'info' => $info,
            'errors' => $errors,
        ];
    }
}