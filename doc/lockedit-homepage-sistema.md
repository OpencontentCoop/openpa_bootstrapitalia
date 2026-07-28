# Sistema lock_edit homepage — Documentazione tecnica verificata empiricamente

Questo documento descrive il funzionamento reale del sistema lock_edit della homepage,
ricavato da lettura del codice e verifiche empiriche tramite log sul sistema locale.

---

## 1. Architettura generale

Il sistema si basa su **due fonti di verità separate**:

| Fonte | Cosa contiene | Chi la legge |
|-------|--------------|--------------|
| `ezpage` XML (attributo eZ) | Struttura dei blocchi: tipo, view, custom_attributes, nome | Frontend (rendering) |
| `ezm_pool` | Items correnti di ogni blocco (gli oggetti da mostrare) | Form lock_edit (`getData()`) |

**Conseguenza fondamentale:** la homepage può sembrare intatta ai visitatori (dal cache Varnish o dall'XML) anche quando la pool è vuota. Il form lock_edit invece legge dalla pool e mostra sezioni vuote.

---

## 2. `currentBlocks` e `valid_items`

```php
// HomepageLockEditClassConnector::getData() riga 40
$this->currentBlocks = $this->content['page']['content']['global']['blocks'];
```

- `currentBlocks` viene dall'XML del page attribute attualmente salvato su DB
- La **struttura** del blocco (type, name, custom_attributes) proviene dall'XML
- I **`valid_items`** sono popolati in tempo reale da `eZFlowPool::validNodes()` che legge `ezm_pool`
- Se `ezm_pool` è vuota → `valid_items = []` nel blocco

**Verificato empiricamente:** con Singolo (pool=1) i valid_items contenevano il remote_id della notizia. Con ListaAutomatica (pool=0) valid_items era vuoto.

---

## 3. `findBlockById(id, strict)`

```php
// LockEditClassConnector riga 110-130
protected function findBlockById($id, $strict = false): ?array
```

| `strict` | Legge da | Contiene |
|----------|----------|----------|
| `true` | `$this->sourceBlocks` (YAML installer) | Solo struttura, `valid_items = []` sempre |
| `false` (default) | `$this->currentBlocks` (XML + pool) | Struttura + valid_items dalla pool |

`sourceBlocks` si popola **lazy**: rimane null finché qualche `mapSection*()` non chiama `findBlockById(id, true)`.

**Verificato empiricamente:** `findBlockById(MAIN_NEWS, true)` → `valid_items: []`; `findBlockById(MAIN_NEWS, false)` → `valid_items: ["4942f12b..."]` (dal pool).

---

## 4. `sourceBlocks` — struttura YAML

I blocchi nel YAML sorgente (8 totali). **Nessuno ha valid_items**, solo struttura:

| block_id | Tipo YAML | Tipo reale in DB |
|----------|-----------|------------------|
| `564803b7...` | Singolo | Singolo |
| `3213d4...` | ListaManuale | ListaManuale |
| `e60d13...` | ListaAutomatica | ListaAutomatica o ListaManuale |
| `9cd237...` | Eventi | Eventi |
| `a41966...` | Argomenti | Argomenti |
| `section-place` | ListaManuale | ListaManuale |
| `d406949b...` | **ListaAutomatica** | **ListaManuale** (dopo save con items) |
| `2813cd...` | Ricerca | Ricerca |

Nota: il banner (`d406949b`) nel YAML ha tipo `ListaAutomatica`, ma `mapSectionBanner()` sovrascrive esplicitamente `type = 'ListaManuale'` quando salva con items.

---

## 5. Flusso di `getData()` — come si costruiscono i flag `add_section_*`

```php
'add_section_news'   => $hasLatestNews || $hasNews,
'add_section_events' => $hasNextEvents || $hasEvents,
'add_section_banner' => is_array($hasBanner),
'add_section_search' => is_array($hasLinks) || is_array($hasSearchBg),
```

### Metodi di mapping e loro dipendenza dalla pool

| Metodo | Dipende dalla pool? | Comportamento con pool vuota |
|--------|--------------------|-----------------------------|
| `mapListaAutomaticaToBoolean` | **No** — controlla solo `$block['type']` | Ritorna `true` se tipo='ListaAutomatica' |
| `mapEventiToBoolean` | **No** — controlla solo `$block['type']` | Ritorna `true` se tipo='Eventi' |
| `mapListaManualeToRelations` | **Sì** — legge `valid_items` | Ritorna `null` se pool vuota |
| `mapSingoloToRelation` | **Sì** — legge `valid_items[0]` | Ritorna `null` se pool vuota |
| `mapArgomentiToRelations` | **Sì** — legge `valid_items` | Ritorna `[]` se pool vuota |
| `mapRicercaToRelations` | **Sì** — legge `valid_items` | Ritorna `null` se pool vuota |
| `mapCustomAttributeImageToRelation` | **Sì** — legge `valid_items[0]` | Ritorna `null` se pool vuota |

### Conseguenza: quali `add_section_*` restano `true` con pool vuota

| Blocco | Flag | Pool vuota → flag |
|--------|------|-------------------|
| Notizie automatiche (ListaAutomatica) | `add_section_news` | **true** (tipo nel blocco basta) |
| Events (Events) | `add_section_events` | **true** (tipo nel blocco basta) |
| Banner (ListaManuale) | `add_section_banner` | **false** (`is_array(null)` = false) |
| Ricerca | `add_section_search` | **false** (dipende da valid_items) |

---

## 6. Serializzazione Alpaca — comportamento verificato

### Campi toggle (`add_section_*`)

| Stato UI | Valore nel POST |
|----------|----------------|
| Toggle attivo | `"true"` (stringa) |
| Toggle disattivo | `"false"` (stringa) |

**I toggle sono SEMPRE inclusi nel POST**, sia attivi che disattivi. Non sono mai ABSENT.

### Campi array (`section_news`, `section_banner`, ecc.)

| Stato | Valore nel POST |
|-------|----------------|
| Ha items | Array di oggetti `[{id, name}, ...]` |
| Vuoto o dipendenza falsa | **ABSENT** (non incluso nel JSON) |

I campi array dipendenti da un toggle disattivo sono **esclusi dal POST** per la dependency Alpaca.

### Dependency cascade

Quando `add_section_news = "false"`:
- `section_latest_news` → **ABSENT**
- `section_news` → **ABSENT**
- `title_news` → **ABSENT**

**Verificato empiricamente.**

### Impossibilità di distinguere intenzione utente da pool vuota

**Caso critico**: per le sezioni SENZA toggle (management, places), il campo è ABSENT sia quando:
1. La pool era vuota al caricamento del form
2. L'utente ha rimosso tutti gli items esplicitamente

**Verificato empiricamente**: rimuovere tutti i 3 items di management produce `section_management = ABSENT`, identico a quando la pool è vuota.

Per le sezioni CON toggle: `add_section_banner = "false"` arriva sia quando pool è vuota (toggle si auto-deseleziona) sia quando l'utente deseleziona intenzionalmente. Indistinguibili dal POST.

---

## 7. Flusso di save — `mapSubmittedFormToBlocks`

Costruisce l'array dei blocchi da passare a `createXML`. Per ogni sezione:
- Se il mapper ritorna un blocco → incluso nell'XML
- Se ritorna `null` → **blocco rimosso dall'XML**

### Comportamento attuale dei mapper con pool vuota

| Sezione | Toggle/flag in POST | Comportamento attuale |
|---------|--------------------|-----------------------|
| Notizie automatiche | `add_section_news="true"`, `section_latest_news="true"` | ✅ Preservata |
| Events automatici | `add_section_events="true"`, `section_next_events="true"` | ✅ Preservata |
| Banner (pool vuota) | `add_section_banner="false"`, `section_banner=ABSENT` | ❌ Rimossa |
| Ricerca (pool vuota) | `add_section_search="false"`, `section_search=ABSENT` | ❌ Rimossa |
| Management (pool vuota) | `section_management=ABSENT` | ❌ Rimossa |
| Places (pool vuota) | `section_place=ABSENT` | ❌ Rimossa |
| Singolo (pool vuota) | `main_news=ABSENT` | ❌ Rimossa (se canRemoveMainNews=true) |
| Topics (pool vuota) | `section_topic=ABSENT` | ❌ Rimossa |

---

## 8. `createXML` e `ezm_pool`

Dalla lettura di `AttributeConverter/Page.php`:

1. Per ogni blocco incluso nei `blocks` passati a `createXML`:
   - **Cancella** tutti gli items di quel blocco da `ezm_pool`
   - **Reinserisce** gli items dalla lista `valid_items` ricevuta
2. I blocchi **non inclusi** nei `blocks` non vengono toccati dalla pool

**Verificato empiricamente:** save con Singolo (valid_items=[remote_id]) → pool = 1 item con same remote_id.

### Struttura `ezm_pool`

```sql
block_id, object_id, node_id, priority, ts_publication, ts_visible, ts_hidden
```

- `ts_visible = 0` → item non visibile nel form (problema con inserimenti manuali via SQL)
- `priority` → determina l'ordine di visualizzazione (più alto = prima)
- Il riordinamento Alpaca produce priorities decrescenti nell'ordine del POST

---

## 9. Ciclo completo banner (sezione con toggle)

### Aggiunta items (pool vuota → pool piena)

1. Pool vuota → `add_section_banner = "false"` nel form
2. Utente attiva toggle → `add_section_banner = "true"` nel POST
3. Utente aggiunge 3 items → `section_banner = [{id:231}, {id:232}, {id:418}]` nel POST
4. `mapSectionBanner()` → prende struttura da sourceBlocks (`strict=true`) → imposta `type='ListaManuale'` → popola `valid_items` con remote_ids
5. `createXML()` → cancella pool banner (era vuota) → inserisce 3 items con priority 3,2,1
6. Block `d406949b` appare in `ezm_block` con tipo `ListaManuale`, pool_count=3

### Rimozione intenzionale (toggle OFF)

1. Pool piena → `add_section_banner = "true"` nel form
2. Utente disattiva toggle → `add_section_banner = "false"` nel POST
3. `section_banner = ABSENT` (dipendenza)
4. `mapSectionBanner()` → `isset($data['section_banner'][0]['id'])` = false → `return null`
5. Block rimosso dall'XML, pool cancellata

---

## 10. Ciclo completo notizie (sezione con toggle + modalità)

### Automatica → Manuale

1. `section_latest_news = "true"` nel POST → `mapSectionNews` → ritorna `$originalBlockNews` (da sourceBlocks, tipo=ListaAutomatica)
2. Block in DB: `e60d13` tipo `ListaAutomatica`, pool=0

### Modalità manuale con items

1. `section_latest_news = "false"`, `section_news = [{id:456}]` nel POST
2. `mapSectionNews()` → prende struttura da SECTION_MANAGEMENT (`strict=true`) → imposta `block_id=SECTION_NEWS` → `type=ListaManuale` → popola valid_items
3. Block `e60d13` diventa tipo `ListaManuale`, pool_count=N

### Manuale → Automatica

1. `section_latest_news = "true"` nel POST
2. `mapSectionNews()` → ritorna `$originalBlockNews` (da sourceBlocks, tipo=ListaAutomatica)
3. Block `e60d13` torna tipo `ListaAutomatica`, pool azzerata

---

## 11. Sezioni senza toggle (management, places)

- Non hanno `add_section_*` nel form né nel POST
- Sopravvivono **solo se `section_management` o `section_place` contengono items nel POST**
- Se `section_management = ABSENT` → `mapSectionManagement()` → `return null` → blocco rimosso
- **Impossibile distinguere** tra "pool vuota al caricamento" e "utente ha rimosso tutti gli items"

---

## 12. Il problema fondamentale (il bug)

Con pool vuota per blocchi `ListaManuale` (banner, management, places, ricerca):

1. `getData()` → `add_section_banner = false` (pool vuota → `is_array(null) = false`)
2. Form → toggle banner deselezionato
3. `section_banner` nascosta da Alpaca dependency
4. POST → `add_section_banner = "false"`, `section_banner = ABSENT`
5. `mapSectionBanner()` → `isset($data['section_banner'][0]['id'])` = false → `return null`
6. Block rimosso dall'XML

**Il POST è identico** sia quando la pool è vuota (accidentalmente) sia quando l'utente deseleziona il toggle intenzionalmente. Il sistema non può distinguere i due casi.
