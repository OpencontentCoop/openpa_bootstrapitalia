<?php

function handleIconDownload(
    $contentObject,
    $contentObjectAttribute
) {
    $version = $contentObject->attribute('current_version');
    $fileInfo = $contentObjectAttribute->storedFileInformation(
        $contentObject,
        $version,
        $contentObjectAttribute->attribute('language_code')
    );
    $fileName = $fileInfo['filepath'];

    $file = eZClusterFileHandler::instance($fileName);

    if ($fileName != "" and $file->exists()) {
        $fileSize = $file->size();
        $fileOffset = 0;
        $contentLength = $fileSize;
        $mimeinfo = $file->dataType();
        header("Content-Type: {$mimeinfo}");
        header("Content-Disposition: inline");
        header("Content-Length: $fileSize");
        header('Content-Transfer-Encoding: binary');
        header('Accept-Ranges: bytes');
        header( "Pragma: " );
        header( "Last-Modified: " );
        header( "Expires: ". gmdate( 'D, d M Y H:i:s', time() + 600 ) . ' GMT' );

        $file->passthrough($fileOffset, $contentLength);
    }
    return eZBinaryFileHandler::RESULT_UNAVAILABLE;
}

eZSession::stop();
ob_end_clean();

$result = eZBinaryFileHandler::RESULT_UNAVAILABLE;
$home = OpenPaFunctionCollection::fetchHome();
if ($home instanceof eZContentObjectTreeNode) {
    $dataMap = $home->dataMap();
    if (isset($dataMap['favicon']) && $dataMap['favicon']->hasContent()) {
        $fileHandler = eZBinaryFileHandler::instance();
        $result = handleIconDownload($home->object(), $dataMap['favicon']);
    }
}

if ($result == eZBinaryFileHandler::RESULT_UNAVAILABLE) {
    $fallback = 'AAABAAEAEBAQAAEABAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAgAAAAAAAAAAAAAAAEAAAAAAAAAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
    header("Content-Type: image/png");
    echo base64_decode($fallback);
}

header("HTTP/1.1 200 OK");
header('Cache-Control: public, must-revalidate, max-age=259200, s-maxage=259200');
eZExecution::cleanExit();
