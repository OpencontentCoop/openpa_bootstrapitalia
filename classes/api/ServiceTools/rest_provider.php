<?php

class ServiceToolsProvider implements ezpRestProviderInterface
{
    public function getRoutes()
    {
        $version = 1;
        return [
            'serviceToolsIndex' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/',
                'ServiceToolsController',
                'endpoint',
                [],
                'http-get'
            ), $version),
            'readServiceTools' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/service/:identifier',
                'ServiceToolsController',
                'getServiceByIdentifier',
                [],
                'http-get'
            ), $version),
            'installServiceTools' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/service/:identifier',
                'ServiceToolsController',
                'installServiceByIdentifier',
                [],
                'http-post'
            ), $version),
            'reinstallServiceTools' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/service/:identifier',
                'ServiceToolsController',
                'reinstallServiceByIdentifier',
                [],
                'http-put'
            ), $version),
            'syncStatusServiceTools' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/service/:identifier/status',
                'ServiceToolsController',
                'syncServiceStatusByIdentifier',
                [],
                'http-put'
            ), $version),
            'syncAccessUrlServiceTools' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/service/:identifier/access_url',
                'ServiceToolsController',
                'syncServiceAccessUrlByIdentifier',
                [],
                'http-put'
            ), $version),
            'syncBookingUrlServiceTools' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/service/:identifier/booking_call_to_action',
                'ServiceToolsController',
                'syncServiceBookingUrlByIdentifier',
                [],
                'http-put'
            ), $version),
            'getTenantInfo' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/tenant_info',
                'ServiceToolsController',
                'getTenantInfo',
                [],
                'http-get'
            ), $version),
            'getMetaInfo' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/meta_info',
                'ServiceToolsController',
                'getMetaInfo',
                [],
                'http-get'
            ), $version),
            'setTenantUrl' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/tenant_url',
                'ServiceToolsController',
                'setTenantUrl',
                [],
                'http-post'
            ), $version),
            'getTenantUrl' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/tenant_url',
                'ServiceToolsController',
                'getTenantUrl',
                [],
                'http-get'
            ), $version),
        ];
    }

    public function getViewController()
    {
        return new ServiceToolsViewController();
    }

}
