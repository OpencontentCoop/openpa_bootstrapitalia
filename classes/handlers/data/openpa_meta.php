<?php

use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\ContentSearch;

/**
 * @depracated
 */
class OpenPAMeta implements JsonSerializable
{
    const DEBUG = true;

    public $favicon;

    public $name;

    public $logo;

    public $theme;

    public $themeInfo;

    public $service = [
        "amministrazione_afferente" => [],
        "nav" => [],
    ];

    public $main = [];

    public $topics = [];

    public $info;

    public $contacts = [
        "address" => null,
        "phone" => null,
        "piva" => null,
        "cf" => null,
        "toll_free_number" => null,
        "fax" => null,
        "email" => null,
        "legal_email" => null,
        "faq_url" => null,
        "meetings_reservation_url" => null,
        "support_url" => null,
    ];

    public $social = [];

    public $utils = [];

    public $legals = [];

    public static function instanceFromGlobals()
    {
        $meta = new static();
        $ini = eZINI::instance();
        $meta->name = $ini->variable('SiteSettings', 'SiteName');
        $meta->service['amministrazione_afferente'] = [
            'text' => OpenPAINI::variable('InstanceSettings','UrlAmministrazioneAfferente'),
            'url' => OpenPAINI::variable('InstanceSettings','NomeAmministrazioneAfferente'),
        ];
        $meta->theme = OpenPAINI::variable('GeneralSettings', 'theme', 'default');
        $meta->themeInfo = OpenPABootstrapItaliaOperators::getCurrentTheme();
        $homepage = OpenPaFunctionCollection::fetchHome();
        if ($homepage instanceof eZContentObjectTreeNode) {
            $currentLanguage = eZLocale::currentLocaleCode();
            $contentRepo = new ContentRepository();
            $currentEnvironment = EnvironmentLoader::loadPreset('content');
            $contentRepo->setEnvironment($currentEnvironment);
            $parser = new ezpRestHttpRequestParser();
            $request = $parser->createRequest();
            $currentEnvironment->__set('request', $request);
            $data = (array)$contentRepo->read($homepage->attribute('contentobject_id'));
            if (isset($data['data'][$currentLanguage])){
                $data = $data['data'][$currentLanguage];

                if (isset($data['service_url']) && !empty($data['service_url'])){
                    [$text, $url] = explode('|', $data['service_url']);
                    $meta->service['amministrazione_afferente'] = [
                        'text' => $text,
                        'url' => $url,
                    ];
                }
                if (isset($data['link_nell_header']) && !empty($data['link_nell_header'])){
                    foreach ($data['link_nell_header'] as $link){
                        $object = eZContentObject::fetch((int)$link['id']);
                        if ($object instanceof eZContentObject) {
                            $text = $link['name'][$currentLanguage];
                            $url = OpenPAObjectHandler::instanceFromObject($object)
                                ->attribute('content_link')->attribute('full_link');
                            $meta->service['nav'][] = [
                                'text' => $text,
                                'url' => $url,
                            ];
                        }
                    }
                }
                if (isset($data['favicon']['url'])){
                    $meta->favicon = $data['favicon']['url'];
                }
                if (isset($data['logo']['url'])){
                    $meta->logo = $data['logo']['url'];
                }
            }
        }
        return $meta;
    }

    public function jsonSerialize()
    {
        $data = get_object_vars($this);

        if (self::DEBUG) {
            return $data;
        }

        foreach ($data as $key => $value) {
            if (empty($value)) {
                unset($data[$key]);
            } else {
                if ($key === 'service') {
                    if (empty($data['service']['amministrazione_afferente'])) {
                        unset($data['service']['amministrazione_afferente']);
                    }
                    if (empty($data['service']['nav'])) {
                        unset($data['service']['nav']);
                    }
                    if (empty($data['service'])) {
                        unset($data['service']);
                    }
                }
                if ($key === 'contacts') {
                    foreach ($data['contacts'] as $contact => $contactValue) {
                        if (empty($contactValue)) {
                            unset($data['contacts'][$contact]);
                        }
                    }
                    if (empty($data['contacts'])) {
                        unset($data['contacts']);
                    }
                }
            }
        }

        return $data;
    }

}