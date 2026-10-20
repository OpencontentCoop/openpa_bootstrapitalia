<?php
/**
 * Verifica che fetchOrganiAmministrativi() trovi come vertice SOLO gli
 * organization taggati esattamente "Area" con hold_employment vuoto -
 * stesso comportamento di oggi, ma dopo aver spostato il controllo da PHP
 * (isTaggedArea + empty($holdEmployment)) a una singola query Solr.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_fetch_organi_amministrativi_vertice.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'fetchOrganiAmministrativi vertice test',
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
    // eZContentObjectOperations::remove() vuole un SINGOLO id numerico, non
    // un array (verificato leggendo il kernel: con un array fetch() ritorna
    // null e la funzione esce subito con false, senza rimuovere nulla e
    // senza nessun errore visibile) - scoperto dopo che la cleanup di
    // questo stesso test ha lasciato oggetti orfani nel DB per l'intera
    // sessione di sviluppo del Task 4/6.
    foreach ($ids as $id) {
        eZContentObjectOperations::remove($id);
    }
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

// Id reali su questo ambiente (verificati via query diretta sulla tabella
// eztags prima di scrivere questo test): 1279 = "Area", figlio diretto di
// "Struttura amministrativa" (1278); 1280 = "Ufficio", suo fratello.
const TAG_ID_AREA = 1279;
const TAG_ID_UFFICIO = 1280;

/**
 * Crea un organization di prova con un tag `type` e, opzionalmente, un
 * `hold_employment` verso un altro organization.
 *
 * Nota sul formato eztags: fromString() richiede il formato serializzato a
 * 4 segmenti "id|#keyword|#parent_id|#locale" (eZTagsType::fromString()) -
 * un id numerico nudo viene respinto silenziosamente (ritorna false, il
 * campo resta vuoto). Scoperto durante lo sviluppo del test del Task 3,
 * riusato qui.
 */
function createOrganization(string $legalName, int $typeTagId, ?int $holdEmploymentTargetId, int $ownerId, int $sectionId, int $parentNodeId, array &$createdObjectIds): eZContentObject
{
    $class = eZContentClass::fetchByIdentifier('organization');
    $object = $class->instantiate($ownerId, $sectionId, false, 'ita-IT');

    eZNodeAssignment::create([
        'contentobject_id'      => $object->attribute('id'),
        'contentobject_version' => 1,
        'parent_node'           => $parentNodeId,
        'is_main'               => 1,
        'sort_field'            => eZContentObjectTreeNode::SORT_FIELD_PUBLISHED,
        'sort_order'            => eZContentObjectTreeNode::SORT_ORDER_DESC,
    ])->store();

    $tag = eZTagsObject::fetch($typeTagId);
    $tagString = $tag->attribute('id') . '|#' . $tag->attribute('keyword') . '|#' . $tag->attribute('parent_id') . '|#eng-GB';

    $version = $object->version(1);
    foreach ($version->contentObjectAttributes('ita-IT') as $attr) {
        if ($attr->contentClassAttributeIdentifier() === 'legal_name') {
            $attr->fromString($legalName);
            $attr->store();
        }
        if ($attr->contentClassAttributeIdentifier() === 'type') {
            $attr->fromString($tagString);
            $attr->store();
        }
        if ($holdEmploymentTargetId !== null && $attr->contentClassAttributeIdentifier() === 'hold_employment') {
            $attr->fromString((string)$holdEmploymentTargetId);
            $attr->store();
        }
    }

    eZOperationHandler::execute('content', 'publish', ['object_id' => $object->attribute('id'), 'version' => 1]);
    $createdObjectIds[] = (int)$object->attribute('id');

    return eZContentObject::fetch((int)$object->attribute('id'));
}

$uniqueSuffix = date('Ymd-His') . '-' . substr(md5(uniqid()), 0, 6);

$vertice = createOrganization("Spike Area Vertice $uniqueSuffix", TAG_ID_AREA, null, $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);
$direzione = createOrganization("Spike Direzione $uniqueSuffix", TAG_ID_AREA, (int)$vertice->attribute('id'), $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);
$ufficioOrfano = createOrganization("Spike Ufficio Orfano $uniqueSuffix", TAG_ID_UFFICIO, null, $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);

$solrIndexer = eZSearch::getEngine();
foreach ([$vertice, $direzione, $ufficioOrfano] as $id => $object) {
    $solrIndexer->addObject(eZContentObject::fetch($object->attribute('id')), false);
}
$solrIndexer->commit();
sleep(2);

$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer();
$organi = $serializer->fetchOrganiAmministrativi();
$denominazioni = array_map(function ($organo) { return $organo['denominazione']; }, $organi);

assert_true(
    in_array($vertice->attribute('name'), $denominazioni, true),
    'L\'Area con hold_employment vuoto compare come organo di vertice'
);
assert_true(
    !in_array($direzione->attribute('name'), $denominazioni, true),
    'L\'Area con hold_employment valorizzato NON compare come organo di vertice (è una Direzione, non un vertice)'
);
assert_true(
    !in_array($ufficioOrfano->attribute('name'), $denominazioni, true),
    'Un Ufficio con hold_employment vuoto NON compare come organo di vertice (tag "Area" richiesto, non "Ufficio")'
);

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
