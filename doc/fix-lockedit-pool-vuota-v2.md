# Piano di fix: lock_edit homepage — pool vuota non deve distruggere la struttura

**Versione:** 2.1 (aggiornato con root cause verificata)  
**File da modificare:**
- `classes/connectors/LockEdit/HomepageLockEditClassConnector.php` (fix difensivo — già implementato)
- `ocopendata/lib/ocopendata/src/Opencontent/Opendata/Api/AttributeConverter/Page.php` (fix root cause)

**Branch:** `fix/lockedit-homepage-vuota`

---

## Root cause — verificata empiricamente (luglio 2026)

### Perché la pool appare vuota

I pool items vengono inseriti da `AttributeConverter/Page.php::createXML()` con **`ts_visible=0`**
(default della colonna in PostgreSQL). La query `eZFlowPool::validNodes()` filtra con
`AND ts_visible>0`, quindi gli items appena inseriti sono **invisibili** finché qualcosa non
li rende visibili.

Il meccanismo che dovrebbe rendere gli items visibili è `eZFlowOperations::update()`, chiamato
da `ezpagetype.php::onPublish()` durante il publish del content object.

**Questo funziona correttamente SOLO se il publish avviene sincronamente.**

### Il workflow "Pre pubblicazione" come trigger del bug

Su alcuni tenant esiste un workflow globale attivo:
- **Nome:** "Pre pubblicazione" (`group_ezserial`, `is_enabled=1`, `workflow_id=2`)
- Processi **DEFERRED** (status=10) possono accumularsi se il cron non li processa

Quando questo workflow è attivo, il publish viene **differito** (status=10 = aspetta cron):
1. Lock_edit salva → `createXML` inserisce items con `ts_visible=0`
2. Content publish → workflow "Pre pubblicazione" → processo **DEFERRED**
3. `ezpagetype.php::onPublish()` non gira → `eZFlowOperations::update()` non gira
4. Pool items rimangono `ts_visible=0`
5. Redattore riapre il form **prima che il cron processi il workflow**
6. `validNodes()` non trova niente (`ts_visible=0`) → form mostra pool vuota
7. Salva → blocchi distrutti

### Il cron non gira

L'accumulo di processi deferred indica che il cron che processa i workflow
**non sta girando o fallisce**. Ogni save aggiunge un nuovo processo
alla coda, ma nessuno li processa.

### Perché la riga era commentata

In `ContentRepository.php:433`:
```php
//        eZFlowOperations::update([$object->mainNodeID()]);
```
Questa riga è stata aggiunta **già commentata** nel commit `bf50afe` del 1 ottobre 2025
("Add opendata v2 block read and put api"). Era un reminder/TODO che non è mai stato
attivato — il codice si affidava implicitamente al publish standard.

In `LockEditConnector.php:44`:
```php
//            eZINI::instance('ezflow.ini')->setVariable('eZFlowOperations', 'UpdateOnPublish', 'disabled');
```
Aggiunta commentata nel commit `995bf8e0` del 3 aprile 2023 come nota residua di un
tentativo di workaround. Non è mai stata attiva.

### Perché succede su alcuni tenant e non altri

Il bug si manifesta SOLO su tenant che hanno:
1. Un workflow globale che causa DEFERRED della publish, E
2. Un cron che non processa i workflow deferred (o lo processa lentamente)

Tenant senza workflow o con cron funzionante non sono affetti.

---

## Contesto verificato empiricamente

### Il bug

Quando la pool (`ezm_pool`) di un blocco `ListaManuale` è vuota al momento dell'apertura
del form lock_edit, il sistema **distrugge il blocco dall'XML della homepage** al salvataggio.

**Meccanismo preciso (verificato):**
1. `getData()` chiama `mapListaManualeToRelations(SECTION_BANNER)` → pool vuota → restituisce `null`
2. `is_array(null) = false` → `add_section_banner = false`
3. Alpaca mostra il toggle come **OFF** (deselezionato)
4. Il POST non include `section_banner` (dipendenza Alpaca: campo nascosto quando toggle=OFF)
5. `mapSectionBanner($data)` → `isset($data['section_banner'][0]['id'])` = false → `return null`
6. `mapSubmittedFormToBlocks()` non include il blocco nell'array
7. `createXML()` riceve i blocchi senza banner → banner rimosso dall'XML permanentemente

