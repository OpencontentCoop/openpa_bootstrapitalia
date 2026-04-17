<?php

use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\Rest\Client\HttpClient;

class OpenAgendaBridge
{
    use SiteDataStorageTrait;

    const URL_CACHE_KEY = 'openagenda_url';

    const IDENTIFIER_CACHE_KEY = 'openagenda_identifier';

    const NAME_CACHE_KEY = 'openagenda_name';

    const VERSION_CACHE_KEY = 'openagenda_version';

    const MAIN_CALENDAR_CACHE_KEY = 'openagenda_main';

    const TOPIC_CACHE_KEY = 'openagenda_topic';

    const PLACE_CACHE_KEY = 'openagenda_place';

    const ORGANIZATION_CACHE_KEY = 'openagenda_organization';

    const PUSH_PLACE_CACHE_KEY = 'openagenda_push_place';

    private static $instance;

    private $agendaUrl;

    private $agendaClient;

    private $enableMainCalendar;

    private $enableTopicCalendar;

    private $enablePlaceCalendar;

    private $enableOrganization;

    private $enablePushPlace;

    private function __construct()
    {
        $this->agendaUrl = OpenPAINI::variable(
            'OpenAgendaBridge',
            'OpenAgendaUrl',
            null
        );
        if ($this->isEnabled()){
            if (self::canUseLocalConnection($this->agendaUrl)){
                $this->agendaClient = new OCLocalHttpClient($this->agendaUrl);
            } else {
                $this->agendaClient = new HttpClient($this->agendaUrl);
            }
        }
    }

