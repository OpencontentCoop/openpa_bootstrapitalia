<?php
require 'autoload.php';

$script = eZScript::instance(array('description' => ("Quick clear cache\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true));

$script->startup();

$options = $script->getOptions('[env:][all][purge][dry-run]',
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

if (file_exists($argument)){
    $content = file_get_contents($argument);
    $instances = explode(PHP_EOL, $content);
    foreach ($instances as $instance){
        $result = $isDryRun ? '' : shell_exec("php $command $instance");
        if ($isVerbose){
            $cli->output($instance);
        }
    }
}else{
    $instance = eZCharTransform::instance()->transformByGroup($argument, 'identifier');
    $env = $options['env'] ?? 'frontend';
    $isVerboseOpt = $isVerbose ? '-v ' : '';
    $clearType = '--clear-tag=i18n,user,openpamenu,openpa,template,content ';
    if ($options['all']){
        $clearType = '--clear-all ';
    }
    if ($options['all']){
        $clearType .= '--purge ';
    }
    $command = "php bin/php/ezcache.php {$isVerboseOpt}{$clearType} -s{$instance}_{$env}";
    if ($isVerbose){
        $cli->output($command);
    }
    $result = $isDryRun ? '' : shell_exec("$command");
    if ($isVerbose){
        $cli->output($result);
    }

    $command = "php bin/php/makestaticcache.php {$isVerboseOpt}-s{$instance}_{$env};";
    if ($isVerbose){
        $cli->output($command);
    }
    $result = $isDryRun ? '' : shell_exec("$command");
    if ($isVerbose){
        $cli->output($result);
    }
}

$script->shutdown();