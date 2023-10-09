<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Set extra param\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions(
    '[c:|class:][h:|handler:][a:|attribute:][k:|key:][v:|value:][dry-run]',
    '[instance_or_file]',
    []
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();
$isVerbose = $options['verbose'];
$isDryRun = $options['dry-run'];
$argument = $options['arguments'][0];
$command = $GLOBALS['argv'][0];

$classIdentifier = $options['class'];
$handlerIdentifier = $options['handler'];
$attributeIdentifier = $options['attribute'];
$key = $options['key'];
$value = $options['value'];
$dryRun = $options['dry-run'];
$dryRunArgument = $dryRun ? '--dry-run' : '';

if (file_exists($argument)) {
    $content = file_get_contents($argument);
    $instances = explode(PHP_EOL, $content);
    foreach ($instances as $instance) {
        $cmd = "php $command -s{$instance}_frontend --class=$classIdentifier --handler=$handlerIdentifier --attribute=$attributeIdentifier --key=$key --value=$value $dryRunArgument";
        $result = $isDryRun ? '' : shell_exec($cmd);
        if ($isVerbose) {
            $cli->output($cmd);
        }
    }
} else {
    $contentClass = eZContentClass::fetchByIdentifier($classIdentifier);
    if ($contentClass) {
        $currentExtras = OCClassExtraParametersManager::instance($contentClass);
        $handler = $currentExtras->getHandler($handlerIdentifier);
        $cli->warning("Upsert $value in {$classIdentifier}/{$attributeIdentifier} {$handlerIdentifier}/{$key }");
        $extra = new OCClassExtraParameters([
            'class_identifier' => $classIdentifier,
            'attribute_identifier' => $attributeIdentifier,
            'handler' => $handlerIdentifier,
            'key' => $key,
            'value' => $value,
        ]);
        if ($dryRun) {
            print_r($extra);
        } else {
            $extra->store();
            OpenPAINI::clearDynamicIniCache();
            eZContentCacheManager::clearAllContentCache(true);
        }
    } else {
        $cli->error();
    }
}

$script->shutdown();

/*
php extension/openpa_bootstrapitalia/bin/set_extra_param.php --class=public_service --attribute=has_module_input --handler=table_view --key=show_link --value=1
*/