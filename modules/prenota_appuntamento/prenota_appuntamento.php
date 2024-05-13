<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$http = eZHTTPTool::instance();

$app = new BuiltinApp('booking', 'Book an appointment');

if ($http->hasPostVariable('StoreConfig')) {
    $configValue = $http->postVariable('Config', '');
    $app->setCustomConfig($configValue);
    $Module->redirectTo($Module->Name);
    return;
}

$Result = $app->getModuleResult();

if (StanzaDelCittadinoBooking::factory()->isEnabled()) {
    $tpl = eZTemplate::factory();
    $serviceId = $http->hasGetVariable('service_id') ? (int)$http->getVariable('service_id') : 0;
    $offices = StanzaDelCittadinoBooking::factory()->getOffices($serviceId);
    $service = $serviceId > 0 ? eZContentObject::fetch($serviceId) : null;
    $locale = eZLocale::instance();
    $months = [];
    $currentMonthIndex = date('n');
    $currentYear = date('Y');
    $append = false;
    $next = [];
    foreach (array_values($locale->LongMonthNames) as $index => $month) {
        $i = $index + 1;
        if ($i == $currentMonthIndex) {
            $append = true;
        }
        if ($append) {
            $months[] = [
                'index' => $currentYear . '-' . str_pad($i, 2, '0', STR_PAD_LEFT),
                'name' => $month . ' ' . $currentYear
            ];
        } else {
            $next[] = [
                'index' => ($currentYear + 1) . '-' . str_pad($i, 2, '0', STR_PAD_LEFT),
                'name' => $month . ' ' . ($currentYear + 1)
            ];
        }
    }
    if (count($next)) {
        $months = array_merge($months, $next);
    }
    $pageHash = OpenPABase::getCurrentSiteaccessIdentifier() . '-booking:' . $serviceId;

    $tpl->setVariable('pal', StanzaDelCittadinoBridge::factory()->getProfileUri());
    $tpl->setVariable('has_session', $http->hasSessionVariable('booking_user_token'));
    $tpl->setVariable('page_key', $pageHash);
    $tpl->setVariable('service_id', $serviceId);
    $tpl->setVariable('service', $service);
    $tpl->setVariable('months', $months);
    $tpl->setVariable('offices', $offices);
    $tpl->setVariable('steps', StanzaDelCittadinoBooking::factory()->getSteps());
    $tpl->setVariable('show_debug', eZINI::instance()->variable('DebugSettings', 'DebugOutput') == 'enabled' ? 'true' : 'false');

    $Result['content_info']['persistent_variable']['show_path'] = false;
    if (!$service && StanzaDelCittadinoBooking::factory()->isServiceDiscoverEnabled()){
        $tpl->setVariable('services_categories', StanzaDelCittadinoBooking::factory()->getServicesByCategories());
        $Result['content'] = $tpl->fetch('design:bootstrapitalia/booking/service_discover.tpl');
    } else {
        $Result['content'] = $tpl->fetch('design:bootstrapitalia/booking.tpl');
    }
}
