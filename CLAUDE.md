# openpa_bootstrapitalia — guida per Claude

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

## i18n (traduzioni)

**Workflow:**
1. Aggiungere la stringa in `translations/untranslated/translation.ts` nel contesto giusto
2. Push su POEditor: `POEDITOR_TOKEN=... php vendor/bin/oci18n -p 740564 --push translations/untranslated/translation.ts`
3. Tradurre su POEditor (progetto ID `740564` — "Opencity Italia - CMS - framework"), tag `openpa_bootstrapitalia`
4. Pull traduzioni: `POEDITOR_TOKEN=... php vendor/bin/oci18n -r` (interattivo: selezionare lingua)

**Contesti principali:**
- `bootstrapitalia` — UI generale
- `bootstrapitalia/booking` — widget prenotazione
- `bootstrapitalia/permissions` — gestione permessi

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
$result = eZFunctionHandler::execute('ezfind', 'search', array_merge($q->query(), ['as_objects' => false]));
// $result['SearchResult'] → array di hit con campi Solr
```

### Operatore `raw[]` e negazione

`raw[fieldname]` bypassa il mapping e accede direttamente al campo Solr.

`!= value` genera `!fieldname:value` in Solr — include anche documenti dove il campo non esiste.
`= value` genera `fieldname:value` — esclude documenti senza il campo (problematico con re-indicizzazione parziale).

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
