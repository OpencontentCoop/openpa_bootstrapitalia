<?php

$url = eZHTTPTool::instance()->getVariable('url');
$provider = parse_url($url, PHP_URL_HOST);
$tpl = eZTemplate::factory();
$tpl->setVariable('url', $url);
$tpl->setVariable('provider', $provider);
echo $tpl->fetch('design:bootstrapitalia/iframe.tpl');
eZExecution::cleanExit();