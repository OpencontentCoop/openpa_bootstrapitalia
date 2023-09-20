<?php

class ezjscBridge extends ezjscServerFunctions
{
    static public function check($args)
    {
        $inSync = true;
        $remoteIsActive = $error = $remoteStatus = null;
        $serviceId = $args[0] ?? false;
        $serviceIdentifier = $args[1] ?? false;
        if (!empty($serviceId) && !empty($serviceIdentifier) && strlen($serviceIdentifier) < 100) {
            try {
                $serviceId = (int)$serviceId;
                if ($serviceId === 0) {
                    throw new Exception("Invalid local service id");
                }
                $localService = eZContentObject::fetch($serviceId);
                if (!$localService instanceof eZContentObject) {
                    throw new Exception("Local service $serviceId not found");
                }
                $remoteService = StanzaDelCittadinoBridge::factory()->getServiceByIdentifier($serviceIdentifier);
                $remoteStatus = $remoteService['status'];
                $remoteIsActive = (isset(StanzaDelCittadinoBridge::$mapServiceStatus[$remoteStatus])
                    && StanzaDelCittadinoBridge::$mapServiceStatus[$remoteStatus] == StanzaDelCittadinoBridge::$mapServiceStatus['active']);
                if (!$remoteIsActive && OpenPABootstrapItaliaOperators::isActivePublicService($localService)){
                    $inSync = false;
                }

            } catch (Throwable $e) {
                $error = $e->getMessage();
            }
        }

        return [
            'is_status_in_sync' => $inSync,
            'is_remote_status_active' => $remoteIsActive,
            'remote_status_value' => $remoteStatus,
            'remote_status_message' => StanzaDelCittadinoBridge::$mapServiceStatus[$remoteStatus] ?? null,
            'remote_base_url' => StanzaDelCittadinoBridge::factory()->getApiBaseUri(),
            'request_error' => $error,
        ];
    }
}