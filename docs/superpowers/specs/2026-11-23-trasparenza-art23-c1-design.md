# Schemi di pubblicazione ANAC art. 23 — Provvedimenti amministrativi (profilo C1)

> Spec architetturale. Issue: [GitLab cms#489](https://gitlab.com/opencity-labs/sito-istituzionale/cms/-/work_items/489).
> Tutte le decisioni qui sotto sono state chiarite e approvate da Marco in chat prima della stesura di questo documento — non sono proposte aperte.

## Obiettivo

Oggi il prodotto mostra i provvedimenti amministrativi (deliberazioni, determinazioni, decreti, ordinanze) su due pagine separate ("Provvedimenti organi indirizzo politico", "Provvedimenti dirigenti"), con tabelle statiche (`fields`) che coprono solo un sottoinsieme delle tipologie reali, e nessun export conforme alle specifiche ANAC per l'art. 23 d.lgs. 33/2013 (Allegato 7, Delibera 495/2024, schema ad adesione volontaria).

Questo lavoro: (1) unifica le due pagine in una sola ("Provvedimenti"), con due tabelle live-rendering al suo interno che coprono tutte le tipologie reali; (2) aggiunge filtri di ricerca; (3) pubblica due CSV + un JSON conformi allo schema ANAC reale (`art.23-v1.0.schema.json`, verificato scaricandolo — non dedotto dalla sola issue).

Solo profilo C1. Niente tedesco in questo giro (stesso precedente di art.26-27 — cms#527).

## Architettura

Due repo, stesso pattern del lavoro appena concluso per art.26-27:

- **`installer`** (branch `trasparenza-additional-scheme-23`, da `main`): patch sulla pagina "Provvedimenti" esistente, nascondere le due sotto-pagine.
- **`openpa_bootstrapitalia`** (branch `trasparenza-additional-scheme-23`, da `master`): nuovo `Art23Serializer`, nuovo provider live-rendering, nuova funzione cron, estensione filtri frontend.

A differenza di art.26-27 (dataset nuovo), qui **non c'è nessun dataset**: la fonte dati è la classe `document` già esistente, filtrata per tag `document_type`. Stesso principio già in uso per `art.31-oiv`/`art.31-or` (vedi `PageArt31DocumentiProvider`) — questo lavoro ne è un'estensione diretta, non un pattern nuovo.

## 1. Content model / installer

### 1.1 Pagina "Provvedimenti" (padre, remote_id `d6e4140acc20a01a7dda910b1a27e714`)

Oggi vuota (verificato: `contenuto_obbligo`, `riferimenti_normativi`, `fields` tutti nulli/vuoti). `patch_content` la popola con:

- `contenuto_obbligo` (testo esatto dall'issue, con link HTML a "Bandi di gara e contratti", remote_id `dd628e7bbe6fd442a5f915ae6e98ea43` — verificato: "Atti e documenti relativi alle singole procedure e link alla BDNCP", profilo C1):

  ```html
  <p>Elenco dei provvedimenti adottati dagli organi di indirizzo politico e dai dirigenti, con particolare riferimento ai provvedimenti finali dei procedimenti di scelta del contraente per l'affidamento di lavori, forniture e servizi e di accordi stipulati dall'amministrazione con soggetti privati o con altre amministrazioni pubbliche.</p>
  <p>Per i provvedimenti di scelta del contraente l'obbligo è assolto con il link alla sotto-sezione <a href="...">Bandi di gara e contratti</a>.</p>
  <p>Oltre a tali provvedimenti, possono essere pubblicati tutti gli altri provvedimenti adottati dagli organi di indirizzo politico e dai dirigenti.</p>
  ```

- `riferimenti_normativi`, `messaggio_di_consiglio`, `decorrenza_di_pubblicazione` (`Tempestiva`), `aggiornamento` (`Semestrale`), `termine_pubblicazione` (`5 anni a decorrere dal primo gennaio dell'anno successivo a quello da cui decorre l'obbligo di pubblicazione`) — copiati **verbatim** dalle due sotto-pagine esistenti, che li hanno identici (verificato leggendo entrambi i file YAML reali). "Semestrale" è solo l'etichetta mostrata al cittadino — non vincola la cadenza del cron (vedi §3).
- `schema_pubblicazione`: `art.23-org`, `art.23-altra-tipologia`, `art.23` (i tre identificativi, vedi §4).

### 1.2 Le due sotto-pagine esistenti — nascoste

"Provvedimenti organi indirizzo politico" (remote_id `280fb2af7960538a94d877f404f67a61`) e "Provvedimenti dirigenti" (remote_id `e28f316825dba873f9f0a4ca50d1c5f4`) smettono di essere raggiungibili, con due azioni indipendenti via `php_callable`:

1. **Stato privato**: `eZContentObject::assignState()` sul gruppo `privacy`, stato `private`. Nessuno step YAML dedicato esiste nell'`ocinstaller` per questo — va richiamato direttamente via callable PHP (stesso pattern già usato altrove in questo modulo per callback custom, es. `fixAnacDatasetSpatialDefault`).
2. **Redirect HTTP 301** dal path attuale della sotto-pagina al nodo padre, via `eZURLAliasML::storePath($pathAttuale, 'eznode:' . $nodeIdPadre, false, false, true, false, true, false, true, true)` — stesso metodo nativo già usato da `ExportPublisher::publishUrlAlias()`, qui con azione `eznode:` invece di `module:` e l'ultimo parametro (`$aliasRedirects`) a `true`.

**Rischio noto e accettato**: se una delle due sotto-pagine venisse ripubblicata in futuro (editing manuale, o un futuro `--force` dell'installer), eZ potrebbe rigenerare il suo alias naturale e sovrascrivere silenziosamente il redirect. Rischio basso e non grave: nel caso peggiore un utente vede un accesso negato (stato privato) invece del redirect, mai il contenuto riesposto.

### 1.3 Tassonomia `document_type` — nessuna modifica

Verificato **live su un tenant QA** (`/opendata/api/tags_tree/Documenti`, non dal solo CSV sorgente locale): tutti i tag necessari esistono già. Nessun nuovo tag da aggiungere. Elenco completo da usare nei due filtri (§2):

- **Organi di indirizzo politico**: Deliberazione del Commissario ad acta, Deliberazione del Commissario straordinario, Deliberazione del Consiglio circoscrizionale, Deliberazione del Consiglio comunale, Deliberazione della Giunta comunale, Deliberazione dell'Esecutivo circoscrizionale, Deliberazione di altri Organi, Decreto del Sindaco, Determinazione del Sindaco, Ordinanza del Sindaco.
- **Dirigenti**: Decreto del Dirigente, Determinazione del Dirigente, Ordinanza del Dirigente.

Nota tecnica non bloccante: il file CSV sorgente locale della tassonomia (`installer/tagtree_csv/documenti.csv`) ha un'anomalia cosmetica sul tag "Deliberazione del Commissario straordinario" (path duplicato con un altro tag nel CSV) — verificato che sul tenant QA il `parentId` reale è corretto (stesso genitore "Deliberazione" degli altri 6 fratelli), quindi non è un problema in produzione. Da controllare il file CSV durante l'implementazione, non blocca il design.

## 2. Live rendering (repo `openpa_bootstrapitalia`)

### 2.1 Nuovo provider, registrato in `LiveRenderingRegistry`

```php
const PROVIDERS = [
    // ... esistenti ...
    'art.23-org' => [PageProvvedimentiProvider::class, 'getOrganiPoliticiRowsJson'],
    'art.23-altra-tipologia' => [PageProvvedimentiProvider::class, 'getDirigentiRowsJson'],
];
```

`PageProvvedimentiProvider` segue lo stesso pattern di `PageArt31DocumentiProvider`: delega la query a `Art23Serializer` (riusata anche dal cron, vedi §3), restituisce righe già appiattite e sicure (`toSafeJson()`, stesso meccanismo `JSON_HEX_*` già in uso). Niente `REPLACES_CLASS_IDENTIFIER` necessario: la pagina padre "Provvedimenti" non ha mai avuto un campo `fields` da sostituire (era vuota).

Righe esposte al template (una per provvedimento): `data` (gg/mm/aaaa, già risolta con la catena di fallback), `numero`, `denominazione`, `oggetto`, `strutturaResponsabile`, `unitaOrganizzativaId` (per il filtro), `url` (pagina del documento, non il file allegato — stesso principio di `PageArt31DocumentiProvider::resolveDocumentPageUrl()`).

### 2.2 Query sorgente

`Art23Serializer` risolve i tag **per remote_id hardcoded**, stesso pattern di `Art31Serializer::TAG_REMOTE_ID_TO_KEY` — corretto rispetto a una stesura precedente di questo documento, che proponeva una risoluzione per keyword (matching sul testo del tag): il keyword è l'etichetta mostrata al redattore ed è editabile da backend, mentre il remote_id è l'identificatore stabile. Un matching per keyword fallirebbe silenziosamente (nessun errore, il provvedimento sparirebbe semplicemente dalla tabella/export) se un domani un tag venisse rinominato anche di poco — stesso tipo di fragilità già incontrata in questo codebase per `Art31Serializer::OGGETTO_AMMESSI` (apostrofo vs accento su "Attivita'"/"Attività"), lì però con un fallimento esplicito (`InvalidVocabolarioException`), non un'esclusione silenziosa. I 13 remote_id (verificati su `installer/tagtree_csv/documenti.csv`, stesso meccanismo di import che assegna remote_id fissi anche ai tag ad-hoc di Art31) sono elencati nel piano di implementazione. La query Solr è sempre su tutto il sito (`subtree [RootNode]`, stesso principio di `Art13Serializer::fetchRiferimentiContatti()`/`Art31Serializer::fetchDocumentsByKeys()`): un provvedimento con quel tag va trovato ovunque sia pubblicato, non solo sotto "Provvedimenti".

### 2.3 Filtri in tabella

Nessun campo nuovo sul content model. Stessa libreria già in uso (DataTables 1.10.25, nessun upgrade necessario in questo lavoro):

- **Tipologia**: filtro a colonna standard (`column().search()`).
- **Unità organizzativa**: filtro a colonna standard.
- **Anno**: filtro a colonna standard, sull'anno della stessa data usata per la colonna "Data" (coerenza visiva: l'anno mostrato nel filtro è l'anno della data mostrata in tabella, non una data ANAC diversa).
- **Periodo**: filtro a intervallo personalizzato su `publication_start_time`/`publication_end_time` del Documento (non sulla "data" ANAC) — confermato esplicitamente da Marco. Implementato con `$.fn.dataTable.ext.search` (pattern standard DataTables per filtri custom, nessuna libreria aggiuntiva).

## 3. Export CSV/JSON (cron)

Nuova funzione `publishArt23()` in `cronjobs/anac_export.php`, nessun riferimento esistente oggi. Tre identificativi:

| File | Contenuto | Criterio |
|---|---|---|
| `art.23-org-YYYYMMDD-YYYYMMDD.csv` | provvedimenti organi politici | tag da §1.3, elenco "Organi di indirizzo politico" |
| `art.23-altra-tipologia-YYYYMMDD-YYYYMMDD.csv` | provvedimenti dirigenti | tag da §1.3, elenco "Dirigenti" |
| `art.23-YYYYMMDD-YYYYMMDD.json` | `intestazione`, `provvedimentiOrganiPolitici`, `provvedimentiDirigDiAltraTipologia` | i due insiemi sopra |

Chiavi JSON verificate ortograficamente sullo schema reale scaricato. `provvedimentiDirigDiSceltaContraente` **omesso**: fuori scope di questo rilascio — nessun attributo oggi distingue una determina di scelta del contraente da un'altra determina (stesso principio di esclusione già visto per profili/schemi rimandati, es. C2).

Cadenza: come tutti gli altri schemi già fatti (il cron gira sempre, confronta l'hash — "Semestrale" è solo l'etichetta in pagina, non un vincolo sul cron, confermato esplicitamente).

`SchemaPubblicazioneLookup` esteso con i tre nuovi identificativi (stesso meccanismo già in uso, nessuna modifica strutturale).

## 4. Mapping campi → attributi Documento

| Campo schema art.23 | Vincolo | Attributo Documento, in ordine di precedenza |
|---|---|---|
| `data` | obbligatorio | `act_date` → `data_di_firma` → `publication_start_time` |
| `numero` | obbligatorio | `act_number` → `has_code` |
| `denominazione` | obbligatorio | tag padre di `document_type` nella tassonomia (vedi §4.1) |
| `oggetto` | obbligatorio | `name` |
| `strutturaResponsabile` | obbligatorio | `has_organization` |
| `provvedimento` | opzionale | URL del documento stesso, solo se il Documento è pubblico |
| `allegati` | opzionale | URL degli allegati, solo se pubblici |
| `sezioneBandiDiGara` | n/a | non applicabile (array scelta-contraente fuori scope) |

**`act_date`/`act_number` possono essere del tutto assenti**, non solo vuoti: li aggiunge solo il modulo opzionale `albo-pretorio` (non la classe base `document`). Il codice deve controllare `isset($dataMap['act_date'])` prima di controllare se l'attributo è valorizzato — confermato esplicitamente da Marco.

### 4.1 "Denominazione" — tag padre, non keyword completo

Lo schema ANAC reale (`art.23-v1.0.schema.json`, verificato) **non ha un `enum`** per `denominazione`: è stringa libera, con solo esempi generici in un commento ("Delibera, Decisione, Determinazione, Ordinanza..."). Nessuna `InvalidVocabolarioException`/validazione bloccante necessaria qui, a differenza di altri schemi ANAC già fatti (es. art.4-bis).

Il valore da riportare è il **tag padre nella tassonomia** (es. "Decreto", non "Decreto del Dirigente") — deciso esplicitamente con Marco: risalire di un livello nell'albero dei tag (`Decreto del Dirigente`/`Decreto del Sindaco` sono entrambi figli di `Decreto`; stesso per `Determinazione`, `Deliberazione`, `Ordinanza`), non fare string-parsing sul keyword. Un solo salto nell'albero copre uniformemente tutte e quattro le famiglie, nessuna eccezione da gestire. Evita anche di duplicare un'informazione già coperta da altri campi (la tabella in cui l'atto compare + `strutturaResponsabile` dicono già "chi" ha firmato).

### 4.2 `provvedimento`/`allegati` nell'export

Inclusi quando il Documento è pubblico (confermato esplicitamente: "nell'export deve esserci quello che prevede anac"). Formato verificato sull'esempio CSV reale ANAC: intestazione `DATA;NUMERO;DENOMINAZIONE;OGGETTO;STRUTTURA_RESPONSABILE;PROVVEDIMENTO;ALLEGATO` (singolare) — con più allegati per lo stesso atto, **una riga ripetuta per allegato** (stessi DATA/NUMERO/DENOMINAZIONE/OGGETTO/STRUTTURA_RESPONSABILE/PROVVEDIMENTO, cambia solo ALLEGATO), non una colonna multivalore. Nel JSON, `allegati` resta un array sullo stesso oggetto provvedimento. "Pubblico" = stato eZ del Documento oggi; nessun controllo aggiuntivo per un eventuale futuro campo "rendi privato dopo pubblicazione" (non esiste ancora, non implementare per quel caso).

In tabella (live-rendering), `provvedimento`/`allegati` **non vengono mostrati** (confermato: "in tabella non li visualizziamo") — solo nell'export.

## 5. Omissione dati personali

Responsabilità editoriale del redattore, nessun supporto dal prodotto (confermato esplicitamente) — stesso principio già applicato in art.26-27 (guida testuale nei campi `description`, nessuna logica di validazione).

## 6. Validazione del JSON contro lo schema ANAC reale (nuovo)

Richiesto esplicitamente da Marco, aggiunto a questo giro: oggi nessuno degli schemi ANAC già scritti (art.4-bis/13/20/31) valida strutturalmente il JSON prodotto contro lo schema reale — la conformità si ottiene solo "a mano", verificando nomi campo/required/pattern sullo schema scaricato al momento di scrivere il serializer (vedi `classes/anac/CLAUDE.md`). Per art.23 si aggiunge una validazione automatica, eseguita ad ogni run del cron prima della pubblicazione: una catena di fallback sui dati (§4) o un bug nel mapping produrrebbero altrimenti un JSON non conforme pubblicato silenziosamente, scoperto solo se/quando ANAC lo segnala.

### 6.1 Libreria

`justinrainbow/json-schema` (`JsonSchema\Validator`, draft-07 — lo stesso draft dichiarato da `art.23-v1.0.schema.json` via `$schema: "http://json-schema.org/draft-07/schema#"`, verificato scaricando il file). **Non è una nuova dipendenza di fatto**: è già risolta nel `composer.lock` del progetto come dipendenza transitiva di `erasys/openapi-php` (usato da `ocopenapi`), versione compatibile con `^5.2`. Va solo dichiarata esplicitamente nel `require` di `openpa_bootstrapitalia/composer.json`, perché questa estensione la userà direttamente (oggi non compare nei suoi require, solo nel lock condiviso) — niente bump di versione installata, solo dichiarazione corretta di cosa viene usato.

### 6.2 Fixture locali dello schema, non fetch a runtime

I due file scaricati e verificati (`art.23-v1.0.schema.json`, `commons-v1.0.schema.json`) vanno committati come fixture statiche in una nuova directory `classes/anac/schema/`, non recuperati via HTTP ad ogni esecuzione del cron: un export di produzione che gira su ~600 tenant non deve dipendere dalla raggiungibilità di `guida-servizi.anticorruzione.it` né dalla sua latenza, e un eventuale cambio di contenuto lato ANAC non deve alterare silenziosamente cosa viene validato (lo schema usato per validare deve essere esattamente quello verificato quando il serializer è stato scritto, lo stesso principio già applicato ai vocabolari controllati di `Art4BisSerializer`).

**Risoluzione dei `$ref`**: nello schema `art.23`, i `$ref` verso le definizioni comuni (`Data`, `Denominazione`, `Descrizione`, `Url`, `Intestazione`, ecc.) puntano all'URL assoluto `$id` di `commons-v1.0.schema.json` (es. `https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/commons-v1.0.schema.json#/definitions/Data`), non a un path relativo. Per evitare che la risoluzione di quei `$ref` generi comunque una richiesta di rete, il contenuto locale di `commons-v1.0.schema.json` viene pre-registrato in una `JsonSchema\SchemaStorage` sotto quello stesso `$id` (`SchemaStorage::addSchema($id, $schemaObject)` prima di validare) — verificato che questo meccanismo esiste proprio per questo caso (iniettare un documento già caricato sotto un id arbitrario, saltando la risoluzione remota).

### 6.3 Nuova classe, riusabile per futuri schemi ANAC

`OpenPABootstrapItalia\Anac\JsonSchemaValidator`: wrapper minimo, un solo metodo pubblico `validate(string $schemaFilename, string $json)`. Internamente: carica `$schemaFilename` da `classes/anac/schema/`, pre-registra `commons-v1.0.schema.json` nella `SchemaStorage` come sopra, `json_decode($json)` (object mode, necessario perché `additionalProperties: false` nello schema richiede un oggetto, non un array associativo), esegue `Validator::validate()`. Se non conforme, lancia una nuova `InvalidAnacSchemaException` (stesso pattern/posizione di `InvalidVocabolarioException`/`InvalidImportoException`: estende la stessa base, messaggio con l'elenco degli errori del validator — property path + motivo — per diagnosticare senza dover rileggere lo schema a mano).

Pensata da subito riusabile (parametro `$schemaFilename`, non hardcoded `art.23`): un futuro schema ANAC può richiamarla passando il proprio file — non si riscrive per ogni schema, ma questo lavoro **non retrofitta** la validazione sugli schemi già scritti (art.4-bis/13/20/31): fuori scope di questo rilascio, nessuna modifica a quei serializer.

### 6.4 Punto di innesto

`Art23Serializer::toJson()` costruisce l'array `$data` (stesso stile di `Art20Serializer::toJsonCo2()`: `$schema` + `intestazione` con le date risolte da `ExportPublisher`, poi le chiavi `provvedimentiOrganiPolitici`/`provvedimentiDirigDiAltraTipologia` **solo se l'array relativo non è vuoto** — lo schema richiede `minItems: 1` quando la chiave è presente, un ente senza provvedimenti di una tipologia deve vedere quella chiave assente, non un array vuoto), fa `json_encode()`, poi passa quella stessa stringa a `JsonSchemaValidator::validate('art.23-v1.0.schema.json', $json)` **prima** di restituirla al chiamante (il `$jsonBuilder` passato a `ExportPublisher::publish()`, vedi §3). Se la validazione fallisce, `InvalidAnacSchemaException` risale fino al `try/catch` di `publishArt23()` nel cron (stesso pattern già in uso in `publishArt31()`/`publishArt13()`: `catch (\Exception $e) { eZDebug::writeError(...); $cli->error(...); }` — stesso trattamento già riservato a `InvalidVocabolarioException`/`InvalidImportoException` per art.4-bis, nessuna funzione helper dedicata nel cron): quel giorno l'export non si aggiorna, l'ultimo file valido già pubblicato resta online, l'errore finisce nei log del cron per essere indagato.

**Il CSV non viene validato** (nessuno schema JSON Schema esiste per il formato CSV — ANAC non ne pubblica uno): resta verificato solo manualmente contro l'intestazione/esempio CSV reale, come già per tutti gli altri schemi.

### 6.5 Test

Nuovo file `tests/test_anac_art23_json_schema_validation.php` (logica pura, nessun kernel eZ — stesso stile di `tests/test_anac_importo_normalizer.php`): un payload corretto deve passare; almeno tre varianti rotte devono fallire con `InvalidAnacSchemaException` — `data` in formato diverso da `GG/MM/AAAA` (es. `AAAA-MM-GG`), un campo obbligatorio assente (es. `strutturaResponsabile`), un `provvedimento`/`allegati` con url senza `http(s)://`. Verifica anche che un payload con `provvedimentiDirigDiAltraTipologia` assente (nessun provvedimento dirigenziale quel giorno) passi comunque (solo `$schema`+`intestazione` sono `required` a livello radice).

## Fuori scope (esplicito)

- Profilo C2.
- Traduzione tedesca.
- `provvedimentiDirigDiSceltaContraente` (nessun attributo oggi distingue scelta-contraente da altre determine).
- Upgrade della libreria DataTables (resta 1.10.25, sufficiente per i filtri richiesti).
- Retroattività: se un ente ha già configurato diversamente le due vecchie pagine (es. personalizzazioni locali ai metadati), questo lavoro non la rileva né la preserva — stesso principio già documentato altrove nel progetto per gate non retroattivi.
- Validazione schema JSON per gli schemi ANAC già scritti (art.4-bis/13/20/31): il meccanismo (§6) è riusabile ma questo lavoro non lo applica retroattivamente.
- Validazione del CSV: nessuno schema formale esiste per quel formato.

## Testing

Checklist derivata dall'issue, con le verifiche aggiuntive emerse dalla ricognizione tecnica di questa fase:

- Le vecchie due sotto-pagine: stato privato + redirect funzionante (non solo "non in menu").
- Pagina "Provvedimenti": entrambe le tabelle, filtri funzionanti (Tipologia, Unità organizzativa, Anno, Periodo), metadati (contenuto obbligo, riferimenti normativi, ecc.) presenti e coerenti con le vecchie pagine.
- Un Decreto/Ordinanza (non solo Deliberazione/Determinazione) compare correttamente nella tabella giusta — questo è il gap reale che oggi esiste in produzione e che questo lavoro risolve.
- Catena di fallback `data`/`numero`, inclusi i casi in cui `act_date`/`act_number` sono del tutto assenti dalla classe (sito senza modulo albo-pretorio).
- `provvedimento`/`allegati` nell'export, assenti in tabella.
- Export con documento privato: niente `provvedimento`/`allegati`, ma la riga resta (gli altri campi obbligatori sono sempre presenti).
- Nessun nuovo tag necessario — riverificare che l'elenco tipologie in query copra esattamente quanto da §1.3.
- Validazione schema JSON (§6): un run con dati reali produce un JSON che passa `JsonSchemaValidator`; un dato malformato iniettato ad-hoc (es. `act_date` in formato non convertibile in `GG/MM/AAAA`) fa fallire l'export con `InvalidAnacSchemaException`, intercettata dal `try/catch` di `publishArt23()` — niente pubblicazione di quel giorno, nessun crash del cron per gli altri schemi.
