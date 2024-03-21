<?php

class StanzaDelCittadinoBooking
{
    use SiteDataStorageTrait;

    const ENABLE_CACHE_KEY = 'sdc_booking_enabled';

    const CALENDAR_FILTER_CACHE_KEY = 'sdc_booking_calendar_filter';

    const STORE_AS_APPLICATION_CACHE_KEY = 'sdc_booking_as_application';

    private static $instance;

    public static function factory(): StanzaDelCittadinoBooking
    {
        if (self::$instance === null) {
            self::$instance = new StanzaDelCittadinoBooking();
        }

        return self::$instance;
    }

    public function isEnabled(): bool
    {
        return $this->getStorage(self::ENABLE_CACHE_KEY);
    }

    public function setEnabled(bool $enable)
    {
        $this->setStorage(self::ENABLE_CACHE_KEY, (int)$enable);
    }

    private static function initDb()
    {
        $db = eZDB::instance();
        eZDB::setErrorHandling(eZDB::ERROR_HANDLING_EXCEPTIONS);
        $tableQuery = "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ocbookingconfig';";
        $exists = array_fill_keys(array_column($db->arrayQuery($tableQuery), 'tablename'), true);
        if (empty($exists)) {
            $tableCreateSql = <<< EOT
CREATE TABLE ocbookingconfig (  
  office_id INTEGER NOT NULL,
  service_id INTEGER NOT NULL,
  place_id INTEGER NOT NULL,
  calendars JSON 
);
ALTER TABLE ONLY ocbookingconfig ADD CONSTRAINT ocbookingconfig_pkey PRIMARY KEY (office_id,service_id,place_id);
CREATE INDEX ocbookingconfig_office ON ocbookingconfig USING btree (office_id);
CREATE INDEX ocbookingconfig_service ON ocbookingconfig USING btree (service_id);
CREATE INDEX ocbookingconfig_place ON ocbookingconfig USING btree (place_id);
EOT;
            $db->query($tableCreateSql);
        }
    }

    public function storeConfig(int $office, int $service, int $place, array $calendars): bool
    {
        self::initDb();
        $capabilities = eZUser::currentUser()->hasAccessTo('bootstrapitalia', 'booking_config');
        if ($capabilities['accessWord'] === 'yes') {
            if (count($calendars)) {
                $calendarsString = json_encode($calendars);
                $query = "INSERT INTO ocbookingconfig (office_id,service_id,place_id,calendars) VALUES ($office,$service,$place,'$calendarsString') ON CONFLICT (office_id,service_id,place_id) DO UPDATE SET calendars = EXCLUDED.calendars";
            } else {
                $query = "DELETE FROM ocbookingconfig WHERE office_id = $office AND service_id = $service AND place_id = $place";
            }
            eZDB::setErrorHandling(eZDB::ERROR_HANDLING_EXCEPTIONS);
            try {
                eZDB::instance()->query($query);
                if ($service > 0) {
                    eZContentCacheManager::clearContentCache($service);
                }
                return true;
            } catch (Throwable $e) {
                eZDebug::writeError($e->getMessage(), __METHOD__);
                return false;
            }
        }
        eZDebug::writeError('Current user can not store booking config', __METHOD__);
        return false;
    }

    public function getCalendar($id)
    {
        return StanzaDelCittadinoBridge::factory()->instanceNewClient()->getCalendar($id);
    }

    public function getCalendars(int $service, int $office, int $place): array
    {
        $query = "SELECT calendars FROM ocbookingconfig WHERE service_id = $service AND office_id = $office AND place_id = $place";
        $rows = eZDB::instance()->arrayQuery($query);
        $calendars = [];
        foreach ($rows as $row) {
            $calendars = array_merge($calendars, json_decode($row['calendars'], true));
        }
        return array_unique($calendars);
    }

    public function isServiceRegistered(int $service): bool
    {
        $query = "SELECT count(*) FROM ocbookingconfig WHERE service_id = $service";
        $rows = eZDB::instance()->arrayQuery($query);

        return $rows[0]['count'] > 0;
    }

