<?php

class DataHandlerBooking implements OpenPADataHandlerInterface
{
    /**
     * @var ?string
     */
    private $request;

    private $requestParameter;

    public function __construct(array $Params)
    {
        $this->request = $Params['Parameters'][1] ?? null;
        $this->requestParameter = $Params['Parameters'][2] ?? null;
    }

    public function getData()
    {
        if (!StanzaDelCittadinoBooking::factory()->isEnabled()) {
            return [];
        }

        $http = eZHTTPTool::instance();
        if ($this->request === 'calendar' && $this->requestParameter) {
            return StanzaDelCittadinoBooking::factory()->getCalendar($this->requestParameter);
        }

        if ($this->request === 'availabilities') {
            $calendars = $http->hasGetVariable('calendars') ? $http->getVariable('calendars') : [];
            if (is_string($calendars)) {
                $calendars = explode(',', $calendars);
            }
            $month = $http->hasGetVariable('month') ? $http->getVariable('month') : null;
            return StanzaDelCittadinoBooking::factory()->getAvailabilities($calendars, $month);
        }

        if ($this->request === 'availabilities_by_day') {
            $calendars = $http->hasGetVariable('calendars') ? $http->getVariable('calendars') : [];
            if (is_string($calendars)) {
                $calendars = explode(',', $calendars);
            }
            $day = $http->hasGetVariable('day') ? $http->getVariable('day') : null;
            return StanzaDelCittadinoBooking::factory()->getAvailabilitiesByDay($calendars, $day);
        }

        if ($this->request === 'availabilities_by_range') {
            $calendars = $http->hasGetVariable('calendars') ? $http->getVariable('calendars') : [];
            if (is_string($calendars)) {
                $calendars = explode(',', $calendars);
            }
            $start = $http->hasGetVariable('start') ? $http->getVariable('start') : null;
            $end = $http->hasGetVariable('end') ? $http->getVariable('end') : null;
            return StanzaDelCittadinoBooking::factory()->getAvailabilitiesByRange($calendars, $start, $end);
        }

        if ($this->request === 'scheduler') {
            $calendars = $http->hasGetVariable('calendars') ? $http->getVariable('calendars') : [];
            if (is_string($calendars)) {
                $calendars = explode(',', $calendars);
            }
            return StanzaDelCittadinoBooking::factory()->getScheduler($calendars);
        }

        if ($this->request === 'draft_meeting' && $_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                $response = StanzaDelCittadinoBooking::factory()->upsertDraftMeeting(
                    StanzaDelCittadinoBookingDTO::fromRequest()
                );
            } catch (Throwable $e) {
                eZDebug::writeError($e->getMessage(), __METHOD__);
                throw new Exception('Error storing meeting draft: ' . $e->getMessage());
            }
            if (isset($response['error'])) {
                header('HTTP/1.1 400 Bad Request');
            }
            return $response;
        }

        if ($this->request === 'restore_meeting' && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $prevToken = $http->hasSessionVariable('booking_user_token') ? $http->sessionVariable('booking_user_token') : null;
            $currentToken = $http->postVariable('currentToken');
            $meeting = $http->postVariable('meeting');
            $response = [
                'meeting' => $meeting,
            ];
            if ($prevToken && $currentToken && isset($meeting['id'])) {
                try {
                    $response['meeting'] = StanzaDelCittadinoBooking::factory()->restoreDraftMeeting(
                        $prevToken,
                        $currentToken,
                        $meeting
                    );
                } catch (Throwable $e) {
                    eZDebug::writeError($e->getMessage(), __METHOD__);
                    $response['error'] = $e->getMessage();
                }
            }
            $http->setSessionVariable('booking_user_token', $currentToken);

            return $response;
        }

        if ($this->request === 'meeting' && $_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                $response = StanzaDelCittadinoBooking::factory()->bookMeeting(
                    StanzaDelCittadinoBookingDTO::fromRequest()
                );
                $http->removeSessionVariable('booking_user_token');
            } catch (Throwable $e) {
                eZDebug::writeError($e->getMessage(), __METHOD__);
                throw new Exception('Error storing meeting: ' . $e->getMessage());
            }
            if (isset($response['error'])) {
                header('HTTP/1.1 400 Bad Request');
            }

            return $response;
        }

        return [];
    }

}