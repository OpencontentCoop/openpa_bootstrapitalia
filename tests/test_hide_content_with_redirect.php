<?php
/**
 * Verifica BootstrapItaliaInstallerUtils::hideContentWithRedirect(): il
 * nodo sorgente passa a stato privacy.private, e il suo path PUBBLICO
 * ORIGINALE (quello su cui un link esterno già indicizzato potrebbe
 * puntare) rimanda con un redirect nativo eZ (301) al nodo di destinazione.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_hide_content_with_redirect.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'hideContentWithRedirect test',
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

// Necessario per poter creare contenuti e assegnare lo stato privacy.private:
// eZContentOperationCollection::updateObjectState() filtra silenziosamente
// gli stati che l'utente corrente non puo' assegnare
// (allowed_assign_state_id_list) - senza login admin l'assegnazione di
// stato fallisce senza errori. Stesso pattern gia' verificato in
// tests/test_art13_fetch_organi_amministrativi_vertice.php e altri test di
// questa cartella.
$adminUser = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

OpenPABase::initStateGroup('privacy', ['public', 'private']);

$rootNodeId = (int)eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');

// Nota: lo schema del brief usava $object->publish(['current' => true]) -
// metodo inesistente su eZContentObject ("Call to undefined method"
// verificato in RED). Sostituito con eZOperationHandler::execute('content',
// 'publish', ...), lo stesso pattern gia' verificato funzionante in
// tests/test_art13_fetch_organi_amministrativi_vertice.php
// (createOrganization()); anche l'assegnazione dell'attributo 'name' e'
// allineata a quel pattern (contentObjectAttributes() sulla versione,
// invece di fetchDataMap() che prima della pubblicazione non e' affidabile).
function createFolderWithRemoteId($parentNodeId, $name, $remoteId)
{
    $class = eZContentClass::fetchByIdentifier('folder');
    $object = $class->instantiate(eZUser::currentUserID());
    $object->setAttribute('remote_id', $remoteId);
    $object->store();

    eZNodeAssignment::create([
        'contentobject_id' => $object->attribute('id'),
        'contentobject_version' => 1,
        'parent_node' => $parentNodeId,
        'is_main' => 1,
    ])->store();

    $version = $object->version(1);
    foreach ($version->contentObjectAttributes('ita-IT') as $attr) {
        if ($attr->contentClassAttributeIdentifier() === 'name') {
            $attr->fromString($name);
            $attr->store();
        }
    }

    eZOperationHandler::execute('content', 'publish', ['object_id' => $object->attribute('id'), 'version' => 1]);

    return eZContentObject::fetch((int)$object->attribute('id'));
}

$sourceRemoteId = 'test_hide_redirect_source_' . uniqid();
$targetRemoteId = 'test_hide_redirect_target_' . uniqid();

$targetObject = createFolderWithRemoteId($rootNodeId, 'Target ' . uniqid(), $targetRemoteId);
$sourceObject = createFolderWithRemoteId($rootNodeId, 'Source ' . uniqid(), $sourceRemoteId);

$sourceNode = $sourceObject->attribute('main_node');
$originalPath = trim($sourceNode->attribute('url_alias'), '/');
check('il nodo sorgente ha un path pubblico prima del test', true, $originalPath !== '');

$stepConfig = [
    'identifier' => 'BootstrapItaliaInstallerUtils::hideContentWithRedirect',
    'remote_id' => $sourceRemoteId,
    'redirect_to_remote_id' => $targetRemoteId,
];
// Nota: Opencontent\Installer\AbstractStepInstaller e' astratta e non ha
// costruttore proprio (step/logger si impostano via setter, non via
// costruttore) - verificato in vendor/opencontent/ocinstaller/src/Opencontent/Installer/AbstractStepInstaller.php.
// Si usa qui Opencontent\Installer\PhpCallable, la sottoclasse concreta che
// l'installer usa realmente per gli step di tipo php_callable (stesso tipo
// con cui hideContentWithRedirect verra' invocato in produzione).
// Non esiste una classe Opencontent\Installer\Logger\NullLogger: si usa il
// NullLogger PSR-3 standard (psr/log), che implementa Psr\Log\LoggerInterface
// come richiesto da AbstractStepInstaller::setLogger().
$step = new \Opencontent\Installer\PhpCallable();
$step->setStep($stepConfig);
$step->setLogger(new \Psr\Log\NullLogger());

BootstrapItaliaInstallerUtils::hideContentWithRedirect($step);

// Nota: eZContentObject::fetch() tiene una cache statica in-process per id
// (array globale $eZContentObjectContentObjectCache) - senza invalidarla,
// questo fetch tornerebbe la stessa istanza PHP ottenuta in
// createFolderWithRemoteId(), con lo state_id_array precedente alla
// chiamata di hideContentWithRedirect(). Verificato in RED (il check sotto
// falliva anche a mutazione DB avvenuta correttamente).
eZContentObject::clearCache([(int)$sourceObject->attribute('id')]);
$sourceObjectAfter = eZContentObject::fetch($sourceObject->attribute('id'));
$privacyStates = OpenPABase::initStateGroup('privacy', ['public', 'private']);
$privateStateId = (int)$privacyStates['privacy.private']->attribute('id');
// Nota: state_id_array e' keyed by group_id (non da state id), coi valori
// assegnati come STRINGHE (driver DB) - in_array(..., true) sulla stringa
// grezza non avrebbe mai potuto essere true contro un (int). Normalizzato
// con array_map('intval', ...) prima del confronto stretto.
$sourceStateIdArray = array_map('intval', (array)$sourceObjectAfter->attribute('state_id_array'));
check('stato privacy.private assegnato', true, in_array($privateStateId, $sourceStateIdArray, true));

// Nota: eZURLAliasML::fetchByPath() ritorna un array di oggetti
// eZURLAliasML (via eZPersistentObject::handleRows(..., true)), non un
// array di hash associativi come ipotizzato nel brief - verificato in RED
// ("Cannot use object of type eZURLAliasML as array"). Accesso quindi via
// ->attribute(), non con la sintassi a indice.
$resolved = eZURLAliasML::fetchByPath($originalPath);
check('il path originale risolve a un alias', true, $resolved !== null && !empty($resolved));
if ($resolved !== null && !empty($resolved)) {
    $last = end($resolved);
    check('action e\' eznode verso il nodo target', 'eznode:' . $targetObject->attribute('main_node_id'), $last->attribute('action'));
}

// Nota: eZURLAliasML::fetchByPath() non seleziona affatto la colonna
// is_alias nella sua query (verificato leggendo generateSelect()/
// generateFullSelect() in kernel/classes/ezurlaliasml.php - SELECT limitato
// a id/parent/lang_mask/text/text_md5/action/link) - $last->attribute('is_alias')
// e' quindi SEMPRE falsy a prescindere dal valore reale in DB, non e' un
// modo valido per verificarlo. Letto quindi direttamente dalla tabella.
$db = eZDB::instance();
$aliasRow = $db->arrayQuery(
    "SELECT is_alias, alias_redirects FROM ezurlalias_ml WHERE parent = 0 AND text = '" . $db->escapeString($originalPath) . "' AND action = 'eznode:" . (int)$targetObject->attribute('main_node_id') . "'"
);
check('riga trovata per verificare is_alias', true, count($aliasRow) === 1);
if (count($aliasRow) === 1) {
    check('e\' marcato come redirect (is_alias)', 1, (int)$aliasRow[0]['is_alias']);
    check('alias_redirects abilitato (301)', 1, (int)$aliasRow[0]['alias_redirects']);
}

// Caso "gia' privato ma redirect mai creato" (trovato in review: un
// oggetto puo' essere gia' privacy.private per un motivo scollegato da
// questo step - stato ereditato, modifica manuale, ecc. - PRIMA che questo
// step giri mai. Il vecchio guard controllava solo lo stato privacy e
// avrebbe considerato questo caso "gia' fatto", saltando la creazione del
// redirect e lasciando la pagina nascosta ma mai redirezionata - un link
// esterno gia' indicizzato sarebbe rimasto rotto in silenzio).
$preHiddenRemoteId = 'test_hide_redirect_prehidden_' . uniqid();
$preHiddenObject = createFolderWithRemoteId($rootNodeId, 'PreHidden ' . uniqid(), $preHiddenRemoteId);
$preHiddenNode = $preHiddenObject->attribute('main_node');
$preHiddenOriginalPath = trim($preHiddenNode->attribute('url_alias'), '/');
check('oggetto pre-nascosto ha un path pubblico prima del test', true, $preHiddenOriginalPath !== '');

// Stato privato assegnato DIRETTAMENTE (non tramite hideContentWithRedirect),
// a simulare un oggetto gia' nascosto per altri motivi, senza alcun redirect.
eZContentOperationCollection::updateObjectState((int)$preHiddenObject->attribute('id'), [$privateStateId]);
eZContentObject::clearCache([(int)$preHiddenObject->attribute('id')]);
$preHiddenObjectCheck = eZContentObject::fetch((int)$preHiddenObject->attribute('id'));
check(
    'oggetto pre-nascosto e\' privato prima di chiamare hideContentWithRedirect',
    true,
    in_array($privateStateId, array_map('intval', (array)$preHiddenObjectCheck->attribute('state_id_array')), true)
);
$preHiddenAliasRowBefore = $db->arrayQuery(
    "SELECT is_alias FROM ezurlalias_ml WHERE parent = 0 AND text = '" . $db->escapeString($preHiddenOriginalPath) . "' AND action = 'eznode:" . (int)$targetObject->attribute('main_node_id') . "'"
);
check('nessun redirect esiste ancora per l\'oggetto pre-nascosto', 0, count($preHiddenAliasRowBefore));

$preHiddenStep = new \Opencontent\Installer\PhpCallable();
$preHiddenStep->setStep([
    'identifier' => 'BootstrapItaliaInstallerUtils::hideContentWithRedirect',
    'remote_id' => $preHiddenRemoteId,
    'redirect_to_remote_id' => $targetRemoteId,
]);
$preHiddenStep->setLogger(new \Psr\Log\NullLogger());
BootstrapItaliaInstallerUtils::hideContentWithRedirect($preHiddenStep);

$preHiddenAliasRowAfter = $db->arrayQuery(
    "SELECT is_alias, action FROM ezurlalias_ml WHERE parent = 0 AND text = '" . $db->escapeString($preHiddenOriginalPath) . "'"
);
check('il redirect viene creato anche se l\'oggetto era gia\' privato per altri motivi', true, count($preHiddenAliasRowAfter) === 1);
if (count($preHiddenAliasRowAfter) === 1) {
    check('action corretta per l\'oggetto pre-nascosto', 'eznode:' . $targetObject->attribute('main_node_id'), $preHiddenAliasRowAfter[0]['action']);
    check('is_alias=1 per l\'oggetto pre-nascosto', 1, (int)$preHiddenAliasRowAfter[0]['is_alias']);
}

// idempotenza: rieseguire lo stesso step non deve lanciare eccezioni ne'
// generare righe aggiuntive in ezurlalias_ml (l'oggetto e' gia' privato,
// deve essere un no-op completo - verificato in RED: senza il guard di
// idempotenza in hideContentWithRedirect(), la seconda esecuzione non
// lanciava eccezioni ma rigenerava comunque l'alias, partendo stavolta dal
// path di fallback del nodo invece che da quello originale, producendo una
// riga spuria).
$targetActionCountBefore = (int)$db->arrayQuery(
    "SELECT COUNT(*) AS c FROM ezurlalias_ml WHERE action = 'eznode:" . (int)$targetObject->attribute('main_node_id') . "'"
)[0]['c'];
try {
    BootstrapItaliaInstallerUtils::hideContentWithRedirect($step);
    check('seconda esecuzione non lancia eccezioni', true, true);
} catch (Exception $e) {
    check('seconda esecuzione non lancia eccezioni', true, false);
}
$targetActionCountAfter = (int)$db->arrayQuery(
    "SELECT COUNT(*) AS c FROM ezurlalias_ml WHERE action = 'eznode:" . (int)$targetObject->attribute('main_node_id') . "'"
)[0]['c'];
check('seconda esecuzione e\' un vero no-op (nessuna riga alias aggiuntiva)', $targetActionCountBefore, $targetActionCountAfter);

// Regressione trovata in review sul fix precedente: una riesecuzione a
// vuoto (sorgente gia' privata E gia' senza alias naturale, cioe' il vero
// stato di no-op) NON deve dipendere dalla risoluzione di
// redirect_to_remote_id - il guard di idempotenza deve bastare da solo.
// Il fix precedente, per poter citare $targetNodeId nel messaggio di log
// del no-op, risolveva il target PRIMA del guard: su una riesecuzione
// genuina in cui il target nel frattempo non risulta piu' (rimosso,
// remote_id cambiato, ecc.) questo trasformava un no-op sicuro in
// un'eccezione non gestita. $sourceObject/$step a questo punto del test
// sono gia' nello stato di vero no-op (migrazione completata sopra), quindi
// basta ripassare un redirect_to_remote_id che non esiste per riprodurre
// esattamente lo scenario.
try {
    $reRunWithGoneTargetStep = new \Opencontent\Installer\PhpCallable();
    $reRunWithGoneTargetStep->setStep([
        'identifier' => 'BootstrapItaliaInstallerUtils::hideContentWithRedirect',
        'remote_id' => $sourceRemoteId,
        'redirect_to_remote_id' => 'questo_target_remote_id_non_esiste_piu',
    ]);
    $reRunWithGoneTargetStep->setLogger(new \Psr\Log\NullLogger());
    BootstrapItaliaInstallerUtils::hideContentWithRedirect($reRunWithGoneTargetStep);
    check('no-op su sorgente gia\' migrata anche se il target non risolve piu\'', true, true);
} catch (Exception $e) {
    check('no-op su sorgente gia\' migrata anche se il target non risolve piu\'', true, false);
}

// remote_id inesistente: deve lanciare, non fallire silenziosamente
try {
    $badStep = new \Opencontent\Installer\PhpCallable();
    $badStep->setStep([
        'identifier' => 'BootstrapItaliaInstallerUtils::hideContentWithRedirect',
        'remote_id' => 'questo_remote_id_non_esiste_mai',
        'redirect_to_remote_id' => $targetRemoteId,
    ]);
    $badStep->setLogger(new \Psr\Log\NullLogger());
    BootstrapItaliaInstallerUtils::hideContentWithRedirect($badStep);
    check('remote_id mancante lancia eccezione', true, false);
} catch (Exception $e) {
    check('remote_id mancante lancia eccezione', true, true);
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
