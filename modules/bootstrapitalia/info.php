<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;

/** @var eZModule $module */
$module = $Params['Module'];
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();
$locale = eZLocale::currentLocaleCode();

/** only admin can view and edit hot zone */
$hasAdminAccess = eZUser::currentUser()->attribute('login') === 'admin';
$tpl->setVariable('has_access_to_hot_zone', $hasAdminAccess);
$tpl->setVariable('bridge_connection', StanzaDelCittadinoBridge::factory()->getApiBaseUri());
$tpl->setVariable('server_url', eZSys::instance()->serverURL());
$home = OpenPaFunctionCollection::fetchHome();

$tpl->setVariable('homepage',
    $home->attribute('class_identifier') === 'homepage' ? $home:  null
);

$partnersItems = [];
$partners = OpenPAINI::variable('CreditsSettings', 'Partners', []);
ksort($partners);
foreach ($partners as $identifier => $partner){
    [$name, $url] = explode('|', $partner, 2);
    $partnersItems[] = [
        'identifier' => $identifier,
        'name' => $name,
        'url' => $url,
    ];
}
$tpl->setVariable('partners', $partnersItems);
$tpl->setVariable('current_partner', OpenPABootstrapItaliaOperators::getCurrentPartner());

if ($http->hasPostVariable('ImportFrom') && $hasAdminAccess) {
    $remoteUrl = $http->postVariable('ImportFrom', '');
    try {
        eZDebug::writeDebug('Copy data from ' . $remoteUrl, __FILE__);
        SiteInfo::importFromUrl($remoteUrl);
        $module->redirectTo('/bootstrapitalia/info');
        return;
    } catch (Exception $e) {
        eZDebug::writeError($e->getMessage(), __FILE__);
        $tpl->setVariable('message', $e->getMessage());
    }
}

if ($http->hasPostVariable('UpdateBridgeTargetUser') && $http->hasPostVariable('UpdateBridgeTargetPassword') && $hasAdminAccess) {
    $user = $http->postVariable('UpdateBridgeTargetUser', '');
    $password = $http->postVariable('UpdateBridgeTargetPassword', '');
    try {
        StanzaDelCittadinoBridge::factory()->updateSiteInfo($user, $password);
        $module->redirectTo('/bootstrapitalia/info');
        return;
    } catch (Exception $e) {
        eZDebug::writeError($e->getMessage(), __FILE__);
        $tpl->setVariable('message', $e->getMessage());
    }
}

if ($http->hasPostVariable('SelectPartner') && $hasAdminAccess) {
    $selectedPartner = $http->postVariable('SelectPartner', '');
    if (empty($selectedPartner)){
        OpenPABootstrapItaliaOperators::removeCurrentPartner();
        $module->redirectTo('/bootstrapitalia/info');
        return;
    }elseif (isset($partners[$selectedPartner])){
        OpenPABootstrapItaliaOperators::setCurrentPartner($selectedPartner);
        $module->redirectTo('/bootstrapitalia/info');
        return;
    }else{
        eZDebug::writeError("Partner $selectedPartner not found", __FILE__);
        $tpl->setVariable('message', "Partner $selectedPartner not found");
    }
}

if ($http->hasPostVariable('EditorPerformanceMonitor') && $hasAdminAccess) {
    OpenPABootstrapItaliaOperators::setSentryScriptLoader($http->postVariable('EditorPerformanceMonitor'));
}
$sentryScriptLoader = OpenPABootstrapItaliaOperators::getSentryScriptLoader();
$tpl->setVariable('sentry_script_loader_url', $sentryScriptLoader);

if ($http->hasPostVariable('OpenAgendaBridge') && $hasAdminAccess) {
    OpenAgendaBridge::factory()->setOpenAgendaUrl($http->postVariable('OpenAgendaUrl'));
    OpenAgendaBridge::factory()->setEnableMainCalendar($http->hasPostVariable('OpenAgendaMainCalendar'));
    OpenAgendaBridge::factory()->setEnableTopicCalendar($http->hasPostVariable('OpenAgendaTopicCalendar'));
    OpenAgendaBridge::factory()->setEnablePlaceCalendar($http->hasPostVariable('OpenAgendaPlaceCalendar'));
    OpenAgendaBridge::factory()->setEnableOrganization($http->hasPostVariable('OpenAgendaOrganization'));
    OpenAgendaBridge::factory()->setEnablePushPlace($http->hasPostVariable('OpenAgendaPushPlace'));
    $module->redirectTo('/bootstrapitalia/info');
    return;
}
$tpl->setVariable('openagenda_url', OpenAgendaBridge::factory()->getOpenAgendaUrl());
$tpl->setVariable('openagenda_embed_main', OpenAgendaBridge::factory()->getEnableMainCalendar());
$tpl->setVariable('openagenda_embed_topic', OpenAgendaBridge::factory()->getEnableTopicCalendar());
$tpl->setVariable('openagenda_embed_place', OpenAgendaBridge::factory()->getEnablePlaceCalendar());
$tpl->setVariable('openagenda_embed_organization', OpenAgendaBridge::factory()->getEnableOrganization());
$tpl->setVariable('openagenda_push_place', OpenAgendaBridge::factory()->getEnablePushPlace());

