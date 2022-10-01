<?php

use Opencontent\Opendata\Api\Values\SearchResults;
use Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder;
use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\Api\Values\ContentData;

class OpenPABootstrapItaliaCalendarEnvironmentSettings extends OpenPABootstrapItaliaContentEnvironmentSettings
{
    const RECURRENCE_ATTRIBUTE_IDENTIFIER = 'time_interval';

    const OPENING_HOURS_FROM_IDENTIFIER = 'valid_from';

    const OPENING_HOURS_TO_IDENTIFIER = 'valid_through';

    const OPENING_HOURS_MATRIX_IDENTIFIER = 'opening_hours';

    protected $maxSearchLimit = 300;

    private $timedAttributesIdentifiers;

    public function filterContent(Content $content)
    {
        return $content;
    }

    /**
     * @see https://fullcalendar.io/docs/event_data/events_json_feed/
     *
     * @param SearchResults $searchResults
     * @param ArrayObject $query
     * @param QueryBuilder $builder
     *
     * @return array
     */
    public function filterSearchResult(
        \Opencontent\Opendata\Api\Values\SearchResults $searchResults,
        \ArrayObject $query,
        \Opencontent\QueryLanguage\QueryBuilder $builder
    )
    {
        //return parent::filterSearchResult($searchResults, $query, $builder);
        $events = [];
        if ($searchResults->totalCount > 0) {
            foreach ($searchResults->searchHits as $content) {
                $events = array_merge($events, $this->convertContentToFullcalendarItem($content));
            }
        }
        return $events;
    }

    private function convertContentToFullcalendarItem(Content $content)
    {
        $data = $this->getFirstLocale($content->data);
        $recurrences = array();
        $timedAttributesIdentifiers = $this->getTimedAttributesIdentifiers();

        if (!empty($timedAttributesIdentifiers)) {
            $converted = false;
            foreach ($timedAttributesIdentifiers['recurrence'] as $recurrence) {
                if (isset($data[$recurrence]) && !empty($data[$recurrence]['content'])) {
                    $recurrences = array_merge($recurrences, $this->convertRecurrenceToFullcalendarItem($content, $recurrence));
                    $converted = true;
                    break;
                }
            }
            if (!$converted) {
                foreach ($timedAttributesIdentifiers['opening_hours'] as $openingHoursIdentifier) {
                    if (isset($data[$openingHoursIdentifier]) && !empty($data[$openingHoursIdentifier]['content'])) {
                        $recurrences = array_merge($recurrences, $this->convertOpeningHourToFullcalendarItem($content, $openingHoursIdentifier));
                        $converted = true;
                        break;
                    }
                }
            }
        }else{
            $recurrences = array_merge($recurrences, $this->convertEventToFullcalendarItem($content));
        }

        return $recurrences;
    }

    private function convertRecurrenceToFullcalendarItem(Content $content, $recurrenceIdentifier)
    {
        $recurrences = array();
        $parameters = $this->request->get;
        $startRequest = new DateTime($parameters['start'], new \DateTimeZone('UTC'));
        $endRequest = new DateTime($parameters['end'], new \DateTimeZone('UTC'));
        $data = $this->getFirstLocale($content->data);
        $recurrencesData = $data[$recurrenceIdentifier]['content'];
        $eventId = $content->metadata->id;
        $eventTitle = $this->getFirstLocale($content->metadata->name);
        $eventContent = parent::filterContent($content);

        foreach ($recurrencesData['events'] as $k => $v) {

            $from = $v['start'];
            $to = $v['end'];
            $allDay = false;

            $fromDateTime = DateTime::createFromFormat(DateTime::ISO8601, $from);
            $toDateTime = DateTime::createFromFormat(DateTime::ISO8601, $to);

            if ($fromDateTime instanceof DateTime && $toDateTime instanceof DateTime) {

                if (
                    ($fromDateTime >= $startRequest && $fromDateTime <= $endRequest)
                    || ($toDateTime >= $startRequest && $toDateTime <= $endRequest)
                    || ($fromDateTime <= $endRequest && $toDateTime >= $startRequest)
                ) {

                    $endOfFrom = clone $fromDateTime;
                    $endOfFrom->setTime(23, 59);
                    if ($toDateTime > $endOfFrom){
                        $allDay = true;
                        $from = $fromDateTime->format("Y-m-d");
                        $fixedToDateTime = clone $toDateTime;
                        /*
                         * https://fullcalendar.io/docs/event-object
                         * The exclusive date/time an event ends. Optional. A Moment-ish input, like an ISO8601 string.
                         * Throughout the API this will become a real Moment object. It is the moment immediately after the event has ended.
                         */
                        $fixedToDateTime->add(new DateInterval("P1D"));
                        $to = $fixedToDateTime->format("Y-m-d");
                    }

                    $event = new OpenPABootstrapItaliaCalendarEvent();
                    $event->setId($eventId)
                        ->setTitle($eventTitle)
                        ->setStart($from)
                        ->setEnd($to)
                        ->setAllDay($allDay)
                        ->setContent($eventContent)
                        ->setType($this->getClassName($content->metadata['classIdentifier']));

                    $recurrences[] = $event;
                }
            }
        }

        return $recurrences;
    }

