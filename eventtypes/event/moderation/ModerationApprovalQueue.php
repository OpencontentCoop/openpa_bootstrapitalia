<?php

class ModerationApprovalQueue
{
    /**
     * @var int
     */
    public $authorId = 0;

    /**
     * @param ModerationApproval[] $items
     */
    public $items = [];

    private $attributes = [];

    public function __construct(int $authorId, array $items = [])
    {
        $this->items = $items;
        $this->authorId = $authorId;
    }

    public function addItem(ModerationApproval $item)
    {
        $this->items[] = $item;
    }

    public function attributes(): array
    {
        $vars = array_keys(get_object_vars($this));
        $vars[] = 'latest';
        $vars[] = 'pending';
        $vars[] = 'discussion';
        $vars[] = 'timeline';
        $vars[] = 'author';
        $vars[] = 'is_author';
        $vars[] = 'has_unread_comments';

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
                case 'latest':
                    $this->attributes[$key] = $this->items[0] ?? null;
                    break;
                case 'author':
                    $this->attributes[$key] = eZUser::fetch($this->authorId);
                    break;
                case 'is_author':
                    $this->attributes[$key] = $this->authorId == eZUser::currentUser()->id();
                    break;
                case 'pending':
                    $this->attributes[$key] = null;
                    foreach ($this->items as $item) {
                        if ($item->status === ModerationHandler::STATUS_PENDING){
                            $this->attributes[$key] = $item;
                            break;
                        }
                    }
                    break;
                case 'discussion':
                    $this->attributes[$key] = [];
                    foreach ($this->items as $item) {
                        foreach ($item->attribute('history') as $message){
                            if ($message->type === ModerationMessage::TYPE_COMMENT){
                                $this->attributes[$key][] = $message;
                            }
                        }
                    }
                    usort($this->attributes[$key], function ($a, $b) {
                        return $a->createdAt > $b->createdAt ? 1 : -1;
                    });
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
                case 'has_unread_comments':
                    $this->attributes[$key] = false;
                    foreach ($this->attribute('discussion') as $message) {
                        if ($message->attribute('is_unread')){
                            $this->attributes[$key] = true;
                            break;
                        }
                    }
                    break;
                default:
                    eZDebug::writeNotice("Attribute $key does not exist", get_called_class());
                    $this->attributes[$key] = false;
            }
        }

        return $this->attributes[$key];
    }
}