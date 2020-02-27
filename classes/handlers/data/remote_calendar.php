<?php

class DataHandlerRemoteCalendar implements OpenPADataHandlerInterface
{
    private $remote;

    private $baseRemoteUrl;

    private $start;

    private $end;

    public function __construct(array $Params)
    {
        $this->baseRemoteUrl = rtrim(eZHTTPTool::instance()->getVariable('url', null));
        $this->remote = $this->fixUrl(eZHTTPTool::instance()->getVariable('remote', null));
        $now = time();
        $this->start = $this->fixDate(eZHTTPTool::instance()->getVariable('start', date('c', $now)));
        $this->end = $this->fixDate(eZHTTPTool::instance()->getVariable('end', date('c', $now + 86400)));
    }

    private function fixUrl($url)
    {
        $parts = parse_url($url);
        if (isset($parts['query'])) {
            parse_str($parts['query'], $query);
            $cleanQuery = [];
            foreach ($query as $key => $value) {
                $cleanQuery[$key] = trim(urlencode($value));
            }
            $parts['query'] = http_build_query($cleanQuery);
        }

        return $this->unparse_url($parts);
    }

    private function unparse_url($parsed_url)
    {
        $scheme = isset($parsed_url['scheme']) ? $parsed_url['scheme'] . '://' : '';
        $host = isset($parsed_url['host']) ? $parsed_url['host'] : '';
        $port = isset($parsed_url['port']) ? ':' . $parsed_url['port'] : '';
        $user = isset($parsed_url['user']) ? $parsed_url['user'] : '';
        $pass = isset($parsed_url['pass']) ? ':' . $parsed_url['pass'] : '';
        $pass = ($user || $pass) ? "$pass@" : '';
        $path = isset($parsed_url['path']) ? $parsed_url['path'] : '';
        $query = isset($parsed_url['query']) ? '?' . $parsed_url['query'] : '';
        $fragment = isset($parsed_url['fragment']) ? '#' . $parsed_url['fragment'] : '';

        if (empty($this->baseRemoteUrl)){
        	$this->baseRemoteUrl = "$scheme$user$pass$host$port";
        }

        return "$scheme$user$pass$host$port$path$query$fragment";
    }

    private function fixDate($date)
    {
        $parts = explode('+', $date);
        $date = $parts[0];
        $parts = explode(' ', $date);
        $date = $parts[0];

        return $date;
    }

    private function addLinkToData($data, $remoteUrl)
    {
        if (!is_array($data)) {
            return [
                'url' => $remoteUrl,
                'error' => 'Invalid data'
            ];
        }

        foreach ($data as $key => $value) {
            if (!isset($value['url'])) {
                $data[$key]['url'] = $this->baseRemoteUrl . '/openpa/object/' . $value['id'];
            }
        }

        return $data;
    }

    public function getData()
    {
        $remoteUrl = $this->remote . '&start=' . $this->start . '&end=' . $this->end;
        $remoteData = eZHTTPTool::getDataByURL($remoteUrl, false, $userAgent);

        if (strpos($remoteData, '{') !== 1) {
            return [
                'url' => $remoteUrl,
                'error' => $remoteData
            ];
        }

        $data = $this->addLinkToData(json_decode($remoteData, true), $remoteUrl);

        return $data;
    }
}
