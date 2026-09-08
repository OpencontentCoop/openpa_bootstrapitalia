<?php
/**
 * Test E2E: OpenPARolesFunctionCollection::fetchPeople() non deve esporre una
 * public_person marcata privacy:private a un utente che non può leggerla, ma
 * deve continuare a mostrarla a un utente con accesso in lettura.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_openparole_people_access_filter.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'openparole fetchPeople() access filter test',
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

foreach (['public_person', 'time_indexed_role', 'organization'] as $identifier) {
    if (!eZContentClass::fetchByIdentifier($identifier)) {
        echo "\033[33m[SKIP]\033[0m Content type $identifier non trovato\n";
        $script->shutdown(0);
        exit(0);
    }
}

$db = eZDB::instance();
$orgAttrRows = $db->arrayQuery(
    "SELECT a.identifier FROM ezcontentclass_attribute a " .
    "JOIN ezcontentclass c ON c.id = a.contentclass_id AND c.version = a.version " .
    "WHERE c.identifier = 'organization' AND a.data_type_string = 'openparole' " .
    // Preferisce un attributo senza filtro per tipo di ruolo (es. "people", filter:[])
    // — uno con filter:["Responsabile"] richiederebbe di taggare il ruolo di test con
    // quel tipo per essere trovato dalla ricerca, complicando il test senza motivo.
    "ORDER BY (a.data_text5 LIKE '%\"filter\":[]%') DESC LIMIT 1"
);
if (empty($orgAttrRows)) {
    echo "\033[33m[SKIP]\033[0m Nessun attributo openparole su 'organization' in questo DB\n";
    $script->shutdown(0);
    exit(0);
}
$orgAttributeIdentifier = $orgAttrRows[0]['identifier'];
echo "Uso l'attributo organization.$orgAttributeIdentifier (view:3, 'chi lavora qui')\n\n";

$roleParentNodeId = OpenPABootstrapItaliaOperators::getOpenpaRolesParentNodeId();
if (!$roleParentNodeId) {
    echo "\033[33m[SKIP]\033[0m Nodo padre ruoli non configurato\n";
    $script->shutdown(0);
    exit(0);
}

$user      = eZUser::fetchByName('admin');
$adminUser = $user instanceof eZUser ? $user : null;
assert_true($adminUser instanceof eZUser, "Precondizione: utente 'admin' esiste");
$ownerId   = $adminUser ? $adminUser->attribute('contentobject_id') : 14;
$sectionId = eZSection::fetchByIdentifier('standard') ? eZSection::fetchByIdentifier('standard')->attribute('id') : 1;

$personParentRows = $db->arrayQuery(
    "SELECT DISTINCT n.parent_node_id FROM ezcontentobject_tree n " .
    "JOIN ezcontentobject o ON o.id = n.contentobject_id " .
    "JOIN ezcontentclass c ON c.id = o.contentclass_id " .
    "WHERE c.identifier = 'public_person' LIMIT 1"
);
$personParentNodeId = !empty($personParentRows) ? (int)$personParentRows[0]['parent_node_id'] : 2;

$orgParentRows = $db->arrayQuery(
    "SELECT DISTINCT n.parent_node_id FROM ezcontentobject_tree n " .
    "JOIN ezcontentobject o ON o.id = n.contentobject_id " .
    "JOIN ezcontentclass c ON c.id = o.contentclass_id " .
    "WHERE c.identifier = 'organization' LIMIT 1"
);
$orgParentNodeId = !empty($orgParentRows) ? (int)$orgParentRows[0]['parent_node_id'] : 2;

$uniqueSuffix = date('Ymd-His') . '-' . substr(md5(uniqid()), 0, 6);

// L'identità di default di un processo CLI eZScript è anonimo, non admin — senza
// questo, updateobjectstate verrebbe filtrata silenziosamente a vuoto.
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

// ── Organization pubblica (il "punto di vista" della pagina ufficio) ────────

$orgClass = eZContentClass::fetchByIdentifier('organization');
$orgObject = $orgClass->instantiate($ownerId, $sectionId, false, 'ita-IT');
eZNodeAssignment::create([
    'contentobject_id'      => $orgObject->attribute('id'),
    'contentobject_version' => 1,
    'parent_node'           => $orgParentNodeId,
    'is_main'               => 1,
    'sort_field'            => eZContentObjectTreeNode::SORT_FIELD_PUBLISHED,
    'sort_order'            => eZContentObjectTreeNode::SORT_ORDER_DESC,
])->store();
foreach ($orgObject->version(1)->contentObjectAttributes('ita-IT') as $attr) {
    if ($attr->contentClassAttributeIdentifier() === 'name') {
        $attr->fromString('Test Org Public ' . $uniqueSuffix);
        $attr->store();
    }
}
eZOperationHandler::execute('content', 'publish', ['object_id' => $orgObject->attribute('id'), 'version' => 1]);
$orgId = $orgObject->attribute('id');
$createdObjectIds[] = $orgId;
echo "Pubblicata organization pubblica id=$orgId\n\n";

// ── Helper: crea una public_person PRIVATA + role → $orgId ─────────────────

function createPrivatePersonWithRole($orgId, $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, $uniqueSuffix, array &$createdObjectIds)
{
    $personClass = eZContentClass::fetchByIdentifier('public_person');
    $personObject = $personClass->instantiate($ownerId, $sectionId, false, 'ita-IT');
    eZNodeAssignment::create([
        'contentobject_id'      => $personObject->attribute('id'),
        'contentobject_version' => 1,
        'parent_node'           => $personParentNodeId,
        'is_main'               => 1,
        'sort_field'            => eZContentObjectTreeNode::SORT_FIELD_PUBLISHED,
        'sort_order'            => eZContentObjectTreeNode::SORT_ORDER_DESC,
    ])->store();
    foreach ($personObject->version(1)->contentObjectAttributes('ita-IT') as $attr) {
        if ($attr->contentClassAttributeIdentifier() === 'given_name') { $attr->fromString('Test'); $attr->store(); }
        if ($attr->contentClassAttributeIdentifier() === 'family_name') { $attr->fromString($uniqueSuffix); $attr->store(); }
    }
    eZOperationHandler::execute('content', 'publish', ['object_id' => $personObject->attribute('id'), 'version' => 1]);
    $personId = $personObject->attribute('id');
    $createdObjectIds[] = $personId;

    $privacyStates = OpenPABase::initStateGroup('privacy', ['public', 'private']);
    $privateStateId = $privacyStates['privacy.private']->attribute('id');
    eZOperationHandler::execute('content', 'updateobjectstate', [
        'object_id'     => $personId,
        'state_id_list' => [$privateStateId],
    ]);

    $roleClass = eZContentClass::fetchByIdentifier('time_indexed_role');
    $roleObject = $roleClass->instantiate($ownerId, $sectionId, false, 'ita-IT');
    eZNodeAssignment::create([
        'contentobject_id'      => $roleObject->attribute('id'),
        'contentobject_version' => 1,
        'parent_node'           => $roleParentNodeId,
        'is_main'               => 1,
        'sort_field'            => eZContentObjectTreeNode::SORT_FIELD_PUBLISHED,
        'sort_order'            => eZContentObjectTreeNode::SORT_ORDER_DESC,
    ])->store();
    foreach ($roleObject->version(1)->contentObjectAttributes('ita-IT') as $attr) {
        $id = $attr->contentClassAttributeIdentifier();
        if ($id === 'label') { $attr->fromString('Ruolo Test ' . $uniqueSuffix); $attr->store(); }
        if ($id === 'person') { $attr->fromString((string)$personId); $attr->store(); }
        if ($id === 'for_entity') { $attr->fromString((string)$orgId); $attr->store(); }
        if ($id === 'start_time') { $attr->setAttribute('data_int', mktime(0, 0, 0, 1, 1, 2025)); $attr->store(); }
    }
    eZOperationHandler::execute('content', 'publish', ['object_id' => $roleObject->attribute('id'), 'version' => 1]);
    $roleId = $roleObject->attribute('id');
    $createdObjectIds[] = $roleId;

    eZSearch::addObject(eZContentObject::fetch($roleId), true);

    // Attende che il ruolo sia effettivamente cercabile via Solr (eventual
    // consistency) prima di procedere, come in test_has_role_webhook_payload.php.
    $orgAttribute = eZContentObject::fetch($orgId);
    for ($i = 0; $i < 10; $i++) {
        $probe = OpenPARolesFunctionCollection::fetchPeople(
            $orgAttribute->dataMap()[$GLOBALS['orgAttributeIdentifier']],
            0,
            50
        );
        $foundInProbe = false;
        foreach ((array)$probe['result'] as $node) {
            if ($node instanceof eZContentObjectTreeNode && (int)$node->attribute('contentobject_id') === (int)$personId) {
                $foundInProbe = true;
            }
        }
        if ($foundInProbe) { break; }
        usleep(300000);
    }

    return $personId;
}

// ── FASE 1: come admin (deve VEDERE la persona privata) ────────────────────

echo "=== Fase 1: valutazione come admin ===\n";
$personIdAdmin = createPrivatePersonWithRole($orgId, $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, 'Admin-' . $uniqueSuffix, $createdObjectIds);
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

$orgAttributeAdmin = eZContentObject::fetch($orgId)->dataMap()[$orgAttributeIdentifier];
$resultAdmin = OpenPARolesFunctionCollection::fetchPeople($orgAttributeAdmin, 0, 50);
$foundAsAdmin = false;
foreach ((array)$resultAdmin['result'] as $node) {
    if ($node instanceof eZContentObjectTreeNode && (int)$node->attribute('contentobject_id') === (int)$personIdAdmin) {
        $foundAsAdmin = true;
    }
}
assert_true($foundAsAdmin, "fetchPeople(): admin CONTINUA a vedere la persona privata (anteprima redattore preservata)");

// ── FASE 2: come anonimo (NON deve vedere la persona privata) ──────────────

echo "\n=== Fase 2: valutazione come anonimo ===\n";
$personIdAnon = createPrivatePersonWithRole($orgId, $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, 'Anon-' . $uniqueSuffix, $createdObjectIds);

$anonymousUser = eZUser::fetch(eZUser::anonymousId());
eZUser::setCurrentlyLoggedInUser($anonymousUser, eZUser::anonymousId(), eZUser::NO_SESSION_REGENERATE);

$orgAttributeAnon = eZContentObject::fetch($orgId)->dataMap()[$orgAttributeIdentifier];
$resultAnon = OpenPARolesFunctionCollection::fetchPeople($orgAttributeAnon, 0, 50);
$foundAsAnon = false;
foreach ((array)$resultAnon['result'] as $node) {
    if ($node instanceof eZContentObjectTreeNode && (int)$node->attribute('contentobject_id') === (int)$personIdAnon) {
        $foundAsAnon = true;
    }
}
assert_true(!$foundAsAnon, "fetchPeople(): anonimo NON vede più la persona privata (fix del leak)");

eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

echo "\n";
echo "Risultato: $PASSED passati / " . ($PASSED + $FAILED) . " totali\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