    private function convertEventToFullcalendarItem(Content $content)
    {
        $content = parent::filterContent($content);
        $data = $this->getFirstLocale($content['data']);
        $recurrences = array();
        $eventBoundary = $this->getFromToEventBoundary($content, $data, 'from_time', 'to_time');

        if ($eventBoundary->from) {
            $event = new OpenPABootstrapItaliaCalendarEvent();
            $event->setTitle($this->getFirstLocale($content['metadata']['name']))
                ->setId($content['metadata']['id'])
                ->setType($this->getClassName($content['metadata']['classIdentifier']))
                ->setStart($eventBoundary->from)
                ->setEnd($eventBoundary->to)
                ->setAllDay($eventBoundary->allDay);
            $recurrences[] = $event;
        }

        return $recurrences;
    }

    private function getFromToEventBoundary($content, $contentData, $fromIdentifier, $toIdentifier)
    {
        $data = new stdClass();
        $data->from = isset($contentData[$fromIdentifier]) ? $contentData[$toIdentifier] : false;
        if ($data->from) {
            $data->to = isset($contentData[$toIdentifier]) ? $contentData[$toIdentifier] : false;
            $data->allDay = false;
            if ($data->to) {
                $fromDateTime = DateTime::createFromFormat(DateTime::ISO8601, $data->from);
                $toDateTime = DateTime::createFromFormat(DateTime::ISO8601, $data->to);
                if ($fromDateTime instanceof DateTime && $toDateTime instanceof DateTime) {
                    $endOfFrom = clone $fromDateTime;
                    $endOfFrom->setTime(23, 59);

                    if ($toDateTime > $endOfFrom) {
                        $data->allDay = true;
                        $data->from = $fromDateTime->format("Y-m-d");
                        $fixedToDateTime = clone $toDateTime;
                        /*
                         * https://fullcalendar.io/docs/event-object
                         * The exclusive date/time an event ends. Optional. A Moment-ish input, like an ISO8601 string.
                         * Throughout the API this will become a real Moment object. It is the moment immediately after the event has ended.
                         */
                        $fixedToDateTime->add(new DateInterval("P1D"));
                        $data->to = $fixedToDateTime->format("Y-m-d");
                    }
                }
            }
        }

        return $data;
    }

