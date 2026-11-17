<?php
/**
 * Riproduce il caso che ha causato il timeout (503 "Page Unavailable") della
 * pagina "Articolazione degli uffici" su un tenant reale (bugliano QA,
 * 2026-11-11): un `organization` con `hold_employment` valorizzato con PIU'
 * di un genitore (il campo e' un ezobjectrelationlist multi-valore) viene
 * trovato come figlio di OGNUNO di quei genitori da fetchFigliDiOrgano() -
 * senza memoizzazione, fetchUfficiFigli() rifà da capo tutta la query Solr +
 * ricorsione per ogni genitore che lo ritrova, invece di una volta sola.
 *
 * Verifica che Art13Serializer::fetchUfficiFigli() calcoli il sottoalbero di
 * un organo condiviso tra piu' radici UNA sola volta per richiesta (cache per
 * id, vedi $ufficiFigliCache), non una volta per ogni radice che lo
 * raggiunge - indipendentemente da quante radici lo condividano.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_fetch_ufficio_figli_duplicate_roots_memoization.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'fetchUfficiFigli duplicate roots memoization test',
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
function assert_eq($a, $b, string $label): void
{
    global $PASSED, $FAILED;
    if ($a === $b) { echo "\033[32m[PASS]\033[0m $label\n"; $PASSED++; }
    else            { echo "\033[31m[FAIL]\033[0m $label (got " . var_export($a, true) . ", expected " . var_export($b, true) . ")\n"; $FAILED++; }
}

$createdObjectIds = [];
function cleanup(array $ids): void
{
    if (empty($ids)) return;
    echo "\nCleanup: rimuovo " . count($ids) . " oggetti di test...\n";
    // eZContentObjectOperations::remove() vuole un SINGOLO id numerico, non un
    // array - stesso gotcha documentato in
    // test_art13_fetch_organi_amministrativi_vertice.php.
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

$areaTag = eZTagsObject::fetchByRemoteID(\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::TAG_REMOTE_ID_AREA);
assert_true($areaTag instanceof eZTagsObject, 'Precondizione: tag "Area" trovato per remote_id');
define('TAG_ID_AREA', (int)$areaTag->attribute('id'));

/**
 * Stessa createOrganization() del test "vertice", estesa per accettare PIU'
 * di un id in hold_employment (il campo e' un ezobjectrelationlist
 * multi-valore - fromString() accetta id "-"-separati, vedi
 * ezobjectrelationlisttype::fromString() nel kernel).
 */
function createOrganization(string $legalName, int $typeTagId, array $holdEmploymentTargetIds, int $ownerId, int $sectionId, int $parentNodeId, array &$createdObjectIds): eZContentObject
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
        if (!empty($holdEmploymentTargetIds) && $attr->contentClassAttributeIdentifier() === 'hold_employment') {
            $attr->fromString(implode('-', $holdEmploymentTargetIds));
            $attr->store();
        }
    }

    eZOperationHandler::execute('content', 'publish', ['object_id' => $object->attribute('id'), 'version' => 1]);
    $createdObjectIds[] = (int)$object->attribute('id');

    return eZContentObject::fetch((int)$object->attribute('id'));
}

$uniqueSuffix = date('Ymd-His') . '-' . substr(md5(uniqid()), 0, 6);
$numeroRadici = 5;

// N radici distinte, genuinamente vertici (hold_employment vuoto) - come
// fetchVerticeAmministrativi() ne troverebbe N reali su un tenant con dati
// sporchi/duplicati, non una sola radice ripetuta.
$radici = [];
for ($i = 1; $i <= $numeroRadici; $i++) {
    $radici[] = createOrganization("Spike Radice $i $uniqueSuffix", TAG_ID_AREA, [], $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);
}
$radiciIds = array_map(function ($r) { return (int)$r->attribute('id'); }, $radici);

// Un solo organo condiviso, il cui hold_employment elenca TUTTE le N radici
// come genitore - fetchFigliDiOrgano() lo ritrova una volta per ciascuna.
$condiviso = createOrganization("Spike Direzione Condivisa $uniqueSuffix", TAG_ID_AREA, $radiciIds, $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);

// Un ufficio sotto l'organo condiviso, cosi' il sottoalbero duplicato non e'
// banale (profondita' 2, non solo l'organo condiviso stesso).
$ufficioFiglio = createOrganization("Spike Ufficio Figlio $uniqueSuffix", TAG_ID_AREA, [(int)$condiviso->attribute('id')], $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);

$solrIndexer = eZSearch::getEngine();
foreach (array_merge($radici, [$condiviso, $ufficioFiglio]) as $object) {
    $solrIndexer->addObject(eZContentObject::fetch($object->attribute('id')), false);
}
$solrIndexer->commit();
sleep(2);

$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer();
$reflMethod = new ReflectionMethod($serializer, 'fetchUfficiFigli');
$reflMethod->setAccessible(true);
$reflCache = new ReflectionProperty($serializer, 'ufficiFigliCache');
$reflCache->setAccessible(true);

$risultatiPerRadice = [];
foreach ($radici as $radice) {
    $risultatiPerRadice[] = $reflMethod->invoke($serializer, $radice);
}

// Ogni radice deve comunque trovare l'organo condiviso con il suo ufficio
// figlio sotto di se' (la cache non deve far SPARIRE dati legittimi, solo
// evitare di ricalcolarli).
foreach ($risultatiPerRadice as $i => $risultato) {
    assert_true(
        count($risultato) === 2,
        "Radice " . ($i + 1) . ": trova l'organo condiviso + il suo ufficio figlio (2 uffici)"
    );
}

// La cache deve contenere esattamente un'entry per id distinto realmente
// passato a fetchUfficiFigli(): le N radici (una chiamata ciascuna, mai
// ripetuta nel test) + l'organo condiviso + il suo ufficio figlio (questi
// due calcolati una volta sola, alla prima radice che li raggiunge, poi
// serviti dalla cache per le radici successive).
$cache = $reflCache->getValue($serializer);
assert_eq(count($cache), $numeroRadici + 2, 'La cache ha esattamente una entry per organo distinto (radici + condiviso + suo figlio), non una per occorrenza');

foreach ($radiciIds as $radiceId) {
    assert_true(isset($cache[$radiceId]), "La cache contiene l'entry per la radice $radiceId");
}
assert_true(isset($cache[(int)$condiviso->attribute('id')]), "La cache contiene l'entry per l'organo condiviso (calcolata una sola volta)");
assert_true(isset($cache[(int)$ufficioFiglio->attribute('id')]), "La cache contiene l'entry per l'ufficio figlio dell'organo condiviso");

// Il risultato servito dalla cache alle radici successive e' letteralmente
// la stessa istanza di array (nessuna ricostruzione), non solo un valore
// uguale per coincidenza.
assert_true($risultatiPerRadice[0] === $risultatiPerRadice[1], 'Il risultato per l\'organo condiviso e identico (dalla cache) tra la prima e la seconda radice che lo raggiunge');

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
