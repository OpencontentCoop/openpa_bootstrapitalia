<?php

require 'autoload.php';

$script = eZScript::instance([
        'description' => "",
        'use-session' => false,
        'use-modules' => true,
        'use-extensions' => true,
    ]
);

$script->startup();

$options = $script->getOptions(
    '[username:][email:][lastname:][firstname:]',
    '',
    [
    ]
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();

$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

try {
    $username = $options['username'];
    $email = $options['email'];
    $lastname = $options['lastname'];
    $firstname = $options['firstname'] ?? die('Missing option');

    $object = eZContentObject::fetchByRemoteID($username);
    if (!$object instanceof eZContentObject) {
        $createUser = true;
        // login|email|password_hash|hash_identifier|is_enabled
        $userAccount = "$username|$email||php_default|1";
        if ($user = eZUser::fetchByName($username)) {
            $object = $user->contentObject();
            $createUser = false;
        }
        if ($createUser && $user = eZUser::fetchByEmail($email)) {
            $object = $user->contentObject();
            $createUser = false;
        }
        if ($createUser) {
            $object = eZContentFunctions::createAndPublishObject([
                'parent_node_id' => eZINI::instance()->variable("UserSettings", "DefaultUserPlacement"),
                'class_identifier' => 'user',
                'attributes' => [
                    'first_name' => $firstname,
                    'last_name' => $lastname,
                    'user_account' => $userAccount,
                ],
            ]);
        }
        if (!$object instanceof eZContentObject) {
            throw new Exception('Error creating or retrieving user');
        }

        $cli->output('Set default roles for object ' . $object->attribute('id'));
        $userNode = $object->mainNode();
        $editorBase = eZContentObject::fetchByRemoteID('editors_base');
        if (!$editorBase instanceof eZContentObject) {
            throw new Exception('Error retrieving role list');
        }
        /** @var eZContentObjectTreeNode $node */
        foreach ($editorBase->mainNode()->children() as $node) {
            if ($node->object()->attribute('remote_id') === 'editors_sito') {
                continue;
            }
            $cli->output('Add to ' . $node->attribute('name'));
            eZContentOperationCollection::addAssignment(
                $userNode->attribute('node_id'),
                $userNode->attribute('contentobject_id'),
                [$node->attribute('node_id')]
            );
        }
    } else {
        $cli->output('Already exixts');
    }


    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}
