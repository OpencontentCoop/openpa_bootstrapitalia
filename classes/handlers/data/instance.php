<?php

class DataHandlerInstance implements OpenPADataHandlerInterface
{
    public function __construct(array $Params)
    {
    }

    public function getData()
    {
        $versionRows = eZDB::instance()->arrayQuery("SELECT * FROM ezsite_data WHERE name like 'ocinstaller_version'");
        return [
            'identifier' => OpenPABase::getCurrentSiteaccessIdentifier(),
            'name' => eZINI::instance()->variable('SiteSettings', 'SiteName'),
            'domain' => eZINI::instance()->variable('SiteSettings', 'SiteURL'),
            'version' => $versionRows[0]['value'] ?? 0,
        ];
    }

}

