<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;

class SiteInfo
{
    public static function importFromUrl($remoteUrl, $overrideLogo = false)
    {
        if (filter_var($remoteUrl, FILTER_VALIDATE_URL)) {
            $remoteHost = parse_url($remoteUrl, PHP_URL_HOST);
            $rootObjectId = false;
            $rootNode = json_decode(file_get_contents("https://$remoteHost/api/opendata/v2/content/browse/1"), true);
            if ($rootNode && isset($rootNode['children'])) {
                foreach ($rootNode['children'] as $child) {
                    if ($child['classIdentifier'] == 'homepage') {
                        $rootObjectId = $child['id'];
                        break;
                    }
                }
            } elseif (!$rootNode) {
                $rootNode = json_decode(
                    file_get_contents("https://$remoteHost/api/opendata/v2/content/browse/2"),
                    true
                );
                if ($rootNode) {
                    $rootObjectId = $rootNode['id'];
                }
            }
            if ($rootObjectId) {
                $rootObject = json_decode(
                    file_get_contents("https://$remoteHost/api/opendata/v2/content/read/" . (int)$rootObjectId),
                    true
                );
                if ($rootObject) {
                    $languages = $rootObject['metadata']['languages'];

                    $payload = new PayloadBuilder();
                    $payload->setId(OpenPaFunctionCollection::fetchHome()->attribute('contentobject_id'));
                    $payload->setLanguages($languages);
                    $syncFields = [
                        'contacts',
                        'logo',
                        'stemma',
                        'favicon',
                    ];
                    foreach ($languages as $language) {
                        $data = $rootObject['data'][$language] ?? $rootObject['data']['ita-IT'];
                        foreach ($syncFields as $syncField) {
                            if (isset($data[$syncField]) && !empty($data[$syncField])) {
                                $fieldValue = $data[$syncField];
                                if (isset($fieldValue['url']) && strpos($fieldValue['url'], 'http') === false) {
                                    $fieldValue['url'] = 'https://' . $remoteHost . $fieldValue['url'];
                                }
                                $payload->setData($language, $syncField, $fieldValue);
                            }
                        }
                    }

                    if ($overrideLogo) {
                        $standardLogoPath = strtolower(
                            eZCharTransform::instance()->transformByGroup(
                                eZINI::instance()->variable('SiteSettings', 'SiteName'),
                                'urlalias'
                            )
                        );
                        $standardLogo = "https://s3.eu-west-1.amazonaws.com/download.stanzadelcittadino.it/{$standardLogoPath}/logo.png";
                        if (file_get_contents($standardLogo)) {
                            $payload->setData(null, 'logo', [
                                'filename' => basename($standardLogo),
                                'url' => $standardLogo,
                            ]);
                            $payload->setData(null, 'stemma', [
                                'filename' => basename($standardLogo),
                                'url' => $standardLogo,
                            ]);
                        }
                    }
                    if (!empty($payload->getData())) {
                        $contentRepository = new ContentRepository();
                        $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));
                        $contentRepository->update($payload->getArrayCopy(), true);

                        return true;
                    }
                }
            }
        }

        return false;
    }

    public static function getCurrent($baseUrl = null)
    {
        $home = OpenPaFunctionCollection::fetchHome();
        $homeDataMap = $home->dataMap();

        if (isset($homeDataMap['service_url']) && $homeDataMap['service_url']->hasContent()) {
            $amministrazioneAfferente = [
                'text' => $homeDataMap['service_url']->attribute('content'),
                'url' => $homeDataMap['service_url']->attribute('data_text'),
            ];
        } else {
            $amministrazioneAfferente = [
                'text' => OpenPAINI::variable('InstanceSettings', 'NomeAmministrazioneAfferente', ''),
                'url' => OpenPAINI::variable('InstanceSettings', 'UrlAmministrazioneAfferente', ''),
            ];
        }

        $nav = [];
        if (isset($homeDataMap['link_nell_header']) && $homeDataMap['link_nell_header']->hasContent()) {
            $navObjects = OpenPABase::fetchObjects(explode('-', $homeDataMap['link_nell_header']->toString()));
            foreach ($navObjects as $navObject) {
                $navNode = $navObject->mainNode();
                if ($navNode instanceof eZContentObjectTreeNode) {
                    $navUrl = $navNode->attribute('url_alias');
                    self::makeAbsoluteUrl($navUrl, $baseUrl);
                    $nav[] = [
                        'text' => $navObject->attribute('name'),
                        'url' => $navUrl,
                    ];
                }
            }
        }

        $main = [];
        $topMenuNodeIdList = OpenPAINI::variable('TopMenu', 'NodiCustomMenu', []);
        foreach ($topMenuNodeIdList as $topMenuNodeId) {
            $topMenu = (array)OpenPAMenuTool::getTreeMenu(['root_node_id' => $topMenuNodeId, 'scope' => 'top_menu']);
            self::makeAbsoluteUrl($topMenu['item']['url'], $baseUrl);
            $menuItem = [
                'text' => $topMenu['item']['name'],
                'url' => $topMenu['item']['url'],
            ];
            if (isset($topMenu['children']) && count($topMenu['children'])) {
                $menuItem['children'] = [];
                foreach ($topMenu['children'] as $topMenuChild) {
                    self::makeAbsoluteUrl($topMenuChild['item']['url'], $baseUrl);
                    $menuItem['children'][] = [
                        'text' => $topMenuChild['item']['name'],
                        'url' => $topMenuChild['item']['url'],
                    ];
                }
            }
            $main[] = $menuItem;
        }

        $topics = [];
        if (isset($homeDataMap['topics']) && $homeDataMap['topics']->hasContent()) {
            $topicsObjects = OpenPABase::fetchObjects(explode('-', $homeDataMap['topics']->toString()));
            foreach ($topicsObjects as $topicsObject) {
                $topicNode = $topicsObject->mainNode();
                if ($topicNode instanceof eZContentObjectTreeNode) {
                    $topicUrl = $topicNode->attribute('url_alias');
                    self::makeAbsoluteUrl($topicUrl, $baseUrl);
                    $topics[] = [
                        'text' => $topicsObject->attribute('name'),
                        'url' => $topicUrl,
                    ];
                }
            }
        }

        $allTopics = null;
        $allTopicsObject = eZContentObject::fetchByRemoteID('topics');
        if ($allTopicsObject instanceof eZContentObject) {
            $allTopicsNode = $allTopicsObject->mainNode();
            if ($allTopicsNode instanceof eZContentObjectTreeNode) {
                $allTopics = $allTopicsNode->attribute('url_alias');
                self::makeAbsoluteUrl($allTopics, $baseUrl);
            }
        }

        $noteFooter = '<p>' . eZINI::instance()->variable('SiteSettings', 'SiteName') . '</p>';
        if (isset($homeDataMap['note_footer']) && $homeDataMap['note_footer']->hasContent()) {
            $noteFooter .= str_replace(
                '&nbsp;',
                ' ',
                $homeDataMap['note_footer']->content()->attribute('output')->attribute('output_text')
            );
        }

        $pagedata = new \OpenPAPageData();
        $contacts = $pagedata->getContactsData();

        $logoUrl = '';
        $logo = OpenPaFunctionCollection::fetchHeaderLogo();
        if (isset($logo['full_path'])) {
            $logoUrl = $logo['full_path'];
            self::makeAbsoluteUrl($logoUrl, $baseUrl);

        }

        $faviconUrl = '';
        if (isset($homeDataMap['favicon']) && $homeDataMap['favicon']->hasContent()) {
            /** @var \eZBinaryFile $favicon */
            $favicon = $homeDataMap['favicon']->content();
            $faviconUrl = 'content/download/' . $homeDataMap['favicon']->attribute('contentobject_id')
                . '/' . $homeDataMap['favicon']->attribute('id')
                . '/' . $homeDataMap['favicon']->attribute('version')
                . '/' . urlencode($favicon->attribute('original_filename'));
            self::makeAbsoluteUrl($faviconUrl, $baseUrl);
        }

        $trasparenzaUrl = '';
        $trasparenza = eZContentObject::fetchByRemoteID(
            OpenPAINI::variable('SitemapSettings', 'TrasaprenzaRemoteId', '5399ef12f98766b90f1804e5d52afd75')
        );
        if ($trasparenza instanceof eZContentObject) {
            $trasparenzaNode = $trasparenza->mainNode();
            if ($trasparenzaNode instanceof eZContentObjectTreeNode) {
                $trasparenzaUrl = $trasparenzaNode->attribute('url_alias');
                self::makeAbsoluteUrl($trasparenzaUrl, $baseUrl);
            }
        }

        $privacyUrl = '';
        $privacy = eZContentObject::fetchByRemoteID('privacy-policy-link');
        if ($privacy instanceof eZContentObject) {
            $privacyNode = $privacy->mainNode();
            if ($privacyNode instanceof eZContentObjectTreeNode) {
                $privacyUrl = $privacyNode->attribute('url_alias');
                self::makeAbsoluteUrl($privacyUrl, $baseUrl);
            }
        }

        $legalNotesUrl = '';
        $legalNotes = eZContentObject::fetchByRemoteID('931779762484010404cf5fa08f77d978');
        if ($legalNotes instanceof eZContentObject) {
            $legalNotesNode = $legalNotes->mainNode();
            if ($legalNotesNode instanceof eZContentObjectTreeNode) {
                $legalNotesUrl = $legalNotesNode->attribute('url_alias');
                self::makeAbsoluteUrl($legalNotesUrl, $baseUrl);
            }
        }

        $accessibilityUrl = '';
        $accessibility = eZContentObject::fetchByRemoteID('accessibility-link');
        if ($accessibility instanceof eZContentObject) {
            $accessibilityDataMap = $accessibility->dataMap();
            if (isset($accessibilityDataMap['location'])) {
                $accessibilityUrl = $accessibilityDataMap['location']->attribute('content');
            }
        }

        $faqUrl = '';
        $faq = eZContentObject::fetchByRemoteID('faq_system');
        if ($faq instanceof eZContentObject) {
            $faqNode = $faq->mainNode();
            if ($faqNode instanceof eZContentObjectTreeNode) {
                $faqUrl = $faqNode->attribute('url_alias');
                self::makeAbsoluteUrl($faqUrl, $baseUrl);
            }
        }

        $bookingUrl = $contacts['link_prenotazione_appuntamento'] ?? false;
        if (!$bookingUrl) {
            $bookingUrl = '/prenota_appuntamento';
            self::makeAbsoluteUrl($bookingUrl, $baseUrl);
        }

        $inefficiencyUrl = $contacts['link_segnalazione_disservizio'] ?? false;
        if (!$inefficiencyUrl) {
            $inefficiencyUrl = '/segnala_disservizio';
            self::makeAbsoluteUrl($inefficiencyUrl, $baseUrl);
        }

        $supportUrl = $contacts['link_assistenza'] ?? false;
        if (!$supportUrl) {
            $supportUrl = '/richiedi_assistenza';
            self::makeAbsoluteUrl($supportUrl, $baseUrl);
        }

        $rssUrl = '';
        if (OpenpaBootstrapItaliaNewsRssHandler::isEnabled()){
            $rssUrl = (new OpenpaBootstrapItaliaNewsRssHandler())->getFeedAccessUrl();
            self::makeAbsoluteUrl($rssUrl, $baseUrl);
        }

        $siteInfo = [
            'tenant_type' => 'comune',
            'enable_search_and_catalogue' => false,
            'favicon' => $faviconUrl,
            'logo' => $logoUrl,
            'theme' => 'default', //@todo
            'service' => [
                'amministrazione_afferente' => $amministrazioneAfferente,
                'nav' => $nav,
            ],
            'main' => $main,
            'topics' => $topics,
            'all_topics' => $allTopics,
            'info' => $noteFooter,
            'contacts' => [
                'address' => $contacts['indirizzo'] ?? '',
                'phone' => $contacts['telefono'] ?? '',
                'email' => $contacts['email'] ?? '',
                'legal_email' => $contacts['pec'] ?? '',
                'piva' => $contacts['partita_iva'] ?? '',
                'cf' => $contacts['codice_fiscale'] ?? '',
            ],
            'social' => [
                'facebook' => $contacts['facebook'] ?? '',
                'twitter' => $contacts['twitter'] ?? '',
                'youtube' => $contacts['youtube'] ?? '',
                'telegram' => $contacts['telegram'] ?? '',
                'whatsapp' => $contacts['whatsapp'] ?? '',
                'tiktok' => $contacts['tiktok'] ?? '',
                'rss' => $rssUrl,
            ],
            'legals' => [
                'transparent_administration' => $trasparenzaUrl,
                'privacy_info' => $privacyUrl,
                'legal_notes' => $legalNotesUrl,
                'accessibility' => $accessibilityUrl,
            ],
            'builtin_services' => [
                'faq' => $faqUrl,
                'appointment_booking' => $bookingUrl,
                'report_inefficiency' => $inefficiencyUrl,
                'support' => $supportUrl,
            ],
            'utils' => [
                [
                    'text' => '',
                    'url' => '',
                ],
            ],
            'theme_info' => OpenPABootstrapItaliaOperators::getCurrentTheme(),
        ];

        return $siteInfo;
    }

    private static function makeAbsoluteUrl(&$url, $baseUrl = null)
    {
        eZURI::transformURI($url, false, 'full');
        if (strpos($baseUrl, 'http') !== false) {
            $url = str_replace(eZSys::instance()->serverURL(), $baseUrl, $url);
        }

        return $url;
    }
}