**Blocchi che sopravvivono con pool vuota (NON toccati dal bug):**
- `ListaAutomatica` (news automatiche): `mapListaAutomaticaToBoolean` controlla il tipo, non la pool
- `Eventi` (eventi automatici): `mapEventiToBoolean` controlla il tipo, non la pool

**Blocchi vulnerabili al bug (pool vuota → distruzione):**
- Banner / Siti tematici (`ListaManuale`)
- Management / Amministrazione (nessun toggle)
- Places / Luoghi (nessun toggle)
- Topics / Argomenti (nessun toggle)
- Ricerca (toggle `add_section_search` dipende dalla pool)
- News in modalità manuale (`ListaManuale` mode)
- Events in modalità manuale (`ListaManuale` mode)
- Main news / Notizione (`mapSingoloToRelation` dipende dalla pool)

### Principio del fix

**Il rendering del frontend non dipende dall'XML — dipende dalla pool.**  
Un blocco in XML con pool vuota → `ha_content = false` → la sezione **non appare ai visitatori**.

Quindi: preservare un blocco nell'XML con pool vuota **non fa apparire sezioni vuote** in homepage.
Il fix può preservare la struttura XML senza violare il comportamento frontend atteso.

**Obiettivo:** un salvataggio con pool vuota non deve mai distruggere blocchi che esistono nell'XML.

---

## Fix 1 — `getData()`: i toggle non si auto-deselezionano per pool vuota

### Problema attuale

```php
// PRIMA
'add_section_banner' => is_array($hasBanner),
'add_section_news'   => $hasLatestNews || $hasNews,
'add_section_events' => $hasNextEvents || $hasEvents,
'add_section_search' => is_array($hasLinks) || is_array($hasSearchBg),
```

Con pool vuota: `$hasBanner = null` → `is_array(null) = false` → toggle OFF → blocco distrutto.

### Fix

```php
// DOPO
'add_section_banner' => is_array($hasBanner) || $this->findBlockById(self::SECTION_BANNER) !== null,
'add_section_news'   => $hasLatestNews || $hasNews || $this->findBlockById(self::SECTION_NEWS) !== null,
'add_section_events' => $hasNextEvents || $hasEvents || $this->findBlockById(self::SECTION_NEXT_EVENTS) !== null,
'add_section_search' => is_array($hasLinks) || is_array($hasSearchBg) || $this->findBlockById(self::SEARCH) !== null,
```

`findBlockById(id)` con `strict=false` cerca in `currentBlocks` (XML corrente). Se il blocco
esiste nell'XML → toggle rimane ON → la sezione appare attiva nel form → al save si entra
nel ramo corretto del `mapSection*()`.

**Corner case Fix 1:**

| Scenario | Comportamento atteso |
|----------|----------------------|
| Pool vuota, blocco in XML | Toggle ON nel form → blocco preservato |
| Pool piena, blocco in XML | Toggle ON nel form (come ora) |
| Pool vuota, blocco NON in XML | Toggle OFF nel form (come ora) |
| Utente deseleziona toggle → salva | Toggle OFF nel POST → blocco rimosso dall'XML ✓ |
| Nuovo sito, blocco mai in XML | Toggle OFF → nessun blocco creato ✓ |

---

## Fix 2 — `mapSectionBanner()`: gate sul toggle, non sugli items

### Problema attuale

```php
// PRIMA
private function mapSectionBanner($data): ?array
{
    if (isset($data['section_banner'][0]['id'])) {
        // ... costruisce blocco
        return $block;
    }
    return null;  // ← null se items assenti, indipendentemente dal toggle
}
```

Con Fix 1 il toggle rimane ON (add_section_banner="true"), ma `section_banner` è ABSENT
perché Alpaca esclude i campi dipendenti da un toggle OFF... aspetta, non è più OFF.

In realtà con Fix 1 il toggle è ON → `section_banner` è visibile nel form ma vuota →
Alpaca invia `section_banner = ABSENT` (array vuoto opzionale non incluso).

Il gate deve essere sul **toggle**, non sulla presenza degli items.

### Fix

