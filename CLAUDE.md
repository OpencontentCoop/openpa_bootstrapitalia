# openpa_bootstrapitalia — guida per Claude

## ⛔ Regola assoluta sul branching git

**Non pushare MAI direttamente su `master`.** Sempre creare un branch da `master`:
1. `git checkout master && git pull`
2. `git checkout -b feature/nome` oppure `fix/nome`
3. Committare sul branch
4. **Aspettare conferma esplicita** prima di fare `push`

Nessuna eccezione.

---

## Scopo dell'estensione

Estensione eZ Publish principale per i siti PA italiani OpenCity/OpenPA. Gestisce rendering frontend (Bootstrap Italia), integrazioni esterne (Stanza del Cittadino, OAuth, CKAN), API REST, validatori, plugin Solr e moduli custom. È il repo più attivo del progetto.

---

## Struttura directory

```
classes/
  bridge/           ← integrazioni esterne (Stanza del Cittadino, booking)
  openapi/          ← costruttori schema OpenAPI REST
  indexplugins/     ← plugin ezFind/Solr (aggiungono campi all'indice)
  connectors/       ← field connectors custom
  validators/       ← validatori input per content class
  environments/     ← contesti di rendering per view mode
  handlers/         ← block, data, attribute handlers
  services/         ← operatori template PHP
  cache/            ← S3StaticCache, ChainStaticCache
design/bootstrapitalia2/
  templates/        ← template .tpl eZ Publish
  javascript/       ← JS per frontend e admin UI
  stylesheets/      ← CSS/SCSS
modules/            ← moduli eZ Publish (24 moduli, ognuno con views PHP)
settings/           ← INI di configurazione (37+ file)
translations/       ← file i18n .ts per lingua
datatypes/          ← 7 datatype custom eZ Publish
```

---

## API REST (OpenAPI)

### Come funziona

Le API REST sono esposte via `BookingEndpointFactoryProvider`, `BookingEndpointFactory`, `BookingOperationFactory`, `BookingSchemaFactory`. La struttura si applica a tutti gli endpoint:

```
EndpointFactoryProvider
  └─ EndpointFactory (path, tags)
       ├─ OperationFactory (logica GET/POST)
       └─ SchemaFactory    (schema OpenAPI + response)
```

### Endpoint booking-config

`GET /api/openapi/booking-config` — configurazione prenotazione per servizio.

- **Dati**: da materialized view PostgreSQL `ocbooking` (creata da `createViewIfNeeded()` in `StanzaDelCittadinoBooking`)
- **Post-processing PHP** in `findBookingService()`: arricchisce ogni item con `page_url`, `show_howto_in_motivation`, `view_type`
- **Schema**: `BookingSchemaFactory.php` — da aggiornare ogni volta che si aggiungono campi

**Campi item response:**

| Campo | Tipo | Fonte |
|-------|------|-------|
| `id` | int | materialized view |
| `link` | uri | materialized view (`/api/openapi/servizi/{remote_id}`) |
| `page_url` | uri | PHP: `mainNode()->url_alias` + host INI |
| `name` | string | materialized view |
| `abstract` | string | materialized view |
| `categories` | array | materialized view (tags) |
| `offices` | array | materialized view |
| `show_howto_in_motivation` | bool | PHP: `isShowHowToEnabled()` |
| `view_type` | string | PHP: `isSchedulerEnabled()` → `calendar`\|`select` |

**Refresh cache:** `GET /api/openapi/booking-config?refresh=true` — ricrea la materialized view. Disponibile solo per utenti loggati.

**Aggiungere un campo alla response:**
1. Aggiungere il valore in `findBookingService()` nel loop `foreach ($data as $i => $service)`
2. Aggiungere la proprietà in `BookingSchemaFactory::generateSchema()`
3. Se il campo deve venire dal DB: modificare la query SQL in `createViewIfNeeded()` (richiede refresh view su tutti i tenant)

---

## Materialized View `ocbooking`

Creata da `StanzaDelCittadinoBooking::createViewIfNeeded()`. Costruisce un JSONB `booking_service` per ogni servizio configurato nella tabella `ocbookingconfig`.

**Attenzione:** modificare la query SQL della view richiede di droppare e ricreare la view su ogni tenant (operazione onerosa). Preferire post-processing PHP quando possibile.

