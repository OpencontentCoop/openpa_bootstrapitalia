<?php

class RemoteIndexClient
{
    /**
     * @var string
     */
    private $remoteUrl;

    private $headers;

    /**
     * @var int
     */
    private $connectionTimeout;

    /**
     * @var int
     */
    private $processTimeout;

    public function __construct()
    {
        $isEnabled = OpenPAINI::variable('RemoteIndexSettings', 'EnableRemoteIndex', 'disabled') === 'enabled';
        if ($isEnabled) {
            $this->remoteUrl = OpenPAINI::variable('RemoteIndexSettings', 'EndpointUrl');
            $this->connectionTimeout = OpenPAINI::variable('RemoteIndexSettings','ConnectionTimeout', 1);
            $this->processTimeout = OpenPAINI::variable('RemoteIndexSettings','ProcessTimeout', 1);
            $this->headers = OpenPAINI::variable('RemoteIndexSettings', 'Headers', []);
        }
    }

    public function add(eZContentObject $object)
    {
        if (!empty($this->remoteUrl)) {
            $this->buildPayloadAndSend($object, false);
        }
    }

    public function remove(eZContentObject $object)
    {
        if (!empty($this->remoteUrl)) {
            $this->buildPayloadAndSend($object, true);
        }
    }

    private function buildPayloadAndSend(eZContentObject $object, $isDeletion)
    {
        $currentVersion = $object->currentVersion();
        $availableLanguages = $currentVersion->translationList(false, false);
        foreach ($availableLanguages as $languageCode) {
            $this->sendData($this->generatePayload($object, $isDeletion, $languageCode));
        }
    }

    private function generatePayload(eZContentObject $object, bool $isDeletion, string $languageCode): array
    {
        $event = $isDeletion ? RemoteIndexContentBuilder::DELETE : RemoteIndexContentBuilder::UPDATE;
        $builder = new RemoteIndexContentBuilder($event, $object, $languageCode);
        return $builder->build();
    }

    private function sendData(array $data)
    {
        $headers = $this->headers;
        $dataEncoded = json_encode($data);
        $headers[] = 'Content-Type: application/json';
        $headers[] = 'Content-Length: ' . strlen($dataEncoded);

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $dataEncoded);
        curl_setopt($ch, CURLOPT_HEADER, 1);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_URL, $this->remoteUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $this->connectionTimeout);
        curl_setopt($ch, CURLOPT_TIMEOUT, $this->processTimeout);
        curl_setopt($ch, CURLINFO_HEADER_OUT, true);

        $data = curl_exec($ch);

        if ($data === false) {
            $errorCode = curl_errno($ch) * -1;
            $errorMessage = curl_error($ch);
            curl_close($ch);
            eZDebug::writeError("Curl error $errorCode: $errorMessage $dataEncoded", __METHOD__);
        }

        $info = curl_getinfo($ch);
        curl_close($ch);
        if ((int)$info['http_code'] > 399) {
            eZDebug::writeError("Error with status code: $info[http_code] $dataEncoded", __METHOD__);
        }
    }
}