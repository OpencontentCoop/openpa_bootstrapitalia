<?php

class ModerationApprovalCollection
{
    public $object_id;

    public $count = 0;

    /**
     * @var ModerationApproval[]
     */
    public $items = [];

    public $latest = 0;

    /**
     * @var ModerationApprovalQueue[]
     */
    public $queues;

    private $attributes = [];

    public static function fetchByContentObjectId(int $contentObjectId): ModerationApprovalCollection
    {
        $filters = [
            'object_id' => $contentObjectId,
        ];
        $user = eZUser::currentUser();
        $userId = (int)$user->id();
        if (ModerationHandler::userNeedModeration($user)) {
            $filters['creator'] = $userId;
        }
        $list = ModerationApproval::fetchList(1, 0, $filters);

        if (isset($list[0])) {
            $list[0]->getQueues();
            return $list[0];
        }

        $collection = new ModerationApprovalCollection();
        $collection->object_id = $contentObjectId;
        $collection->latest = time();

        return $collection;
    }

    public function setItems(array $items): void
    {
        $this->items = $items;
        $this->getQueues();
    }

    public function setLastRead(): void
    {
        $collaborationIdList = array_column(
            eZDB::instance()->arrayQuery(
                "select ezcollab_item.id from ezcollab_item where ezcollab_item.type_identifier = 'ocmoderation' 
            and ezcollab_item.data_int1 = $this->object_id"
            ),
            'id'
        );
        $timestamp = time();
        if (count($collaborationIdList)) {
            $user = eZUser::currentUser();
            $userId = (int)$user->id();
            eZPersistentObject::updateObjectList([
                'definition' => eZCollaborationItemStatus::definition(),
                'update_fields' => ['last_read' => $timestamp],
                'conditions' => [
                    'collaboration_id' => $collaborationIdList,
                    'user_id' => ModerationHandler::userNeedModeration($user) ? $userId : 0,
                ],
            ]);
        }
    }

    public function attributes(): array
    {
        $vars = array_keys(get_object_vars($this));
        $vars[] = 'queues';
        $vars[] = 'timeline';

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
                case 'queues':
                    $this->attributes[$key] = $this->queues;
                    break;
                case 'timeline':
                    $this->attributes[$key] = [];
                    foreach ($this->items as $item) {
                        foreach ($item->attribute('history') as $message){
                            if ($message->type !== ModerationMessage::TYPE_COMMENT){
                                $this->attributes[$key][] = $message;
                            }
                        }
                    }
                    usort($this->attributes[$key], function ($a, $b) {
                        return $a->createdAt > $b->createdAt ? 1 : -1;
                    });
                    break;
                default:
                    eZDebug::writeNotice("Attribute $key does not exist", get_called_class());
                    $this->attributes[$key] = false;
            }
        }

        return $this->attributes[$key];
    }

    private function getQueues()
    {
        if (!is_array($this->queues)) {
            $this->queues = [];
            foreach ($this->items as $item) {
                if (!isset($this->queues[$item->authorId])) {
                    $this->queues[$item->authorId] = new ModerationApprovalQueue($item->authorId);
                }
                $this->queues[$item->authorId]->addItem($item);
            }
            $this->queues = array_values($this->queues);
            usort($this->queues, function ($a, $b) {
                return $a->attribute('pending') ? -1 : 1;
            });
        }
    }
}