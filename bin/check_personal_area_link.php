<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Get personal area link\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions(
    '[fix][dry-run]',
    '[instance_or_file]',
    []
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();
$isVerbose = $options['verbose'];
$argument = $options['arguments'][0] ?? null;
$command = $GLOBALS['argv'][0];

if ($argument && file_exists($argument)) {
    $content = file_get_contents($argument);
    $instances = explode(PHP_EOL, $content);
    foreach ($instances as $instance) {
        $result = shell_exec("php $command -s{$instance}_backend");
        $result = trim($result);
        if (!empty($result)) {
            $cli->output($instance . ' ' . $result);
        }
    }
} else {
    $cli->warning('https://' . eZINI::instance()->variable('SiteSettings', 'SiteURL') . ' ==> ',  false);
    $uri = PersonalAreaLogin::instance()->getUri();
    if (strpos($uri, '/operatori') !== false && $options['fix']){
        $replaced = str_replace(['operatori/login', 'operatori'], 'user', $uri);
        $resetInfo = PersonalAreaLogin::instance()->resetUriTo($replaced, $options['dry-run']);
        if ($options['verbose']) {
            print_r($resetInfo);
        }
        $uri = PersonalAreaLogin::instance()->getUri();
    }
    $cli->warning($uri);

}

$script->shutdown();
