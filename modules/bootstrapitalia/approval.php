<?php

/** @var eZModule $module */
$module = $Params['Module'];
$http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();
$entityType = $Params['Entity'];
$entityId = (int)$Params['Id'];
$action = $Params['Action'];

$tpl->setVariable('approval_item', false);
$tpl->setVariable('approval_item_list_by_object', false);

$redirectParams = '';
if ($http->hasPostVariable('ByStatus') && (int)$http->postVariable('ByStatus') !== 0) {
    $redirectParams .= '/(status)/' . (int)$http->postVariable('ByStatus');
} elseif ($http->hasPostVariable('Filter')) {
    if ($http->hasPostVariable('assignment') && $http->postVariable('assignment') > 0) {
        $redirectParams .= '/(assignment)/' . (int)$http->postVariable('assignment');
    }
    if ($http->hasPostVariable('status') && (int)$http->postVariable('status') !== 0) {
        $redirectParams .= '/(status)/' . (int)$http->postVariable('status');
    }
    if ($http->hasPostVariable('classIdentifier') && !empty($http->postVariable('classIdentifier'))) {
        $redirectParams .= '/(class)/' . $http->postVariable('classIdentifier');
    }
}
if (!empty($redirectParams)) {
    $module->redirectTo('/bootstrapitalia/approval' . $redirectParams);
    return;
}

$Offset = $Params['Offset'];
$Assignment = $Params['Assignment'] > 0 ? (int)$Params['Assignment'] : null;
$Class = !empty($Params['Class']) ? $Params['Class'] : null;
$Status = $Params['Status'] >= -1 && in_array($Params['Status'], [-1, 0, 1, 2, 100]
) ? (int)$Params['Status'] : ModerationHandler::STATUS_PENDING;
$viewParameters = [
    'offset' => $Offset,
    'assignment' => $Assignment,
    'class' => $Class,
    'status' => $Status,
];

