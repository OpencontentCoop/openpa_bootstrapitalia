<?php

/** @var eZModule $module */
$module = $Params['Module'];
$http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();
$versionId = (int)$Params['VersionId'];
$action = $Params['Action'];

if ($http->hasPostVariable('Filter')){
    $redirectParams = '';
    if ($http->hasPostVariable('assignment') && $http->postVariable('assignment') > 0){
        $redirectParams .= '/(assignment)/' . (int)$http->postVariable('assignment');
    }
    if ($http->hasPostVariable('status') && (int)$http->postVariable('status') !== 0){
        $redirectParams .= '/(status)/' . (int)$http->postVariable('status');
    }
    if ($http->hasPostVariable('classIdentifier') && !empty($http->postVariable('classIdentifier'))){
        $redirectParams .= '/(class)/' . $http->postVariable('classIdentifier');
    }

    $module->redirectTo('/bootstrapitalia/approval' . $redirectParams);
    return;
}

$Offset = $Params['Offset'];
$Assignment = $Params['Assignment'] > 0 ? (int)$Params['Assignment'] : null;
$Class = !empty($Params['Class']) ? $Params['Class'] : null;
$Status = $Params['Status'] >= -1 && $Params['Status'] <= 3 ? (int)$Params['Status'] : ModerationHandler::STATUS_PENDING;
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

if ($versionId > 0
    && in_array($action, ['approve', 'deny'])
    && ModerationHandler::canApproveVersion($versionId)) {
    try {
        if ($action == 'approve') {
            $approval = ModerationHandler::approveVersion($versionId);
        } else {
            $approval = ModerationHandler::denyVersion($versionId);
        }
        if ($redirect === 'history') {
            $module->redirectTo('/content/history/' . $approval->contentObjectId);
            return;
        }
    } catch (RuntimeException $e) {
        return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
    }
}
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
$facets = ModerationApproval::fetchFacets($filters);
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
        'text' => ezpI18n::tr('design/standard/collaboration/approval', 'Approval'),
        'url' => false,
    ],
];