    private function convertOpeningHourToFullcalendarItem(Content $content, $openingHoursIdentifier)
    {
        $content = parent::filterContent($content);
        $recurrences = array();
        $data = $this->getFirstLocale($content['data']);
        $fromTo = $data[$openingHoursIdentifier];

        foreach ($fromTo as $timeRelation) {
            $eventBoundary = $this->getFromToEventBoundary($timeRelation, $timeRelation['data'],self::OPENING_HOURS_FROM_IDENTIFIER, self::OPENING_HOURS_FROM_IDENTIFIER);
            if ($eventBoundary->from) {
                $hoursMatrix = isset($timeRelation['data'][self::OPENING_HOURS_MATRIX_IDENTIFIER]) ? $this->getMatrixContent($timeRelation['data'][self::OPENING_HOURS_MATRIX_IDENTIFIER]) : false;
                $baseEvent = new OpenPABootstrapItaliaCalendarEvent();
                $baseEvent->setTitle($this->getFirstLocale($content['metadata']['name']) . ' (' . $this->getFirstLocale($timeRelation['name']) . ')')
                    ->setId($content['metadata']['id'])
                    ->setType($this->getClassName($content['metadata']['classIdentifier']));

                if (empty($hoursMatrix)) {
                    $event = clone $baseEvent;
                    $event->setTitle($this->getFirstLocale($content['metadata']['name']) . ' (' . $this->getFirstLocale($timeRelation['name']) . ')')
                        ->setStart($eventBoundary->from)
                        ->setEnd($eventBoundary->to)
                        ->setAllDay($eventBoundary->allDay);

                    $recurrences[] = $event;
                
                } else {
                    $parameters = $this->request->get;
                    $startRequest = new DateTime($parameters['start'], new \DateTimeZone('UTC'));
                    $endRequest = new DateTime($parameters['end'], new \DateTimeZone('UTC'));
                    $datePeriod = new DatePeriod($startRequest, new DateInterval('P1D'), $endRequest);

                    /** @var DateTime $period */
                    foreach ($datePeriod as $period) {
                        foreach ($hoursMatrix as $day => $values){
                            if ($day == strtolower($period->format('l'))){
                                foreach ($values as $value){                                    
                                    $startTime = explode('.', $value[0]);                                    
                                    $endTime = explode('.', $value[1]);
                                    $start = clone $period;
                                    $start->setTime($startTime[0], $startTime[1]);
                                    $end = clone $period;
                                    $end->setTime($endTime[0], $endTime[1]);

                                    $event = clone $baseEvent;
                                    $event->setId($content['metadata']['id'] . '-' . $timeRelation['id'] . '-' . $day . '-' . implode(':', $value))
                                        ->setTitle($this->getFirstLocale($content['metadata']['name']) . ' (' . $this->getFirstLocale($timeRelation['name']) . ')')
                                        ->setStart($start->format(DateTime::ISO8601))
                                        ->setEnd($end->format(DateTime::ISO8601));

                                    $recurrences[] = $event;
                                }
                            }
                        }
                    }
                }
            }
        }


        return $recurrences;
    }

    private function getMatrixContent($data)
    {
        $days = array();
        foreach ($data as $item) {
            foreach ($item as $day => $value) {
                if (!empty($value)) {
                    $valueParts = explode('-', $value);
                    $valueParts = array_map('trim', $valueParts);
                    $days[$day][] = $valueParts;                    
                }
            }
        }

        return $days;
    }

    private function getFirstLocale($value)
    {
        $language = eZLocale::currentLocaleCode();
        return isset($value[$language]) ? $value[$language] : array_shift($value);
    }

    /**
     * @see https://fullcalendar.io/docs/event_data/events_json_feed/
     *
     * @param ArrayObject $query
     * @param QueryBuilder $builder
     *
     * @return ArrayObject
     */
    public function filterQuery(
        \ArrayObject $query,
        \Opencontent\QueryLanguage\QueryBuilder $builder
    )
    {
        $calendarFilter = $this->buildCalendarFilter($query, $builder);

        $currentFilter = isset($query['Filter']) ? $query['Filter'] : [];
        if (!empty($currentFilter))
            $query['Filter'] = array($currentFilter, $calendarFilter);
        else
            $query['Filter'] = $calendarFilter;

        if (isset($query['SearchLimit'])) {
            if ($query['SearchLimit'] > $this->maxSearchLimit) {
                $query['SearchLimit'] = $this->maxSearchLimit;
            }
        } else {
            $query['SearchLimit'] = $this->maxSearchLimit;
        }

        if (!isset($query['SearchOffset'])) {
            $query['SearchOffset'] = 0;
        }

        return $query;
    }

