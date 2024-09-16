<?php

class CollectInefficiencyProvider implements ezpRestProviderInterface
{
    public function getRoutes()
    {
        $version = 1;
        return [
            'collectInefficiency' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/',
                'CollectInefficiencyController',
                'endpoint',
                [],
                'http-get'
            ), $version),
            'postCollectInefficiency' => new ezpRestVersionedRoute(new OpenApiRailsRoute(
                '/collect',
                'CollectInefficiencyController',
                'collect',
                [],
                'http-post'
            ), $version),
        ];
    }

    public function getViewController()
    {
        return new CollectInefficiencyViewController();
    }

}
