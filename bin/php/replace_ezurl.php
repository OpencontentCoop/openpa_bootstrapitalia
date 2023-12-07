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
    '[from:][to:][dry-run][strict]',
    '',
    []
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();

$from = $options['from'] ?? die('Missing from');
$to = $options['to'] ?? die('Missing to');
$strict = $options['strict'];
$fromStrict = $strict ? $from : "{$from}%";
$query = "select * from ezurl where url like '{$fromStrict}';";
$cli->output('Query: ' . $query);
$rows = eZDB::instance()->arrayQuery($query);
foreach ($rows as $row) {
    $cli->output(' <- ' . $row['url'] . ' ' . $row['original_url_md5']);
    $url = eZURL::fetch($row['id']);
    $newUrl = str_replace($from, $to, $row['url']);
    $newUrlMd5 = md5($newUrl);
    if ($url instanceof eZURL) {
        if (!$options['dry-run']) {
            $cli->warning(' -> ' . $newUrl . ' ' . $newUrlMd5);
            $url->setAttribute('url', $newUrl);
            $url->setAttribute('original_url_md5', $newUrlMd5);
            $url->store();
        }else {
            $cli->output(' -> ' . $newUrl . ' ' . $newUrlMd5);
        }
    } else {
        $cli->error('Url not found ' . $row['id']);
    }
}

$script->shutdown();