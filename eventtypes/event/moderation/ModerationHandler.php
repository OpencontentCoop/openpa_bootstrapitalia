<?php

class ModerationHandler
{
    const STATUS_PENDING = 0;

    const STATUS_ACCEPTED = 1;

    const STATUS_REFUSED = 2;

    /**
     * @var eZContentObjectVersion
     */
    private $version;

    /**
     * @var eZContentObject
     */
    private $object;

    /**
     * @var eZWorkflowProcess
     */
    private $process;

    /**
     * @var eZUser
     */
    private $user;

    private static $moderateGroupObjectId = 0;

    public function __construct(eZContentObject $object, eZContentObjectVersion $version, eZWorkflowProcess $process)
    {
        $this->object = $object;
        $this->version = $version;
        $this->process = $process;
        $this->user = eZUser::instance($this->process->attribute('user_id'));
    }

    private static function getModerationGroupObjectId(): ?int
    {
        if (self::$moderateGroupObjectId === 0) {
            $res = eZDB::instance()->arrayQuery(
                "SELECT ezcontentobject.id FROM ezcontentobject WHERE ezcontentobject.remote_id='moderation'"
            );
            self::$moderateGroupObjectId = $res[0]['id'] ?? null;
        }

        return self::$moderateGroupObjectId;
    }

    public static function isEnabled(): bool
    {
        return self::getModerationGroupObjectId() !== null;
    }

    public static function hasPendingApproval(int $objectId, string $locale): int
    {
        return self::isEnabled() ?
            ModerationApproval::fetchPendingCountByObjectIdAndLocale($objectId, $locale) : 0;
    }

    public static function hasChildPendingApproval(int $mainAssignmentId, string $locale): int
    {
        return self::isEnabled() ?
            ModerationApproval::fetchPendingCountByMainAssignmentIdAndLocale($mainAssignmentId, $locale) : 0;
    }

    public static function canApproveVersion(int $contentObjectVersionId): bool
    {
        $approval = ModerationApproval::fetchByContentObjectVersionId($contentObjectVersionId);

        return $approval instanceof ModerationApproval
            && $approval->attribute('can_edit')
            && $approval->status === self::STATUS_PENDING
            && $approval->processId > 0
            && !self::userNeedModeration(eZUser::currentUser())
            && $approval->authorId != eZUser::currentUserID();
    }

    public static function approveVersion(int $contentObjectVersionId): ModerationApproval
    {
        $approval = ModerationApproval::fetchByContentObjectVersionId($contentObjectVersionId);
        if (!$approval instanceof ModerationApproval) {
            throw new RuntimeException('Invalid approved version');
        }
        $approval->status = self::STATUS_ACCEPTED;
        ModerationApproval::updateStatus($approval);
        self::executeProcess($approval->processId);

        return $approval;
    }

    public static function denyVersion(int $contentObjectVersionId): ModerationApproval
    {
        $approval = ModerationApproval::fetchByContentObjectVersionId($contentObjectVersionId);
        if (!$approval instanceof ModerationApproval) {
            throw new RuntimeException('Invalid approved version');
        }
        $approval->status = self::STATUS_REFUSED;
        ModerationApproval::updateStatus($approval);
        self::executeProcess($approval->processId);

        return $approval;
    }

