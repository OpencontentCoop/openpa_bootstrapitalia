# Trasparenza art. 23 C1 (Provvedimenti) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unificare le due pagine "Provvedimenti organi indirizzo politico"/"Provvedimenti dirigenti" in un'unica pagina "Provvedimenti" con due tabelle live-rendering filtrabili, e pubblicare export CSV/JSON conformi allo schema ANAC reale per l'art. 23 d.lgs. 33/2013, con validazione automatica del JSON contro lo schema scaricato.

**Architecture:** Due repo. `installer` (branch `trasparenza-additional-scheme-23`, da `main`): patch content sulla pagina "Provvedimenti" esistente, nasconde con redirect le due sotto-pagine. `openpa_bootstrapitalia` (branch `trasparenza-additional-scheme-23`, da `master`): nuovo `Art23Serializer` (query Solr su `document`/`document_type`, nessun dataset nuovo), nuovo provider live-rendering, nuova funzione cron, validazione JSON Schema riusabile, filtri frontend.

**Tech Stack:** eZ Publish Legacy (PHP 7.4), Solr/eZFind, DataTables 1.10.25 (client-side), `justinrainbow/json-schema` (draft-07, già transitivo nel lock del progetto).

**Spec:** `docs/superpowers/specs/2026-11-23-trasparenza-art23-c1-design.md`

## Global Constraints

- Solo profilo C1. Niente tedesco in questo lavoro (nessuna patch `ger-DE` per i nuovi contenuti; quello esistente sulle due sotto-pagine resta invariato, verrà comunque nascosto insieme al resto della pagina).
- Nessuna modifica alla tassonomia `document_type`: tutti i tag necessari esistono già (verificato: `Atto amministrativo` remote_id `e9b9ff2bd36752f66d70f70833583e4d`, con i 4 gruppi `Decreto`/`Deliberazione`/`Determinazione`/`Ordinanza` e le 13 foglie elencate nel Task 5).
- **Nessun bump di versione in nessun `installer.yml`** (regola assoluta del profilo utente, vale specificamente per i moduli `trasparenza*` del repo `installer`): le modifiche al content model vanno come step `patch_content`/`php_callable` aggiunti direttamente alla lista `steps:` esistente, senza gate di versione — stesso pattern già in uso per `$articolazione_uffici`/`$telefono_e_posta_elettronica` in `modules/trasparenza-c1/installer.yml` (step ripetibili, idempotenti, nessun `current_version_le`).
- **Coordinamento con il branch `trasparenza-additional-scheme-26-27`** (non ancora mergeato in nessuno dei due repo, ids schema 22-25 già presi in entrambi i repo da quel branch): questo lavoro usa gli id **26 (`art.23-org`), 27 (`art.23-altra-tipologia`), 28 (`art.23`)** per evitare collisioni. Chiunque merga per secondo tra i due branch deve riverificare che `SchemaPubblicazioneLookup::OPTION_IDS` e l'XML `data_text5` di `pagina_trasparenza.yml` non abbiano duplicati dopo il merge.
- Schema JSON reale verificato scaricando `art.23-v1.0.schema.json` + `commons-v1.0.schema.json` (draft-07) da `guida-servizi.anticorruzione.it` in questa sessione — tutti i nomi di campo/requiredness/pattern nei task sotto sono presi da lì, non dalla sola issue.
- Nessun nuovo meccanismo di attivazione: l'unico switch è `schema_pubblicazione` sulla pagina "Provvedimenti" (già esistente, stesso meccanismo di tutti gli altri schemi ANAC).
- `provvedimento`/`allegati` non vanno mai mostrati in tabella (live-rendering), solo nell'export.
- Nessun secret va scritto nei file di questo piano: i comandi che usano il token POEditor fanno riferimento alla variabile che lo contiene (vedi CLAUDE.md root, sezione i18n), mai al valore letterale.

## Review Focus

- Un Decreto o un'Ordinanza (non solo Deliberazione/Determinazione) deve comparire nella tabella giusta — è il gap reale che oggi esiste in produzione (le due pagine attuali filtrano solo `Deliberazione`/`Determinazione`, e "Provvedimenti dirigenti" include erroneamente "Determinazione del Sindaco", un tag politico). Test in Task 5.
- Un documento la cui catena di fallback data/numero (`act_date`/`data_di_firma`/`publication_start_time`, `act_number`/`has_code`) ha `act_date`/`act_number` **del tutto assenti dalla classe** (sito senza modulo albo-pretorio) non deve generare un errore fatale né un campo vuoto non valido. Test in Task 5.
- Un documento privato non deve mai esporre `provvedimento`/`allegati` nell'export, ma la riga CSV/JSON resta (gli altri campi restano obbligatori). Test in Task 6.
- Un JSON con un campo fuori formato (es. `data` non `GG/MM/AAAA`, un `url` senza `http(s)://`, un campo obbligatorio mancante) deve far fallire l'export con un'eccezione dedicata, non pubblicare un file non conforme. Test in Task 4 e Task 6.
- La vecchia sotto-pagina, una volta nascosta, deve rispondere con un redirect 301 funzionante al vecchio path (non un generico "accesso negato" silenzioso che un test superficiale potrebbe scambiare per successo). Test in Task 10.

---

## Task 1: `SchemaPubblicazioneLookup` — nuovi identificativi di schema

**Files:**
- Modify: `classes/SchemaPubblicazioneLookup.php:35-57` (`OPTION_IDS`), `:70-92` (`LABELS`)
- Test: `tests/test_schema_pubblicazione_lookup_art23.php`

**Interfaces:**
- Produces: `SchemaPubblicazioneLookup::OPTION_IDS['art.23-org'] === 26`, `['art.23-altra-tipologia'] === 27`, `['art.23'] === 28`. Usati da Task 9 (cron) e dal content model (Task 10, installer) per il binding pagina↔schema.

- [ ] **Step 1: Scrivere il test (fallisce perché le chiavi non esistono ancora)**

Crea `tests/test_schema_pubblicazione_lookup_art23.php`:

```php
<?php
/**
 * Verifica che i tre identificativi art.23 siano registrati con gli id
 * 26/27/28 (scelti per non collidere con 22-25, già presi dal branch
 * trasparenza-additional-scheme-26-27 non ancora mergeato - vedi piano,
 * Global Constraints) e che abbiano un'etichetta.
 * Run: php tests/test_schema_pubblicazione_lookup_art23.php
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

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

check('art.23-org id', 26, SchemaPubblicazioneLookup::OPTION_IDS['art.23-org'] ?? null);
check('art.23-altra-tipologia id', 27, SchemaPubblicazioneLookup::OPTION_IDS['art.23-altra-tipologia'] ?? null);
check('art.23 id', 28, SchemaPubblicazioneLookup::OPTION_IDS['art.23'] ?? null);

check('nessun id duplicato', count(SchemaPubblicazioneLookup::OPTION_IDS), count(array_unique(SchemaPubblicazioneLookup::OPTION_IDS)));

foreach (['art.23-org', 'art.23-altra-tipologia', 'art.23'] as $schema) {
    check("label non vuota per $schema", true, isset(SchemaPubblicazioneLookup::LABELS[$schema]) && SchemaPubblicazioneLookup::LABELS[$schema] !== '');
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
```

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_schema_pubblicazione_lookup_art23.php 2>&1); echo "$OUT"'`
Expected: FAIL (le chiavi `art.23-*` non esistono ancora in `OPTION_IDS`/`LABELS`, i controlli su di esse falliscono — il controllo "nessun id duplicato" invece passa già).

- [ ] **Step 2: Aggiungere le 3 chiavi a `OPTION_IDS`** (prossimi id liberi: 26-28, verificato — l'ultimo id realmente nel file è 21 per `art.20-c2`; 22-25 sono presi dal branch `trasparenza-additional-scheme-26-27`, non ancora mergeato, vedi Global Constraints)

In `classes/SchemaPubblicazioneLookup.php`, dentro `const OPTION_IDS = [...]`, dopo `'art.20-c2' => 21,`:

```php
        'art.20-c2' => 21,
        'art.23-org' => 26,
        'art.23-altra-tipologia' => 27,
        'art.23' => 28,
    ];
```

- [ ] **Step 3: Aggiungere le 3 etichette a `LABELS`**

Dentro `const LABELS = [...]`, dopo `'art.20-c2' => 'Staff bonus allocation criteria',`:

```php
        'art.20-c2' => 'Staff bonus allocation criteria',
        'art.23-org' => 'Measures adopted by political governing bodies',
        'art.23-altra-tipologia' => 'Measures adopted by executives',
        'art.23' => 'Administrative measures',
    ];
```

- [ ] **Step 4: Rieseguire il test**

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_schema_pubblicazione_lookup_art23.php 2>&1); echo "$OUT"'`
Expected: `0 falliti`

- [ ] **Step 5: Commit**

```bash
git add classes/SchemaPubblicazioneLookup.php tests/test_schema_pubblicazione_lookup_art23.php
git commit -m "feat: aggiunge gli identificativi di schema art.23 a SchemaPubblicazioneLookup"
```

---

## Task 2: `BootstrapItaliaInstallerUtils::hideContentWithRedirect()`

**Files:**
- Modify: `classes/BootstrapItaliaInstallerUtils.php` (nuovo metodo, dopo `fixAnacDatasetSpatialDefault`)
- Test: `tests/test_hide_content_with_redirect.php`

**Interfaces:**
- Consumes: `OpenPABase::initStateGroup()`, `eZContentOperationCollection::updateObjectState()` (stesso pattern di `migratePrivacyObjectStates()`/`setBooleanAttributeAndChangeState()` già nel file), `eZURLAliasML::storePath()` (stessa firma già usata da `ExportPublisher::publishUrlAlias()`).
- Produces: callable `BootstrapItaliaInstallerUtils::hideContentWithRedirect(AbstractStepInstaller $step)`, invocabile da uno step `php_callable` con config `remote_id`/`redirect_to_remote_id` (letti via `$step->getStep()`). Usata da Task 10 (installer).

Nessuno step YAML dedicato esiste nell'`ocinstaller` per "assegna stato privato + redirigi il path a un altro nodo" — va scritto come `php_callable`, stesso principio di `fixAnacDatasetSpatialDefault`.

- [ ] **Step 1: Scrivere il test** (eZ kernel reale: serve creare due nodi, nasconderne uno con redirect verso l'altro, verificare stato + alias — non è logica pura isolabile senza kernel, a differenza di `ImportoNormalizer`)

Crea `tests/test_hide_content_with_redirect.php`:

```php
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

OpenPABase::initStateGroup('privacy', ['public', 'private']);

$rootNodeId = (int)eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');

function createFolderWithRemoteId($parentNodeId, $name, $remoteId)
{
    $class = eZContentClass::fetchByIdentifier('folder');
    $object = $class->instantiate(eZUser::currentUserID());
    $object->setAttribute('remote_id', $remoteId);
    $object->store();
    $nodeAssignment = eZNodeAssignment::create([
        'contentobject_id' => $object->attribute('id'),
        'contentobject_version' => 1,
        'parent_node' => $parentNodeId,
        'is_main' => 1,
    ]);
    $nodeAssignment->store();
    $version = $object->version(1);
    $version->setAttribute('status', eZContentObjectVersion::STATUS_DRAFT);
    $version->store();
    $dataMap = $object->fetchDataMap(false, 'ita-IT');
    if (isset($dataMap['name'])) {
        $dataMap['name']->fromString($name);
        $dataMap['name']->store();
    }
    $object->publish(['current' => true]);

    return eZContentObject::fetch($object->attribute('id'));
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
$step = new \Opencontent\Installer\AbstractStepInstaller($stepConfig, new \Opencontent\Installer\Logger\NullLogger());
BootstrapItaliaInstallerUtils::hideContentWithRedirect($step);

$sourceObjectAfter = eZContentObject::fetch($sourceObject->attribute('id'));
$privacyStates = OpenPABase::initStateGroup('privacy', ['public', 'private']);
$privateStateId = (int)$privacyStates['privacy.private']->attribute('id');
check('stato privacy.private assegnato', true, in_array($privateStateId, (array)$sourceObjectAfter->attribute('state_id_array'), true));

$resolved = eZURLAliasML::fetchByPath($originalPath);
check('il path originale risolve a un alias', true, $resolved !== null && !empty($resolved));
if ($resolved !== null && !empty($resolved)) {
    $last = end($resolved);
    check('action e\' eznode verso il nodo target', 'eznode:' . $targetObject->attribute('main_node_id'), $last['action']);
    check('e\' marcato come redirect', 1, (int)$last['is_alias']);
}

// idempotenza: rieseguire lo stesso step non deve lanciare eccezioni
try {
    BootstrapItaliaInstallerUtils::hideContentWithRedirect($step);
    check('seconda esecuzione non lancia eccezioni', true, true);
} catch (Exception $e) {
    check('seconda esecuzione non lancia eccezioni', true, false);
}

// remote_id inesistente: deve lanciare, non fallire silenziosamente
try {
    $badStep = new \Opencontent\Installer\AbstractStepInstaller([
        'identifier' => 'BootstrapItaliaInstallerUtils::hideContentWithRedirect',
        'remote_id' => 'questo_remote_id_non_esiste_mai',
        'redirect_to_remote_id' => $targetRemoteId,
    ], new \Opencontent\Installer\Logger\NullLogger());
    BootstrapItaliaInstallerUtils::hideContentWithRedirect($badStep);
    check('remote_id mancante lancia eccezione', true, false);
} catch (Exception $e) {
    check('remote_id mancante lancia eccezione', true, true);
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
```

**Nota per chi implementa**: verificare la firma reale di `Opencontent\Installer\AbstractStepInstaller` (costruttore, `Logger\NullLogger` o equivalente) con `grep -rn "class AbstractStepInstaller" vendor/opencontent/ocinstaller/` dentro il container prima di eseguire — se il costruttore o il logger differiscono, adattare l'istanziazione nel test di conseguenza (il test deve comunque arrivare a chiamare `hideContentWithRedirect($step)` con un oggetto `$step` reale che risponde a `getStep()`/`getLogger()`).

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_hide_content_with_redirect.php 2>&1); echo "$OUT"'`
Expected: FAIL con errore "Call to undefined method BootstrapItaliaInstallerUtils::hideContentWithRedirect()"

