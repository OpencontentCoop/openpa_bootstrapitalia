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
            'syncServiceTools' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/sync_service',
                'ServiceToolsController',
                'syncService',
                [],
                'http-post'
            ), $version),
            'installServiceTools' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/install_service',
                'ServiceToolsController',
                'installService',
                [],
                'http-post'
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
        ];
    }

    public function getViewController()
    {
        return new ServiceToolsViewController();
    }

}
