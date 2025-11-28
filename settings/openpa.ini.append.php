<?php /* #?ini charset="utf-8"?

[StanzaDelCittadinoBridge]
AutoDiscover=enabled
UseLoginBox=disabled
BuiltInWidgetSource_inefficiency=https://%host%/widgets/inefficiencies/bootstrap-italia@2/js/inefficiencies.js
BuiltInWidgetStyle_inefficiency=https://%host%/widgets/inefficiencies/css/inefficiencies.css

BuiltInWidgetSource_support=https://%host%/widgets/helpdesk/bootstrap-italia@2/js/helpdesk.js
BuiltInWidgetStyle_support=https://%host%/widgets/helpdesk/css/helpdesk.css

BuiltInWidgetSource_booking=https://%host%/widgets/bookings/bootstrap-italia@2/js/bookings.js
BuiltInWidgetStyle_booking=https://%host%/widgets/bookings/css/bookings.css

#BuiltInWidgetSource_satisfy=https://%host%/widgets/satisfy/js/satisfy.js
BuiltInWidgetSource_satisfy=https://static.opencityitalia.it/widgets/satisfy/version/1.5.6/js/satisfy.js

BuiltInWidgetSource_login=https://%host%/widgets/login-box/bootstrap-italia@2/js/login-box.js

BuiltInWidgetSource_service-form=https://static.opencityitalia.it/widgets/formio/latest/js/web-formio.js
BuiltInWidgetStyle_service-form=

#BuiltInWidgetSource_payment=https://%host%/widgets/payments-due/js/paymentsDue.js
#BuiltInWidgetStyle_payment=https://%host%/widgets/payments-due/css/paymentsDue.css
BuiltInWidgetSource_payment=https://static.opencityitalia.it/widgets/payments-due/version/1.0.5/js/paymentsDue.js
BuiltInWidgetStyle_payment=https://static.opencityitalia.it/widgets/payments-due/version/1.0.5/css/paymentsDue.css

#BuiltInWidgetSource_payments-area=https://%host%/widgets/personal-area/ap-personal-area.js
#BuiltInWidgetStyle_payments-area=https://%host%/widgets/personal-area/%theme%.css
uiltInWidgetSource_personal-area=https://static.opencityitalia.it/widgets/area-personale-cittadino/latest/js/ap-personal-area.js
BuiltInWidgetStyle_personal-area=https://static.opencityitalia.it/widgets/area-personale-cittadino/latest/css/%theme%.css

#BuiltInWidgetSource_payments-area=area=https://%host%/widgets/personal-area/ap-payments.js
#BuiltInWidgetStyle_payments-area=https://%host%/widgets/personal-area/%theme%.css
BuiltInWidgetSource_payments-area=https://static.opencityitalia.it/widgets/area-personale-cittadino/latest/js/ap-payments.js
BuiltInWidgetStyle_payments-area=https://static.opencityitalia.it/widgets/area-personale-cittadino/latest/css/%theme%.css

#BuiltInWidgetSource_documents-area=area=https://%host%/widgets/personal-area/ap-documents.js
#BuiltInWidgetStyle_documents-area=https://%host%/widgets/personal-area/%theme%.css
BuiltInWidgetSource_documents-area=https://static.opencityitalia.it/widgets/area-personale-cittadino/latest/js/ap-documents.js
BuiltInWidgetStyle_documents-area=https://static.opencityitalia.it/widgets/area-personale-cittadino/latest/css/%theme%.css

#BuiltInWidgetSource_operators-area=area=https://%host%/widgets/personal-area/ap-documents-operator.js
#BuiltInWidgetStyle_operators-area=https://%host%/widgets/personal-area/%theme%.css
BuiltInWidgetSource_operators-area=https://static.opencityitalia.it/widgets/area-personale-cittadino/latest/js/ap-documents-operator.js
BuiltInWidgetStyle_operators-area=https://static.opencityitalia.it/widgets/area-personale-cittadino/latest/css/%theme%.css

#BuiltInWidgetSource_applications-area=area=https://%host%/widgets/personal-area/personal-area.js
#BuiltInWidgetStyle_applications-area=https://%host%/widgets/personal-area/%theme%.css
BuiltInWidgetSource_applications-area=https://static.opencityitalia.it/widgets/area-personale-cittadino/latest/js/personal-area.js
BuiltInWidgetStyle_applications-area=https://static.opencityitalia.it/widgets/area-personale-cittadino/latest/css/%theme%.css


ApiUserLogin=
ApiUserPassword=

[InefficiencyCollector]
DefaultStatus[]
DefaultStatus[]=Aperta
DefaultStatus[]=Presa in carico

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
Handlers[instance]=DataHandlerInstance
Handlers[booking_config]=DataHandlerBookingConfig
Handlers[booking]=DataHandlerBooking
Handlers[albo_pretorio]=DataHandlerAlboPretorioContents

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
Services[event_link]=ObjectHandlerServiceEventLink
Services[content_analytics]=ObjectHandlerServiceContentAnalytics

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
AvailableView[]=fullpage
AvailableView[]=text_linked
TopicCard=custom
ForceCurrentSiteUrl=disabled
MainChannelHelpLink=disabled
MainChannelHelpLink_href=#
MainChannelHelpLink_text=Scopri come ottenere la tua identità digitale
FaqTreeView=disabled
ChildrenFilter=disabled
ShowYearInEventCard=disabled
ShowTitleInSingleBlock=disabled
ForceShowServiceChannel=disabled
ShowEmptyTopicsCards=disabled

[ChildrenFilters]
#Aree amministrative
Remotes[899b1ac505747c0d8523dfe12751eaae]=search
#Uffici
Remotes[a9d783ef0712ac3e37edb23796990714]=search
#Enti e fondazioni
Remotes[10742bd28e405f0e83ae61223aea80cb]=search
#Personale amministrativo
Remotes[3da91bfec50abc9740f0f3d62c8aaac4]=search-roles
#Politici
Remotes[50f295ca2a57943b195fa8ffc6b909d8]=search-roles

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
ShowBandoFaseSelect=enabled

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
IncludiClassi[]=public_project
IncludiClassi[]=insight
IncludiClassi[]=howto

[ExcludedClassesAsChild]
FromFolder[]
FromFolder[]=global_layout
FromFolder[]=infobox

[AttributeHandlers]
#Handlers[datatype/classIdentifier/attributeIdentifier]=PhpClassname
Handlers[ezobjectrelationlist/*/*]=OpenPAAttributeRelations
Handlers[ezinteger/*/*]=OpenPAAttributeIntegerHandler
Handlers[ezobjectrelationlist/howto/steps]=OpenPAAttributeRelationsWithoutPermissionHandler
Handlers[ezprice/*/*]=OpenPAAttributePriceHandler
UniqueStringCheck[]
#UniqueStringCheck[]=document/has_code
#UniqueStringCheck[]=lotto/cig
#UniqueStringCheck[]=public_service/identifier
UniqueStringCheck[]=public_project/identifier
UniqueStringCheck[]=bando/codice_identificativo_gara
UniqueStringAllowedValue[bando/codice_identificativo_gara]=in definizione
DefaultIntegerIsNull[]
DefaultIntegerIsNull[]=public_service/average_processing_time
DefaultIntegerIsNull[]=public_service/has_processing_time
#DefaultContent_has_processing_time=I tempi e le scadenze non sono al momento disponibili
DefaultContent_status_note=Il servizio online al momento non è disponibile
InputValidators[]
InputValidators[]=DocumentFileValidator
InputValidators[]=PublicServiceStatusValidator
InputValidators[]=PublicServiceProcessingTimeValidator
InputValidators[]=UniqueStringValidator
InputValidators[]=EventCostsValidator
InputValidators[]=EventContactPointValidator
InputValidators[]=EventPlacesValidator
#InputValidators[]=OneOfFieldValidator:class_identifier;attribute_identifier,attribute_identifier,...
InputValidators[]=OneOfFieldValidator:bando;pubblicazione,pubblicazione_relations,notes_pubblicazione
InputValidators[]=OneOfFieldValidator:bando;affidamento,affidamento_relations,notes_affidamento
InputValidators[]=OneOfFieldValidator:bando;esecutiva,esecutiva_relations,notes_esecutiva
InputValidators[]=OneOfFieldValidator:bando;sponsorizzazioni,sponsorizzazioni_relations,notes_sponsorizzazioni
InputValidators[]=OneOfFieldValidator:bando;somma_urgenza,somma_urgenza_relations,notes_somma_urgenza
InputValidators[]=OneOfFieldValidator:bando;finanza,finanza_relations,notes_finanza
MainContentFields[]
MainContentFields[]=name
MainContentFields[]=alternative_name
MainContentFields[]=alt_name
MainContentFields[]=type
MainContentFields[]=identifier
MainContentFields[]=content_type
MainContentFields[]=status_note
MainContentFields[]=has_public_event_typology
MainContentFields[]=document_type
MainContentFields[]=announcement_type
#MatrixColumnSuggestionByTag[class_identifier-attribute_identifier-column_identifier]=Root tag

