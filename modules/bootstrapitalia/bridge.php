<?php

/** @var eZModule $module */
$module = $Params['Module'];
$tpl = eZTemplate::factory();
$action = $Params['Action'];
$parameter = $Params['Parameter'];

if ($action === 'push-openagenda-place') {
    $tpl->setVariable('place', eZContentObject::fetch((int)$parameter));
    $tpl->setVariable('error', false);
    $tpl->setVariable('openageda_url', '#');

    if (OpenAgendaBridge::factory()->isEnabled()) {
        $tpl->setVariable('openageda_url', OpenAgendaBridge::factory()->getOpenAgendaUrl());
        try {
            if (eZHTTPTool::instance()->hasGetVariable('push')) {
                header('Content-Type: application/json');
                try {
                    [$payloads, $payloadCount] = OpenAgendaBridge::factory()->pushPlacePayloads((int)$parameter);
                    echo json_encode(['payloads' => $payloads, 'payloadCount' => $payloadCount]);
                } catch (Throwable $e) {
                    echo json_encode(['payloads' => 0, 'error' => $e->getMessage()]);
                }
                eZExecution::cleanExit();
            }
        } catch (Throwable $e) {
            $tpl->setVariable('error', $e->getMessage());
        }
    }else{
        $tpl->setVariable('error', 'Connector not enabled');
    }

    $Result = [];
    $Result['content'] = $tpl->fetch("design:bootstrapitalia/bridge/push_openagenda_place.tpl");
    $Result['path'] = [];
    $Result['content_info'] = [
        'node_id' => null,
        'class_identifier' => null,
    ];
}