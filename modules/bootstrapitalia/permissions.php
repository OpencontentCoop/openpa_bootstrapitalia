<?php

$module = $Params['Module'];
$http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();
$action = $Params['Action'];
$userNode = $Params['UserNode'];
$groupNode = $Params['GroupNode'];

if (in_array($action, ['add', 'remove'])) {
    $done = 'fail';
    $message = 'Unauthorized';

    $userNode = eZContentObjectTreeNode::fetch((int)$userNode);
    $groupNode = eZContentObjectTreeNode::fetch((int)$groupNode);

    if ($userNode instanceof eZContentObjectTreeNode
        && in_array($userNode->attribute('class_identifier'), eZUser::fetchUserClassNames())
        && $groupNode instanceof eZContentObjectTreeNode
        && ($userNode->attribute('contentobject_id') != eZUser::currentUserID() || $groupNode->attribute('name') != 'Gestione Accessi redazione')
    ) {

        if ($action === 'add') {
            if (eZOperationHandler::operationIsAvailable('content_addlocation')) {
                $operationResult = eZOperationHandler::execute('content',
                    'addlocation', array(
                        'node_id' => $userNode->attribute('node_id'),
                        'object_id' => $userNode->attribute('contentobject_id'),
                        'select_node_id_array' => array($groupNode->attribute('node_id'))
                    ),
                    null,
                    true);
            } else {
                eZContentOperationCollection::addAssignment($userNode->attribute('node_id'), $userNode->attribute('contentobject_id'), array($groupNode->attribute('node_id')));
            }

            foreach ($userNode->object()->assignedNodes() as $assignedNode){
                if ($assignedNode->attribute('parent_node_id') == $groupNode->attribute('node_id')){
                    $done = 'success';
                    $message = '';
                }
            }

        }elseif ($action === 'remove') {

            $removeList = [];
            foreach ($userNode->object()->assignedNodes() as $assignedNode){
                if ($assignedNode->attribute('parent_node_id') == $groupNode->attribute('node_id')
                    && $assignedNode->canRemove()
                    && $assignedNode->canRemoveLocation()
                ){
                    $removeList[] = $assignedNode->attribute('node_id');
                }
            }
            if (!empty($removeList)) {
                if (eZOperationHandler::operationIsAvailable('content_removelocation')) {
                    $operationResult = eZOperationHandler::execute('content',
                        'removelocation', array('node_list' => $removeList),
                        null,
                        true);
                } else {
                    eZContentOperationCollection::removeNodes($removeList);
                }
                $done = 'success';
                $message = '';
            }
        }
    }

    header('Content-Type: application/json');
    echo json_encode( ['code' => $done, 'message' => $message] );
    eZExecution::cleanExit();
}

$Result = array();
$Result['content'] = $tpl->fetch('design:bootstrapitalia/permissions.tpl');
$Result['path'] = array(
    array(
        'text' => 'Gestione accessi redazione',
        'url' => false
    )
);
$contentInfoArray = array(
    'node_id' => null,
    'class_identifier' => null
);
$contentInfoArray['persistent_variable'] = array(
    'show_path' => true
);
if (is_array($tpl->variable('persistent_variable'))) {
    $contentInfoArray['persistent_variable'] = array_merge($contentInfoArray['persistent_variable'], $tpl->variable('persistent_variable'));
}
$Result['content_info'] = $contentInfoArray;