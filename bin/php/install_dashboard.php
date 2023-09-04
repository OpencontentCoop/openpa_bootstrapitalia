<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => (""),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions(
    '[class:][parent:]',
    '',
    [
        'class' => 'Class identifier',
        'parent' => 'Parent node identifier (node_id or object_remote_id)',
    ]
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();
$admin = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($admin, $admin->attribute('contentobject_id'));


try {
    $class = eZContentClass::fetchByIdentifier($options['class']);
    if (!$class instanceof eZContentClass) {
        throw new Exception('Class not found');
    }

    $parentNodeIdentifier = $options['parent'];
    if (is_numeric($parentNodeIdentifier)) {
        $parentNode = eZContentObjectTreeNode::fetch($parentNodeIdentifier);
    } else {
        $parentNodeObject = eZContentObject::fetchByRemoteID($parentNodeIdentifier);
        if (!$parentNodeObject instanceof eZContentObject) {
            throw new Exception('Parent object not found');
        }
        $parentNode = $parentNodeObject->mainNode();
    }

    // install Contributors group
    $groupRemoteId = 'contributors_' . $class->attribute('identifier');
    $groupName = 'Contributors (' . $class->attribute('name') . ')';
    $cli->output("Assert exists group $groupName");
    $groupObject = eZContentObject::fetchByRemoteID($groupRemoteId);
    if (!$groupObject instanceof eZContentObject) {
        $baseGroup = eZContentObject::fetchByRemoteID('editors_base');
        if (!$baseGroup instanceof eZContentObject) {
            throw new Exception('Base group not found');
        }
        $groupObject = eZContentFunctions::createAndPublishObject([
            'class_identifier' => 'user_group',
            'remote_id' => $groupRemoteId,
            'parent_node_id' => $baseGroup->attribute('main_node_id'),
            'attributes' => ['name' => $groupName],
        ]);
        if (!$groupObject instanceof eZContentObject) {
            throw new Exception('Fail creating contributors group');
        }
    }

    // install Contributors role
    $roleName = 'Contributors ' . $class->attribute('name');
    $cli->output("Assert exists role $roleName");
    $moderationStateGroup = OpenPABase::initStateGroup('moderation', [
        'skipped',
        'draft',
        'waiting',
        'accepted',
        'refused',
    ]);
    $policies = [
        [
            'ModuleName' => 'content',
            'FunctionName' => 'create',
            'Limitation' => [
                'Class' => [$class->attribute('id')],
                'Node' => [$parentNode->attribute('main_node_id')],
            ],
        ],
        [
            'ModuleName' => 'content',
            'FunctionName' => 'dashboard',
        ],
        [
            'ModuleName' => 'editorialstuff',
            'FunctionName' => 'dashboard',
        ],
        [
            'ModuleName' => 'content',
            'FunctionName' => 'edit',
            'Limitation' => [
                'Class' => [$class->attribute('id')],
                'Owner' => [1],
                'StateGroup_moderation' => [
                    $moderationStateGroup['moderation.draft']->attribute('id'),
                ],
            ],
        ],
        [
            'ModuleName' => 'content',
            'FunctionName' => 'remove',
            'Limitation' => [
                'Class' => [$class->attribute('id')],
                'Owner' => [1],
                'StateGroup_moderation' => [
                    $moderationStateGroup['moderation.draft']->attribute('id'),
                ],
            ],
        ],
        [
            'ModuleName' => 'state',
            'FunctionName' => 'assign',
            'Limitation' => [
                'Class' => [$class->attribute('id')],
                'Owner' => [1],
                'StateGroup_moderation' => [
                    $moderationStateGroup['moderation.refused']->attribute('id'),
                    $moderationStateGroup['moderation.draft']->attribute('id'),
                ],
                'NewState' => [
                    $moderationStateGroup['moderation.waiting']->attribute('id'),
                ],
            ],
        ],
    ];
    $role = OpenPABase::initRole($roleName, $policies, true);
    if (!$role instanceof eZRole) {
        throw new Exception("Failing creating role");
    }
    $cli->output("Assert role assignment");
    $role->assignToUser($groupObject->attribute('id'));

    $cli->warning('CHECK WORKFLOW!!!');

} catch (Exception $e) {
    $cli->error($e->getMessage());
}

$script->shutdown();