<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;

/** @var eZModule $module */
$module = $Params['Module'];
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();
$locale = eZLocale::currentLocaleCode();

/** only admin can view import form */
$canImport = eZUser::currentUser()->attribute('login') === 'admin';
$tpl->setVariable('can_import', $canImport);

if ($http->hasPostVariable('From') && $canImport) {
    $remoteUrl = $http->postVariable('From', '');
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
$fields = OpenPAAttributeContactsHandler::getContactsFields();
if ($http->hasPostVariable('Store')) {
    $home = OpenPaFunctionCollection::fetchHome();
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