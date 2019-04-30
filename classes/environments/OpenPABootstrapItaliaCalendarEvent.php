<?php

/**
 * Class OpenPABootstrapItaliaCalendarEvent
 * @see https://fullcalendar.io/docs/event_data/Event_Object/
 */
class OpenPABootstrapItaliaCalendarEvent implements JsonSerializable
{
    private $content;

    private $id;

    private $title;

    private $allDay;

    private $start;

    private $end;

    private $url;

    private $className;

    private $editable;

    private $startEditable;

    private $durationEditable;

    private $resourceEditable;

    private $rendering;

    private $overlap;

    private $constraint;

    private $color;

    private $backgroundColor;

    private $borderColor;

    private $textColor;

    private $type;

    /**
     * @param mixed $content
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setContent($content)
    {
        $this->content = $content;

        return $this;
    }

    /**
     * @param mixed $id
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setId($id)
    {
        $this->id = $id;

        return $this;
    }

    /**
     * @param mixed $title
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setTitle($title)
    {
        $this->title = $title;

        return $this;
    }

    /**
     * @param mixed $allDay
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setAllDay($allDay)
    {
        $this->allDay = $allDay;

        return $this;
    }

    /**
     * @param mixed $start
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setStart($start)
    {
        $this->start = $start;

        return $this;
    }

    /**
     * @param mixed $end
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setEnd($end)
    {
        $this->end = $end;

        return $this;
    }

    /**
     * @param mixed $url
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setUrl($url)
    {
        $this->url = $url;

        return $this;
    }

    /**
     * @param mixed $className
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setClassName($className)
    {
        $this->className = $className;

        return $this;
    }

    /**
     * @param mixed $editable
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setEditable($editable)
    {
        $this->editable = $editable;

        return $this;
    }

    /**
     * @param mixed $startEditable
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setStartEditable($startEditable)
    {
        $this->startEditable = $startEditable;

        return $this;
    }

    /**
     * @param mixed $durationEditable
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setDurationEditable($durationEditable)
    {
        $this->durationEditable = $durationEditable;

        return $this;
    }

    /**
     * @param mixed $resourceEditable
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setResourceEditable($resourceEditable)
    {
        $this->resourceEditable = $resourceEditable;

        return $this;
    }

    /**
     * @param mixed $rendering
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setRendering($rendering)
    {
        $this->rendering = $rendering;

        return $this;
    }

    /**
     * @param mixed $overlap
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setOverlap($overlap)
    {
        $this->overlap = $overlap;

        return $this;
    }

    /**
     * @param mixed $constraint
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setConstraint($constraint)
    {
        $this->constraint = $constraint;

        return $this;
    }

    /**
     * @param mixed $color
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setColor($color)
    {
        $this->color = $color;

        return $this;
    }

    /**
     * @param mixed $backgroundColor
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setBackgroundColor($backgroundColor)
    {
        $this->backgroundColor = $backgroundColor;

        return $this;
    }

    /**
     * @param mixed $borderColor
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setBorderColor($borderColor)
    {
        $this->borderColor = $borderColor;

        return $this;
    }

    /**
     * @param mixed $textColor
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setTextColor($textColor)
    {
        $this->textColor = $textColor;

        return $this;
    }

    /**
     * @param mixed $color
     *
     * @return OpenPABootstrapItaliaCalendarEvent
     */
    public function setType($type)
    {
        $this->type = $type;

        return $this;
    }

    function jsonSerialize()
    {
        $data = array();
        try {
            $reflection = new ReflectionClass($this);
            foreach ($reflection->getProperties() as $property) {
                $name = $property->getName();
                $value = $this->{$name};
                if ($value !== null) {
                    $data[$name] = $value;
                }
            }
        } catch (Exception $e) {

        }

        return $data;
    }
}
