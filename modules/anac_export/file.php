<?php
/**
 * Serve un file di export ANAC (#479) gia' scritto su cluster storage da
 * OpenPABootstrapItalia\Anac\ExportPublisher. Nessun controllo di accesso:
 * si tratta di dati di trasparenza obbligatoriamente pubblici.
 *
 * @var eZModule $Module
 */
$Module = $Params['Module'];

$filename = isset($Params['Filename']) ? basename($Params['Filename']) : false;

if (!$filename || !preg_match('/^[a-zA-Z0-9_.\-]+$/', $filename)) {
    return $Module->handleError(eZError::KERNEL_NOT_FOUND, 'kernel');
}

$path = eZSys::cacheDirectory() . '/anac_export/' . $filename;
$fileHandler = eZClusterFileHandler::instance($path);

if (!$fileHandler->exists()) {
    return $Module->handleError(eZError::KERNEL_NOT_FOUND, 'kernel');
}

$extension = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
$contentType = $extension === 'json' ? 'application/json' : 'text/csv';

ob_get_clean();

header('Content-Type: ' . $contentType . '; charset=utf-8');
header('Content-Disposition: inline; filename="' . $filename . '"');
header('Cache-Control: public, max-age=3600');
echo $fileHandler->fetchContents();

eZExecution::cleanExit();
