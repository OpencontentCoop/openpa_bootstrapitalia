<?php

class ModerationMessage
{
    const TYPE_CREATED = 'ocmoderation_created';

    const TYPE_APPROVED = 'ocmoderation_approved';

    const TYPE_REJECTED = 'ocmoderation_rejected';

    const TYPE_ARCHIVED = 'ocmoderation_archived';

    const TYPE_COMMENT = 'ocmoderation_comment';

    public $id;

    public $creatorId;

    public $approvalId;

    public $contentObjectId;

    public $text;

    public $type;

    public $createdAt;

    public $archivedByVersion;

    private $attributes = [];

    public static function createAuditOnCreated(ModerationApproval $approval)
    {
        self::create($approval->id, $approval->contentObjectId, self::TYPE_CREATED);
    }

    public static function createAuditOnApproved(ModerationApproval $approval)
    {
        self::create($approval->id, $approval->contentObjectId, self::TYPE_APPROVED);
    }

    public static function createAuditOnRejected(ModerationApproval $approval)
    {
        self::create($approval->id, $approval->contentObjectId, self::TYPE_REJECTED);
    }

    public static function createAuditOnArchived(ModerationApproval $approval, int $archivedByVersion)
    {
        self::create($approval->id, $approval->contentObjectId, self::TYPE_ARCHIVED, $archivedByVersion);
    }

    public static function createComment(ModerationApproval $approval, string $text)
    {
        if (!empty($text)) {
            self::create($approval->id, $approval->contentObjectId, self::TYPE_COMMENT, null, $text);
        }
    }

    private static function create($approvalId, $contentObjectId, $type, $archivedByVersion = null, $text = null)
    {
        $now = time();
        $message = new eZCollaborationSimpleMessage([
            'message_type' => $type,
            'data_int1' => $approvalId,
            'data_int2' => $archivedByVersion,
            'data_int3' => $contentObjectId,
            'data_text1' => $text,
            'creator_id' => eZUser::currentUser()->id(),
            'created' => $now,
            'modified' => $now,
        ]);
        $message->store();
    }

    public static function fetchByApprovalId(int $approvalId): array
    {
        $rows = eZPersistentObject::fetchObjectList(
            eZCollaborationSimpleMessage::definition(), null, [
            'data_int1' => $approvalId,
            'message_type' => [
                [
                    self::TYPE_CREATED,
                    self::TYPE_APPROVED,
                    self::TYPE_REJECTED,
                    self::TYPE_ARCHIVED,
                    self::TYPE_COMMENT,
                ],
            ],
        ], ['created' => 'asc']
        );

        $items = [];
        foreach ($rows as $row) {
            $item = new ModerationMessage();
            $item->id = (int)$row->attribute('id');
            $item->creatorId = (int)$row->attribute('creator_id');
            $item->contentObjectId = (int)$row->attribute('data_int3');
            $item->approvalId = (int)$row->attribute('data_int1');
            $item->archivedByVersion = (int)$row->attribute('data_int2');
            $item->createdAt = (int)$row->attribute('created');
            $item->type = $row->attribute('message_type');
            $item->text = $row->attribute('data_text1');
            $items[] = $item;
        }

        return $items;
    }

    public static function fetchCountByApprovalId(int $approvalId, array $types = null): int
    {
        return eZPersistentObject::count(
            eZCollaborationSimpleMessage::definition(), [
                'data_int1' => $approvalId,
                'message_type' => [
                    $types ??
                    [
                        self::TYPE_CREATED,
                        self::TYPE_APPROVED,
                        self::TYPE_REJECTED,
                        self::TYPE_ARCHIVED,
                        self::TYPE_COMMENT,
                    ],
                ],
            ]
        );
    }

    public function attributes(): array
    {
        $vars = array_keys(get_object_vars($this));
        $vars[] = 'creator';
        $vars[] = 'is_creator';

        return $vars;
    }

    public function hasAttribute($key): bool
    {
        return in_array($key, $this->attributes());
    }

    public function attribute($key)
    {
        if (property_exists($this, $key)) {
            return $this->$key;
        }

        if (!isset($this->attributes[$key])) {
            switch ($key) {
                case 'creator':
                    $this->attributes[$key] = eZUser::fetch($this->creatorId);
                    break;
                case 'is_creator':
                    $this->attributes[$key] = $this->creatorId == eZUser::currentUserID();
                    break;
                default:
                    eZDebug::writeNotice("Attribute $key does not exist", get_called_class());
                    $this->attributes[$key] = false;
            }
        }

        return $this->attributes[$key];
    }

    public static function unreadApprovalCount(): int
    {
        $user = eZUser::currentUser();
        $userId = (int)$user->id();
        if (ModerationHandler::userNeedModeration($user)) {
            $rows = eZDB::instance()->arrayQuery(
                "select count(distinct(ezcollab_item.id)) as count from ezcollab_simple_message 
                join ezcollab_item on(ezcollab_simple_message.data_int1 = ezcollab_item.id) 
                full join ezcollab_item_status on(ezcollab_simple_message.data_int1 = ezcollab_item_status.collaboration_id) 
                where ezcollab_simple_message.creator_id != $userId
                and ezcollab_item.creator_id = $userId
                and ezcollab_item_status.user_id = $userId
                and ezcollab_simple_message.created > COALESCE(ezcollab_item_status.last_read, 0)
                and ezcollab_simple_message.message_type in ('ocmoderation_approved', 'ocmoderation_rejected', 'ocmoderation_archived', 'ocmoderation_comment')"
            );
        } else {
            $rows = eZDB::instance()->arrayQuery(
                "select count(distinct(ezcollab_item.id)) as count from ezcollab_simple_message
                join ezcollab_item on(ezcollab_simple_message.data_int1 = ezcollab_item.id) 
                full join ezcollab_item_status on(ezcollab_simple_message.data_int1 = ezcollab_item_status.collaboration_id) 
                where ezcollab_item_status.user_id = 0
                and ezcollab_simple_message.created > COALESCE(ezcollab_item_status.last_read, 0)
                and ezcollab_simple_message.message_type in ('ocmoderation_comment')"
            );
        }

        return (int)$rows[0]['count'];
    }

    public static function unreadApprovalIdQuery(): string
    {
        $user = eZUser::currentUser();
        $userId = (int)$user->id();
        if (ModerationHandler::userNeedModeration($user)) {
            return "select distinct(ezcollab_item.id) from ezcollab_simple_message 
              join ezcollab_item on(ezcollab_simple_message.data_int1 = ezcollab_item.id) 
              full join ezcollab_item_status on(ezcollab_simple_message.data_int1 = ezcollab_item_status.collaboration_id) 
              where 
              ezcollab_simple_message.creator_id != $userId
              and ezcollab_item.creator_id = $userId
              and ezcollab_item_status.user_id = $userId
              and ezcollab_simple_message.created > COALESCE(ezcollab_item_status.last_read, 0)
              and ezcollab_simple_message.message_type in ('ocmoderation_approved', 'ocmoderation_rejected', 'ocmoderation_archived', 'ocmoderation_comment')";
        } else {
            return "select distinct(ezcollab_item.id) from ezcollab_simple_message 
              join ezcollab_item on(ezcollab_simple_message.data_int1 = ezcollab_item.id) 
              full join ezcollab_item_status on(ezcollab_simple_message.data_int1 = ezcollab_item_status.collaboration_id) 
              where 
              ezcollab_item_status.user_id = 0
              and ezcollab_simple_message.created > COALESCE(ezcollab_item_status.last_read, 0)
              and ezcollab_simple_message.message_type in ('ocmoderation_comment')";
        }
    }
}