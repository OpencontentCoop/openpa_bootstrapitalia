<?php /* #?ini charset="utf-8"?

[StanzaDelCittadinoBridge]
AutoDiscover=enabled
BuiltInWidgetSource_inefficiency=https://%host%/widgets/inefficiencies/bootstrap-italia@2/js/inefficiencies.js
#BuiltInWidgetStyle_inefficiency=https://%host%/widgets/inefficiencies/bootstrap-italia@2/css/inefficiencies.css
BuiltInWidgetSource_support=https://%host%/widgets/helpdesk/bootstrap-italia@2/js/helpdesk.js
BuiltInWidgetSource_booking=https://%host%/widgets/bookings/bootstrap-italia@2/js/bookings.js
BuiltInWidgetSource_satisfy=https://satisfy.opencontent.it/widget_ns.js

RootId_inefficiency=oc-inefficiencies
RootId_support=oc-helpdesk
RootId_booking=oc-bookings

ContactsField_inefficiency=link_segnalazione_disservizio
ContactsField_support=link_assistenza
ContactsField_booking=link_prenotazione_appuntamento

[AccessPage]
Title=Sign in
Intro=To access the site and its services, use one of the following methods.
EditorAccessTitle=Access reserved only for staff
EditorAccessIntro=

SpidAccess=enabled
CieAccess=disabled

SpidAccess_Title=SPID
SpidAccess_Intro=Log in with SPID, the public digital identity system.
SpidAccess_ButtonText=Log in with SPID
SpidAccess_HelpText=How to activate SPID?
SpidAccess_HelpLink=https://www.spid.gov.it/cos-e-spid/come-attivare-spid/

CieAccess_Title=CIE
CieAccess_Intro=Log in with your Electronic Identity Card.
CieAccess_ButtonText=Log in with CIE
CieAccess_HelpText=How to request CIE?
CieAccess_HelpLink=https://www.cartaidentita.interno.gov.it/argomenti/richiesta-cie/"

Others[]
#Others[]=ExampleAccess

Others_Title=Other types
Others_Intro=Alternatively you can use the following methods.

EditorAccessList[]
EditorAccessList[]=EditorAccess
EditorAccessList[]=OperatorAccess
EditorAccess_Title=Login as website editor
OperatorAccess_Title=Login to manage digital services

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
AvailableView[]=point_list
TopicCard=custom

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
ShowTopicsInOverview=enabled

[Attributi]
AttributiAbstract[]=event_abstract
AttributiAbstract[]=description
GeoMapLink=google

[Menu]
IgnoraVirtualizzazione=enabled
HeaderLinksLimit=3

[SideMenu]
IdentificatoriMenu[]=topic
IdentificatoriMenu_trasparenza[]
IdentificatoriMenu_trasparenza[]=pagina_trasparenza

[Trasparenza]
MostraAvvisoPaginaVuota=disabled
UseCustomTemplate=disabled

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
IncludiClassi[]=public_person
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
#DefaultIntegerIsNull[]=public_service/has_processing_time
#DefaultContent_has_processing_time=I tempi e le scadenze non sono al momento disponibili
DefaultContent_status_note=Il servizio online al momento non è disponibile

[WebsiteToolbar]
ShowEditorRoles=disabled

[GeneralSettings]
AnnounceKit=BvwBO
Valuation=1
ShowRssInSocialList=disabled
ShowUeLogo=enabled
HideSlimHeaderIfUseless=disabled
PerformanceLink=https://link.opencontent.it/piano-di-miglioramento-delle-performance

[InstanceSettings]
InstallerDirectory=./extension/openpa_bootstrapitalia/data/installer

[ImageSettings]
LazyLoadImages=disabled
FlyImgBaseUrl=
BackendBaseUrl=
#FlyImgBaseUrl=http://flyimg.localtest.me/upload/
#BackendBaseUrl=minio:9000
FlyImgDefaultFilter=o_auto

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
Partners[opencontent]=OpenContent|https://www.opencontent.it
Partners[opencitylabs]=OpenCity Labs|https://www.opencontent.it

[CookiesSettings]
#simple or advanced
Consent=advanced

[LockEdit_homepage]
EnableBackgroundImage=enabled
*/ ?>
