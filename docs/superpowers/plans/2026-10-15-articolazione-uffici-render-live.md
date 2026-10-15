# Articolazione degli uffici — rendering live da Art13Serializer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sostituire, per le sezioni "Organi di indirizzo politico" e "Organi amministrativi" della pagina "Articolazione degli uffici" (`pagina_trasparenza`), il meccanismo dichiarativo `fields`/datatable con un rendering live che chiama direttamente le funzioni di raccolta dati già scritte per l'export ANAC (`Art13Serializer`), così che pagina ed export condividano esattamente la stessa fonte — stesso raggruppamento organo→uffici, stessa ricorsione multi-livello su `hold_employment`, stesso responsabile risolto (non il placeholder `(calculated)`).

**Architecture:** Due repository coinvolti — `openpa_bootstrapitalia` (branch `feature/anac-export-serializers`, dove vive `Art13Serializer` e dove va costruito tutto il lavoro di questo piano) e `sito-comunale-dev` (ambiente di verifica, nessuna modifica di codice attesa lì). Due metodi del serializer passano da scan PHP/controllo misto a query Solr dirette (stesso pattern già usato da `fetchFigliDiOrgano()`); viene aggiunto un nuovo service di presentazione che chiama i metodi `fetch*()` esistenti e li espone a un nuovo partial di template; l'invalidazione della cache HTTP della pagina aggregata viene agganciata all'estensione `ocfoshttpcache` già attiva, con un tag dedicato e un nuovo listener.

**Tech Stack:** eZ Publish Legacy (PHP 7.4), PostgreSQL, Solr (via `Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder` + `eZSolr`), estensione `ocfoshttpcache` (FOSHttpCache + Varnish xkey) per la cache HTTP, ambiente di verifica `sito-comunale-dev` (docker compose). Questo repo non ha un framework di test automatico per template/cron eZ Publish Legacy (stessa nota già nel piano `2026-09-15-anac-export-followup.md`) — la convenzione di test già in uso qui è uno script PHP standalone in `tests/`, bootstrap via `eZScript`, con helper `assert_true`/`assert_eq` locali al file (vedi `tests/test_has_role_webhook_payload.php`), eseguito con `docker exec sito-comunale-dev-app-1 php /var/www/html/extension/openpa_bootstrapitalia/tests/<file>.php`. Questo piano segue la stessa convenzione per la logica PHP pura (Task 3, 4), e verifica manuale via curl/browser per template e cache (Task 6, 7).

