<?php

class ExtraIndexProvider implements ezpRestProviderInterface
{
    public function getRoutes()
    {
        $version = 1;
        return [
            'extraIndex' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/',
                'ExtraIndexController',
                'endpoint',
                [],
                'http-get'
            ), $version),
            'postExtraIndex' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/document',
                'ExtraIndexController',
                'post',
                [],
                'http-post'
            ), $version),
            'getExtraIndex' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/document/:item',
                'ExtraIndexController',
                'get',
                [],
                'http-get'
            ), $version),
            'deleteExtraIndex' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/document/:item',
                'ExtraIndexController',
                'delete',
                [],
                'http-delete'
            ), $version),
            'putExtraIndex' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/document/:item',
                'ExtraIndexController',
                'put',
                [],
                'http-put'
            ), $version),
        ];
    }

    public function getViewController()
    {
        return new ExtraIndexViewController();
    }

}
