<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;

/** @var eZModule $module */
$module = $Params['Module'];
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();

$fields = OpenPAAttributeContactsHandler::getContactsFields();
if ($http->hasPostVariable('Store')){
    $home = OpenPaFunctionCollection::fetchHome();
    $contacts = $http->postVariable('Contacts');
    $data = [];
    foreach ($fields as $field){
        $data[] = [
            'media' => $field,
            'value' => $contacts[$field],
        ];
    }
    $locale = eZLocale::currentLocaleCode();
    $payload = new \Opencontent\Opendata\Rest\Client\PayloadBuilder();
    $payload->setId($home->attribute('contentobject_id'));
    $payload->setLanguages([$locale]);
    $payload->setData($locale, 'contacts', $data);
    $contentRepository = new ContentRepository();
    $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));
    try {
        $contentRepository->update($payload->getArrayCopy(), true);
        $module->redirectTo('/bootstrapitalia/info');
    }catch (Exception $e){
        $tpl->setVariable('message', $e->getMessage());
    }
}

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
        ]
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

        ]
    ],
    [
        'label' => 'Integrazioni',
        'contacts' => [
            'link_area_personale',
            'link_assistenza',
            'link_prenotazione_appuntamento',
            'link_segnalazione_disservizio',
            'newsletter',
        ]
    ],
];
$tpl->setVariable('sections', $sections);

$contacts = [];
$pagedata = new \OpenPAPageData();
$contactsHash = $pagedata->getContactsData();
$trans = eZCharTransform::instance();
foreach ($fields as $label){
    $identifier = $trans->transformByGroup($label, 'identifier');
    $contacts[$identifier] = [
        'label' => $label,
        'identifier' => $identifier,
        'value' => $contactsHash[$identifier] ?? '',
    ];
}

$tpl->setVariable('site_title', 'Gestione informazioni');
$tpl->setVariable('contacts', $contacts);

$Result = array();
$Result['content'] = $tpl->fetch('design:bootstrapitalia/info.tpl');
$Result['content_info'] = array(
    'node_id' => null,
    'class_identifier' => null,
    'persistent_variable' => array(
        'show_path' => true,
        'site_title' => 'Gestione informazioni'
    )
);
if (is_array($tpl->variable('persistent_variable'))) {
    $Result['content_info']['persistent_variable'] = array_merge($Result['content_info']['persistent_variable'], $tpl->variable('persistent_variable'));
}
$Result['path'] = array();