    public function getOffices(int $service): array
    {
        $query = "SELECT office_id, json_agg(json_build_object('place', place_id, 'calendars', calendars)) as data FROM ocbookingconfig WHERE service_id = $service GROUP BY office_id";
        $rows = eZDB::instance()->arrayQuery($query);
        $offices = [];
        foreach ($rows as $row) {
            $officeObject = eZContentObject::fetch((int)$row['office_id']);
            if ($officeObject instanceof eZContentObject) {
                $officeDataMap = $officeObject->dataMap();
                $officeRelatedPlaceIdList = [];
                if (isset($officeDataMap['has_spatial_coverage'])
                    && $officeDataMap['has_spatial_coverage']->attribute(
                        'data_type_string'
                    ) === eZObjectRelationListType::DATA_TYPE_STRING
                    && $officeDataMap['has_spatial_coverage']->hasContent()) {
                    $officeRelatedPlaceIdList = explode('-', $officeDataMap['has_spatial_coverage']->toString());
                }
                if (!empty($officeRelatedPlaceIdList)) {
                    $data = json_decode($row['data'], true);
                    $places = [];
                    foreach ($data as $datum) {
                        $placeObject = eZContentObject::fetch((int)$datum['place']);
                        if ($placeObject instanceof eZContentObject && in_array(
                                $datum['place'],
                                $officeRelatedPlaceIdList
                            )) {
                            $dataMap = $placeObject->dataMap();
                            $place = [
                                'id' => $datum['place'],
                                'name' => $placeObject->attribute('name'),
                                'address' => [
                                    'address' => '',
                                    'latitude' => '',
                                    'longitude' => '',
                                ],
                                'calendars' => $datum['calendars'],
                            ];
                            if (isset($dataMap['has_address'])) {
                                /** @var eZGmapLocation $address */
                                $address = $dataMap['has_address']->content();
                                $place['address'] = [
                                    'address' => $address->attribute('address'),
                                    'latitude' => $address->attribute('address'),
                                    'longitude' => $address->attribute('address'),
                                ];
                            }
                            $places[$place['name']] = $place;
                        }
                    }
                    if (!empty($places)) {
                        $office = [
                            'id' => $row['office_id'],
                            'name' => $officeObject->attribute('name'),
                            'places' => array_values($places),
                        ];
                        $offices[$office['name']] = $office;
                    }
                }
            }
        }
        ksort($offices);
        return array_values($offices);
    }

    public function getConfigs(): array
    {
        return eZDB::instance()->arrayQuery("SELECT calendars FROM ocbookingconfig");
    }

    /**
     * @throws Exception
     */
    public function getTimeTable(array $calendars, $showCalendarName = false, $showWeekEnd = true): array
    {
        if (empty($calendars)) {
            return [];
        }

        StanzaDelCittadinoClient::$connectionTimeout = 10;
        StanzaDelCittadinoClient::$processTimeout = 10;
        $client = StanzaDelCittadinoBridge::factory()->instanceNewClient();
        $timeTableItem = [];
        if ($showCalendarName) {
            $timeTableItem[] = '';
        }
        $locale = eZLocale::instance();
        $timeTableItem = array_merge($timeTableItem, [
            $locale->LongDayNames['mon'],
            $locale->LongDayNames['tue'],
            $locale->LongDayNames['wed'],
            $locale->LongDayNames['thu'],
            $locale->LongDayNames['fri'],
        ]);
        if ($showWeekEnd) {
            $timeTableItem[] = $locale->LongDayNames['sat'];
            $timeTableItem[] = $locale->LongDayNames['sun'];
        }
        $timeTable[] = array_values($timeTableItem);
        $countColumns = $showWeekEnd ? 8 : 6;
        foreach ($calendars as $calendar) {
            try {
                $timeTableItem = [];
                if ($showCalendarName) {
                    $client->getCalendar($calendar)['title'];
                }
                $openingHours = $client->getCalendarOpeningHours($calendar);
                for ($i = 1; $i < $countColumns; $i++) {
                    $timeTableItem[$i] = [];
                }
                foreach ($openingHours['results'] as $openingHour) {
                    for ($i = 1; $i < $countColumns; $i++) {
                        if (in_array($i, $openingHour['days_of_week'])) {
                            $timeTableItem[$i][] = $openingHour['begin_hour'] . '-' . $openingHour['end_hour'];
                        }
                        $timeTableItem[$i] = array_unique($timeTableItem[$i]);
                        sort($timeTableItem[$i]);
                    }
                }
                $timeTable[] = array_values($timeTableItem);
            } catch (Throwable $e) {
                eZDebug::writeError($e->getMessage(), __METHOD__);
            }
        }

        return $timeTable;
    }