- [ ] **Step 2: Implementare il metodo** (in `classes/BootstrapItaliaInstallerUtils.php`, dopo `fixAnacDatasetSpatialDefault`)

```php
    /**
     * Nasconde un contenuto esistente (stato privacy.private) e redirige il
     * suo path pubblico naturale verso un altro nodo, con un redirect 301
     * nativo eZ (eZURLAliasML::storePath(), action 'eznode:', $aliasRedirects
     * = true) - usato per ritirare pagine sostituite da una pagina unificata
     * senza rompere link esterni gia' indicizzati che puntavano al vecchio
     * path (es. motori di ricerca, altri siti che linkano la vecchia pagina).
     *
     * Il path da redirigere e' quello GIA' assegnato al nodo al momento in
     * cui questo step gira - catturato PRIMA di cambiare stato, cosi' non
     * dipende da come l'alias verrebbe (ri)calcolato dopo (in pratica lo
     * stato privacy non tocca l'alias esistente, ma e' piu' sicuro leggerlo
     * prima di qualunque mutazione).
     *
     * Rischio noto e accettato (vedi spec): se in futuro questo contenuto
     * venisse ripubblicato/modificato manualmente, eZ potrebbe rigenerare un
     * alias naturale e sovrascrivere silenziosamente questo redirect - nel
     * caso peggiore si torna ad "accesso negato" (stato privato), mai al
     * contenuto riesposto.
     *
     * steps:
     *     ...
     *     -   type: php_callable
     *         identifier: 'BootstrapItaliaInstallerUtils::hideContentWithRedirect'
     *         remote_id: 280fb2af7960538a94d877f404f67a61
     *         redirect_to_remote_id: d6e4140acc20a01a7dda910b1a27e714
     *     ...
     *
     * @param AbstractStepInstaller $step
     * @throws Exception se remote_id o redirect_to_remote_id non risolvono a un oggetto/nodo
     */
    public static function hideContentWithRedirect(AbstractStepInstaller $step)
    {
        $stepData = $step->getStep();
        $remoteId = $stepData['remote_id'];
        $redirectToRemoteId = $stepData['redirect_to_remote_id'];

        $object = eZContentObject::fetchByRemoteID($remoteId);
        if (!$object instanceof eZContentObject) {
            throw new Exception("hideContentWithRedirect: oggetto con remote_id '$remoteId' non trovato");
        }
        $node = $object->attribute('main_node');
        if (!$node instanceof eZContentObjectTreeNode) {
            throw new Exception("hideContentWithRedirect: main_node non trovato per remote_id '$remoteId'");
        }

        $targetObject = eZContentObject::fetchByRemoteID($redirectToRemoteId);
        if (!$targetObject instanceof eZContentObject) {
            throw new Exception("hideContentWithRedirect: oggetto con remote_id '$redirectToRemoteId' (redirect_to_remote_id) non trovato");
        }
        $targetNodeId = (int)$targetObject->attribute('main_node_id');

        // Catturato PRIMA di cambiare stato: e' il path pubblico su cui un
        // link esterno gia' esistente punta oggi.
        $currentPath = trim($node->attribute('url_alias'), '/');

        $step->getLogger()->info(" - Nascondo '{$object->attribute('name')}' (stato privato) e redirigo '$currentPath' -> nodo $targetNodeId");

        $privacyStates = OpenPABase::initStateGroup('privacy', ['private']);
        eZContentOperationCollection::updateObjectState($object->attribute('id'), [$privacyStates['privacy.private']->attribute('id')]);
        eZContentOperationCollection::registerSearchObject($object->attribute('id'));

        // cleanupElements=true (default, a differenza di ExportPublisher che
        // lo forza a false per i nomi file con punti): $currentPath e' un
        // normale path di pagina, gia' pulito, nessun punto da preservare.
        eZURLAliasML::storePath($currentPath, 'eznode:' . $targetNodeId, false, false, true, false, true, false, true, true);
    }
```

- [ ] **Step 3: Rieseguire il test**

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_hide_content_with_redirect.php 2>&1); echo "$OUT"'`
Expected: `0 falliti`

- [ ] **Step 4: Commit**

```bash
git add classes/BootstrapItaliaInstallerUtils.php tests/test_hide_content_with_redirect.php
git commit -m "feat: aggiunge hideContentWithRedirect per ritirare pagine con redirect 301"
```

---

## Task 3: `DocumentFileResolver::resolveAllUrls()`

**Files:**
- Modify: `classes/anac/DocumentFileResolver.php` (nuovo metodo, accanto a `resolveUrl()`)
- Test: `tests/test_document_file_resolver_all_urls.php`

**Interfaces:**
- Consumes: stessa logica di risoluzione file di `resolveUrl()` (campo `file` singolo o `attachments` multiplo via `ocmultibinary`), riusata non duplicata.
- Produces: `DocumentFileResolver::resolveAllUrls(\eZContentObject $object): string[]` — TUTTI gli url dei file allegati (non solo il primo). Usato da Task 6 (`Art23Serializer`): il primo elemento e' `provvedimento`, il resto e' `allegati`.

`resolveUrl()` esistente prende solo il primo file (`reset($files)`) - va bene per Art31/Art13 (un solo file per documento), ma art.23 distingue esplicitamente "provvedimento" (il documento stesso) da "allegati" (eventuali file aggiuntivi sullo stesso oggetto) - serve l'elenco completo, non solo il primo.

- [ ] **Step 1: Scrivere il test** (richiede un oggetto `document` reale con `attachments` multipli - eZ kernel)

Crea `tests/test_document_file_resolver_all_urls.php`:

```php
<?php
/**
 * Verifica DocumentFileResolver::resolveAllUrls(): con il campo 'file'
 * (singolo) restituisce un solo url; con 'attachments' (ocmultibinary)
 * restituisce TUTTI gli url nell'ordine di visualizzazione, non solo il
 * primo (a differenza di resolveUrl(), che resta invariato).
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_document_file_resolver_all_urls.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'resolveAllUrls test',
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

// Documento senza nessun file: nessun url.
$class = eZContentClass::fetchByIdentifier('document');
$rootNodeId = (int)eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');
$object = $class->instantiate(eZUser::currentUserID());
$object->store();
$nodeAssignment = eZNodeAssignment::create([
    'contentobject_id' => $object->attribute('id'),
    'contentobject_version' => 1,
    'parent_node' => $rootNodeId,
    'is_main' => 1,
]);
$nodeAssignment->store();
$dataMap = $object->fetchDataMap(false, 'ita-IT');
if (isset($dataMap['name'])) {
    $dataMap['name']->fromString('Documento senza file ' . uniqid());
    $dataMap['name']->store();
}
$object->publish(['current' => true]);
$object = eZContentObject::fetch($object->attribute('id'));

check('nessun file => array vuoto', [], \OpenPABootstrapItalia\Anac\DocumentFileResolver::resolveAllUrls($object));

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
```

**Nota per chi implementa**: il caso "nessun file" e' l'unico facilmente riproducibile senza caricare davvero un binario nei test automatici con questo harness leggero. Il caso "`attachments` con piu' file, ordine preservato" va verificato manualmente in Task 13 (verifica end-to-end), caricando un documento reale con 2+ allegati e controllando che l'export CSV/JSON (Task 6) produca effettivamente due righe `ALLEGATO` nell'ordine giusto - annotarlo nella checklist di Task 13.

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_document_file_resolver_all_urls.php 2>&1); echo "$OUT"'`
Expected: FAIL con errore "Call to undefined method DocumentFileResolver::resolveAllUrls()"

- [ ] **Step 2: Implementare il metodo** (in `classes/anac/DocumentFileResolver.php`, accanto a `resolveUrl()`)

```php
    /**
     * @return string[] TUTTI gli url dei file allegati, nell'ordine di
     *         visualizzazione (stesso ordine di resolveUrl(), che ne prende
     *         solo il primo) - [] se il documento non ha nessun file. Usato
     *         da Art23Serializer: il primo e' 'provvedimento', il resto
     *         sono 'allegati' - un unico oggetto document rappresenta un
     *         provvedimento con il proprio file principale piu' eventuali
     *         allegati aggiuntivi sullo stesso oggetto.
     */
    public static function resolveAllUrls(\eZContentObject $object)
    {
        $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        $rawSiteUrl = trim(\eZINI::instance()->variable('SiteSettings', 'SiteURL'), '/');
        $siteUrl = explode('/', $rawSiteUrl, 2)[0];

        if (isset($dataMap['file']) && $dataMap['file']->hasContent()) {
            return ['https://' . $siteUrl . '/content/download/' . $object->attribute('id') . '/' . $dataMap['file']->attribute('id')];
        }

        if (!isset($dataMap['attachments']) || !$dataMap['attachments']->hasContent()) {
            return [];
        }

        $attachmentsAttribute = $dataMap['attachments'];
        $datatype = $attachmentsAttribute->dataType();
        $method = new \ReflectionMethod($datatype, 'getBinaryFiles');
        $method->setAccessible(true);
        $files = (array)$method->invoke($datatype, $attachmentsAttribute, $attachmentsAttribute->attribute('version'));

        $urls = [];
        foreach ($files as $file) {
            if (!$file instanceof \eZMultiBinaryFile) {
                continue;
            }
            $urls[] = 'https://' . $siteUrl . '/ocmultibinary/download/' . $object->attribute('id') . '/' . $attachmentsAttribute->attribute('id') . '/' . $attachmentsAttribute->attribute('version') . '/' . $file->attribute('filename') . '/file/' . rawurlencode($file->attribute('original_filename'));
        }

        return $urls;
    }
```

- [ ] **Step 3: Rieseguire il test**

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_document_file_resolver_all_urls.php 2>&1); echo "$OUT"'`
Expected: `0 falliti`

- [ ] **Step 4: Commit**

```bash
git add classes/anac/DocumentFileResolver.php tests/test_document_file_resolver_all_urls.php
git commit -m "feat: aggiunge resolveAllUrls a DocumentFileResolver per allegati multipli"
```

---

## Task 4: Validazione JSON Schema — fixture, eccezione, `JsonSchemaValidator`

**Files:**
- Create: `classes/anac/schema/art.23-v1.0.schema.json`
- Create: `classes/anac/schema/commons-v1.0.schema.json`
- Create: `classes/anac/InvalidAnacSchemaException.php`
- Create: `classes/anac/JsonSchemaValidator.php`
- Modify: `composer.json` (aggiunge `justinrainbow/json-schema` a `require`)
- Test: `tests/test_anac_json_schema_validator.php`

**Interfaces:**
- Produces: `OpenPABootstrapItalia\Anac\JsonSchemaValidator::validate(string $schemaFilename, string $json): void` (lancia `InvalidAnacSchemaException` se non conforme). Usato da Task 6 (`Art23Serializer::toJson()`), riusabile per futuri schemi ANAC (parametro `$schemaFilename`, non hardcoded).

Libreria `justinrainbow/json-schema` (`JsonSchema\Validator`/`JsonSchema\SchemaStorage`, draft-07): **non e' una nuova dipendenza di fatto** - e' gia' risolta nel `composer.lock` condiviso del progetto come dipendenza transitiva di `erasys/openapi-php` (usato da `ocopenapi`), versione compatibile con `^5.2`. Va solo dichiarata esplicitamente nel `require` di questo `composer.json`, perche' questa estensione la usera' direttamente.

- [ ] **Step 1: Aggiungere la dipendenza a `composer.json`**

In `composer.json`, dentro `"require": {...}`, dopo `"league/oauth2-client": "2.*"`:

```json
    "require": {
        "ezsystems/ezpublish-legacy-installer": "*",
        "opencontent/ocbootstrap-ls": "*",
        "opencontent/openpa-ls": "*",
        "league/oauth2-client": "2.*",
        "justinrainbow/json-schema": "^5.2"
    },
```

- [ ] **Step 2: Scaricare e salvare le due fixture dello schema**

