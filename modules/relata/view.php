<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$id = (int)$Params['ID'];

$object = eZContentObject::fetch($id);
if (
    !$object instanceof eZContentObject
    || !$object->canRead()
    || $object->attribute('class_identifier') !== 'document'
) {
    return $Module->handleError(eZError::KERNEL_NOT_FOUND, 'kernel');
}

$pdf = new BootstrapItaliaPdf(
    $object,
    'design:relata/view.tpl',
    'relata_' . $object->attribute('id') . 'v' . $object->attribute('current_version') . '.pdf'
);

if (isset($_GET['debug'])) {
    echo $pdf->generateHtml();
    eZDisplayDebug();
    eZExecution::cleanExit();
}

try {
    $pdf->handleDownload();
    eZExecution::cleanExit();
} catch (Throwable $e) {
    eZDebug::writeError($e->getMessage(), __FILE__);
    return $Module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}
