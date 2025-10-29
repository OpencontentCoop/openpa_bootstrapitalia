<?php

class StanzaDelCittadinoBookingDTO implements JsonSerializable
{
    private $calendar;

    private $openingHourId;

    private $date;

    private $toTime;

    private $fromTime;

    private $user;

    private $userToken;

    private $meetingId;

    private $meetingCode;

    private $email;

    private $phoneNumber;

    private $fiscalCode;

    private $name;

    private $surname;

    private $userMessage;

    private $reason;

    private $place;

    private $slot;

    private $motivationOutcome;

    private $calendarGroupConfigId;

    /**
     * @return mixed
     */
    public function getCalendar()
    {
        return $this->calendar;
    }

    /**
     * @param mixed $calendar
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setCalendar($calendar)
    {
        $this->calendar = $calendar;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getOpeningHourId()
    {
        return $this->openingHourId;
    }

    /**
     * @param mixed $openingHourId
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setOpeningHourId($openingHourId)
    {
        $this->openingHourId = $openingHourId;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getDate()
    {
        return $this->date;
    }

    /**
     * @param mixed $date
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setDate($date)
    {
        $this->date = $date;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getToTime()
    {
        return $this->toTime;
    }

    /**
     * @param mixed $toTime
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setToTime($toTime)
    {
        $this->toTime = $toTime;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getFromTime()
    {
        return $this->fromTime;
    }

    /**
     * @param mixed $fromTime
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setFromTime($fromTime)
    {
        $this->fromTime = $fromTime;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getUser()
    {
        return $this->user;
    }

    /**
     * @param mixed $user
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setUser($user)
    {
        $this->user = $user;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getUserToken()
    {
        return $this->userToken;
    }

    /**
     * @param mixed $userToken
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setUserToken($userToken)
    {
        $this->userToken = $userToken;
        if (!empty($userToken) && empty($this->getUser())){
            $this->setUser($this->getUserProperties()['id'] ?? null);
        }
        return $this;
    }

    /**
     * @return mixed
     */
    public function getMeetingId()
    {
        return $this->meetingId;
    }

    /**
     * @param mixed $meetingId
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setMeetingId($meetingId)
    {
        $this->meetingId = $meetingId['id'] ?? $meetingId;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getEmail()
    {
        return $this->email;
    }

    /**
     * @param mixed $email
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setEmail($email)
    {
        $this->email = $email;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getPhoneNumber()
    {
        return $this->phoneNumber;
    }

    /**
     * @param mixed $phoneNumber
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setPhoneNumber($phoneNumber)
    {
        $this->phoneNumber = $phoneNumber;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getFiscalCode()
    {
        return $this->fiscalCode;
    }

    /**
     * @param mixed $fiscalCode
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setFiscalCode($fiscalCode)
    {
        $this->fiscalCode = $fiscalCode;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * @param mixed $name
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setName($name)
    {
        $this->name = $name;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getSurname()
    {
        return $this->surname;
    }

    /**
     * @param mixed $surname
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setSurname($surname)
    {
        $this->surname = $surname;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getUserMessage()
    {
        return $this->userMessage;
    }

    /**
     * @param mixed $userMessage
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setUserMessage($userMessage)
    {
        $this->userMessage = $userMessage;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getReason()
    {
        return $this->reason;
    }

    /**
     * @param mixed $reason
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setReason($reason)
    {
        $this->reason = $reason;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getPlace()
    {
        return $this->place;
    }

    /**
     * @param mixed $place
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setPlace($place)
    {
        $this->place = $place;
        return $this;
    }

    /**
     * @return mixed
     */
    public function getSlot()
    {
        return $this->slot;
    }

    /**
     * @param mixed $slot
     * @return StanzaDelCittadinoBookingDTO
     */
    public function setSlot($slot)
    {
        $this->slot = $slot;
        return $this;
    }

    public function getMotivationOutcome()
    {
        return $this->motivationOutcome;
    }

    public function setMotivationOutcome($motivationOutcome)
    {
        $this->motivationOutcome = $motivationOutcome;
        return $this;
    }

    public function getMeetingCode()
    {
        return $this->meetingCode;
    }

    public function setMeetingCode($meetingCode)
    {
        $this->meetingCode = $meetingCode['code'] ?? $meetingCode;
        return $this;
    }

    public function getCalendarGroupConfigId()
    {
        return $this->calendarGroupConfigId;
    }

    public function setCalendarGroupConfigId($calendarGroupConfigId)
    {
        $this->calendarGroupConfigId = $calendarGroupConfigId;
        return $this;
    }

