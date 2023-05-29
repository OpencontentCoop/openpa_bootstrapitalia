<?php

class PersonalAreaLogin
{
    private static $instance = [];

    /**
     * @var string
     */
    private $uri;

    public static function instance()
    {
        $locale = eZLocale::currentLocaleCode();
        if (!isset(self::$instance[$locale])) {
            self::$instance[$locale] = new PersonalAreaLogin();
        }

        return self::$instance[$locale];
    }

    public function getUri(): ?string
    {
        if ($this->uri === null) {
            $this->discoverUri();
        }

        return $this->uri;
    }

    public function setUri(?string $uri)
    {
        $this->uri = $uri;
    }

    private function discoverUri()
    {
        $pagedata = new \OpenPAPageData();
        $contacts = $pagedata->getContactsData();
        $this->setUri($contacts['link_area_personale'] ?? false);
    }
}