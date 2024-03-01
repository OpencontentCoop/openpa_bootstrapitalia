<?php

class DataHandlerBookingConfig implements OpenPADataHandlerInterface
{
    /**
     * @var ?string
     */
    private $request;

    public function __construct(array $Params)
    {
        $this->request = $Params['Parameters'][1] ?? null;
    }

    public function getData()
    {
        if (!StanzaDelCittadinoBooking::factory()->isEnabled()) {
            return [];
        }

        $http = eZHTTPTool::instance();
        if ($http->hasPostVariable('office') && $http->hasPostVariable('service')
            && $http->hasPostVariable('place') && $http->hasPostVariable('calendars')) {
            return StanzaDelCittadinoBooking::factory()->storeConfig(
                (int)$http->postVariable('office'),
                (int)$http->postVariable('service'),
                (int)$http->postVariable('place'),
                (array)$http->postVariable('calendars')
            );
        }

        if ($this->request === 'calendars') {
            $office = $http->hasGetVariable('office') ? (int)$http->getVariable('office') : null;
            $service = $http->hasGetVariable('service') ? (int)$http->getVariable('service') : null;
            $place = $http->hasGetVariable('place') ? (int)$http->getVariable('place') : null;
            if ($office !== null && $service !== null && $place !== null) {
                return StanzaDelCittadinoBooking::factory()->getCalendars($service, $office, $place);
            }
            return [];
        }

        if ($this->request === 'offices') {
            $service = $http->hasGetVariable('service') ? (int)$http->getVariable('service') : null;
            if ($service !== null) {
                return StanzaDelCittadinoBooking::factory()->getOffices($service);
            }
            return [];
        }

        if ($this->request === 'timetable') {
            $calendars = $http->hasGetVariable('calendars') ? $http->getVariable('calendars') : [];
            return StanzaDelCittadinoBooking::factory()->getTimeTable($calendars);
        }

        return StanzaDelCittadinoBooking::factory()->getConfigs();
    }

}