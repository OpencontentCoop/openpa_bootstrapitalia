<?php

$data = [
    'name' => eZINI::instance()->variable('SiteSettings', 'SiteName'),
    'icons' => [
        [
            'src' => '/extension/openpa_bootstrapitalia/design/standard/images/svg/icon.png',
            'type' => 'image/png',
            'sizes' => '512x512',
            'purpose' => 'any',
        ],
        [
            'src' => '/extension/openpa_bootstrapitalia/design/standard/images/svg/icon.png',
            'type' => 'image/png',
            'sizes' => '512x512',
            'purpose' => 'maskable',
        ],
    ],
    'id' => '/?source=pwa',
    'start_url' => '/?source=pwa',
    'display' => 'minimal-ui',
    'scope' => '/',
    'prefer_related_applications' => true,
    'background_color' => OpenPABootstrapItaliaOperators::getCurrentTheme()->getCssData('primary_color', '#222'),
    'theme_color' => OpenPABootstrapItaliaOperators::getCurrentTheme()->getCssData('primary_color', '#222'),
    'offline_enabled' => false,
];

header('Content-Type: application/json');
#header('Cache-Control: public, must-revalidate, max-age=10, s-maxage=259200');
header('Cache-Control: private, must-revalidate');
echo json_encode($data);
eZExecution::cleanExit();
