<?php
/**
 * Test E2E: OpenPARoles::getTypesPerEntity() (attribute 'main_type_per_entities',
 * usato dal ramo "compatto/abstract" del template openparole.tpl) non deve esporre
 * il nome di un'entità marcata privacy:private a un utente che non può leggerla —
 * anche se il documento Solr del ruolo contiene ancora il nome congelato al momento
 * dell'indicizzazione. Deve continuare a mostrarla a un utente con accesso in lettura.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_openparole_types_per_entity_access_filter.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'openparole getTypesPerEntity() access filter test',
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

$db = eZDB::instance();
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

// L'identità di default di un processo CLI eZScript è anonimo, non admin.
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

// ── Crea l'organization di test e la marca privacy:private ────────────────

$orgClass = eZContentClass::fetchByIdentifier('organization');
$orgObject = $orgClass->instantiate($ownerId, $sectionId, false, 'ita-IT');
assert_true($orgObject instanceof eZContentObject, 'organization di test istanziata');

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
        $attr->fromString('Test Org Private ' . $uniqueSuffix);
        $attr->store();
    }
}

eZOperationHandler::execute('content', 'publish', ['object_id' => $orgObject->attribute('id'), 'version' => 1]);
$orgId = $orgObject->attribute('id');
$createdObjectIds[] = $orgId;
echo "Pubblicata organization id=$orgId\n";

$privacyStates = OpenPABase::initStateGroup('privacy', ['public', 'private']);
$privateStateId = $privacyStates['privacy.private']->attribute('id');
eZOperationHandler::execute('content', 'updateobjectstate', [
    'object_id'      => $orgId,
    'state_id_list'  => [$privateStateId],
]);
echo "organization id=$orgId marcata privacy:private\n\n";

// ── Helper: crea una coppia public_person + time_indexed_role (ruolo_principale=1) → $orgId

function createPersonWithMainRole($orgId, $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, $uniqueSuffix, array &$createdObjectIds)
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

    $personVersion = $personObject->version(1);
    foreach ($personVersion->contentObjectAttributes('ita-IT') as $attr) {
        if ($attr->contentClassAttributeIdentifier() === 'given_name') {
            $attr->fromString('Test');
            $attr->store();
        }
        if ($attr->contentClassAttributeIdentifier() === 'family_name') {
            $attr->fromString($uniqueSuffix);
            $attr->store();
        }
    }
    $personId = $personObject->attribute('id');
    $createdObjectIds[] = $personId;

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

    $roleVersion = $roleObject->version(1);
    foreach ($roleVersion->contentObjectAttributes('ita-IT') as $attr) {
        $id = $attr->contentClassAttributeIdentifier();
        if ($id === 'label') { $attr->fromString('Ruolo Test ' . $uniqueSuffix); $attr->store(); }
        if ($id === 'person') { $attr->fromString((string)$personId); $attr->store(); }
        if ($id === 'for_entity') { $attr->fromString((string)$orgId); $attr->store(); }
        if ($id === 'start_time') { $attr->setAttribute('data_int', mktime(0, 0, 0, 1, 1, 2025)); $attr->store(); }
        if ($id === 'ruolo_principale') { $attr->fromString('1'); $attr->store(); }
    }
    eZOperationHandler::execute('content', 'publish', ['object_id' => $roleObject->attribute('id'), 'version' => 1]);
    $roleId = $roleObject->attribute('id');
    $createdObjectIds[] = $roleId;

    eZSearch::addObject(eZContentObject::fetch($roleId), true);
    for ($i = 0; $i < 10; $i++) {
        $probe = OpenPARoles::instance(eZContentObject::fetch($personId)->dataMap()['has_role']);
        if ($probe->hasContent()) { break; }
        usleep(300000);
    }

    // Pubblicare la persona per ultima: vedi nota nel test getEntities sulla cache
    // per-processo di OpenPARoles::instance().
    eZOperationHandler::execute('content', 'publish', ['object_id' => $personId, 'version' => 1]);

    return $personId;
}

// ── FASE 1: come admin (deve VEDERE il nome dell'entità privata) ───────────

echo "=== Fase 1: valutazione come admin ===\n";
$personIdAdmin = createPersonWithMainRole($orgId, $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, 'Admin-' . $uniqueSuffix, $createdObjectIds);
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

$personAdminObject = eZContentObject::fetch($personIdAdmin);
$typesPerEntityAdmin = OpenPARoles::instance($personAdminObject->dataMap()['has_role'])->attribute('main_type_per_entities');
$foundNameAsAdmin = false;
foreach ($typesPerEntityAdmin as $type => $entitiesById) {
    if (isset($entitiesById[$orgId])) { $foundNameAsAdmin = true; }
}
assert_true($foundNameAsAdmin, "getTypesPerEntity(): admin CONTINUA a vedere il nome dell'entità privata");

// ── FASE 2: come anonimo (NON deve vedere il nome dell'entità privata) ─────

echo "\n=== Fase 2: valutazione come anonimo ===\n";
$personIdAnon = createPersonWithMainRole($orgId, $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, 'Anon-' . $uniqueSuffix, $createdObjectIds);

$anonymousUser = eZUser::fetch(eZUser::anonymousId());
eZUser::setCurrentlyLoggedInUser($anonymousUser, eZUser::anonymousId(), eZUser::NO_SESSION_REGENERATE);

$personAnonObject = eZContentObject::fetch($personIdAnon);
$typesPerEntityAnon = OpenPARoles::instance($personAnonObject->dataMap()['has_role'])->attribute('main_type_per_entities');
$foundNameAsAnon = false;
foreach ($typesPerEntityAnon as $type => $entitiesById) {
    if (isset($entitiesById[$orgId])) { $foundNameAsAnon = true; }
}
assert_true(!$foundNameAsAnon, "getTypesPerEntity(): anonimo NON vede più il nome dell'entità privata (fix del leak)");

eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

echo "\n";
echo "Risultato: $PASSED passati / " . ($PASSED + $FAILED) . " totali\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