**Tabella sorgente:** `ocbookingconfig` (ufficio/servizio/luogo/calendari).

---

## Plugin Solr (indexplugins/)

Implementano `ezfIndexPlugin` con metodo `modify(eZContentObject $object, array &$docList)`.

Registrazione in `settings/ezfind.ini.append.php`:
```ini
[IndexPlugins]
Class[user]=ezfIndexUserEnabled
General[]=ezfIndexHomepage
```

**Plugin esistenti rilevanti:**
- `index_user_enabled.php` → aggiunge `attr_is_enabled_b` (bool) per filtrare utenti disabilitati
- `index_fase_bando.php` → aggiunge campo fase per i bandi
- `index_extra_geo.php` → geolocalizzazione

**Query Solr con operatore negazione:**
```
raw[attr_is_enabled_b] != false   →  !attr_is_enabled_b:false  (include documenti senza il campo)
raw[attr_is_enabled_b] = true     →  attr_is_enabled_b:true    (esclude non-indicizzati!)
```
Usare `!= false` invece di `= true` per includere oggetti non ancora re-indicizzati.

---

## Template eZ Publish

I template `.tpl` usano la sintassi eZ Publish 5.x:
- `{ }` per tutto (variabili, fetch, operatori)
- `|` per operatori: `{'stringa'|i18n('bootstrapitalia/booking')}`
- `fetch(content, node/list, hash(...))` per query contenuti
- `{attribute_view_gui attribute=$obj.data_map.nome}` per attributi

**Override system:** `design/bootstrapitalia2/override/templates/override.ini.append.php`
Il primo match vince. Campi: `Source`, `MatchFile`, `Match[class_identifier]`, `Match[template]`.

**Template booking:**
```
design/bootstrapitalia2/templates/bootstrapitalia/booking/
  error.tpl       ← gestione errori API (messaggi per codice errore)
  step_*.tpl      ← step del wizard
```

**`error.tpl` — gestione errori per codice:**
- `.error-message-generic` — mostrato di default
- `.error-message-code[data-code="X"]` — mostrato per codice specifico (reservation_limit, daily_reservation_limit, ecc.)
- `.error-goto-datetime` — bottone "scegli altro periodo", visibile solo per errori limite prenotazione
- Logica JS in `design/bootstrapitalia2/javascript/jquery.booking.js` → `displayError(jqXHR)`

---

## i18n (traduzioni con oci18n)

Per i dettagli tecnici su come funziona lo strumento vedere `html/vendor/opencontent/oci18n/CLAUDE.md`.

### Workflow rapido

1. Aggiungere la stringa nel template: `{'Nuova stringa'|i18n('bootstrapitalia/booking')}`
2. Aggiungerla in `translations/untranslated/translation.ts` nel contesto corretto
3. Push term e traduzioni su POEditor via API diretta (vedi sotto — **preferito**)
4. Pull: `POEDITOR_TOKEN=$PO_ORG_TOKEN php vendor/bin/oci18n -r --no-colors`
   - Lingua: `0`=it, `1`=de, `2`=en
   - Estensione: selezionare `openpa_bootstrapitalia`
   - Content types / contenuti / tags → `n`

Esistono anche script PHP per il push (`php vendor/opencontent/oci18n/bin/push_ts_terms_to_poeditor.php -r --no-colors`), ma non gestiscono in modo affidabile il `context` del term — preferire sempre le API dirette.

### ⚠️ `oci18n -r` (pull) può cancellare traduzioni non correlate

Il pull sembra fare una "full sync" col remote POEditor invece di un merge
additivo: se sul progetto POEditor manca, o non è taggata correttamente con
l'estensione giusta, una entry già presente nel `.ts` locale, il pull la
elimina dal file locale — anche se non ha niente a che fare coi term che si
stavano aggiungendo. Il sintomo tipico è un `git diff --stat` con molte più
righe cambiate di quante ne giustifichino i nuovi term (nel caso che ha fatto
emergere il problema: ~12 term aggiunti, 13 entry preesistenti sparite,
confermato non un riordino con un diff riga-per-riga ordinato sui `<source>`).

