<?php
require 'autoload.php';

$script = eZScript::instance(array('description' => ("Get version\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true));

$script->startup();

$options = $script->getOptions('[module:][list]',
    '[instance_or_file]',
    []
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();
$isVerbose = $options['verbose'];
$module = $options['module'];
$argument = $options['arguments'][0] ?? null;
$command = $GLOBALS['argv'][0];

if ($options['list']) {
    $result = eZSiteData::fetchObjectList(eZSiteData::definition(), null, ['name' => ['like', 'ocinstaller%']]);
    foreach ($result as $item) {
        $name = $item->attribute('name');
        if ($name === 'ocinstaller_version'){
            continue;
        }
        $name = str_replace('ocinstaller_', '', $name);
        $name = str_replace('_version', '', $name);
        $cli->output($name);
    }
}
if ($argument && file_exists($argument)){
    $content = file_get_contents($argument);
    $instances = explode(PHP_EOL, $content);
    foreach ($instances as $instance){
        $result = shell_exec("php $command {$instance}_backend");
        $result = trim($result);
        if (!empty($result)) {
            $cli->output($instance . ' ' . $result);
        }
    }
}else{
    if ($module) {
        $siteData = eZSiteData::fetchByName("ocinstaller_{$module}_version");
    }else{
        $siteData = eZSiteData::fetchByName("ocinstaller_version");
    }
    if ($siteData instanceof eZSiteData){
        $cli->output($siteData->attribute('value'));
    }
}

$script->shutdown();