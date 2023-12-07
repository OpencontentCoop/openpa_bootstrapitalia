<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Get version\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions(
    '[base:][dry-run][strict]',
    '',
    []
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();

$base = $options['base'] ?? die('Missing base');
$strict = $options['strict'];
$fromStrict = $strict ? $base : "{$base}%";
$query = "select * from ezurl where url like '{$fromStrict}';";
$cli->output('Query: ' . $query);
$rows = eZDB::instance()->arrayQuery($query);
foreach ($rows as $row) {
    $url = eZURL::fetch($row['id']);
    $path = parse_url($row['url'], PHP_URL_PATH);
    $cli->output(ltrim($path, '/'));
    $test = eZURLAliasML::fetchByPath( $path );
    if (empty($test)){
        $cli->warning($row['url']);
    }

}

$script->shutdown();