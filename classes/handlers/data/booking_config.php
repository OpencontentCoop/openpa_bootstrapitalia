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
        if (OpenPAINI::variable('StanzaDelCittadinoBridge', 'UseCustomBuiltin_booking', 'disabled') !== 'enabled') {
            return [];
        }

        $http = eZHTTPTool::instance();
        if ($http->hasPostVariable('office') && $http->hasPostVariable('service')
            && $http->hasPostVariable('place') && $http->hasPostVariable('calendars')) {
            return StanzaDelCittadinoBooking::storeConfig(
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
                return StanzaDelCittadinoBooking::getCalendars($service, $office, $place);
            }
            return [];
        }

        if ($this->request === 'offices') {
            $service = $http->hasGetVariable('service') ? (int)$http->getVariable('service') : null;
            if ($service !== null) {
                return StanzaDelCittadinoBooking::getOffices($service);
            }
            return [];
        }

        if ($this->request === 'timetable') {
            $calendars = $http->hasGetVariable('calendars') ? $http->getVariable('calendars') : [];
            return StanzaDelCittadinoBooking::getTimeTable($calendars);
        }

        if ($this->request === 'availabilities') {
            $calendars = $http->hasGetVariable('calendars') ? $http->getVariable('calendars') : [];
            if (is_string($calendars)){
                $calendars = explode(',', $calendars);
            }
            $month = $http->hasGetVariable('month') ? $http->getVariable('month') : null;
            return StanzaDelCittadinoBooking::getAvailabilities($calendars, $month);
        }

        if ($this->request === 'availabilities_by_day') {
            $calendars = $http->hasGetVariable('calendars') ? $http->getVariable('calendars') : [];
            if (is_string($calendars)){
                $calendars = explode(',', $calendars);
            }
            $day = $http->hasGetVariable('day') ? $http->getVariable('day') : null;
            return StanzaDelCittadinoBooking::getAvailabilitiesByDay($calendars, $day);
        }

        return StanzaDelCittadinoBooking::getConfigs();
    }

}