Scarica i due file reali (gia' verificati in questa sessione) e salvali esattamente cosi' come sono (nessuna modifica):

```bash
mkdir -p classes/anac/schema
curl -s -o classes/anac/schema/art.23-v1.0.schema.json "https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.23-v1.0.schema.json"
curl -s -o classes/anac/schema/commons-v1.0.schema.json "https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/commons-v1.0.schema.json"
python3 -c "
import json
for f in ['classes/anac/schema/art.23-v1.0.schema.json', 'classes/anac/schema/commons-v1.0.schema.json']:
    with open(f, encoding='utf-8-sig') as fh:
        d = json.load(fh)
    with open(f, 'w', encoding='utf-8') as fh:
        json.dump(d, fh, ensure_ascii=False, indent=2)
        fh.write('\n')
print('OK: entrambi i file sono JSON valido, BOM rimosso, re-indentati per il commit')
"
```

Expected: `OK: entrambi i file sono JSON valido, BOM rimosso, re-indentati per il commit`

Verifica che il contenuto scaricato coincida con quello gia' verificato in questa sessione: `art.23-v1.0.schema.json` deve avere `"$schema": "http://json-schema.org/draft-07/schema#"`, `"required": ["$schema", "intestazione"]`, le tre proprieta' `provvedimentiOrganiPolitici`/`provvedimentiDirigDiSceltaContraente`/`provvedimentiDirigDiAltraTipologia` (array, `minItems: 1`), e le due `definitions` `ProvvedimentoGen`/`ProvvedimentoSceltaContraente`. `commons-v1.0.schema.json` deve avere la definizione `Data` con pattern `^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/([2-9]\d{3})$` e `Url` con pattern `^https?:\/\/`.

- [ ] **Step 3: Scrivere `InvalidAnacSchemaException`**

Crea `classes/anac/InvalidAnacSchemaException.php`:

```php
<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * JSON non conforme allo schema ANAC reale (validato con JsonSchemaValidator):
 * l'export fallisce esplicitamente invece di pubblicare un file non
 * conforme - stesso principio di InvalidVocabolarioException/
 * InvalidImportoException/MissingCodiceFiscaleException.
 */
class InvalidAnacSchemaException extends \Exception
{
}
```

- [ ] **Step 4: Scrivere il test (fallisce perché `JsonSchemaValidator` non esiste ancora)**

Crea `tests/test_anac_json_schema_validator.php`:

```php
<?php
/**
 * Test di JsonSchemaValidator contro lo schema reale art.23 (logica pura +
 * libreria vendor, nessun kernel eZ - a differenza dei test che leggono
 * contenuti, qui serve solo l'autoload Composer per JsonSchema\Validator).
 *
 * Run (container, serve il vendor/autoload.php di Composer):
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_anac_json_schema_validator.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
require_once $ezRoot . '/vendor/autoload.php';
require __DIR__ . '/../classes/anac/InvalidAnacSchemaException.php';
require __DIR__ . '/../classes/anac/JsonSchemaValidator.php';

use OpenPABootstrapItalia\Anac\JsonSchemaValidator;
use OpenPABootstrapItalia\Anac\InvalidAnacSchemaException;

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
function validates($json)
{
    try {
        JsonSchemaValidator::validate('art.23-v1.0.schema.json', $json);
        return true;
    } catch (InvalidAnacSchemaException $e) {
        return false;
    }
}

$validPayload = [
    '$schema' => 'https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.23-v1.0.schema.json',
    'intestazione' => [
        'amministrazione' => ['codiceFiscale' => '12345678901', 'denominazione' => 'Comune di Prova'],
        'dataPrimaPubblicazione' => '01/01/2026',
        'dataUltimaModifica' => '01/01/2026',
    ],
    'provvedimentiOrganiPolitici' => [[
        'data' => '12/03/2026',
        'numero' => '45',
        'denominazione' => 'Decreto',
        'oggetto' => 'Nomina responsabile',
        'strutturaResponsabile' => 'Ufficio Segreteria',
    ]],
];

check('payload valido passa', true, validates(json_encode($validPayload)));

check('intestazione mancante fallisce', false, validates(json_encode(['$schema' => 'x'])));

$badDate = $validPayload;
$badDate['provvedimentiOrganiPolitici'][0]['data'] = '2026-03-12';
check('data in formato sbagliato fallisce', false, validates(json_encode($badDate)));

$missingField = $validPayload;
unset($missingField['provvedimentiOrganiPolitici'][0]['strutturaResponsabile']);
check('campo obbligatorio mancante fallisce', false, validates(json_encode($missingField)));

$badUrl = $validPayload;
$badUrl['provvedimentiOrganiPolitici'][0]['provvedimento'] = 'www.example.org/senza-protocollo';
check('url senza http(s) fallisce', false, validates(json_encode($badUrl)));

$noDirigenti = $validPayload;
unset($noDirigenti['provvedimentiDirigDiAltraTipologia']);
check('chiave array opzionale assente passa (nessun provvedimento dirigenziale quel giorno)', true, validates(json_encode($noDirigenti)));

$emptyArray = $validPayload;
$emptyArray['provvedimentiDirigDiAltraTipologia'] = [];
check('array vuoto presente fallisce (minItems:1, va omesso non svuotato)', false, validates(json_encode($emptyArray)));

try {
    JsonSchemaValidator::validate('art.23-v1.0.schema.json', 'non e\' json valido {{{');
    check('json malformato lancia eccezione', true, false);
} catch (InvalidAnacSchemaException $e) {
    check('json malformato lancia eccezione', true, true);
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
```

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_anac_json_schema_validator.php 2>&1); echo "$OUT"'`
Expected: FAIL (errore "Class JsonSchemaValidator not found" o simile)

- [ ] **Step 5: Implementare `JsonSchemaValidator`**

Crea `classes/anac/JsonSchemaValidator.php`:

```php
<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Valida un JSON (gia' serializzato in stringa) contro uno schema ANAC
 * reale scaricato e committato come fixture locale (classes/anac/schema/),
 * MAI recuperato via HTTP a runtime: un export di produzione che gira su
 * ~600 tenant non deve dipendere dalla raggiungibilita' di
 * guida-servizi.anticorruzione.it ne' dalla sua latenza, e un eventuale
 * cambio di contenuto lato ANAC non deve alterare silenziosamente cosa
 * viene validato.
 *
 * I $ref dello schema specifico (es. art.23-v1.0.schema.json) puntano
 * all'URL assoluto $id di commons-v1.0.schema.json (non un path relativo) -
 * il contenuto locale di commons viene pre-registrato in una SchemaStorage
 * sotto quello stesso $id, cosi' la risoluzione dei $ref non genera MAI una
 * richiesta di rete.
 *
 * Pensata da subito riusabile per futuri schemi ANAC ($schemaFilename non
 * hardcoded) - questo lavoro non retrofitta pero' la validazione sugli
 * schemi gia' scritti (art.4-bis/13/20/31): fuori scope di questo rilascio.
 */
class JsonSchemaValidator
{
    const SCHEMA_DIR = __DIR__ . '/schema';

    const COMMONS_ID = 'https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/commons-v1.0.schema.json';

    /**
     * @throws InvalidAnacSchemaException se $json non e' JSON valido o non e' conforme allo schema
     */
    public static function validate($schemaFilename, $json)
    {
        $data = json_decode($json);
        if ($data === null && json_last_error() !== JSON_ERROR_NONE) {
            throw new InvalidAnacSchemaException('JSON non valido: ' . json_last_error_msg());
        }

        $commonsPath = self::SCHEMA_DIR . '/commons-v1.0.schema.json';
        $commonsSchema = json_decode(file_get_contents($commonsPath));

        $schemaStorage = new \JsonSchema\SchemaStorage(new \JsonSchema\Uri\UriRetriever(), new \JsonSchema\Uri\UriResolver());
        $schemaStorage->addSchema(self::COMMONS_ID, $commonsSchema);

        $schemaPath = self::SCHEMA_DIR . '/' . $schemaFilename;
        $schema = json_decode(file_get_contents($schemaPath));
        $schemaId = isset($schema->{'$id'}) ? $schema->{'$id'} : 'file://' . $schemaPath;
        $schemaStorage->addSchema($schemaId, $schema);

        $validator = new \JsonSchema\Validator(new \JsonSchema\Constraints\Factory($schemaStorage));
        $validator->validate($data, $schema);

        if (!$validator->isValid()) {
            $messages = [];
            foreach ($validator->getErrors() as $error) {
                $messages[] = ($error['property'] !== '' ? $error['property'] . ': ' : '') . $error['message'];
            }
            throw new InvalidAnacSchemaException(
                "JSON non conforme allo schema ANAC '{$schemaFilename}': " . implode('; ', $messages)
            );
        }
    }
}
```

**Nota per chi implementa**: la firma esatta del costruttore di `JsonSchema\SchemaStorage` dipende dalla versione di `justinrainbow/json-schema` effettivamente risolta - verificare con `grep -n "function __construct" vendor/justinrainbow/json-schema/src/JsonSchema/SchemaStorage.php` dentro il container prima di eseguire il test. Alcune versioni accettano `SchemaStorage($uriRetriever = null, $uriResolver = null)` con entrambi opzionali: in quel caso va bene anche `new \JsonSchema\SchemaStorage()` seguito da `addSchema()`. Adattare la riga del costruttore di conseguenza se il test fallisce per un errore di firma.

- [ ] **Step 6: Rieseguire il test**

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_anac_json_schema_validator.php 2>&1); echo "$OUT"'`
Expected: `0 falliti`

Se fallisce per un errore relativo a `SchemaStorage`/`UriRetriever` (firma non corrispondente), applicare la correzione indicata nella nota dello Step 5 e rieseguire.

- [ ] **Step 7: Aggiornare il lock file**

```bash
composer update justinrainbow/json-schema --lock
```

Se il comando non è eseguibile in locale (nessun composer.json di progetto con repository path), aggiornare manualmente `composer.lock` del progetto CMS (`sito-comunale-dev/composer.json`/`composer.lock`) seguendo la stessa procedura già documentata nel CLAUDE.md root per gli altri pacchetti — ma qui `justinrainbow/json-schema` è già presente e risolto (dipendenza transitiva), quindi questo step probabilmente non produce nessuna modifica al lock: verificare con `git diff composer.lock` dopo il comando, e non committare se non c'è nessuna differenza.

- [ ] **Step 8: Commit**

```bash
git add composer.json classes/anac/schema/art.23-v1.0.schema.json classes/anac/schema/commons-v1.0.schema.json classes/anac/InvalidAnacSchemaException.php classes/anac/JsonSchemaValidator.php tests/test_anac_json_schema_validator.php
git commit -m "feat: aggiunge validazione JSON Schema ANAC riusabile (JsonSchemaValidator)"
```

---

## Task 5: `Art23Serializer` — risoluzione tag, fetch, CSV

**Files:**
- Create: `classes/anac/Serializer/Art23Serializer.php`
- Test: `tests/test_art23_serializer_tag_resolution.php`
- Test: `tests/test_art23_serializer_csv.php`

**Interfaces:**
- Consumes: `DocumentFileResolver::resolveAllUrls()` (Task 3), `SchemaPubblicazioneLookup::EXPORT_LANGUAGE`, `CsvLineBuilder::line()`.
- Produces: `Art23Serializer::fetchProvvedimenti(): array` (righe `{object, denominazione, group}`, `group` = `'organi'` o `'dirigenti'`), `getOrgani(array $provvedimenti = null)`/`getDirigenti(array $provvedimenti = null)` (filtrano per gruppo), `toCsvOrgani(array $provvedimenti = null)`/`toCsvDirigenti(array $provvedimenti = null)`. Usati da Task 6 (JSON), Task 7 (provider live-rendering), Task 9 (cron).

### Risoluzione tag: remote_id hardcoded, non keyword (decisione corretta dopo revisione del piano)

Stesso pattern di `Art31Serializer::TAG_REMOTE_ID_TO_KEY`: un array piatto `remote_id => [denominazione, gruppo]`, i 13 valori hardcoded. **Una stesura precedente di questo task proponeva di risolvere i tag camminando l'albero da un tag radice noto e confrontando le keyword** - scartato in revisione: la keyword è l'etichetta mostrata al redattore, editabile da backend; un domani rinominata anche di poco (un apostrofo, uno spazio), il matching fallirebbe e quel tipo di provvedimento sparirebbe **silenziosamente** dalla tabella e dall'export (il design tollerava esplicitamente le foglie non riconosciute, per non bloccare l'intero export su un tag imprevisto - ma questo rende invisibile anche un semplice refuso). Stessa famiglia di fragilità già incontrata in questo codebase per `Art31Serializer::OGGETTO_AMMESSI` (apostrofo vs accento su "Attivita'"/"Attività"), lì però con un fallimento esplicito (`InvalidVocabolarioException`), non un'esclusione muta.

I 13 remote_id sono verificati su `installer/tagtree_csv/documenti.csv` (stesso meccanismo di import che assegna remote_id fissi anche ai tag ad-hoc di Art31 - "tassonomia standard" non significa "remote_id meno stabile"):

| remote_id | keyword (solo per riferimento, non usato a runtime) | denominazione | gruppo |
|---|---|---|---|
| `ccf6761810b5ac50d32eade1fbe17fca` | Decreto del Sindaco | Decreto | organi |
| `99af81198d42521cfc45090770824e26` | Determinazione del Sindaco | Determinazione | organi |
| `2039d8bedb749132b8bf4301f4c6aeb6` | Ordinanza del Sindaco | Ordinanza | organi |
| `4271686f78f9dbc0fb871f32553ffb6c` | Deliberazione del Commissario ad acta | Deliberazione | organi |
| `19123462b045f0b8977ce0b1a9047032` | Deliberazione del Commissario straordinario | Deliberazione | organi |
| `7634e3355a07d671094fe120d7919653` | Deliberazione del Consiglio circoscrizionale | Deliberazione | organi |
| `7bda99bae095fde15daa1fe54af6861c` | Deliberazione del Consiglio comunale | Deliberazione | organi |
| `5b1e0b73926e47e0e8691c727a2a57df` | Deliberazione della Giunta comunale | Deliberazione | organi |
| `2a8a6817a8f54531c77be68f03655833` | Deliberazione dell'Esecutivo circoscrizionale | Deliberazione | organi |
| `173d943cedd25729d8707a753b12280c` | Deliberazione di altri Organi | Deliberazione | organi |
| `fd0176933fb88cb62d6a3ad4be3cdaa2` | Decreto del Dirigente | Decreto | dirigenti |
| `f3431b7c90f441bab1a0b2e3068325d4` | Determinazione del Dirigente | Determinazione | dirigenti |
| `4bdaece33ace3d1c3911b3b43c554b47` | Ordinanza del Dirigente | Ordinanza | dirigenti |

Nessuna risoluzione a runtime della tassonomia è più necessaria (niente `eZTagsObject::fetchByRemoteID()`/`getChildren()` nel path caldo) - più semplice e più veloce, oltre che più robusto. Il test sotto include comunque un controllo di coerenza che interroga la tassonomia live e verifica che questi 13 remote_id esistano ancora con il keyword atteso: se in futuro un redattore rinominasse un tag, il test fallisce **in modo rumoroso** invece di lasciare che l'export si impoverisca senza nessun segnale.

