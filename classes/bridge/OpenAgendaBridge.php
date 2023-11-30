<?php

use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\Rest\Client\HttpClient;

class OpenAgendaBridge
{
    const URL_CACHE_KEY = 'openagenda_url';

    const MAIN_CALENDAR_CACHE_KEY = 'openagenda_main';

    const TOPIC_CACHE_KEY = 'openagenda_topic';

    const PLACE_CACHE_KEY = 'openagenda_place';

    const ORGANIZATION_CACHE_KEY = 'openagenda_organization';

    const PUSH_PLACE_CACHE_KEY = 'openagenda_push_place';

    private static $instance;

    private $agendaUrl;

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
                    ],
                ],
            ];
        }

        if ($context->attribute('class_identifier') === 'topic') {
            if (!$this->getEnableTopicCalendar()) {
                return $isDisabled;
            }

            $remoteTopicIdList = OpenAgendaTopicMapper::findTopicRemoteIdList($context);
            if (empty($remoteTopicIdList)) {
                return $isDisabled;
            }
            eZDebug::writeDebug($this->getQuery($remoteTopicIdList), __METHOD__);

            return [
                'is_enabled' => true,
                'view' => [
                    'block_name' => ezpI18n::tr('bootstrapitalia', 'Upcoming appointments'),
                    'block_type' => 'OpendataRemoteContents',
                    'block_view' => 'default',
                    'parameters' => [
                        'remote_url' => $this->getOpenAgendaUrl(),
                        'query' => $this->getQuery(
                            ["raw[submeta_topics___remote_id____ms] in ['" . implode("','", $remoteTopicIdList) . "']"]
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
                    ],
                ],
            ];
        }

        if ($context->attribute('remote_id') === '10742bd28e405f0e83ae61223aea80cb') {
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

    private function getStorage($key)
    {
        $siteData = eZSiteData::fetchByName($key);
        if (!$siteData instanceof eZSiteData) {
            return false;
        }
        return $siteData->attribute('value');
    }

    private function removeStorage($key)
    {
        $siteData = eZSiteData::fetchByName($key);
        if ($siteData instanceof eZSiteData) {
            $siteData->remove();
        }
    }

    private function setStorage($key, $value)
    {
        $siteData = eZSiteData::fetchByName($key);
        if (!$siteData instanceof eZSiteData) {
            $siteData = eZSiteData::create($key, $value);
        }
        $siteData->setAttribute('value', $value);
        $siteData->store();
    }

    public function setOpenAgendaUrl($url)
    {
        if (empty($url)) {
            $this->removeStorage(self::URL_CACHE_KEY);
            $this->agendaUrl = null;
        } else {
            $this->agendaUrl = $url;
            $this->setStorage(self::URL_CACHE_KEY, $this->agendaUrl);
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
    public function pushPlace($placeId)
    {
        if (!$this->isEnabled()) {
            throw new Exception('OpenAgenda bridge is not enabled');
        }

        $place = eZContentObject::fetch((int)$placeId);
        if (!$place instanceof eZContentObject) {
            throw new Exception('Place not found');
        }
        if ($place->attribute('class_identifier') !== 'place') {
            throw new Exception('Content type selected is not a place');
        }

        try {
            $builder = new SharedLinkedPayloadBuilder(
                $this->getOpenAgendaUrl(),
                $placeId,
                'openagendavicenza_openpa_agenda_locations'
            );
            $payloads = $builder->build();
        } catch (Throwable $e) {
            throw new Exception('Error creating payloads: ' . $e->getMessage());
        }

        /** @var eZUser $user */
        $user = eZUser::fetchByName('admin');
        foreach ($payloads as $payload) {
            try {
                $this->push(
                    $this->getOpenAgendaUrl() . '/content/api/opendata/v2/upsert',
                    json_encode($payload->getArrayCopy()),
                    ["Authorization: Bearer " . JWTManager::issueInternalJWTToken($user)]
                );
            } catch (Throwable $e) {
                throw new Exception('Fail upserting content: ' . $payload->getMetadaData('remoteId'));
            }
        }
    }

    private function push($url, $data = null, $headers = [])
    {
        $headers[] = 'Content-Type: application/json';
        $headers[] = 'Content-Length: ' . strlen($data);

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        curl_setopt($ch, CURLOPT_HEADER, 1);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 60);
        curl_setopt($ch, CURLOPT_TIMEOUT, 60);
        curl_setopt($ch, CURLINFO_HEADER_OUT, true);

        $data = curl_exec($ch);

        if ($data === false) {
            $errorCode = curl_errno($ch) * -1;
            $errorMessage = curl_error($ch);
            curl_close($ch);
            throw new \Exception($errorMessage, $errorCode);
        }

        $info = curl_getinfo($ch);
        \eZDebug::writeDebug($info['request_header'], __METHOD__);

        curl_close($ch);

        $headers = substr($data, 0, $info['header_size']);
        if ($info['download_content_length'] > 0) {
            $body = substr($data, -$info['download_content_length']);
        } else {
            $body = substr($data, $info['header_size']);
        }

        $body = json_decode($body);

        if (isset($body->error_message)) {
            $errorMessage = '';
            if (isset($body->error_type)) {
                $errorMessage = $body->error_type . ': ';
            }
            $errorMessage .= $body->error_message;
            throw new \Exception($errorMessage);
        }

        if ($info['http_code'] == 401) {
            throw new \Exception("Authorization Required");
        }

        if (!in_array($info['http_code'], [100, 200, 201, 202])) {
            throw new \Exception("Unknown error");
        }

        return json_decode($body, true);
    }
}