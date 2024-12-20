<?php

class BootstrapItaliaSolrTools
{
    public static function sendPatch(int $objectId, array $languages, array $data): void
    {
        $solr = new eZSolr();
        $collectedData = [];
        foreach ($languages as $languageCode) {
            $collectedData[$languageCode] = [
                'meta_guid_ms' => $solr->guid($objectId, $languageCode),
            ];
            foreach ($data as $key => $value) {
                $collectedData[$languageCode][$key] = [
                    'set' => $value,
                ];
            }
        }

        $postData = json_encode(array_values($collectedData));

        $solrBase = new \eZSolrBase();
        $maxRetries = (int)\eZINI::instance('solr.ini')->variable('SolrBase', 'ProcessMaxRetries');
        \eZINI::instance('solr.ini')->setVariable('SolrBase', 'ProcessTimeout', 60);
        if ($maxRetries < 1) {
            $maxRetries = 1;
        }
        $commitParam = 'true';
        $tries = 0;
        while ($tries < $maxRetries) {
            try {
                $tries++;
                $solrBase->sendHTTPRequest(
                    $solrBase->SearchServerURI . '/update?commit=' . $commitParam,
                    $postData,
                    'application/json',
                    'OpenAgenda'
                );
                eZDebug::writeDebug('Patch object ' . $objectId, __METHOD__ . ' at retry ' . $tries);
                break;
            } catch (\ezfSolrException $e) {
                $doRetry = false;
                $errorMessage = $e->getMessage();
                switch ($e->getCode()) {
                    case \ezfSolrException::REQUEST_TIMEDOUT : // Code error 28. Server is most likely overloaded
                    case \ezfSolrException::CONNECTION_TIMEDOUT : // Code error 7, same thing
                        $errorMessage .= ' // Retry #' . $tries;
                        $doRetry = true;
                        break;
                }

                if (!$doRetry) {
                    break;
                }
                eZDebug::writeError($errorMessage, __METHOD__ . ' at retry ' . $tries);
            }
        }
    }
}