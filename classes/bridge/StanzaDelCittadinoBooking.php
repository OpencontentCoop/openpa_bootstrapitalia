<?php

class StanzaDelCittadinoBooking
{
    use SiteDataStorageTrait;

    const ENABLE_CACHE_KEY = 'sdc_booking_enabled';

    const CALENDAR_FILTER_CACHE_KEY = 'sdc_booking_calendar_filter';

    const STORE_AS_APPLICATION_CACHE_KEY = 'sdc_booking_as_application';

    const USE_SERVICE_DISCOVER = 'sdc_booking_use_service_discover';

    const USE_SCHEDULER = 'sdc_booking_use_scheduler';

    const SHOW_HOW_TO = 'sdc_booking_show_how_to';

    private static $instance;

    private $calendars = [];

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
        self::initDb();
        $this->setStorage(self::ENABLE_CACHE_KEY, (int)$enable);
    }

    public function isServiceDiscoverEnabled(): bool
    {
        return $this->getStorage(self::USE_SERVICE_DISCOVER);
    }

    public function setServiceDiscover(bool $enable): void
    {
        $this->setStorage(self::USE_SERVICE_DISCOVER, (int)$enable);
    }

    public function isSchedulerEnabled(): bool
    {
        return $this->getStorage(self::USE_SCHEDULER);
    }

    public function setScheduler(bool $enable): void
    {
        $this->setStorage(self::USE_SCHEDULER, (int)$enable);
    }

    public function isShowHowToEnabled(): bool
    {
        return $this->getStorage(self::SHOW_HOW_TO);
    }

    public function setShowHowTo(bool $enable): void
    {
        $this->setStorage(self::SHOW_HOW_TO, (int)$enable);
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
  enable_filter INTEGER DEFAULT 0,
  calendars JSON 
);
ALTER TABLE ONLY ocbookingconfig ADD CONSTRAINT ocbookingconfig_pkey PRIMARY KEY (office_id,service_id,place_id);
CREATE INDEX ocbookingconfig_office ON ocbookingconfig USING btree (office_id);
CREATE INDEX ocbookingconfig_service ON ocbookingconfig USING btree (service_id);
CREATE INDEX ocbookingconfig_place ON ocbookingconfig USING btree (place_id);
EOT;
            $db->query($tableCreateSql);
        } else {
            $columnsQuery = "SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name   = 'ocbookingconfig';";
            $columns = array_column($db->arrayQuery($columnsQuery), 'column_name');
            if (!in_array('enable_filter', $columns)) {
                $appendColumnQuery = "ALTER TABLE ocbookingconfig ADD COLUMN enable_filter INTEGER DEFAULT 0";
                $db->query($appendColumnQuery);
            }
        }
    }

    public function storeConfig(int $office, int $service, int $place, array $calendars, int $enable_filters = 0): bool
    {
        $capabilities = eZUser::currentUser()->hasAccessTo('bootstrapitalia', 'booking_config');
        if ($capabilities['accessWord'] === 'yes') {
            if (count($calendars)) {
                $calendarsString = json_encode($calendars);
                $query = "INSERT INTO ocbookingconfig (office_id,service_id,place_id,enable_filter,calendars) VALUES ($office,$service,$place,$enable_filters,'$calendarsString') ON CONFLICT (office_id,service_id,place_id) DO UPDATE SET calendars = EXCLUDED.calendars, enable_filter = EXCLUDED.enable_filter";
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
        if (!isset($this->calendars[$id])) {
            $this->calendars[$id] = StanzaDelCittadinoBridge::factory()->instanceNewClient(5)->getCalendar($id);
        }
        return $this->calendars[$id];
    }

    public function getCalendars(int $service, int $office, int $place): array
    {
        $query = "SELECT enable_filter, calendars FROM ocbookingconfig WHERE service_id = $service AND office_id = $office AND place_id = $place";
        $rows = eZDB::instance()->arrayQuery($query);
        $calendars = [];
        foreach ($rows as $row) {
            $calendars = array_merge($calendars, json_decode($row['calendars'], true));
        }
        return [
            'enable_filter' => (bool)$rows[0]['enable_filter'],
            'calendars' => array_unique($calendars),
        ];
    }

    public function isServiceRegistered(int $service): bool
    {
        $query = "SELECT count(*) FROM ocbookingconfig WHERE service_id = $service";
        $rows = eZDB::instance()->arrayQuery($query);

        return $rows[0]['count'] > 0;
    }

    public function getOffices(int $service): array
    {
        $offices = [];
        $holdsRoleInTime = [];
        $serviceObject = eZContentObject::fetch($service);
        if ($serviceObject instanceof eZContentObject) {
            $serviceDataMap = $serviceObject->dataMap();
            if (isset($serviceDataMap['holds_role_in_time'])
                && $serviceDataMap['holds_role_in_time']
                    ->attribute('data_type_string') === eZObjectRelationListType::DATA_TYPE_STRING
                && $serviceDataMap['holds_role_in_time']->hasContent()) {
                $holdsRoleInTime = explode(
                    '-',
                    $serviceDataMap['holds_role_in_time']->toString()
                );
            }
        }
        $query = "SELECT 
            office_id, 
            json_agg(json_build_object('place', place_id, 'calendars', calendars, 'enable_filter', enable_filter)) as data 
            FROM ocbookingconfig 
            WHERE service_id = $service GROUP BY office_id";
        $rows = eZDB::instance()->arrayQuery($query);
        foreach ($rows as $row) {
            if ($serviceObject instanceof eZContentObject && !in_array($row['office_id'], $holdsRoleInTime)) {
                $officeIdToRemove = (int)$row['office_id'];
                $removeQuery = "DELETE FROM ocbookingconfig WHERE office_id = $officeIdToRemove AND service_id = $service";
                eZDB::instance()->arrayQuery($removeQuery);
                continue;
            }
            $officeObject = eZContentObject::fetch((int)$row['office_id']);
            if ($officeObject instanceof eZContentObject) {
                $officeDataMap = $officeObject->dataMap();
                $officeRelatedPlaceIdList = [];
                if (isset($officeDataMap['has_spatial_coverage'])
                    && $officeDataMap['has_spatial_coverage']
                        ->attribute('data_type_string') === eZObjectRelationListType::DATA_TYPE_STRING
                    && $officeDataMap['has_spatial_coverage']->hasContent()) {
                    $officeRelatedPlaceIdList = explode(
                        '-',
                        $officeDataMap['has_spatial_coverage']->toString()
                    );
                }
                if (!empty($officeRelatedPlaceIdList)) {
                    $data = json_decode($row['data'], true);
                    $places = [];
                    foreach ($data as $datum) {
                        $placeObject = eZContentObject::fetch((int)$datum['place']);
                        if ($placeObject instanceof eZContentObject
                            && in_array($datum['place'], $officeRelatedPlaceIdList)) {
                            $dataMap = $placeObject->dataMap();
                            $calendars = $datum['calendars'];
                            $calendarNames = [];
                            $maxRollingDays = 0;
                            foreach ($calendars as $index => $calendar) {
                                try {
                                    $c = $this->getCalendar($calendar);
                                    if ($c['rolling_days'] > $maxRollingDays){
                                        $maxRollingDays = (int)$c['rolling_days'];
                                    }
                                    $now = new DateTimeImmutable();
                                    $max = $now->add(new DateInterval('P' . (int)$c['rolling_days'] . 'D'));
                                    $diff = $max->diff($now);
                                    $monthInterval = (($diff->y) * 12) + ($diff->m);
                                    if ($diff->d > 1){
                                        $monthInterval++;
                                    }
                                    $calendarNames[$calendar] = [
                                        'id' => $c['id'],
                                        'title' => $c['title'],
                                        'rolling_days' => $c['rolling_days'],
                                        'month_interval' => $monthInterval,
                                    ];
                                } catch (Throwable $e) {
                                    eZDebug::writeError($e->getMessage(), __METHOD__);
                                    unset($calendars[$index]);
                                }
                            }
                            if (!empty($calendars)) {
                                $now = new DateTimeImmutable();
                                $max = $now->add(new DateInterval('P' . $maxRollingDays . 'D'));
                                $diff = $max->diff($now);
                                $monthInterval = (($diff->y) * 12) + ($diff->m);
                                if ($diff->d > 1){
                                    $monthInterval++;
                                }
                                $place = [
                                    'id' => $datum['place'],
                                    'name' => $placeObject->attribute('name'),
                                    'address' => [
                                        'address' => '',
                                        'latitude' => '',
                                        'longitude' => '',
                                    ],
                                    'calendars' => $calendars,
                                    'calendar_names' => $calendarNames,
                                    'enable_filter' => $datum['enable_filter'],
                                    'max_rolling_days' => $maxRollingDays,
                                    'month_interval' => $monthInterval,
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
                    }
                    if (!empty($places)) {
                        $maxRollingDays = (int)max(array_column($places, 'max_rolling_days'));
                        $now = new DateTimeImmutable();
                        $max = $now->add(new DateInterval('P' . $maxRollingDays . 'D'));
                        $office = [
                            'id' => $row['office_id'],
                            'name' => $officeObject->attribute('name'),
                            'places' => array_values($places),
                            'max_rolling_days' => $maxRollingDays,
                            'month_interval' => $max->diff($now)->format('%m'),
                        ];
                        $offices[$office['name']] = $office;
                    }
                }
            }
        }
        ksort($offices);

        return array_values($offices);
    }

    private function getServiceIdList(): array
    {
        $query = "SELECT service_id, json_agg(calendars) FROM ocbookingconfig GROUP BY service_id";
        $rows = eZDB::instance()->arrayQuery($query);
        return array_column($rows, 'service_id');
    }

    public function getServicesByCategories(): array
    {
        $attributeId = eZContentClassAttribute::classAttributeIDByIdentifier('public_service/type');
        $locale = eZLocale::currentLocaleCode();
        $query = "WITH booking_capable AS (
              SELECT service_id, json_agg(calendars) as calendars FROM ocbookingconfig GROUP BY service_id
            ), 
            services AS (
              SELECT ezcontentobject.*,
                 ezcontentclass.serialized_name_list as serialized_name_list,
                 ezcontentclass.identifier as contentclass_identifier,
                 ezcontentclass.is_container as is_container,
                 booking_capable.calendars as _calendars,
                 ezcontentobject_tree.priority as _priority
              FROM
                 ezcontentobject
              JOIN booking_capable ON (ezcontentobject.id = booking_capable.service_id AND booking_capable.calendars is not null)   
              JOIN ezcontentclass ON (ezcontentclass.id = ezcontentobject.contentclass_id AND ezcontentclass.version=0)
              JOIN ezcontentobject_tree ON (ezcontentobject.id = ezcontentobject_tree.contentobject_id)   
            ),
            type_attributes AS (
              SELECT ezcontentobject_attribute.id as _type_id, ezcontentobject_attribute.version as _type_version, services.* FROM ezcontentobject_attribute 
              JOIN services ON (ezcontentobject_attribute.contentobject_id = services.id AND ezcontentobject_attribute.version = services.current_version)
              WHERE contentclassattribute_id = $attributeId 
            )
            SELECT keyword as _category, type_attributes.*
            FROM eztags_attribute_link 
            JOIN eztags_keyword ON (eztags_keyword.keyword_id = eztags_attribute_link.keyword_id AND eztags_keyword.locale = '$locale')
            JOIN type_attributes 
              ON (eztags_attribute_link.objectattribute_id = type_attributes._type_id AND eztags_attribute_link.objectattribute_version = type_attributes._type_version)
            ORDER BY type_attributes._priority DESC, type_attributes.name ASC";

        $rows = eZDB::instance()->arrayQuery($query);

        $data = [];
        foreach ($rows as $item) {
            $category = $item['_category'];
            $identifier = eZCharTransform::instance()->transformByGroup($category, 'identifier');
            if (!isset($data[$identifier])) {
                $data[$identifier] = [
                    'category' => $category,
                    'identifier' => $identifier,
                    'services' => [],
                ];
            }
            $data[$identifier]['services'][] = new eZContentObject($item);
        }
        ksort($data);
        return array_values($data);
    }

    public function getConfigs(): array
    {
        return eZDB::instance()->arrayQuery("SELECT * FROM ocbookingconfig");
    }

    /**
     * @throws Exception
     */
    public function getTimeTable(array $calendars, $showCalendarLimit = true, $showWeekEnd = true): array
    {
        if (empty($calendars)) {
            return [];
        }

        $client = StanzaDelCittadinoBridge::factory()->instanceNewClient(10);
        $timeTableItem = [];
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
        if ($showCalendarLimit) {
            $timeTableItem[] = '';
        }
        $timeTable[] = array_values($timeTableItem);
        $countColumns = $showWeekEnd ? 8 : 6;
        foreach ($calendars as $calendar) {
            try {
                $timeTableItem = [];
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
                if ($showCalendarLimit) {
                    $timeTableItem[][] = $client->getCalendar($calendar)['rolling_days'] . 'd';
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
        $client = StanzaDelCittadinoBridge::factory()->instanceNewClient(10);
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
            $client = StanzaDelCittadinoBridge::factory()->instanceNewClient(10);
            $response = $client->getCalendarsAvailabilities($calendars, $day);
            $availabilities = $response['data'];
        }

        return $availabilities;
    }

    public function getAvailabilitiesByRange(array $calendars, string $start = null, string $end = null, int $limit = 300): array
    {
        $availabilities = [];
        if ($start && $end) {
            $client = StanzaDelCittadinoBridge::factory()->instanceNewClient(10);
            $response = $client->getCalendarsAvailabilitiesByRange($calendars, $start, $end, $limit);
            $slots = $response['data'];
            foreach ($slots as $slot){
                $availabilities[] = [
                    'id' => md5($slot['date'] . ' ' . $slot['start_time'] . $slot['end_time']),
                    'allDay' => false,
                    'start' => $slot['date'] . ' ' . $slot['start_time'] . ':00',
                    'end' => $slot['date'] . ' ' . $slot['end_time'] . ':00',
                    'title' => '', //$slot['start_time'] . ' '. $slot['end_time'],
                    'editable' => false,
                    'startEditable' => false,
                    'durationEditable' => false,
                    'resourceId' => $slot['calendar_id'],
                    'display' => 'auto',
                    'extendedProps' => $slot,
                ];
            }
        }

        return $availabilities;
    }

    public function getScheduler(array $calendars): array
    {
        $min = '24:00';
        $max = '00:00';
        $hideDays = [0,1,2,3,4,5,6];
        $slot = 30;
        $client = StanzaDelCittadinoBridge::factory()->instanceNewClient(10);
        foreach ($calendars as $calendar) {
            $openingHours = $client->getCalendarOpeningHours($calendar);
//return $openingHours;
            foreach ($openingHours['results'] as $openingHour){
                $min = min($min, $openingHour['begin_hour']);
                $max = max($max, $openingHour['end_hour']);
                $hideDays = array_diff($hideDays, $openingHour['days_of_week']);
                $slot = min($slot, ($openingHour['meeting_minutes']+$openingHour['interval_minutes']));
            }
        }

        $start = new DateTimeImmutable();
        $end = $start->add(new DateInterval('P9D'));
        // cerco fino a 10 gg
        $firstAvailability = StanzaDelCittadinoBooking::factory()->getAvailabilitiesByRange(
            $calendars,
            $start->format('Y-m-d'),
            $end->format('Y-m-d'),
            1
        );
        // cerco ancora altri 10 gg
        if (empty($firstAvailability)){
            $firstAvailability = StanzaDelCittadinoBooking::factory()->getAvailabilitiesByRange(
                $calendars,
                $end->format('Y-m-d'),
                $end->add(new DateInterval('P9D'))->format('Y-m-d'),
                1
            );
        }
        $firstAvailabilityAsString = $firstAvailability[0]['extendedProps']['date'] ?? null;
        if ($firstAvailabilityAsString && !empty($hideDays)){
            $firstAvailabilityAsDateTime = DateTime::createFromFormat('Y-m-d', $firstAvailabilityAsString);
            if ($firstAvailabilityAsDateTime instanceof DateTime) {
                $dayOfWeek = $firstAvailabilityAsDateTime->format('w');
                while (in_array($dayOfWeek, $hideDays)){
                    $firstAvailabilityAsDateTime->add(new DateInterval('P1D'));
                    $dayOfWeek = $firstAvailabilityAsDateTime->format('w');
                }
                $firstAvailabilityAsString = $firstAvailabilityAsDateTime->format('Y-m-d');
            }
        }

        return [
            'minTime' => $min . ':00',
            'maxTime' => $max . ':00',
            'firstAvailability' => $firstAvailabilityAsString,
            'slotDuration' => '00:' . $slot. ':00',
            'hiddenDays' => array_values($hideDays),
        ];
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
        $client = StanzaDelCittadinoBridge::factory()->instanceNewClient(10);
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
            $client = StanzaDelCittadinoBridge::factory()->instanceNewClient(10);
            $client->setBearerToken($prevToken);
            $endpoint = '/api/meetings/' . $meetingId;
            $client->request('DELETE', $endpoint);

            $client = StanzaDelCittadinoBridge::factory()->instanceNewClient(10);
            $client->setBearerToken($currentToken);
            $method = 'POST';
            $endpoint = '/api/meetings';
            $payload = [
                'calendar' => $meeting['calendar']['id'] ?? $meeting['calendar'] ?? null,
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
        $response = $this->isStoreMeetingAsApplication() ? $this->bookAsApplication($dto) : $this->bookAsMeeting($dto);
        $response['meeting'] = $response['data'] ?? $this->getMeetingFromDto($dto);

        return $response;
    }

    private function getMeetingFromDto(StanzaDelCittadinoBookingDTO $dto): ?array
    {
        $meetingId = $dto->getMeetingId();
        if (is_string($meetingId)) {
            try{
                $client = StanzaDelCittadinoBridge::factory()->instanceNewClient(10);
                if (empty($dto->getUserToken())) {
                    $authResponse = $client->request('POST', '/api/session-auth');
                    $dto->setUserToken($authResponse['token']);
                }
                $client->setBearerToken($dto->getUserToken());
                $method = 'GET';
                $endpoint = '/api/meetings/' . $meetingId;
                return $client->request($method, $endpoint);
            }catch (Throwable $e){
                eZDebug::writeError($e->getMessage(), __METHOD__);
            }
        }

        return null;
    }

    private function bookAsApplication(StanzaDelCittadinoBookingDTO $dto): array
    {
        $client = StanzaDelCittadinoBridge::factory()->instanceNewClient(10);
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
        $client = StanzaDelCittadinoBridge::factory()->instanceNewClient(10);
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
                'title' => ezpI18n::tr('bootstrapitalia/booking', 'Permissions and conditions'),
                'required' => [],
            ],
            [
                'id' => 'place',
                'title' => ezpI18n::tr('bootstrapitalia/booking', 'Place'),
                'required' => [
                    [
                        'id' => 'office',
                        'title' => ezpI18n::tr('bootstrapitalia/booking', 'Office'),
                    ],
                ],
            ],
            [
                'id' => 'datetime',
                'title' => ezpI18n::tr('bootstrapitalia/booking', 'Date and time'),
                'required' => [
                    [
                        'id' => 'appointment-available',
                        'title' => ezpI18n::tr('bootstrapitalia/booking', 'Appointments available'),
                    ],
                    [
                        'id' => 'appointment-office',
                        'title' => ezpI18n::tr('bootstrapitalia/booking', 'Office'),
                    ],
                ],
            ],
            [
                'id' => 'details',
                'title' => ezpI18n::tr('bootstrapitalia/booking', 'Appointment details'),
                'required' => [
                    [
                        'id' => 'reason',
                        'title' => ezpI18n::tr('bootstrapitalia/booking', 'Reason'),
                    ],
                    [
                        'id' => 'details',
                        'title' => ezpI18n::tr('bootstrapitalia/booking', 'Detail'),
                    ],
                ],
            ],
            [
                'id' => 'applicant',
                'title' => ezpI18n::tr('bootstrapitalia/booking', 'Applicant'),
                'required' => [
                    [
                        'id' => 'applicant',
                        'title' => ezpI18n::tr('bootstrapitalia/booking', 'Applicant'),
                    ],
                ],
            ],
            [
                'id' => 'summary',
                'title' => ezpI18n::tr('bootstrapitalia/booking', 'Summary'),
                'required' => [],
            ],
        ];
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