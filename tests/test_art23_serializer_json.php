<?php
/**
 * Verifica Art23Serializer::toJson(): struttura conforme allo schema ANAC
 * reale (validato con JsonSchemaValidator, non solo "json_decode non
 * fallisce"), provvedimento/allegati presenti solo per documenti pubblici,
 * chiave omessa (non array vuoto) quando un gruppo non ha righe.
 *
 * Le prime righe usano l'hook di test '__override' (vedi
 * buildJsonProvvedimenti()), che bypassa isPublic()/buildRigaConAllegati()
 * del tutto - utile per verificare la FORMA del JSON ma NON la logica di
 * pubblico/privato. La sezione finale ("isPublic() attraverso un vero
 * eZContentObject") esercita invece il percorso reale, l'unico usato in
 * produzione dal cron (Task 9): un documento pubblicato di classe
 * `document` e' pubblico per default - con un file allegato reale verifica
 * che provvedimento/allegati vengano popolati; marcato poi privacy.private
 * (stesso meccanismo di modules/bootstrapitalia/privacy.php, vedi
 * test_openparole_entity_access_filter.php) verifica che spariscano, pur
 * restando la riga con gli altri campi.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_json.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/vendor/autoload.php';
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'Art23Serializer JSON test',
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

// Necessario per poter creare/pubblicare contenuti e assegnare lo stato
// privacy.private con eZOperationHandler - stesso pattern gia' verificato in
// test_art23_serializer_csv.php/test_openparole_entity_access_filter.php.
$adminUser = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

$amministrazione = ['codiceFiscale' => '12345678901', 'denominazione' => 'Comune di Prova'];
$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art23Serializer($amministrazione);

$organiRows = [[
    'object' => null,
    'denominazione' => 'Decreto',
    'group' => 'organi',
    '__override' => ['data' => '12/03/2026', 'numero' => '45', 'oggetto' => 'Nomina', 'strutturaResponsabile' => 'Ufficio Segreteria'],
]];

// Il JSON con un solo gruppo valorizzato deve essere comunque conforme
// (l'altro array va omesso, non svuotato).
$jsonSoloOrgani = $serializer->toJson('01/01/2026', '01/01/2026', $organiRows, []);
$decoded = json_decode($jsonSoloOrgani, true);
check('chiave provvedimentiDirigDiAltraTipologia assente quando il gruppo e\' vuoto', false, array_key_exists('provvedimentiDirigDiAltraTipologia', $decoded));
check('chiave provvedimentiOrganiPolitici presente', true, array_key_exists('provvedimentiOrganiPolitici', $decoded));

try {
    \OpenPABootstrapItalia\Anac\JsonSchemaValidator::validate('art.23-v1.0.schema.json', $jsonSoloOrgani);
    check('JSON prodotto e\' conforme allo schema reale', true, true);
} catch (\OpenPABootstrapItalia\Anac\InvalidAnacSchemaException $e) {
    check('JSON prodotto e\' conforme allo schema reale', true, false);
    echo '  dettaglio: ' . $e->getMessage() . "\n";
}

// Entrambi i gruppi vuoti: toJson() non deve essere chiamato dal cron in
// questo caso (vedi Task 9) - ma se lo fosse, il JSON prodotto conterrebbe
// solo $schema+intestazione, comunque conforme (nessun campo richiesto oltre
// quei due a livello radice).
$jsonVuoto = $serializer->toJson('01/01/2026', '01/01/2026', [], []);
try {
    \OpenPABootstrapItalia\Anac\JsonSchemaValidator::validate('art.23-v1.0.schema.json', $jsonVuoto);
    check('JSON con entrambi i gruppi vuoti resta conforme', true, true);
} catch (\OpenPABootstrapItalia\Anac\InvalidAnacSchemaException $e) {
    check('JSON con entrambi i gruppi vuoti resta conforme', true, false);
}

// ── isPublic()/buildRigaConAllegati() attraverso un vero eZContentObject ──

$documentClass = eZContentClass::fetchByIdentifier('document');
$rootNodeId = (int)eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');
$realObject = $documentClass->instantiate(eZUser::currentUserID());
$realObject->store();
eZNodeAssignment::create([
    'contentobject_id' => $realObject->attribute('id'),
    'contentobject_version' => 1,
    'parent_node' => $rootNodeId,
    'is_main' => 1,
])->store();

$realVersion = $realObject->version(1);
$realDataMap = [];
foreach ($realVersion->contentObjectAttributes('ita-IT') as $attr) {
    $realDataMap[$attr->contentClassAttributeIdentifier()] = $attr;
}
$realDataMap['name']->fromString('Decreto reale di prova ' . uniqid());
$realDataMap['name']->store();
// 'numero'/'data' sono richiesti dallo schema ANAC (vedi art.23-v1.0.schema.json,
// ProvvedimentoGen.required) - senza questi due la validazione fallirebbe per
// un motivo estraneo a isPublic()/allegati, che e' quello che questa sezione
// vuole verificare. Stesso campo (act_number) e stesso fallback
// (publication_start_time) gia' usati in test_art23_serializer_csv.php.
$realDataMap['act_number']->fromString('99');
$realDataMap['act_number']->store();
$realDataMap['publication_start_time']->fromString((string)strtotime('2026-03-12'));
$realDataMap['publication_start_time']->store();

// 'file' (ezbinaryfile) E 'attachments' (ocmultibinary) entrambi popolati,
// stesso pattern di test_document_file_resolver_all_urls.php - serve ad
// avere sia 'provvedimento' (primo url) sia 'allegati' (resto) valorizzati
// quando pubblico, non solo uno dei due.
$tmpFile = sys_get_temp_dir() . '/test_art23_json_file_' . uniqid() . '.txt';
file_put_contents($tmpFile, 'contenuto provvedimento');
$realDataMap['file']->fromString($tmpFile);
$realDataMap['file']->store();

$tmpAttachment = sys_get_temp_dir() . '/test_art23_json_attachment_' . uniqid() . '.txt';
file_put_contents($tmpAttachment, 'contenuto allegato');
$realDataMap['attachments']->fromString($tmpAttachment);
$realDataMap['attachments']->store();

eZOperationHandler::execute('content', 'publish', ['object_id' => $realObject->attribute('id'), 'version' => 1]);
@unlink($tmpFile);
@unlink($tmpAttachment);
$realObjectPubblico = eZContentObject::fetch((int)$realObject->attribute('id'));

$realRowPubblico = ['object' => $realObjectPubblico, 'denominazione' => 'Decreto', 'group' => 'organi'];

// buildRigaConAllegati() e' privato - chiamato via Reflection per esercitare
// isPublic()/resolveAllUrls() direttamente, SENZA passare da toJson()
// (che valida subito lo $schema "format: uri" - in questo ambiente di
// sviluppo, invocazione PHP CLI diretta senza passare da runcronjobs.php,
// SiteSettings.SiteURL risolve vuoto e DocumentFileResolver produce url
// malformati tipo "https:///content/download/...", verificato - un limite
// di QUESTO ambiente di test, non legato a isPublic()/buildRigaConAllegati(),
// che toJson() farebbe comunque fallire per un motivo estraneo a quello che
// questa sezione vuole isolare: se 'provvedimento'/'allegati' vengono
// POPOLATI quando l'oggetto e' pubblico).
$buildRigaConAllegatiMethod = new ReflectionMethod($serializer, 'buildRigaConAllegati');
$buildRigaConAllegatiMethod->setAccessible(true);
$rigaPubblico = $buildRigaConAllegatiMethod->invoke($serializer, $realRowPubblico);

check('documento reale pubblico (stato di default): provvedimento popolato', true, $rigaPubblico['provvedimento'] !== null && $rigaPubblico['provvedimento'] !== '');
check('documento reale pubblico (stato di default): allegati popolato', true, count($rigaPubblico['allegati']) === 1);

// Marca lo stesso documento privato (stesso meccanismo esatto usato da
// "Imposta come privato" in produzione, modules/bootstrapitalia/privacy.php)
// - provvedimento/allegati devono sparire, la riga deve restare con gli
// altri campi.
$privacyStates = OpenPABase::initStateGroup('privacy', ['public', 'private']);
$privateStateId = (int)$privacyStates['privacy.private']->attribute('id');
eZOperationHandler::execute('content', 'updateobjectstate', [
    'object_id' => $realObjectPubblico->attribute('id'),
    'state_id_list' => [$privateStateId],
]);
// eZContentObject::fetch() tiene una cache statica in-process per id - senza
// invalidarla, questo fetch tornerebbe la stessa istanza PHP di
// $realObjectPubblico, con lo state_id_array precedente all'updateobjectstate
// (stesso gotcha gia' documentato in test_hide_content_with_redirect.php).
eZContentObject::clearCache([(int)$realObjectPubblico->attribute('id')]);
$realObjectPrivato = eZContentObject::fetch((int)$realObjectPubblico->attribute('id'));

$realRowPrivato = ['object' => $realObjectPrivato, 'denominazione' => 'Decreto', 'group' => 'organi'];
$jsonOggettoPrivato = $serializer->toJson('01/01/2026', '01/01/2026', [$realRowPrivato], []);
$decodedPrivato = json_decode($jsonOggettoPrivato, true);
$itemPrivato = $decodedPrivato['provvedimentiOrganiPolitici'][0];

check('documento reale privato: provvedimento assente', false, isset($itemPrivato['provvedimento']));
check('documento reale privato: allegati assente', false, isset($itemPrivato['allegati']));
check('documento reale privato: la riga resta con gli altri campi (denominazione)', 'Decreto', $itemPrivato['denominazione']);

try {
    \OpenPABootstrapItalia\Anac\JsonSchemaValidator::validate('art.23-v1.0.schema.json', $jsonOggettoPrivato);
    check('JSON con documento reale privato e\' conforme allo schema reale', true, true);
} catch (\OpenPABootstrapItalia\Anac\InvalidAnacSchemaException $e) {
    check('JSON con documento reale privato e\' conforme allo schema reale', true, false);
    echo '  dettaglio: ' . $e->getMessage() . "\n";
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