- [ ] **Step 1: Scrivere il test di risoluzione tag** (eZ kernel: serve leggere la tassonomia reale gia' installata)

Crea `tests/test_art23_serializer_tag_resolution.php`:

```php
<?php
/**
 * Verifica che Art23Serializer::resolveTagMap() esponga esattamente i 13
 * remote_id attesi, nei due gruppi corretti - il gap che oggi esiste in
 * produzione (le due pagine attuali escludono Decreto/Ordinanza e mettono
 * erroneamente "Determinazione del Sindaco" tra i dirigenti).
 *
 * Include anche un controllo di coerenza contro la tassonomia LIVE: per
 * ciascuno dei 13 remote_id hardcoded, verifica che il tag esista ancora e
 * che il suo keyword corrisponda a quello atteso - se un domani un
 * redattore rinominasse un tag, questo test fallisce in modo rumoroso
 * invece di lasciare che l'export si impoverisca senza nessun segnale
 * (motivo per cui si e' scelto remote_id hardcoded invece di risoluzione
 * per keyword, vedi nota di design sopra).
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_tag_resolution.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'Art23Serializer tag resolution test',
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

$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art23Serializer();
$tagMap = $serializer->resolveTagMap();

check('13 tag foglia nella mappa', 13, count($tagMap));

$organiCount = 0;
$dirigentiCount = 0;
foreach ($tagMap as $info) {
    if ($info['group'] === 'organi') {
        $organiCount++;
    } elseif ($info['group'] === 'dirigenti') {
        $dirigentiCount++;
    }
}
check('10 remote_id nel gruppo organi', 10, $organiCount);
check('3 remote_id nel gruppo dirigenti (non Determinazione del Sindaco)', 3, $dirigentiCount);

// Controllo di coerenza con la tassonomia live: ogni remote_id hardcoded
// deve risolvere a un tag esistente il cui keyword coincide con
// l'etichetta attesa (documentata qui per leggibilita', non usata a
// runtime da resolveTagMap()).
$expectedKeywords = [
    'ccf6761810b5ac50d32eade1fbe17fca' => 'Decreto del Sindaco',
    '99af81198d42521cfc45090770824e26' => 'Determinazione del Sindaco',
    '2039d8bedb749132b8bf4301f4c6aeb6' => 'Ordinanza del Sindaco',
    '4271686f78f9dbc0fb871f32553ffb6c' => 'Deliberazione del Commissario ad acta',
    '19123462b045f0b8977ce0b1a9047032' => 'Deliberazione del Commissario straordinario',
    '7634e3355a07d671094fe120d7919653' => 'Deliberazione del Consiglio circoscrizionale',
    '7bda99bae095fde15daa1fe54af6861c' => 'Deliberazione del Consiglio comunale',
    '5b1e0b73926e47e0e8691c727a2a57df' => 'Deliberazione della Giunta comunale',
    '2a8a6817a8f54531c77be68f03655833' => "Deliberazione dell'Esecutivo circoscrizionale",
    '173d943cedd25729d8707a753b12280c' => 'Deliberazione di altri Organi',
    'fd0176933fb88cb62d6a3ad4be3cdaa2' => 'Decreto del Dirigente',
    'f3431b7c90f441bab1a0b2e3068325d4' => 'Determinazione del Dirigente',
    '4bdaece33ace3d1c3911b3b43c554b47' => 'Ordinanza del Dirigente',
];

foreach ($expectedKeywords as $remoteId => $expectedKeyword) {
    $tag = eZTagsObject::fetchByRemoteID($remoteId);
    check("tag '$remoteId' esiste ancora nella tassonomia", true, $tag instanceof eZTagsObject);
    if ($tag instanceof eZTagsObject) {
        check("keyword di '$remoteId' invariato", $expectedKeyword, $tag->getKeyword(SchemaPubblicazioneLookup::EXPORT_LANGUAGE));
    }
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
```

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_tag_resolution.php 2>&1); echo "$OUT"'`
Expected: FAIL (classe non trovata)

- [ ] **Step 2: Scrivere il test CSV** (eZ kernel: crea 2-3 documenti con tag reali, verifica righe CSV)

Crea `tests/test_art23_serializer_csv.php`:

```php
<?php
/**
 * Verifica Art23Serializer::toCsvOrgani()/toCsvDirigenti(): intestazione
 * esatta, catena di fallback data/numero (incluso il caso act_date/
 * act_number DEL TUTTO ASSENTI dalla classe, sito senza albo-pretorio),
 * denominazione = tag padre (non il keyword completo).
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_csv.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'Art23Serializer CSV test',
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

function createDocument($name, $keyword, $organizationObject, $publicationTimestamp)
{
    $class = eZContentClass::fetchByIdentifier('document');
    $rootNodeId = (int)eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');
    $object = $class->instantiate(eZUser::currentUserID());
    $object->store();
    $nodeAssignment = eZNodeAssignment::create([
        'contentobject_id' => $object->attribute('id'),
        'contentobject_version' => 1,
        'parent_node' => $rootNodeId,
        'is_main' => 1,
    ]);
    $nodeAssignment->store();
    $dataMap = $object->fetchDataMap(false, 'ita-IT');
    $dataMap['name']->fromString($name);
    $dataMap['name']->store();
    $dataMap['publication_start_time']->fromString(date('d/m/Y', $publicationTimestamp));
    $dataMap['publication_start_time']->store();
    $tag = eZTagsObject::fetchByKeyword($keyword, true);
    $dataMap['document_type']->fromString($tag->attribute('id'));
    $dataMap['document_type']->store();
    $dataMap['has_organization']->fromString((string)$organizationObject->attribute('id'));
    $dataMap['has_organization']->store();
    $object->publish(['current' => true]);

    return eZContentObject::fetch($object->attribute('id'));
}

$orgClass = eZContentClass::fetchByIdentifier('organization');
$rootNodeId = (int)eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');
$orgObject = $orgClass->instantiate(eZUser::currentUserID());
$orgObject->store();
$nodeAssignment = eZNodeAssignment::create([
    'contentobject_id' => $orgObject->attribute('id'),
    'contentobject_version' => 1,
    'parent_node' => $rootNodeId,
    'is_main' => 1,
]);
$nodeAssignment->store();
$orgDataMap = $orgObject->fetchDataMap(false, 'ita-IT');
if (isset($orgDataMap['legal_name'])) {
    $orgDataMap['legal_name']->fromString('Ufficio di prova ' . uniqid());
    $orgDataMap['legal_name']->store();
}
$orgObject->publish(['current' => true]);
$orgObject = eZContentObject::fetch($orgObject->attribute('id'));

$decreto = createDocument('Decreto di prova ' . uniqid(), 'Decreto del Sindaco', $orgObject, strtotime('2026-03-12'));
$determinazioneDirigente = createDocument('Determina di prova ' . uniqid(), 'Determinazione del Dirigente', $orgObject, strtotime('2026-04-01'));

$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art23Serializer();
$csvOrgani = $serializer->toCsvOrgani();
$csvDirigenti = $serializer->toCsvDirigenti();

check('intestazione CSV organi', 'DATA;NUMERO;DENOMINAZIONE;OGGETTO;STRUTTURA_RESPONSABILE', explode("\n", $csvOrgani)[0]);
check('Decreto del Sindaco compare nel CSV organi con denominazione Decreto', true, strpos($csvOrgani, ';Decreto;') !== false);
check('Determinazione del Dirigente NON compare nel CSV organi', false, strpos($csvOrgani, (string)$determinazioneDirigente->attribute('id')) !== false);

check('intestazione CSV dirigenti', 'DATA;NUMERO;DENOMINAZIONE;OGGETTO;STRUTTURA_RESPONSABILE', explode("\n", $csvDirigenti)[0]);
check('Determinazione del Dirigente compare nel CSV dirigenti con denominazione Determinazione', true, strpos($csvDirigenti, ';Determinazione;') !== false);

check('data risolta dal fallback (act_date assente, usa publication_start_time)', true, strpos($csvOrgani, '12/03/2026') !== false);

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
```

**Nota per chi implementa**: il modulo `albo-pretorio` (che aggiunge `act_date`/`act_number`) potrebbe non essere installato su questa istanza di sviluppo - se la classe `document` non ha quegli attributi, il test sopra verifica automaticamente il caso "assenti dalla classe" (non solo "vuoti"), che e' esattamente il caso da coprire (vedi Review Focus del piano). Se invece il modulo e' installato e gli attributi esistono ma sono vuoti su questi documenti di test, il comportamento atteso e' identico (fallback a `data_di_firma` poi `publication_start_time`) - il controllo sulla data nel CSV resta valido in entrambi i casi.

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_csv.php 2>&1); echo "$OUT"'`
Expected: FAIL (classe non trovata)

- [ ] **Step 3: Implementare `Art23Serializer`** (risoluzione tag, fetch, CSV — il JSON è nel Task 6)

Crea `classes/anac/Serializer/Art23Serializer.php`:

```php
<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

/**
 * Export art. 23 (cms#489): Provvedimenti amministrativi adottati dagli
 * organi di indirizzo politico e dai dirigenti, profilo C1. Risoluzione tag
 * per remote_id hardcoded (vedi REMOTE_ID_TO_INFO sotto), stesso pattern di
 * Art31Serializer::TAG_REMOTE_ID_TO_KEY - NON per keyword (il keyword e'
 * l'etichetta mostrata al redattore, editabile da backend; un matching per
 * testo fallirebbe silenziosamente a una rinomina anche minima, vedi nota di
 * design nel piano di implementazione, Task 5).
 *
 * Struttura JSON verificata scaricando lo schema reale in questa sessione:
 * https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.23-v1.0.schema.json
 * (fixture locale in classes/anac/schema/, vedi JsonSchemaValidator).
 *
 * `provvedimentiDirigDiSceltaContraente` omesso: fuori scope (nessun
 * attributo oggi distingue una determina di scelta del contraente da
 * un'altra determina).
 */
class Art23Serializer
{
    const SCHEMA_IDENTIFIER_ORGANI = 'art.23-org';
    const SCHEMA_IDENTIFIER_DIRIGENTI = 'art.23-altra-tipologia';
    const SCHEMA_IDENTIFIER_JSON = 'art.23';

    const SCHEMA_URL = 'https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.23-v1.0.schema.json';

    /**
     * remote_id del tag document_type (ramo "Tipo di documento -> Documenti
     * Albo Pretorio -> Atto amministrativo") => ['denominazione' => tag
     * padre nella tassonomia, es. 'Decreto', 'group' => 'organi'|'dirigenti'].
     * Verificato su installer/tagtree_csv/documenti.csv (vedi spec §1.3 e
     * piano, Task 5, tabella remote_id/keyword/denominazione/gruppo).
     */
    const REMOTE_ID_TO_INFO = [
        'ccf6761810b5ac50d32eade1fbe17fca' => ['denominazione' => 'Decreto', 'group' => 'organi'],
        '99af81198d42521cfc45090770824e26' => ['denominazione' => 'Determinazione', 'group' => 'organi'],
        '2039d8bedb749132b8bf4301f4c6aeb6' => ['denominazione' => 'Ordinanza', 'group' => 'organi'],
        '4271686f78f9dbc0fb871f32553ffb6c' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '19123462b045f0b8977ce0b1a9047032' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '7634e3355a07d671094fe120d7919653' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '7bda99bae095fde15daa1fe54af6861c' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '5b1e0b73926e47e0e8691c727a2a57df' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '2a8a6817a8f54531c77be68f03655833' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '173d943cedd25729d8707a753b12280c' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        'fd0176933fb88cb62d6a3ad4be3cdaa2' => ['denominazione' => 'Decreto', 'group' => 'dirigenti'],
        'f3431b7c90f441bab1a0b2e3068325d4' => ['denominazione' => 'Determinazione', 'group' => 'dirigenti'],
        '4bdaece33ace3d1c3911b3b43c554b47' => ['denominazione' => 'Ordinanza', 'group' => 'dirigenti'],
    ];

    private $amministrazione;

    /** @var array|null tagId (int) => ['denominazione' => string, 'group' => 'organi'|'dirigenti'], risolto una sola volta per istanza */
    private $tagMap;

    public function __construct(array $amministrazione = null)
    {
        $this->amministrazione = $amministrazione;
    }

    private function getAmministrazione()
    {
        if ($this->amministrazione === null) {
            $this->amministrazione = \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione();
        }

        return $this->amministrazione;
    }

    /**
     * Risolve REMOTE_ID_TO_INFO (13 voci fisse) in tagId => info, una sola
     * query per remote_id (nessuna risoluzione per keyword/tree-walk - vedi
     * docblock di classe). Un remote_id che non risolve piu' a un tag
     * esistente (tassonomia cancellata a mano, mai il caso su un'istanza
     * reale non manomessa) viene saltato, non blocca l'intero export.
     *
     * @return array tagId => ['denominazione' => string, 'group' => 'organi'|'dirigenti']
     */
    public function resolveTagMap()
    {
        if ($this->tagMap !== null) {
            return $this->tagMap;
        }

        $this->tagMap = [];
        foreach (self::REMOTE_ID_TO_INFO as $remoteId => $info) {
            $tag = \eZTagsObject::fetchByRemoteID($remoteId);
            if (!$tag instanceof \eZTagsObject) {
                continue;
            }
            $this->tagMap[(int)$tag->attribute('id')] = $info;
        }

        return $this->tagMap;
    }

    /**
     * Query Solr sempre su tutto il sito (subtree [RootNode], stesso
     * principio di Art13Serializer::fetchRiferimentiContatti()/
     * Art31Serializer::fetchDocumentsByKeys()): un provvedimento con questo
     * tag va trovato ovunque sia pubblicato, non solo sotto "Provvedimenti".
     *
     * @return array righe {object: eZContentObject, denominazione: string, group: 'organi'|'dirigenti'}
     */
    public function fetchProvvedimenti()
    {
        $tagMap = $this->resolveTagMap();
        if (empty($tagMap)) {
            return [];
        }

        $rootNodeId = (int)\eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');
        $tagIds = array_keys($tagMap);
        $query = 'classes [document] and raw[subattr_document_type___tag_ids____si] in [' . implode(',', $tagIds) . '] and subtree [' . $rootNodeId . ']';
        $queryBuilder = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
        $queryObject = $queryBuilder->instanceQuery($query);

        // eZFunctionHandler::execute('ezfind', ...) richiede un dispatch di
        // modulo completo - non disponibile in un contesto cron/CLI (stesso
        // motivo gia' documentato in Art31Serializer::fetchDocumentsByKeys()).
        $solr = new \eZSolr();
        $searchResult = $solr->search('', (array)$queryObject->convert());

        $rows = [];
        foreach ($searchResult['SearchResult'] as $resultNode) {
            $object = $resultNode->attribute('object');
            if (!$object instanceof \eZContentObject) {
                continue;
            }
            $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
            if (!isset($dataMap['document_type'])) {
                continue;
            }
            $tags = $dataMap['document_type']->content();
            if (!$tags instanceof \eZTags) {
                continue;
            }
            foreach ($tags->attribute('tags') as $tag) {
                $tagId = (int)$tag->attribute('id');
                if (!isset($tagMap[$tagId])) {
                    continue;
                }
                $rows[] = [
                    'object' => $object,
                    'denominazione' => $tagMap[$tagId]['denominazione'],
                    'group' => $tagMap[$tagId]['group'],
                ];
                break;
            }
        }

        return $rows;
    }

    public function getOrgani(array $provvedimenti = null)
    {
        $provvedimenti = $provvedimenti !== null ? $provvedimenti : $this->fetchProvvedimenti();

        return array_values(array_filter($provvedimenti, function ($row) {
            return $row['group'] === 'organi';
        }));
    }

    public function getDirigenti(array $provvedimenti = null)
    {
        $provvedimenti = $provvedimenti !== null ? $provvedimenti : $this->fetchProvvedimenti();

        return array_values(array_filter($provvedimenti, function ($row) {
            return $row['group'] === 'dirigenti';
        }));
    }

    /**
     * Catena di fallback data/numero (spec §4): act_date/act_number
     * possono essere DEL TUTTO ASSENTI dalla classe (solo il modulo
     * opzionale albo-pretorio li aggiunge), non solo vuoti - isset() prima
     * di controllare se l'attributo e' valorizzato.
     *
     * @return array{data: string|null, numero: string|null} 'data' in formato gg/mm/aaaa, null se nessuna fonte disponibile
     */
    private function resolveDataNumero(\eZContentObject $object, array $dataMap)
    {
        $data = null;
        foreach (['act_date', 'data_di_firma', 'publication_start_time'] as $field) {
            if (!isset($dataMap[$field])) {
                continue;
            }
            $timestamp = (int)$dataMap[$field]->toString();
            if ($timestamp > 0) {
                $data = date('d/m/Y', $timestamp);
                break;
            }
        }

        $numero = null;
        foreach (['act_number', 'has_code'] as $field) {
            if (!isset($dataMap[$field])) {
                continue;
            }
            $value = trim((string)$dataMap[$field]->content());
            if ($value !== '') {
                $numero = $value;
                break;
            }
        }

        return ['data' => $data, 'numero' => $numero];
    }

    /**
     * @return string nomi delle organization collegate (has_organization,
     *         ezobjectrelationlist multi-valore), separate da ", " se piu' di una
     */
    private function resolveStrutturaResponsabile(array $dataMap)
    {
        if (!isset($dataMap['has_organization']) || !$dataMap['has_organization']->hasContent()) {
            return '';
        }
        $content = $dataMap['has_organization']->content();
        $names = [];
        foreach ((array)($content['relation_list'] ?? []) as $item) {
            $relatedObject = \eZContentObject::fetch((int)$item['contentobject_id']);
            if ($relatedObject instanceof \eZContentObject) {
                $names[] = trim($relatedObject->attribute('name'));
            }
        }

        return implode(', ', $names);
    }

    /**
     * @return array{data: string|null, numero: string|null, denominazione: string, oggetto: string, strutturaResponsabile: string}
     *         campi comuni a CSV e JSON, SENZA provvedimento/allegati (vedi
     *         buildRigaConAllegati() in Task 6, solo per l'export)
     */
    private function buildRigaBase(array $row)
    {
        $object = $row['object'];
        $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        $dataNumero = $this->resolveDataNumero($object, $dataMap);

        return [
            'data' => $dataNumero['data'],
            'numero' => $dataNumero['numero'],
            'denominazione' => $row['denominazione'],
            'oggetto' => trim($object->attribute('name')),
            'strutturaResponsabile' => $this->resolveStrutturaResponsabile($dataMap),
        ];
    }

    private function toCsvGruppo(array $rows)
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line(['DATA', 'NUMERO', 'DENOMINAZIONE', 'OGGETTO', 'STRUTTURA_RESPONSABILE'])];

        foreach ($rows as $row) {
            $riga = $this->buildRigaBase($row);
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
                (string)$riga['data'], (string)$riga['numero'], $riga['denominazione'], $riga['oggetto'], $riga['strutturaResponsabile'],
            ]);
        }

        return implode("\n", $lines) . "\n";
    }

    public function toCsvOrgani(array $provvedimenti = null)
    {
        return $this->toCsvGruppo($this->getOrgani($provvedimenti));
    }

    public function toCsvDirigenti(array $provvedimenti = null)
    {
        return $this->toCsvGruppo($this->getDirigenti($provvedimenti));
    }
}
```

