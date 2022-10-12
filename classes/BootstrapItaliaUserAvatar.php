<?php

class BootstrapItaliaUserAvatar
{

    public static function clearCache()
    {
        $commonPath = eZDir::path(array(eZSys::cacheDirectory()));
        $fileHandler = eZClusterFileHandler::instance();
        $commonSuffix = '';
        $fileHandler->fileDeleteByDirList(array('avatars'), $commonPath, $commonSuffix);
    }

    public static function streamDefault()
    {
        $avatar = new LasseRafn\InitialAvatarGenerator\InitialAvatar();
        $avatar->background('#666666');
        $avatar->color('#ffffff');
        $avatar->name('?');
        $avatar->size(20);
        echo $avatar->generate()->stream('png', 100);
    }

    /**
     * @param $id
     * @return eZClusterFileHandlerInterface
     */
    public static function getById($id)
    {
        $cachePath = eZDir::path(array(eZSys::cacheDirectory(), 'ocopendata', 'avatars', $id . '.png'));
        $cacheFileHandler = eZClusterFileHandler::instance($cachePath);
        $cacheFileHandler->processCache(
            function ($file, $mtime, $identifier) {},
            function ($file, $args) {
                $id = $args['id'];
                $object = eZContentObject::fetch((int)$id);
                $avatar = new LasseRafn\InitialAvatarGenerator\InitialAvatar();
                if ($object instanceof eZContentObject){
                    $avatar->name($object->attribute('name'));
                }else{
                    $avatar->background('#000000');
                    $avatar->color('#ffffff');
                    $avatar->name('?');
                }
                $avatar->size(20);
                $content = $avatar->generate()->stream('png', 100);
                eZLog::write("Create avatar for user $id", 'sensor.log');
                return array(
                    'binarydata' => $content,
                    'scope' => 'avatar-cache',
                    'datatype' => 'image/png',
                    'store' => true
                );
            },
            -1,
            null,
            array('id' => $id)
        );

        return $cacheFileHandler;
    }
}