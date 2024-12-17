<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$http = eZHTTPTool::instance();

$app = BuiltinAppFactory::instanceByIdentifier('booking');

if ($http->hasPostVariable('StoreConfig')) {
    $configValue = $http->postVariable('Config', '');
    $app->setCustomConfig($configValue);
    $Module->redirectTo($Module->Name);
    return;
}

$Result = $app->getModuleResult($Module);

if (StanzaDelCittadinoBooking::factory()->isEnabled() && StanzaDelCittadinoBridge::factory()->getTenantUri()) {
    $tpl = eZTemplate::factory();
    $serviceId = $http->hasGetVariable('service_id') ? (int)$http->getVariable('service_id') : 0;
    $service = $serviceId > 0 ? eZContentObject::fetch($serviceId) : null;
    $tpl->setVariable('service_id', $serviceId);
    $tpl->setVariable('service', $service);
    if (!$service && StanzaDelCittadinoBooking::factory()->isServiceDiscoverEnabled()) {
        $tpl->setVariable('services_categories', StanzaDelCittadinoBooking::factory()->getServicesByCategories());
        $Result['content'] = $tpl->fetch('design:bootstrapitalia/booking/service_discover.tpl');
    } else {
        $offices = StanzaDelCittadinoBooking::factory()->getOffices($serviceId);
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
                    'name' => $month . ' ' . $currentYear,
                ];
            } else {
                $next[] = [
                    'index' => ($currentYear + 1) . '-' . str_pad($i, 2, '0', STR_PAD_LEFT),
                    'name' => $month . ' ' . ($currentYear + 1),
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
        $tpl->setVariable('months', $months);
        $tpl->setVariable('offices', $offices);
        $tpl->setVariable('steps', StanzaDelCittadinoBooking::factory()->getSteps());

        try {
            $remoteService = StanzaDelCittadinoBridge::factory()->getServiceByIdentifier('bookings');
            $satisfyEntrypointId = $remoteService['satisfy_entrypoint_id'] ?? null;
        } catch (Throwable $exception) {
            eZDebug::writeError($exception->getMessage(), __FILE__);
            $satisfyEntrypointId = null;
        }
        $tpl->setVariable('built_in_app_satisfy_entrypoint', $satisfyEntrypointId);

        $tpl->setVariable(
            'show_debug',
            eZINI::instance()->variable('DebugSettings', 'DebugOutput') == 'enabled' ? 'true' : 'false'
        );
        $calendars = [];
        foreach ($offices as $office) {
            foreach ($office['places'] as $place) {
                $calendars = array_merge($calendars, $place['calendar_names']);
            }
        }
        $tpl->setVariable('calendars_json', json_encode($calendars));

        $Result['content_info']['persistent_variable']['show_path'] = false;

        $Result['content'] = $tpl->fetch('design:bootstrapitalia/booking.tpl');
    }
}
