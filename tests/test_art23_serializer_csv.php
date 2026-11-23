<?php
/**
 * Verifica Art23Serializer::toCsvOrgani()/toCsvDirigenti(): intestazione
 * esatta, catena di fallback data/numero (incluso il caso act_date/
 * act_number DEL TUTTO ASSENTI dalla classe, sito senza albo-pretorio),
 * denominazione = tag padre (non il keyword completo).
 *
 * Nota: lo schema del brief usava fetchDataMap() + $object->publish(['current'
 * => true]) - entrambi inaffidabili/inesistenti prima della pubblicazione
 * ("Call to undefined method eZContentObject::publish()" verificato in RED,
 * stesso problema gia' risolto in test_document_file_resolver_all_urls.php,
 * Task 3). Sostituiti con contentObjectAttributes() sulla versione +
 * eZOperationHandler::execute('content', 'publish', ...), stesso pattern
 * gia' verificato funzionante in quel test e in
 * test_hide_content_with_redirect.php.
 *
 * Altre due insidie scoperte durante lo sviluppo di questo test, gia'
 * documentate in test_art13_fetch_organizzazioni_by_tag_id.php:
 * - il datatype eztags richiede per fromString() il formato serializzato a
 *   4 segmenti "id|#keyword|#parent_id|#locale" - un id numerico nudo
 *   viene respinto silenziosamente (restituisce false, campo lasciato
 *   vuoto), senza nessun errore visibile;
 * - un oggetto appena pubblicato non e' garantito raggiungibile
 *   immediatamente via Solr (fetchProvvedimenti() usa eZSolr) - serve
 *   un reindex esplicito (eZSearch::getEngine()->addObject()+commit()) e
 *   una breve attesa.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_csv.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'Art23Serializer CSV test',
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
// stesso pattern gia' verificato in test_document_file_resolver_all_urls.php
// e test_hide_content_with_redirect.php.
$adminUser = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

function createDocument($name, $keyword, $organizationObject, $publicationTimestamp)
{
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

    $version = $object->version(1);
    $dataMap = [];
    foreach ($version->contentObjectAttributes('ita-IT') as $attr) {
        $dataMap[$attr->contentClassAttributeIdentifier()] = $attr;
    }
    $dataMap['name']->fromString($name);
    $dataMap['name']->store();
    // eZDateTimeType::fromString() scrive il parametro direttamente in
    // 'data_int' (nessun parsing di formato) - vuole un timestamp UNIX
    // grezzo, non una data formattata "gg/mm/aaaa" (che verrebbe castata a
    // (int) e produrrebbe un timestamp vicino all'epoch, 01/01/1970).
    // Verificato leggendo il sorgente del datatype.
    $dataMap['publication_start_time']->fromString((string)$publicationTimestamp);
    $dataMap['publication_start_time']->store();
    // eZTagsObject::fetchByKeyword() restituisce sempre un array (anche con
    // $mainTranslation=true), mai un singolo oggetto - verificato leggendo
    // il sorgente (extension/eztags/classes/eztagsobject.php, delega a
    // fetchList()).
    $matchingTags = eZTagsObject::fetchByKeyword($keyword, true);
    $tag = reset($matchingTags);
    $tagString = $tag->attribute('id') . '|#' . $tag->attribute('keyword') . '|#' . $tag->attribute('parent_id') . '|#ita-IT';
    $dataMap['document_type']->fromString($tagString);
    $dataMap['document_type']->store();
    $dataMap['has_organization']->fromString((string)$organizationObject->attribute('id'));
    $dataMap['has_organization']->store();

    eZOperationHandler::execute('content', 'publish', ['object_id' => $object->attribute('id'), 'version' => 1]);

    $freshObject = eZContentObject::fetch($object->attribute('id'));
    $solrIndexer = eZSearch::getEngine();
    $solrIndexer->addObject($freshObject, false);
    $solrIndexer->commit();

    return $freshObject;
}

$orgClass = eZContentClass::fetchByIdentifier('organization');
$rootNodeId = (int)eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');
$orgObject = $orgClass->instantiate(eZUser::currentUserID());
$orgObject->store();
$nodeAssignment = eZNodeAssignment::create([
    'contentobject_id' => $orgObject->attribute('id'),
    'contentobject_version' => 1,
    'parent_node' => $rootNodeId,
    'is_main' => 1,
]);
$nodeAssignment->store();
$orgVersion = $orgObject->version(1);
foreach ($orgVersion->contentObjectAttributes('ita-IT') as $attr) {
    if ($attr->contentClassAttributeIdentifier() === 'legal_name') {
        $attr->fromString('Ufficio di prova ' . uniqid());
        $attr->store();
    }
}
eZOperationHandler::execute('content', 'publish', ['object_id' => $orgObject->attribute('id'), 'version' => 1]);
$orgObject = eZContentObject::fetch($orgObject->attribute('id'));

$decreto = createDocument('Decreto di prova ' . uniqid(), 'Decreto del Sindaco', $orgObject, strtotime('2026-03-12'));
$determinazioneDirigente = createDocument('Determina di prova ' . uniqid(), 'Determinazione del Dirigente', $orgObject, strtotime('2026-04-01'));

sleep(2);

$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art23Serializer();
$csvOrgani = $serializer->toCsvOrgani();
$csvDirigenti = $serializer->toCsvDirigenti();

check('intestazione CSV organi', 'DATA;NUMERO;DENOMINAZIONE;OGGETTO;STRUTTURA_RESPONSABILE', explode("\n", $csvOrgani)[0]);
check('Decreto del Sindaco compare nel CSV organi con denominazione Decreto', true, strpos($csvOrgani, ';Decreto;') !== false);
check('Determinazione del Dirigente NON compare nel CSV organi', false, strpos($csvOrgani, (string)$determinazioneDirigente->attribute('id')) !== false);

check('intestazione CSV dirigenti', 'DATA;NUMERO;DENOMINAZIONE;OGGETTO;STRUTTURA_RESPONSABILE', explode("\n", $csvDirigenti)[0]);
check('Determinazione del Dirigente compare nel CSV dirigenti con denominazione Determinazione', true, strpos($csvDirigenti, ';Determinazione;') !== false);

check('data risolta dal fallback (act_date assente, usa publication_start_time)', true, strpos($csvOrgani, '12/03/2026') !== false);

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
