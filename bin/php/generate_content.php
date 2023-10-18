#!/usr/bin/env php
<?php

require_once 'autoload.php';

$script = eZScript::instance(array('description' => (""),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true));

$script->startup();
$options = $script->getOptions(
    '[url:]'
);
$script->initialize();

$siteURL = eZINI::instance()->variable('SiteSettings', 'SiteURL');
$url = $options['url'];

$_SERVER['REQUEST_URI'] = $url;
eZSys::setInstance(
    new eZSys([
        '_SERVER' => [
            'HTTP_X_FORWARDED_PROTO' => 'https',
            'HTTP_HOST' => $siteURL,
            'PHP_SELF' => '/index.php',
            'REQUEST_SCHEME' => 'https',
            'REQUEST_METHOD' => 'GET',
            'REQUEST_URI' => $url,
        ],
    ])
);
$GLOBALS['eZURIRequestInstance'] = new eZURI($url);
$kernel = new ezpKernel(
    new ezpKernelWeb([
        'injected-settings' => [
            'site.ini/ContentSettings/StaticCache' => 'disabled',
        ],
    ])
);
$content = $kernel->run()->getContent();
$content .= "<!-- Generated: " . date('Y-m-d H:i:s') . " -->\n\n";

eZExecution::cleanup();
eZExecution::setCleanExit();
eZExpiryHandler::shutdown();

eZCLI::instance()->output($content);