```php
// DOPO
private function mapSectionBanner($data): ?array
{
    // Gate: il redattore ha esplicitamente disattivato la sezione
    if (!$this->isSectionActive($data['add_section_banner'] ?? false)) {
        return null;
    }

    $originalBlock = $this->findBlockById(self::SECTION_BANNER, true)
        ?? $this->findBlockById(self::SECTION_BANNER);

    $originalBlock['name'] = $data['title_banner'] ?? '';
    $originalBlock['type'] = 'ListaManuale';

    $originalCustomAttributes = $originalBlock['custom_attributes'];
    $originalBlock['custom_attributes'] = [
        'elementi_per_riga' => $originalCustomAttributes['elementi_per_riga'],
        'color_style'       => $originalCustomAttributes['color_style'],
        'container_style'   => $originalCustomAttributes['container_style'],
        'intro_text'        => $originalCustomAttributes['intro_text'],
    ];

    $remoteIdList = [];
    foreach ((array)($data['section_banner'] ?? []) as $item) {
        $object = eZContentObject::fetch((int)$item['id']);
        if ($object instanceof eZContentObject) {
            $remoteIdList[] = $object->attribute('remote_id');
        }
    }
    $originalBlock['valid_items'] = $remoteIdList;
    return $originalBlock;
}

private function isSectionActive($value): bool
{
    return $value === true || $value === 'true' || $value === 1 || $value === '1';
}
```

**Corner case Fix 2:**

| Scenario | `add_section_banner` | `section_banner` | Risultato |
|----------|---------------------|------------------|-----------|
| Pool vuota, blocco in XML, nessuna modifica | "true" | ABSENT | Blocco preservato, valid_items=[] |
| Pool piena, redattore aggiunge items | "true" | [items] | Blocco con nuovi items ✓ |
| Redattore disattiva toggle | "false" | ABSENT | Blocco rimosso ✓ |
| Redattore attiva toggle ma non mette items | "true" | ABSENT | Blocco preservato, pool vuota, frontend invisibile |
| Toggle assente dal POST | ABSENT (false) | ABSENT | Blocco rimosso (retrocompatibile) |

**Nota:** stessa logica si applica identicamente a `mapSectionSearch()`.

---

## Fix 3 — `mapSectionNews()` e `mapSectionEvents()`: gate sul toggle

### Problema attuale

Entrambi i metodi terminano con `return null` quando:
- `section_latest_news` ≠ `'true'`  
- `section_news[0][id]` non presente

Con pool vuota in modalità manuale: `add_section_news = false` (prima del Fix 1) →
blocco eliminato.

Con Fix 1: `add_section_news = true` → il toggle è ON → ma il metodo potrebbe comunque
ritornare `null` se nessuna modalità è selezionata nel POST.

### Fix

Aggiungere gate iniziale e ramo di fallback:

```php
// DOPO — mapSectionNews
private function mapSectionNews($data): ?array
{
    // Gate: redattore ha disattivato la sezione notizie
    if (!$this->isSectionActive($data['add_section_news'] ?? false)) {
        return null;
    }

    $originalBlockNews = $this->findBlockById(self::SECTION_NEWS, true);
    if ($originalBlockNews === null) {
        return null;  // Blocco non nel YAML sorgente — non può essere creato
    }
    $originalBlockNews['name'] = $data['title_news'] ?? '';

    if (isset($data['section_latest_news']) && $data['section_latest_news'] === 'true') {
        return $originalBlockNews;  // Modalità automatica
    } elseif (isset($data['section_news'][0]['id'])) {
        // ... modalità manuale (invariato)
    }

    // Fallback: sezione attiva nel form ma nessuna modalità selezionata
    // (es. pool era vuota al caricamento) → preserva il blocco corrente dall'XML
    $currentBlock = $this->findBlockById(self::SECTION_NEWS) ?? $originalBlockNews;
    $currentBlock['name'] = $originalBlockNews['name'];
    return $currentBlock;
}
```

Stessa struttura per `mapSectionEvents()`.

**Corner case Fix 3:**

| Scenario | Risultato |
|----------|-----------|
| Notizie automatiche, pool vuota | Gate passa, `section_latest_news='true'` → blocco YAML restituito (type=ListaAutomatica) |
| Notizie manuali, pool vuota | Gate passa, no items → fallback → blocco corrente da XML preservato |
| Redattore disattiva notizie | Gate blocca → null → blocco rimosso ✓ |
| `$originalBlockNews = null` (YAML mancante) | Return null sicuro, no crash |

**Nota critica:** `$originalBlockNews['name'] = ...` crashava se `findBlockById(strict=true)`
ritornava null. Il fix aggiunge il null-check obbligatorio.

---

## Fix 4 — Sezioni senza toggle: management, places, topics, main news

Queste sezioni non hanno `add_section_*` nel form. Con pool vuota, i loro campi sono
ABSENT dal POST → i metodi attuali ritornano `null` → blocco distrutto.

