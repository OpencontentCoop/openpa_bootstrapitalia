<?php

/** @var eZModule $module */
$module = $Params['Module'];
$http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();
$versionId = (int)$Params['VersionId'];
$action = $Params['Action'];

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

if ($versionId > 0) {
    if (in_array($action, ['approve', 'deny'])) {
        try {
            if (ModerationHandler::canApproveVersion($versionId)) {
                if ($action == 'approve') {
                    $approval = ModerationHandler::approveVersion($versionId);
                } else {
                    $approval = ModerationHandler::denyVersion($versionId);
                }
                $redirectTo = '/bootstrapitalia/approval';
                if ($redirect === 'history') {
                    $redirectTo = '/content/history/' . $approval->contentObjectId;
                }
                if ($redirect === 'version') {
                    $redirectTo = '/bootstrapitalia/approval/' . $versionId;
                }
            } else {
                $redirectTo = '/bootstrapitalia/approval/' . $versionId;
            }
            $module->redirectTo($redirectTo);
            return;
        } catch (RuntimeException $e) {
            eZDebug::writeError($e->getMessage(), __FILE__);
            return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
        }
    } else {
        $item = ModerationApproval::fetchByContentObjectVersionId($versionId);
        if ($item instanceof ModerationApproval) {
            ModerationHandler::setLastRead($item);

            if ($action === 'comment' && $http->hasPostVariable('Comment')) {
                $text = $http->postVariable('Comment');
                ModerationMessage::createComment($item, $text);
                $module->redirectTo('/bootstrapitalia/approval/' . $versionId);
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
    $tpl->setVariable('approval_item', false);

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
