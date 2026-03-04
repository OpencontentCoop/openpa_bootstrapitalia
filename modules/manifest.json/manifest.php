<?php

$http = eZHTTPTool::instance();
$app = $http->hasGetVariable('app') ? $http->getVariable('app') : false;

$appTranslationMap = [
    'booking' => ['label' => 'Book an appointment', 'scope' => 'prenota_appuntamento'],
    'segnala_disservizio' => ['label' => 'Report a inefficiency', 'scope' => 'segnala_disservizio'],
    'richiedi_assistenza' => ['label' => 'Request assistance', 'scope' => 'richiedi_assistenza'],
];

$siteName = '';
$ini = eZINI::instance();
if ($ini->hasVariable('SiteSettings', 'SiteName')) {
    $siteName = $ini->variable('SiteSettings', 'SiteName');
}

$displayName = $siteName;
$urlBase = '/';

if ($appTranslationMap[$app]) {
    $appLabel = ezpI18n::tr('bootstrapitalia/footer', $appTranslationMap[$app]['label']);
    $displayName = trim($appLabel . ' - ' . $siteName);
    $urlBase .= $appTranslationMap[$app]['scope'];
}

$appleTouchIconUrl = false;
$home = OpenPaFunctionCollection::fetchHome();
if ($home instanceof eZContentObjectTreeNode) {
    $dataMap = $home->dataMap();
    if (isset($dataMap['apple_touch_icon']) && $dataMap['apple_touch_icon']->hasContent()) {
        /** @var \eZBinaryFile $file */
        $file = $dataMap['apple_touch_icon']->content();

        $appleTouchIconUrl = 'content/download/' . $dataMap['apple_touch_icon']->attribute('contentobject_id')
            . '/' . $dataMap['apple_touch_icon']->attribute('id')
            . '/' . $dataMap['apple_touch_icon']->attribute('version')
            . '/' . urlencode($file->attribute('original_filename'));
        eZURI::transformURI($appleTouchIconUrl, true, 'full');
    }
}

function getManifestImageUrl($size = 192, $imageUrl): string
{
    if (!$imageUrl){
        $imageUrl = 'https://' . eZINI::instance()->variable('SiteSettings', 'SiteURL') 
            . "/extension/openpa_bootstrapitalia/design/standard/images/svg/web-app-manifest-{$size}x{$size}.png";
    }
    if (OpenPAINI::variable('ImageSettings', 'FlyImgBaseUrl', '') !== '') {
        $filter = "/w_{$size},h_{$size}/";
        $baseUrl = rtrim(OpenPAINI::variable('ImageSettings', 'FlyImgBaseUrl'), '/');
        $imageUrl = $baseUrl . $filter . urlencode($imageUrl);
    }
    return $imageUrl;
}

$data = [
    'name' => $displayName,
    'short_name' => $displayName,
    'icons' => [
        [
            'src' => getManifestImageUrl(192, $appleTouchIconUrl),
            'type' => 'image/png',
            'sizes' => '192x192',
            'purpose' => 'maskable',
        ],
        [
            'src' => getManifestImageUrl(512, $appleTouchIconUrl),
            'type' => 'image/png',
            'sizes' => '512x512',
            'purpose' => 'maskable',
        ],
    ],
    'id' => $urlBase . '?source=pwa',
    'start_url' => $urlBase . '?source=pwa',
    'display' => 'standalone',
    'scope' => $urlBase,
    'prefer_related_applications' => true,
    'background_color' => OpenPABootstrapItaliaOperators::getCurrentTheme()->getCssData('primary_color', '#005fff'),
    'theme_color' => OpenPABootstrapItaliaOperators::getCurrentTheme()->getCssData('primary_color', '#005fff'),
    'offline_enabled' => false,
];

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: public, must-revalidate, max-age=300, s-maxage=300');
echo json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
eZExecution::cleanExit();