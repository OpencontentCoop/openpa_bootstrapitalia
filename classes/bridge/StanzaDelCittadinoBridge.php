<?php

use Opencontent\Opendata\Rest\Client\HttpClient;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;

class StanzaDelCittadinoBridge
{
    private static $instanceByPal;

    /**
     * @var ?string
     */
    private $apiBaseUrl;

    private $accessUrl;

    private $prefix = 'lang';

    private $serviceList;

    private static $mapServiceStatus = [
        0 => 'Servizio non attivo',
        1 => 'Servizio attivo',
        2 => 'Servizio non attivo',
        3 => 'In fase di sviluppo',
        4 => 'Servizio non attivo',
        'fallback' => 'Servizio non attivo',
        'active' => 'Servizio attivo',
    ];

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
    }

    public function getUserLoginUri(): ?string
    {
        return $this->accessUrl;
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
        $contentServiceLists = $client->find("select-fields [data.identifier => metadata.remoteId] classes [public_service] limit 100");

        foreach ($serviceList as $index => $service){
            $identifier = $service['identifier'] ?? null;
//            if (!$identifier && isset($prototypeServiceListBySlug[$service['slug']])){
//                $serviceList[$index]['identifier'] = $prototypeServiceListBySlug[$service['slug']]['identifier'];
//                $serviceList[$index]['_is_prototype_identifier'] = true;
//                $serviceList[$index]['_prototype_id'] = $prototypeServiceListBySlug[$service['slug']]['id'];
//            }
            $serviceList[$index]['_content_prototype_remote_id'] = $contentServiceLists[$serviceList[$index]['identifier']] ?? null;
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
        $client->patchTenant($info['slug'], ['meta' => $data]);
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
            'tenant_type',
            'enable_search_and_catalogue',
            'favicon',
            'logo',
            'theme',
        ];
        foreach ($preserveKeys as $preserveKey) {
            $data[$preserveKey] = $meta[$preserveKey] ?? '';
        }
        unset($data['theme_info']);
        unset($data['topics']); //@todo

        return $data;
    }

    /**
     * @param $identifier
     * @param string $status
     * @param string|null $message
     * @return string
     * @throws ServiceToolsException
     */
    public function updateServiceStatusByIdentifier($identifier, string $status, ?string $message = null, $locale = 'ita-IT')
    {
        $publicServiceObject = null;
        if (!$publicServiceObject instanceof eZContentObject) {
            $publicServiceObject = eZContentObject::fetchByRemoteID($identifier);
        }
        if (!$publicServiceObject instanceof eZContentObject) {
            throw new ServiceToolsException('Local service not found');
        }

        if ($status !== self::$mapServiceStatus['active'] && empty($message)){
            throw new ServiceToolsException('Message is required in inactive service');
        }

        $publicServicePayload = new PayloadBuilder();
        $publicServicePayload->setRemoteId($identifier);
        $publicServicePayload->setLanguages([$locale]);
        $publicServicePayload->setData($locale, 'has_service_status', [$status]);
        $publicServicePayload->setData($locale, 'status_note', $message);
        if ($status !== self::$mapServiceStatus['active']) {
            $publicServicePayload->setData($locale, 'has_channel', []);
        }else {
            $channels = [];
            $accessChannel = eZContentObject::fetchByRemoteID('access-'.$identifier);
            if ($accessChannel instanceof eZContentObject){
                $channels[] = $accessChannel->attribute('id');
            }
            $bookingChannel = eZContentObject::fetchByRemoteID('booking-'.$identifier);
            if ($bookingChannel instanceof eZContentObject){
                $channels[] = $bookingChannel->attribute('id');
            }
            $publicServicePayload->setData($locale, 'has_channel', $channels);
        }

        $repository = new ContentRepository();
        $repository->setEnvironment(new DefaultEnvironmentSettings());

        $repository->update((array)$publicServicePayload);
        $url = eZContentObject::fetchByRemoteID($publicServicePayload->getMetadaData('remoteId'))->mainNode()->urlAlias();
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
    public function updateServiceChannelByIdentifier($identifier, string $type, string $url, ?string $label = null, $locale = 'ita-IT'): string
    {
        $remoteId = $type.'-'.$identifier;
        $channelObject = null;
        if (!$channelObject instanceof eZContentObject) {
            $channelObject = eZContentObject::fetchByRemoteID($remoteId);
        }
        if (!$channelObject instanceof eZContentObject) {
            throw new ServiceToolsException('Local service channel not found');
        }
        if (empty($label)){
            $dataMap = $channelObject->dataMap();
            if (isset($dataMap['channel_url'])){
                $label = $dataMap['channel_url']->attribute('data_text');
            }
        }
        $channelPayload = new PayloadBuilder();
        $channelPayload->setRemoteId($remoteId);
        $channelPayload->setLanguages([$locale]);
        $channelPayload->setData($locale, 'channel_url', $url . '|'. $label);

        $repository = new ContentRepository();
        $repository->setEnvironment(new DefaultEnvironmentSettings());

        $repository->update((array)$channelPayload);
        $url = eZContentObject::fetchByRemoteID($channelPayload->getMetadaData('remoteId'))->mainNode()->urlAlias();
        eZURI::transformURI($url, false, 'full');

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
        $publicServicePayload = $client->getPayload($contentRemoteId ?? $this->getPrototypeServiceContentRemoteId($identifier));

        $publicServicePayload->setRemoteId($identifier);
        $publicServicePayload->setParentNodes([eZContentObject::fetchByRemoteID('all-services')->mainNodeID()]);
        $publicServicePayload->setData(
            null,
            'produces_output',
            $this->getIdListFromRemoteIdList(
                $client,
                $this->getIdList($publicServicePayload, 'produces_output', $locale),
                eZContentObject::fetchByRemoteID('f1c1c3e7404f162fa27d7accbe742f3d')->mainNodeID()
            )
        );
        $publicServicePayload->setData(
            null,
            'has_temporal_coverage',
            $this->getIdListFromRemoteIdList(
                $client,
                $this->getIdList($publicServicePayload, 'has_temporal_coverage', $locale),
                eZContentObject::fetchByRemoteID('f10a85a4ddd1810f10f655785dd84e75')->mainNodeID()
            )
        );
        $publicServicePayload->setData(
            null,
            'has_channel',
            $this->getIdListFromRemoteIdList(
                $client,
                $this->getIdList($publicServicePayload, 'has_channel', $locale),
                eZContentObject::fetchByRemoteID('3bb4f45279e3c4efe2ac84630e53a7b4')->mainNodeID(),
                function (PayloadBuilder $payload) use ($service, $locale, $identifier) {
                    $name = $payload->getData('object', $locale);
                    $channelUrl = $payload->getData('channel_url', $locale);
                    $channelUrlParts = explode('|', $channelUrl);
                    if (stripos($name, 'online') !== false) {
                        $linkLabel = $channelUrlParts[1] ?? 'Accedi al servizio';
                        $payload->setRemoteId('access-'.$identifier);
                        $payload->setData(null, 'has_channel_type', ['Applicazione Web']);
                        $callToAction = isset($service['slug']) ?
                            $this->getApiBaseUri() . '/it/servizi/' . $service['slug'] . '/access' : '#';
                        $payload->setData(null, 'channel_url', $callToAction . '|'. $linkLabel);
                    }
                    if (stripos($name, 'prenota') !== false) {
                        $payload->setRemoteId('booking-'.$identifier);
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
                        $payload->setData(null, 'channel_url', $callToAction. '|'. $linkLabel);
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
                eZContentObject::fetchByRemoteID('all-places')->mainNodeID(),
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
                eZContentObject::fetchByRemoteID('punti_di_contatto')->mainNodeID(),
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
                eZContentObject::fetchByRemoteID('a9d783ef0712ac3e37edb23796990714')->mainNodeID(),
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
        foreach ($topics as $locale => $topicLocalized){
            foreach ($topicLocalized as $topic) {
                $topicRemoteId = $topic['remoteId'];
                if (eZContentObject::fetchByRemoteID($topicRemoteId)) {
                    $topicList[$locale][] = $topicRemoteId;
                }
            }
        }
        foreach ($topicList as $locale => $topics){
            $publicServicePayload->setData($locale, 'topics', $topics);
        }

        $repository = new ContentRepository();
        $repository->setEnvironment(new DefaultEnvironmentSettings());

        $repository->createUpdate((array)$publicServicePayload);
        $url = eZContentObject::fetchByRemoteID($publicServicePayload->getMetadaData('remoteId'))->mainNode()->urlAlias();
        eZURI::transformURI($url, false, 'full');

        return $url;
    }

    /**
     * @param string $identifier
     * @param bool $doUpdate
     * @return string
     * @throws ServiceToolsException
     */
    public function importServiceByIdentifier(string $identifier, bool $doUpdate = false): string
    {
        if (empty($identifier)){
            throw new ServiceToolsException('Missing identifier');
        }
        try {
            $service = StanzaDelCittadinoBridge::factory()->getServiceByIdentifier($identifier);
        }catch (Throwable $e){
            $service = [];
        }
        return $this->cloneServiceFromPrototype($identifier, $doUpdate, $service);
    }

    private function getPrototypeServiceContentRemoteId($identifier)
    {
        $prototypeBaseUrl = self::getServiceContentPrototypeBaseUrl();
        $client = new HttpClient($prototypeBaseUrl);
        $searchResponse = $client->find("classes [public_service] and identifier = '\"{$identifier}\"'");
        if ($searchResponse['totalCount'] > 0){
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
}