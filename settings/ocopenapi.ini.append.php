<?php /* #?ini charset="utf-8"?

[EndpointFactoryProvider]
ProviderList[]=TrasparenzaEndpointFactoryProvider
ProviderList[]=ServiceCategoryEndpointFactoryProvider
ProviderList[]=BookingEndpointFactoryProvider

[TrasparenzaEndpoints]
# Albero della trasparenza a cui agganciare l'endpoint /cig: c1 (Amministrazione Trasparente) o c2 (Societa trasparente)
Tree=c1

[RoleDiscover]
Exclude[]=Editor Trasparenza

[ContentMetaSettings]
ContentMetaPropertyFactories[privacy]=PrivacyStatusFactoryProvider
ContentMetaPropertyFactories[pagina_trasparenza/page]=PagineTrasparenzaPageFactoryProvider
ContentMetaPropertyFactories[topic/parent_topic]=ParentTopicObjectFactoryProvider

[ClassAttributeSettings]
ClassAttributePropertyFactories[lotto/id]=InternalIdFactoryProvider
ClassAttributePropertyFactories[bando/id]=InternalIdFactoryProvider
ClassAttributePropertyFactories[openpacomuniitaliani]=OpenPAComuniItalianiFactoryProvider
ClassAttributePropertyFactories[openpaalbosequential]=OpenPAAlboSequentialFactoryProvider
*/ ?>