**Non possiamo distinguere** "pool vuota per bug" da "utente ha rimosso tutti gli items"
perché producono lo stesso POST identico.

**Decisione:** preservare il blocco se esiste nell'XML, anche se il campo è ABSENT.

**Comportamento frontend invariato:** pool vuota → `ha_content=false` → sezione non appare.
Il sito si comporta come se la sezione non ci fosse. Il blocco esiste nell'XML ma è invisibile.

**Tradeoff accettato:** rimuovere management/places/topics tramite lock_edit non è più
possibile quando il blocco è in XML. Va fatto dal backend eZ standard.

### Fix `mapSectionManagement()`

```php
private function mapSectionManagement($data, $hasMainNews): ?array
{
    $originalBlockManagement = $this->findBlockById(self::SECTION_MANAGEMENT, true);

    if (!isset($data['section_management'][0]['id'])) {
        // Campo assente: pool vuota O utente ha rimosso tutti gli items
        // Preserva il blocco se esiste nell'XML (invisibile in frontend finché pool è vuota)
        $existingBlock = $this->findBlockById(self::SECTION_MANAGEMENT);
        if ($existingBlock !== null) {
            if (!$hasMainNews) {
                $existingBlock['custom_attributes']['container_style'] = false;
            }
            return $existingBlock;
        }
        return null;  // Blocco mai esistito in XML → non lo creiamo
    }

    // ... logica esistente con items (invariata)
}
```

Stesso pattern per `mapSectionPlaces()` e `mapSectionTopics()`.

### Fix `mapMainNews()`

```php
private function mapMainNews($data): ?array
{
    $newsRemoteId = false;

    if (!isset($data['main_news'][0]['id'])) {
        // Pool vuota: preserva blocco corrente se esiste nell'XML
        $existingBlock = $this->findBlockById(self::MAIN_NEWS);
        if ($existingBlock !== null && !empty($existingBlock['valid_items'])) {
            // Blocco in XML con items → usa gli items esistenti (da pool)
            $block = $this->findBlockById(self::MAIN_NEWS, true) ?? $existingBlock;
            $block['valid_items'] = $existingBlock['valid_items'];
            if (isset($data['background_image'][0]['id']) && $this->canAttachBackgroundImage()) {
                $block['custom_attributes']['container_style'] = 'overlay';
            }
            return $block;
        }
        // Nessun blocco in XML, o blocco con valid_items=[]:
        // usa il comportamento esistente (canRemoveMainNews + fallback query)
        if ($this->canRemoveMainNews()) {
            return null;
        }
        // Fallback query (invariata ma con filtro is_invisible)
        // ...
    }
    // ... logica esistente con items (invariata)
}
```

**Corner case Fix 4:**

| Sezione | Blocco in XML | Campo nel POST | Risultato |
|---------|--------------|----------------|-----------|
| Management | Sì | ABSENT | Preservato, pool invariata |
| Management | No | ABSENT | null — non creato ✓ |
| Places | Sì | ABSENT | Preservato |
| Main news | Sì, valid_items=[remote_id] | ABSENT | Preservato con item ✓ |
| Main news | Sì, valid_items=[] | ABSENT | Fallback a query filtrata |
| Topics | Sì | ABSENT | Preservato |
| Topics | No | ABSENT | null ✓ |

---

## Fix 5 — `mapMainNews()` fallback query: filtra per visibilità

### Problema attuale

```php
// PRIMA
$newsList = eZContentObjectTreeNode::subTreeByNodeID([
    'ClassFilterType' => 'include',
    'ClassFilterArray' => ['article'],
    'Limit' => 1,
    'SortBy' => [['published', false]],
], 1);  // ← cerca da root, nessun filtro visibilità
```

Può restituire articoli con nodo nascosto (`is_invisible=1`), come articoli con data futura da sezioni non pubblicate.

### Fix

```php
// DOPO
$newsList = eZContentObjectTreeNode::subTreeByNodeID([
    'ClassFilterType' => 'include',
    'ClassFilterArray' => ['article'],
    'Limit' => 10,
    'SortBy' => [['published', false]],
], 1);
foreach ($newsList as $newsNode) {
    if ($newsNode->attribute('is_invisible') == 0) {
        $newsRemoteId = $newsNode->attribute('object')->attribute('remote_id');
        break;
    }
}
```

**Corner case Fix 5:**

