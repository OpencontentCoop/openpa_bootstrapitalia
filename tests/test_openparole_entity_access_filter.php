<?php
/**
 * Test E2E: OpenPARoles::getEntities() non deve esporre un'entità (organization)
 * marcata privacy:private a un utente che non può leggerla (anonimo), ma deve
 * continuare a mostrarla a un utente che ha accesso in lettura (es. redattore) —
 * per preservare l'anteprima "in grigio" esistente (access_style/no-sezioni_per_tutti).
 *
 * Riproduce dal vivo il caso reale osservato su un tenant di produzione, dove
 * un ufficio marcato privacy:private compariva per intero nell'HTML della
 * pagina di una public_person anche da anonimo.
 *
 * Crea DUE coppie person+role distinte (attribute id diversi) per evitare la
 * cache statica per-processo di OpenPARoles::instance() (keyed sull'attribute id):
 * una valutata da anonimo, una da admin, nello stesso processo PHP.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_openparole_entity_access_filter.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'openparole getEntities() access filter test',
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

// ── Verifica pre-condizioni ─────────────────────────────────────────────────

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

// L'identità di default di un processo CLI eZScript è anonimo, non admin — senza
// questo, la successiva updateobjectstate verrebbe filtrata silenziosamente a
// vuoto (anonimo non ha il permesso di assegnare lo stato privacy:private).
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

// ── Crea l'organization di test e la marca privacy:private ────────────────
// Stesso meccanismo esatto usato da "Imposta come privato" in produzione
// (modules/bootstrapitalia/privacy.php).

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

$orgVersion = $orgObject->version(1);
foreach ($orgVersion->contentObjectAttributes('ita-IT') as $attr) {
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
assert_true(isset($privacyStates['privacy.private']), "Precondizione: stato 'privacy.private' disponibile");
$privateStateId = $privacyStates['privacy.private']->attribute('id');
eZOperationHandler::execute('content', 'updateobjectstate', [
    'object_id'      => $orgId,
    'state_id_list'  => [$privateStateId],
]);
echo "organization id=$orgId marcata privacy:private\n\n";


// ── Helper: crea una coppia public_person + time_indexed_role → $orgId ─────

function createPersonWithRole($orgId, $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, $uniqueSuffix, array &$createdObjectIds)
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

    // Pubblicare la persona per ultima: OpenPARoles::instance() cachea per attribute
    // id all'interno del processo — se pubblicassimo la persona prima che il ruolo
    // esista, la prima valutazione (zero ruoli) resterebbe cachata per il resto dello
    // script.
    eZOperationHandler::execute('content', 'publish', ['object_id' => $personId, 'version' => 1]);

    return $personId;
}

// ── FASE 1: valutare come utente con accesso (admin) — l'entità deve restare ──
// Fatta PRIMA di passare ad anonimo, così l'unica valutazione di questo attributo
// in questo processo avviene sotto l'utente admin.

echo "=== Fase 1: valutazione come admin (deve VEDERE l'entità privata, per l'anteprima redattore) ===\n";
$personIdAdmin = createPersonWithRole($orgId, $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, 'Admin-' . $uniqueSuffix, $createdObjectIds);
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

$personAdminObject = eZContentObject::fetch($personIdAdmin);
$entitiesAsAdmin = OpenPARoles::instance($personAdminObject->dataMap()['has_role'])->attribute('entities');
$foundAsAdmin = false;
foreach ($entitiesAsAdmin as $entity) {
    if ($entity instanceof eZContentObject && (int)$entity->attribute('id') === (int)$orgId) { $foundAsAdmin = true; }
}
assert_true($foundAsAdmin, "getEntities(): admin CONTINUA a vedere l'organization privata (anteprima redattore preservata)");

// ── FASE 2: valutare come utente anonimo — l'entità deve sparire ──────────────

echo "\n=== Fase 2: valutazione come anonimo (NON deve vedere l'entità privata) ===\n";
$personIdAnon = createPersonWithRole($orgId, $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, 'Anon-' . $uniqueSuffix, $createdObjectIds);

$anonymousUser = eZUser::fetch(eZUser::anonymousId());
eZUser::setCurrentlyLoggedInUser($anonymousUser, eZUser::anonymousId(), eZUser::NO_SESSION_REGENERATE);

$personAnonObject = eZContentObject::fetch($personIdAnon);
$entitiesAsAnon = OpenPARoles::instance($personAnonObject->dataMap()['has_role'])->attribute('entities');
$foundAsAnon = false;
foreach ($entitiesAsAnon as $entity) {
    if ($entity instanceof eZContentObject && (int)$entity->attribute('id') === (int)$orgId) { $foundAsAnon = true; }
}
assert_true(!$foundAsAnon, "getEntities(): anonimo NON vede più l'organization privata (fix del leak)");

// Ripristina admin per il cleanup (remove richiede permessi)
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

echo "\n";
echo "Risultato: $PASSED passati / " . ($PASSED + $FAILED) . " totali\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
