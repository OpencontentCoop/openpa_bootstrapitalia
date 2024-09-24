<?php

class ezjscApproval extends ezjscServerFunctions
{
    static public function unread()
    {
        $creator = ModerationHandler::userNeedModeration(eZUser::currentUser()) ?
            (int)eZUser::currentUser()->id() : null;
        $pendingList = !ModerationHandler::userNeedModeration(eZUser::currentUser()) ?
            ModerationApproval::fetchList(10, 0, [
                'creator' => $creator,
                'status' => ModerationHandler::STATUS_PENDING,
            ]) : [];
        $unreadList = ModerationApproval::fetchList(10, 0, [
            'creator' => $creator,
            'status' => ModerationHandler::STATUS_UNREAD,
        ]);
        return [
            'pending' => $pendingList,
            'unread' => $unreadList,
        ];
    }
}