| Scenario | Risultato |
|----------|-----------|
| Articoli visibili disponibili | Primo articolo visibile → corretto ✓ |
| Tutti gli articoli sono invisibili/privati | Nessun item → `$newsRemoteId = false` → blocco senza valid_items |
| Articolo con data pubblicazione futura | `is_invisible=1` → saltato ✓ |

---

## Null-check mancanti (bug pre-esistenti da correggere)

Questi crash erano possibili già prima del fix, ma il fix li rende più facilmente
raggiungibili aumentando le situazioni in cui `mapSection*()` vengono chiamati:

```php
// HomepageLockEditClassConnector.php riga 591
$originalBlockNews = $this->findBlockById(self::SECTION_NEWS, true);
// ↑ può essere null se SECTION_NEWS non è in sourceBlocks
$originalBlockNews['name'] = $data['title_news'] ?? '';  // ← CRASH

// Riga 617 — stesso problema per SECTION_NEXT_EVENTS
// Riga 622 — SECTION_MANAGEMENT usato come template per eventi manuali
$block = $this->findBlockById(self::SECTION_MANAGEMENT, true);
$block['block_id'] = self::SECTION_NEXT_EVENTS;  // ← CRASH se null
```

**Fix:** aggiungere null-check e early return in tutti e tre i casi.

---

## Test da scrivere

### Test 1 — Pool vuota, blocco in XML: nessun blocco eliminato

**Setup:** `currentBlocks` ha tutti i blocchi (Singolo, ListaManuale news, Events, Banner,
Management, Places, Topics, Search). Pool vuota per tutti i blocchi tranne Singolo.

**Input POST (simulato):** `add_section_banner="true"`, `add_section_news="true"`,
`add_section_events="true"`, `add_section_search="true"`, `main_news=[...]`, `section_topic=[...]`.

**Assert:** `mapSubmittedFormToBlocks()` restituisce tutti i blocchi (stessa quantità di
`currentBlocks`). Nessun blocco con `block_id` mancante.

### Test 2 — Toggle disattivo: blocco rimosso correttamente

**Input POST:** `add_section_banner="false"`, `section_banner=ABSENT`.

**Assert:** `mapSectionBanner()` restituisce `null` → blocco non incluso nei risultati. ✓

### Test 3 — Toggle attivo, items assenti: blocco preservato

**Input POST:** `add_section_banner="true"`, `section_banner=ABSENT`.

**Assert:** `mapSectionBanner()` restituisce blocco con `valid_items=[]`. Non null.

### Test 4 — Management assente dal POST, blocco in XML

**Setup:** `currentBlocks` contiene il blocco management.  
**Input POST:** `section_management=ABSENT`.

**Assert:** `mapSectionManagement()` restituisce il blocco existente. Non null.

### Test 5 — Management assente dal POST, blocco NON in XML

**Setup:** `currentBlocks` vuoto.  
**Input POST:** `section_management=ABSENT`.

**Assert:** `mapSectionManagement()` restituisce `null`. Non crea blocchi inesistenti. ✓

### Test 6 — News automatica, pool vuota

**Setup:** `currentBlocks` contiene blocco news (ListaAutomatica).  
**Input POST:** `add_section_news="true"`, `section_latest_news="true"`.

**Assert:** `mapSectionNews()` restituisce blocco da sourceBlocks con `type=ListaAutomatica`. ✓

### Test 7 — News manuale, pool vuota, nessun item nel POST

**Setup:** `currentBlocks` contiene blocco news (ListaManuale).  
**Input POST:** `add_section_news="true"`, `section_latest_news="false"`, `section_news=ABSENT`.

**Assert:** `mapSectionNews()` restituisce blocco da `currentBlocks` (fallback). Non null. ✓

### Test 8 — Fallback mapMainNews: no articoli privati

**Setup:** `currentBlocks` ha Singolo con `valid_items=[]`. Solr non disponibile o vuoto.  
**Input POST:** `main_news=ABSENT`.

**Assert:** se la query restituisce nodi, ognuno ha `is_invisible=0`.

### Test 9 — Null-check: nessun crash con sourceBlocks mancante

**Setup:** `sourceBlocks=[]` (YAML vuoto).  
**Input POST:** qualsiasi POST con toggle attivi.

**Assert:** nessun Fatal Error in `mapSectionNews()`, `mapSectionEvents()`.

### Test 10 — Regressione: salvataggio normale con pool piena

**Setup:** pool piena per tutti i blocchi. `currentBlocks` popolato.  
**Input POST:** POST completo con tutti gli items.

