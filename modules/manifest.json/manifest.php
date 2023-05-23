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
echo json_encode($data);
eZExecution::cleanExit();