**Prima di committare un pull**, controllare `git diff --stat`: se il
numero di righe cambiate è molto maggiore di quanto giustificato dai nuovi
term, NON committare — fare `git checkout -- translations/<lingua>/translation.ts`
e aggiungere il nuovo blocco `<context>` a mano (XML diretto, subito prima
di `</TS>`), lasciando intatto il resto del file. Poi verificare con:
```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
docker exec sito-comunale-dev-app-1 php -r '
require_once "autoload.php";
$script = eZScript::instance(["description" => "check i18n"]);
$script->startup(); $script->initialize();
echo ezpI18n::tr("CONTESTO", "Stringa inglese") . "\n";
$script->shutdown();
'
```

### Push via API POEditor (preferito)

Token: `2c1c4091bc25d3d5eb6aa365ceaeb537` — Progetto ID: `740564`

**Aggiungere un term:**
```bash
curl -s -X POST https://api.poeditor.com/v2/terms/add \
  -d api_token=2c1c4091bc25d3d5eb6aa365ceaeb537 \
  -d id=740564 \
  --data-urlencode 'data=[{"term":"Nome term","context":"bootstrapitalia","tags":["openpa_bootstrapitalia"]}]'
```

**Aggiungere una traduzione (ripetere per ogni lingua):**
```bash
curl -s -X POST https://api.poeditor.com/v2/translations/add \
  -d api_token=2c1c4091bc25d3d5eb6aa365ceaeb537 \
  -d id=740564 \
  -d language=it \
  --data-urlencode 'data=[{"term":"Nome term","context":"bootstrapitalia","translation":{"content":"Testo tradotto"}}]'
```

Lingue disponibili: `it`, `en`, `de`, `es`, `fr`, `pt-br`

### Contesti principali

Il **context** in POEditor identifica univocamente un term insieme al suo testo: due term con lo stesso testo ma contesti diversi sono term distinti. Qui corrisponde al namespace i18n usato nei template eZ.

| Contesto | Uso |
|---------|-----|
| `bootstrapitalia` | UI generale |
| `bootstrapitalia/booking` | Widget prenotazione |
| `bootstrapitalia/permissions` | Gestione permessi utenti |

---

## Bridge Stanza del Cittadino

`classes/bridge/StanzaDelCittadinoBridge.php` — singleton, connessione alla piattaforma SDC.

`classes/bridge/StanzaDelCittadinoBooking.php` — logica booking (materalized view, config, draft meeting, book).

`classes/bridge/BuiltinAppFactory.php` — factory per app embedded (booking, helpdesk, inefficiency, payment). Versioni V1/V2.

---

## Autenticazione OAuth (SPID/CIE)

`classes/bridge/BootstrapItaliaLoginOauth.php` — gestisce login OAuth2 con provider SPID/CIE. Usa `league/oauth2-client` v2.

Configurazione in `settings/openpa.ini.append.php` sotto `[AccessPage]`.

---

## Moduli principali

| Modulo | View principali |
|--------|----------------|
| `bootstrapitalia` | `permissions`, `booking_config`, `theme`, `bridge`, `widget` |
| `prenota_appuntamento` | widget prenotazione appuntamento |
| `area_personale` | area personale cittadino |
| `accedi` | login/logout |
| `login-oauth` | OAuth SPID/CIE |
| `richiedi_assistenza` | helpdesk |
| `segnala_disservizio` | segnalazioni |
| `pagamento` | pagamenti |

**Modulo `bootstrapitalia/booking_config`** (`modules/bootstrapitalia/booking_config.php`): pagina admin per configurare i calendari per ufficio/servizio/sede.

### Ordine dei servizi nella pagina di scoperta (`prenota_appuntamento`)

Quando si arriva a `/prenota_appuntamento` senza un `service_id`, viene mostrata la pagina di scoperta con i servizi raggruppati per categoria. L'ordine è gestito da `StanzaDelCittadinoBooking::getServicesByCategories()` con questo SQL:

```sql
ORDER BY type_attributes._priority DESC, type_attributes.name ASC
```

Dove `_priority` = `ezcontentobject_tree.priority` del nodo del servizio pubblico.