**Nota per chi implementa**: il CSV reale ANAC (spec §4.2) include anche `PROVVEDIMENTO`/`ALLEGATO` con una riga ripetuta per allegato - quella variante (`toCsvOrganiConAllegati()`/`toCsvDirigentiConAllegati()`, usata SOLO dall'export, mai dal rendering live) va nel Task 6 insieme al JSON, perche' condivide la stessa logica "solo se il documento e' pubblico" del blocco JSON.

- [ ] **Step 4: Rieseguire entrambi i test**

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_tag_resolution.php 2>&1); echo "$OUT"'`
Expected: `0 falliti`

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_csv.php 2>&1); echo "$OUT"'`
Expected: `0 falliti`

- [ ] **Step 5: Commit**

```bash
git add classes/anac/Serializer/Art23Serializer.php tests/test_art23_serializer_tag_resolution.php tests/test_art23_serializer_csv.php
git commit -m "feat: aggiunge Art23Serializer (risoluzione tag, fetch, CSV)"
```

---

## Task 6: `Art23Serializer` — export con allegati, JSON con validazione schema

**Files:**
- Modify: `classes/anac/Serializer/Art23Serializer.php`
- Test: `tests/test_art23_serializer_json.php`

**Interfaces:**
- Consumes: `Art23Serializer` (Task 5), `DocumentFileResolver::resolveAllUrls()` (Task 3), `JsonSchemaValidator::validate()`/`InvalidAnacSchemaException` (Task 4).
- Produces: `toCsvOrganiConAllegati()`/`toCsvDirigentiConAllegati()` (export, con `PROVVEDIMENTO`/`ALLEGATO`), `toJson($dataPrimaPubblicazione, $dataUltimaModifica, array $organi, array $dirigenti): string` (valida contro lo schema PRIMA di restituire). Usati da Task 9 (cron).

### Pubblico = stato eZ del Documento (spec §4.2)

`provvedimento`/`allegati` solo se il Documento e' pubblico - stesso principio gia' documentato per gli altri stati nella memoria di sessione (10 = public, 11 = private). Un documento privato resta comunque in CSV/JSON con gli altri campi obbligatori, solo senza questi due.

- [ ] **Step 1: Scrivere il test JSON** (eZ kernel: crea documenti pubblici/privati, verifica JSON valido E conforme allo schema reale)

Crea `tests/test_art23_serializer_json.php`:

```php
<?php
/**
 * Verifica Art23Serializer::toJson(): struttura conforme allo schema ANAC
 * reale (validato con JsonSchemaValidator, non solo "json_decode non
 * fallisce"), provvedimento/allegati presenti solo per documenti pubblici,
 * chiave omessa (non array vuoto) quando un gruppo non ha righe.
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

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
```

**Nota per chi implementa**: il test usa righe con `object => null` e una chiave `__override` di comodo per bypassare la necessita' di creare veri `eZContentObject` solo per testare la FORMA del JSON - `toJson()` deve quindi accettare righe gia' "appiattite" (stesso shape di `buildRigaBase()`) oltre alle righe grezze `{object, denominazione, group}` di `fetchProvvedimenti()`. Il modo piu' semplice: far si' che `toJson()` chiami `buildRigaBase($row)` SOLO se `$row['object']` e' un `eZContentObject` reale, altrimenti usi direttamente `$row['__override']` unito a `denominazione`/`group`. Documentarlo con un commento nel codice (non e' un'eccezione silenziosa, e' un hook di test esplicito) oppure, in alternativa che non richiede questo hook: costruire nel test un vero documento `eZContentObject` pubblico con quei valori (piu' lento ma piu' pulito) - scegliere l'opzione piu' semplice da implementare correttamente, annotando la scelta nel commit.

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_json.php 2>&1); echo "$OUT"'`
Expected: FAIL (metodo `toJson()` non esiste ancora)

- [ ] **Step 2: Implementare `toCsvXxxConAllegati()` e `toJson()`** (in `classes/anac/Serializer/Art23Serializer.php`, dopo `toCsvDirigenti()`)

```php
    private function isPublic(\eZContentObject $object)
    {
        $publicStates = \OpenPABase::initStateGroup('privacy', ['public']);
        $publicStateId = (int)$publicStates['privacy.public']->attribute('id');

        return in_array($publicStateId, (array)$object->attribute('state_id_array'), true);
    }

    /**
     * @return array{...} stessi campi di buildRigaBase() + 'provvedimento'
     *         (string|null, primo url) e 'allegati' (string[], resto degli
     *         url) - solo se il Documento e' pubblico, altrimenti entrambi
     *         vuoti (la riga resta comunque, con gli altri campi).
     */
    private function buildRigaConAllegati(array $row)
    {
        $riga = $this->buildRigaBase($row);
        $riga['provvedimento'] = null;
        $riga['allegati'] = [];

        $object = $row['object'];
        if ($this->isPublic($object)) {
            $urls = \OpenPABootstrapItalia\Anac\DocumentFileResolver::resolveAllUrls($object);
            if (!empty($urls)) {
                $riga['provvedimento'] = array_shift($urls);
                $riga['allegati'] = $urls;
            }
        }

        return $riga;
    }

    /**
     * Formato verificato sull'esempio CSV reale ANAC (spec §4.2):
     * DATA;NUMERO;DENOMINAZIONE;OGGETTO;STRUTTURA_RESPONSABILE;PROVVEDIMENTO;ALLEGATO
     * (ALLEGATO singolare) - con piu' allegati per lo stesso atto, una riga
     * ripetuta per allegato (stessi DATA/NUMERO/.../PROVVEDIMENTO, cambia
     * solo ALLEGATO), non una colonna multivalore. Un atto senza allegati
     * produce comunque una riga (ALLEGATO vuoto).
     */
    private function toCsvGruppoConAllegati(array $rows)
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
            'DATA', 'NUMERO', 'DENOMINAZIONE', 'OGGETTO', 'STRUTTURA_RESPONSABILE', 'PROVVEDIMENTO', 'ALLEGATO',
        ])];

        foreach ($rows as $row) {
            $riga = $this->buildRigaConAllegati($row);
            $base = [(string)$riga['data'], (string)$riga['numero'], $riga['denominazione'], $riga['oggetto'], $riga['strutturaResponsabile'], (string)$riga['provvedimento']];
            if (empty($riga['allegati'])) {
                $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line(array_merge($base, ['']));
            } else {
                foreach ($riga['allegati'] as $allegato) {
                    $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line(array_merge($base, [$allegato]));
                }
            }
        }

        return implode("\n", $lines) . "\n";
    }

    public function toCsvOrganiConAllegati(array $provvedimenti = null)
    {
        return $this->toCsvGruppoConAllegati($this->getOrgani($provvedimenti));
    }

    public function toCsvDirigentiConAllegati(array $provvedimenti = null)
    {
        return $this->toCsvGruppoConAllegati($this->getDirigenti($provvedimenti));
    }

    /**
     * @param array $organi righe gia' filtrate (getOrgani()), puo' essere []
     * @param array $dirigenti righe gia' filtrate (getDirigenti()), puo' essere []
     * @return string JSON, gia' validato contro art.23-v1.0.schema.json
     * @throws \OpenPABootstrapItalia\Anac\InvalidAnacSchemaException se il JSON costruito non e' conforme
     */
    public function toJson($dataPrimaPubblicazione, $dataUltimaModifica, array $organi, array $dirigenti)
    {
        $data = [
            '$schema' => self::SCHEMA_URL,
            'intestazione' => [
                'amministrazione' => $this->getAmministrazione(),
                'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
                'dataUltimaModifica' => $dataUltimaModifica,
            ],
        ];

        $organiJson = $this->buildJsonProvvedimenti($organi);
        if (!empty($organiJson)) {
            $data['provvedimentiOrganiPolitici'] = $organiJson;
        }

        $dirigentiJson = $this->buildJsonProvvedimenti($dirigenti);
        if (!empty($dirigentiJson)) {
            $data['provvedimentiDirigDiAltraTipologia'] = $dirigentiJson;
        }

        $json = json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        \OpenPABootstrapItalia\Anac\JsonSchemaValidator::validate('art.23-v1.0.schema.json', $json);

        return $json;
    }

    private function buildJsonProvvedimenti(array $rows)
    {
        $items = [];
        foreach ($rows as $row) {
            $riga = $row['object'] instanceof \eZContentObject
                ? $this->buildRigaConAllegati($row)
                : array_merge($row['__override'], ['denominazione' => $row['denominazione'], 'provvedimento' => null, 'allegati' => []]);

            $item = [
                'data' => $riga['data'],
                'numero' => $riga['numero'],
                'denominazione' => $riga['denominazione'],
                'oggetto' => $riga['oggetto'],
                'strutturaResponsabile' => $riga['strutturaResponsabile'],
            ];
            if ($riga['provvedimento'] !== null) {
                $item['provvedimento'] = $riga['provvedimento'];
            }
            if (!empty($riga['allegati'])) {
                $item['allegati'] = $riga['allegati'];
            }
            $items[] = $item;
        }

        return $items;
    }
```

