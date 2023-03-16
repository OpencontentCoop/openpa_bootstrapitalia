<?php /* #?ini charset="utf-8"?

[StanzaDelCittadinoBridge]
AutoDiscover=enabled
BuiltInWidgetSource_inefficiency=https://download.stanzadelcittadino.it/assets/js/inefficiency/main.js
BuiltInWidgetSource_support=https://download.stanzadelcittadino.it/assets/js/request/main.js
BuiltInWidgetSource_booking=https://static.opencityitalia.it/widgets/bookings/version/1.0.0/js/bookings.js
BuiltInWidgetSource_satisfy=https://satisfy.opencontent.it/widget_ns.js

[AccessPage]
Title=Accedi
Intro=Per accedere al sito e ai suoi servizi, utilizza una delle seguenti modalità.

SpidAccess=enabled
CieAccess=disabled

Others[]
Others[]=EditorAccess
Others[]=OperatorAccess
#Others[]=ExampleAccess

SpidAccess_Title=SPID
SpidAccess_Intro=Accedi con SPID, il sistema Pubblico di Identità Digitale.
SpidAccess_ButtonText=Entra con SPID
SpidAccess_HelpText=Come attivare SPID
SpidAccess_HelpLink=https://www.spid.gov.it/cos-e-spid/come-attivare-spid/

CieAccess_Title=CIE
CieAccess_Intro=Accedi con la tua Carta d’Identità Elettronica.
CieAccess_ButtonText=Entra con CIE
CieAccess_HelpText=Come richiedere CIE
CieAccess_HelpLink=https://www.cartaidentita.interno.gov.it/argomenti/richiesta-cie/"

Others_Title=Altre utenze
Others_Intro=In alternativa puoi utilizzare le seguenti modalità.

EditorAccess_Title=Accedi come redattore del sito
OperatorAccess_Title=Accedi come operatore comunale

#ExampleAccess_Title=Accedi con esempio
#ExampleAccess_Link=https://...

[DataHandlers]
Handlers[remote_calendar]=DataHandlerRemoteCalendar
Handlers[theme]=DataHandlerTheme
Handlers[block_opendata_queried_contents]=DataHandlerOpendataQueriedContents
Handlers[meta]=DataHandlerMeta

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
Services[data_element]=ObjectHandlerServiceDataElement

[ViewSettings]
AvailableView[]=card
AvailableView[]=card_children
AvailableView[]=banner
AvailableView[]=card_teaser
AvailableView[]=card_image
AvailableView[]=banner_color
AvailableView[]=card_simple
AvailableView[]=card_teaser_info
AvailableView[]=latest_messages_item

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
HeaderLinksLimit=3

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
IncludiClassi[]=organization
IncludiClassi[]=person
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
UniqueStringCheck[]
#UniqueStringCheck[]=document/has_code
#UniqueStringCheck[]=lotto/cig
#UniqueStringCheck[]=public_service/identifier
DefaultIntegerIsNull[]
DefaultIntegerIsNull[]=public_service/average_processing_time
DefaultIntegerIsNull[]=public_service/has_processing_time

[WebsiteToolbar]
ShowEditorRoles=disabled

[GeneralSettings]
#AnnounceKit=BvwBO
AnnounceKit=disabled
Valuation=1
ShowRssInSocialList=disabled
ShowUeLogo=enabled
HideSlimHeaderIfUseless=disabled

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

[CookiesSettings]
#simple or advanced
Consent=advanced
*/ ?>