    private static function executeProcess(int $processId)
    {
        $db = eZDB::instance();

        /** @var eZWorkflowProcess $process */
        $process = eZWorkflowProcess::fetch($processId);
        if (!$process instanceof eZWorkflowProcess) {
            throw new RuntimeException('Invalid process ID');
        }
        $db->begin();

        $workflow = eZWorkflow::fetch($process->attribute("workflow_id"));

        if ($process->attribute("event_id") != 0) {
            $workflowEvent = eZWorkflowEvent::fetch($process->attribute("event_id"));
        }
        $process->run($workflow, $workflowEvent, $eventLog);

        if ($process->attribute('status') != eZWorkflow::STATUS_DONE) {
            if ($process->attribute('status') == eZWorkflow::STATUS_RESET ||
                $process->attribute('status') == eZWorkflow::STATUS_FAILED ||
                $process->attribute('status') == eZWorkflow::STATUS_NONE ||
                $process->attribute('status') == eZWorkflow::STATUS_CANCELLED ||
                $process->attribute('status') == eZWorkflow::STATUS_BUSY
            ) {
                if ($bodyMemento = eZOperationMemento::fetchMain($process->attribute('memento_key'))) {
                    $bodyMemento->remove();
                }
                foreach (eZOperationMemento::fetchList($process->attribute('memento_key')) as $memento) {
                    $memento->remove();
                }
            }

            if ($process->attribute('status') == eZWorkflow::STATUS_CANCELLED) {
                $process->removeThis();
            } else {
                $process->store();
            }
        } else {
            /** @var eZOperationMemento $bodyMemento */
            $bodyMemento = eZOperationMemento::fetchChild($process->attribute('memento_key'));
            if ($bodyMemento === null) {
                eZDebug::writeError($bodyMemento, "Empty body memento " . __METHOD__);
                $db->commit();
                return;
            }
            $mainMemento = $bodyMemento->attribute('main_memento');
            if (!$mainMemento) {
                $db->commit();
                return;
            }

            $mementoData = $bodyMemento->data();
            $mementoData['main_memento'] = $mainMemento;
            $mementoData['skip_trigger'] = true;
            $mementoData['memento_key'] = $process->attribute('memento_key');
            $bodyMemento->remove();
            $operationParameters = [];
            if (isset($mementoData['parameters'])) {
                $operationParameters = $mementoData['parameters'];
            }
            eZOperationHandler::execute(
                $mementoData['module_name'],
                $mementoData['operation_name'],
                $operationParameters,
                $mementoData
            );
            $process->removeThis();
        }

        $db->commit();
    }

    public function needModeration(): bool
    {
        return $this->currentUserNeedModeration()
            && $this->currentContentNeedModeration();
    }

    public function currentUserNeedModeration(): bool
    {
        return self::userNeedModeration($this->user);
    }

    public static function userNeedModeration(eZUser $user): bool
    {
        $isAdmin = $user->hasAccessTo('*', '*')['accessWord'] == 'yes';
        if (self::isEnabled()) {
            return in_array(self::getModerationGroupObjectId(), $user->groups()) && !$isAdmin;
        }
        return false;
    }

    public function currentContentNeedModeration(): bool
    {
        return in_array(
            $this->object->attribute('class_identifier'),
            OpenPAINI::variable('Moderation', 'Classes', [
                'article',
                'document',
                'place',
                'public_service',
                'event',
            ])
        );
    }

    public function checkModerationStatus(): int
    {
        $approval = $this->getApproval() ?? $this->createApproval();
        return $approval->status;
    }

    public function cleanup()
    {
        ModerationApproval::cleanByContentObjectIdAndVersion(
            (int)$this->object->attribute('id'),
            (int)$this->version->attribute('id'),
            (string)$this->version->initialLanguageCode()
        );
    }

    private function getApproval(): ?ModerationApproval
    {
        return ModerationApproval::fetchByProcessId((int)$this->process->attribute('id'));
    }

    private function createApproval(): ModerationApproval
    {
        $approval = new ModerationApproval;
        $approval->contentObjectId = (int)$this->version->attribute('contentobject_id');
        $approval->contentObjectVersionId = (int)$this->version->attribute('id');
        $approval->contentObjectVersionLanguage = (string)$this->version->initialLanguageCode();
        $approval->status = self::STATUS_PENDING;
        $approval->classIdentifier = $this->object->attribute('class_identifier');
        $approval->title = $this->version->attribute('name');
        $approval->createdAt = (int)$this->version->attribute('created');
        $approval->authorId = (int)$this->user->id();
        $approval->processId = (int)$this->process->attribute('id');
        $approval->mainAssignmentId = (int)$this->version->mainParentNodeID();
        ModerationApproval::store($approval);

        return $approval;
    }

    private function deleteApproval(): void
    {
        ModerationApproval::deleteByProcessId((int)$this->process->attribute('id'));
    }
}