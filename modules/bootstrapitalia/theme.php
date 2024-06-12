<?php

$module = $Params['Module'];
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();

$themeList = array();
$currentDesign = eZINI::instance()->variable('DesignSettings', 'SiteDesign');
$files = eZDir::findSubitems("extension/openpa_bootstrapitalia/design/$currentDesign/_build/src/scss", 'f');
if (empty($files)){
    $additionalSiteDesignList = eZINI::instance()->variable('DesignSettings', 'AdditionalSiteDesignList');
    foreach ($additionalSiteDesignList as $additionalSiteDesign){
        if (strpos($additionalSiteDesign, 'bootstrapitalia') === 0){
            $files = eZDir::findSubitems("extension/openpa_bootstrapitalia/design/$additionalSiteDesign/_build/src/scss", 'f');
            break;
        }
    }
}
foreach ($files as $file) {
    $filename = basename($file);
    $parts = explode('.', $filename);
    array_pop($parts);
    $filename = implode('.', $parts);
    if (substr($filename, 0, 1) !== '_' && substr($filename, 0, 16) !== 'bootstrap-italia'){
        $themeList[] = $filename;
    }
}
sort($themeList);

if ($http->hasPostVariable('StoreTheme') && $http->hasPostVariable('Theme')) {
    $theme = trim($http->postVariable('Theme'));
    $useLightSlim = $http->hasPostVariable('use_light_slim') ? '::light_slim' : '';
    $useLightCenter = $http->hasPostVariable('use_light_center') ? '::light_center' : '';
    $useLightNavbar = $http->hasPostVariable('use_light_navbar') ? '::light_navbar' : '';
    $themeString = $theme.$useLightSlim.$useLightCenter.$useLightNavbar;

    if (!in_array($theme, $themeList)) {
        $tpl->setVariable('message', 'Errore: tema non supportato');
    } else {
        $save = OpenPAINI::set("GeneralSettings", "theme", $themeString);
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

$tpl->setVariable('current_base_theme', OpenPABootstrapItaliaOperators::getCurrentTheme()->getBaseIdentifier());
$tpl->setVariable('use_light_slim', OpenPABootstrapItaliaOperators::getCurrentTheme()->hasVariation('light_slim'));
$tpl->setVariable('use_light_center', OpenPABootstrapItaliaOperators::getCurrentTheme()->hasVariation('light_center'));
$tpl->setVariable('use_light_navbar', OpenPABootstrapItaliaOperators::getCurrentTheme()->hasVariation('light_navbar'));
$tpl->setVariable('theme_list', $themeList);
if (count($themeList) == 0) {
    $tpl->setVariable('message', 'Impostazione non configurabile per il tema grafico corrente');
}

$tpl->setVariable('site_title', 'Impostazioni tema');

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
if (is_array($tpl->variable('persistent_variable'))) {
    $Result['content_info']['persistent_variable'] = array_merge($Result['content_info']['persistent_variable'], $tpl->variable('persistent_variable'));
}
$Result['path'] = array();