**Conseguenza:** un servizio con priorità > 0 appare prima di tutti gli altri nella sua categoria, indipendentemente dall'ordine alfabetico. Gli altri (priorità = 0) sono ordinati alfabeticamente per nome.

**Come impostare/azzerare la priorità:** dal backend eZ, aprire il nodo del servizio pubblico → tab _Localizzazioni_ → campo _Priorità_. Impostare a 0 per tornare all'ordine alfabetico puro.

---

## Sistema FAQ (`faq_root`/`faq_section`/`faq_group`/`faq`)

Classi installate dal modulo opzionale `installer/modules/faq/` (repo `installer`): `faq_root` (radice), `faq_section`, `faq_group`, `faq` (singola domanda/risposta). Ruolo dedicato: `Editor Faq`.

### Le due viste alternative, controllate da un solo ini

`openpa/full/faq_root.tpl` (design `bootstrapitalia2`) si comporta in modo completamente diverso a seconda di `[ViewSettings] FaqTreeView` (`openpa.ini`):

- **`disabled`** (default): mostra **tutte** le FAQ dirette (classe `faq`) in un unico accordion piatto (`include uri='design:parts/faq_accordion.tpl'`) — nessuna gerarchia.
- **`enabled`**: **non guarda più le FAQ dirette** — fa un `fetch(content, list_count, ...)` filtrato su `faq_section`/`faq_group` come figli diretti del nodo, e li mostra come griglia di card (per navigare a sezioni prima di arrivare alle domande).

**Attenzione**: con `FaqTreeView=enabled`, se non esistono ancora contenuti di classe `faq_section`/`faq_group` sotto il nodo radice, il blocco `{if $children_count}` è falso e **non viene mostrato nulla** — niente fallback all'accordion. La pagina "Domande frequenti" appare vuota anche se ci sono FAQ dirette pubblicate. Verificato in locale (2026-09-11): serve creare almeno una `faq_section`/`faq_group` prima di abilitare la vista ad albero, altrimenti si perde la visualizzazione delle FAQ esistenti.

---

## Link nel footer

### Come funziona

Il template `design/bootstrapitalia2/templates/page_footer.tpl` chiama `fetch('openpa', 'footer_links')` che esegue `OpenPaFunctionCollection::fetchFooterLinks()` in `extension/openpa/classes/openpafunctioncollection.php`.

La funzione ha **due code path**:

**Path 1 — Homepage con attributo `link_nel_footer`** (caso normale):
Se la Homepage ha la classe `homepage` e l'attributo `link_nel_footer` (ezobjectrelationlist) ha contenuto, usa quei nodi. Per ogni item nella relation_list chiama `eZContentObjectTreeNode::fetch((int)$item['node_id'])` — se il nodo non esiste o non è accessibile all'utente anonimo, viene **scartato silenziosamente** senza errori.

**Path 2 — Fallback INI** (istanze vecchie / classe non homepage):
Legge da `openpa.ini` sezione `[LinkSpeciali]`:
```ini
[LinkSpeciali]
NodoPrivacy=
NodoNoteLegali=
NodoDichiarazione=
NodoCredits=
```

### Constraint automatici al salvataggio

Quando si salva la homepage dal pannello **`/backend/bootstrapitalia/info`**, il file `modules/bootstrapitalia/info.php` applica un meccanismo di constraints: se uno dei nodi obbligatori è assente da `link_nel_footer`, viene aggiunto automaticamente. I nodi vincolati sono identificati per remote_id:

| Remote ID | Nodo | `data-element` nel footer |
|-----------|------|--------------------------|
| `privacy-policy-link` | Privacy | `privacy-policy-link` |
| `931779762484010404cf5fa08f77d978` | Note legali | `legal-notes` |
| `accessibility-link` | Dichiarazione di accessibilità | `accessibility-link` |

**Attenzione:** il constraint si attiva solo salvando tramite `/backend/bootstrapitalia/info`. Salvare la homepage dal normale edit del backend (`/content/edit/...`) **non** attiva questa logica.

### `data-element` sui link del footer

Il valore dell'attributo `data-element="..."` su ogni link viene calcolato da `classes/services/data_element.php` in base al remote_id del nodo. Se il nodo non ha un remote_id riconosciuto, il link viene comunque renderizzato ma con il `data-element` basato sul class identifier.