    public static function fromRequest()
    {
        $dto = new static();
        $http = eZHTTPTool::instance();

        if ($http->hasSessionVariable('booking_user_token')) {
            $dto->setUserToken($http->sessionVariable('booking_user_token'));
        }

        if ($http->hasPostVariable('calendar')) {
            $dto->setCalendar($http->postVariable('calendar'));
        }
        if ($http->hasPostVariable('opening_hour_id')) {
            $dto->setOpeningHourId($http->postVariable('opening_hour_id'));
        }
        if ($http->hasPostVariable('date')) {
            $dto->setDate($http->postVariable('date'));
        }
        if ($http->hasPostVariable('to_time')) {
            $dto->setToTime($http->postVariable('to_time'));
        }
        if ($http->hasPostVariable('from_time')) {
            $dto->setFromTime($http->postVariable('from_time'));
        }
        if ($http->hasPostVariable('user') && empty($dto->getUser())) {
            $dto->setUser($http->postVariable('user'));
        }
        if ($http->hasPostVariable('meeting')) {
            $dto->setMeetingId($http->postVariable('meeting'));
            $dto->setMeetingCode($http->postVariable('meeting'));
        }
        if ($http->hasPostVariable('email')) {
            $dto->setEmail($http->postVariable('email'));
        }
        if ($http->hasPostVariable('phone_number')) {
            $dto->setPhoneNumber($http->postVariable('phone_number'));
        }
        if ($http->hasPostVariable('fiscal_code')) {
            $dto->setFiscalCode($http->postVariable('fiscal_code'));
        }
        if ($http->hasPostVariable('name')) {
            $dto->setName($http->postVariable('name'));
        }
        if ($http->hasPostVariable('surname')) {
            $dto->setSurname($http->postVariable('surname'));
        }
        if ($http->hasPostVariable('user_message')) {
            $dto->setUserMessage($http->postVariable('user_message'));
        }
        if ($http->hasPostVariable('reason')) {
            $dto->setReason($http->postVariable('reason'));
        }
        if ($http->hasPostVariable('place')) {
            $dto->setPlace($http->postVariable('place'));
        }
        if ($http->hasPostVariable('slot')) {
            $dto->setSlot($http->postVariable('slot'));
        }
        if ($http->hasPostVariable('motivation_outcome')) {
            $dto->setMotivationOutcome($http->postVariable('motivation_outcome'));
        }
        if ($http->hasPostVariable('calendar_group_config_id')) {
            $dto->setCalendarGroupConfigId($http->postVariable('calendar_group_config_id'));
        }

        return $dto;
    }

    public function toApplicationPayload(): array
    {
        $dateFormatted = implode('/', array_reverse(explode('-', $this->getDate())));
        return [
            'service' => 'bookings',
            'data' => [
                'applicant' => [
                    'data' => [
                        'email_address' => $this->getEmail(),
                        'phone_number' => $this->getPhoneNumber(),
                        'completename' => [
                            'data' => [
                                'name' => $this->getName(),
                                'surname' => $this->surname,
                            ],
                        ],
                        'fiscal_code' => [
                            'data' => [
                                'fiscal_code' => $this->getFiscalCode(),
                            ],
                        ],
                    ],
                ],
                'calendar' => "$dateFormatted @ {$this->getFromTime()}-{$this->getToTime()} ({$this->getCalendar()}#{$this->getMeetingId()}#{$this->getOpeningHourId()})",
                'user_group' => [],
                'day' => $this->getDate(),
                'meeting_id' => $this->getMeetingId(),
                'service' => $this->getReason(),
                'time' => [
                    'availability' => true,
                    'date' => $this->getDate(),
                    'end_time' => $this->getToTime(),
                    'opening_hour' => $this->getOpeningHourId(),
                    'slots_available' => 1,
                    'start_time' => $this->getFromTime(),
                ],
                'user_message' => $this->getUserMessage(),
                'privacy' => true,
                'location' => $this->getPlace(),
            ],
            'status' => 1900,
        ];
    }

    public function toMeetingPayload(int $withStatus = 0): array
    {
        if (empty($this->getFromTime()) || empty($this->getToTime())){
            [$fromTime, $toTime] = explode('-', $this->getSlot());
            $this->setFromTime($fromTime);
            $this->setToTime($toTime);
        }

        $data = [
            'calendar' => $this->getCalendar(),
            'user' => $this->getUser(),
            'opening_hour' => $this->getOpeningHourId(),
            'email' => $this->getEmail(),
            'fiscal_code' => $this->getFiscalCode(),
            'name' => $this->getName() . ' ' . $this->getSurname(),
            'phone_number' => $this->getPhoneNumber(),
            'from_time' => DateTime::createFromFormat('Y-m-d H:i', $this->getDate() . ' ' . $this->getFromTime())->format('c'),
            'to_time' => DateTime::createFromFormat('Y-m-d H:i', $this->getDate() . ' ' . $this->getToTime())->format('c'),
            'user_message' => $this->getUserMessage(),
            'reason' => $this->getReason(),
            'status' => $withStatus,
            'location' => $this->getPlace(),
            'motivation_outcome' => $this->getMotivationOutcome(),
            'calendar_group_config_id' => $this->getCalendarGroupConfigId(),
            'locale' => eZLocale::instance()->httpLocaleCode(),
        ];

        if (!empty($this->getMeetingCode())){
            $data['code'] = $this->getMeetingCode();
        }

        return $data;
    }

    public function jsonSerialize()
    {
        return get_object_vars($this);
    }

    private function getUserProperties(): ?array
    {
        if (!empty($this->getUserToken())) {
            [$header, $payload, $signature] = explode(".", $this->getUserToken());
            return json_decode(base64_decode($payload), true);
        }

        return null;
    }
}