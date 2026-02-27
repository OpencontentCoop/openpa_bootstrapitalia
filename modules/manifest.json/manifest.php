<?php

$data = [
    'name' => eZINI::instance()->variable('SiteSettings', 'SiteName'),
    'short_name' => eZINI::instance()->variable('SiteSettings', 'SiteName'),
    'icons' => [
        [
            'src' => '/extension/openpa_bootstrapitalia/design/standard/images/svg/web-app-manifest-192x192.png',
            'type' => 'image/png',
            'sizes' => '192x192',
            'purpose' => 'maskable',
        ],
        [
            'src' => '/extension/openpa_bootstrapitalia/design/standard/images/svg/web-app-manifest-512x512.png',
            'type' => 'image/png',
            'sizes' => '512x512',
            'purpose' => 'maskable',
        ],
    ],
    'id' => '/?source=pwa',
    'start_url' => '/?source=pwa',
    'display' => 'standalone',
    'scope' => '/',
    'prefer_related_applications' => true,
    'background_color' => OpenPABootstrapItaliaOperators::getCurrentTheme()->getCssData('primary_color', '#005fff'),
    'theme_color' => OpenPABootstrapItaliaOperators::getCurrentTheme()->getCssData('primary_color', '#005fff'),
    'offline_enabled' => false,
];

header('Content-Type: application/json');
#header('Cache-Control: public, must-revalidate, max-age=10, s-maxage=259200');
header('Cache-Control: private, must-revalidate');
echo json_encode($data);
eZExecution::cleanExit();