### Troubleshooting: link mancante nel footer

1. Verificare che il nodo esista e sia visibile: `curl https://<sito>/opendata/api/content/browse/2` — cercare il nodo tra i figli della homepage
2. Verificare il remote_id del nodo: deve corrispondere ai valori nella tabella sopra
3. Se il nodo esiste ma non appare: il suo `node_id` in `link_nel_footer` è probabilmente errato/stale
4. **Fix rapido:** aprire `/backend/bootstrapitalia/info` e salvare — i constraints riaggiungeranno i nodi mancanti
5. **Fix manuale:** editare la Homepage dal backend, aggiungere manualmente il nodo al campo "Link nel footer"
6. Dopo il fix: svuotare la cache Varnish della homepage

---

## Build CSS

I CSS sono compilati con npm. Ci sono due design attivi con la loro directory `_build`:

```bash
# design bootstrapitalia2 (il più usato)
cd design/bootstrapitalia2/_build
npm run build

# design bootstrapitalia2110
cd design/bootstrapitalia2110/_build
npm run build
```

Eseguire entrambi dopo modifiche ai file SCSS. I CSS compilati vengono scritti nella directory `stylesheets/` del rispettivo design.

---

## Query language ocopendata (find)

Il sistema di ricerca usa una query language propria, sia lato JS che PHP. È il modo principale per interrogare i contenuti.

### JS: `$.opendataTools`

Esposto dall'estensione `ocopendata` (`extension/ocopendata/design/standard/javascript/jquery.opendataTools.js`).

```javascript
$.opendataTools.find(query, callback)      // ricerca con paginazione
$.opendataTools.findOne(query, callback)   // primo risultato, cached in sessionStorage
$.opendataTools.findAll(query, callback)   // tutte le pagine in parallelo
$.opendataTools.geoJsonFind(query, cb)     // risultati GeoJSON
$.opendataTools.contentClass(name, cb)     // schema di una classe
$.opendataTools.tagsTree(identifier, cb)   // struttura di un tag tree
```

Endpoint REST sottostante: `GET /opendata/api/content/search/?q=<query>`

Response:
```json
{
  "searchHits": [
    {
      "metadata": { "id": 123, "mainNodeId": 456, "class": "public_service", "name": {...} },
      "data": { "title": {...}, "abstract": {...} }
    }
  ],
  "nextPageQuery": "classes [public_service] limit 10 offset 10"
}
```

### Sintassi query language

**Filtri (sentences):**
```
name = 'valore'                    → uguaglianza
name != 'valore'                   → disuguaglianza
name contains 'parola'             → full-text (wildcard)
id in [1, 2, 3]                    → lista OR
id !in [1, 2, 3]                   → escludi lista
created range [2024-01-01, 2024-12-31]  → intervallo date
raw[meta_class_identifier_ms] = 'article'  → campo Solr diretto (senza mapping)
```

**Parametri:**
```
classes [public_service, organization]   → filtra per content class identifier
limit 50                                 → max risultati
offset 10                                → paginazione
sort [name=>asc, created=>desc]          → ordinamento multi-campo
subtree 43                               → solo sotto nodo 43
language 'ita-IT'                        → filtra per lingua
facets [type]                            → aggregazioni
select-fields [id, name, abstract]       → proiezione campi
```

**Esempio completo:**
```javascript
$.opendataTools.find(
  "classes [public_service] and raw[attr_topic_ids_lk] in ['123'] sort [name=>asc] limit 20",
  function(response) {
    response.searchHits.forEach(function(hit) {
      console.log(hit.metadata.name['ita-IT']);
    });
  }
);
```

### PHP: QueryBuilder

```php
$qb = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
$q = $qb->instanceQuery("classes [public_service] limit 10");
$result = eZFunctionHandler::execute('ezfind', 'search', array_merge($q->convert(), ['as_objects' => false]));
// $result['SearchResult'] → array di eZFindResultNode (usare ->attribute('campo'), non l'accesso come array)
```

**Attenzione**: il metodo è `convert()`, non `query()` (quest'ultimo non esiste
sulla classe `Query` restituita da `instanceQuery()` — verificato il
2026-09-15, un esempio precedente in questo file usava `query()` ed era
sbagliato/mai testato). Riferimento a un uso reale verificato:
`classes/handlers/data/albo_pretorio.php`.

