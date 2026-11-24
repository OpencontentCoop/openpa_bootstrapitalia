<?php
/**
 * Verifica DocumentFileResolver::resolveAllUrls():
 * - documento senza nessun file => array vuoto;
 * - documento con 'file' (ezbinaryfile, singolo) E 'attachments'
 *   (ocmultibinary) ENTRAMBI popolati => l'url di 'file' e' il primo
 *   elemento dell'array, SEGUITO dall'url dell'allegato - non si ferma al
 *   primo campo trovato (un redattore puo' avere valorizzato entrambi i
 *   campi, scenario esplicitamente documentato nel docblock di
 *   resolveUrl(), che resta invariato e prende solo il file piu'
 *   "prioritario" tra i due campi).
 *
 * Il caso "'attachments' con PIU' di un file, ordine di visualizzazione
 * preservato" resta deferito alla verifica end-to-end manuale di Task 13
 * (richiederebbe piu' file reali con decorazioni display_order per
 * esercitare usort()/parseDecorations() del datatype ocmultibinary -
 * preferibile verificarlo end-to-end con un documento reale piuttosto che
 * replicare qui quella logica).
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_document_file_resolver_all_urls.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'resolveAllUrls test',
    'use-session'    => false,
    'use-modules'    => true,
    'use-extensions' => true,
]);
$script->startup();
$script->initialize();

$PASSED = 0;
$FAILED = 0;
function check($label, $expected, $actual)
{
    global $PASSED, $FAILED;
    if ($expected === $actual) {
        $PASSED++;
        return;
    }
    $FAILED++;
    echo "FAIL $label\n  atteso:   " . var_export($expected, true) . "\n  ottenuto: " . var_export($actual, true) . "\n";
}

// Necessario per poter creare/pubblicare contenuti con eZOperationHandler -
// stesso pattern gia' verificato in test_hide_content_with_redirect.php e
// test_art13_fetch_organi_amministrativi_vertice.php.
$adminUser = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

// Documento senza nessun file: nessun url.
$class = eZContentClass::fetchByIdentifier('document');
$rootNodeId = (int)eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');
$object = $class->instantiate(eZUser::currentUserID());
$object->store();
$nodeAssignment = eZNodeAssignment::create([
    'contentobject_id' => $object->attribute('id'),
    'contentobject_version' => 1,
    'parent_node' => $rootNodeId,
    'is_main' => 1,
]);
$nodeAssignment->store();
// Nota: lo schema del brief usava fetchDataMap() + $object->publish(['current'
// => true]) - entrambi inaffidabili/inesistenti prima della pubblicazione
// ("Call to undefined method eZContentObject::publish()" verificato in RED).
// Sostituiti con contentObjectAttributes() sulla versione +
// eZOperationHandler::execute('content', 'publish', ...), lo stesso pattern
// gia' verificato funzionante in test_hide_content_with_redirect.php.
$version = $object->version(1);
foreach ($version->contentObjectAttributes('ita-IT') as $attr) {
    if ($attr->contentClassAttributeIdentifier() === 'name') {
        $attr->fromString('Documento senza file ' . uniqid());
        $attr->store();
    }
}
eZOperationHandler::execute('content', 'publish', ['object_id' => $object->attribute('id'), 'version' => 1]);
$object = eZContentObject::fetch((int)$object->attribute('id'));

check('nessun file => array vuoto', [], \OpenPABootstrapItalia\Anac\DocumentFileResolver::resolveAllUrls($object));

// Documento con 'file' E 'attachments' entrambi popolati: resolveAllUrls()
// deve restituire l'url di 'file' seguito dall'url dell'allegato - non solo
// il primo campo trovato. Usa fromString() con un path locale (formato
// accettato sia da eZBinaryFileType sia da OCMultiBinaryType, verificato
// leggendo il sorgente dei due datatype: insertRegularFile() legge il file
// da un path filesystem, nessun upload HTTP necessario).
$object2 = $class->instantiate(eZUser::currentUserID());
$object2->store();
eZNodeAssignment::create([
    'contentobject_id' => $object2->attribute('id'),
    'contentobject_version' => 1,
    'parent_node' => $rootNodeId,
    'is_main' => 1,
])->store();

$version2 = $object2->version(1);
$dataMap2 = [];
foreach ($version2->contentObjectAttributes('ita-IT') as $attr) {
    $identifier = $attr->contentClassAttributeIdentifier();
    $dataMap2[$identifier] = $attr;
    if ($identifier === 'name') {
        $attr->fromString('Documento con file e allegati ' . uniqid());
        $attr->store();
    }
}

$tmpFile = sys_get_temp_dir() . '/test_document_file_' . uniqid() . '.txt';
file_put_contents($tmpFile, 'contenuto file principale');
$dataMap2['file']->fromString($tmpFile);
$dataMap2['file']->store();
$fileAttributeId = (int)$dataMap2['file']->attribute('id');

$tmpAttachment = sys_get_temp_dir() . '/test_document_attachment_' . uniqid() . '.txt';
file_put_contents($tmpAttachment, 'contenuto allegato');
$dataMap2['attachments']->fromString($tmpAttachment);
$dataMap2['attachments']->store();
$attachmentsAttributeId = (int)$dataMap2['attachments']->attribute('id');

eZOperationHandler::execute('content', 'publish', ['object_id' => $object2->attribute('id'), 'version' => 1]);
$object2 = eZContentObject::fetch((int)$object2->attribute('id'));

@unlink($tmpFile);
@unlink($tmpAttachment);

// Url attesi costruiti in modo indipendente dal metodo sotto test (stesso
// schema di resolveUrl()/resolveAllUrls(), ma non chiamando quel codice):
// per 'file' basta l'id dell'attributo stesso (/content/download/<object
// id>/<attribute id>); per 'attachments' serve anche il filename interno
// generato da eZMultiBinaryFile allo store, letto qui direttamente dal
// fetch() del kernel.
$storedAttachments = (array)eZMultiBinaryFile::fetch($attachmentsAttributeId, 1);
$storedAttachment = reset($storedAttachments);

$rawSiteUrl = trim(eZINI::instance()->variable('SiteSettings', 'SiteURL'), '/');
$siteUrl = explode('/', $rawSiteUrl, 2)[0];

$expectedUrls = [
    'https://' . $siteUrl . '/content/download/' . $object2->attribute('id') . '/' . $fileAttributeId,
];
if ($storedAttachment instanceof eZMultiBinaryFile) {
    $expectedUrls[] = 'https://' . $siteUrl . '/ocmultibinary/download/' . $object2->attribute('id') . '/' . $attachmentsAttributeId . '/1/' . $storedAttachment->attribute('filename') . '/file/' . rawurlencode($storedAttachment->attribute('original_filename'));
}

check(
    "file e attachments entrambi popolati => url di 'file' seguito dagli url di 'attachments'",
    $expectedUrls,
    \OpenPABootstrapItalia\Anac\DocumentFileResolver::resolveAllUrls($object2)
);

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
