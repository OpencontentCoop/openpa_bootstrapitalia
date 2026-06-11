# Piano: `include_expired` nelle regole di rappresentazione (Amministrazione Trasparente)

## Obiettivo

Aggiungere un'opzione `include_expired:true` alle regole di rappresentazione delle pagine
`pagina_trasparenza` per mostrare nelle tabelle DataTables anche i documenti in stato
`privacy.expired` (normalmente nascosti agli utenti anonimi), senza link cliccabile
per i documenti expired.

---

## Contesto tecnico

- Le regole di rappresentazione sono stringhe `&`-separate nell'attributo `fields` del
  nodo `pagina_trasparenza`, tipo:
  `include_expired:true|document|name*,abstract,file|3`
- I documenti `privacy.expired` **sono indicizzati in Solr** (confermato da `albo_pretorio.php`
  che li esclude esplicitamente con `state !in ['privacy.expired']`)
- Passare `[]` come `$limitation` a `ContentSearch::search()` bypassa le access policy
  (pattern già usato in `block_opendata_queried_contents.php` e `albo_pretorio.php`)
- Il client non trasmette nessun parametro di sicurezza: tutto è letto dal CMS server-side

---

## Approccio scelto: module view proxy

Solo `openpa_bootstrapitalia` viene toccata (nessuna modifica a `ocopendata`).

Il template usa il nuovo endpoint solo quando `include_expired` è attivo;
altrimenti continua a usare `/opendata/api/datatable/search/` come oggi.

---

## File da modificare/creare

### 0. `settings/site.ini.append.php` (~1 riga)

Aggiungere alla `PolicyOmitList` per rendere il view accessibile agli utenti anonimi
(senza di esso eZ Publish restituisce 410):

```ini
PolicyOmitList[]=bootstrapitalia/trasparenza_datatable
```

### 1. `classes/services/content_trasparenza.php` (~15 righe)

In `parseTableFieldsParameter()`, aggiungere `include_expired` a
`$availableFieldsWithCallback`:

```php
'include_expired' => function ($parameter) {
    return $parameter == 1 || $parameter == 'true' || $parameter == '1';
},
```

Aggiungere nel `$result` restituito:

```php
'include_expired' => $data['include_expired'] ?? false,
```

### 2. `modules/bootstrapitalia/module.php` (~8 righe)

Registrare la nuova view e la relativa funzione:

```php
$ViewList['trasparenza_datatable'] = [
    'script'   => 'trasparenza_datatable.php',
    'default_navigation_part' => 'ezsetupnavigationpart',
    'functions' => ['trasparenza_datatable'],
    'params' => ['NodeID', 'TableIndex'],
    'unordered_params' => [],
];

// in fondo, accanto agli altri $FunctionList vuoti:
$FunctionList['trasparenza_datatable'] = [];
```

### 3. `modules/bootstrapitalia/trasparenza_datatable.php` (~70 righe) — nuovo file

```php
// 1. Legge nodeId e tableIndex dalla URL
$nodeId     = (int)$Params['NodeID'];
$tableIndex = (int)$Params['TableIndex'];

// 2. Carica il nodo
$node = eZContentObjectTreeNode::fetch($nodeId);
// → 404 se non trovato

// 3. Legge le regole di rappresentazione dall'attributo 'fields'
$fieldsString = $node->attribute('object')
                     ->attribute('data_map')['fields']
                     ->toString();
$parameters = explode('&', $fieldsString);
$tables = [];
foreach ($parameters as $p) {
    $t = ObjectHandlerServiceContentTrasparenza
            ::parseTableFieldsParameter($p, $node);
    if (!empty($t)) $tables[] = $t;
}
$fields = $tables[$tableIndex] ?? null;
// → 404 se indice non trovato

// 4. Determina la limitation in base a include_expired
$includeExpired = $fields['include_expired'] ?? false;
$limitation     = $includeExpired ? [] : null;

// 5. Prepara ContentSearch con ambiente datatable
// NOTA: usare ezpRestHttpRequestParser (pattern da api.php di ocopendata),
// NON leggere $_GET direttamente — filterQuery() legge da $this->request->get
$contentSearch      = new ContentSearch();
$currentEnvironment = EnvironmentLoader::loadPreset('datatable');
$parser             = new ezpRestHttpRequestParser();
$request            = $parser->createRequest();
$currentEnvironment->__set('request', $request);
$contentSearch->setEnvironment($currentEnvironment);

// 6. Esegue la ricerca
// NOTA: con l'environment datatable, search() restituisce già un array nel
// formato DataTables (draw/recordsTotal/data) perché filterSearchResult()
// è chiamato internamente da SearchGateway — NON va richiamato esternamente.
$query  = $fields['query'];
$result = (array)$contentSearch->search($query, $limitation);

// 7. Post-processing: aggiunge is_expired ai metadata di ogni hit
// stateIdentifiers è incluso da OpenPABootstrapItaliaContentEnvironmentSettings::filterMetaData()
if ($includeExpired) {
    foreach ($result['data'] as &$hit) {
        $states = $hit['metadata']['stateIdentifiers'] ?? [];
        $hit['metadata']['is_expired'] = in_array('privacy.expired', $states);
    }
}

// 8. Restituisce JSON
header('Content-Type: application/json');
echo json_encode($result);
eZExecution::cleanExit();
```

### 4. `design/bootstrapitalia2/templates/openpa/full/parts/amministrazione_trasparente/children_table_fields.tpl` (~20 righe)

