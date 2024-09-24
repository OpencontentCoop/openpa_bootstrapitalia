<?php

class ModerationHandler
{
    const STATUS_PENDING = 0;

    const STATUS_ACCEPTED = 1;

    const STATUS_REFUSED = 2;

    const STATUS_UNREAD = 100;

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

    private static $storage;

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
        return boolval(self::getStorage()->attribute('value')) && self::getModerationGroupObjectId() !== null;
    }

    public static function setIsEnabled(bool $isEnabled): void
    {
        self::getStorage()->setAttribute('value', (int)$isEnabled);
        self::getStorage()->store();
        if (!$isEnabled){
            $moderationGroup = eZContentObject::fetch(self::getModerationGroupObjectId());
            if ($moderationGroup instanceof eZContentObject){
                $moderationGroupNode = $moderationGroup->mainNode();
                if ($moderationGroupNode instanceof eZContentObjectTreeNode){
                    $removeList = [];
                    foreach ($moderationGroupNode->children() as $node){
                        $removeList[] = $node->attribute('node_id');
                    }
                    if (count($removeList)) {
                        eZContentOperationCollection::removeNodes($removeList);
                    }
                }
            }
        }
    }

    private static function getStorage(): eZSiteData
    {
        if (self::$storage === null) {
            self::$storage = eZSiteData::fetchByName('bootstrapitalia_approval');
            if (!self::$storage instanceof eZSiteData) {
                self::$storage = eZSiteData::create('bootstrapitalia_approval', 0);
            }
        }
        return self::$storage;
    }

    public static function hasPendingApproval(int $objectId, string $locale, bool $onlyForCurrentUser = false): int
    {
        return self::isEnabled() ?
            ModerationApproval::fetchPendingCountByObjectIdAndLocale($objectId, $locale, $onlyForCurrentUser) : 0;
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
            && eZWorkflowProcess::fetch($approval->processId) instanceof eZWorkflowProcess
            && !self::userNeedModeration(eZUser::currentUser())
            && $approval->authorId != eZUser::currentUserID();
    }

    public static function approveVersion(int $contentObjectVersionId): ModerationApproval
    {
        $approval = ModerationApproval::fetchByContentObjectVersionId($contentObjectVersionId);
        if (!$approval instanceof ModerationApproval) {
            throw new RuntimeException('Invalid approved version');
        }
        /** @var eZWorkflowProcess $process */
        $process = eZWorkflowProcess::fetch($approval->processId);
        if (!$process instanceof eZWorkflowProcess) {
            throw new RuntimeException('Invalid process ID');
        }
        $approval->fixContingentRelations();
        $approval->status = self::STATUS_ACCEPTED;
        ModerationApproval::updateStatus($approval);
        self::executeProcess($approval->processId);

        ModerationMessage::createAuditOnApproved($approval);

        return $approval;
    }

    public static function canDiscardVersion(int $contentObjectVersionId): bool
    {
        $approval = ModerationApproval::fetchByContentObjectVersionId($contentObjectVersionId);

        return $approval instanceof ModerationApproval
            && $approval->attribute('is_author')
            && $approval->status === self::STATUS_PENDING;
    }

    public static function discardVersion(int $contentObjectVersionId): ModerationApproval
    {
        $approval = ModerationApproval::fetchByContentObjectVersionId($contentObjectVersionId);
        if ($approval instanceof ModerationApproval) {
            $currentObject = $approval->attribute('object');

            if ($currentObject instanceof eZContentObject) {
                if ($currentObject->attribute('status') == eZContentObject::STATUS_DRAFT){
                    $version = eZContentObjectVersion::fetch($contentObjectVersionId);
                    if ($version instanceof eZContentObjectVersion) {
                        $db = eZDB::instance();
                        $db->begin();
                        $version->removeThis();
                        ModerationApproval::cleanup();
                        $db->commit();
                    }
                } else {
                    $currentVersion = $currentObject->attribute('current');
                    if ($currentVersion instanceof eZContentObjectVersion) {
                        ModerationApproval::cleanByContentObjectIdAndVersion(
                            (int)$currentObject->attribute('id'),
                            (int)$currentVersion->attribute('id'),
                            $currentVersion->initialLanguageCode(),
                            (int)eZUser::currentUserID(),
                            true
                        );
                    }
                }
            }
        }


        return $approval;
    }

    public static function denyVersion(int $contentObjectVersionId): ModerationApproval
    {
        $approval = ModerationApproval::fetchByContentObjectVersionId($contentObjectVersionId);
        if (!$approval instanceof ModerationApproval) {
            throw new RuntimeException('Invalid approved version');
        }
        /** @var eZWorkflowProcess $process */
        $process = eZWorkflowProcess::fetch($approval->processId);
        if (!$process instanceof eZWorkflowProcess) {
            throw new RuntimeException('Invalid process ID');
        }
        $approval->status = self::STATUS_REFUSED;
        ModerationApproval::updateStatus($approval);
        self::executeProcess($approval->processId);

        ModerationMessage::createAuditOnRejected($approval);
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
        return self::isEnabled()
            && self::userNeedModeration($this->user)
            && self::classNeedModeration($this->object->attribute('class_identifier'));
    }

    public static function userNeedModeration(eZUser $user): bool
    {
        $isAdmin = $user->hasAccessTo('*', '*')['accessWord'] == 'yes';
        if (self::isEnabled()) {
            return in_array(self::getModerationGroupObjectId(), $user->groups()) && !$isAdmin;
        }
        return false;
    }

    public static function classNeedModeration(string $classIdentifier): bool
    {
        return in_array(
            $classIdentifier,
            [
                'article',
                'document',
                'place',
                'public_service',
                'event',
            ]
        );
    }

    public static function getUserGroupsConstraintRemoteIdList(): array
    {
        return [
            'editors_vivere_il_comune',
            'editors_novita',
            'editors_servizi',
        ];
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
        ModerationApproval::cleanup();
    }

    public function cleanupPendingByOwner()
    {
        ModerationApproval::cleanByContentObjectIdAndVersion(
            (int)$this->object->attribute('id'),
            (int)$this->version->attribute('id'),
            (string)$this->version->initialLanguageCode(),
            (int)$this->user->id()
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
        $approval->authorId = (int)$this->user->id();
        $approval->processId = (int)$this->process->attribute('id');
        $approval->mainAssignmentId = (int)$this->version->mainParentNodeID();

        $approval = ModerationApproval::create($approval);
        ModerationMessage::createAuditOnCreated($approval);

        (new eZCollaborationItemStatus([
            'collaboration_id' => $approval->id,
            'user_id' => $approval->authorId,
            'last_read' => 0,
        ]))->store();
        (new eZCollaborationItemStatus([
            'collaboration_id' => $approval->id,
            'user_id' => 0,
            'last_read' => 0,
        ]))->store();

        return $approval;
    }

    private function deleteApproval(): void
    {
        ModerationApproval::deleteByProcessId((int)$this->process->attribute('id'));
    }

    public static function setLastRead(ModerationApproval $approval): void
    {
        $timestamp = time();
        eZPersistentObject::updateObjectList([
            'definition' => eZCollaborationItemStatus::definition(),
            'update_fields' => ['last_read' => $timestamp],
            'conditions' => [
                'collaboration_id' => $approval->id,
                'user_id' => $approval->attribute('is_author') ? eZUser::currentUserID() : 0,
            ],
        ]);
    }
}