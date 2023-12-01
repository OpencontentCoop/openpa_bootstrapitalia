<?php

trait SiteDataStorageTrait
{
    protected function getStorage($key)
    {
        $siteData = eZSiteData::fetchByName($key);
        if (!$siteData instanceof eZSiteData) {
            return false;
        }
        return $siteData->attribute('value');
    }

    protected function removeStorage($key)
    {
        $siteData = eZSiteData::fetchByName($key);
        if ($siteData instanceof eZSiteData) {
            $siteData->remove();
        }
    }

    protected function setStorage($key, $value)
    {
        $siteData = eZSiteData::fetchByName($key);
        if (!$siteData instanceof eZSiteData) {
            $siteData = eZSiteData::create($key, $value);
        }
        $siteData->setAttribute('value', $value);
        $siteData->store();
    }
}