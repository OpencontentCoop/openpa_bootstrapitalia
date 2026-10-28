<?php
/**
 * Test E2E: OpenPARoles::filterReadableObjects() deve scartare gli oggetti senza nodo
 * principale (archiviati / nel cestino), che un ruolo (for_entity) puo' ancora referenziare.
 *
 * Regressione osservata su un tenant di produzione (ticket Freshdesk #32045): dopo il
 * riordino dell'organigramma le organization vecchie sono finite nel cestino ma i ruoli
 * (time_indexed_role) puntavano ancora a loro; per un redattore con una policy a
 * limitazione Node, OpenPAWhoCan::checkAccess() chiamava mainNode()->attribute('node_id')
 * su un oggetto senza nodo principale ("Call to a member function attribute() on null",
 * HTTP 500 su tutte le schede con un ruolo su quell'ente).
 *
 * Fase 1 (admin): getEntities() non deve mostrare l'organization archiviata.
 * Fase 2 (utente con policy content/read limitata per Node): filterReadableObjects() non deve
 * andare in fatal, deve scartare l'ente archiviato e mantenere quello vivo.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_openparole_archived_entity_access_filter.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'openparole archived entity access filter test',
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
$createdRoleIds = [];
$createdSectionIds = [];
function cleanup(array $ids, array $roleIds, array $sectionIds): void
{
    echo "\nCleanup: rimuovo " . count($ids) . " oggetti e " . count($roleIds) . " ruoli di test...\n";
    foreach ($roleIds as $roleId) {
        $role = eZRole::fetch($roleId);
        if ($role instanceof eZRole) { $role->removeThis(); }
    }
    foreach ($ids as $id) {
        $object = eZContentObject::fetch($id);
        if ($object instanceof eZContentObject) {
            // purge() rimuove anche gli oggetti archiviati (nel cestino), che remove() non tocca
            $object->purge();
        }
    }
    foreach ($sectionIds as $sectionId) {
        $section = eZSection::fetch($sectionId);
        if ($section instanceof eZSection) { $section->removeThis(); }
    }
    eZRole::expireCache();
    echo "Rimossi.\n";
}
register_shutdown_function(function () use (&$createdObjectIds, &$createdRoleIds, &$createdSectionIds) { cleanup($createdObjectIds, $createdRoleIds, $createdSectionIds); });

// ── Verifica pre-condizioni ─────────────────────────────────────────────────

foreach (['public_person', 'time_indexed_role', 'organization', 'user'] as $identifier) {
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

$adminUser = eZUser::fetchByName('admin');
assert_true($adminUser instanceof eZUser, "Precondizione: utente 'admin' esiste");
$ownerId   = $adminUser->attribute('contentobject_id');
$sectionId = eZSection::fetchByIdentifier('standard') ? eZSection::fetchByIdentifier('standard')->attribute('id') : 1;
eZUser::setCurrentlyLoggedInUser($adminUser, $ownerId, eZUser::NO_SESSION_REGENERATE);

$db = eZDB::instance();
$parentOf = function (string $classIdentifier) use ($db): int {
    $rows = $db->arrayQuery(
        "SELECT DISTINCT n.parent_node_id FROM ezcontentobject_tree n " .
        "JOIN ezcontentobject o ON o.id = n.contentobject_id " .
        "JOIN ezcontentclass c ON c.id = o.contentclass_id " .
        "WHERE c.identifier = '" . $db->escapeString($classIdentifier) . "' LIMIT 1"
    );
    return !empty($rows) ? (int)$rows[0]['parent_node_id'] : 2;
};
$personParentNodeId = $parentOf('public_person');
$orgParentNodeId    = $parentOf('organization');
$userParentNodeId   = $parentOf('user');

$uniqueSuffix = date('Ymd-His') . '-' . substr(md5(uniqid()), 0, 6);

// ── Helper ───────────────────────────────────────────────────────────────────

function createObject(string $classIdentifier, int $parentNodeId, int $ownerId, int $sectionId, array $attributes, array &$createdObjectIds): eZContentObject
{
    $class = eZContentClass::fetchByIdentifier($classIdentifier);
    $object = $class->instantiate($ownerId, $sectionId, false, 'ita-IT');
    eZNodeAssignment::create([
        'contentobject_id'      => $object->attribute('id'),
        'contentobject_version' => 1,
        'parent_node'           => $parentNodeId,
        'is_main'               => 1,
        'sort_field'            => eZContentObjectTreeNode::SORT_FIELD_PUBLISHED,
        'sort_order'            => eZContentObjectTreeNode::SORT_ORDER_DESC,
    ])->store();
    foreach ($object->version(1)->contentObjectAttributes('ita-IT') as $attr) {
        $id = $attr->contentClassAttributeIdentifier();
        if (isset($attributes[$id])) {
            $attr->fromString($attributes[$id]);
            $attr->store();
        }
    }
    $createdObjectIds[] = $object->attribute('id');
    eZOperationHandler::execute('content', 'publish', ['object_id' => $object->attribute('id'), 'version' => 1]);

    return eZContentObject::fetch($object->attribute('id'));
}

function createPersonWithRole($entityIds, $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, $uniqueSuffix, array &$createdObjectIds, $withLabel = true)
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
        if ($attr->contentClassAttributeIdentifier() === 'given_name')  { $attr->fromString('Test'); $attr->store(); }
        if ($attr->contentClassAttributeIdentifier() === 'family_name') { $attr->fromString($uniqueSuffix); $attr->store(); }
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
    foreach ($roleObject->version(1)->contentObjectAttributes('ita-IT') as $attr) {
        $id = $attr->contentClassAttributeIdentifier();
        if ($id === 'label' && $withLabel) { $attr->fromString('Ruolo Test ' . $uniqueSuffix); $attr->store(); }
        if ($id === 'person')     { $attr->fromString((string)$personId); $attr->store(); }
        if ($id === 'for_entity') { $attr->fromString(implode('-', $entityIds)); $attr->store(); }
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
    // Persona pubblicata per ultima: OpenPARoles::instance() cachea per attribute id nel processo.
    eZOperationHandler::execute('content', 'publish', ['object_id' => $personId, 'version' => 1]);

    return $personId;
}

function entityIds(array $entities): array
{
    $ids = [];
    foreach ($entities as $entity) {
        if ($entity instanceof eZContentObject) { $ids[] = (int)$entity->attribute('id'); }
    }
    return $ids;
}

// ── Setup: un'organization viva (A) e una finita nel cestino (B) ─────────────
// Le due organization stanno in una sezione dedicata: cosi' le policy ereditate dall'utente di
// test (per Section/Class) non le autorizzano in anticipo e OpenPAWhoCan valuta davvero il ramo
// 'Node' (quello che andava in fatal su un oggetto senza nodo principale).

$testSection = new eZSection(['name' => 'Test archived entity ' . $uniqueSuffix, 'identifier' => 'test-archived-' . substr(md5($uniqueSuffix), 0, 8), 'locale' => '']);
$testSection->store();
$testSectionId = (int)$testSection->attribute('id');
$createdSectionIds[] = $testSectionId;

$orgLive = createObject('organization', $orgParentNodeId, $ownerId, $testSectionId, ['name' => 'Test Org Viva ' . $uniqueSuffix], $createdObjectIds);
$orgGone = createObject('organization', $orgParentNodeId, $ownerId, $testSectionId, ['name' => 'Test Org Archiviata ' . $uniqueSuffix], $createdObjectIds);
$orgLiveId = (int)$orgLive->attribute('id');
$orgGoneId = (int)$orgGone->attribute('id');
$orgLiveNodeId = (int)$orgLive->attribute('main_node_id');
// La sezione dell'oggetto puo' essere riallineata a quella del nodo padre alla pubblicazione: la forziamo.
eZContentObjectTreeNode::assignSectionToSubTree($orgLiveNodeId, $testSectionId);
eZContentObjectTreeNode::assignSectionToSubTree((int)$orgGone->attribute('main_node_id'), $testSectionId);
assert_true((int)eZContentObject::fetch($orgLiveId)->attribute('section_id') === $testSectionId
    && (int)eZContentObject::fetch($orgGoneId)->attribute('section_id') === $testSectionId,
    'Precondizione: le organization di test stanno nella sezione dedicata');
echo "Pubblicate organization viva id=$orgLiveId, da archiviare id=$orgGoneId\n";

eZContentObjectTreeNode::removeSubtrees([(int)$orgGone->attribute('main_node_id')], true);
$orgGone = eZContentObject::fetch($orgGoneId);
assert_true(!$orgGone->attribute('main_node') instanceof eZContentObjectTreeNode,
    "Precondizione: l'organization archiviata non ha piu' un nodo principale");
assert_true((int)$orgGone->attribute('status') === eZContentObject::STATUS_ARCHIVED,
    "Precondizione: l'organization archiviata ha status ARCHIVED");

// ── FASE 1: admin — getEntities() non deve piu' mostrare l'ente archiviato ───

echo "\n=== Fase 1: admin, ruolo con for_entity = ente vivo + ente archiviato ===\n";
$personIdAdmin = createPersonWithRole([$orgLiveId, $orgGoneId], $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, 'Admin-' . $uniqueSuffix, $createdObjectIds);
eZUser::setCurrentlyLoggedInUser($adminUser, $ownerId, eZUser::NO_SESSION_REGENERATE);
$entitiesAsAdmin = entityIds(OpenPARoles::instance(eZContentObject::fetch($personIdAdmin)->dataMap()['has_role'])->attribute('entities'));
assert_true(in_array($orgLiveId, $entitiesAsAdmin, true), 'getEntities(): admin vede ancora l\'organization viva');
assert_true(!in_array($orgGoneId, $entitiesAsAdmin, true), 'getEntities(): l\'organization archiviata NON compare');

// ── FASE 2: utente con policy content/read limitata per Node ────────────────

echo "\n=== Fase 2: utente con policy content/read a limitazione Node (caso redattore) ===\n";
$userObject = createObject('user', $userParentNodeId, $ownerId, $sectionId, [], $createdObjectIds);
$limitedUserId = (int)$userObject->attribute('id');
$login = 'test-node-limited-' . substr(md5($uniqueSuffix), 0, 8);
$userRow = eZUser::fetch($limitedUserId);
if (!$userRow instanceof eZUser) {
    // L'attributo user_account non e' stato valorizzato dal createObject generico: lo creiamo qui.
    $user = eZUser::create($limitedUserId);
    $user->setAttribute('login', $login);
    $user->setAttribute('email', $login . '@example.invalid');
    $user->setAttribute('password_hash', eZUser::createHash($login, 'Test-' . $uniqueSuffix . '!', eZUser::site(), eZUser::hashType()));
    $user->setAttribute('password_hash_type', eZUser::hashType());
    $user->store();
}
$limitedUser = eZUser::fetch($limitedUserId);
assert_true($limitedUser instanceof eZUser, 'Precondizione: utente di test con policy a limitazione Node creato');

$role = eZRole::create('test-node-limited-' . $uniqueSuffix);
$role->store();
$role->appendPolicy('content', 'read', ['Node' => [$orgLiveNodeId]]);
$role->assignToUser($limitedUserId);
$createdRoleIds[] = $role->attribute('id');
eZRole::expireCache();
eZUser::cleanupCache();

eZUser::setCurrentlyLoggedInUser(eZUser::fetch($limitedUserId), $limitedUserId, eZUser::NO_SESSION_REGENERATE);

// Se l'utente avesse una policy content/read senza limitazioni (ereditata dal gruppo),
// OpenPAWhoCan uscirebbe prima di valutare il ramo Node e il test non proverebbe nulla.
$readAccess = eZUser::currentUser()->hasAccessTo('content', 'read');
echo "hasAccessTo(content, read) per l'utente di test: " . $readAccess['accessWord'] . "\n";
assert_true($readAccess['accessWord'] === 'limited', "Precondizione: l'utente di test ha content/read 'limited' (il ramo Node viene valutato)");

$readable = null;
$error = null;
try {
    $readable = OpenPARoles::filterReadableObjects([eZContentObject::fetch($orgLiveId), eZContentObject::fetch($orgGoneId)]);
} catch (\Throwable $e) {
    $error = $e->getMessage();
}
assert_true($error === null, 'filterReadableObjects(): nessun fatal con un ente senza nodo principale' . ($error ? " (errore: $error)" : ''));
$readableIds = is_array($readable) ? entityIds($readable) : [];
assert_true(in_array($orgLiveId, $readableIds, true), 'filterReadableObjects(): l\'ente vivo nel Node della policy resta leggibile');
assert_true(!in_array($orgGoneId, $readableIds, true), 'filterReadableObjects(): l\'ente archiviato viene scartato');

// ── FASE 3: richiesta HTTP vera alla scheda della persona, da redattore ───────
// Replica il caso di produzione: redattore con una policy content/read per sezione (che gli
// fa leggere persona e ruolo) piu' una policy a limitazione Node; l'ente archiviato sta in
// un'altra sezione, quindi la prima policy lo nega e viene valutata quella Node.

echo "\n=== Fase 3: richiesta HTTP alla scheda della persona (redattore con policy Section + Node) ===\n";

function httpRequest(string $url, string $cookieJar, array $post = null, string $cookieHeader = ''): array
{
    $cmd = 'curl -s -o - -D ' . escapeshellarg($cookieJar . '.hdr') . ' -w "\n__HTTP_STATUS__%{http_code}" -c ' . escapeshellarg($cookieJar) . ' -b ' . escapeshellarg($cookieJar)
        . ' --max-time 60 ' . ($cookieHeader !== '' ? '-H ' . escapeshellarg('Cookie: ' . $cookieHeader) . ' ' : '')
        . ($post !== null ? '--data ' . escapeshellarg(http_build_query($post)) . ' ' : '') . escapeshellarg($url);
    $out = (string)shell_exec($cmd);
    $pos = strrpos($out, "\n__HTTP_STATUS__");
    return [
        $pos === false ? 0 : (int)substr($out, $pos + strlen("\n__HTTP_STATUS__")),
        $pos === false ? $out : substr($out, 0, $pos),
    ];
}

$baseUrl = 'http://localhost';
$probeJar = sys_get_temp_dir() . '/probe-' . $uniqueSuffix . '.jar';
list($probeStatus) = httpRequest($baseUrl . '/', $probeJar);
@unlink($probeJar);
@unlink($probeJar . '.hdr');
if ($probeStatus !== 200) {
    echo "\033[33m[SKIP]\033[0m Fase 3: $baseUrl non raggiungibile da questo processo (status $probeStatus)\n";
} else {
    $personIdHttp = createPersonWithRole([$orgLiveId, $orgGoneId], $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, 'Http-' . $uniqueSuffix, $createdObjectIds);

    $editorObject = createObject('user', $userParentNodeId, $ownerId, $sectionId, [], $createdObjectIds);
    $editorId = (int)$editorObject->attribute('id');
    $editorLogin = 'test-editor-' . substr(md5($uniqueSuffix), 0, 8);
    $editorPassword = 'Test-' . substr(md5($uniqueSuffix), 8, 12) . '!';
    if (!eZUser::fetch($editorId) instanceof eZUser) {
        $editor = eZUser::create($editorId);
        $editor->setAttribute('login', $editorLogin);
        $editor->setAttribute('email', $editorLogin . '@example.invalid');
        $editor->setAttribute('password_hash', eZUser::createHash($editorLogin, $editorPassword, eZUser::site(), eZUser::hashType()));
        $editor->setAttribute('password_hash_type', eZUser::hashType());
        $editor->store();
    }
    // ezmbpaex: una password mai aggiornata risulta scaduta e il login rimanda al cambio password.
    $editorPaex = eZPaEx::getPaEx($editorId, true);
    if ($editorPaex instanceof eZPaEx) { $editorPaex->resetPasswordLastUpdated(); }
    if (!eZUserSetting::fetch($editorId) instanceof eZUserSetting) {
        // Senza la riga ezuser_setting (is_enabled) il login web rifiuta l'utente.
        eZUserSetting::create($editorId, 1)->store();
    }

    $editorRole = eZRole::create('test-editor-section-node-' . $uniqueSuffix);
    $editorRole->store();
    $editorRole->appendPolicy('user', 'login');
    $editorRole->appendPolicy('content', 'read', ['Section' => [$sectionId]]);
    $editorRole->appendPolicy('content', 'read', ['Node' => [$orgLiveNodeId]]);
    $editorRole->assignToUser($editorId);
    $createdRoleIds[] = $editorRole->attribute('id');
    eZRole::expireCache();
    eZUser::cleanupCache();

    $personNode = eZContentObject::fetch($personIdHttp)->attribute('main_node');
    $personUrl = $baseUrl . '/' . ltrim($personNode->attribute('url_alias'), '/');
    $jar = sys_get_temp_dir() . '/editor-' . $uniqueSuffix . '.jar';

    // Il login e' protetto da un token di form (ezuserformtoken): va prima letto dalla pagina di login.
    list(, $loginForm) = httpRequest($baseUrl . '/user/login', $jar);
    $formToken = preg_match('/name="ezxuserform_token"[^>]*value="([^"]+)"/', $loginForm, $m) || preg_match('/value="([^"]+)"[^>]*name="ezxuserform_token"/', $loginForm, $m) ? $m[1] : '';
    echo "Token di form del login: " . ($formToken !== '' ? 'trovato' : 'NON trovato') . "\n";
    list($loginStatus, $loginBody) = httpRequest($baseUrl . '/user/login', $jar, ['Login' => $editorLogin, 'Password' => $editorPassword, 'LoginButton' => 'Login', 'ezxuserform_token' => $formToken]);
    $jarContent = is_file($jar) ? (string)file_get_contents($jar) : '';
    $loginHeaders = is_file($jar . '.hdr') ? (string)file_get_contents($jar . '.hdr') : '';
    echo "Login HTTP status: $loginStatus, cookie di sessione: " . (strpos($jarContent, 'eZSESSID') !== false || stripos($jarContent, 'SESS') !== false ? 'si' : 'no') . "\n";

    $cookies = [];
    foreach (explode("\n", $loginHeaders) as $headerLine) {
        if (preg_match('/^Set-Cookie:\s*([^=;]+)=([^;\r\n]*)(.*)$/i', trim($headerLine), $cm)
            && stripos($cm[3], 'Max-Age=0') === false && stripos($cm[3], '1970') === false) {
            $cookies[$cm[1]] = $cm[2];
        }
    }
    $cookieHeader = implode('; ', array_map(function ($k, $v) { return $k . '=' . $v; }, array_keys($cookies), $cookies));
    echo "Cookie ricevuti dal login: " . implode(', ', array_keys($cookies)) . "\n";
    list($pageStatus, $pageBody) = httpRequest($personUrl, $jar, null, $cookieHeader);
    assert_true(stripos($pageBody, '/user/logout') !== false,
        'Precondizione: la richiesta alla scheda e\' autenticata come redattore (non anonima)');
    echo "GET $personUrl -> HTTP $pageStatus, " . strlen($pageBody) . " byte\n";
    assert_true($pageStatus === 200, 'Scheda persona da redattore: HTTP 200 (non 500)');
    assert_true(stripos($pageBody, 'An unexpected error has occurred') === false, 'Scheda persona da redattore: nessun "An unexpected error has occurred"');
    assert_true(strpos($pageBody, 'Test Org Archiviata') === false, 'Scheda persona da redattore: l\'ente archiviato NON compare nell\'HTML');
    echo "(info) nome dell'ente vivo presente nell'HTML: " . (strpos($pageBody, 'Test Org Viva') !== false ? 'si' : 'no') . "\n";

    // Come appare la scheda quando il PRIMO (e unico) ente del ruolo e' archiviato?
    // Il template usa relation_list[0]: con l'ente filtrato ripiega su hash('name', '?').
    $roleTitles = function (string $body): array {
        preg_match_all('#<h3 class="h5 mt-4 font-sans-serif">(.*?)</h3>#s', $body, $titles);
        return array_map(function ($t) { return trim(preg_replace('/\s+/', ' ', strip_tags($t))); }, $titles[1]);
    };
    foreach ([['con label', true], ['senza label', false]] as list($caseLabel, $withLabel)) {
        $pid = createPersonWithRole([$orgGoneId], $personParentNodeId, $roleParentNodeId, $ownerId, $sectionId, 'Solo-' . ($withLabel ? 'L' : 'N') . '-' . $uniqueSuffix, $createdObjectIds, $withLabel);
        $url = $baseUrl . '/' . ltrim(eZContentObject::fetch($pid)->attribute('main_node')->attribute('url_alias'), '/');
        list($st, $body) = httpRequest($url, $jar, null, $cookieHeader);
        assert_true($st === 200 && stripos($body, 'An unexpected error has occurred') === false, "Ruolo solo sull'ente archiviato ($caseLabel): HTTP 200 senza errore (status $st)");
        assert_true(strpos($body, 'Test Org Archiviata') === false, "Ruolo solo sull'ente archiviato ($caseLabel): il nome dell'ente archiviato non compare");
        echo "(info) titoli ruolo in pagina ($caseLabel): " . json_encode($roleTitles($body), JSON_UNESCAPED_UNICODE) . "\n";
    }

    @unlink($jar);
    @unlink($jar . '.hdr');
}

// Ripristina admin per il cleanup
eZUser::setCurrentlyLoggedInUser($adminUser, $ownerId, eZUser::NO_SESSION_REGENERATE);

echo "\n";
echo "Risultato: $PASSED passati / " . ($PASSED + $FAILED) . " totali\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
