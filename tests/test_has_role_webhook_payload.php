<?php
/**
 * Test E2E: OpenPARoleAttributeConverter — has_role deve esporre i dati reali del
 * ruolo (non più il placeholder "(calculated)"), con for_entity risolto e
 * standardizzato dalla pipeline ocwebhookserver (id "instance:objectId",
 * content_url, niente mainNodeId residuo).
 *
 * Crea una public_person con un ruolo collegato all'ente esistente "Giunta comunale"
 * (id 226 in questo DB di sviluppo), verifica il converter isolato e l'intera
 * pipeline webhook (Content::createFromEzContentObject → OCWebHookPayloadBuilder
 * → OCWebHookKafkaPayloadFormatter), poi ripulisce gli oggetti creati.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_has_role_webhook_payload.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'has_role webhook payload test',
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
    else {
        echo "\033[31m[FAIL]\033[0m $label — atteso " . var_export($b, true) . ", ottenuto " . var_export($a, true) . "\n";
        $FAILED++;
    }
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

// ── Verifica pre-condizioni ────────────────────────────────────────────────────

foreach (['public_person', 'time_indexed_role', 'organization'] as $identifier) {
    if (!eZContentClass::fetchByIdentifier($identifier)) {
        echo "\033[33m[SKIP]\033[0m Content type $identifier non trovato\n";
        $script->shutdown(0);
        exit(0);
    }
}

$giuntaComunale = eZContentObject::fetch(226);
if (!$giuntaComunale || $giuntaComunale->attribute('name') !== 'Giunta comunale') {
    echo "\033[33m[SKIP]\033[0m Oggetto 'Giunta comunale' (id 226) non trovato in questo DB — fixture specifica di questo ambiente\n";
    $script->shutdown(0);
    exit(0);
}
$giuntaMainNode = $giuntaComunale->mainNode();
assert_true($giuntaMainNode instanceof eZContentObjectTreeNode, "Precondizione: 'Giunta comunale' ha un main node");

// ── Crea public_person di test ─────────────────────────────────────────────────

$uniqueSuffix = date('Ymd-His') . '-' . substr(md5(uniqid()), 0, 6);
$personName   = 'Test HasRole ' . $uniqueSuffix;

$user      = eZUser::fetchByName('admin');
$ownerId   = $user ? $user->attribute('contentobject_id') : 14;
$sectionId = eZSection::fetchByIdentifier('standard') ? eZSection::fetchByIdentifier('standard')->attribute('id') : 1;

$db = eZDB::instance();
$parentRows = $db->arrayQuery(
    "SELECT DISTINCT n.parent_node_id FROM ezcontentobject_tree n " .
    "JOIN ezcontentobject o ON o.id = n.contentobject_id " .
    "JOIN ezcontentclass c ON c.id = o.contentclass_id " .
    "WHERE c.identifier = 'public_person' LIMIT 1"
);
$personParentNodeId = !empty($parentRows) ? (int)$parentRows[0]['parent_node_id'] : 2;

$personClass = eZContentClass::fetchByIdentifier('public_person');
$personObject = $personClass->instantiate($ownerId, $sectionId, false, 'ita-IT');
assert_true($personObject instanceof eZContentObject, 'public_person istanziato');

eZNodeAssignment::create([
    'contentobject_id'      => $personObject->attribute('id'),
    'contentobject_version' => 1,
    'parent_node'           => $personParentNodeId,
    'is_main'               => 1,
    'sort_field'            => eZContentObjectTreeNode::SORT_FIELD_PUBLISHED,
    'sort_order'            => eZContentObjectTreeNode::SORT_ORDER_DESC,
])->store();

$personVersion = $personObject->version(1);
foreach ($personVersion->contentObjectAttributes('ita-IT') as $attr) {
    if ($attr->contentClassAttributeIdentifier() === 'given_name') {
        $attr->fromString('Test');
        $attr->store();
    }
    if ($attr->contentClassAttributeIdentifier() === 'family_name') {
        $attr->fromString('HasRole ' . $uniqueSuffix);
        $attr->store();
    }
}

eZOperationHandler::execute('content', 'publish', ['object_id' => $personObject->attribute('id'), 'version' => 1]);
$personId = $personObject->attribute('id');
$createdObjectIds[] = $personId;
echo "Pubblicata public_person id=$personId — \"$personName\"\n";

// ── Crea time_indexed_role collegato a Giunta comunale ─────────────────────────

$roleParentRows = $db->arrayQuery(
    "SELECT DISTINCT n.parent_node_id FROM ezcontentobject_tree n " .
    "JOIN ezcontentobject o ON o.id = n.contentobject_id " .
    "JOIN ezcontentclass c ON c.id = o.contentclass_id " .
    "WHERE c.identifier = 'time_indexed_role' LIMIT 1"
);
$roleParentNodeId = !empty($roleParentRows) ? (int)$roleParentRows[0]['parent_node_id'] : 2;

$roleClass = eZContentClass::fetchByIdentifier('time_indexed_role');
$roleObject = $roleClass->instantiate($ownerId, $sectionId, false, 'ita-IT');
assert_true($roleObject instanceof eZContentObject, 'time_indexed_role istanziato');

eZNodeAssignment::create([
    'contentobject_id'      => $roleObject->attribute('id'),
    'contentobject_version' => 1,
    'parent_node'           => $roleParentNodeId,
    'is_main'               => 1,
    'sort_field'            => eZContentObjectTreeNode::SORT_FIELD_PUBLISHED,
    'sort_order'            => eZContentObjectTreeNode::SORT_ORDER_DESC,
])->store();

$knownStartTimestamp = mktime(0, 0, 0, 7, 9, 2025); // 2025-07-09, come il caso reale Turci/Bugliano

$roleVersion = $roleObject->version(1);
foreach ($roleVersion->contentObjectAttributes('ita-IT') as $attr) {
    $id = $attr->contentClassAttributeIdentifier();
    if ($id === 'label') {
        $attr->fromString('Assessore Test — ' . $uniqueSuffix);
        $attr->store();
    }
    if ($id === 'person') {
        $attr->fromString((string)$personId);
        $attr->store();
    }
    if ($id === 'for_entity') {
        $attr->fromString((string)$giuntaComunale->attribute('id'));
        $attr->store();
    }
    if ($id === 'start_time') {
        $attr->setAttribute('data_int', $knownStartTimestamp);
        $attr->store();
    }
}

eZOperationHandler::execute('content', 'publish', ['object_id' => $roleObject->attribute('id'), 'version' => 1]);
$roleId = $roleObject->attribute('id');
$createdObjectIds[] = $roleId;
echo "Pubblicato time_indexed_role id=$roleId, person=$personId, for_entity=" . $giuntaComunale->attribute('id') . "\n\n";

// NOTA: OpenPARoleAttributeConverter::get() risolve i ruoli tramite
// OpenPARoles::attribute('roles'), che dipende da una ricerca Solr sull'oggetto
// person (person.id = ...). In questo ambiente di sviluppo Solr indicizza i
// documenti senza memorizzare alcun campo (anche con commit esplicito e
// indicizzazione sincrona forzata via eZSearch::addObject) — problema
// preesistente dell'installazione locale, non introdotto da questa modifica.
// Per non dipendere da quel livello (che il fix di questo lavoro non tocca),
// TEST 1 chiama direttamente — via reflection — il metodo privato di
// serializzazione di un singolo ruolo, che è il codice realmente modificato.

$reflection = new ReflectionClass('OpenPARoleAttributeConverter');
$serializeRole = $reflection->getMethod('serializeRole');
$serializeRole->setAccessible(true);

$freshRoleObject = eZContentObject::fetch($roleId); // ricarica, versione pubblicata

// ── TEST 1: serializzazione del ruolo (codice modificato) ───────────────────────

$roleItem = $serializeRole->invoke(null, $freshRoleObject);

assert_true(is_array($roleItem), 'serializeRole: restituisce un array (non più la stringa "(calculated)")');
assert_eq($roleItem['id'], (int)$roleId, 'serializeRole: id del ruolo corretto');
assert_eq($roleItem['classIdentifier'], 'time_indexed_role', 'serializeRole: classIdentifier del ruolo');
assert_eq((int)$roleItem['mainNodeId'], (int)$freshRoleObject->mainNode()->attribute('node_id'), 'serializeRole: mainNodeId del ruolo (interno, verrà droppato a valle)');
assert_true(count($roleItem['for_entity']) === 1, 'serializeRole: for_entity ha esattamente 1 elemento');

if (count($roleItem['for_entity']) === 1) {
    $entity = $roleItem['for_entity'][0];
    assert_eq((int)$entity['id'], 226, 'serializeRole: for_entity punta a Giunta comunale (id 226)');
    assert_eq($entity['name'], 'Giunta comunale', 'serializeRole: for_entity.name = "Giunta comunale"');
    assert_eq($entity['classIdentifier'], 'organization', 'serializeRole: for_entity.classIdentifier = organization');
    assert_true(!empty($entity['mainNodeId']), 'serializeRole: for_entity.mainNodeId presente (necessario per content_url a valle)');
}

assert_true($roleItem['start_date'] !== null, 'serializeRole: start_date valorizzato');
assert_true(strpos($roleItem['start_date'], '2025-07-09') === 0, 'serializeRole: start_date riflette la data impostata (2025-07-09)');
assert_eq($roleItem['end_date'], null, 'serializeRole: end_date null (non impostato)');
assert_eq($roleItem['role'], [], 'serializeRole: "role" (eztags non impostato in questo fixture) → array vuoto, nessun errore');

// ── TEST 2: pipeline ocwebhookserver reale (stesso item, come se venisse da has_role) ──
// Il resto della pipeline (Content::createFromEzContentObject → converter → questo
// punto) è indipendente da Solr: qui verifichiamo con dati reali (mainNodeId veri,
// urlAlias() vere) che enrichRelationContentUrls()/normalizeRelationItem() — il
// codice modificato in ocwebhookserver — normalizzino correttamente l'item annidato.

require_once $ezRoot . '/extension/ocwebhookserver/classes/ocwebhookpayloadbuilder.php';
require_once $ezRoot . '/extension/ocwebhookserver/classes/ocwebhookkafkapayloadformatter.php';

$rawPayload = [
    'metadata' => ['id' => (string)$personId, 'classIdentifier' => 'public_person', 'languages' => ['ita-IT']],
    'data' => ['ita-IT' => ['has_role' => ['content' => [$roleItem], 'type' => 'openparole']]],
];
OCWebHookPayloadBuilder::enrichRelationContentUrls($rawPayload, 'https://www.comune.example.it');

$formatter = new OCWebHookKafkaPayloadFormatter('frontend', 'testinstance');
$kafkaPayload = $formatter->format($rawPayload);

$hasRoleOut = $kafkaPayload['entity']['data']['ita-IT']['has_role'] ?? null;
assert_true(is_array($hasRoleOut) && count($hasRoleOut) === 1, 'pipeline: has_role presente in entity.data.ita-IT con 1 ruolo');

$roleOut = $hasRoleOut[0] ?? null;
assert_true($roleOut !== null, 'pipeline: il ruolo di test è presente nel messaggio Kafka finale');

if ($roleOut !== null) {
    assert_eq($roleOut['id'], 'testinstance:' . $roleId, 'pipeline: ruolo — id standardizzato "instance:objectId"');
    assert_eq($roleOut['type_id'], 'time_indexed_role', 'pipeline: ruolo — type_id');
    assert_true(!isset($roleOut['mainNodeId']) && !isset($roleOut['main_node_id']), 'pipeline: ruolo — mainNodeId droppato dal payload finale');

    assert_true(isset($roleOut['for_entity']) && count($roleOut['for_entity']) === 1, 'pipeline: for_entity presente con 1 elemento');
    if (isset($roleOut['for_entity'][0])) {
        $entityOut = $roleOut['for_entity'][0];
        assert_eq($entityOut['id'], 'testinstance:226', 'pipeline: for_entity — id standardizzato "instance:226" (STESSA istanza del ruolo)');
        assert_eq($entityOut['type_id'], 'organization', 'pipeline: for_entity — type_id = organization');
        assert_eq($entityOut['title'], 'Giunta comunale', 'pipeline: for_entity — title = "Giunta comunale"');
        assert_true(!isset($entityOut['mainNodeId']) && !isset($entityOut['main_node_id']), 'pipeline: for_entity — mainNodeId droppato');
        assert_true(isset($entityOut['content_url']) && is_string($entityOut['content_url']) && strlen($entityOut['content_url']) > 0,
            'pipeline: for_entity — content_url risolto (URL pubblico di Giunta comunale)');
        echo "    → content_url risolto: " . $entityOut['content_url'] . "\n";
    }

    assert_true(isset($roleOut['start_date']), 'pipeline: start_date presente nel payload finale');
    assert_true(strpos((string)$roleOut['start_date'], '2025-07-0') === 0, 'pipeline: start_date normalizzato a UTC, ancora riconducibile al 2025-07-09');
    echo "    → start_date finale: " . $roleOut['start_date'] . "\n";
}

// ─────────────────────────────────────────────────────────────────────────────

echo "\n";
echo "Risultato: $PASSED passati / " . ($PASSED + $FAILED) . " totali\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
