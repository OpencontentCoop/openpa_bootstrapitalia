<?php

class OpenpaBootstrapItaliaNewsRssHandler extends SubTreeRSSHandler
{
    public function __construct()
    {
        $newsContainer = eZContentObject::fetchByRemoteID('news');
        if (!$newsContainer instanceof eZContentObject || !$newsContainer->mainNodeID()) {
            throw new Exception("News container not found");
        }
        parent::__construct($newsContainer->mainNodeID(), ['article']);
    }


    function getFeedAccessUrl()
    {
        $url = '/feed/rss/news';
        eZURI::transformURI($url, false, 'full');

        return $url;
    }

    function cacheKey()
    {
        return 'rss-news';
    }

    public static function isEnabled()
    {
        $handlers = eZINI::instance('ocrss.ini')->group('Handlers');

        return isset($handlers['CustomHandlers']['news']) && eZContentObject::fetchByRemoteID('news');
    }
}