### Operatore `raw[]` e negazione

`raw[fieldname]` bypassa il mapping e accede direttamente al campo Solr.

`!= value` genera `!fieldname:value` in Solr — include anche documenti dove il campo non esiste.
`= value` genera `fieldname:value` — esclude documenti senza il campo (problematico con re-indicizzazione parziale).

---

## Lock Edit (interfaccia redattore semplificata)

### Cos'è

Un'interfaccia di editing semplificata per utenti con permesso `bootstrapitalia/opencity_locked_editor` (redattori con accesso limitato). Invece dell'editor eZ completo, mostrano un form con soli i campi necessari per la loro operatività quotidiana (titolo, testo, immagini, selezione blocchi homepage, ecc.).

Accessibile dal toolbar del sito tramite il link "Modifica" per gli utenti con il permesso.

Entry point: modulo `ocopendata_forms`, connector `lock_edit` → `LockEditConnector.php` (verifica il permesso, carica il connector corretto via factory, renderizza il form).

### Risoluzione connector (Factory)

`LockEditConnectorFactory::load()` risolve il connector per un oggetto con questa priorità:

1. `toCamelCase(remote_id) + LockEditClassConnector` — per oggetti specifici (es. la homepage principale)
2. `toCamelCase(class_identifier) + LockEditClassConnector` — per tutti gli oggetti di una classe

`toCamelCase` usa `eZCharTransform` per normalizzare l'identificatore, poi converte underscore in CamelCase con prima lettera maiuscola.

### Gerarchia classi

```
LockEditClassConnector          (abstract base)
  └─ PageLockEditClassConnector (abstract, per contenuti "page" con zone/block)
       ├─ HomepageLockEditClassConnector   → remote_id homepage principale
       ├─ FrontpageLockEditClassConnector  → class_identifier frontpage
       ├─ NewsLockEditClassConnector       → class_identifier news/comunicati
       ├─ LiveLockEditClassConnector       → class_identifier live
       └─ PaginaSitoLockEditClassConnector → class_identifier pagina_sito
```

### Connector concreti

| File | Oggetto target | Note |
|------|---------------|------|
| `Page/HomepageLockEditClassConnector.php` | Homepage principale | Gestisce eventi, slider, sezioni homepage |
| `Page/FrontpageLockEditClassConnector.php` | Frontpage | Sottopagine tematiche |
| `Page/NewsLockEditClassConnector.php` | News / comunicati | |
| `Page/LiveLockEditClassConnector.php` | Live events | |
| `Page/PaginaSitoLockEditClassConnector.php` | Pagine sito generiche | |

### Blocco "prossimi eventi" in homepage

`HomepageLockEditClassConnector` gestisce il blocco eventi con due modalità (stesso block UUID `9cd237a12fdb73a490fee0b01a3fab9d`):

- **Automatico** (`section_next_events=true`): usa il blocco `[Eventi]` originale con environment `FullCalendar` → filtra solo eventi futuri via parametri GET `start`/`end` passati al search Solr
- **Manuale** (`section_calendar` con item selezionati): sostituisce il view `lista_card` con `valid_items` = lista remote_id scelti dal redattore → **nessun filtro per data**, mostra anche eventi passati

Logica in `mapSectionEvents()` di `HomepageLockEditClassConnector.php`.

### Template blocchi homepage e `InstanceSettings.InstallerDirectory` — trappola nota

`LockEditConnectorFactory::load()` chiama `setInstallerDataDir(OpenPAINI::variable('InstanceSettings', 'InstallerDirectory', '../installer'))`. Questo path è usato da `HomepageLockEditClassConnector::fetchSourcePathInfo()` per trovare `contents/OpenCity.yml` — il template YAML da cui viene letta la definizione "di fabbrica" di un blocco (`view`, `custom_attributes`) quando un redattore attiva per la **prima volta** una sezione homepage mai configurata prima (es. "Siti tematici"). Stesso meccanismo, path diverso, per `LiveLockEditClassConnector` (`contenttrees/OpenCity/Vivere-il-comune.yml`).