    private function getTimedAttributesIdentifiers($classIdList = array())
    {
        if ($this->timedAttributesIdentifiers === null) {

            $db = eZDB::instance();
            $oCEventTypeDataTypeString = $db->escapeString(OCEventType::DATA_TYPE_STRING);
            $eZObjectRelationListType = $db->escapeString(eZObjectRelationListType::DATA_TYPE_STRING);

            if (empty($classIdList)) {
                $version = eZContentClass::VERSION_STATUS_DEFINED;

                $sql = "SELECT DISTINCT contentclass_id
                    FROM ezcontentclass_attribute
                    WHERE version=$version
                    AND ( data_type_string='$oCEventTypeDataTypeString' ) OR ( data_type_string='$eZObjectRelationListType' AND data_text5 like '%opening_hours_specification%')";

                $classIdList = $db->arrayQuery($sql, array('column' => 'contentclass_id'));
            }

            $recurrenceIdentifiers = array();
            $openingHoursIdentifiers = array();
            foreach ($classIdList as $classId) {
                $classIdentifier = eZContentClass::classIdentifierByID($classId);
                if ($classIdentifier) {
                    $class = $this->getClassDefinition($classIdentifier);
                    foreach ($class['fields'] as $field) {
                        if ($field['dataType'] == $oCEventTypeDataTypeString) {
                            $recurrenceIdentifiers[] = $field['identifier'];
                            break;
                        }
                        if ($field['dataType'] == $eZObjectRelationListType && in_array('opening_hours_specification', $field['constraint'])) {
                            $openingHoursIdentifiers[] = $field['identifier'];
                            break;
                        }
                    }
                }
            }

            if (empty($recurrenceIdentifiers) && empty($openingHoursIdentifiers)) {
                $this->timedAttributesIdentifiers = array();
            } else {
                $this->timedAttributesIdentifiers = array(
                    'recurrence' => array_unique($recurrenceIdentifiers),
                    'opening_hours' => array_unique($openingHoursIdentifiers),
                );
            }
        }

        return $this->timedAttributesIdentifiers;
    }

    private function buildCalendarFilter(
        \ArrayObject $query,
        \Opencontent\QueryLanguage\QueryBuilder $builder
    )
    {
        $parameters = $this->request->get;
        $start = $parameters['start'];
        $end = $parameters['end'];

        $classIdList = isset($query['SearchContentClassID']) ? $query['SearchContentClassID'] : array();
        $timedAttributesIdentifiers = $this->getTimedAttributesIdentifiers($classIdList);

        $calendarFilter = array();
        if (empty($timedAttributesIdentifiers)) {
            $calendarQuery = "calendar[] = [$start,$end]";
            $queryObject = $builder->instanceQuery($calendarQuery);
            $calendarQuery = $queryObject->convert();
            $calendarFilter[] = $calendarQuery->getArrayCopy()['Filter'];
        } else {
            foreach ($timedAttributesIdentifiers['recurrence'] as $recurrenceIdentifier) {
                $calendarQuery = "calendar[" . $recurrenceIdentifier . "] = [$start,$end]";
                $queryObject = $builder->instanceQuery($calendarQuery);
                $calendarQuery = $queryObject->convert();
                $calendarFilter[] = $calendarQuery->getArrayCopy()['Filter'];
            }
            foreach ($timedAttributesIdentifiers['opening_hours'] as $openingHoursIdentifier) {
                $calendarQuery = "calendar[{$openingHoursIdentifier}." . self::OPENING_HOURS_FROM_IDENTIFIER . ",{$openingHoursIdentifier}." . self::OPENING_HOURS_TO_IDENTIFIER . "] = [$start,$end]";
                $queryObject = $builder->instanceQuery($calendarQuery);
                $calendarQuery = $queryObject->convert();
                $calendarFilter[] = $calendarQuery->getArrayCopy()['Filter'];
            }
        }

        if (count($calendarFilter) > 1) {
            array_unshift($calendarFilter, 'or');
        }

        return $calendarFilter;
    }
}
