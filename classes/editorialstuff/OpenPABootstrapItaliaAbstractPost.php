<?php

use Opencontent\Opendata\Api\Values\Content;

abstract class OpenPABootstrapItaliaAbstractPost extends OCEditorialStuffPostDefault
{
    protected function currentUserNeedModeration()
    {
        $configurations = $this->getFactory()->getConfiguration();
        $whiteListGroupRemoteId = isset($configurations['WhiteListGroupRemoteId']) ? $configurations['WhiteListGroupRemoteId'] : 'editors_base';
        $editorsBaseGroup = eZContentObject::fetchByRemoteID($whiteListGroupRemoteId);
        if ($editorsBaseGroup instanceof eZContentObject) {
            $currentUserGroups = eZUser::currentUser()->groups(false);
            if (in_array($editorsBaseGroup->attribute('id'), $currentUserGroups)){
                return false;
            }
        }

        return true;
    }

    protected function emitPostPublishWebhook()
    {
        if (!class_exists('OCWebHookEmitter')){
            return;
        }
        
        try {
            $object = eZContentObject::fetch($this->id());
            if ($object instanceof eZContentObject) {
                $content = Content::createFromEzContentObject($object);
                $currentEnvironment = new DefaultEnvironmentSettings();
                $parser = new ezpRestHttpRequestParser();
                $request = $parser->createRequest();
                $currentEnvironment->__set('request', $request);
                $payload = $currentEnvironment->filterContent($content);
                $payload['metadata']['baseUrl'] = eZSys::serverURL();

                OCWebHookEmitter::emit(
                    PostPublishWebHookTrigger::IDENTIFIER,
                    $payload,
                    OCWebHookQueue::defaultHandler()
                );
            }
        } catch (Exception $e) {
            eZLog::write(__METHOD__ . ': ' . $e->getMessage(), 'webhook.log');
        }
    }
}