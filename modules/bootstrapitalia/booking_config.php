<?php

$module = $Params['Module'];
$http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();
$action = $Params['Action'];
$parameter = $Params['Parameter'];

if (!StanzaDelCittadinoBooking::factory()->isEnabled()) {
    return $module->handleError(eZError::KERNEL_ACCESS_DENIED, 'kernel');
}

try{
    StanzaDelCittadinoClient::$connectionTimeout = 60;
    StanzaDelCittadinoClient::$processTimeout = 60;
    $calendars = StanzaDelCittadinoBridge::factory()->instanceNewClient()->getCalendarList();
}catch (Throwable $e){
    eZDebug::writeError($e->getMessage(), __FILE__);
    $calendars = [];
}
$tpl->setVariable('calendars', $calendars);
$Result = array();
$Result['content'] = $tpl->fetch('design:bootstrapitalia/booking_config.tpl');
$Result['path'] = array(
    array(
        'text' => 'Booking config',
        'url' => false
    )
);
$contentInfoArray = array(
    'node_id' => null,
    'class_identifier' => null
);
$contentInfoArray['persistent_variable'] = array(
    'show_path' => false
);
if (is_array($tpl->variable('persistent_variable'))) {
    $contentInfoArray['persistent_variable'] = array_merge($contentInfoArray['persistent_variable'], $tpl->variable('persistent_variable'));
}
$Result['content_info'] = $contentInfoArray;