if ($http->hasPostVariable('StanzadelcittadinoBridge') && $hasAdminAccess) {
    StanzaDelCittadinoBridge::factory()->setEnableRuntimeServiceStatusCheck($http->hasPostVariable('RuntimeServiceStatusCheck'));
    $module->redirectTo('/bootstrapitalia/info');
    return;
}
$tpl->setVariable('sdc_status_check', StanzaDelCittadinoBridge::factory()->getEnableRuntimeServiceStatusCheck());

if ($http->hasPostVariable('StanzaDelCittadinoBooking') && $hasAdminAccess) {
    StanzaDelCittadinoBooking::factory()->setEnabled($http->hasPostVariable('StanzaDelCittadinoBookingEnable'));
    StanzaDelCittadinoBooking::factory()->setStoreMeetingAsApplication($http->hasPostVariable('StanzaDelCittadinoBookingStoreAsApplication'));
    eZContentCacheManager::clearAllContentCache();
    $module->redirectTo('/bootstrapitalia/info');
    return;
}
$tpl->setVariable('stanzadelcittadino_booking', StanzaDelCittadinoBooking::factory()->isEnabled());
$tpl->setVariable('stanzadelcittadino_booking_store_as_application', StanzaDelCittadinoBooking::factory()->isStoreMeetingAsApplication());

$fields = OpenPAAttributeContactsHandler::getContactsFields();
if ($http->hasPostVariable('Store')) {
    $contacts = $http->postVariable('Contacts');

    $data = [];
    foreach ($fields as $field) {
        $data[] = [
            'media' => $field,
            'value' => $contacts[$field] ?? '',
        ];
    }
    $payload = new PayloadBuilder();
    $payload->setId($home->attribute('contentobject_id'));
    $payload->setLanguages([$locale]);
    $payload->setData($locale, 'contacts', $data);

    if (isset($_FILES['Logo']) && eZHTTPFile::canFetch('Logo')) {
        $httpFile = eZHTTPFile::fetch('Logo');
        $payload->setData($locale, 'logo', [
            'filename' => uniqid() . $httpFile->attribute('original_filename'),
            'file' => base64_encode(file_get_contents($httpFile->attribute('filename'))),
        ]);
    }

    if (isset($_FILES['Favicon']) && eZHTTPFile::canFetch('Favicon')) {
        $httpFile = eZHTTPFile::fetch('Favicon');
        $payload->setData($locale, 'favicon', [
            'filename' => uniqid() . $httpFile->attribute('original_filename'),
            'file' => base64_encode(file_get_contents($httpFile->attribute('filename'))),
        ]);
    }

    if (isset($_FILES['LogoFooter']) && eZHTTPFile::canFetch('LogoFooter')) {
        $httpFile = eZHTTPFile::fetch('LogoFooter');
        $payload->setData($locale, 'footer_logo', [
            'filename' => uniqid() . $httpFile->attribute('original_filename'),
            'file' => base64_encode(file_get_contents($httpFile->attribute('filename'))),
        ]);
    }

    $dataMap = $home->dataMap();
    $headerLinks = $dataMap['link_nell_header'] ?? null;
    $relationsPriority = $http->hasPostVariable('ContentObjectAttribute_priority') ? $http->postVariable('ContentObjectAttribute_priority') : [];
    if ($headerLinks){
        $headerLinksClassId = $headerLinks->attribute('id');
        if ($http->hasPostVariable('ContentObjectAttribute_data_object_relation_list_' . $headerLinksClassId)) {
            $values = (array)$http->postVariable('ContentObjectAttribute_data_object_relation_list_' . $headerLinksClassId);
            if (isset($relationsPriority[$headerLinksClassId])){
                $pValues = [];
                foreach ($values as $index => $value){
                    $p = $relationsPriority[$headerLinksClassId][$index];
                    $pValues[$p][] = $value;
                }
                ksort($pValues);
                $values = [];
                foreach ($pValues as $pValue){
                    $values = array_merge($values, $pValue);
                }
            }
            foreach ($values as $index => $value){
                if ($value == 'no_relation'){
                    unset($values[$index]);
                }
            }
            $payload->setData($locale, 'link_nell_header', $values);
        }
    }
    $footerLinks = $dataMap['link_nel_footer'] ?? null;
    if ($footerLinks){
        $footerLinksClassId = $footerLinks->attribute('id');
        if ($http->hasPostVariable('ContentObjectAttribute_data_object_relation_list_' . $footerLinksClassId)) {
            $values = (array)$http->postVariable('ContentObjectAttribute_data_object_relation_list_' . $footerLinksClassId);
            if (isset($relationsPriority[$footerLinksClassId])){
                $pValues = [];
                foreach ($values as $index => $value){
                    $p = $relationsPriority[$footerLinksClassId][$index];
                    $pValues[$p][] = $value;
                }
                ksort($pValues);
                $values = [];
                foreach ($pValues as $pValue){
                    $values = array_merge($values, $pValue);
                }
            }
            $originalValues = explode('-', $footerLinks->toString());
            foreach ($values as $index => $value){
                if ($value == 'no_relation'){
                    unset($values[$index]);
                }
            }
            $missingValues = array_diff($originalValues, $values);
            if (!empty($missingValues)){
                $values = array_merge($values, $missingValues);
            }
            $values = array_unique($values);
            $payload->setData($locale, 'link_nel_footer', $values);
        }
    }

    $footerBanner = $dataMap['footer_banner'] ?? null;
    if ($footerBanner){
        $footerBannerClassId = $footerBanner->attribute('id');
        if ($http->hasPostVariable('ContentObjectAttribute_data_object_relation_list_' . $footerBannerClassId)) {
            $values = (array)$http->postVariable('ContentObjectAttribute_data_object_relation_list_' . $footerBannerClassId);
            if (isset($relationsPriority[$footerBannerClassId])){
                $pValues = [];
                foreach ($values as $index => $value){
                    $p = $relationsPriority[$footerBannerClassId][$index];
                    $pValues[$p][] = $value;
                }
                ksort($pValues);
                $values = [];
                foreach ($pValues as $pValue){
                    $values = array_merge($values, $pValue);
                }
            }
            $originalValues = explode('-', $footerBanner->toString());
            foreach ($values as $index => $value){
                if ($value == 'no_relation' || empty($value)){
                    unset($values[$index]);
                }
            }
            if (empty($values)) {
                $dataMap['footer_banner']->fromString('');
                $dataMap['footer_banner']->store();
            }else {
                $missingValues = array_diff($originalValues, $values);
                if (!empty($missingValues)) {
                    $values = array_merge($values, $missingValues);
                }
                $values = array_unique($values);
                if (!empty($values)) {
                    $values = (array)array_shift($values);
                }
                $payload->setData($locale, 'footer_banner', $values);
            }
        }
    }

    $contentRepository = new ContentRepository();
    $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));
    try {
        $contentRepository->update($payload->getArrayCopy(), true);

        $module->redirectTo('/bootstrapitalia/info');
        return;
    } catch (Exception $e) {
        $tpl->setVariable('message', $e->getMessage());
    }
}

