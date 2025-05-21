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
/** @var eZContentObjectAttribute[] $dataMap */
$dataMap = $home->dataMap();

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

if (class_exists('OpenPASendy') && $hasAdminAccess) {
    if ($http->hasPostVariable('SendyBrandId')) {
        OpenPASendy::setBrandId($http->postVariable('SendyBrandId'));
        OpenPASendy::setSingleCampaignCreation($http->hasPostVariable('SendySendSingleContent'));
    }
}

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
    StanzaDelCittadinoBooking::factory()->setServiceDiscover($http->hasPostVariable('StanzaDelCittadinoBookingServiceDiscover'));
    StanzaDelCittadinoBooking::factory()->setScheduler($http->hasPostVariable('StanzaDelCittadinoBookingScheduler'));
    StanzaDelCittadinoBooking::factory()->setShowHowTo($http->hasPostVariable('StanzaDelCittadinoBookingShowHowTo'));
    eZContentCacheManager::clearAllContentCache();
    $module->redirectTo('/bootstrapitalia/info');
    return;
}
$tpl->setVariable('stanzadelcittadino_booking', StanzaDelCittadinoBooking::factory()->isEnabled());
$tpl->setVariable('stanzadelcittadino_booking_store_as_application', StanzaDelCittadinoBooking::factory()->isStoreMeetingAsApplication());
$tpl->setVariable('stanzadelcittadino_booking_service_discover', StanzaDelCittadinoBooking::factory()->isServiceDiscoverEnabled());
$tpl->setVariable('stanzadelcittadino_booking_scheduler', StanzaDelCittadinoBooking::factory()->isSchedulerEnabled());
$tpl->setVariable('stanzadelcittadino_booking_how_to', StanzaDelCittadinoBooking::factory()->isShowHowToEnabled());

if ($http->hasPostVariable('StanzaDelCittadinoBuiltin') && $hasAdminAccess) {
    BuiltinApp::setCurrentOptions((array)$http->postVariable('StanzaDelCittadinoBuiltin'));
    $module->redirectTo('/bootstrapitalia/info');
    return;
}
$tpl->setVariable('built_in_options', BuiltinApp::getOptionsDefinition());

if ($http->hasPostVariable('Moderation') && $hasAdminAccess) {
    ModerationHandler::setIsEnabled((bool)$http->hasPostVariable('ModerationIsEnabled'));
    $module->redirectTo('/bootstrapitalia/info');
    return;
}

if ($http->hasPostVariable('AccessPageSettings') && $hasAdminAccess) {
    PersonalAreaLogin::instance()->setAccess('cie', $http->hasPostVariable('AccessPageSettingsCieEnable'));
    PersonalAreaLogin::instance()->setAccess('eidas', $http->hasPostVariable('AccessPageSettingsEidasEnable'));
    PersonalAreaLogin::instance()->setAccess('cns', $http->hasPostVariable('AccessPageSettingsCnsEnable'));
    PersonalAreaLogin::instance()->storeAccesses();
    $module->redirectTo('/bootstrapitalia/info');
    return;
}
$tpl->setVariable('access_spid', PersonalAreaLogin::instance()->hasAccess('spid'));
$tpl->setVariable('access_cie', PersonalAreaLogin::instance()->hasAccess('cie'));
$tpl->setVariable('access_eidas', PersonalAreaLogin::instance()->hasAccess('eidas'));
$tpl->setVariable('access_cns', PersonalAreaLogin::instance()->hasAccess('cns'));

if ($http->hasPostVariable('LoginOauth') && $hasAdminAccess) {
    BootstrapItaliaLoginOauth::instance()->setCurrentOptions((array)$http->postVariable('LoginOauth'));
    $module->redirectTo('/bootstrapitalia/info');
    return;
}
$tpl->setVariable('oauth_options', BootstrapItaliaLoginOauth::instance()->getOptionsDefinitionWithCurrentData());

