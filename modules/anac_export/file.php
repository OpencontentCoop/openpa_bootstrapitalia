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

$path = eZSys::varDirectory() . '/anac_export/' . $filename;
$fileHandler = eZClusterFileHandler::instance($path);

if (!$fileHandler->exists()) {
    // Fallback per i file pubblicati prima del commit 0244e5f2 (5/10/2026),
    // quando ExportPublisher scriveva ancora su cacheDirectory(): se il dato
    // non e' piu' cambiato da allora, resolveAndPublish() non ha mai
    // riscritto il file sul nuovo path, quindi esiste ancora solo li'.
    $legacyPath = eZSys::cacheDirectory() . '/anac_export/' . $filename;
    $fileHandler = eZClusterFileHandler::instance($legacyPath);
    if (!$fileHandler->exists()) {
        return $Module->handleError(eZError::KERNEL_NOT_FOUND, 'kernel');
    }
}

$extension = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
$contentType = $extension === 'json' ? 'application/json' : 'text/csv';

ob_get_clean();

header('Content-Type: ' . $contentType . '; charset=utf-8');
header('Content-Disposition: inline; filename="' . $filename . '"');
header('Cache-Control: public, max-age=3600');
echo $fileHandler->fetchContents();

eZExecution::cleanExit();
