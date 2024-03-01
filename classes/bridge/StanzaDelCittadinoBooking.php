<?php

class StanzaDelCittadinoBooking
{
    use SiteDataStorageTrait;

    const ENABLE_CACHE_KEY = 'sdc_booking_enabled';

    private static $instance;

    private function __construct(){}

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
            $calendarsString = json_encode($calendars);
            $query = "INSERT INTO ocbookingconfig (office_id,service_id,place_id,calendars) VALUES ($office,$service,$place,'$calendarsString') ON CONFLICT (office_id,service_id,place_id) DO UPDATE SET calendars = EXCLUDED.calendars";
            eZDB::setErrorHandling(eZDB::ERROR_HANDLING_EXCEPTIONS);
            try {
                eZDB::instance()->query($query);
                return true;
            } catch (Throwable $e) {
                eZDebug::writeError($e->getMessage(), __METHOD__);
                return false;
            }
        }
        eZDebug::writeError('Current user can not store booking config', __METHOD__);
        return false;
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
        foreach ($rows as $row){
            $officeObject = eZContentObject::fetch((int)$row['office_id']);
            if ($officeObject instanceof eZContentObject) {
                $data = json_decode($row['data'], true);
                $places = [];
                foreach ($data as $datum) {
                    $placeObject = eZContentObject::fetch((int)$datum['place']);
                    if ($placeObject instanceof eZContentObject) {
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
                        if (isset($dataMap['has_address'])){
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
                $office = [
                    'id' => $row['office_id'],
                    'name' => $officeObject->attribute('name'),
                    'places' => array_values($places),
                ];
                $offices[$office['name']] = $office;
            }
        }
        ksort($office);
        return array_values($offices);
    }

    public function getConfigs(): array
    {
        return eZDB::instance()->arrayQuery("SELECT calendars FROM ocbookingconfig");
    }

    /**
     * @throws Exception
     */
    public function getTimeTable(array $calendars, $showCalendarName = false, $showWeekEnd = false): array
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
        if (!$month || $month == $currentMonth){
            $startDate = date('Y-m-d');
        }else{
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
            $remoteAvailabilities = $client->getCalendarsAvailabilities($calendars, $startDate, $endDateTime->format('Y-m-d'));
            foreach ($remoteAvailabilities['data'] as $index => $availability){
                $availability['name'] = $locale->formatDate(DateTime::createFromFormat('Y-m-d', $availability['date'])->format('U'));
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
        if ($day){
            $client = StanzaDelCittadinoBridge::factory()->instanceNewClient();
            $response = $client->getCalendarsAvailabilities($calendars, $day);
            $availabilities = $response['data'];
        }

        return $availabilities;
    }

//    public static function deleteDraftMeeting($meetingId)
//    {
//        try{
//            StanzaDelCittadinoBridge::factory()
//                ->instanceNewClient()
//                ->request('DELETE', '/api/meetings/'.$meetingId);
//        }catch (Throwable $e){
//            eZDebug::writeError($e->getMessage(), __METHOD__);
//        }
//    }

    /**
     * @param string $calendar
     * @param string $date
     * @param string $opening_hour
     * @param string $slot
     * @param string|null $meetingId
     * @return array
     * @throws Exception
     */
    public function upsertDraftMeeting(string $calendar, string $date, string $opening_hour, string $slot, string $meetingId = null): array
    {
        $data = [
            'calendar' => $calendar,
            'date' => $date,
            'opening_hour' => $opening_hour,
            'slot' => $slot,
            'meeting' => $meetingId,
        ];
        return StanzaDelCittadinoBridge::factory()
            ->instanceNewClient()
            ->request('POST', '/it/meetings/new-draft', $data);

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
}