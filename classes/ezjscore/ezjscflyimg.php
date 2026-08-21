<?php

class ezjscFlyImg extends ezjscServerFunctions
{
    /**
     * @param array $args
     * @return array
     */
    public static function config($args)
    {
        $baseUrl = rtrim(OpenPAINI::variable('ImageSettings', 'FlyImgBaseUrl', ''), '/');

        return array(
            'enabled' => $baseUrl !== '',
            'baseUrl' => $baseUrl,
            'backendBaseUrl' => OpenPAINI::variable('ImageSettings', 'BackendBaseUrl', ''),
            'backendBaseScheme' => OpenPAINI::variable('ImageSettings', 'BackendBaseScheme', ''),
            'defaultFilter' => OpenPAINI::variable('ImageSettings', 'FlyImgDefaultFilter', ''),
            'filters' => array(
                'reference' => array('w' => 2500, 'h' => 2500),
                'large' => array('w' => 800, 'h' => 800),
                'imagelargeoverlay' => array('w' => 800, 'h' => 800),
                'medium' => array('w' => 400, 'h' => 400),
                'small' => array('w' => 200, 'h' => 200),
                'mini' => array('w' => 180, 'h' => 180),
                'rss' => array('w' => 100, 'h' => 100),
            ),
        );
    }
}
