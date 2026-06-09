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

### 2. `modules/bootstrapitalia/module.php` (~5 righe)

Registrare la nuova view:

```php
'trasparenza_datatable' => array(
    'script'   => 'trasparenza_datatable.php',
    'default_navigation_part' => 'ezsetupnavigationpart',
    'functions' => array('view'),
),
```

### 3. `modules/bootstrapitalia/trasparenza_datatable.php` (~70 righe) — nuovo file

Logica:

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
$contentSearch      = new ContentSearch();
$request            = /* costruisce request da $_GET (draw, columns, order, start, length, search) */;
$currentEnvironment = EnvironmentLoader::loadPreset('datatable');
$currentEnvironment->__set('request', $request);
$contentSearch->setEnvironment($currentEnvironment);

// 6. Esegue la ricerca
$query  = $fields['query'];
$search = $contentSearch->search($query, $limitation);

// 7. Post-processing: aggiunge is_expired ai metadata
if ($includeExpired) {
    foreach ($search->searchHits as &$hit) {
        $states = $hit['metadata']['stateIdentifiers'] ?? [];
        $hit['metadata']['is_expired'] = in_array('privacy.expired', $states);
    }
}

// 8. Formatta risposta DataTables e restituisce JSON
$response = $currentEnvironment->filterSearchResult($search, ...);
header('Content-Type: application/json');
echo json_encode($response);
eZExecution::cleanExit();
```

### 4. `design/bootstrapitalia2/templates/openpa/full/parts/amministrazione_trasparente/children_table_fields.tpl` (~20 righe)

**URL condizionale:**

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

---

## Punti aperti / da verificare

1. **`filterSearchResult()` call chain**: verificare che `EnvironmentLoader::loadPreset('datatable')`
   + `filterSearchResult()` esplicito nel module view restituisca il JSON nel formato DataTables
   corretto (draw, recordsTotal, recordsFiltered, data). Il punto non è chiaro al 100% senza test.

2. **`ezpRestRequest` vs `$_GET` nativo**: il `DatatableEnvironmentSettings::filterQuery()`
   legge da `$this->request->get`. Nel module view occorre costruire un oggetto request
   compatibile. Alternativa: leggere `$_GET` direttamente e bypassare l'environment,
   replicando solo la parte di sorting/pagination (~20 righe extra).

3. **Stato `privacy.expired` disponibile su tutti i tenant**: verificare che lo state group
   `privacy` con stato `expired` sia creato su tutti i tenant che useranno la feature
   (viene creato da `OpenPABase::initStateGroup` al primo utilizzo).

4. **Accesso diretto al file allegato**: i file (`/content/download/...`) di documenti expired
   sono tecnicamente raggiungibili se si conosce l'URL. Accettato come rischio residuo perché
   `privacy.expired` riguarda contenuti che erano già pubblici.

---

## Stima

| Attività | Tempo |
|----------|-------|
| `content_trasparenza.php` | 1h |
| `modules/bootstrapitalia/trasparenza_datatable.php` (nuovo) | 4h |
| `children_table_fields.tpl` | 1h |
| Test e debug (punto 1 e 2 sopra) | 2h |
| **Totale** | **~1.5 giorni** |