**Spec:** Non un documento singolo — tre fonti discusse e decise in sessione (conversazione 2026-10-14/15 con Marco):
1. Le tre tabelle della pagina "Articolazione degli uffici" devono rispecchiare il più possibile gli export `art.13-op` (organi di indirizzo politico), `art.13-oa` (organi amministrativi) e `art.13-rif` (riferimenti e contatti) — vedi `openpa_bootstrapitalia/classes/anac/CLAUDE.md` (branch `feature/anac-export-serializers`) per l'architettura dell'export.
2. Il meccanismo dichiarativo `fields`/datatable (`openpa_bootstrapitalia/classes/services/content_trasparenza.php`) è stato valutato e scartato per le sezioni "organi politici"/"organi amministrativi": non sa seguire `hold_employment` oltre un salto, non sa raggruppare per organo, e la colonna "responsabile" mostra sempre il placeholder `(calculated)` (`openpa_bootstrapitalia/datatypes/openparole/OpenPARoleAttributeConverter.php:36`) perché passa dalla REST API pubblica `ocopendata`, che lo evita apposta per non introdurre una query Solr per persona ad ogni lettura.
3. La sezione "Telefono e contatti" (`art.13-rif`) resta **fuori scopo da questo piano**: ha un problema diverso (include tutti gli `online_contact_point` del sito, non solo quelli di un'unità organizzativa) che richiede un campo calcolato in indicizzazione — discusso ma non deciso, trattato come lavoro futuro separato.

## Global Constraints

- Questo lavoro dipende da `Art13Serializer` e dalle classi correlate (`classes/anac/`), che oggi esistono solo sul branch `feature/anac-export-serializers` di `openpa_bootstrapitalia`, non ancora mergiato — i task di questo piano vanno eseguiti partendo da quel branch (o da dove verrà mergiato), non da `master`/`dev`.
- Nessun nuovo campo attributo nel content model — tutto il lavoro è codice (serializer, service, template, cache), nessuno step `class`/`class_with_extra` nell'installer.
- La tabella "Telefono e contatti" (`art.13-rif`) non viene toccata da questo piano — resta sul meccanismo `fields`/datatable esistente.
- Fonte di verità per cosa deve contenere ogni tabella: `Art13Serializer::fetchOrganiConUffici()` e `fetchOrganiAmministrativi()` — questo piano non cambia la logica di business di queste funzioni, solo come recuperano il set iniziale di candidati (PHP scan → query Solr) e come i risultati arrivano a schermo (CSV/JSON batch → HTML live).
- Niente push senza conferma esplicita di Marco per ciascun repo coinvolto (regola di profilo, vale sempre) — questo piano produce commit locali, non push.
- Ogni task che tocca `sito-comunale-dev` va verificato con un test reale (query SQL read-only, curl, e/o browser) prima di considerarlo concluso.

## Review Focus

- **Ente senza `trasparenza-c1`/`trasparenza-c2` installato** (nessun binding `schema_pubblicazione`): il nuovo rendering live non deve essere invocato né rompere la pagina — oggi `has_table_fields`/`has_anac_exports` già gestiscono questo caso per le funzionalità esistenti, il nuovo blocco deve seguire lo stesso schema di guardia.
- **Zero organi trovati** (query Solr vuota, es. dati di test incompleti o tag non ancora indicizzato): la tabella deve mostrare uno stato vuoto leggibile, non un errore PHP né una tabella con intestazioni e zero righe che sembra un bug.
- **`!range [*,*]` su un campo mai popolato vs. un campo con relazione cancellata di recente**: verificare che l'operatore distingua correttamente "non ha mai avuto valore" da un oggetto con indice Solr non ancora aggiornato dopo una modifica — altrimenti un'Area con `hold_employment` appena svuotato potrebbe non comparire come vertice fino al prossimo reindex.
- **Oggetto `organization` che riusa la classe per altro** (il caso "Ente"/ente esterno già documentato nel commento di `fetchOrganiAmministrativi()`): la query Solr deve riprodurre esattamente la stessa combinazione di condizioni (tag esatto "Area" + `hold_employment` vuoto) della versione PHP attuale, non una condizione più permissiva che reintroduce falsi positivi già esclusi oggi.
- **Doppia invalidazione cache nello stesso giorno** (due pubblicazioni ravvicinate di `organization` diversi): il tag di cache condiviso deve bustare la pagina ad ogni pubblicazione rilevante, non solo alla prima — da verificare esplicitamente nel Task 2, perché la logica a "una pubblicazione al massimo al giorno" vista nell'export (`ExportPublisher`) qui NON deve applicarsi (la pagina live deve rinfrescarsi ad ogni modifica, non una volta al giorno).

---

### Task 1 — Spike: verificare l'operatore `!range [*,*]` per "relazione vuota" su `hold_employment`

**Perché prima di tutto**: `fetchOrganiAmministrativi()` (Task 4) deve sostituire il controllo PHP "`hold_employment` vuoto" con una condizione Solr. L'operatore esiste nel motore (`ocopendata/lib/ocopendata/src/Opencontent/Opendata/Api/QueryLanguage/EzFind/SentenceConverter.php`, funzione `generateRangeFilter`, forma negata `!range` → `!fieldName:[A TO B]`), ma non c'è nel codebase un precedente che lo usi per "campo assente" su una relazione (`submeta_hold_employment___id____si`) — solo la forma positiva `range [*,*]` ("campo esiste") in `openpa_bootstrapitalia/classes/handlers/data/albo_pretorio.php:18`. Va verificato con un test reale prima di costruirci sopra Task 4.

**Files:**
- Create: `tests/test_art13_hold_employment_empty_query.php`

**Interfaces:**
- Consumes: `Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder::instanceQuery($queryString)`, `eZSolr::search($string, array $parameters)` — stessa coppia già usata in `classes/anac/Serializer/Art13Serializer.php:297-301` (`fetchFigliDiOrgano()`).
- Produces: un verdetto booleano (PASS/FAIL del test) che decide se Task 4 procede così com'è o va rivista.

- [ ] **Step 1: Creare due organization di prova via backend o script, uno con `hold_employment` vuoto e uno valorizzato**

Nel container app, usare la stessa convenzione di setup/cleanup di `tests/test_has_role_webhook_payload.php` (crea oggetti, verifica, pulisce a fine test). Lo script seguente crea due oggetti `organization` temporanei sotto la Home (node 2, radice standard eZ Publish Legacy):

```php
<?php
/**
 * Spike: verifica che `raw[submeta_hold_employment___id____si] !range [*,*]`
 * isoli correttamente gli organization con `hold_employment` vuoto da quelli
 * valorizzati - operatore mai usato prima in questa forma nel codebase (solo
 * `range [*,*]` positivo, vedi albo_pretorio.php:18).
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_hold_employment_empty_query.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'hold_employment empty query spike',
    'use-session'    => false,
    'use-modules'    => true,
    'use-extensions' => true,
]);
$script->startup();
$script->initialize();

/**
 * Questo script crea e PUBBLICA (non solo bozza) contenuti reali di prova -
 * se eseguito per sbaglio contro un tenant reale invece di sito-comunale-dev,
 * crea unità organizzative finte visibili pubblicamente su una pagina di
 * trasparenza amministrativa fino alla pulizia a fine script (o per sempre,
 * se lo script termina prima di arrivarci). Si rifiuta di procedere se non
 * trova la fixture di sviluppo nota (id 226 = "Giunta comunale", già usata
 * da tests/test_has_role_webhook_payload.php) con quel nome esatto.
 */
$devFixture = eZContentObject::fetch(226);
if (!$devFixture instanceof eZContentObject || $devFixture->attribute('name') !== 'Giunta comunale') {
    fwrite(STDERR, "Fixture di sviluppo attesa (id 226 = \"Giunta comunale\") non trovata o non corrispondente - questo non sembra sito-comunale-dev, interrotto per sicurezza prima di creare/pubblicare qualunque contenuto.\n");
    exit(1);
}

$PASSED = 0;
$FAILED = 0;

function assert_true(bool $condition, string $label): void
{
    global $PASSED, $FAILED;
    if ($condition) { echo "\033[32m[PASS]\033[0m $label\n"; $PASSED++; }
    else            { echo "\033[31m[FAIL]\033[0m $label\n"; $FAILED++; }
}

$createdIds = [];

function createOrganization(string $legalName, ?int $holdEmploymentTargetId, array &$createdIds): eZContentObject
{
    $class = eZContentClass::fetchByIdentifier('organization');
    $contentObject = $class->instantiate(eZUser::currentUserID(), 2);
    $version = $contentObject->currentVersion();
    $dataMap = $version->attribute('data_map');

    $dataMap['legal_name']->fromString($legalName);
    $dataMap['legal_name']->store();

    if ($holdEmploymentTargetId !== null) {
        $dataMap['hold_employment']->fromString((string)$holdEmploymentTargetId);
        $dataMap['hold_employment']->store();
    }

    $contentObject->publish();
    $createdIds[] = (int)$contentObject->attribute('id');

    return eZContentObject::fetch((int)$contentObject->attribute('id'));
}

$vertice = createOrganization('Spike Vertice ' . time(), null, $createdIds);
$figlio = createOrganization('Spike Figlio ' . time(), (int)$vertice->attribute('id'), $createdIds);

// eZSolr::addObject non aspetta il cron: forziamo l'indicizzazione sincrona
// per questo test, altrimenti la query sotto vedrebbe un indice vuoto.
$solrIndexer = eZSearch::getEngine();
$solrIndexer->addObject($vertice, false);
$solrIndexer->addObject($figlio, false);
$solrIndexer->commit();

$queryBuilder = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
$query = "classes [organization] and raw[submeta_hold_employment___id____si] !range [*,*]";
$queryObject = $queryBuilder->instanceQuery($query);
$solr = new eZSolr();
$searchResult = $solr->search('', (array)$queryObject->convert());

$foundIds = [];
foreach ($searchResult['SearchResult'] as $resultNode) {
    $object = $resultNode->attribute('object');
    if ($object instanceof eZContentObject) {
        $foundIds[] = (int)$object->attribute('id');
    }
}

assert_true(
    in_array((int)$vertice->attribute('id'), $foundIds, true),
    'Il vertice (hold_employment vuoto) compare nel risultato di !range [*,*]'
);
assert_true(
    !in_array((int)$figlio->attribute('id'), $foundIds, true),
    'Il figlio (hold_employment valorizzato) NON compare nel risultato di !range [*,*]'
);

foreach ($createdIds as $id) {
    $object = eZContentObject::fetch($id);
    if ($object instanceof eZContentObject) {
        eZContentObject::removeObject($id, $object->attribute('published'));
    }
}

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
```

- [ ] **Step 2: Eseguire lo spike**

```bash
docker exec sito-comunale-dev-app-1 sh -c \
  'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_hold_employment_empty_query.php 2>&1); echo "$OUT"'
```

Atteso: `2 passed, 0 failed`.

- [ ] **Step 3: Decisione di go/no-go**

Se entrambi i PASS: procedere con Task 4 così pianificato. Se il primo PASS fallisce (il vertice non compare): l'indice Solr per `submeta_hold_employment___id____si` potrebbe non distinguere "campo mai valorizzato" da "campo non indicizzato per altri motivi" — fermarsi e verificare lo schema Solr (`schema.xml`/dynamic field per `submeta_*`) prima di proseguire, non indovinare una sintassi alternativa. Se il secondo PASS fallisce (il figlio compare comunque): l'operatore `!range` non sta negando correttamente — stesso stop, verificare `generateRangeFilter()` riga per riga prima di proseguire.

- [ ] **Step 4: Rimuovere lo script di spike (non è un test di regressione permanente)**

```bash
rm tests/test_art13_hold_employment_empty_query.php
git add tests/test_art13_hold_employment_empty_query.php
git commit -m "Rimuove script di spike dopo verifica operatore !range per hold_employment vuoto"
```

Annotare l'esito (PASS/FAIL e eventuali osservazioni) nel commit o in un commento del Task 4 prima di procedere.

---

### Task 2 — Spike: verificare il meccanismo di invalidazione cache per una pagina aggregata

**Perché prima di tutto**: la pagina "Articolazione degli uffici" aggrega dati di oggetti pubblicati altrove (`organization`, `time_indexed_role`). Ho letto `sito-comunale-dev/html/extension/ocfoshttpcache/classes/CacheListener.php` e trovato un disallineamento reale da verificare empiricamente prima di affidarcisi:

- `onContentPreRendering()` (riga 59-82) tagga ogni pagina renderizzata con `object-{id}`, `class-{id}`, `node-{id}`, `parent-{id}`, `path-{...}` di default — **e se il template imposta la variabile `response_tag_list`, quella SOSTITUISCE tutti i tag di default** (riga 73-75), non li somma.
- `onContentCache($nodeIdList)` (riga 39-57), chiamato alla pubblicazione, genera tag `node-{nodeId}` **solo se `hasStaticCache()` è falso** (riga 43-47) — cioè solo se `ContentSettings.StaticCache` NON è `enabled` con handler `Opencontent\FosHttpCache\StaticCache`. Se questa configurazione è attiva (verosimile in produzione, visto che l'estensione esiste apposta per questo), il tag list di partenza resta vuoto e viene popolato solo dal filtro `ocfoshttpcache/invalidate_tag_node_list` — su cui oggi **non c'è nessun listener registrato** (verificato: `grep` su `ezpEvent::getInstance()->attach` in `openpa`, `openpa_bootstrapitalia`, `ocwebhookserver` non trova nulla).

Conclusione architetturale (non un'ipotesi, una decisione di design per uscire dal problema): invece di inseguire tag `object-`/`node-` per-oggetto (fragile, dipende da quale branch di `hasStaticCache()` è attivo), usare **un tag fisso e condiviso** (es. `trasparenza-articolazione-uffici-{node_id_della_pagina}`) impostato via `response_tag_list` sulla pagina aggregata, e un **nuovo listener** sul filtro `ocfoshttpcache/invalidate_tag_node_list` che aggiunge quello stesso tag alla lista di invalidazione ogni volta che viene pubblicato/cancellato un `organization` o un `time_indexed_role`. Così l'invalidazione non dipende da quale branch di `hasStaticCache()` è attivo (il listener aggiunge sempre il tag, indipendentemente), e non richiede di enumerare quali oggetti specifici sono stati mostrati nell'ultimo render.

**Files:**
- Read: `sito-comunale-dev/html/extension/ocfoshttpcache/classes/CacheListener.php` (già letto, righe 39-82)
- Create: `tests/test_articolazione_uffici_cache_invalidation.php` (spike, da rimuovere a fine task come Task 1)

**Interfaces:**
- Consumes: `\ezpEvent::getInstance()->filter('ocfoshttpcache/invalidate_tag_node_list', $tagList, $nodeIdList)` (punto di aggancio già esistente, CacheListener.php:49).
- Produces: conferma che (a) `ContentSettings.StaticCache`/`StaticCacheHandler` hanno davvero il valore ipotizzato su `sito-comunale-dev`, (b) il meccanismo di registrazione di un listener `ezpEvent` funziona come documentato nel kernel eZ Publish Legacy, (c) un tag impostato via `response_tag_list` arriva davvero nell'header di risposta e viene davvero invalidato da `CacheInvalidator::instance()->invalidateTags(...)`.

- [ ] **Step 1: Verificare la configurazione reale di `ContentSettings.StaticCache` su `sito-comunale-dev`**

```bash
docker exec sito-comunale-dev-app-1 sh -c \
  'OUT=$(php -r '"'"'
require "autoload.php";
$script = eZScript::instance(["description" => "check static cache ini"]);
$script->startup(); $script->initialize();
$ini = eZINI::instance();
echo "StaticCache: " . $ini->variable("ContentSettings", "StaticCache") . "\n";
echo "StaticCacheHandler: " . $ini->variable("ContentSettings", "StaticCacheHandler") . "\n";
$script->shutdown();
'"'"' 2>&1); echo "$OUT"'
```

Annotare il risultato: determina quale branch di `onContentCache()` è davvero attivo su questo ambiente.

- [ ] **Step 2: Trovare la sintassi di registrazione di un listener `ezpEvent` nel kernel eZ Publish Legacy**

```bash
grep -rn "class ezpEvent" ezpublish-legacy/lib/ 2>/dev/null
grep -rn "function attach" ezpublish-legacy/lib/ezutils/classes/ezpevent*.php 2>/dev/null
grep -rln "ezpevents.ini" ezpublish-legacy/ --include="*.php" 2>/dev/null | head -5
```

Leggere il file trovato per ricavare la sintassi esatta (probabilmente un file `settings/ezpevents.ini.append.php` con una sezione che mappa `nome/evento` a una callable statica, pattern standard eZ Publish Legacy — verificarlo leggendo il codice, non assumerlo).

- [ ] **Step 3: Scrivere un listener di prova minimale e verificarne l'invocazione**

Creare in `openpa_bootstrapitalia/classes/CacheListenerTest.php` (temporaneo, da rimuovere a fine spike) una callable che scrive in un file di log quando viene invocata:

```php
<?php

class CacheListenerTest
{
    public static function onInvalidateTagNodeList($tagList, $nodeIdList)
    {
        file_put_contents('/tmp/cache_listener_spike.log', date('c') . ' nodeIdList=' . implode(',', $nodeIdList) . "\n", FILE_APPEND);

        return $tagList;
    }
}
```

Registrarlo seguendo esattamente la sintassi trovata allo Step 2 (non una sintassi plausibile — quella verificata nel kernel), poi pubblicare un oggetto qualsiasi dal backend e controllare:

```bash
docker exec sito-comunale-dev-app-1 cat /tmp/cache_listener_spike.log
```

- [ ] **Step 4: Decisione di go/no-go e pulizia**

Se il log si popola alla pubblicazione: il meccanismo di registrazione funziona, procedere con Task 7 usando la stessa sintassi. Se non si popola: il filtro potrebbe richiedere una registrazione diversa (es. via `ezpevents.ini` invece che PHP, o un nome di evento diverso da quello letto nel codice) — fermarsi e leggere `kernel/classes/content/ezcontentoperationcollection.php` per trovare dove/come viene effettivamente chiamato `onContentCache()` prima di procedere.

```bash
rm /Volumes/Repos/sviluppo-sito-comunale/openpa_bootstrapitalia/classes/CacheListenerTest.php
rm /tmp/cache_listener_spike.log
docker exec sito-comunale-dev-app-1 rm -f /tmp/cache_listener_spike.log
git add -A
git commit -m "Rimuove listener di spike dopo verifica meccanismo di invalidazione cache"
```

---

### Task 3 — Refactor `fetchOrganizzazioniByTagPath()`: da scan PHP a query Solr

**Files:**
- Modify: `classes/anac/Serializer/Art13Serializer.php:252-272` (metodo `fetchOrganizzazioniByTagPath`), righe 39-53 (aggiungere costante), righe 102, 128 (aggiornare chiamanti)
- Test: `tests/test_art13_fetch_organizzazioni_by_tag_id.php`

**Interfaces:**
- Consumes: `Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder`, `eZSolr` (stesso pattern di `fetchFigliDiOrgano()`, righe 289-311 dello stesso file).
- Produces: `fetchOrganizzazioniByTagPath(int $tagId): \eZContentObject[]` — stessa firma di ritorno di oggi (array di `eZContentObject`), **cambia il tipo del parametro da `string $tagPath` a `int $tagId`** — i due chiamanti (righe 102 e 128) vanno aggiornati di conseguenza.

- [ ] **Step 1: Aggiungere la costante mancante accanto a `TAG_ID_STRUTTURA_AMMINISTRATIVA`**

In `classes/anac/Serializer/Art13Serializer.php`, dopo la riga 53 (`const TAG_ID_STRUTTURA_AMMINISTRATIVA = 1278;`):

```php
    /**
     * Id numerico del tag "Struttura politica" (tagtree_csv/organizzazione.csv),
     * stesso principio di TAG_ID_STRUTTURA_AMMINISTRATIVA: basta l'id della
     * radice per includere ogni discendente (Sindaco, Giunta, Assessorati,
     * Consiglio, Commissioni, ecc.) via subattr_type___tag_ids____si.
     */
    const TAG_ID_STRUTTURA_POLITICA = 1266;
```

- [ ] **Step 2: Scrivere il test che deve fallire con l'implementazione attuale**

```php
<?php
/**
 * Verifica che fetchOrganizzazioniByTagPath() accetti un tag id numerico e
 * trovi via Solr gli organization taggati in quel ramo - sostituendo lo scan
 * PHP completo della classe (eZContentObject::fetchSameClassList) con la
 * stessa tecnica di query Solr già usata da fetchFigliDiOrgano().
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_fetch_organizzazioni_by_tag_id.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'fetchOrganizzazioniByTagPath by tag id test',
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

// "Giunta comunale" esiste già come fixture di sviluppo (id 226, usata anche
// da tests/test_has_role_webhook_payload.php) - taggata "Giunta comunale",
// discendente di "Struttura politica" (id tag 1266).
$giuntaComunale = eZContentObject::fetch(226);
assert_true($giuntaComunale instanceof eZContentObject, 'Fixture "Giunta comunale" (id 226) esiste in questo ambiente');

$solrIndexer = eZSearch::getEngine();
$solrIndexer->addObject($giuntaComunale, false);
$solrIndexer->commit();

$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer();
$reflection = new ReflectionMethod($serializer, 'fetchOrganizzazioniByTagPath');
$reflection->setAccessible(true);
$result = $reflection->invoke($serializer, \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::TAG_ID_STRUTTURA_POLITICA);

$foundIds = array_map(function ($object) { return (int)$object->attribute('id'); }, $result);
assert_true(
    in_array(226, $foundIds, true),
    'fetchOrganizzazioniByTagPath(TAG_ID_STRUTTURA_POLITICA) trova "Giunta comunale" via Solr'
);

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
```

- [ ] **Step 3: Eseguire il test, verificare che fallisca**

```bash
docker exec sito-comunale-dev-app-1 sh -c \
  'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_fetch_organizzazioni_by_tag_id.php 2>&1); echo "$OUT"'
```

Atteso: fallimento con `TypeError` (il metodo attuale accetta una stringa path, non un int) o comunque un FAIL sul secondo assert, perché l'implementazione attuale fa `tagMatchesPath($dataMap['type'], $tagPath)` confrontando `path_string`, non un id.

- [ ] **Step 4: Riscrivere `fetchOrganizzazioniByTagPath()` per usare Solr**

Sostituire il corpo del metodo (righe 252-272) con:

```php
    /**
     * @param int $tagId id numerico della radice del ramo tassonomico
     *        (TAG_ID_STRUTTURA_POLITICA o TAG_ID_STRUTTURA_AMMINISTRATIVA)
     * @return \eZContentObject[]
     *
     * Query Solr diretta (stesso pattern di fetchFigliDiOrgano() sotto):
     * subattr_type___tag_ids____si contiene l'id del tag assegnato più tutti
     * i suoi antenati, quindi cercare l'id della radice include qualunque
     * discendente - sostituisce lo scan PHP completo della classe
     * organization che faceva prima questa funzione.
     */
    private function fetchOrganizzazioniByTagPath($tagId)
    {
        $result = [];

        $query = 'classes [organization] and raw[subattr_type___tag_ids____si] in [' . (int)$tagId . ']';

        $queryBuilder = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
        $queryObject = $queryBuilder->instanceQuery($query);

        $solr = new \eZSolr();
        $searchResult = $solr->search('', (array)$queryObject->convert());

        foreach ($searchResult['SearchResult'] as $resultNode) {
            $object = $resultNode->attribute('object');
            if ($object instanceof \eZContentObject) {
                $result[] = $object;
            }
        }

        return $result;
    }
```

Rimuovere il metodo `tagMatchesPath()` (righe 323-338) se non più usato da nessun altro chiamante nel file (verificare con `grep -n tagMatchesPath classes/anac/Serializer/Art13Serializer.php` prima di cancellarlo).

- [ ] **Step 5: Aggiornare i due chiamanti**

Riga 102 (`fetchOrganiConUffici()`), da:
```php
        foreach ($this->fetchOrganizzazioniByTagPath(self::TAG_PATH_STRUTTURA_POLITICA) as $organoObject) {
```
a:
```php
        foreach ($this->fetchOrganizzazioniByTagPath(self::TAG_ID_STRUTTURA_POLITICA) as $organoObject) {
```

Riga 128 (`fetchOrganiAmministrativi()`), da:
```php
        foreach ($this->fetchOrganizzazioniByTagPath(self::TAG_PATH_STRUTTURA_AMMINISTRATIVA) as $candidato) {
```
a:
```php
        foreach ($this->fetchOrganizzazioniByTagPath(self::TAG_ID_STRUTTURA_AMMINISTRATIVA) as $candidato) {
```

- [ ] **Step 6: Eseguire di nuovo il test, verificare che passi**

```bash
docker exec sito-comunale-dev-app-1 sh -c \
  'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_fetch_organizzazioni_by_tag_id.php 2>&1); echo "$OUT"'
```

Atteso: `2 passed, 0 failed`.

- [ ] **Step 7: Eseguire anche i test esistenti che toccano Art13Serializer per verificare nessuna regressione**

```bash
docker exec sito-comunale-dev-app-1 sh -c \
  'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_has_role_webhook_payload.php 2>&1); echo "$OUT"'
```

- [ ] **Step 8: Commit**

```bash
git add classes/anac/Serializer/Art13Serializer.php tests/test_art13_fetch_organizzazioni_by_tag_id.php
git commit -m "Sostituisce lo scan PHP di fetchOrganizzazioniByTagPath con una query Solr diretta"
```

---

### Task 4 — Refactor del rilevamento vertice in `fetchOrganiAmministrativi()`

**Dipende da**: Task 1 (go/no-go sull'operatore `!range`) e Task 3 (nuova firma di `fetchOrganizzazioniByTagPath`).

**Files:**
- Modify: `classes/anac/Serializer/Art13Serializer.php:125-163` (metodo `fetchOrganiAmministrativi` e `isTaggedArea`)
- Test: `tests/test_art13_fetch_organi_amministrativi_vertice.php`

**Interfaces:**
- Consumes: operatore `!range` confermato funzionante da Task 1.
- Produces: `fetchOrganiAmministrativi()` con la stessa firma e stesso valore di ritorno di oggi — cambia solo come trova i candidati vertice (una query Solr invece di scan + due controlli PHP separati).

- [ ] **Step 1: Scrivere il test (stato attuale, deve già passare — è un test di non-regressione, non TDD puro qui perché il comportamento esterno non cambia)**

```php
<?php
/**
 * Verifica che fetchOrganiAmministrativi() trovi come vertice SOLO gli
 * organization taggati esattamente "Area" con hold_employment vuoto -
 * stesso comportamento di oggi, ma dopo aver spostato il controllo da PHP
 * (isTaggedArea + empty($holdEmployment)) a una singola query Solr.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_fetch_organi_amministrativi_vertice.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'fetchOrganiAmministrativi vertice test',
    'use-session'    => false,
    'use-modules'    => true,
    'use-extensions' => true,
]);
$script->startup();
$script->initialize();

/**
 * Stessa guardia di tests/test_art13_hold_employment_empty_query.php (Task
 * 1): questo script crea e pubblica 3 organization reali - si rifiuta di
 * procedere fuori da un ambiente che ha la fixture di sviluppo nota.
 */
$devFixture = eZContentObject::fetch(226);
if (!$devFixture instanceof eZContentObject || $devFixture->attribute('name') !== 'Giunta comunale') {
    fwrite(STDERR, "Fixture di sviluppo attesa (id 226 = \"Giunta comunale\") non trovata o non corrispondente - questo non sembra sito-comunale-dev, interrotto per sicurezza prima di creare/pubblicare qualunque contenuto.\n");
    exit(1);
}

$PASSED = 0;
$FAILED = 0;

function assert_true(bool $condition, string $label): void
{
    global $PASSED, $FAILED;
    if ($condition) { echo "\033[32m[PASS]\033[0m $label\n"; $PASSED++; }
    else            { echo "\033[31m[FAIL]\033[0m $label\n"; $FAILED++; }
}

$createdIds = [];

function createOrganization(string $legalName, string $typeKeyword, ?int $holdEmploymentTargetId, array &$createdIds): eZContentObject
{
    $class = eZContentClass::fetchByIdentifier('organization');
    $contentObject = $class->instantiate(eZUser::currentUserID(), 2);
    $version = $contentObject->currentVersion();
    $dataMap = $version->attribute('data_map');

    $dataMap['legal_name']->fromString($legalName);
    $dataMap['legal_name']->store();

    $tagObject = eZTagsObject::fetchByKeyword($typeKeyword);
    $dataMap['type']->fromString((string)$tagObject->attribute('id'));
    $dataMap['type']->store();

    if ($holdEmploymentTargetId !== null) {
        $dataMap['hold_employment']->fromString((string)$holdEmploymentTargetId);
        $dataMap['hold_employment']->store();
    }

    $contentObject->publish();
    $createdIds[] = (int)$contentObject->attribute('id');

    return eZContentObject::fetch((int)$contentObject->attribute('id'));
}

$vertice = createOrganization('Spike Area Vertice ' . time(), 'Area', null, $createdIds);
$direzione = createOrganization('Spike Direzione ' . time(), 'Area', (int)$vertice->attribute('id'), $createdIds);
$ufficioOrfano = createOrganization('Spike Ufficio Orfano ' . time(), 'Ufficio', null, $createdIds);

$solrIndexer = eZSearch::getEngine();
foreach ([$vertice, $direzione, $ufficioOrfano] as $object) {
    $solrIndexer->addObject($object, false);
}
$solrIndexer->commit();

$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer();
$organi = $serializer->fetchOrganiAmministrativi();
$denominazioni = array_map(function ($organo) { return $organo['denominazione']; }, $organi);

assert_true(
    in_array($vertice->attribute('name'), $denominazioni, true),
    'L\'Area con hold_employment vuoto compare come organo di vertice'
);
assert_true(
    !in_array($direzione->attribute('name'), $denominazioni, true),
    'L\'Area con hold_employment valorizzato NON compare come organo di vertice (è una Direzione, non un vertice)'
);
assert_true(
    !in_array($ufficioOrfano->attribute('name'), $denominazioni, true),
    'Un Ufficio con hold_employment vuoto NON compare come organo di vertice (tag "Area" richiesto, non "Ufficio")'
);

foreach ($createdIds as $id) {
    $object = eZContentObject::fetch($id);
    if ($object instanceof eZContentObject) {
        eZContentObject::removeObject($id, $object->attribute('published'));
    }
}

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
```

- [ ] **Step 2: Eseguire il test contro l'implementazione ATTUALE (prima di modificarla), verificare che passi già**

```bash
docker exec sito-comunale-dev-app-1 sh -c \
  'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_fetch_organi_amministrativi_vertice.php 2>&1); echo "$OUT"'
```

Atteso: `3 passed, 0 failed` — questo fissa il comportamento di riferimento prima del refactor, così un eventuale FAIL dopo lo Step 4 indica una regressione introdotta dal refactor stesso, non un comportamento già rotto.

- [ ] **Step 3: Riscrivere `fetchOrganiAmministrativi()` (righe 125-147) e rimuovere `isTaggedArea()` (righe 149-163)**

```php
    public function fetchOrganiAmministrativi()
    {
        $organi = [];
        foreach ($this->fetchVerticeAmministrativi() as $candidato) {
            $dataMap = $candidato->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);

            $organi[] = [
                'denominazione' => $candidato->attribute('name'),
                'competenze' => $this->plainText($dataMap['main_function']),
                'uffici' => $this->fetchUfficiFigli($candidato),
            ];
        }

        return $organi;
    }

    /**
     * @return \eZContentObject[] organization taggati ESATTAMENTE "Area" (non
     *         una foglia diversa, non il tag radice) E con hold_employment
     *         vuoto - stessa doppia condizione di prima (vedi commento
     *         storico su fetchOrganiAmministrativi() prima di questo
     *         refactor: il solo tag "Area" prenderebbe anche le Direzioni,
     *         che sono taggate Area ma hanno hold_employment valorizzato;
     *         il solo hold_employment vuoto prenderebbe anche uffici orfani
     *         o oggetti che riusano la classe per altro), ora espressa come
     *         un'unica query Solr invece di scan + due controlli PHP.
     */
    private function fetchVerticeAmministrativi()
    {
        $result = [];

        $query = 'classes [organization]'
            . ' and type in [\'"Area"\']'
            . ' and raw[submeta_hold_employment___id____si] !range [*,*]';

        $queryBuilder = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
        $queryObject = $queryBuilder->instanceQuery($query);

        $solr = new \eZSolr();
        $searchResult = $solr->search('', (array)$queryObject->convert());

        foreach ($searchResult['SearchResult'] as $resultNode) {
            $object = $resultNode->attribute('object');
            if ($object instanceof \eZContentObject) {
                $result[] = $object;
            }
        }

        return $result;
    }
```

Verificare con `grep -n isTaggedArea classes/anac/Serializer/Art13Serializer.php` che non resti nessun altro chiamante prima di rimuovere definitivamente il vecchio metodo.

- [ ] **Step 4: Eseguire di nuovo il test, confermare che passi ancora (nessuna regressione)**

```bash
docker exec sito-comunale-dev-app-1 sh -c \
  'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_fetch_organi_amministrativi_vertice.php 2>&1); echo "$OUT"'
```

Atteso: `3 passed, 0 failed`, identico allo Step 2.

- [ ] **Step 5: Commit**

```bash
git add classes/anac/Serializer/Art13Serializer.php tests/test_art13_fetch_organi_amministrativi_vertice.php
git commit -m "Sposta il rilevamento del vertice amministrativo da PHP a una singola query Solr"
```

---

### Task 5 — Service di presentazione per il rendering HTML

**Dipende da**: Task 3, Task 4.

**Files:**
- Create: `classes/anac/PageArticolazioneUfficiProvider.php`
- Test: `tests/test_page_articolazione_uffici_provider.php`

**Interfaces:**
- Consumes: `Art13Serializer::fetchOrganiConUffici()`, `fetchOrganiAmministrativi()` (nessuna modifica di firma da Task 3/4).
- Produces:
  - `PageArticolazioneUfficiProvider::getOrganiPolitici(): array` — stesso formato di ritorno di `fetchOrganiConUffici()`.
  - `PageArticolazioneUfficiProvider::getOrganiAmministrativi(): array` — stesso formato di ritorno di `fetchOrganiAmministrativi()`.
  - `PageArticolazioneUfficiProvider::getOrganiPoliticiRowsJson(): string` — righe appiattite organo+ufficio (una riga per ufficio, stessa logica di `Art13Serializer::toCsvOrganiUffici()` ma senza passare dal CSV) pronte per DataTables lato client, già codificate in JSON HTML-safe.
  - `PageArticolazioneUfficiProvider::getOrganiAmministrativiRowsJson(): string` — come sopra, con in più la colonna `tipologia`.
  - `PageArticolazioneUfficiProvider::getCacheTag(\eZContentObjectTreeNode $pageNode): string` — restituisce il tag fisso da usare sia nel `response_tag_list` del Task 6 sia nel listener del Task 7 (`'trasparenza-articolazione-uffici-' . $pageNode->attribute('node_id')`), così le due parti non possono disallinearsi su due stringhe scritte a mano in due punti diversi.

**Nota di sicurezza che guida il design di questo task**: `denominazione`/`competenze`/`nominativo` sono testo a cura di redattori CMS (campi `ezstring`/`ezxmltext`), non input anonimo di cittadini — ma vengono comunque incorporati in pagina dentro un blocco `<script>` come JSON (Task 6), non mostrati tramite un normale output HTML con escaping automatico del template engine. Un valore che contenga letteralmente la stringa `</script>` (anche non malevolo, es. un redattore che incolla testo con quel frammento) chiuderebbe il tag prematuramente e inietterebbe JavaScript arbitrario nella pagina. Per questo `getOrganiPoliticiRowsJson()`/`getOrganiAmministrativiRowsJson()` restituiscono già la stringa JSON pronta per l'incorporamento sicuro (vedi Step 3) — il template non deve mai fare un `json_encode`/dump manuale dei dati grezzi.

- [ ] **Step 1: Scrivere il test**

```php
<?php
/**
 * Verifica che PageArticolazioneUfficiProvider esponga i dati di
 * Art13Serializer senza modificarli, e che getCacheTag() produca un tag
 * deterministico basato sul node_id della pagina (stessa stringa che userà
 * sia il template sia il listener di invalidazione - un'unica fonte di
 * verità per il nome del tag).
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_page_articolazione_uffici_provider.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'PageArticolazioneUfficiProvider test',
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

$provider = new \OpenPABootstrapItalia\Anac\PageArticolazioneUfficiProvider();

$organiPolitici = $provider->getOrganiPolitici();
assert_true(is_array($organiPolitici), 'getOrganiPolitici() restituisce un array');

$organiAmministrativi = $provider->getOrganiAmministrativi();
assert_true(is_array($organiAmministrativi), 'getOrganiAmministrativi() restituisce un array');

$fakeNode = eZContentObjectTreeNode::fetch(2); // Home, nodo noto in ogni ambiente di sviluppo
assert_eq(
    $provider->getCacheTag($fakeNode),
    'trasparenza-articolazione-uffici-2',
    'getCacheTag() produce un tag deterministico basato sul node_id'
);

// Riga di prova con un payload pensato per rompere un embedding JSON ingenuo
// in un blocco <script> - deve restituire una stringa JSON valida che NON
// contenga la sequenza letterale "</script" (altrimenti il browser
// chiuderebbe il tag a metà e inietterebbe il resto come markup/script).
$maliciousRows = [[
    'organo' => 'Test</script><script>window.xssFired=true;</script>',
    'competenzeOrgano' => '',
    'denominazione' => 'Ufficio "virgolette" & commerciale',
    'competenze' => '',
    'nominativo' => '',
    'telefono' => '',
    'email' => '',
]];
$reflection = new ReflectionMethod($provider, 'toSafeJson');
$reflection->setAccessible(true);
$json = $reflection->invoke($provider, $maliciousRows);

assert_true(
    strpos($json, '</script') === false,
    'toSafeJson() non produce mai la sequenza letterale "</script" nel suo output'
);
$decoded = json_decode($json, true);
assert_true(
    json_last_error() === JSON_ERROR_NONE && is_array($decoded),
    'toSafeJson() produce comunque JSON valido e decodificabile'
);
assert_eq(
    $decoded[0]['organo'],
    'Test</script><script>window.xssFired=true;</script>',
    'Il valore decodificato è identico all\'originale (solo l\'incapsulamento cambia, non il dato)'
);

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
```

- [ ] **Step 2: Eseguire il test, verificare che fallisca (la classe non esiste ancora)**

```bash
docker exec sito-comunale-dev-app-1 sh -c \
  'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_page_articolazione_uffici_provider.php 2>&1); echo "$OUT"'
```

Atteso: errore fatale `Class "OpenPABootstrapItalia\Anac\PageArticolazioneUfficiProvider" not found`.

- [ ] **Step 3: Implementare la classe**

```php
<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Espone a template/view i metodi di raccolta dati di Art13Serializer senza
 * passare dal formato CSV/JSON - stessa fonte dell'export, presentazione
 * diversa (HTML invece di file). Nessuna logica di business qui: questa
 * classe non decide COSA mostrare, solo COME renderlo disponibile a un
 * template eZ Publish e come nominare il tag di cache condiviso con il
 * listener di invalidazione (Task 7) - un'unica fonte di verità per quella
 * stringa, per evitare che template e listener la scrivano due volte a mano
 * e finiscano per disallinearsi.
 */
class PageArticolazioneUfficiProvider
{
    private $serializer;

    public function __construct(Serializer\Art13Serializer $serializer = null)
    {
        $this->serializer = $serializer ?: new Serializer\Art13Serializer();
    }

    public function getOrganiPolitici()
    {
        return $this->serializer->fetchOrganiConUffici();
    }

    public function getOrganiAmministrativi()
    {
        return $this->serializer->fetchOrganiAmministrativi();
    }

    /**
     * @return string JSON di righe {organo, competenzeOrgano, denominazione,
     *         competenze, nominativo, telefono, email} - una riga per
     *         ufficio, stesso appiattimento organo->uffici già fatto da
     *         Art13Serializer::toCsvOrganiUffici() ma qui per DataTables lato
     *         client invece che per un file CSV. Un organo senza uffici non
     *         produce nessuna riga - stesso comportamento del CSV (vedi
     *         discussione con Marco: accettato così per ora).
     */
    public function getOrganiPoliticiRowsJson()
    {
        return $this->toSafeJson($this->flattenRows($this->getOrganiPolitici(), false));
    }

    /**
     * Come sopra, con in più la colonna `tipologia` (Ufficio dirigenziale /
     * non dirigenziale) - presente nei dati di fetchOrganiAmministrativi()
     * ma non in quelli di fetchOrganiConUffici() per com'è oggi
     * Art13Serializer (entrambi i metodi restituiscono comunque sempre la
     * chiave 'tipologia' per ogni ufficio, qui la esponiamo solo per la
     * tabella amministrativi per non aggiungere una colonna sempre vuota
     * alla tabella organi politici).
     */
    public function getOrganiAmministrativiRowsJson()
    {
        return $this->toSafeJson($this->flattenRows($this->getOrganiAmministrativi(), true));
    }

    private function flattenRows(array $organi, $includeTipologia)
    {
        $rows = [];
        foreach ($organi as $organo) {
            foreach ($organo['uffici'] as $ufficio) {
                $row = [
                    'organo' => $organo['denominazione'],
                    'competenzeOrgano' => $organo['competenze'],
                    'denominazione' => $ufficio['denominazione'],
                    'competenze' => $ufficio['competenze'],
                    'nominativo' => $ufficio['nominativo'],
                    'telefono' => $ufficio['contatti']['recapitoTelefonico'] ?? '',
                    'email' => $ufficio['contatti']['postaElettronicaOrdinaria'] ?? '',
                ];
                if ($includeTipologia) {
                    $row['tipologia'] = $ufficio['tipologia'];
                }
                $rows[] = $row;
            }
        }

        return $rows;
    }

    /**
     * JSON_HEX_TAG converte `<`/`>` in `<`/`>`, quindi la sequenza
     * letterale "</script" non può mai comparire nell'output, qualunque sia
     * il contenuto del campo (vedi nota di sicurezza nelle Interfaces di
     * questo task) - JSON_HEX_AMP/APOS/QUOT per lo stesso motivo su
     * `&`/`'`/`"`, che potrebbero altrimenti rompere l'attributo HTML se
     * questo JSON finisse mai incorporato anche lì invece che solo in un
     * blocco <script>.
     */
    private function toSafeJson(array $rows)
    {
        return json_encode(
            $rows,
            JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_UNICODE
        );
    }

    public function getCacheTag(\eZContentObjectTreeNode $pageNode)
    {
        return 'trasparenza-articolazione-uffici-' . $pageNode->attribute('node_id');
    }
}
```

- [ ] **Step 4: Eseguire di nuovo il test, verificare che passi**

```bash
docker exec sito-comunale-dev-app-1 sh -c \
  'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_page_articolazione_uffici_provider.php 2>&1); echo "$OUT"'
```

Atteso: `3 passed, 0 failed`.

- [ ] **Step 5: Commit**

```bash
git add classes/anac/PageArticolazioneUfficiProvider.php tests/test_page_articolazione_uffici_provider.php
git commit -m "Aggiunge service di presentazione per il rendering live di Organi politici/amministrativi"
```

---

### Task 6 — Template: tabelle DataTables lato client, gated su `schema_pubblicazione`

**Dipende da**: Task 5. Verifica solo manuale (curl/browser), coerente con la Tech Stack di questo piano.

**Decisione di design** (dopo discussione con Marco): non una tabella HTML statica, ma la libreria **jQuery DataTables reale** (ricerca, ordinamento, paginazione), inizializzata in modalità client-side (`serverSide: false`, dati già in memoria) invece che nella modalità AJAX usata oggi da `opendataDataTable`/`children_table_fields.tpl`. Verificato che `jquery.opendataDataTable.js` è solo un involucro sottile che alla fine chiama `table.DataTable(this.settings.datatable)` — la libreria DataTables standard è quindi già disponibile e già caricata **su ogni pagina, non solo quando è presente una tabella `fields`** (confermato: `dataTables.min.js` è incluso in `design/bootstrapitalia2/templates/page_head_script.tpl`/`pagelayout.tpl`, non dentro un `{if $trasparenza.has_table_fields}`). Non serve quindi aggiungere nessun nuovo asset JS/CSS.

A differenza dell'involucro esistente, qui non serve la funzione `opendataDataTableRenderField()` (pensata per valori-attributo eZ grezzi tipo `ezmatrix`/`ezauthor`/`file`): i dati di `PageArticolazioneUfficiProvider` sono già stringhe semplici (`Art13Serializer` li ha già appiattiti e, per `competenze`, già passati da `plainText()` che rimuove i tag HTML) — bastano colonne DataTables semplici (`{ data: 'nomeCampo' }`).

**Files:**
- Modify: `design/bootstrapitalia2/templates/openpa/full/pagina_trasparenza.tpl:203-210` (blocco `{if $trasparenza.has_table_fields}`)
- Create: `design/bootstrapitalia2/templates/openpa/full/parts/amministrazione_trasparente/organi_uffici_live.tpl`
- Modify: `classes/services/content_trasparenza.php` (aggiungere un nuovo dato esposto al template, seguendo il pattern `$this->fnData[...]` già usato nel file)

**Interfaces:**
- Consumes: `PageArticolazioneUfficiProvider::getOrganiPoliticiRowsJson()`, `getOrganiAmministrativiRowsJson()` (Task 5, già JSON HTML-safe), `SchemaPubblicazioneLookup::schemasForObject($object)` (già esistente, `classes/SchemaPubblicazioneLookup.php`).
- Produces: variabile template `$trasparenza.organi_uffici_live` — array con chiavi `organi_politici_rows_json`, `organi_amministrativi_rows_json` (stringhe JSON già pronte, o `null` se la pagina non espone quella sezione), `cache_tag`, oppure `false` se la pagina corrente non è bindata né a `art.13-op` né a `art.13-oa`.

- [ ] **Step 1: Esporre il dato nel service esistente**

In `classes/services/content_trasparenza.php`, nel metodo `run()` (righe 22-52), aggiungere accanto alle righe 39-41 (`has_table_fields`/`table_fields_attribute`/`table_fields`):

```php
        $this->fnData['organi_uffici_live'] = 'getOrganiUfficiLive';
```

Poi aggiungere il metodo (accanto a `getTableFieldsParameters()`, dopo la riga 430):

```php
    protected function getOrganiUfficiLive()
    {
        if (!$this->isPaginaTrasparenza() || !$this->container->hasContentObject()) {
            return false;
        }

        $schemas = \SchemaPubblicazioneLookup::schemasForObject($this->container->getContentObject());
        $isOp = in_array(\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OP, $schemas, true);
        $isOa = in_array(\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OA, $schemas, true);

        if (!$isOp && !$isOa) {
            return false;
        }

        $provider = new \OpenPABootstrapItalia\Anac\PageArticolazioneUfficiProvider();

        return [
            'organi_politici_rows_json' => $isOp ? $provider->getOrganiPoliticiRowsJson() : null,
            'organi_amministrativi_rows_json' => $isOa ? $provider->getOrganiAmministrativiRowsJson() : null,
            'cache_tag' => $provider->getCacheTag($this->getNode()),
        ];
    }
```

Nota: `getNode()` è un metodo privato già esistente nello stesso file (righe 54-60) — riusarlo, non duplicarne la logica.

- [ ] **Step 2: Creare il partial di template**

Il JSON va dentro un blocco `<script type="application/json">` separato dal blocco `<script>` di inizializzazione — il parser HTML non esegue mai il contenuto di un tag con quel `type`, e il codice di inizializzazione (sotto) non interpola mai dati non fidati al suo interno: legge il JSON dal DOM via `JSON.parse()`, non da una stringa costruita lato server dentro al JS. Anche con `toSafeJson()` già HTML-safe (Task 5), questa separazione è una seconda rete di sicurezza — nessun dato arriva mai dentro codice JavaScript eseguibile, solo dentro un blocco dati inerte.

```smarty
{def $current_language = ezini('RegionalSettings', 'Locale')}

{if $organi_uffici_live.organi_politici_rows_json !== null}
<section class="mt-5">
    <h3 class="h4">{'Organi di indirizzo politico'|i18n('bootstrapitalia/anac_export')}</h3>
    <script type="application/json" id="organi-politici-rows-data">{$organi_uffici_live.organi_politici_rows_json}</script>
    <table id="organi-politici-table" class="table table-striped display responsive no-wrap" style="width:100%">
        <thead>
            <tr>
                <th>{'Body'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Body competencies'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Office'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Office competencies'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Manager'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Phone'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Email'|i18n('bootstrapitalia/anac_export')}</th>
            </tr>
        </thead>
    </table>
</section>
{/if}

{if $organi_uffici_live.organi_amministrativi_rows_json !== null}
<section class="mt-5">
    <h3 class="h4">{'Organi amministrativi'|i18n('bootstrapitalia/anac_export')}</h3>
    <script type="application/json" id="organi-amministrativi-rows-data">{$organi_uffici_live.organi_amministrativi_rows_json}</script>
    <table id="organi-amministrativi-table" class="table table-striped display responsive no-wrap" style="width:100%">
        <thead>
            <tr>
                <th>{'Body'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Body competencies'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Office'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Type'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Office competencies'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Manager'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Phone'|i18n('bootstrapitalia/anac_export')}</th>
                <th>{'Email'|i18n('bootstrapitalia/anac_export')}</th>
            </tr>
        </thead>
    </table>
</section>
{/if}

{if or($organi_uffici_live.organi_politici_rows_json !== null, $organi_uffici_live.organi_amministrativi_rows_json !== null)}
<script type="text/javascript" language="javascript" class="init">
$(document).ready(function () {ldelim}
    function readEmbeddedRows(elementId) {ldelim}
        var el = document.getElementById(elementId);
        if (!el) {ldelim} return []; {rdelim}
        try {ldelim}
            return JSON.parse(el.textContent);
        {rdelim} catch (e) {ldelim}
            return [];
        {rdelim}
    {rdelim}

    var datatableLanguageUrl = "{concat('javascript/datatable/',$current_language,'.json')|ezdesign(no)}";

    {if $organi_uffici_live.organi_politici_rows_json !== null}
    $('#organi-politici-table').DataTable({ldelim}
        data: readEmbeddedRows('organi-politici-rows-data'),
        serverSide: false,
        responsive: true,
        language: {ldelim} url: datatableLanguageUrl {rdelim},
        columns: [
            {ldelim} data: 'organo' {rdelim},
            {ldelim} data: 'competenzeOrgano' {rdelim},
            {ldelim} data: 'denominazione' {rdelim},
            {ldelim} data: 'competenze' {rdelim},
            {ldelim} data: 'nominativo' {rdelim},
            {ldelim} data: 'telefono' {rdelim},
            {ldelim} data: 'email' {rdelim}
        ]
    {rdelim});
    {/if}

    {if $organi_uffici_live.organi_amministrativi_rows_json !== null}
    $('#organi-amministrativi-table').DataTable({ldelim}
        data: readEmbeddedRows('organi-amministrativi-rows-data'),
        serverSide: false,
        responsive: true,
        language: {ldelim} url: datatableLanguageUrl {rdelim},
        columns: [
            {ldelim} data: 'organo' {rdelim},
            {ldelim} data: 'competenzeOrgano' {rdelim},
            {ldelim} data: 'denominazione' {rdelim},
            {ldelim} data: 'tipologia' {rdelim},
            {ldelim} data: 'competenze' {rdelim},
            {ldelim} data: 'nominativo' {rdelim},
            {ldelim} data: 'telefono' {rdelim},
            {ldelim} data: 'email' {rdelim}
        ]
    {rdelim});
    {/if}
{rdelim});
</script>
{/if}
```

Lo stato vuoto ("zero organi trovati", vedi Review Focus) non richiede un `{if count(...)}` manuale come in una tabella statica: DataTables mostra già di suo il messaggio "Nessun dato disponibile" quando `data` è un array vuoto, localizzato dallo stesso file `language.url` già usato dal meccanismo esistente — un organo senza uffici (il caso comune per gli organi politici, vedi discussione precedente) produce zero righe e DataTables lo rende correttamente da solo.

- [ ] **Step 3: Includere il partial in `pagina_trasparenza.tpl`**

Dopo la riga 210 (chiusura del blocco `{if $trasparenza.has_table_fields}` esistente, che resta invariato per la tabella "Telefono e contatti" — fuori scopo di questo piano), aggiungere:

```smarty
{if $trasparenza.organi_uffici_live}
    {include uri='design:openpa/full/parts/amministrazione_trasparente/organi_uffici_live.tpl'
             organi_uffici_live = $trasparenza.organi_uffici_live}
{/if}
```

- [ ] **Step 4: Verifica manuale su `sito-comunale-dev` — funzionale**

```bash
# 1. Trovare il node_id di una pagina pagina_trasparenza bindata ad art.13-op o art.13-oa
docker exec sito-comunale-dev-postgres-1 psql -U openpa -d opencity -c "
SELECT o.id, o.name, n.node_id
FROM ezcontentobject o
JOIN ezcontentobject_tree n ON n.contentobject_id = o.id AND n.is_main_node = 1
JOIN ezcontentclass c ON c.id = o.contentclass_id
WHERE c.identifier = 'pagina_trasparenza'
  AND o.name ILIKE '%uffici%';
"

# 2. Caricare la pagina e verificare che compaiano le due nuove sezioni, con il JSON incorporato
curl -s https://opencity.localtest.me/content/view/full/<node_id> | grep -A3 "organi-politici-rows-data"
curl -s https://opencity.localtest.me/content/view/full/<node_id> | grep -A3 "organi-amministrativi-rows-data"
```

Atteso: entrambe le sezioni compaiono, con un blocco `<script type="application/json">` popolato (anche solo `[]` se non ci sono dati) e nessun errore PHP in pagina/log.

```bash
docker exec sito-comunale-dev-app-1 sh -c 'OUT=$(tail -50 /var/log/php_errors.log 2>&1 || tail -50 var/log/*.log 2>&1); echo "$OUT"'
```

- [ ] **Step 5: Verifica manuale — interattività DataTables nel browser**

Aprire la pagina in un browser reale (non solo curl, qui serve il JS):
1. Confermare che la tabella mostri ricerca, intestazioni ordinabili e paginazione (lo stesso aspetto/comportamento della tabella `fields` esistente altrove sulla stessa pagina, per la sezione "Telefono e contatti").
2. Aprire la console sviluppatore e verificare che non ci siano errori JS (in particolare: nessun errore di parsing JSON, nessun warning "DataTable already initialized").
3. Verificare che il testo delle celle sia quello atteso (nessun tag HTML residuo visibile come testo, nessuna entità codificata visibile come `<` invece che renderizzata).

- [ ] **Step 6: Commit**

```bash
git add classes/services/content_trasparenza.php design/bootstrapitalia2/templates/openpa/full/pagina_trasparenza.tpl design/bootstrapitalia2/templates/openpa/full/parts/amministrazione_trasparente/organi_uffici_live.tpl
git commit -m "Aggiunge rendering live di Organi politici/amministrativi con DataTables lato client"
```

---

### Task 7 — Invalidazione cache: tag condiviso + listener sulla pubblicazione

**Dipende da**: Task 2 (esito dello spike — sintassi di registrazione confermata), Task 5, Task 6.

**Files:**
- Modify: `design/bootstrapitalia2/templates/openpa/full/pagina_trasparenza.tpl` (impostare `response_tag_list`)
- Create: `classes/anac/ArticolazioneUfficiCacheInvalidationListener.php`
- Modify: file di registrazione trovato in Task 2 Step 2 (verosimilmente `settings/ezpevents.ini.append.php` o equivalente — nome esatto noto solo dopo Task 2)

**Interfaces:**
- Consumes: `PageArticolazioneUfficiProvider::getCacheTag()` (Task 5) — stessa stringa usata sia qui sia nel listener, un'unica fonte di verità.
- Produces: il tag `trasparenza-articolazione-uffici-{node_id}` viene (a) incluso nell'header di risposta cache quando la pagina viene renderizzata, (b) invalidato ogni volta che un `organization` o `time_indexed_role` viene pubblicato o cancellato.

- [ ] **Step 1: Impostare `response_tag_list` nel template**

In `pagina_trasparenza.tpl`, dove oggi la pagina viene renderizzata (vicino all'inclusione del Task 6), aggiungere, **solo quando `$trasparenza.organi_uffici_live` non è `false`** (altrimenti si romperebbe il tagging di default per ogni altra pagina_trasparenza che non usa questa funzionalità — vedi `CacheListener.php:73-75`, `response_tag_list` sostituisce tutti i tag di default, non li somma):

```smarty
{if $trasparenza.organi_uffici_live}
    {set-block scope=root variable=response_tag_list}{ldelim}
        'object-' . concat($node.contentobject_id,''),
        'node-' . concat($node.node_id,''),
        $trasparenza.organi_uffici_live.cache_tag
    {rdelim}{/set-block}
{/if}
```

Nota: la sintassi esatta per costruire un array in un template `.tpl` eZ Publish Legacy va verificata contro un esempio reale esistente nel codebase (cercare `response_tag_list` o costruzione di array via `{def}`/`{set}` in altri template `.tpl` di questo repo) prima di considerare questo step completo — non assumere che la sintassi sopra sia sintatticamente valida senza averla vista girare.

```bash
grep -rn "response_tag_list" design/ 2>/dev/null
grep -rln "{def \$.*= array(" design/bootstrapitalia2/templates/ 2>/dev/null | head -3
```

- [ ] **Step 2: Implementare il listener, con la sintassi di registrazione confermata da Task 2**

```php
<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Invalida il tag di cache condiviso della pagina "Articolazione degli
 * uffici" quando un organization o un time_indexed_role viene pubblicato o
 * cancellato - questi sono gli oggetti che PageArticolazioneUfficiProvider
 * legge per costruire le tabelle live (Task 5/6). A differenza
 * dell'ExportPublisher dell'export ANAC (che pubblica al massimo una volta
 * al giorno), qui NON c'è quel vincolo: ogni pubblicazione rilevante deve
 * invalidare subito, perché questa è una pagina pubblica letta in tempo
 * reale, non un file con un nome datato.
 *
 * Non enumera QUALI pagine_trasparenza invalidare (richiederebbe risalire
 * schema_pubblicazione per ogni pubblicazione, costoso e fragile) - banna
 * per classe di oggetto cambiato, affidandosi al fatto che ci si aspetta un
 * numero contenuto di pagine_trasparenza bindate ad art.13-op/art.13-oa per
 * ogni tenant (tipicamente una sola per profilo C1 o C2, vedi
 * SchemaPubblicazioneLookup).
 */
class ArticolazioneUfficiCacheInvalidationListener
{
    const RELEVANT_CLASSES = ['organization', 'time_indexed_role'];

    /**
     * Costo noto da monitorare: fetchArticolazioneUfficiPageTags() scansiona
     * TUTTI gli oggetti pagina_trasparenza del tenant (via
     * SchemaPubblicazioneLookup::fetchAllBindings(), uno scan PHP completo
     * della classe) ogni volta che QUALUNQUE organization/time_indexed_role
     * viene pubblicato - non solo quando viene pubblicato un oggetto
     * effettivamente mostrato da questa pagina. Su un tenant con
     * trasparenza-c1/c2, il numero di pagina_trasparenza è tipicamente
     * poche decine, quindi il costo per pubblicazione resta contenuto - ma
     * aggiunge latenza alla pubblicazione di QUALUNQUE organization/
     * time_indexed_role sul sito, non solo a chi tocca questa pagina. La
     * cache statica sotto evita di ripetere lo scan più volte nella stessa
     * richiesta (un'operazione di pubblicazione può toccare più nodi in una
     * volta sola, es. uno spostamento), ma non riduce il costo sulla prima
     * chiamata di ogni richiesta - se diventa un problema misurabile in
     * produzione, la mitigazione corretta è cachare il risultato di
     * fetchAllBindings() con invalidazione esplicita alla pubblicazione di
     * un pagina_trasparenza (fuori scopo per questo piano).
     */
    private static $cachedTags = null;

    public static function onInvalidateTagNodeList($tagList, $nodeIdList)
    {
        foreach ($nodeIdList as $nodeId) {
            $node = \eZContentObjectTreeNode::fetch((int)$nodeId);
            if (!$node instanceof \eZContentObjectTreeNode) {
                continue;
            }
            if (!in_array($node->attribute('class_identifier'), self::RELEVANT_CLASSES, true)) {
                continue;
            }

            foreach (self::fetchArticolazioneUfficiPageTags() as $tag) {
                $tagList[] = $tag;
            }

            break;
        }

        return $tagList;
    }

    /**
     * @return string[] uno per ogni pagina_trasparenza bindata ad
     *         art.13-op/art.13-oa effettivamente presente su questo tenant
     */
    private static function fetchArticolazioneUfficiPageTags()
    {
        if (self::$cachedTags !== null) {
            return self::$cachedTags;
        }

        $tags = [];
        $bindings = \SchemaPubblicazioneLookup::fetchAllBindings();
        $provider = new PageArticolazioneUfficiProvider();

        foreach ([Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OP, Serializer\Art13Serializer::SCHEMA_IDENTIFIER_OA] as $schema) {
            if (!isset($bindings[$schema])) {
                continue;
            }
            $node = $bindings[$schema]->mainNode();
            if ($node instanceof \eZContentObjectTreeNode) {
                $tags[] = $provider->getCacheTag($node);
            }
        }

        self::$cachedTags = array_unique($tags);

        return self::$cachedTags;
    }
}
```

Registrare `ArticolazioneUfficiCacheInvalidationListener::onInvalidateTagNodeList` sul filtro `ocfoshttpcache/invalidate_tag_node_list` usando **esattamente** la sintassi confermata in Task 2 Step 2/3 — non la sintassi plausibile di questo step, quella verificata empiricamente.

- [ ] **Step 3: Verifica manuale end-to-end su `sito-comunale-dev`**

```bash
# 1. Caricare la pagina e verificare l'header del tag di cache
curl -sI https://opencity.localtest.me/content/view/full/<node_id_pagina> | grep -i "xkey\|cache-tags"

# 2. Pubblicare una modifica a "Giunta comunale" (id 226) dal backend, o via script
#    (stesso pattern di creazione/publish usato nei test precedenti, su un oggetto
#    che la pagina effettivamente mostra - verificare prima quale id usare)

# 3. Ricaricare la pagina e confermare che il contenuto rifletta la modifica
curl -s https://opencity.localtest.me/content/view/full/<node_id_pagina> | grep "Giunta comunale"
```

- [ ] **Step 4: Commit**

```bash
git add classes/anac/ArticolazioneUfficiCacheInvalidationListener.php design/bootstrapitalia2/templates/openpa/full/pagina_trasparenza.tpl <file di registrazione trovato in Task 2>
git commit -m "Aggiunge invalidazione cache mirata per la pagina Articolazione degli uffici"
```

---

## Note per chi esegue questo piano

- Task 1 e Task 2 sono spike: il loro scopo è produrre una decisione verificata (go/no-go), non codice permanente. Non saltarli per andare più veloci — Task 4 e Task 7 sono costruiti esplicitamente sopra le loro conclusioni, non su quanto descritto in questo piano come ipotesi di partenza.
- La tabella "Telefono e contatti" resta volutamente fuori da questo piano (vedi Spec, punto 3) — non aggiungerla come task extra non richiesto.
- Questo piano presuppone che `feature/anac-export-serializers` sia il branch di partenza. Se nel frattempo è stato mergiato altrove, verificare con `git log --oneline --all -- classes/anac/Serializer/Art13Serializer.php` da dove ripartire prima del Task 1.
