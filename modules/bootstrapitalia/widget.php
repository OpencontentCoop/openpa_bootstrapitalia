<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$http = eZHTTPTool::instance();

$builtin = $Params['Identifier'] ?? null;
if (!$builtin || !in_array($builtin, ['booking', 'support', 'inefficiency', 'service-form'])) {
    $tpl = eZTemplate::factory();
    $Result = [];
    $Result['path'] = [];
    $contentInfoArray = [
        'node_id' => null,
        'class_identifier' => null,
    ];
    $contentInfoArray['persistent_variable'] = [];
    if (is_array($tpl->variable('persistent_variable'))) {
        $contentInfoArray['persistent_variable'] = array_merge(
            $contentInfoArray['persistent_variable'],
            $tpl->variable('persistent_variable')
        );
    }
    $Result['content_info'] = $contentInfoArray;
    $Result['content'] = $tpl->fetch('design:bootstrapitalia/widget.tpl');
} else {
    if ($builtin === 'booking') {
        $app = new BuiltinApp('booking', 'Book an appointment');
    } elseif ($builtin === 'support') {
        $app = new BuiltinApp('support', 'Request assistance');
    } elseif ($builtin === 'inefficiency') {
        $app = new BuiltinApp('inefficiency', 'Report a inefficiency');
    } elseif ($builtin === 'service-form') {
        $app = new BuiltinApp('service-form', 'Compila');
    }
    if (isset($app)) {
        $Result = $app->getModuleResult();
    }
}
