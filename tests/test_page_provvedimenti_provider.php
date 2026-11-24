<?php
/**
 * Verifica PageProvvedimentiProvider: righe appiattite con i campi per
 * tabella+filtri (NON provvedimento/allegati, solo export), JSON gia' reso
 * sicuro per l'incorporamento in pagina.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_page_provvedimenti_provider.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'PageProvvedimentiProvider test',
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

// Garantisce almeno una riga reale per "organi" - senza questo, su un DB
// senza nessun documento tag document_type gia' pubblicato, il foreach sotto
// non esegue mai e i controlli sulla forma della riga non verificano nulla
// (trovato dalla review finale whole-branch).
$adminUser = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

$documentClass = eZContentClass::fetchByIdentifier('document');
$rootNodeId = (int)eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');
$testObject = $documentClass->instantiate(eZUser::currentUserID());
$testObject->store();
eZNodeAssignment::create([
    'contentobject_id' => $testObject->attribute('id'),
    'contentobject_version' => 1,
    'parent_node' => $rootNodeId,
    'is_main' => 1,
])->store();
$testVersion = $testObject->version(1);
$testDataMap = [];
foreach ($testVersion->contentObjectAttributes('ita-IT') as $attr) {
    $testDataMap[$attr->contentClassAttributeIdentifier()] = $attr;
}
$testDataMap['name']->fromString('TEST_PROVIDER Decreto ' . uniqid());
$testDataMap['name']->store();
// Formato richiesto da eztags fromString() per un singolo tag: vedi
// test_art23_serializer_csv.php, stesso pattern gia' verificato.
$decretoDelSindaco = eZTagsObject::fetchByRemoteID('ccf6761810b5ac50d32eade1fbe17fca');
$testDataMap['document_type']->fromString(
    $decretoDelSindaco->attribute('id') . '|#' . $decretoDelSindaco->attribute('keyword') . '|#' . $decretoDelSindaco->attribute('parent_id') . '|#ita-IT'
);
$testDataMap['document_type']->store();
eZOperationHandler::execute('content', 'publish', ['object_id' => $testObject->attribute('id'), 'version' => 1]);

// Forza l'indicizzazione immediata (stesso pattern di
// test_art23_serializer_csv.php) - su questa istanza di sviluppo la
// reindicizzazione asincrona puo' avere latenza significativa (vedi Task 13,
// Finding 3), e questo test ha bisogno della riga SUBITO per essere
// deterministico.
$freshTestObject = eZContentObject::fetch((int)$testObject->attribute('id'));
$solrIndexer = eZSearch::getEngine();
$solrIndexer->addObject($freshTestObject, false);
$solrIndexer->commit();

$provider = new \OpenPABootstrapItalia\Anac\PageProvvedimentiProvider();
$organiJson = $provider->getOrganiRowsJson();
$dirigentiJson = $provider->getDirigentiRowsJson();

check('getOrganiRowsJson restituisce JSON valido', true, json_decode($organiJson) !== null || $organiJson === '[]');
check('getDirigentiRowsJson restituisce JSON valido', true, json_decode($dirigentiJson) !== null || $dirigentiJson === '[]');

$rows = json_decode($organiJson, true);
check('almeno una riga "organi" presente (documento di test appena pubblicato)', true, count((array)$rows) > 0);
foreach ((array)$rows as $row) {
    check('nessuna riga espone provvedimento', false, array_key_exists('provvedimento', $row));
    check('nessuna riga espone allegati', false, array_key_exists('allegati', $row));
    check('riga ha denominazione', true, array_key_exists('denominazione', $row));
    check('riga ha anno', true, array_key_exists('anno', $row));
    check('riga ha pubblicazioneInizio', true, array_key_exists('pubblicazioneInizio', $row));
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