`InstanceSettings.InstallerDirectory` è pensato per selezionare il pacchetto installer del prodotto corrente: il default (`./extension/openpa_bootstrapitalia/data/installer`) è quello sempre aggiornato assieme all'estensione; il prodotto ASL usa `AslLockEditConnectorFactory` con un default diverso (`opencity-asl-installer`).

**Trappola**: se questo INI viene sovrascritto a runtime per puntare a una directory che **non** contiene un `OpenCity.yml` aggiornato — ad esempio su alcuni tenant Boat migrati da SaaS, dove il template di provisioning punta a `./vendor/opencity-labs/opencity-installer`, la cui copia locale può essere uno snapshot/export dei contenuti del tenant congelato al momento della migrazione, non il template generico — `findBlockById(..., strict=true)` non trova mai il blocco per una sezione mai attivata prima. Il salvataggio la scarta silenziosamente: risposta 200, nessun errore, XML invariato. Diagnosticato su ticket Freshdesk #31723 (2026-09-17); fix applicato lato configurazione (rimozione dell'override `EZINI_openpa__InstanceSettings__InstallerDirectory` dallo stack file del tenant, quando presente) — nessun fix di codice ancora fatto per rendere il connector indipendente da questo INI.

---

## Export ANAC (Amministrazione Trasparente)

Sistema per produrre export CSV/JSON conformi agli schemi ANAC (art. 4-bis,
31, 13) a partire dai contenuti del sito, con url pubblici versionati e
naming datato — namespace `OpenPABootstrapItalia\Anac` in `classes/anac/` +
modulo `modules/anac_export/`. Vedi `classes/anac/CLAUDE.md` per architettura
completa, meccanismo di pubblicazione url, vocabolario controllato,
gestione errori e stato di avanzamento (in sviluppo, GitLab cms#475/#477/#478/#479).
Controparte lato content model/installer: `installer/modules/trasparenza-c1/CLAUDE.md`.

---

## File rilevanti

| File | Ruolo |
|------|-------|
| `classes/bridge/StanzaDelCittadinoBooking.php` | Booking API, materialized view `ocbooking`, `findBookingService()` |
| `classes/openapi/Booking/BookingOperationFactory.php` | Handler GET `/api/openapi/booking-config` |
| `classes/openapi/Booking/BookingSchemaFactory.php` | Schema OpenAPI response booking-config |
| `classes/openapi/BookingEndpointFactoryProvider.php` | Registrazione endpoint booking |
| `design/bootstrapitalia2/javascript/jquery.booking.js` | JS widget prenotazione (displayError, gotoStep, ecc.) |
| `design/bootstrapitalia2/templates/bootstrapitalia/booking/error.tpl` | Template errori booking |
| `design/bootstrapitalia2/templates/bootstrapitalia/permissions.tpl` | Gestione utenti/permessi con filtro enabled |
| `classes/indexplugins/index_user_enabled.php` | Plugin Solr: campo `attr_is_enabled_b` per utenti |
| `settings/ezfind.ini.append.php` | Registrazione plugin Solr |
| `translations/untranslated/translation.ts` | Stringhe da tradurre |
| `translations/ita-IT/translation.ts` | Traduzioni italiane (aggiornate da POEditor) |
| `modules/bootstrapitalia/info.php` | Pannello impostazioni homepage: salvataggio `link_nel_footer` con constraint automatici |
| `classes/services/data_element.php` | Mappa remote_id → valore `data-element` per link nel footer e navigation |
| `design/bootstrapitalia2/templates/page_footer.tpl` | Template footer: rendering `footer_links`, contatti, copyright |
| `classes/connectors/LockEdit/LockEditConnector.php` | Entry point Lock Edit: verifica permesso, delega a factory |
| `classes/connectors/LockEdit/LockEditConnectorFactory.php` | Factory: risolve connector per remote_id o class_identifier |
| `classes/connectors/LockEdit/LockEditClassConnector.php` | Abstract base per tutti i connector Lock Edit |
| `classes/connectors/LockEdit/PageLockEditClassConnector.php` | Abstract base per connector page-type (zone/block) |
| `classes/connectors/LockEdit/Page/HomepageLockEditClassConnector.php` | Connector homepage: blocco eventi (auto vs manuale), slider, sezioni |