- [ ] **Step 3: Rieseguire il test**

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_json.php 2>&1); echo "$OUT"'`
Expected: `0 falliti`

- [ ] **Step 4: Commit**

```bash
git add classes/anac/Serializer/Art23Serializer.php tests/test_art23_serializer_json.php
git commit -m "feat: aggiunge export con allegati e JSON validato a Art23Serializer"
```

---

## Task 7: `PageProvvedimentiProvider` + `LiveRenderingRegistry`

**Files:**
- Create: `classes/anac/PageProvvedimentiProvider.php`
- Modify: `classes/anac/LiveRenderingRegistry.php` (`PROVIDERS`, nessuna voce in `REPLACES_CLASS_IDENTIFIER`: "Provvedimenti" non ha mai avuto un `fields` da sostituire, era vuota)
- Test: `tests/test_page_provvedimenti_provider.php`

**Interfaces:**
- Consumes: `Art23Serializer::fetchProvvedimenti()`/`getOrgani()`/`getDirigenti()` (Task 5).
- Produces: `PageProvvedimentiProvider::getOrganiRowsJson()`/`getDirigentiRowsJson()`, registrati in `LiveRenderingRegistry::PROVIDERS['art.23-org']`/`['art.23-altra-tipologia']`. Usati da Task 8 (template).

Righe esposte (una per provvedimento): `denominazione`, `data`, `numero`, `oggetto`, `strutturaResponsabile`, `anno` (anno della stessa data mostrata, per il filtro Anno), `pubblicazioneInizio`/`pubblicazioneFine` (epoch, per il filtro Periodo - sulla data di pubblicazione del Documento, non sulla "data" ANAC, vedi spec §2.3), `url` (pagina del documento). **Mai** `provvedimento`/`allegati` (solo export).

- [ ] **Step 1: Scrivere il test**

Crea `tests/test_page_provvedimenti_provider.php`:

```php
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

$provider = new \OpenPABootstrapItalia\Anac\PageProvvedimentiProvider();
$organiJson = $provider->getOrganiRowsJson();
$dirigentiJson = $provider->getDirigentiRowsJson();

check('getOrganiRowsJson restituisce JSON valido', true, json_decode($organiJson) !== null || $organiJson === '[]');
check('getDirigentiRowsJson restituisce JSON valido', true, json_decode($dirigentiJson) !== null || $dirigentiJson === '[]');

$rows = json_decode($organiJson, true);
foreach ((array)$rows as $row) {
    check('nessuna riga espone provvedimento', false, array_key_exists('provvedimento', $row));
    check('nessuna riga espone allegati', false, array_key_exists('allegati', $row));
    check('riga ha denominazione', true, array_key_exists('denominazione', $row));
    check('riga ha anno', true, array_key_exists('anno', $row));
    check('riga ha pubblicazioneInizio', true, array_key_exists('pubblicazioneInizio', $row));
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
```

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_page_provvedimenti_provider.php 2>&1); echo "$OUT"'`
Expected: FAIL (classe non trovata)

- [ ] **Step 2: Implementare `PageProvvedimentiProvider`**

Crea `classes/anac/PageProvvedimentiProvider.php`:

```php
<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Espone a template/view i provvedimenti di Art23Serializer (classe
 * `document`, filtrati per tag document_type) senza passare dal formato
 * CSV/JSON - stesso principio di PageArt31DocumentiProvider.
 *
 * Registrata in LiveRenderingRegistry sotto gli schemi art.23-org/
 * art.23-altra-tipologia.
 */
class PageProvvedimentiProvider
{
    private $serializer;

    public function __construct(Serializer\Art23Serializer $serializer = null)
    {
        $this->serializer = $serializer ?: new Serializer\Art23Serializer();
    }

    public function getOrganiRowsJson()
    {
        return $this->rowsJson($this->serializer->getOrgani());
    }

    public function getDirigentiRowsJson()
    {
        return $this->rowsJson($this->serializer->getDirigenti());
    }

    /**
     * @return array righe {denominazione, data, numero, oggetto,
     *         strutturaResponsabile, anno, pubblicazioneInizio,
     *         pubblicazioneFine, url} - MAI provvedimento/allegati (confermato:
     *         "in tabella non li visualizziamo", solo nell'export).
     */
    private function flattenRows(array $rows)
    {
        $flattened = [];
        foreach ($rows as $row) {
            $object = $row['object'];
            $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);

            $data = null;
            $anno = null;
            foreach (['act_date', 'data_di_firma', 'publication_start_time'] as $field) {
                if (!isset($dataMap[$field])) {
                    continue;
                }
                $timestamp = (int)$dataMap[$field]->toString();
                if ($timestamp > 0) {
                    $data = date('d/m/Y', $timestamp);
                    $anno = date('Y', $timestamp);
                    break;
                }
            }

            $numero = null;
            foreach (['act_number', 'has_code'] as $field) {
                if (!isset($dataMap[$field])) {
                    continue;
                }
                $value = trim((string)$dataMap[$field]->content());
                if ($value !== '') {
                    $numero = $value;
                    break;
                }
            }

            $pubblicazioneInizio = isset($dataMap['publication_start_time']) ? (int)$dataMap['publication_start_time']->toString() : 0;
            $pubblicazioneFine = isset($dataMap['publication_end_time']) ? (int)$dataMap['publication_end_time']->toString() : 0;

            $strutturaResponsabile = '';
            if (isset($dataMap['has_organization']) && $dataMap['has_organization']->hasContent()) {
                $names = [];
                foreach ((array)($dataMap['has_organization']->content()['relation_list'] ?? []) as $item) {
                    $relatedObject = \eZContentObject::fetch((int)$item['contentobject_id']);
                    if ($relatedObject instanceof \eZContentObject) {
                        $names[] = trim($relatedObject->attribute('name'));
                    }
                }
                $strutturaResponsabile = implode(', ', $names);
            }

            $flattened[] = [
                'denominazione' => $row['denominazione'],
                'data' => $data,
                'numero' => $numero,
                'oggetto' => trim($object->attribute('name')),
                'strutturaResponsabile' => $strutturaResponsabile,
                'anno' => $anno,
                'pubblicazioneInizio' => $pubblicazioneInizio,
                'pubblicazioneFine' => $pubblicazioneFine,
                'url' => $this->resolveDocumentPageUrl($object),
            ];
        }

        return $flattened;
    }

    private function resolveDocumentPageUrl(\eZContentObject $object)
    {
        $node = $object->attribute('main_node');
        if (!$node instanceof \eZContentObjectTreeNode) {
            return null;
        }

        return '/' . $node->attribute('url_alias');
    }

    private function rowsJson(array $rows)
    {
        return json_encode(
            $this->flattenRows($rows),
            JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_UNICODE
        );
    }
}
```

**Nota per chi implementa**: questa classe duplica deliberatamente la catena di fallback data/numero/strutturaResponsabile gia' presente in `Art23Serializer::buildRigaBase()`, invece di riusarla direttamente - `buildRigaBase()` e' `private` e lavora su un formato di riga pensato per CSV/JSON (stringhe pronte), mentre qui serve ANCHE `anno`/`pubblicazioneInizio`/`pubblicazioneFine` (non richiesti dall'export). Se in revisione risultasse piu' pulito, si puo' rendere `buildRigaBase()` `public` e farla restituire anche questi tre campi aggiuntivi (innocui per CSV/JSON, semplicemente ignorati li') - valutare in review, non bloccante.

- [ ] **Step 3: Registrare i due provider in `LiveRenderingRegistry`**

In `classes/anac/LiveRenderingRegistry.php`, dentro `const PROVIDERS = [...]`, dopo `'art.31-or' => [...]`:

```php
        'art.31-or' => [PageArt31DocumentiProvider::class, 'getOrganiDiRevisioneRowsJson'],
        'art.23-org' => [PageProvvedimentiProvider::class, 'getOrganiRowsJson'],
        'art.23-altra-tipologia' => [PageProvvedimentiProvider::class, 'getDirigentiRowsJson'],
    ];
```

**Nessuna voce in `REPLACES_CLASS_IDENTIFIER`**: la pagina "Provvedimenti" non ha mai avuto un campo `fields` valorizzato (era vuota, vedi spec §1.1) - niente da sostituire.

- [ ] **Step 4: Rieseguire il test**

Run: `docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_page_provvedimenti_provider.php 2>&1); echo "$OUT"'`
Expected: `0 falliti`

- [ ] **Step 5: Commit**

```bash
git add classes/anac/PageProvvedimentiProvider.php classes/anac/LiveRenderingRegistry.php tests/test_page_provvedimenti_provider.php
git commit -m "feat: aggiunge PageProvvedimentiProvider e lo registra in LiveRenderingRegistry"
```

---

## Task 8: Template — colonne e filtri per `art.23-org`/`art.23-altra-tipologia`

**Files:**
- Modify: `design/bootstrapitalia2/templates/openpa/full/parts/amministrazione_trasparente/live_rendering_blocks.tpl`

**Interfaces:**
- Consumes: righe JSON di `PageProvvedimentiProvider` (Task 7): `{denominazione, data, numero, oggetto, strutturaResponsabile, anno, pubblicazioneInizio, pubblicazioneFine, url}`.

Nessun test automatico (template + JS lato client, nessun harness nel progetto per questo) - verificato manualmente in Task 13.

- [ ] **Step 1: Aggiungere la colonna header per i due nuovi schemi**

In `live_rendering_blocks.tpl`, dentro il blocco `{foreach $live_rendering.blocks as $block}` (`<thead>`), aggiungere un nuovo `{elseif}` PRIMA di `{else}` (il ramo generico art.13-op/oa):

```smarty
            {elseif or($block.schema|eq('art.23-org'), $block.schema|eq('art.23-altra-tipologia'))}
            <tr>
                <th>{'Date'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Act number'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Type'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Subject'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Office'|i18n('bootstrapitalia/anac_export')}</th>
            </tr>
```

- [ ] **Step 2: Aggiungere il toolbar filtri sopra la tabella** (solo per i due schemi art.23, dentro la stessa `<section>` del blocco)

Subito prima del tag `<table id="live-rendering-{$block.dom_id}-table" ...>`:

```smarty
    {if or($block.schema|eq('art.23-org'), $block.schema|eq('art.23-altra-tipologia'))}
    <div class="row g-3 mb-3 live-rendering-art23-filters" data-dom-id="{$block.dom_id}">
        <div class="col-md-3">
            <label class="form-label" for="live-rendering-{$block.dom_id}-filter-denominazione">{'Type'|i18n('bootstrapitalia/anac_export')}</label>
            <select class="form-select" id="live-rendering-{$block.dom_id}-filter-denominazione">
                <option value="">{'All'|i18n('bootstrapitalia/anac_export')}</option>
            </select>
        </div>
        <div class="col-md-3">
            <label class="form-label" for="live-rendering-{$block.dom_id}-filter-struttura">{'Office'|i18n('bootstrapitalia/anac_export')}</label>
            <select class="form-select" id="live-rendering-{$block.dom_id}-filter-struttura">
                <option value="">{'All'|i18n('bootstrapitalia/anac_export')}</option>
            </select>
        </div>
        <div class="col-md-2">
            <label class="form-label" for="live-rendering-{$block.dom_id}-filter-anno">{'Year'|i18n('bootstrapitalia/anac_export')}</label>
            <select class="form-select" id="live-rendering-{$block.dom_id}-filter-anno">
                <option value="">{'All'|i18n('bootstrapitalia/anac_export')}</option>
            </select>
        </div>
        <div class="col-md-2">
            <label class="form-label" for="live-rendering-{$block.dom_id}-filter-data-da">{'From'|i18n('bootstrapitalia/anac_export')}</label>
            <input type="date" class="form-control" id="live-rendering-{$block.dom_id}-filter-data-da">
        </div>
        <div class="col-md-2">
            <label class="form-label" for="live-rendering-{$block.dom_id}-filter-data-a">{'To'|i18n('bootstrapitalia/anac_export')}</label>
            <input type="date" class="form-control" id="live-rendering-{$block.dom_id}-filter-data-a">
        </div>
    </div>
    {/if}
```

- [ ] **Step 3: Aggiungere le colonne DataTables per i due schemi**

Nel blocco JS, dentro `{foreach $live_rendering.blocks as $block} $('#live-rendering-{$block.dom_id}-table').DataTable({ldelim} ... {rdelim});`, aggiungere un nuovo `{elseif}` prima di `{else}`:

```smarty
        {elseif or($block.schema|eq('art.23-org'), $block.schema|eq('art.23-altra-tipologia'))}
        columns: [
            {ldelim} data: 'data' {rdelim},
            {ldelim} data: 'numero' {rdelim},
            {ldelim} data: 'denominazione' {rdelim},
            {ldelim} data: 'oggetto', render: function (data, type, row) {ldelim}
                if (type !== 'display' || !row.url) {ldelim} return data; {rdelim}
                var div = document.createElement('div');
                div.textContent = data;
                var a = document.createElement('a');
                a.href = row.url;
                a.innerHTML = div.innerHTML;
                return a.outerHTML;
            {rdelim} {rdelim},
            {ldelim} data: 'strutturaResponsabile' {rdelim}
        ]
```

- [ ] **Step 4: Aggiungere la logica filtri** (dopo il blocco `{foreach $live_rendering.blocks as $block} $('#live-rendering-...).DataTable(...)` esistente, stesso `<script>`)

