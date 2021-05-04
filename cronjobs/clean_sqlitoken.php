<?php

$cli->output('Stop al running imports and clean sqlitoken');

$runningItems = SQLIImportItem::fetchRunning();
foreach ($runningItems as $runningItem) {
    $cli->output('Stop #' . $runningItem->attribute('id') . ' ' . $runningItem->attribute('handler'));
    $runningItem->setAttribute('status', SQLIImportItem::STATUS_INTERRUPTED);
    $runningItem->store();
}

SQLIImportToken::cleanAll();