    public function getNextEventsInfo($context): array
    {
        $isDisabled = [
            'is_enabled' => false,
        ];

        if (!$this->getOpenAgendaUrl()) {
            return $isDisabled;
        }

        if (!$this->getEnableMainCalendar()
            && !$this->getEnableTopicCalendar()
            && !$this->getEnablePlaceCalendar()
            && !$this->getEnableOrganization()) {
            return $isDisabled;
        }

        if (!$context instanceof eZContentObject) {
            return $isDisabled;
        }
        if ($context->attribute('remote_id') === 'all-events') {
            if (!$this->getEnableMainCalendar()) {
                return $isDisabled;
            }

            eZDebug::writeDebug($this->getQuery(), __METHOD__);
            return [
                'is_enabled' => true,
                'view' => [
                    'block_name' => '',
                    'block_type' => 'OpendataRemoteContents',
                    'block_view' => 'default',
                    'parameters' => [
                        'remote_url' => $this->getOpenAgendaUrl(),
                        'query' => $this->getQuery(),
                        'show_grid' => "1",
                        'show_map' => "0",
                        'show_search' => "0",
                        'limit' => "9",
                        'items_per_row' => "3",
                        'facets' => "",
                        'view_api' => "card",
                        'color_style' => "",
                        'fields' => "",
                        'template' => "",
                        'simple_geo_api' => "0",
                        'input_search_placeholder' => "",
                        'intro_text' => "",
                        'show_all_link' => "1",
                        'show_all_text' => ezpI18n::tr('bootstrapitalia', 'Go to event calendar') .
                            ' ' . $this->getStorage(self::NAME_CACHE_KEY),
                        'hide_if_empty' => true,
                    ],
                ],
            ];
        }

        if ($context->attribute('class_identifier') === 'topic') {
            if (!$this->getEnableTopicCalendar()) {
                return $isDisabled;
            }

            $topicsFilter = OpenAgendaTopicMapper::generateTopicQueryFilter(
                $context,
                $this->getStorage(self::VERSION_CACHE_KEY)
            );
            if (empty($topicsFilter)) {
                return $isDisabled;
            }

            return [
                'is_enabled' => true,
                'view' => [
                    'block_name' => ezpI18n::tr('bootstrapitalia', 'Upcoming appointments'),
                    'block_type' => 'OpendataRemoteContents',
                    'block_view' => 'default',
                    'parameters' => [
                        'remote_url' => $this->getOpenAgendaUrl(),
                        'query' => $this->getQuery(
                            [$topicsFilter]
                        ),
                        'show_grid' => "1",
                        'show_map' => "0",
                        'show_search' => "0",
                        'limit' => "3",
                        'items_per_row' => "3",
                        'facets' => "",
                        'view_api' => "card_teaser",
                        'color_style' => "",
                        'fields' => "",
                        'template' => "",
                        'simple_geo_api' => "0",
                        'input_search_placeholder' => "",
                        'intro_text' => "",
                        'show_all_link' => "1",
                        'show_all_text' => ezpI18n::tr('bootstrapitalia', 'Go to event calendar') .
                            ' ' . $this->getStorage(self::NAME_CACHE_KEY),
                        'hide_if_empty' => true,
                    ],
                ],
            ];
        }

        if ($context->attribute('class_identifier') === 'place') {
            if (!$this->getEnablePlaceCalendar()) {
                return $isDisabled;
            }

            return [
                'is_enabled' => true,
                'view' => [
                    'block_name' => ezpI18n::tr('bootstrapitalia', 'Upcoming appointments'),
                    'block_type' => 'OpendataRemoteContents',
                    'block_view' => 'default',
                    'parameters' => [
                        'remote_url' => $this->getOpenAgendaUrl(),
                        'query' => $this->getQuery(
                            [
                                "raw[submeta_takes_place_in___remote_id____ms] in ['" . implode(
                                    "','",
                                    $context->attribute('remote_id')
                                ) . "']",
                            ]
                        ),
                        'show_grid' => "1",
                        'show_map' => "0",
                        'show_search' => "0",
                        'limit' => "3",
                        'items_per_row' => "3",
                        'facets' => "",
                        'view_api' => "card_teaser",
                        'color_style' => "",
                        'fields' => "",
                        'template' => "",
                        'simple_geo_api' => "0",
                        'input_search_placeholder' => "",
                        'intro_text' => "",
                        'show_all_link' => "1",
                        'hide_if_empty' => true,
                    ],
                ],
            ];
        }

        if ($context->attribute('remote_id') === '10742bd28e405f0e83ae61223aea80cb') { //enti e fondazioni
            if (!$this->getEnableOrganization()) {
                return $isDisabled;
            }

            return [
                'is_enabled' => true,
                'view' => [
                    'block_name' => ezpI18n::tr('bootstrapitalia', 'Local associations'),
                    'block_type' => 'OpendataRemoteContents',
                    'block_view' => 'default',
                    'parameters' => [
                        'remote_url' => $this->getOpenAgendaUrl(),
                        'query' => 'classes [private_organization] and state in [privacy.public] sort [name=>asc]',
                        'show_grid' => "1",
                        'show_map' => "0",
                        'show_search' => "0",
                        'limit' => "9",
                        'items_per_row' => "3",
                        'facets' => "",
                        'view_api' => "card",
                        'color_style' => "",
                        'fields' => "",
                        'template' => "",
                        'simple_geo_api' => "0",
                        'input_search_placeholder' => "",
                        'intro_text' => "",
                        'show_all_link' => "1",
                        'show_all_text' => ezpI18n::tr('bootstrapitalia', 'Go to event calendar') .
                            ' ' . $this->getStorage(self::NAME_CACHE_KEY),
                        'hide_if_empty' => true,
                    ],
                ],
            ];
        }

        return $isDisabled;
    }

    private function getQuery(?array $filters = null): string
    {
        $parts = [];
        $parts[] = 'classes [event]';
        $parts[] = 'and state in [moderation.skipped,moderation.accepted]';
        $parts[] = "and calendar[time_interval] = [now, '+ 2 months']";
        if (!empty($filters)) {
            foreach ($filters as $filter) {
                $parts[] = "and " . $filter;
            }
        }
        $parts[] = 'sort [time_interval=>asc]';

        return implode(' ', $parts);
    }

