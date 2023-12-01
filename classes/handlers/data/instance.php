<?php

class DataHandlerInstance implements OpenPADataHandlerInterface
{
    public function __construct(array $Params)
    {
    }

    public function getData()
    {
        return [
            'identifier' => OpenPABase::getCurrentSiteaccessIdentifier(),
            'name' => eZINI::instance()->variable('SiteSettings', 'SiteName'),
            'domain' => eZINI::instance()->variable('SiteSettings', 'SiteURL'),
        ];
    }

}