    /**
     * @throws Exception
     */
    public function getAvailabilities(array $calendars, string $month = null): array
    {
        StanzaDelCittadinoClient::$connectionTimeout = 10;
        StanzaDelCittadinoClient::$processTimeout = 10;
        $client = StanzaDelCittadinoBridge::factory()->instanceNewClient();
        $currentMonth = date('Y-m');
        if (!$month || $month == $currentMonth) {
            $startDate = date('Y-m-d');
        } else {
            $startDate = $month . '-01';
        }
        $startDateTime = DateTime::createFromFormat('Y-m-d', $startDate);
        $response = [
            'from' => $startDate,
            'to' => null,
            'availabilities' => [],
        ];
        $locale = eZLocale::instance();
        if ($startDateTime instanceof DateTime) {
            $endDateTime = new DateTime(sprintf('last day of %s', $startDateTime->format('Y-m')));
            $response['to'] = $endDateTime->format('Y-m-d');
            $remoteAvailabilities = $client->getCalendarsAvailabilities(
                $calendars,
                $startDate,
                $endDateTime->format('Y-m-d')
            );
            foreach ($remoteAvailabilities['data'] as $index => $availability) {
                $availability['name'] = $locale->formatDate(
                    DateTime::createFromFormat('Y-m-d', $availability['date'])->format('U')
                );
                $response['availabilities'][$index] = $availability;
            }
        }
        return $response;
    }

    /**
     * @throws Exception
     */
    public function getAvailabilitiesByDay(array $calendars, string $day = null): array
    {
        $availabilities = [];
        if ($day) {
            $client = StanzaDelCittadinoBridge::factory()->instanceNewClient();
            $response = $client->getCalendarsAvailabilities($calendars, $day);
            $availabilities = $response['data'];
        }

        return $availabilities;
    }

    /**
     * @param string $calendar
     * @param string $date
     * @param string $opening_hour
     * @param string $slot
     * @param string|null $meetingId
     * @return array
     * @throws Exception
     */
    public function upsertDraftMeeting(StanzaDelCittadinoBookingDTO $dto): array
    {
        $client = StanzaDelCittadinoBridge::factory()->instanceNewClient();
        if (empty($dto->getUserToken())) {
            $authResponse = $client->request('POST', '/api/session-auth');
            $dto->setUserToken($authResponse['token']);
        }
        $client->setBearerToken($dto->getUserToken());

        if ($dto->getMeetingId()) {
            $method = 'PUT';
            $endpoint = '/api/meetings/' . $dto->getMeetingId();
            $meeting = $client->request('GET', $endpoint);
        } else {
            $method = 'POST';
            $endpoint = '/api/meetings';
        }
        $payload = $dto->toMeetingPayload(6);
        $response = [
            'token' => $dto->getUserToken(),
            'payload' => $payload,
            'dto' => $dto,
            'endpoint' => $endpoint,
        ];
        try {
            $response['data'] = $client->request($method, $endpoint, $payload);
            if ($dto->getMeetingId()) {
                $response['data'] = $meeting;
            }
        } catch (Throwable $e) {
            $response['error'] = $e->getMessage();
        }

        return $response;
    }

    public function restoreDraftMeeting($prevToken, $currentToken, $meeting)
    {
        $meetingId = $meeting['id'];
        if ($meetingId) {
            $client = StanzaDelCittadinoBridge::factory()->instanceNewClient();
            $client->setBearerToken($prevToken);
            $endpoint = '/api/meetings/' . $meetingId;
            $client->request('DELETE', $endpoint);

            $client = StanzaDelCittadinoBridge::factory()->instanceNewClient();
            $client->setBearerToken($currentToken);
            $method = 'POST';
            $endpoint = '/api/meetings';
            $payload = [
                'calendar' => $meeting['calendar'] ?? null,
                'opening_hour' => $meeting['opening_hour'] ?? null,
                'from_time' => $meeting['from_time'] ?? null,
                'to_time' => $meeting['to_time'] ?? null,
                'status' => 6,
            ];
            return $client->request($method, $endpoint, $payload);
        }

        return null;
    }