$fields = OpenPAAttributeContactsHandler::getContactsFields();
if ($http->hasPostVariable('Store')) {
    $contacts = $http->postVariable('Contacts');

    $data = [];
    foreach ($fields as $field) {
        $value = $contacts[$field] ?? '';
        $value = trim($value);
        if (strpos($value, 'http') !== false && strpos($value, '&') !== false) {
            $parts = parse_url($value);
            foreach ($parts as $key => $part) {
                if (strpos($part, '&') !== false) {
                    $parts[$key] = urlencode($part);
                }
            }
            $value = (isset($parts['scheme']) ? "{$parts['scheme']}:" : '') .
                ((isset($parts['user']) || isset($parts['host'])) ? '//' : '') .
                (isset($parts['user']) ? "{$parts['user']}" : '') .
                (isset($parts['pass']) ? ":{$parts['pass']}" : '') .
                (isset($parts['user']) ? '@' : '') .
                (isset($parts['host']) ? "{$parts['host']}" : '') .
                (isset($parts['port']) ? ":{$parts['port']}" : '') .
                (isset($parts['path']) ? "{$parts['path']}" : '') .
                (isset($parts['query']) ? "?{$parts['query']}" : '') .
                (isset($parts['fragment']) ? "#{$parts['fragment']}" : '');;
        }
        $data[] = [
            'media' => $field,
            'value' => $value,
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
        if (OpenPAINI::variable('GeneralSettings', 'StaticLogoUrl', 'disabled') !== 'disabled'){
            $logoUrl = OpenPAINI::variable('GeneralSettings', 'StaticLogoUrl');
            eZURI::transformURI($logoUrl, true, 'full');
            $staticCacheHandler = eZExtension::getHandlerClass(new ezpExtensionOptions([
                'iniFile'      => 'site.ini',
                'iniSection'   => 'ContentSettings',
                'iniVariable'  => 'StaticCacheHandler'
            ]));
            if ($staticCacheHandler instanceof ezpStaticCache){
                $staticCacheHandler->removeURL($logoUrl);
            }
        }
    }

    if (isset($_FILES['AppleTouchIcon']) && eZHTTPFile::canFetch('AppleTouchIcon')) {
        $httpFile = eZHTTPFile::fetch('AppleTouchIcon');
        $payload->setData($locale, 'apple_touch_icon', [
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
            $constraints = [
                'privacy-policy-link',
                '931779762484010404cf5fa08f77d978', //note legali
                'accessibility-link',
            ];
            $constraintValues = [];
            foreach ($constraints as $constraint){
                $obj = eZContentObject::fetchByRemoteID($constraint);
                if ($obj instanceof eZContentObject){
                    $constraintValues[] = $obj->attribute('id');
                }
            }
            foreach ($values as $index => $value){
                if ($value == 'no_relation'){
                    unset($values[$index]);
                }
            }
            $missingValues = array_diff($constraintValues, $values);
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
            foreach ($values as $index => $value){
                if ($value == 'no_relation' || empty($value)){
                    unset($values[$index]);
                }
            }
            $values = array_unique($values);
            if (empty($values)) {
                $dataMap['footer_banner']->fromString('');
                $dataMap['footer_banner']->store();
            }else {
                $values = (array)array_shift($values);
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

$logoUrl = null;
if (isset($dataMap['logo']) && $dataMap['logo']->hasContent()){
    $logoImageAlias = $dataMap['logo']->attribute('content');
    if ($logoImageAlias instanceof eZImageAliasHandler) {
        $logoUrl = $logoImageAlias->attribute('header_logo')['full_path'];
        eZURI::transformURI($logoUrl, true, 'full');
    }
}
$imageDecorator = new BootstrapItaliaImage();
if ($imageDecorator->isEnabled() && OpenPAINI::variable('GeneralSettings', 'StaticLogoUrl', 'disabled') !== 'disabled'){
    $logoUrl = $imageDecorator->process(OpenPAINI::variable('GeneralSettings', 'StaticLogoUrl'), ['refresh' => true])['src'];
}
$tpl->setVariable('logo_url', $logoUrl);

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