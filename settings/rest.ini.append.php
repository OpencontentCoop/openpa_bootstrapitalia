<?php /* #?ini charset="utf-8"?

[ApiProvider]
ProviderClass[extraindex]=ExtraIndexProvider
ProviderClass[servicetools]=ServiceToolsProvider
ProviderClass[inefficiency]=CollectInefficiencyProvider

[ExtraIndexController_CacheSettings]
ApplicationCache=disabled

[ServiceToolsController_CacheSettings]
ApplicationCache=disabled

[CollectInefficiencyController_CacheSettings]
ApplicationCache=disabled

[RouteSettings]
SkipFilter[]=ExtraIndexController_endpoint
SkipFilter[]=ServiceToolsController_endpoint
SkipFilter[]=CollectInefficiencyProvider_endpoint

[Authentication]
AuthenticationStyle=OpenApiBasicAuthStyle


*/ ?>
