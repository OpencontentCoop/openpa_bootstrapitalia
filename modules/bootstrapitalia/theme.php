<?php

$module = $Params['Module'];
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();

$themeList = array();
$files = eZDir::recursiveFind('extension/openpa_bootstrapitalia/src', '.scss');
foreach ($files as $file) {
    $filename = basename($file);
    $parts = explode('.', $filename);
    array_pop($parts);
    $filename = implode('.', $parts);
    if (substr($filename, 0, 1) !== '_'){
        $themeList[] = $filename;
    }
}
sort($themeList);

if ($http->hasPostVariable('StoreTheme') && $http->hasPostVariable('Theme')) {
    $theme = trim($http->postVariable('Theme'));
    if (!in_array($theme, $themeList)) {
        $tpl->setVariable('message', 'Errore: tema non supportato');
    } else {
        $save = OpenPAINI::set("GeneralSettings", "theme", $theme);
        if ($save) {
            $tpl->setVariable('message', 'Impostazioni salvate correttamente');

            eZCache::clearByTag('template');

            eZExtension::getHandlerClass(new ezpExtensionOptions(array('iniFile' => 'site.ini',
                'iniSection' => 'ContentSettings',
                'iniVariable' => 'StaticCacheHandler')))->generateCache(true, true);

            return $module->redirectTo('bootstrapitalia/theme');

        } else {
            $tpl->setVariable('message', 'Errore!');
        }
    }
}

$tpl->setVariable('current_theme', OpenPAINI::variable("GeneralSettings", "theme", false));
$tpl->setVariable('theme_list', $themeList);
if (count($themeList) == 0) {
    $tpl->setVariable('message', 'Impostazione non configurabile per il tema grafico corrente');
}

$Result = array();
$Result['content'] = $tpl->fetch('design:bootstrapitalia/theme.tpl');
$Result['content_info'] = array(
    'node_id' => null,
    'class_identifier' => null,
    'persistent_variable' => array(
        'show_path' => true,
        'site_title' => 'Impostazioni tema'
    )
);
$Result['path'] = array();
