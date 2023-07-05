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
    '[dry-run]',
    '[instance_or_file]',
    [
        'dry-run' => 'O dimo',
    ]
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();

$isDryRun = $options['dry-run'];
$argument = $options['arguments'][0];
$command = $GLOBALS['argv'][0];

if ($argument && file_exists($argument)) {
    $content = file_get_contents($argument);
    $instances = explode(PHP_EOL, $content);
    foreach ($instances as $instance) {
        $isDryRunCommand = $isDryRun ? '--dry-run' : '';
        $commandExecute = "php $command -s{$instance}_backend $isDryRunCommand";
        $cli->warning($commandExecute);
        $result = shell_exec($commandExecute);
        $result = trim($result);
        if (!empty($result)) {
            $cli->output($instance . ' ' . $result);
        }
    }
} else {
    try {
        $admin = eZUser::fetchByName('admin');
        eZUser::setCurrentlyLoggedInUser($admin, $admin->attribute('contentobject_id'));

        $fixData = [
            [
                'wrong' => 'benessere e assistenza',
                'right' => 'Salute, benessere e assistenza',
            ],
        ];

        foreach ($fixData as $fixItem) {
            $tag = false;
            /** @var eZTagsKeyword[] $tags */
            $tags = (array)eZTagsKeyword::fetchObjectList(eZTagsKeyword::definition(), null, [
                'keyword' => $fixItem['wrong'],
                'locale' => 'ita-IT',
            ]);
            if (count($tags)) {
                $tag = eZTagsObject::fetch((int)$tags[0]->attribute('keyword_id'));
            }

            $mainTag = false;
            /** @var eZTagsKeyword[] $tags */
            $mainTags = (array)eZTagsKeyword::fetchObjectList(eZTagsKeyword::definition(), null, [
                'keyword' => $fixItem['wrong'],
                'locale' => 'ita-IT',
            ]);
            if (count($mainTags)) {
                $mainTag = eZTagsObject::fetch((int)$mainTags[0]->attribute('keyword_id'));
            }

            if (!$tag instanceof eZTagsObject) {
                $cli->error('Wrong tag not found');
                $script->shutdown(1);
            }
            if (!$mainTag instanceof eZTagsObject) {
                $cli->error('Main tag not found');
                $script->shutdown(1);
            }

            if (!$tag->isSynonym()) {
                $cli->warning('Make wrong tag as synonym');
                if (!$isDryRun) {
                    $updateDepth = false;
                    $updatePathString = false;
                    $db = eZDB::instance();
                    $db->begin();
                    if ($tag->attribute('depth') != $mainTag->attribute('depth')) {
                        $updateDepth = true;
                    }
                    if ($tag->attribute('parent_id') != $mainTag->attribute('parent_id')) {
                        $oldParentTag = $tag->getParent(true);
                        if ($oldParentTag instanceof eZTagsObject) {
                            $oldParentTag->updateModified();
                        }

                        $updatePathString = true;
                    }
                    $tag->moveChildrenBelowAnotherTag($mainTag);
                    $synonyms = $tag->getSynonyms(true);
                    foreach ($synonyms as $synonym) {
                        $synonym->setAttribute('parent_id', $mainTag->attribute('parent_id'));
                        $synonym->setAttribute('main_tag_id', $mainTag->attribute('id'));
                        $synonym->store();
                    }
                    $tag->setAttribute('parent_id', $mainTag->attribute('parent_id'));
                    $tag->setAttribute('main_tag_id', $mainTag->attribute('id'));
                    $tag->store();
                    if ($updatePathString) {
                        $tag->updatePathString();
                    }
                    if ($updateDepth) {
                        $tag->updateDepth();
                    }
                    $tag->updateModified();
                    $db->commit();
                    /* Extended Hook */
                    if (class_exists('ezpEvent', false)) {
                        ezpEvent::getInstance()->filter(
                            'tag/makesynonym',
                            [
                                'tag' => $tag,
                                'mainTag' => $mainTag,
                            ]
                        );
                    }
                }
            }

            /** @var eZContentObject[] $objects */
            $objects = $tag->getRelatedObjects();
            $tagId = $mainTag->attribute('id');
            $tagKeyword = $mainTag->attribute('keyword');
            $tagParentId = $mainTag->attribute('parent_id');
            $tagLocale = 'ita-IT';
            $stringTag = "$tagId|#$tagKeyword|#$tagParentId|#$tagLocale";
            foreach ($objects as $object) {
                if ($object->attribute('class_identifier') == 'public_service') {
                    $dataMap = $object->dataMap();
                    if (isset($dataMap['type']) && $dataMap['type']->attribute(
                            'data_type_string'
                        ) === eZTagsType::DATA_TYPE_STRING) {
                        $cli->output(
                            ' - Fix and reindex object: ' . $object->attribute('name') . ' with tag ' . $stringTag
                        );
                        if (!$isDryRun) {
                            $dataMap['type']->fromString($stringTag);
                            $dataMap['type']->store();
                            eZSearch::addObject($object, true);
                        }
                    } else {
                        $cli->warning(' - Cannot fix type attribute for object: ' . $object->attribute('name'));
                    }
                } else {
                    $cli->warning(' - Cannot fix object: ' . $object->attribute('name'));
                }
            }
            if (!$isDryRun) {
                eZContentCacheManager::clearContentCache(
                    eZContentObject::fetchByRemoteID('all-services')->attribute('id')
                );
            }
        }
    } catch (Throwable $e) {
        $cli->error($e->getMessage());
    }
}
$script->shutdown();

