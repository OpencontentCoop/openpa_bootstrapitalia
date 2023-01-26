<?php

class eZSDCSSOHandler
{
    public function handleSSOLogin()
    {
        if (eZHTTPTool::instance()->hasGetVariable('token')
            && !eZHTTPTool::instance()->hasSessionVariable('sso_user')) {
            $token = eZHTTPTool::instance()->getVariable('token');
        }
    }

    public static function getCurrentProfile()
    {
        return eZHTTPTool::instance()->hasSessionVariable('sso_user') ?
            eZHTTPTool::instance()->sessionVariable('sso_user') : null;
    }

    public static function getApiUrl()
    {
        $currentHost = eZSys::hostname();
        $pagedata = new OpenPAPageData();
        $contacts = $pagedata->getContactsData();
        if ($contacts['link_area_personale']) {
            $contactUrl = $contacts['link_area_personale'];
            $url = parse_url($contactUrl, PHP_URL_HOST);
            if ($url && str_replace('www.', 'servizi.', $currentHost) === $url) {
                return "https://{$contactUrl}/api/session-auth";
            }
        }

        return false;
    }
}