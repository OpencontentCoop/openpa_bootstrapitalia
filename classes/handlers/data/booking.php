<?php

class DataHandlerBooking implements OpenPADataHandlerInterface
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

        if ($this->request === 'draft_meeting' && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $calendar = $http->hasPostVariable('calendar') ? $http->postVariable('calendar') : null;
            $date = $http->hasPostVariable('date') ? $http->postVariable('date') : null;
            $opening_hour = $http->hasPostVariable('opening_hour') ? $http->postVariable('opening_hour') : null;
            $slot = $http->hasPostVariable('slot') ? $http->postVariable('slot') : null;
            $meeting = $http->hasPostVariable('meeting') ? $http->postVariable('meeting') : false;
            $meetingId = $meeting['id'] ?? false;
            $meetingExp = $meeting['$meeting'] ?? false;

            if ($meetingId && $meetingExp){
                $exp = DateTime::createFromFormat('Y m d H:m', $meetingExp, new DateTimeZone('Europe/Rome'));
                if ($exp > (new DateTime())){
//                    StanzaDelCittadinoBooking::deleteDraftMeeting($meetingId);
                    $meetingId = false;
                }
            }
            try {
                return StanzaDelCittadinoBooking::upsertDraftMeeting(
                    $calendar,
                    $date,
                    $opening_hour,
                    $slot,
                    $meetingId
                );
            }catch (Throwable $e){
                eZDebug::writeError($e->getMessage(), __METHOD__);
                throw new Exception('Error storing meeting draft: ' . $e->getMessage());
            }
        }

        if ($this->request === 'meeting' && $_SERVER['REQUEST_METHOD'] === 'POST') {
            return $_POST;
        }

        return [];
    }

}