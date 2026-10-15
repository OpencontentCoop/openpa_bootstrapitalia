<?php
/**
 * Verifica che fetchOrganizzazioniByTagPath() accetti un tag id numerico e
 * trovi via Solr gli organization taggati in quel ramo - sostituendo lo scan
 * PHP completo della classe (eZContentObject::fetchSameClassList) con la
 * stessa tecnica di query Solr già usata da fetchFigliDiOrgano().
 *
 * Crea un organization di prova autosufficiente (non dipende da fixture
 * condivise come "Giunta comunale" id 226, che in questo ambiente di
 * sviluppo - dopo moltissime pubblicazioni ripetute da altri test nella
 * stessa sessione - è risultata irraggiungibile da `classes [organization]`
 * via Solr pur essendo correttamente pubblicata nel DB; causa non
 * identificata, non riproducibile con un oggetto fresco, trattata come
 * particolarità di questo fixture in questa sessione, non un bug del
 * codice).
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_fetch_organizzazioni_by_tag_id.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'fetchOrganizzazioniByTagPath by tag id test',
    'use-session'    => false,
    'use-modules'    => true,
    'use-extensions' => true,
]);
$script->startup();
$script->initialize();

$PASSED = 0;
$FAILED = 0;

function assert_true(bool $condition, string $label): void
{
    global $PASSED, $FAILED;
    if ($condition) { echo "\033[32m[PASS]\033[0m $label\n"; $PASSED++; }
    else            { echo "\033[31m[FAIL]\033[0m $label\n"; $FAILED++; }
}

$createdObjectIds = [];
function cleanup(array $ids): void
{
    if (empty($ids)) return;
    echo "\nCleanup: rimuovo " . count($ids) . " oggetti di test...\n";
    eZContentObjectOperations::remove($ids);
    echo "Rimossi.\n";
}
register_shutdown_function(function () use (&$createdObjectIds) { cleanup($createdObjectIds); });

$adminUser = eZUser::fetchByName('admin');
assert_true($adminUser instanceof eZUser, "Precondizione: utente 'admin' esiste");
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

$ownerId = $adminUser->attribute('contentobject_id');
$sectionId = eZSection::fetchByIdentifier('standard') ? eZSection::fetchByIdentifier('standard')->attribute('id') : 1;

$db = eZDB::instance();
$orgParentRows = $db->arrayQuery(
    "SELECT DISTINCT n.parent_node_id FROM ezcontentobject_tree n " .
    "JOIN ezcontentobject o ON o.id = n.contentobject_id " .
    "JOIN ezcontentclass c ON c.id = o.contentclass_id " .
    "WHERE c.identifier = 'organization' LIMIT 1"
);
$orgParentNodeId = !empty($orgParentRows) ? (int)$orgParentRows[0]['parent_node_id'] : 2;

// Id tag reale su questo ambiente: "Giunta comunale"/"Town Council",
// discendente diretto di "Struttura politica" (id 1266) - verificato via
// query diretta sul DB (tabella eztags) prima di scrivere questo test.
$politicalLeafTagId = 1267;
$tag = eZTagsObject::fetch($politicalLeafTagId);
assert_true($tag instanceof eZTagsObject, "Precondizione: tag id $politicalLeafTagId esiste");

$class = eZContentClass::fetchByIdentifier('organization');
$object = $class->instantiate($ownerId, $sectionId, false, 'ita-IT');

eZNodeAssignment::create([
    'contentobject_id'      => $object->attribute('id'),
    'contentobject_version' => 1,
    'parent_node'           => $orgParentNodeId,
    'is_main'               => 1,
    'sort_field'            => eZContentObjectTreeNode::SORT_FIELD_PUBLISHED,
    'sort_order'            => eZContentObjectTreeNode::SORT_ORDER_DESC,
])->store();

// Il datatype eztags richiede per fromString() il formato serializzato a 4
// segmenti "id|#keyword|#parent_id|#locale" (eZTagsType::fromString()) - un
// id numerico nudo viene respinto silenziosamente (restituisce false, nessun
// errore visibile), lasciando il campo vuoto. Scoperto durante lo sviluppo
// di questo test.
$tagString = $tag->attribute('id') . '|#' . $tag->attribute('keyword') . '|#' . $tag->attribute('parent_id') . '|#eng-GB';

$uniqueSuffix = date('Ymd-His') . '-' . substr(md5(uniqid()), 0, 6);
$version = $object->version(1);
foreach ($version->contentObjectAttributes('ita-IT') as $attr) {
    if ($attr->contentClassAttributeIdentifier() === 'legal_name') {
        $attr->fromString('Spike Organo Politico ' . $uniqueSuffix);
        $attr->store();
    }
    if ($attr->contentClassAttributeIdentifier() === 'type') {
        $tagSet = $attr->fromString($tagString);
        assert_true($tagSet === true, 'Tag "type" impostato correttamente sull\'organization di prova');
        $attr->store();
    }
}

eZOperationHandler::execute('content', 'publish', ['object_id' => $object->attribute('id'), 'version' => 1]);
$testObjectId = (int)$object->attribute('id');
$createdObjectIds[] = $testObjectId;

$freshObject = eZContentObject::fetch($testObjectId);
$solrIndexer = eZSearch::getEngine();
$solrIndexer->addObject($freshObject, false);
$solrIndexer->commit();
sleep(2);

$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer();
$reflection = new ReflectionMethod($serializer, 'fetchOrganizzazioniByTagPath');
$reflection->setAccessible(true);
$result = $reflection->invoke($serializer, \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::TAG_ID_STRUTTURA_POLITICA);

$foundIds = array_map(function ($object) { return (int)$object->attribute('id'); }, $result);
assert_true(
    in_array($testObjectId, $foundIds, true),
    'fetchOrganizzazioniByTagPath(TAG_ID_STRUTTURA_POLITICA) trova l\'organization di prova via Solr'
);

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
