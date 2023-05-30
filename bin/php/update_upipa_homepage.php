<?php

require 'autoload.php';

$cli = eZCLI::instance();
$script = eZScript::instance([
    'description' => ("Update homepage"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);

$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

$home = OpenPaFunctionCollection::fetchHome();
$object = $home->object();


$menuList = [];
foreach ([
    '664d801957002a127d4ac64ddc98f412', // azienda
    'ae4dbab2eafbc91e84259bb3ecb74fa6', // servizi
    'e541f3c8544732a82428b5f4d631c35e', // lavora
    'c75c16448b728fc3e33b39c4eb550f2f', // documenti
    '49986652d694d8f4516d9614c387bc9f', // novitò
         ] as $remoteId) {
    $menuItem = eZContentObject::fetchByRemoteID($remoteId);
    if (!$menuItem instanceof eZContentObject) {
        throw new Exception("Menu $remoteId not found");
    }
    $menuList[] = $menuItem->attribute('id');
}
$headerLinkList = [];
/** @var eZContentObjectTreeNode[] $nodes */
$nodes = eZContentObjectTreeNode::subTreeByNodeID([
    'ClassFilterType' => 'include',
    'ClassFilterArray' => ['trasparenza', 'albotelematicotrentino'],
], 1);
foreach ($nodes as $node){
    $headerLinkList[] = $node->attribute('contentobject_id');
}
$attributes = [
    'link_nell_header' => implode('-', $headerLinkList),
    'link_al_menu_orizzontale' => implode('-', $menuList),
];

eZContentFunctions::updateAndPublishObject($object, [
    'attributes' => $attributes,
]);

$script->shutdown();