<?php

$path = '';
if ( isset( $Params ) && is_array( $Params ) && !empty( $Params['path'] ) ) {
    $path = $Params['path'];
}

$pathTranslationMap = [
    'prenota_appuntamento' => 'Book an appointment',
    'segnala_disservizio'  => 'Report a inefficiency',
    'richiedi_assistenza'  => 'Request assistance',
];

$siteName = '';
$ini = eZINI::instance();
if ( $ini->hasVariable( 'SiteSettings', 'SiteName' ) ) {
    $siteName = $ini->variable( 'SiteSettings', 'SiteName' );
}

$displayName = $siteName;
$urlBase = '/';

if ( $path !== '' && isset( $pathTranslationMap[$path] ) ) {

    $pathLabel = ezpI18n::tr( 'bootstrapitalia/footer', $pathTranslationMap[$path] );
    $displayName = trim( $pathLabel . ' - ' . $siteName );
    $urlBase .= $path;
}

$data = [
    'name'                       => $displayName,
    'short_name'                 => $displayName,
    'icons'                      => [
        [
            'src'                => '/extension/openpa_bootstrapitalia/design/standard/images/svg/web-app-manifest-192x192.png',
            'type'               => 'image/png',
            'sizes'              => '192x192',
            'purpose'            => 'maskable',
        ],
        [
            'src'                => '/extension/openpa_bootstrapitalia/design/standard/images/svg/web-app-manifest-512x512.png',
            'type'               => 'image/png',
            'sizes'              => '512x512',
            'purpose'            => 'maskable',
        ],
    ],
    'id'                         => $urlBase . '?source=pwa',
    'start_url'                  => $urlBase . '?source=pwa',
    'display'                    => 'standalone',
    'scope'                      => $urlBase,
    'prefer_related_applications' => true,
    'background_color'           => OpenPABootstrapItaliaOperators::getCurrentTheme()->getCssData( 'primary_color', '#005fff' ),
    'theme_color'                => OpenPABootstrapItaliaOperators::getCurrentTheme()->getCssData( 'primary_color', '#005fff' ),
    'offline_enabled'            => false,
];

header( 'Content-Type: application/json; charset=utf-8' );
header( 'Cache-Control: private, must-revalidate' );
echo json_encode( $data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE );
eZExecution::cleanExit();