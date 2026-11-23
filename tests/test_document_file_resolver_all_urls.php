<?php
/**
 * Verifica DocumentFileResolver::resolveAllUrls(): con il campo 'file'
 * (singolo) restituisce un solo url; con 'attachments' (ocmultibinary)
 * restituisce TUTTI gli url nell'ordine di visualizzazione, non solo il
 * primo (a differenza di resolveUrl(), che resta invariato).
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

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
