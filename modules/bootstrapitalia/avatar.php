<?php
$id = (int)$Params['ID'];
if ($id !== (int)eZUser::currentUserID()){
    header("Content-Type: image/png");
    BootstrapItaliaUserAvatar::streamDefault();
    eZExecution::cleanExit();
}

$maxAge = 2592000;

if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE'])) {
    header($_SERVER['SERVER_PROTOCOL'] . ' 304 Not Modified');
    header('Expires: ' . gmdate('D, d M Y H:i:s', time() + $maxAge) . ' GMT');
    header('Cache-Control: max-age=' . $maxAge);
    header('Last-Modified: ' . gmdate('D, d M Y H:i:s', strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE'])) . ' GMT');
    header('Pragma: ');

}else {
    $cacheFileHandler = BootstrapItaliaUserAvatar::getById($id);
    $filesize = $cacheFileHandler->size();
    $mtime = $cacheFileHandler->mtime();
    $datatype = $cacheFileHandler->dataType();

    header("Content-Type: {$datatype}");
    header("Connection: close");
    header('Served-by: ' . $_SERVER["SERVER_NAME"]);
    header("Last-Modified: " . gmdate('D, d M Y H:i:s', $mtime) . ' GMT');
    header("ETag: $mtime-$filesize");
    header("Cache-Control: max-age=$maxAge s-max-age=$maxAge");
    header('Expires: ' . gmdate('D, d M Y H:i:s', time() + $maxAge) . ' GMT');

    $cacheFileHandler->passthrough();
}
eZExecution::cleanExit();