```smarty
    var art23PeriodoInputs = {ldelim}{rdelim};
    var art23AnnoFilters = {ldelim}{rdelim};

    $.fn.dataTable.ext.search.push(function (settings, searchData, index, rowData) {ldelim}
        var tableId = settings.nTable.id;

        var anno = art23AnnoFilters[tableId];
        if (anno && String(rowData.anno) !== anno) {ldelim} return false; {rdelim}

        var range = art23PeriodoInputs[tableId];
        if (range) {ldelim}
            var fromValue = range.from.val();
            var toValue = range.to.val();
            if (fromValue || toValue) {ldelim}
                var from = fromValue ? (new Date(fromValue)).getTime() / 1000 : null;
                var to = toValue ? ((new Date(toValue)).getTime() / 1000 + 86399) : null;
                var start = rowData.pubblicazioneInizio || 0;
                var end = rowData.pubblicazioneFine || null;
                if (from !== null && (end ? end : start) < from) {ldelim} return false; {rdelim}
                if (to !== null && start > to) {ldelim} return false; {rdelim}
            {rdelim}
        {rdelim}

        return true;
    {rdelim});

    function populateArt23Filter($select, rows, field) {ldelim}
        var values = [];
        rows.forEach(function (row) {ldelim}
            if (row[field] && values.indexOf(row[field]) === -1) {ldelim} values.push(row[field]); {rdelim}
        {rdelim});
        values.sort();
        values.forEach(function (value) {ldelim}
            $select.append($('<option></option>').attr('value', value).text(value));
        {rdelim});
    {rdelim}

    {foreach $live_rendering.blocks as $block}
    {if or($block.schema|eq('art.23-org'), $block.schema|eq('art.23-altra-tipologia'))}
    (function () {ldelim}
        var domId = '{$block.dom_id}';
        var rows = readEmbeddedRows('live-rendering-' + domId + '-data');
        var table = $('#live-rendering-' + domId + '-table').DataTable();
        var tableId = 'live-rendering-' + domId + '-table';

        populateArt23Filter($('#live-rendering-' + domId + '-filter-denominazione'), rows, 'denominazione');
        populateArt23Filter($('#live-rendering-' + domId + '-filter-struttura'), rows, 'strutturaResponsabile');
        populateArt23Filter($('#live-rendering-' + domId + '-filter-anno'), rows, 'anno');

        $('#live-rendering-' + domId + '-filter-denominazione').on('change', function () {ldelim}
            table.column(2).search(this.value ? '^' + $.fn.dataTable.util.escapeRegex(this.value) + '$' : '', true, false).draw();
        {rdelim});
        $('#live-rendering-' + domId + '-filter-struttura').on('change', function () {ldelim}
            table.column(4).search(this.value ? '^' + $.fn.dataTable.util.escapeRegex(this.value) + '$' : '', true, false).draw();
        {rdelim});
        $('#live-rendering-' + domId + '-filter-anno').on('change', function () {ldelim}
            art23AnnoFilters[tableId] = this.value || null;
            table.draw();
        {rdelim});

        art23PeriodoInputs[tableId] = {ldelim}
            from: $('#live-rendering-' + domId + '-filter-data-da'),
            to: $('#live-rendering-' + domId + '-filter-data-a')
        {rdelim};
        $('#live-rendering-' + domId + '-filter-data-da, #live-rendering-' + domId + '-filter-data-a').on('change', function () {ldelim}
            table.draw();
        {rdelim});
    {rdelim})();
    {/if}
    {/foreach}
```

- [ ] **Step 5: Commit**

```bash
git add design/bootstrapitalia2/templates/openpa/full/parts/amministrazione_trasparente/live_rendering_blocks.tpl
git commit -m "feat: aggiunge colonne e filtri Tipologia/Unita organizzativa/Anno/Periodo per art.23"
```

---

## Task 9: Cron — `publishArt23()`

**Files:**
- Modify: `cronjobs/anac_export.php`

**Interfaces:**
- Consumes: `Art23Serializer` (Task 5/6), `SchemaPubblicazioneLookup::fetchAllBindings()` (già calcolato in testa al file, riusato), `ExportPublisher::publish()`.
- Produces: 3 file pubblicati (CSV organi, CSV dirigenti, JSON combinato), tracciati sotto `art.23-org`/`art.23-altra-tipologia`/`art.23`.

**Nessuna funzione `recordAnacExportError()`**: non esiste nel codice attuale (rimossa nel lavoro art.26-27, branch non ancora mergeato ma il commit di rimozione è già confermato) - il pattern reale è il `try/catch` inline già usato da `publishArt31()`/`publishArt13()`.

- [ ] **Step 1: Aggiungere la funzione** (dopo `publishArt31()`, stesso file)

```php

/**
 * art. 23 (cms#489) - Provvedimenti amministrativi, solo C1. Due CSV (uno
 * per gruppo, stesso identificativo delle rispettive tabelle live-rendering)
 * + un JSON combinato con identificativo proprio ('art.23', diverso dai due
 * CSV - stesso principio gia' visto per art.13-pa/art.31 "file unico").
 *
 * Un solo fetch condiviso (Art23Serializer::fetchProvvedimenti()) per CSV e
 * JSON nella stessa esecuzione, stesso principio di publishArt31().
 */
function publishArt23(eZCLI $cli, array $schemaBindings)
{
    try {
        $organiIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art23Serializer::SCHEMA_IDENTIFIER_ORGANI;
        $dirigentiIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art23Serializer::SCHEMA_IDENTIFIER_DIRIGENTI;
        $jsonIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art23Serializer::SCHEMA_IDENTIFIER_JSON;

        $pageObject = $schemaBindings[$organiIdentifier] ?? null;
        if (!$pageObject instanceof eZContentObject) {
            $cli->warning("anac_export: nessuna pagina con schema_pubblicazione = {$organiIdentifier}, schema art.23 saltato (modulo trasparenza-c1 non installato o non aggiornato su questo sito?)");

            return;
        }
        $rootNodeId = $pageObject->attribute('main_node')->attribute('node_id');

        $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art23Serializer();
        $provvedimenti = $serializer->fetchProvvedimenti();
        $organi = $serializer->getOrgani($provvedimenti);
        $dirigenti = $serializer->getDirigenti($provvedimenti);

        $organiPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($organiIdentifier, $rootNodeId);
        $csvOrgani = $serializer->toCsvOrganiConAllegati($organi);
        $organiTracking = $organiPublisher->publishSingle($csvOrgani, 'csv');
        $cli->notice("anac_export: schema {$organiIdentifier} ok, ultima modifica {$organiTracking['dataUltimaModifica']}");

        $dirigentiPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($dirigentiIdentifier, $rootNodeId);
        $csvDirigenti = $serializer->toCsvDirigentiConAllegati($dirigenti);
        $dirigentiTracking = $dirigentiPublisher->publishSingle($csvDirigenti, 'csv');
        $cli->notice("anac_export: schema {$dirigentiIdentifier} ok, ultima modifica {$dirigentiTracking['dataUltimaModifica']}");

        // Il JSON combinato (un solo identificativo per entrambi i gruppi,
        // a differenza dei due CSV separati) dipende dalle date risolte
        // (intestazione) - publishWithDates() con hash sulla sola
        // rappresentazione del dato (senza date), stesso principio di
        // art.13-pa.
        $jsonPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($jsonIdentifier, $rootNodeId);
        $dataHashSource = json_encode([$organi, $dirigenti]);
        $jsonTracking = $jsonPublisher->publishWithDates($dataHashSource, function ($first, $last) use ($serializer, $organi, $dirigenti) {
            return $serializer->toJson($first, $last, $organi, $dirigenti);
        }, 'json');
        $cli->notice("anac_export: schema {$jsonIdentifier} ok, ultima modifica {$jsonTracking['dataUltimaModifica']}");
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: art.23');
        $cli->error('anac_export: schema art.23 fallito: ' . $e->getMessage());
    }
}
```

- [ ] **Step 2: Wiring nella lista principale** (dopo `publishArt20($cli, $schemaBindings);`)

```php
publishArt4Bis($cli, $schemaBindings);
publishArt13($cli, $schemaBindings);
publishArt31($cli, $schemaBindings);
publishArt12($cli, $schemaBindings);
publishArt36($cli, $schemaBindings);
publishArt20($cli, $schemaBindings);
publishArt23($cli, $schemaBindings);
```

- [ ] **Step 3: Verificare manualmente in locale** (richiede Task 1/5/6/10 già applicati)

```bash
docker exec sito-comunale-dev-app-1 php bin/php/runcronjobs.php -s sito_comunale_dev_backend changesection
docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(cat var/log/cronlog.log 2>&1 | grep "anac_export.*art.23"); echo "$OUT"'
```

Expected: righe `anac_export: schema art.23-org ok, ...` / `art.23-altra-tipologia ok, ...` / `art.23 ok, ...`, nessun `fallito`.

- [ ] **Step 4: Commit**

```bash
git add cronjobs/anac_export.php
git commit -m "feat: aggiunge publishArt23 al cron export ANAC"
```

---

## Task 10: Installer — content model (installer repo)

**Files (repo `installer`):**
- Modify: `modules/trasparenza/classes/pagina_trasparenza.yml` (XML `data_text5`, opzioni `schema_pubblicazione`)
- Modify: `modules/trasparenza-c1/installer.yml` (patch "Provvedimenti" + nascondi le due sotto-pagine)