[WebsiteToolbar]
ShowEditorRoles=disabled

[GeneralSettings]
AnnounceKit=BvwBO
Valuation=1
ShowRssInSocialList=disabled
ShowUeLogo=enabled
HideSlimHeaderIfUseless=disabled
PerformanceLink=https://link.opencontent.it/piano-di-miglioramento-delle-performance-sito
ShowFooterBanner=disabled
MinifyHtml=enabled

[InstanceSettings]
InstallerDirectory=./extension/openpa_bootstrapitalia/data/installer

[ImageSettings]
LazyLoadImages=disabled
FlyImgBaseUrl=
BackendBaseUrl=
BackendBaseScheme=
#FlyImgBaseUrl=http://flyimg.localtest.me/upload/
#BackendBaseUrl=minio:9000
#BackendBaseScheme=http
FlyImgDefaultFilter=o_auto
UseSizeAndSrcSet=disabled

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
AttributeIdentifiers[]=temporal

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
AllowRemoveMainNews=disabled
BoostSearchBlock=disabled
SectionNewsLimit=6
SectionManagementLimit=3
SectionCalendarLimit=6
SectionBannerLimit=9

[LockEdit_pagina_sito]
EnableTimelineRemoteIds[]
EnableTimelineRemoteIds[]=history
EnableDatasetMapRemoteIds[]
EnableDatasetMapRemoteIds[]=all-places

[OpenpaAgenda]
EnableDiscussion=enabled

[EditSettings]
ModerationInToolbar=disabled
AvoidInContextCreation[]
SelectImageFolder=disabled

[Seo]
AnalyticsSegments[]=type
AnalyticsSegments[]=organization
AnalyticsSegments[]=service

*/ ?>
