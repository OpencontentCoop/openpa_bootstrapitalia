<?php

class ModerationType extends eZWorkflowEventType
{
    const WORKFLOW_TYPE_STRING = "moderation";

    public function __construct()
    {
        parent::__construct(ModerationType::WORKFLOW_TYPE_STRING, 'Sistema di moderazione dei contenuti');
        $this->setTriggerTypes(['content' => ['publish' => ['before']]]);
    }

    public function execute($process, $event)
    {
        $parameters = $process->attribute('parameter_list');

        $objectId = (int)$parameters['object_id'];
        $object = eZContentObject::fetch($objectId);
        if (!$object instanceof eZContentObject) {
            return eZWorkflowType::STATUS_WORKFLOW_CANCELLED;
        }

        $versionId = (int)$parameters['version'];
        $version = $object->version($versionId);
        if (!$version instanceof eZContentObjectVersion) {
            return eZWorkflowType::STATUS_WORKFLOW_CANCELLED;
        }

        if ($process->attribute('status') == eZWorkflow::STATUS_DEFERRED_TO_CRON) {
            $nodeAssignmentList = $version->attribute('node_assignments');
            if (!empty($nodeAssignmentList)) {
                foreach ($nodeAssignmentList as $nodeAssignment) {
                    $parentNode = $nodeAssignment->getParentNode();
                    if ($parentNode === null) {
                        return eZWorkflowType::STATUS_WORKFLOW_CANCELLED;
                    }
                }
            }
        }

        /*
          If we run event first time we do not have user_id set in workflow process,
          so we take current user and store it in workflow process, so next time when we run event from cronjob we fetch
          user_id from there.
         */
        if ($process->attribute('user_id') == 0) {
            $process->setAttribute('user_id', eZUser::currentUser()->id());
        }

        $handler = new ModerationHandler($object, $version, $process);

        if ($handler->needModeration()) {
            $moderationStatus = $handler->checkModerationStatus();
            if ($moderationStatus === ModerationHandler::STATUS_PENDING) {
                $handler->cleanupPendingByOwner();
                return eZWorkflowType::STATUS_DEFERRED_TO_CRON_REPEAT;
            }

            if ($moderationStatus === ModerationHandler::STATUS_REFUSED) {
                return eZWorkflowType::STATUS_WORKFLOW_CANCELLED;
            }
        }

        $handler->cleanup();
        return eZWorkflowType::STATUS_ACCEPTED;
    }
}

eZWorkflowEventType::registerEventType(ModerationType::WORKFLOW_TYPE_STRING, 'ModerationType');