    public static function factory(): OpenAgendaBridge
    {
        if (self::$instance === null) {
            self::$instance = new OpenAgendaBridge();
        }

        return self::$instance;
    }

    public function isEnabled(): bool
    {
        return (bool)$this->getOpenAgendaUrl();
    }

    public function getOpenAgendaUrl()
    {
        if ($this->agendaUrl === null) {
            $this->agendaUrl = $this->getStorage(self::URL_CACHE_KEY);
        }

        return rtrim($this->agendaUrl, '/');
    }

    public function getOpenAgendaName()
    {
        $name = $this->getStorage(self::NAME_CACHE_KEY);
        return empty($name) ? parse_url($this->getOpenAgendaUrl(), PHP_URL_HOST) : $name;
    }

    public function setOpenAgendaUrl($url)
    {
        if (empty($url)) {
            $this->removeStorage(self::URL_CACHE_KEY);
            $this->removeStorage(self::IDENTIFIER_CACHE_KEY);
            $this->removeStorage(self::NAME_CACHE_KEY);
            $this->agendaUrl = null;
        } else {
            $this->agendaUrl = rtrim($url, '/');
            $this->setStorage(self::URL_CACHE_KEY, $this->agendaUrl);
            $remoteInstance = $this->agendaClient->request('GET', '/openpa/data/instance');
            $remoteInstanceIdentifier = $remoteInstance['identifier'] ?? null;
            $remoteInstanceName = $remoteInstance['name'] ?? null;
            $remoteInstanceVersion = $remoteInstance['version'] ?? null;
            $this->setStorage(self::IDENTIFIER_CACHE_KEY, $remoteInstanceIdentifier);
            $this->setStorage(self::NAME_CACHE_KEY, $remoteInstanceName);
            $this->setStorage(self::VERSION_CACHE_KEY, $remoteInstanceVersion);
        }
    }

    /**
     * @return mixed
     */
    public function getEnableMainCalendar()
    {
        if ($this->enableMainCalendar === null) {
            $this->enableMainCalendar = $this->getStorage(self::MAIN_CALENDAR_CACHE_KEY);
        }
        return $this->enableMainCalendar;
    }

    /**
     * @param bool $enableMainCalendar
     */
    public function setEnableMainCalendar(bool $enableMainCalendar): void
    {
        $this->enableMainCalendar = $enableMainCalendar;
        $this->setStorage(self::MAIN_CALENDAR_CACHE_KEY, (int)$enableMainCalendar);
    }

    /**
     * @return mixed
     */
    public function getEnablePlaceCalendar()
    {
        if ($this->enablePlaceCalendar === null) {
            $this->enablePlaceCalendar = $this->getStorage(self::PLACE_CACHE_KEY);
        }
        return $this->enablePlaceCalendar;
    }

    /**
     * @param mixed $enablePlaceCalendar
     */
    public function setEnablePlaceCalendar($enablePlaceCalendar): void
    {
        $this->enablePlaceCalendar = $enablePlaceCalendar;
        $this->setStorage(self::PLACE_CACHE_KEY, (int)$enablePlaceCalendar);
    }


    /**
     * @return mixed
     */
    public function getEnableTopicCalendar()
    {
        if ($this->enableTopicCalendar === null) {
            $this->enableTopicCalendar = $this->getStorage(self::TOPIC_CACHE_KEY);
        }
        return $this->enableTopicCalendar;
    }

    /**
     * @param bool $enableTopicCalendar
     */
    public function setEnableTopicCalendar(bool $enableTopicCalendar): void
    {
        $this->enableTopicCalendar = $enableTopicCalendar;
        $this->setStorage(self::TOPIC_CACHE_KEY, (int)$enableTopicCalendar);
    }

    /**
     * @return mixed
     */
    public function getEnableOrganization()
    {
        if ($this->enableOrganization === null) {
            $this->enableOrganization = $this->getStorage(self::ORGANIZATION_CACHE_KEY);
        }
        return $this->enableOrganization;
    }

