<?php /* #?ini charset="utf-8"?

[DataHandlers]
Handlers[remote_calendar]=DataHandlerRemoteCalendar

[BlockHandlers]
Handlers[ListaManuale/*]=OpenPABootstrapItaliaBlockHandlerListaManuale
Handlers[ListaAutomatica/*]=OpenPABootstrapItaliaBlockHandlerLista
Handlers[ListaPaginata/*]=OpenPABootstrapItaliaBlockHandlerListaPaginata

[ObjectHandlerServices]
Services[content_icon]=ObjectHandlerServiceContentIcon
Services[content_show_history]=ObjectHandlerServiceContentShowHistory
Services[content_show_modified]=ObjectHandlerServiceContentShowModified
Services[content_tree_related]=ObjectHandlerServiceContentTreeRelated
Services[content_show_published]=ObjectHandlerServiceContentShowPublished
Services[content_trasparenza]=ObjectHandlerServiceContentTrasparenza
Services[content_tag_menu]=ObjectHandlerServiceContentTagMenu
Services[opengraph]=ObjectHandlerServiceOpengraph
Services[content_show_info_collector]=ObjectHandlerServiceShowContentInfoCollector

[ViewSettings]
AvailableView[]=card
AvailableView[]=card_children
AvailableView[]=banner
AvailableView[]=card_teaser
AvailableView[]=card_image
AvailableView[]=banner_color

[ContentMain]
Identifiers[]=image
Identifiers[]=ruolo
Identifiers[]=ruolo2
Identifiers[]=oggetto
Identifiers[]=abstract
Identifiers[]=short_description
Identifiers[]=description
Identifiers[]=event_abstract
AbstractIdentifiers[]=abstract
AbstractIdentifiers[]=short_description
AbstractIdentifiers[]=oggetto
AbstractIdentifiers[]=event_abstract

[Attributi]
AttributiAbstract[]=event_abstract
AttributiAbstract[]=description

[Menu]
IgnoraVirtualizzazione=enabled

[SideMenu]
IdentificatoriMenu[]=topic
IdentificatoriMenu_trasparenza[]
IdentificatoriMenu_trasparenza[]=pagina_trasparenza

[Trasparenza]
MostraAvvisoPaginaVuota=disabled

[MotoreRicerca]
IncludiClassi[]=administrative_area
IncludiClassi[]=topic
IncludiClassi[]=article
IncludiClassi[]=dataset
IncludiClassi[]=employee
IncludiClassi[]=document
IncludiClassi[]=event
IncludiClassi[]=place
IncludiClassi[]=private_organization
IncludiClassi[]=public_organization
IncludiClassi[]=pagina_sito
IncludiClassi[]=pagina_trasparenza
IncludiClassi[]=politico
IncludiClassi[]=online_contact_point
IncludiClassi[]=public_service
#IncludiClassi[]=trasparenza
IncludiClassi[]=political_body
IncludiClassi[]=office

[ExcludedClassesAsChild]
FromFolder[]
FromFolder[]=global_layout
FromFolder[]=infobox

[AttributeHandlers]
#Handlers[datatype/classIdentifier/attributeIdentifier]=PhpClassname
Handlers[ezinteger/*/*]=OpenPAAttributeIntegerHandler

[WebsiteToolbar]
ShowEditorRoles=disabled

[GeneralSettings]
AnnounceKit=BvwBO
Valuation=1

[RelationsBrowse]
AllowAllBrowse=enabled
#AllowAllBrowseAttributes[]=article/attachment

[AreeTematiche]
IdentificatoreAreaTematica[]

[HideRelationsTitle]
AttributeIdentifiers[]
AttributeIdentifiers[]=has_spatial_coverage
AttributeIdentifiers[]=has_online_contact_point
AttributeIdentifiers[]=opening_hours_specification
AttributeIdentifiers[]=has_channel

[NetworkSettings]
SyncTrasparenza=disabled

[CreditsSettings]
ShowCredits=enabled

*/ ?>
