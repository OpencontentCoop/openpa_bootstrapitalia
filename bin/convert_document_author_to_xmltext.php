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

$options = $script->getOptions('',
    '[instance_or_file]',
    []
);
$script->initialize();
$script->setUseDebugAccumulators(true);

$cli = eZCLI::instance();
$isVerbose = $options['verbose'];
$argument = $options['arguments'][0] ?? null;
$command = $GLOBALS['argv'][0];

if ($argument && file_exists($argument)){
    $content = file_get_contents($argument);
    $instances = explode(PHP_EOL, $content);
    foreach ($instances as $instance){
        $runCommand = "php $command {$instance}_backend";
        if ($options['verbose']){
            $cli->output($runCommand);
        }
        shell_exec($runCommand);

    }
    $script->shutdown();

}else{
    try {
        BootstrapItaliaInstallerUtils::convertDocumentAuthorDatatype();
        $script->shutdown();
    } catch (Exception $e) {
        $errCode = $e->getCode();
        $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
        $script->shutdown($errCode, $e->getMessage());
    }
}


