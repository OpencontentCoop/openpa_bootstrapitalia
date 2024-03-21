<?php

class StanzaDelCittadinoClient
{
    private $apiEndPointBaseUrl;

    private $bearerToken;

    private $basicAuth;

    public static $connectionTimeout = 1;

    public static $processTimeout = 2;

    public function __construct(string $apiEndPointBaseUrl)
    {
        $this->apiEndPointBaseUrl = $apiEndPointBaseUrl;
    }

    public function getApiEndPointBaseUrl(): string
    {
        return $this->apiEndPointBaseUrl;
    }

    public function setApiEndPointBaseUrl(string $apiEndPointBaseUrl): StanzaDelCittadinoClient
    {
        $this->apiEndPointBaseUrl = $apiEndPointBaseUrl;

        return $this;
    }

    public function getBearerToken(string $username, string $password): string
    {
        if ($this->bearerToken === null){
            $reponse = $this->request('POST', '/api/auth', [
                'username' => $username,
                'password' => $password,
            ]);
            $this->bearerToken = $reponse['token'];
        }
        return $this->bearerToken;
    }

    public function setBearerToken(string $bearerToken): StanzaDelCittadinoClient
    {
        $this->bearerToken = $bearerToken;

        return $this;
    }

    public function getBasicAuth(): string
    {
        return $this->basicAuth;
    }

    public function setBasicAuth($basicAuth): StanzaDelCittadinoClient
    {
        $this->basicAuth = $basicAuth;

        return $this;
    }

    public function getTenantInfo()
    {
        return $this->request('GET', '/api/tenants/info');
    }

    public function getServiceList()
    {
        return $this->request('GET', '/api/services?_=' . time());
    }

    public function getCalendarList()
    {
        return $this->request('GET', '/api/calendars?_=' . time());
    }

    public function getCalendar(string $calendarId)
    {
        return $this->request('GET', '/api/calendars/' . $calendarId);
    }

    public function getCalendarOpeningHours(string $calendarId)
    {
        return $this->request('GET', '/api/calendars/' . $calendarId . '/opening-hours');
    }

    public function getCalendarsAvailabilities(array $calendarIdList, string $fromTime, string $toTime = null)
    {

        if ($toTime) {
            $query = http_build_query([
                'available' => 'true',
                'calendar_ids' => implode(',', $calendarIdList),
                'from_date' => $fromTime,
                'to_date' => $toTime,
            ]);
            return $this->request(
                'GET',
                "/api/availabilities?$query"
            );
        }else{
            $query = http_build_query([
                'available' => 'true',
                'calendar_ids' => implode(',', $calendarIdList),
            ]);

            return $this->request(
                'GET',
                "/api/availabilities/$fromTime?$query"
            );
        }
    }

    public function getService($id)
    {
        return $this->request('GET', '/api/services/' . $id);
    }

    public function getCategory($id)
    {
        return $this->request('GET', '/api/categories/' . $id);
    }

    public function getCategories()
    {
        return $this->request('GET', '/api/categories');
    }

    public function getServiceByIdentifier($identifier)
    {
        return $this->getService($identifier);
    }

    public function patchTenant($slug, $data)
    {
        return $this->request('PATCH', '/api/tenants/' . $slug, $data);
    }

    public function patchService($id, $data)
    {
        return $this->request('PATCH', '/api/services/' . $id, $data);
    }

    public function request($method, $path, $data = null)
    {
        $url = $this->apiEndPointBaseUrl . $path;
        eZDebug::writeDebug($method . ' ' . $url, __METHOD__);
        $headers = [
            "Cache-Control: no-cache"
        ];
        if ($this->bearerToken) {
            $headers[] = "Authorization: Bearer " . $this->bearerToken;
        }
        if ($this->basicAuth) {
            $headers[] = "Authorization: Basic " . $this->basicAuth;
        }
        $ch = curl_init();
        if ($method == "POST") {
            curl_setopt($ch, CURLOPT_POST, 1);
        } elseif ($method == "PATCH") {
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PATCH');
        } elseif ($method == "PUT") {
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PUT');
        } elseif ($method == "DELETE") {
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
        }
        if ($data !== null) {
            $data = json_encode($data);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
            $headers[] = 'Content-Type: application/json';
            $headers[] = 'Content-Length: ' . strlen($data);
        }
        curl_setopt($ch, CURLOPT_HEADER, 1);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, self::$connectionTimeout);
        curl_setopt($ch, CURLOPT_TIMEOUT, self::$processTimeout);
        curl_setopt($ch, CURLINFO_HEADER_OUT, true);

        $data = curl_exec($ch);

        if ($data === false) {
            $errorCode = curl_errno($ch) * -1;
            $errorMessage = curl_error($ch);
            curl_close($ch);
            throw new \Exception($errorMessage, $errorCode);
        }

        $info = curl_getinfo($ch);
        eZDebug::writeDebug($method . ' ' . $url . ' ' . $info['http_code'], __METHOD__);

        curl_close($ch);
        $headers = substr($data, 0, $info['header_size']);
        if ($info['download_content_length'] > 0) {
            $body = substr($data, -$info['download_content_length']);
        } else {
            $body = substr($data, $info['header_size']);
        }

        return $this->parseResponse($info, $headers, $body, $method . ' ' . $url);
    }

    protected function parseResponse($info, $headers, $body, $requestUrl)
    {
        $data = json_decode($body);
        if (isset( $data->error_message )) {
            $errorMessage = '';
            if (isset( $data->error_type )) {
                $errorMessage = $data->error_type . ': ';
            }
            $errorMessage .= $data->error_message;
            throw new \Exception($errorMessage . ' ' . json_encode($data));
        }

        if ($info['http_code'] == 401) {
            throw new \Exception("Authorization Required " . json_encode($data));
        }
        if ($info['http_code'] == 403) {
            throw new \Exception("Forbidden ". json_encode($data));
        }

        if (intval($info['http_code']) > 299) {
            throw new \Exception("$requestUrl: Reponse code is " .  $info['http_code'], $info['http_code'] . ' ' . json_encode($data));
        }

        return json_decode($body, true);
    }
}