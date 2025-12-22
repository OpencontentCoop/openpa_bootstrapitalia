<?php

use Opencontent\Opendata\Api\Values\Content;

class RemoteIndexType extends eZWorkflowEventType
{
    const WORKFLOW_TYPE_STRING = "remoteindex";

    public function __construct()
    {
        parent::__construct(RemoteIndexType::WORKFLOW_TYPE_STRING, 'Remote index');
        $this->setTriggerTypes([
            'content' => [
                'publish' => ['after'],
                'delete' => ['before'],
            ],
        ]);
    }

    public function execute($process, $event)
    {
        $parameters = $process->attribute('parameter_list');

        try {
            $client = new RemoteIndexClient();
            if ($parameters['trigger_name'] === 'pre_delete') {
                $nodeIdList = $parameters['node_id_list'];
                foreach ($nodeIdList as $nodeId) {
                    $object = eZContentObject::fetchByNodeID($nodeId);
                    if ($object instanceof eZContentObject) {
                        $client->remove($object);
                    }
                }
            } elseif ($parameters['trigger_name'] === 'post_publish') {
                $object = eZContentObject::fetch($parameters['object_id']);
                if ($object instanceof eZContentObject) {
                    $client->add($object);
                }
            }
        } catch (Throwable $t) {
            eZDebug::writeError($t->getMessage(), __METHOD__);
        }

        return eZWorkflowType::STATUS_ACCEPTED;
    }
}

eZWorkflowEventType::registerEventType(RemoteIndexType::WORKFLOW_TYPE_STRING, 'RemoteIndexType');