    public function bookMeeting(StanzaDelCittadinoBookingDTO $dto): array
    {
        return $this->isStoreMeetingAsApplication() ? $this->bookAsApplication($dto) : $this->bookAsMeeting($dto);
    }

    private function bookAsApplication(StanzaDelCittadinoBookingDTO $dto): array
    {
        $client = StanzaDelCittadinoBridge::factory()->instanceNewClient();
        if (empty($dto->getUserToken())) {
            $authResponse = $client->request('POST', '/api/session-auth');
            $dto->setUserToken($authResponse['token']);
        }
        $client->setBearerToken($dto->getUserToken());
        $endpoint = '/api/applications';
        $payload = $dto->toApplicationPayload();
        $response = [
            'token' => $dto->getUserToken(),
            'payload' => $payload,
            'dto' => $dto,
            'endpoint' => $endpoint,
        ];
        try {
            $response['data'] = $client->request('POST', $endpoint, $payload);
        } catch (Throwable $e) {
            $response['error'] = $e->getMessage();
        }

        return $response;
    }

    private function bookAsMeeting(StanzaDelCittadinoBookingDTO $dto): array
    {
        $client = StanzaDelCittadinoBridge::factory()->instanceNewClient();
        if (empty($dto->getUserToken())) {
            $authResponse = $client->request('POST', '/api/session-auth');
            $dto->setUserToken($authResponse['token']);
        }
        $client->setBearerToken($dto->getUserToken());
        $method = 'PUT';
        $endpoint = '/api/meetings/' . $dto->getMeetingId();
        $payload = $dto->toMeetingPayload(1);
        $response = [
            'token' => $dto->getUserToken(),
            'payload' => $payload,
            'dto' => $dto,
            'endpoint' => $endpoint,
        ];
        try {
            $response['data'] = $client->request($method, $endpoint, $payload);
        } catch (Throwable $e) {
            $response['error'] = $e->getMessage();
        }

        return $response;
    }

    public function getSteps(): array
    {
        return [
            [
                'id' => 'auth',
                'title' => 'Autorizzazioni e condizioni',
                'required' => [],
            ],
            [
                'id' => 'place',
                'title' => 'Luogo',
                'required' => [
                    [
                        'id' => 'office',
                        'title' => 'Ufficio',
                    ],
                ],
            ],
            [
                'id' => 'datetime',
                'title' => 'Data e orario',
                'required' => [
                    [
                        'id' => 'availabilities',
                        'title' => 'Appuntamenti disponibili',
                    ],
                    [
                        'id' => 'office',
                        'title' => 'Ufficio',
                    ],
                ],
            ],
            [
                'id' => 'details',
                'title' => 'Dettagli appuntamento',
                'required' => [
                    [
                        'id' => 'service_detail',
                        'title' => 'Motivo',
                    ],
                    [
                        'id' => 'user_details',
                        'title' => 'Dettagli',
                    ],
                ],
            ],
            [
                'id' => 'applicant',
                'title' => 'Richiedente',
                'required' => [
                    [
                        'id' => 'applicant',
                        'title' => 'Richiedente',
                    ],
                ],
            ],
            [
                'id' => 'summary',
                'title' => 'Riepilogo',
                'required' => [],
            ],
        ];
    }

    public function useCalendarFilter(): bool
    {
        return (bool)$this->getStorage(self::CALENDAR_FILTER_CACHE_KEY);
    }

    public function setUseCalendarFilter($enable)
    {
        $this->setStorage(self::CALENDAR_FILTER_CACHE_KEY, (int)$enable);
    }

    public function isStoreMeetingAsApplication(): bool
    {
        return (bool)$this->getStorage(self::STORE_AS_APPLICATION_CACHE_KEY);
    }

    public function setStoreMeetingAsApplication($enable)
    {
        $this->setStorage(self::STORE_AS_APPLICATION_CACHE_KEY, (int)$enable);
    }
}