if (!ModerationHandler::isEnabled()) {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

$redirect = $http->hasGetVariable('redirect') ? $http->getVariable('redirect') : null;

if ($entityType === 'edit' && $entityId > 0) {
    $object = eZContentObject::fetch($entityId);
    if ($object instanceof eZContentObject && $object->canEdit()) {
        if (ModerationApproval::fetchPendingCountByObjectIdAndLocale($entityId, eZLocale::currentLocaleCode(), true)){
            $approvalsByObject = ModerationApprovalCollection::fetchByContentObjectId($entityId);
            $queue = $approvalsByObject->attribute('queues');
            if (isset($queue[0])){
                $pending = $queue[0]->attribute('pending');
                if ($pending instanceof ModerationApproval
                    && $pending->attribute('version') instanceof eZContentObjectVersion) {
                    $locale = $pending->attribute('version')->attribute('initial_language')->attribute('locale');
                    //redirect to edit from current approval version
                    $nodeAssignmentList = eZNodeAssignment::fetchForObject($entityId, $pending->attribute('version')->attribute('version'));
                    $db = eZDB::instance();
                    $db->begin();
                    $newVersionID = $object->copyRevertTo(
                        $pending->attribute('version')->attribute('version'),
                        $locale
                    );
                    // Copy assignments without a remote_id to avoid browse for parent after publish
                    // @see eZContentObject::copyVersion
                    foreach ($nodeAssignmentList as $nodeAssignment) {
                        if ($nodeAssignment->attribute('remote_id') == 0) {
                            $clonedAssignment = $nodeAssignment->cloneNodeAssignment(
                                $newVersionID,
                                $entityId
                            );
                            $clonedAssignment->setAttribute('op_code', eZNodeAssignment::OP_CODE_CREATE);
                            $clonedAssignment->setAttribute('from_node_id', -1);
                            $clonedAssignment->store();
                        }
                    }

                    $db->commit();
                    $module->redirectTo('content/edit/' . $object->attribute('id') . '/' . $newVersionID . '/' . $locale);
                    return;
                }
            }
        }
        //redirect to standard edit
        $module->redirectTo('content/edit/' . $object->attribute('id') . '/f/' . eZLocale::currentLocaleCode());
        return;
    } else {
        return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
    }
} elseif ($entityType === 'object' && $entityId > 0) {
    $object = eZContentObject::fetch($entityId);
    if ($object instanceof eZContentObject) {
        $approvalsByObject = ModerationApprovalCollection::fetchByContentObjectId($entityId);
        $tpl->setVariable('approval_item_list_by_object', true);
        $tpl->setVariable('approvals_by_object', $approvalsByObject);
        $tpl->setVariable('object', $object);
        $Result = [];
        $Result['content'] = $tpl->fetch('design:bootstrapitalia/approval.tpl');
        $Result['path'] = [
            [
                'text' => ezpI18n::tr('bootstrapitalia/moderation', 'Approval'),
                'url' => '/bootstrapitalia/approval',
            ],
            [
                'text' => $object->attribute('name'),
                'url' => false,
            ],
        ];
        $contentInfoArray = [];
        $contentInfoArray['persistent_variable'] = [
            'show_path' => true,
        ];
        if (is_array($tpl->variable('persistent_variable'))) {
            $contentInfoArray['persistent_variable'] = array_merge(
                $contentInfoArray['persistent_variable'],
                $tpl->variable('persistent_variable')
            );
        }
        $Result['content_info'] = $contentInfoArray;
        $approvalsByObject->setLastRead();
    } else {
        return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
    }
} elseif ($entityType === 'version' && $entityId > 0) {
    if (in_array($action, ['approve', 'deny', 'discard'])) {
        try {
            $approval = false;
            if ($action == 'discard' && ModerationHandler::canDiscardVersion($entityId)) {
                $approval = ModerationHandler::discardVersion($entityId);
                $redirect = 'dashboard';
            } elseif ($action == 'approve' && ModerationHandler::canApproveVersion($entityId)) {
                $approval = ModerationApproval::fetchByContentObjectVersionId($entityId);
                if ($approval && empty($approval->attribute('depends_on'))) {
                    $approval = ModerationHandler::approveVersion($entityId);
                }
            } elseif ($action == 'deny' && ModerationHandler::canApproveVersion($entityId)) {
                $approval = ModerationHandler::denyVersion($entityId);
            }
            if ($approval) {
                $redirectTo = '/bootstrapitalia/approval';
                if ($redirect === 'dashboard') {
                    $redirectTo = '/bootstrapitalia/approval';
                }
                if ($redirect === 'history') {
                    $redirectTo = '/content/history/' . $approval->contentObjectId;
                }
                if ($redirect === 'version') {
                    $redirectTo = '/bootstrapitalia/approval/version/' . $entityId;
                }
                if ($redirect === 'object') {
                    $redirectTo = '/bootstrapitalia/approval/object/' . $approval->contentObjectId;
                }
            } else {
                $redirectTo = '/bootstrapitalia/approval/version/' . $entityId;
            }
            $module->redirectTo($redirectTo);
            return;
        } catch (RuntimeException $e) {
            eZDebug::writeError($e->getMessage(), __FILE__);
            return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
        }
    } else {
        $item = ModerationApproval::fetchByContentObjectVersionId($entityId);
        if ($item instanceof ModerationApproval) {
            if ($action === 'comment' && $http->hasPostVariable('Comment')) {
                $text = $http->postVariable('Comment');
                ModerationMessage::createComment($item, $text);

                $redirectTo = '/bootstrapitalia/approval/version/' . $entityId;
                if ($redirect === 'object') {
                    $redirectTo = '/bootstrapitalia/approval/object/' . $item->contentObjectId;
                }
                $module->redirectTo($redirectTo);
                return;
            }

            $tpl->setVariable('approval_item', $item);
            $Result = [];
            $Result['content'] = $tpl->fetch('design:bootstrapitalia/approval.tpl');
            $Result['path'] = [
                [
                    'text' => ezpI18n::tr('bootstrapitalia/moderation', 'Approval'),
                    'url' => '/bootstrapitalia/approval',
                ],
                [
                    'text' => $item->title,
                    'url' => '/bootstrapitalia/approval/object/' . $item->contentObjectId,
                ],
                [
                    'text' => ezpI18n::tr('bootstrapitalia/moderation', 'version') . ' ' . $item->attribute(
                            'version'
                        )->attribute('version'),
                    'url' => false,
                ],
            ];
            $contentInfoArray = [];
            $contentInfoArray['persistent_variable'] = [
                'show_path' => true,
            ];
            if (is_array($tpl->variable('persistent_variable'))) {
                $contentInfoArray['persistent_variable'] = array_merge(
                    $contentInfoArray['persistent_variable'],
                    $tpl->variable('persistent_variable')
                );
            }
            $Result['content_info'] = $contentInfoArray;
            ModerationHandler::setLastRead($item);
        } else {
            return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
        }
    }
} else {
    $limit = 10;
    $offset = $viewParameters['offset'];
    $creator = ModerationHandler::userNeedModeration(eZUser::currentUser()) ? (int)eZUser::currentUser()->id() : null;
    $filters = [
        'assignment' => $viewParameters['assignment'],
        'creator' => $creator,
        'status' => $viewParameters['status'],
        'classIdentifier' => $viewParameters['class'],
    ];
    $approvals = ModerationApproval::fetchList($limit, $offset, $filters);
    $facets = ModerationApproval::fetchFacets([
        'creator' => $creator,
        'status' => $viewParameters['status'],
    ]);
    $tpl->setVariable('page_limit', $limit);
    $tpl->setVariable('view_parameters', $viewParameters);
    $tpl->setVariable('current_filters', $filters);
    $tpl->setVariable('approvals', $approvals);
    $tpl->setVariable('approvals_count', ModerationApproval::fetchCount($filters));
    $tpl->setVariable('approvals_facets', $facets);

    $Result = [];
    $Result['content'] = $tpl->fetch('design:bootstrapitalia/approval.tpl');
    $Result['path'] = [
        [
            'text' => ezpI18n::tr('bootstrapitalia/moderation', 'Approval'),
            'url' => false,
        ],
    ];
    $contentInfoArray = [];
    $contentInfoArray['persistent_variable'] = [
        'show_path' => false,
    ];
    if (is_array($tpl->variable('persistent_variable'))) {
        $contentInfoArray['persistent_variable'] = array_merge(
            $contentInfoArray['persistent_variable'],
            $tpl->variable('persistent_variable')
        );
    }
    $Result['content_info'] = $contentInfoArray;
}
