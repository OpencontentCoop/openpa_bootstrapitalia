<?php

use Opencontent\Opendata\Api\Values\Content;

class InternalWebhook implements ezfIndexPlugin
{
    public function modify(eZContentObject $contentObject, &$docList)
    {
        try {
            $client = new RemoteIndexClient();
            $client->add($contentObject);
        }catch (Throwable $t) {
            eZDebug::writeError($t->getMessage(), __METHOD__);
        }
    }

}