**Interfaces:**
- Consumes: `BootstrapItaliaInstallerUtils::hideContentWithRedirect()` (openpa_bootstrapitalia, Task 2 — deve essere gia' presente nel branch `openpa_bootstrapitalia` attivo sull'istanza di test, l'estensione deve essere in `ActiveExtensions` per il build-time autoload, vedi CLAUDE.md root "ActiveExtensions vs ActiveAccessExtensions").
- Produces: content model pronto per il cron (Task 9) e il rendering live (Task 7/8). Nessun bump di versione (vedi Global Constraints).

- [ ] **Step 1: Aggiungere le 3 opzioni a `pagina_trasparenza.yml`** (prossimi id liberi 26-28, coerenti con `SchemaPubblicazioneLookup::OPTION_IDS` del Task 1)

In `modules/trasparenza/classes/pagina_trasparenza.yml:246`, dentro la stringa XML di `data_text5`, sostituire la chiusura `<option id="21" name="art.20-c2"/></options>` con:

```
<option id="21" name="art.20-c2"/><option id="26" name="art.23-org"/><option id="27" name="art.23-altra-tipologia"/><option id="28" name="art.23"/></options>
```

Run: `python3 -c "import yaml; yaml.safe_load(open('modules/trasparenza/classes/pagina_trasparenza.yml'))" && echo OK`
Expected: `OK`

Verifica aggiuntiva (coerenza col Task 1):

```bash
python3 -c "
import yaml, re
d = yaml.safe_load(open('modules/trasparenza/classes/pagina_trasparenza.yml'))
xml_str = d['schema_pubblicazione']['data_text5']
ids = re.findall(r'option id=\"(\d+)\" name=\"([^\"]+)\"', xml_str)
names = dict(ids)
assert names.get('26') == 'art.23-org', names.get('26')
assert names.get('27') == 'art.23-altra-tipologia', names.get('27')
assert names.get('28') == 'art.23', names.get('28')
print('OK: id 26/27/28 coerenti')
"
```

- [ ] **Step 2: Verificare l'URL reale della pagina "Atti e documenti relativi alle singole procedure e link alla BDNCP"** (remote_id `dd628e7bbe6fd442a5f915ae6e98ea43`, già usata da `contenuto_obbligo` dello Step 3 sotto)

Il path esatto NON è stato verificato live in questa sessione di ricerca (nessun accesso a un'istanza live durante la stesura del piano) — va confermato su un tenant QA prima di committare lo Step 3:

```bash
curl -s "https://<tenant-qa>/opendata/api/content/search/?q=classes%20%5Bpagina_trasparenza%5D%20and%20remote_id%20%3D%20'dd628e7bbe6fd442a5f915ae6e98ea43'" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['searchHits'][0]['metadata'].get('path_alias') or d['searchHits'][0]['metadata'])"
```

Se il comando sopra non restituisce direttamente il path pubblico, risalire dal `mainNodeId` restituito con `curl .../opendata/api/content/browse/<node_id>` (vedi convenzioni query language in `openpa_bootstrapitalia/CLAUDE.md`, sezione "Query language ocopendata"). Usare il path confermato al posto di `/Amministrazione-Trasparente/Bandi-di-gara-e-contratti/Atti-e-documenti-relativi-alle-singole-procedure-e-link-alla-BDNCP` (valore provvisorio, NON verificato) nello Step 3.

- [ ] **Step 3: Patch della pagina "Provvedimenti"** (in `modules/trasparenza-c1/installer.yml`, dopo il blocco `php_callable patchContentAttributeForLanguage` su `2803f003c03c4940a1d01bac9dee285c` — stessa area di `$articolazione_uffici`/`$telefono_e_posta_elettronica`)

```yaml
    # Unifica "Provvedimenti organi indirizzo politico" e "Provvedimenti
    # dirigenti" (nascoste sotto, vedi Step 4) in questa pagina unica, con
    # due tabelle live-rendering (art.23-org/art.23-altra-tipologia) +
    # export JSON combinato (art.23) - cms#489.
    -   type: patch_content
        identifier: d6e4140acc20a01a7dda910b1a27e714
        ignore_error: true
        attributes:
            contenuto_obbligo: '<p>Elenco dei provvedimenti adottati dagli organi di indirizzo politico e dai dirigenti, con particolare riferimento ai provvedimenti finali dei procedimenti di scelta del contraente per l''affidamento di lavori, forniture e servizi e di accordi stipulati dall''amministrazione con soggetti privati o con altre amministrazioni pubbliche.</p><p>Per i provvedimenti di scelta del contraente l''obbligo è assolto con il link alla sotto-sezione <a href="/Amministrazione-Trasparente/Bandi-di-gara-e-contratti/Atti-e-documenti-relativi-alle-singole-procedure-e-link-alla-BDNCP">Bandi di gara e contratti</a>.</p><p>Oltre a tali provvedimenti, possono essere pubblicati tutti gli altri provvedimenti adottati dagli organi di indirizzo politico e dai dirigenti.</p>'
            riferimenti_normativi: "Ai sensi dell'art.1, co.1, lett. g) della l.r. n. 10/2014 e ss.mm., art. 23, co.1, d.lgs. n. 33/2013 e ss.mm."
            messaggio_di_consiglio: '<p>Si raccomanda il rispetto dei principi in materia di trattamento di dati personali ed in particolare il divieto di pubblicare dati sensibili e la regola dell''inserimento dei dati personali secondo il criterio di pertinenza e non eccedenza</p>'
            decorrenza_di_pubblicazione:
                - Tempestiva
            aggiornamento:
                - Semestrale
            termine_pubblicazione:
                - '5 anni a decorrere dal primo gennaio dell''anno successivo a quello da cui decorre l''obbligo di pubblicazione'
            schema_pubblicazione:
                - art.23-org
                - art.23-altra-tipologia
                - art.23
```

- [ ] **Step 4: Nascondere le due sotto-pagine con redirect** (subito dopo lo step precedente)

```yaml
    # Le due sotto-pagine sono sostituite dalla pagina unica sopra - stato
    # privato + redirect 301 verso il nodo padre (BootstrapItaliaInstallerUtils::
    # hideContentWithRedirect(), openpa_bootstrapitalia). Rischio noto e
    # accettato (vedi spec): una ripubblicazione futura potrebbe rigenerare
    # l'alias naturale e sovrascrivere il redirect - nel caso peggiore si
    # vede "accesso negato", mai il contenuto riesposto.
    -   type: php_callable
        identifier: 'BootstrapItaliaInstallerUtils::hideContentWithRedirect'
        remote_id: 280fb2af7960538a94d877f404f67a61
        redirect_to_remote_id: d6e4140acc20a01a7dda910b1a27e714

    -   type: php_callable
        identifier: 'BootstrapItaliaInstallerUtils::hideContentWithRedirect'
        remote_id: e28f316825dba873f9f0a4ca50d1c5f4
        redirect_to_remote_id: d6e4140acc20a01a7dda910b1a27e714
```

**Nessun gate di versione** (vedi Global Constraints): questi quattro step girano sempre, su ogni esecuzione dell'installer (fresh install incluso, dove la pagina "Provvedimenti" e le due sotto-pagine esistono gia' dallo step `tree` prima che questi step le patchino/nascondano nella stessa esecuzione).

- [ ] **Step 5: Validare la sintassi YAML**

Run: `python3 -c "import yaml; yaml.safe_load(open('modules/trasparenza-c1/installer.yml'))" && echo OK`
Expected: `OK`

- [ ] **Step 6: Commit**

```bash
git add modules/trasparenza/classes/pagina_trasparenza.yml modules/trasparenza-c1/installer.yml
git commit -m "feat: unifica Provvedimenti in una pagina con due tabelle live, nasconde le vecchie sotto-pagine"
```

---

## Task 11: i18n — stringhe nuove

**Files:**
- Modify: `translations/untranslated/translation.ts`
- Esterno: push term + traduzioni su POEditor (progetto 740564, token già documentato in CLAUDE.md root — mai scrivere il valore letterale nei comandi committati, usare la variabile d'ambiente)

**Interfaces:**
- Consumes: nessuna.
- Produces: tutte le stringhe inglesi aggiunte nei Task 6-8 (`'Measures adopted by political governing bodies'`, `'Measures adopted by executives'`, `'Administrative measures'`, `'Date'`, `'Act number'`, `'Subject'`, `'All'`, `'From'`, `'To'`) disponibili tradotte in ita-IT.

- [ ] **Step 1: Elencare le stringhe nuove per contesto**

Contesto `bootstrapitalia/anac_export`:
- `Measures adopted by political governing bodies`
- `Measures adopted by executives`
- `Administrative measures`
- `Date` (se non già presente in questo contesto da altro schema — verificare con `grep -n "'Date'" translations/ita-IT/translation.ts` prima di aggiungerla di nuovo)
- `Act number`
- `Subject`
- `All`
- `From`
- `To`

- [ ] **Step 2: Push dei term via API POEditor** (per ogni stringa non già presente; `$PO_ORG_TOKEN` è la variabile d'ambiente col token, già usata nella procedura di pull documentata in CLAUDE.md root — esportarla in locale prima di lanciare il comando, mai scriverne il valore in un file)

```bash
curl -s -X POST https://api.poeditor.com/v2/terms/add \
  -d api_token="$PO_ORG_TOKEN" \
  -d id=740564 \
  --data-urlencode 'data=[{"term":"Measures adopted by political governing bodies","context":"bootstrapitalia/anac_export","tags":["openpa_bootstrapitalia"]},{"term":"Measures adopted by executives","context":"bootstrapitalia/anac_export","tags":["openpa_bootstrapitalia"]},{"term":"Administrative measures","context":"bootstrapitalia/anac_export","tags":["openpa_bootstrapitalia"]},{"term":"Act number","context":"bootstrapitalia/anac_export","tags":["openpa_bootstrapitalia"]},{"term":"Subject","context":"bootstrapitalia/anac_export","tags":["openpa_bootstrapitalia"]},{"term":"All","context":"bootstrapitalia/anac_export","tags":["openpa_bootstrapitalia"]},{"term":"From","context":"bootstrapitalia/anac_export","tags":["openpa_bootstrapitalia"]},{"term":"To","context":"bootstrapitalia/anac_export","tags":["openpa_bootstrapitalia"]}]'
```

(Omettere `Date` dal payload se già presente in questo contesto, verificato allo Step 1.)

- [ ] **Step 3: Push delle traduzioni ita-IT**

```bash
curl -s -X POST https://api.poeditor.com/v2/translations/add \
  -d api_token="$PO_ORG_TOKEN" \
  -d id=740564 \
  -d language=it \
  --data-urlencode 'data=[{"term":"Measures adopted by political governing bodies","context":"bootstrapitalia/anac_export","translation":{"content":"Provvedimenti adottati dagli organi di indirizzo politico"}},{"term":"Measures adopted by executives","context":"bootstrapitalia/anac_export","translation":{"content":"Provvedimenti adottati dai dirigenti"}},{"term":"Administrative measures","context":"bootstrapitalia/anac_export","translation":{"content":"Provvedimenti amministrativi"}},{"term":"Act number","context":"bootstrapitalia/anac_export","translation":{"content":"Numero atto"}},{"term":"Subject","context":"bootstrapitalia/anac_export","translation":{"content":"Oggetto"}},{"term":"All","context":"bootstrapitalia/anac_export","translation":{"content":"Tutti"}},{"term":"From","context":"bootstrapitalia/anac_export","translation":{"content":"Dal"}},{"term":"To","context":"bootstrapitalia/anac_export","translation":{"content":"Al"}}]'
```

- [ ] **Step 4: Pull locale** (seguire la procedura con attenzione al rischio "full sync", vedi root `CLAUDE.md`)

```bash
docker exec sito-comunale-dev-app-1 sh -c 'POEDITOR_TOKEN="$PO_ORG_TOKEN" php vendor/bin/oci18n -r --no-colors'
```

Al prompt: lingua `0` (it), estensione `openpa_bootstrapitalia`, poi `n` a content types/contenuti/tags.

- [ ] **Step 5: Verificare `git diff --stat` prima di committare**

Run: `git diff --stat translations/`
Expected: un numero di righe cambiate coerente con le ~9 stringhe aggiunte (non decine di righe in più che indicherebbero una cancellazione di entry preesistenti non correlate — se così, NON committare, vedi procedura di recupero nel CLAUDE.md root).

- [ ] **Step 6: Verificare che le traduzioni risolvano**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
docker exec sito-comunale-dev-app-1 php -r '
require_once "autoload.php";
$script = eZScript::instance(["description" => "check i18n art.23"]);
$script->startup(); $script->initialize();
foreach (["Measures adopted by political governing bodies", "Measures adopted by executives", "Administrative measures"] as $s) {
    echo ezpI18n::tr("bootstrapitalia/anac_export", $s) . "\n";
}
$script->shutdown();
'
```

Expected: le tre traduzioni italiane, non le stringhe inglesi invariate.

- [ ] **Step 7: Commit**

```bash
git add translations/
git commit -m "i18n: aggiunge stringhe inglesi/italiane per art.23 (tabella, filtri, etichette schema)"
```

---

## Task 12: Documentazione `CLAUDE.md` (entrambi i repo)

**Files:**
- Modify: `classes/anac/CLAUDE.md` (repo `openpa_bootstrapitalia`)
- Modify: `modules/trasparenza-c1/CLAUDE.md` (repo `installer`)

**Interfaces:** nessuna (solo documentazione).

- [ ] **Step 1: Aggiornare `openpa_bootstrapitalia/classes/anac/CLAUDE.md`**

Aggiungere in fondo una sezione `## art. 23 - Provvedimenti amministrativi (cms#489), solo C1` che descriva: fonte dati (`document`/`document_type`, nessun dataset, a differenza di art.4-bis/art.20/art.26-27); risoluzione tag per keyword da un singolo tag radice noto (`Atto amministrativo`), non remote_id hardcoded come `Art31Serializer::TAG_REMOTE_ID_TO_KEY` (motivazione: tassonomia standard preesistente, non tag creati ad-hoc); le due pagine legacy ritirate con stato privato + redirect 301 (`BootstrapItaliaInstallerUtils::hideContentWithRedirect()`, nuovo meccanismo riusabile — primo caso d'uso in questo progetto di "ritiro pagina con redirect", diverso da tutte le altre pagine ANAC che restano sempre attive); tre identificativi (`art.23-org`/`art.23-altra-tipologia` CSV, `art.23` JSON combinato — stesso principio di `art.13-pa`); **nuova validazione JSON Schema generica** (`JsonSchemaValidator`, fixture locali in `classes/anac/schema/`, non retrofittata sugli altri schemi già scritti); `provvedimentiDirigDiSceltaContraente` omesso (nessun attributo distingue scelta-contraente da altre determine, stesso principio di esclusione già visto altrove).

- [ ] **Step 2: Aggiornare `installer/modules/trasparenza-c1/CLAUDE.md`**

Aggiungere una riga alla tabella "Binding schema ANAC ↔ contenuto" per `art.23-org`/`art.23-altra-tipologia`/`art.23` (Backing: `document` taggato `document_type`, nessun dataset; Node id passato a `ExportPublisher`: il nodo della pagina "Provvedimenti", remote_id `d6e4140acc20a01a7dda910b1a27e714`). Aggiungere una sezione dedicata che spiega: le due vecchie pagine (`280fb2af7960538a94d877f404f67a61`/`e28f316825dba873f9f0a4ca50d1c5f4`) sono state **ritirate**, non più navigabili (stato privato + redirect) — a differenza di tutte le altre righe della tabella, che restano pagine attive; nessun bump di versione per questo cambiamento (vedi Global Constraints del piano); il gap di classificazione che questo lavoro risolve (Decreto/Ordinanza mancanti, "Determinazione del Sindaco" erroneamente tra i dirigenti nelle vecchie pagine).

- [ ] **Step 3: Commit** (un commit per repo)

```bash
# openpa_bootstrapitalia
git add classes/anac/CLAUDE.md
git commit -m "docs: documenta art.23 (Provvedimenti) in classes/anac/CLAUDE.md"
```

```bash
# installer
git add modules/trasparenza-c1/CLAUDE.md
git commit -m "docs: documenta art.23 (Provvedimenti) in trasparenza-c1/CLAUDE.md"
```

---

## Task 13: Verifica end-to-end in locale (prima della consegna)

**Files:** nessuno (solo verifica manuale).

Checklist derivata dalla sezione "Testing" dello spec — ripercorrerla punto per punto su un'istanza locale con entrambi i branch (`installer` + `openpa_bootstrapitalia`) attivi:

- [ ] Eseguire l'installer aggiornato (`ocinstall --update` sul modulo `trasparenza-c1`, o rebuild locale completo) e verificare che "Provvedimenti" (remote_id `d6e4140acc20a01a7dda910b1a27e714`) mostri contenuto_obbligo/riferimenti_normativi/ecc. e che le due tabelle live-rendering compaiano.
- [ ] Visitare il vecchio path di "Provvedimenti organi indirizzo politico" (quello catturato nello Step di Task 10) e verificare un redirect 301 funzionante verso "Provvedimenti" — non un generico "accesso negato" che una verifica superficiale potrebbe scambiare per successo.
- [ ] Ripetere per "Provvedimenti dirigenti".
- [ ] Creare un Decreto del Sindaco, un'Ordinanza del Dirigente e una Deliberazione del Consiglio comunale (tag reali, nessuna creazione di tag) e verificare che compaiano nella tabella corretta (organi vs dirigenti) — il gap reale che oggi esiste in produzione.
- [ ] Verificare i filtri Tipologia/Unità organizzativa/Anno/Periodo sulle due tabelle (dropdown popolati, filtro Periodo che esclude correttamente documenti fuori intervallo).
- [ ] Creare un documento SENZA modulo albo-pretorio attivo (quindi senza `act_date`/`act_number` sulla classe) e verificare che CSV/JSON risolvano comunque `data`/`numero` dal fallback, senza errori fatali.
- [ ] Caricare un documento con 2+ allegati (`attachments`, ocmultibinary) e verificare che l'export CSV/JSON produca `provvedimento` + `allegati` nell'ordine corretto (vedi nota Task 3, Step 1).
- [ ] Rendere un documento privato e verificare che CSV/JSON mantengano la riga ma omettano `provvedimento`/`allegati`.
- [ ] Lanciare il cron (`runcronjobs.php ... changesection`) e verificare i tre file pubblicati (`art.23-org`, `art.23-altra-tipologia`, `art.23`) sotto il nodo "Provvedimenti", URL pubblici funzionanti.
- [ ] Validare il JSON pubblicato contro lo schema reale con un tool esterno (es. https://www.jsonschemavalidator.net/ o `ajv-cli`), non solo fidandosi del test automatico — doppia verifica indipendente dalla stessa libreria usata in `JsonSchemaValidator`.
- [ ] Verificare che gli altri schemi ANAC (art.4-bis, art.13, ecc.) continuino a pubblicarsi correttamente dopo il deploy (nessuna regressione nel cron condiviso).
- [ ] Rieseguire l'intera checklist di test automatici (Task 1-7) in sequenza su un ambiente pulito, non solo singolarmente durante lo sviluppo.
