<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Change document search block\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();

$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

function updateSearchBlock(eZContentObject $object)
{
    eZCLI::instance()->output($object->attribute('name'), false);
    $dataMap = $object->dataMap();
    if (isset($dataMap['layout'])) {
        $contentObjectAttribute = $dataMap['layout'];
        /** @var eZPage $ezPage */
        $ezPage = $contentObjectAttribute->content();
        //print_r($contentObjectAttribute->attribute('data_text'));
        foreach ($ezPage->attribute('zones') as $zone) {
            /** @var eZPageBlock $block */
            foreach ($zone->attribute('blocks') as $block) {
                if ($block->attribute('type') === 'RicercaDocumenti' || $block->attribute('type') === 'OpendataQueriedContents') {
                    $block->setAttribute('type', 'OpendataQueriedContents');
                    $mainNodeId = $object->mainNodeID();
                    $subtreeFilter = " and subtree [$mainNodeId] ";
                    $block->setAttribute('custom_attributes', [
                        'query' => "classes [document]{$subtreeFilter}sort [published => desc]",
                        'ignore_policy' => 0,
                        'show_grid' => 1,
                        'show_map' => 0,
                        'show_search' => 1,
                        'input_search_placeholder' => '',
                        'limit' => 3,
                        'items_per_row' => 3,
                        'facets' => '',
                        'view_api' => 'card',
                        'fields' => '',
                        'simple_geo_api' => 0,
                        'template' => '',
                        'color_style' => 'bg-100',
                        'container_style' => '',
                        'intro_text' => '',
                    ]);
                    eZCLI::instance()->warning('...update block');
                    eZDB::instance()->begin();
                    $flowBlock = eZFlowBlock::fetch($block->attribute('id'));
                    if ($flowBlock instanceof eZFlowBlock){
                        $flowBlock->setAttribute('block_type', 'OpendataQueriedContents');
                    }
                    $contentObjectAttribute->setAttribute('data_text', $ezPage->toXML());
                    $contentObjectAttribute->store();
                    eZContentCacheManager::clearContentCache($object->attribute('id'));
                    eZDB::instance()->commit();

                    return true;
                }
            }
        }
    }
    eZCLI::instance()->output('...block not found');
    return false;
}

try {
    $documentiObject = eZContentObject::fetchByRemoteID('cb945b1cdaad4412faaa3a64f7cdd065'); // Documenti e dati
    if ($documentiObject instanceof eZContentObject) {
        $documenti = $documentiObject->mainNode();
        updateSearchBlock($documentiObject);
        /** @var eZContentObjectTreeNode $child */
        foreach ($documenti->children() as $child) {
            updateSearchBlock($child->object());
        }
    }
    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}