**URL condizionale** (sostituisce la riga con `opendata/api/datatable/search`).
Attenzione: usare underscore (`trasparenza_datatable`), non trattino:

```tpl
{if $fields.include_expired}
  {def $datatable_url = concat('/bootstrapitalia/trasparenza-datatable/', $node.node_id, '/', $table_index)|ezurl(no,full)}
{else}
  {def $datatable_url = 'opendata/api/datatable/search'|ezurl(no,full)}
{/if}
```

**Nel render JS della prima colonna**, aggiungere il check expired:

```javascript
{if $fields.include_expired}
  if (!row.metadata.is_expired) {
    link = "{'/openpa/object/'|ezurl(no)}/"+row.metadata.id;
  }
{else}
  link = "{'/openpa/object/'|ezurl(no)}/"+row.metadata.id;
{/if}
```

---

## Formato regola di rappresentazione aggiornato

```
[include_expired:true|][parent:<nodeId>|][filters:<queryFilters>|][group_by:<id>|][order_by:+<attr>|]
<classIdentifier>|<field1>[,<field2>...]|<depth>
```

Esempio per Provvedimenti dirigenti con expired visibili:
```
include_expired:true|filters:document_type in ['Determinazione']|document|name*,abstract,file|3
```

### Filtro per anno (già supportato, nessuna modifica necessaria)

Per aggiungere un filtro per anno su un campo data, usare il campo Solr
`subattr_<identifier>___year____dt` già indicizzato da `ocSolrDocumentFieldDate`:

```
group_by:raw[subattr_date___year____dt]|document|name*,abstract,file|3
```

Il meccanismo di facet/filtro per anno è già gestito da `content_trasparenza.php`
e dal template (`ends_with('year____dt]')` con range filter).

---

## Punti aperti / da verificare

1. ~~**`filterSearchResult()` call chain**~~ — **RISOLTO**: `filterSearchResult()` è chiamato
   internamente da `SearchGateway::search()`. Il module view chiama solo `$contentSearch->search()`
   e il risultato è già nel formato DataTables (`draw`, `recordsTotal`, `data`, ecc.).

2. ~~**`ezpRestRequest` vs `$_GET` nativo**~~ — **RISOLTO**: usare il pattern di `api.php`:
   `ezpRestHttpRequestParser` + `createRequest()`.

3. ~~**Stato `privacy.expired` disponibile su tutti i tenant**~~ — **NON BLOCCANTE**:
   lo stato viene creato dall'installer su ogni tenant nuovo, e lazily da `openpabootstrapitaliaoperators.php`
   al primo render. Un tenant senza lo stato non ha documenti expired → feature non si applica.

4. ~~**Accesso diretto al file allegato**~~ — **NON È UN RISCHIO**: `kernel/content/download.php`
   verifica `can_read` prima di servire il file. `Anonymous.yml` limita `content/read` a
   `StateGroup_privacy: [public]` → i documenti `privacy.expired` restituiscono 403 al download.
   Il bypass ACL riguarda solo la query Solr per il listing.

---

## Test

### PHPStan (senza Docker avviato)

```bash
cd sito-comunale-dev
docker compose run --rm app vendor/bin/phpstan analyse \
  extension/openpa_bootstrapitalia/classes/services/content_trasparenza.php \
  extension/openpa_bootstrapitalia/modules/bootstrapitalia/trasparenza_datatable.php
```

### Test di integrazione PHP (`tests/test_include_expired_trasparenza.php`)

Richiedono Docker up (DB + Solr). Stesso pattern degli esistenti in `tests/`.

```bash
docker compose exec -T app sh -c \
  'php /var/www/html/extension/openpa_bootstrapitalia/tests/test_include_expired_trasparenza.php 2>&1'
```

| # | Input `parseTableFieldsParameter` | Assert |
|---|-----------------------------------|--------|
| 1 | `include_expired:true\|document\|name*,file\|3` | `$result['include_expired'] === true` |
| 2 | `document\|name*,file\|3` (senza parametro) | `$result['include_expired'] === false` |
| 3 | `include_expired:false\|document\|...` | `$result['include_expired'] === false` |
| 4 | `include_expired:1\|document\|...` | `$result['include_expired'] === true` |
| 5 | Tabella senza `include_expired` → `$limitation = null` | `$limitation === null` |
| 6 | Tabella con `include_expired:true` → `$limitation = []` | `$limitation === [] && is_array($limitation)` |

### Test di sicurezza HTTP

**A) Endpoint standard non espone expired:**
```bash
curl -s "https://opencity.localtest.me/api/opendata/v2/content/search/classes%20%5Bdocument%5D%20and%20state%20in%20%5B%27privacy.expired%27%5D" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('searchHits:', len(d.get('searchHits',[])))"
# Atteso: searchHits: 0
```

**B) Proxy su tabella senza `include_expired` non fa bypass ACL:**
Chiamare `/bootstrapitalia/trasparenza-datatable/{nodeId}/{tableIndex}` su un nodo
la cui configurazione `fields` non contiene `include_expired:true` → nessun documento
`privacy.expired` nella risposta.

---

## Stima

| Attività | Tempo |
|----------|-------|
| `content_trasparenza.php` | 1h |
| `modules/bootstrapitalia/trasparenza_datatable.php` (nuovo) | 3h |
| `children_table_fields.tpl` | 1h |
| `tests/test_include_expired_trasparenza.php` | 1h |
| **Totale** | **~1 giorno** |
