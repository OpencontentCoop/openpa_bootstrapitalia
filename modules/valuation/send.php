<?php

$module = $Params['Module'];
$http = eZHTTPTool::instance();

try {
    $connector = new ValuationConnector('valuation');
    foreach ($_GET as $key => $value) {
        $connector->setParameter($key, $value);
    }
    $data = $connector->submitOk();
} catch (Exception $e) {
    $data = array(
        'error' => $e->getMessage(),
    );
    if ($http->hasGetVariable('debug')) {
        $data = array_merge($data, array(
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'trace' => explode("\n", $e->getTraceAsString()),
            'prev' => $e->getPrevious()
        ));
    }
}

if ($http->hasGetVariable('debug')) {
    echo '<pre>';
    print_r($data);
    eZDisplayDebug();
} else {
    header('Content-Type: application/json');
    echo json_encode($data);
}

eZExecution::cleanExit();