<?php

function openpa_bootstrapitalia_ContentActionHandler($module, $http, $objectID)
{
    if ($http->hasPostVariable('LockedUpdatePriorityButton')) {
        $viewMode = $http->postVariable('ViewMode', 'full');

        if ($http->hasPostVariable('ContentNodeID')) {
            $contentNodeID = $http->postVariable('ContentNodeID');
        } else {
            eZDebug::writeError("Variable 'ContentNodeID' can not be found in template.");
            $module->redirectTo('openpa/object/' . $objectID);
            return;
        }
        if ($http->hasPostVariable('Priority') and $http->hasPostVariable('PriorityID')) {
            $contentNode = eZContentObjectTreeNode::fetch($contentNodeID);
            if (!$contentNode->attribute('can_edit') && !LockEditConnector::canLockEdit($contentNode->object())) {
                eZDebug::writeError(
                    'Current user can not update the priorities because he has no permissions to edit the node'
                );
                $module->redirectTo($module->functionURI('view') . '/' . $viewMode . '/' . $contentNodeID . '/');
                return;
            }
            $priorityArray = $http->postVariable('Priority');
            $priorityIDArray = $http->postVariable('PriorityID');

            if (eZOperationHandler::operationIsAvailable('content_updatepriority')) {
                $operationResult = eZOperationHandler::execute(
                    'content',
                    'updatepriority',
                    [
                        'node_id' => $contentNodeID,
                        'priority' => $priorityArray,
                        'priority_id' => $priorityIDArray,
                    ],
                    null,
                    true
                );
            } else {
                eZContentOperationCollection::updatePriority($contentNodeID, $priorityArray, $priorityIDArray);
            }
        }

        if ($http->hasPostVariable('ContentObjectID')) {
            $objectID = $http->postVariable('ContentObjectID');
            eZContentCacheManager::clearContentCacheIfNeeded($objectID);
        }

        if ($http->hasPostVariable('RedirectURIAfterPriority')) {
            return $module->redirectTo($http->postVariable('RedirectURIAfterPriority'));
        }
        $module->redirectTo($module->functionURI('view') . '/' . $viewMode . '/' . $contentNodeID . '/');
        return;
    }
}