    /**
     * @param mixed $enableOrganization
     */
    public function setEnableOrganization($enableOrganization): void
    {
        $this->enableOrganization = $enableOrganization;
        $this->setStorage(self::ORGANIZATION_CACHE_KEY, (int)$enableOrganization);
    }

    /**
     * @return mixed
     */
    public function getEnablePushPlace()
    {
        if ($this->enablePushPlace === null) {
            $this->enablePushPlace = $this->getStorage(self::PUSH_PLACE_CACHE_KEY);
        }
        return $this->enablePushPlace;
    }

    /**
     * @param mixed $enablePushPlace
     */
    public function setEnablePushPlace($enablePushPlace): void
    {
        $this->enablePushPlace = $enablePushPlace;
        $this->setStorage(self::PUSH_PLACE_CACHE_KEY, (int)$enablePushPlace);
    }

    /**
     * @param $placeId
     * @throws Exception
     */
    private function getPlacePayloads($placeId): array
    {
        if (!$this->isEnabled()) {
            throw new Exception('OpenAgenda bridge is not enabled');
        }
        $placeId = (int)$placeId;
        $place = eZContentObject::fetch($placeId);
        if (!$place instanceof eZContentObject) {
            throw new Exception('Place not found');
        }
        if ($place->attribute('class_identifier') !== 'place') {
            throw new Exception('Content type selected is not a place');
        }

        $remoteInstanceIdentifier = $this->getStorage(self::IDENTIFIER_CACHE_KEY);

        if (empty($remoteInstanceIdentifier)) {
            throw new Exception('Remote instance identifier not found');
        }

        try {
            $builder = new SharedLinkedPayloadBuilder(
                $this->agendaClient,
                $placeId,
                $remoteInstanceIdentifier . '_openpa_agenda_locations'
            );
            $payloads = $builder->build();
        } catch (Throwable $e) {
            throw new Exception('Error creating payloads: ' . $e->getMessage());
        }

        return $payloads;
    }

    public function pushPlacePayloads($placeId): array
    {
        $placeId = (int)$placeId;
        $payloads = $this->getStorage('place_' . $placeId);
        if (!$payloads){
            $payloads = $this->getPlacePayloads($placeId);
            $this->setStorage('place_' . $placeId, json_encode($payloads));
            $this->setStorage('count_place_' . $placeId, count($payloads));
            $payloads = json_encode($payloads);
        }
        $payloads = json_decode($payloads, true);
        $payloadCount = (int)$this->getStorage('count_place_' . $placeId);;
        $payload = array_shift($payloads);
        /** @var eZUser $user */
        $user = eZUser::fetchByName('admin');
        if ($payload['metadata']['classIdentifier'] === 'place') {
            $payload['metadata']['stateIdentifiers'] = ['privacy.public'];
        }
        try {
            $this->agendaClient
                ->setHeader('Authorization', 'Bearer ' . JWTManager::issueInternalJWTToken($user))
                ->upsert($payload);
        } catch (Throwable $e) {
            $this->removeStorage('place_' . $placeId);
            $this->removeStorage('count_place_' . $placeId);
            throw new Exception('Fail upserting content: ' .
                $payload['metadata']['remoteId'] . ' ' .
                $e->getMessage());
        }
        if (count($payloads) === 0){
            $this->removeStorage('place_' . $placeId);
            $this->removeStorage('count_place_' . $placeId);
        }else {
            $this->setStorage('place_' . $placeId, json_encode($payloads));
        }
        $remaining = count($payloads);
        return [$remaining, $payloadCount];
    }

    private static function canUseLocalConnection($url): bool
    {
        $host = parse_url($url, PHP_URL_HOST);
        $hostUriMatchMapItems = eZINI::instance()->variable('SiteAccessSettings', 'HostUriMatchMapItems');
        foreach ($hostUriMatchMapItems as $hostUriMatchMapItem) {
            if (strpos($hostUriMatchMapItem, $host) !== false) {
                return true;
            }
        }

        return false;
    }
}