OpenPAPageData::clearOnModifyHomepage();

$sections = [
    [
        'label' => 'Generale',
        'contacts' => [
            'telefono',
            'fax',
            'numero_verde',
            'email',
            'pec',
            'web',

            'indirizzo',
            'via',
            'numero_civico',
            'cap',
            'comune',

            'codice_fiscale',
            'partita_iva',
            'codice_sdi',

            'latitudine',
            'longitudine',
        ],
    ],
    [
        'label' => 'Social',
        'contacts' => [
            'facebook',
            'twitter',
            'linkedin',
            'instagram',
            'youtube',
            'whatsapp',
            'telegram',
            'tiktok',

        ],
    ],
    [
        'label' => 'Integrazioni',
        'contacts' => [
            'link_area_personale',
            'link_assistenza',
            'link_prenotazione_appuntamento',
            'link_segnalazione_disservizio',
            'newsletter',
        ],
    ],
];
$tpl->setVariable('sections', $sections);

$contacts = [];
$pagedata = new \OpenPAPageData();
$contactsHash = $pagedata->getContactsData();
$trans = eZCharTransform::instance();
foreach ($fields as $label) {
    $identifier = $trans->transformByGroup($label, 'identifier');
    $contacts[$identifier] = [
        'label' => $label,
        'identifier' => $identifier,
        'value' => $contactsHash[$identifier] ?? '',
    ];
}

$tpl->setVariable('site_title', 'Gestione informazioni');
$tpl->setVariable('contacts', $contacts);

$Result = [];
$Result['content'] = $tpl->fetch('design:bootstrapitalia/info.tpl');
$Result['content_info'] = [
    'node_id' => null,
    'class_identifier' => null,
    'persistent_variable' => [
        'show_path' => true,
        'site_title' => 'Gestione informazioni',
    ],
];
if (is_array($tpl->variable('persistent_variable'))) {
    $Result['content_info']['persistent_variable'] = array_merge(
        $Result['content_info']['persistent_variable'],
        $tpl->variable('persistent_variable')
    );
}
$Result['path'] = [];