**Assert:** `mapSubmittedFormToBlocks()` restituisce blocchi con `valid_items` corretti
(non quelli vecchi da `currentBlocks`). Gli items inviati dal POST prevalgono sempre.

---

## Comportamento frontend invariato (da verificare manualmente)

Dopo il fix, aprire la homepage con pool vuota per il banner:
- ✅ La sezione banner **non appare** ai visitatori (`ha_content=false`)
- ✅ Il form lock_edit mostra il toggle banner **ON** con lista vuota
- ✅ Aggiungendo items e salvando, la sezione **riappare** correttamente
- ✅ Disattivando il toggle e salvando, il blocco **viene rimosso** dall'XML
- ✅ Per tenant che non hanno mai avuto il banner, il blocco **non viene creato**

---

---

## Fix 6 — Root cause: `Page.php` deve rendere items visibili immediatamente

**Repository:** `ocopendata` (da agganciare in locale come le altre estensioni)  
**File:** `lib/ocopendata/src/Opencontent/Opendata/Api/AttributeConverter/Page.php`

### Problema

`eZFlowPool::insertItems()` inserisce items con `ts_visible=0` (default colonna PostgreSQL).
La query `validNodes()` filtra `AND ts_visible>0`, quindi gli items sono invisibili finché
`eZFlowOperations::update()` non li processa. Se la publish è deferred (workflow), `update()`
non gira → items restano `ts_visible=0` → pool appare vuota al prossimo form open.

### Fix

Dopo `insertItems()`, aggiornare immediatamente `ts_visible = time()` per tutti gli items
appena inseriti. Questo bypassa la dipendenza da `eZFlowOperations::update()`.

```php
// PRIMA (attuale):
\eZFlowPool::insertItems($flowPoolItems);

// DOPO:
\eZFlowPool::insertItems($flowPoolItems);

// Rendi visibili immediatamente gli items (ts_visible=0 = invisibili a validNodes())
// Non aspettare il cron/workflow deferred che potrebbe non girare
if (!empty($flowPoolItems)) {
    $db = \eZDB::instance();
    $now = time();
    foreach ($flowPoolItems as $item) {
        $db->query(
            "UPDATE ezm_pool SET ts_visible=$now" .
            " WHERE block_id='" . $db->escapeString($item['blockID']) . "'" .
            " AND object_id=" . (int)$item['objectID'] .
            " AND ts_visible=0 AND ts_hidden=0"
        );
    }
}
```

**Nota:** `eZFlowPool::insertItems()` non accetta `ts_visible` come parametro, quindi
l'UPDATE separato è il modo più sicuro senza modificare l'interfaccia di `insertItems`.

### Corner case Fix 6

| Scenario | Risultato |
|----------|-----------|
| Save con items → form riaperta subito | Items visibili immediatamente ✓ |
| Workflow deferred attivo | Items visibili comunque (bypass workflow delay) ✓ |
| Items con `ts_hidden > 0` | Non toccati (la condizione `ts_hidden=0` li esclude) ✓ |
| Items già visibili (`ts_visible > 0`) | Non toccati (la condizione `ts_visible=0` li esclude) ✓ |
| `insertItems` fallisce | UPDATE non viene eseguito (no items to update) ✓ |

### Relazione con il Fix difensivo (Fix 1-5)

I due fix sono **complementari**, non alternativi:

| Fix | Cosa risolve |
|-----|-------------|
| Fix difensivo (1-5, già implementato) | Se la pool appare vuota per qualsiasi motivo, la struttura XML non viene distrutta |
| Fix root cause (questo Fix 6) | Previene che la pool appaia vuota dopo un save lock_edit su tenant con workflow |

Con solo il fix difensivo: la pool può ancora apparire vuota (sezioni non renderizzate in frontend), ma i blocchi sopravvivono in XML e si recuperano ri-aggiungendo items.

Con solo il fix root cause: la pool è sempre visibile dopo il save, ma se per qualche altra ragione diventasse vuota (es. `cleanupRemovedItems`, contenuti eliminati, bug), i blocchi verrebbero comunque distrutti.

Con **entrambi**: sistema robusto end-to-end.

---

## File da modificare

**Fix difensivo (già implementato):**
- `classes/connectors/LockEdit/HomepageLockEditClassConnector.php`

**Fix root cause (da implementare):**
- `ocopendata/lib/ocopendata/src/Opencontent/Opendata/Api/AttributeConverter/Page.php`

Nessuna modifica a:
- Template
- INI
- DB
- Classi di contenuto
