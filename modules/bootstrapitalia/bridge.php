<?php

/** @var eZModule $module */
$module = $Params['Module'];
$tpl = eZTemplate::factory();
$action = $Params['Action'];
$parameter = $Params['Parameter'];

if ($action === 'push-openagenda-place') {
    try {
        OpenAgendaBridge::factory()->pushPlace((int)$parameter);
        $module->redirectTo('/openpa/object/' . (int)$parameter);
    } catch (Throwable $e) {
        $error = $e->getMessage();
        $Result = [];
        $errorTitle = ezpI18n::tr("design/admin/contentstructuremenu", 'Internal error');
        $Result['content'] = '<h2>' . $errorTitle . '</h2><div class="alert alert-danger my-5">' . $error . '</div>';
        $Result['path'] = [];
        $Result['content_info'] = [
            'node_id' => null,
            'class_identifier' => null,
        ];
    }
}