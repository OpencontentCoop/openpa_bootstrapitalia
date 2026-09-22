# Export ANAC (namespace `OpenPABootstrapItalia\Anac`)

Sistema per produrre export CSV/JSON conformi agli schemi ANAC per la sezione
Amministrazione Trasparente (Guida Online ANAC, `guida-servizi.anticorruzione.it`),
a partire dai contenuti già pubblicati sul sito. Nasce dalle issue GitLab
opencity-labs/sito-istituzionale/cms#475 (art. 4-bis, "Dati sui pagamenti"),
#477 (art. 31), #478 (art. 13), con requisiti trasversali di naming/versionamento
in #479. Vedi anche `installer/modules/trasparenza-c1/CLAUDE.md` per la parte
di content model/binding schema↔pagina.

## Fonte di verità: gli schemi JSON sono scaricabili direttamente

**Scoperta importante (2026-09-15)**: la guida online ANAC ha i JSON Schema
reali scaricabili direttamente via HTTP (non serve un browser, `curl` basta),
a un path prevedibile:

```
https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/<schema>-v1.0.schema.json
https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/commons-v1.0.schema.json
```

dove `<schema>` è `art.4-bis`, `art.13`, `art.31`, ecc. `commons-v1.0.schema.json`
contiene le definizioni condivise (`Intestazione`, `Amministrazione`, `Data`,
`Url`, `Importo`, `Riferimenti`, ecc.) referenziate da tutti gli schemi
specifici. **Usare questi file, non riassunti automatici della pagina guida
(`guida-servizi.anticorruzione.it/it/help/...`)** per vocabolari/enum/campi
obbligatori: un riassunto automatico ha portato a un errore reale già
pubblicato (vedi sotto, categoria di art. 4-bis) prima di scoprire che i
file erano scaricabili direttamente.

**Stato**: art. 4-bis completo (cron incluso). Art. 13 (#478), profili
**C1 e C2**: `art.13-as`/`art.13-op`/`art.13-pa` (C1) e `art.13-as`/`art.13-oa`/
`art.13-se` (C2) scritti, collegati al cron, la tipologia si deriva dal
binding reale (vedi "SchemaPubblicazioneLookup" sotto), verificato
end-to-end con dati reali per entrambi i profili. Manca ancora
l'organigramma (`art.13-org`) e la tassonomia degli organi societari per C2
(vedi "Cosa manca"). Art. 31 (#477), profili **C1 e C2**: `art.31-oiv`
(Organismi indipendenti di valutazione), `art.31-or` (Organi di revisione),
`art.31-oc` (Corte dei conti) + JSON "file unico" scritti, collegati al cron
e verificati con dati reali in `sito-comunale-dev` (documenti taggati,
url `content/download` reali, vocabolario "oggetto" Corte dei conti) -
nessun fork di codice per tipologia qui, solo la pagina che ancora ciascuno
schema cambia. Meccanismo di
pubblicazione URL generico, condiviso da tutti gli schemi, completo e
testato - esteso per supportare anche schemi a file singolo (vedi
"ExportPublisher — publishSingle()/publishWithDates()" sotto) e per lo
storico versioni (#479, vedi "ExportPublisher — storico versioni e
discoverability" sotto). Binding pagina↔schema formalizzato (vedi
"SchemaPubblicazioneLookup" sotto): il cron non ha più remote_id ANAC-specifici
hardcoded (a parte i due schemi ancorati a un dataset), e una UI di
download+storico è live su `pagina_trasparenza.tpl`.

## Architettura

```
classes/
  SchemaPubblicazioneLookup.php        globale (non nel namespace Anac):
                                        binding pagina<->schema ANAC, letto
                                        sia dal cron sia dal template
  services/content_trasparenza.php     service esistente (openpa.ini
                                        [Services]) esteso con
                                        anac_exports/has_anac_exports
  anac/
    ExportPublisher.php              generico, per tutti gli schemi: scrive su
                                      cluster storage + espone url pubblico
                                      + storico versioni (#479)
    IntestazioneProvider.php         blocco "intestazione" comune a tutti gli
                                      schemi (codice fiscale + denominazione ente)
    MissingCodiceFiscaleException.php
    InvalidVocabolarioException.php
    Serializer/
      Art4BisSerializer.php          art. 4-bis (Dati sui pagamenti) - completo
      Art13Serializer.php            art. 13 (Organizzazione) - solo C1 per ora
      Art31Serializer.php            art. 31 (Controlli e rilievi) - solo C1 per ora
modules/anac_export/
  module.php                       registra la view "file"
  file.php                         streama il file dal cluster storage
design/bootstrapitalia2/templates/openpa/full/
  pagina_trasparenza.tpl           include il blocco download+storico se
                                    $trasparenza.has_anac_exports
  parts/amministrazione_trasparente/anac_export.tpl  il blocco stesso
```

### `ExportPublisher` — versionamento e pubblicazione (comune a tutti gli schemi)

Per ogni schema (`$schemaIdentifier`, es. `art.4-bis`):

1. Calcola l'hash del solo CSV (non del JSON — vedi sotto perché). Se
   identico all'ultima pubblicazione, non fa nulla (tracking già a posto,
   nessuna riscrittura inutile, date invariate).
2. **Una pubblicazione avviene al massimo una volta al giorno**: se il
   tracking dice che oggi è già stato pubblicato (`dataUltimaModifica ==
   oggi`), un ulteriore cambiamento rilevato nello stesso giorno non genera
   una nuova pubblicazione — viene colto dalla prossima esecuzione, il
   giorno dopo (vedi "Immutabilità e -latest" sotto per il perché).
3. Altrimenti risolve `dataUltimaModifica = oggi` e `dataPrimaPubblicazione`
   (invariata se già pubblicato in passato, oggi se prima pubblicazione),
   POI chiede al chiamante di costruire il JSON finale con quelle date (vedi
   "Perché il JSON si costruisce con una callback" sotto), poi scrive
   insieme, stesso contenuto, su cluster storage (`eZClusterFileHandler`, NON
   filesystem diretto — necessario perché in produzione SaaS si usa quasi
   certamente `--embed-dfs-schema`, cluster DB/S3, non disco locale):
   - `{schema}-{dataPrimaPubblicazione}-{dataUltimaModifica}.csv`
   - `{schema}-{dataPrimaPubblicazione}-{dataUltimaModifica}.json`
   - `{schema}-latest.csv` (stesso contenuto del file datato appena scritto)
   - `{schema}-latest.json` (idem)
4. Traccia lo stato in `eZSiteData` (`anac_export_<schema>`, JSON: dataHash,
   dataPrimaPubblicazione, dataUltimaModifica, pathCsv, pathJson) — stesso
   pattern già usato dall'installer per il version-tracking dei moduli.
5. Pubblica un url pubblico per ogni file scritto via `eZURLAliasML::storePath()`
   (vedi sotto).

Trigger: **non** `post_publish`. Un dataset (classe `dataset`, datatype
`opendatadataset`/`csv_resource`) può cambiare contenuto senza mai passare da
`onPublish()` di una versione (verificato: l'inserimento riga nel dataset è un
INSERT diretto in tabella, non un publish). Il chiamante di `publish()` deve
quindi essere un cron periodico che rigenera ogni schema attivo confrontando
l'hash — non un webhook/trigger sull'evento di pubblicazione contenuto.

#### Perché il JSON si costruisce con una callback, non una stringa già pronta

`publish($csv, callable $jsonBuilder)`, non `publish($csv, $json)`. Bug reale
trovato prima ancora di scrivere il cron: se il chiamante serializza il JSON
PRIMA di chiamare `publish()`, deve già sapere `dataUltimaModifica` — ma
quel valore dipende proprio dal confronto che `publish()` fa internamente
("il dato è cambiato rispetto a ieri?"). Se il chiamante mette sempre "oggi"
a priori, il JSON cambia ad ogni esecuzione del cron anche quando il dato
è identico (perché la data cambia comunque), quindi l'hash del JSON cambia
sempre, quindi `dataUltimaModifica` si aggiornerebbe ad ogni run — violando
il requisito ANAC che deve aggiornarsi solo quando il dato cambia davvero.
Soluzione: hash calcolato solo sul CSV (che non contiene mai le date), e il
JSON si costruisce tramite callback **dopo** che `publish()` ha già deciso
le date giuste. Vale solo per il JSON: il CSV non ha questo problema perché
non incorpora `intestazione` con le date.

#### Immutabilità e "-latest" — il cron gira più volte al giorno

Rischio reale, non teorico: `[CronjobPart-changesection]` gira 2 volte al
giorno (1:00 e 15:00, vedi crontab). Se `publish()` pubblicasse ad ogni
cambiamento rilevato senza limiti, un secondo cambiamento nello stesso
giorno sovrascriverebbe silenziosamente un url datato già pubblicato e
potenzialmente già scaricato/citato da qualcuno — il naming a due date
esiste apposta per garantire che un url, una volta pubblicato, non cambi mai
più.

**Primo tentativo di fix (sbagliato, scartato)**: scrivere il file datato
solo se non esiste già, ma continuare a sovrascrivere sempre `-latest` con
il contenuto più recente. Sbagliato perché la issue descrive `-latest` come
un **alias sempre puntato all'ultima versione [pubblicata]**, non un mirror
indipendente in tempo reale — con quel primo fix, un secondo cambiamento
nello stesso giorno avrebbe fatto divergere `-latest` (dato più recente) dal
file datato di quel giorno (dato meno recente, congelato al primo
cambiamento) — due fonti di verità diverse per "lo stato attuale".

**Fix corretto**: una pubblicazione avviene al massimo una volta al giorno
(vedi punto 2 sopra). Quando succede, datato e `-latest` si scrivono insieme,
stesso contenuto, nello stesso momento — non possono mai divergere per
costruzione, perché non esiste un percorso di codice che aggiorni l'uno senza
l'altro. Un secondo cambiamento nello stesso giorno non viene pubblicato
affatto (né datato né `-latest`): resta quello di stamattina finché il giorno
dopo non arriva una nuova pubblicazione con lo stato cumulativo. Verificato
con test reale (due `publish()` in sequenza, stesso giorno, contenuti
diversi: sia il file datato sia `-latest` restano al primo contenuto — il
secondo cambiamento non viene scritto da nessuna parte finché non cambia il
giorno).

#### Latenza: quando un redattore vede il proprio dato pubblicato

`[CronjobPart-changesection]` gira alle **1:00 e alle 15:00** (crontab reale
di `sito-comunale-dev`: `0 1,15 * * *`). Punto importante da non fraintendere
(non è "il dato del giorno non finisce mai nel file di quel giorno" — è più
sottile):

- **La guardia "una pubblicazione al massimo al giorno" (vedi sopra) dipende
  da se quel giorno ha GIÀ avuto una pubblicazione, non dall'orario
  dell'edit.** Un redattore che modifica il dataset a mezzogiorno, se quel
  giorno non è ancora stata fatta nessuna pubblicazione (es. il run
  dell'1:00 non aveva trovato nulla di cambiato), viene tranquillamente
  catturato dal run delle 15:00 e finisce nel file datato di **oggi**.
- Il caso che resta davvero scoperto fino al giorno dopo è un **secondo
  cambiamento nello stesso giorno DOPO che una pubblicazione è già
  avvenuta** (es. qualcosa cambia già all'1:00 e viene pubblicato, poi il
  redattore modifica di nuovo a mezzogiorno) — quel secondo cambiamento non
  compare da nessuna parte (né datato né `-latest`) fino al run dell'1:00
  del giorno successivo.
- Una modifica fatta **dopo il run delle 15:00** (es. alle 18:00) viene vista
  solo al run dell'1:00 del giorno dopo, e finisce quindi nel file datato di
  **domani**, non di oggi — anche se per il redattore "l'ha fatto oggi". La
  data nel nome del file riflette **quando il cron se ne accorge**, non
  quando il dato è stato effettivamente scritto.
- Latenza massima nel caso peggiore: circa mezza giornata (dal run delle
  15:00 al run dell'1:00 del giorno dopo, se il cambiamento arriva subito
  dopo le 15:00) o un giorno intero (se cade nel caso del secondo punto).
  Non eliminabile aumentando la frequenza del cron, per via del vincolo
  "una pubblicazione al massimo al giorno" richiesto dalla granularità delle
  date ANAC (YYYYMMDD, non un timestamp) — un cron più frequente
  ridurrebbe solo la finestra di rilevazione del PRIMO cambiamento del
  giorno, non risolverebbe il caso del secondo cambiamento stesso giorno.
  L'unica soluzione strutturale sarebbe un trigger event-driven invece di un
  cron periodico, ma i dataset non passano da `post_publish` (vedi sopra) —
  richiederebbe agganciarsi a un altro punto del ciclo di vita
  (`OpendataDatasetSearchableRepository`/l'insert diretto in tabella), non
  ancora esplorato.

#### Schemi a file singolo: `publishSingle()` e `publishWithDates()`

`publish($csv, $jsonBuilder)` assume sempre una coppia CSV+JSON sotto lo
stesso `$schemaIdentifier` (il caso di art. 4-bis). Art. 13 non ci sta:
`art.13-as`/`art.13-op` sono CSV a se stanti senza un JSON gemello, e il
JSON è un "file unico" (`art.13-pa`) con un identificativo proprio che copre
insieme ambito soggettivo + organi. Due metodi aggiuntivi, stesso nucleo
condiviso (`resolveAndPublish()`, hash + "una pubblicazione al massimo al
giorno" invariati):

- `publishSingle($content, $extension)` — per un file il cui contenuto NON
  incorpora le date (es. `art.13-as`/`art.13-op`: pure righe di dato, hash
  diretto sul contenuto).
- `publishWithDates($dataHashSource, callable $contentBuilder, $extension)` —
  per un file singolo il cui contenuto DIPENDE dalle date risolte (es.
  `art.13-pa`, che ha comunque un blocco `intestazione` con le date, stesso
  problema di `publish()` ma senza un CSV gemello su cui calcolare l'hash):
  il chiamante passa a parte una rappresentazione del solo dato, senza date
  (per art.13-pa: `json_encode($organi)`, lo stesso array già passato a
  `Art13Serializer::toJson()`/`toCsvOrganiUffici()` per evitare di
  ricalcolarlo tre volte nello stesso cron).

### Node id da passare a `ExportPublisher`: NON la radice dell'alberatura

Il secondo parametro del costruttore (`$rootNodeId`) è il nodo della
**pagina/oggetto specifico dello schema**, non la radice di "Amministrazione
Trasparente" o "Società trasparente" - vale per ogni schema, mai un'eccezione.
(Corrisponde al pattern richiesto da ANAC in #479:
`<alberatura>/art.<N>[-suffisso]-YYYYMMDD-YYYYMMDD.<ext>` + alias
`-latest.<ext>`, dove `<alberatura>` è il path reale della pagina che mostra
quel dato, non un prefisso fisso per tutto il sito.)

**Da dove viene quel nodo**, per ciascuno schema (vedi
`SchemaPubblicazioneLookup` sotto per il meccanismo):

- **Schemi ancorati a `pagina_trasparenza`** (`art.13-as/op/pa`,
  `art.31-oiv/or`, `art.31`): il nodo si risolve leggendo l'attributo
  `schema_pubblicazione` sulle pagine reali - `SchemaPubblicazioneLookup::fetchAllBindings()`.
  Nessun remote_id ANAC-specifico hardcoded nel cron.
- **Schemi ancorati a un `dataset`** (`art.4-bis`, `art.31-oc`): il dato
  sorgente viene sempre letto dall'oggetto `dataset` per remote_id fisso
  (`dati_sui_pagamenti`, `corte_dei_conti` - la classe `dataset` non ha
  `schema_pubblicazione`, quel dato non cambia), ma il **nodo passato a
  `ExportPublisher` preferisce la pagina di trasparenza reale** quando
  esiste un binding (`$schemaBindings['art.4-bis']`/`['art.31-oc']`, popolato
  da `patch_content` in `trasparenza-c1`), con fallback al nodo del dataset
  stesso solo se quel binding manca (tenant piu' vecchi, vedi
  `hasAnyAnacExportActive()`) - **bug corretto il 2026-09-21**: prima si
  usava sempre e solo il nodo del dataset, anche quando il binding sulla
  pagina esisteva gia' ed era gia' risolto correttamente da
  `SchemaPubblicazioneLookup` per tutti gli ALTRI usi (blocco download in
  pagina, warning di collisione) - solo l'ancoraggio url dell'export non lo
  sfruttava. Risultato pratico prima del fix: l'url pubblico di art.4-bis
  finiva sotto `Amministrazione/Documenti-e-dati/Dataset/Dati-sui-pagamenti/`
  (il nodo tecnico del dataset, non visibile nell'albero di trasparenza)
  invece che sotto `Amministrazione-Trasparente/Pagamenti-dell-amministrazione/Dati-sui-pagamenti/`
  (la pagina che il cittadino vede davvero) - trovato da Marco confrontando
  gli url generati con quelli attesi su QA Bugliano.

**Corte dei conti, stesso principio**: esistono DUE oggetti concettualmente
"Corte dei conti" - la pagina di trasparenza (classe `pagina_trasparenza`,
dichiara `schema_pubblicazione: [art.31-oc]`, sta sotto "Controlli e rilievi
sull'amministrazione") e il dataset con le righe CSV grezze (classe
`dataset`, remote_id `corte_dei_conti`, sta sotto "Documenti e dati"). Dal
fix sopra, il file `art.31-oc` è ancorato al nodo della **pagina** quando il
binding esiste (il caso normale su un sito con `trasparenza-c1` aggiornato),
non più sempre al dataset.

JSON "file unico" di art. 31 (`art.31`, nessun suffisso — confermato
scaricando l'HTML della pagina guida ANAC e cercando il link reale al file
di esempio, non un riassunto WebFetch) → ospitato sotto **"Controlli e
rilievi sull'amministrazione"**, il genitore reale (verificato in
`sito-comunale-dev`) di **tutte e tre** le pagine di trasparenza dell'art. 31
- decisione presa con Marco il 2026-09-15, dopo aver scartato una prima
ipotesi sbagliata ("Organismi indipendenti di valutazione", scelta arbitraria
senza giustificazione) e una seconda incompleta (avevo controllato solo
l'oggetto dataset di Corte dei conti, non la sua pagina di trasparenza,
concludendo erroneamente che solo 2 pagine su 3 condividessero un genitore).

Vedi `installer/modules/trasparenza-c1/CLAUDE.md` per la tabella di binding
completa schema↔remote_id.

### `SchemaPubblicazioneLookup` — binding pagina↔schema, un solo posto

Prima del 2026-09-15 il cron aveva i remote_id delle pagine ANAC (OIV, Organi
di revisione, Controlli e rilievi) scritti a mano dentro `anac_export.php` -
esattamente il "sapere a memoria quale remote_id corrisponde a quale schema"
che `installer/modules/trasparenza-c1/CLAUDE.md` segnalava come debito da
formalizzare. **Trovato durante il lavoro** (Marco: "ma esiste già l'attributo
nella pagina trasparenza, no?"): `pagina_trasparenza` ha già da tempo un
attributo `schema_pubblicazione` (ezselection multi-valore, categoria
`hidden`, non modificabile dal redattore) pensato esattamente per questo -
semplicemente non era mai stato popolato su nessuna pagina di
`trasparenza-c1` prima d'ora.

`SchemaPubblicazioneLookup` (globale, non nel namespace `Anac` - concetto
trasversale, non specifico dell'export) legge quell'attributo:

- `fetchAllBindings()`: UN solo scan della classe `pagina_trasparenza` (non
  uno scan per schema), restituisce `schemaIdentifier => eZContentObject`.
  Usato dal cron (`anac_export.php`) e condiviso tra `publishArt13()`/
  `publishArt31()` nella stessa esecuzione. Se due pagine dichiarano lo
  stesso schema (solo possibile se un ente ha sia `trasparenza-c1` sia
  `trasparenza-c2` installati contemporaneamente, mai il caso in produzione)
  vince l'ultima trovata nello scan, ma logga un warning invece di
  sovrascrivere in silenzio.
- `schemasForObject($object)`: dato un oggetto, quali schemi dichiara di
  esporre. Usato dal template (`content_trasparenza.php`, vedi sotto) per "a
  quale schema corrisponde LA PAGINA CHE STO RENDERIZZANDO".

Le opzioni dell'ezselection (`installer/modules/trasparenza/classes/pagina_trasparenza.yml`,
`schema_pubblicazione.data_text5`) sono state estese con 3 nuovi valori
(id 9/10/11: `art.13-pa`, `art.13-se`, `art.31` - i JSON "file unico", assenti
dall'elenco originale che copriva solo i suffissi CSV) - `SchemaPubblicazioneLookup::OPTION_IDS`
**deve restare sincronizzato** con quegli id, non c'è verifica automatica.

**Popolato in `trasparenza-c1/installer.yml`** aggiungendo `schema_pubblicazione`
ai `patch_content` già esistenti (nessun nuovo step per gli schemi già
patchati - solo per "Controlli e rilievi sull'amministrazione", che prima non
aveva un patch_content dedicato). **Attenzione consistenza col comportamento
già in produzione**: `art.13-as` è stato messo sulla stessa pagina di
`art.13-op`/`art.13-pa` ("Articolazione degli uffici"), NON su "Titolari di
incarichi politici" (che sarebbe stata la scelta "semanticamente più giusta")
- perché il cron **già pubblicava** tutti e tre sotto quel nodo prima di
questa modifica (un solo `$rootNodeId` condiviso in `publishArt13()`), e
cambiare pagina avrebbe spostato l'url di un export già pubblicato,
interrompendone la continuità - un errore quasi fatto, corretto prima del
commit. **Lezione**: il comportamento del cron già in produzione è la fonte
di verità per "dove sta oggi" uno schema, non un ragionamento a posteriori
su dove "dovrebbe" stare semanticamente.

**Usato anche per `art.4-bis`/`art.31-oc`, ma solo come preferenza per
l'ancoraggio url** (dal fix 2026-09-21, vedi "Node id da passare a
ExportPublisher" sopra) - il dato sorgente di questi due schemi resta letto
dall'oggetto `dataset` per remote_id fisso, `SchemaPubblicazioneLookup` non
c'entra con quello.

**Gotcha eZ Publish reale, trovato pulendo un binding sbagliato in dev**:
`eZSelectionType::fromString('')` è un **no-op** (`if ($string == '') return true;`,
non svuota `data_text`) - per azzerare un `ezselection` multi-valore serve
`$attr->setAttribute('data_text', ''); $attr->store();` direttamente, non
`fromString('')`. Diverso da `eZTags`, dove `fromString('')` invece funziona
(usato per azzerare `anac_document_type` nei test di `Art31Serializer`).

### `ExportPublisher` — storico versioni e discoverability (#479)

Issue #479, punto "discoverability": conservare le versioni passate non
basta se sono raggiungibili solo indovinando le date nell'url - serve un
elenco. `getVersions()`/`getLatestUrls()` lo forniscono, ma leggono soltanto
dal tracking già salvato - **non ricalcolano l'url a lettura**, e questo è
deliberato, non solo un'ottimizzazione.

**Perché non ricalcolare l'url a lettura**: farlo richiederebbe conoscere il
nodo che ha originariamente pubblicato quello schema - ma un lettore (un
template, su una pagina qualunque) non lo sa in generale. Vale anche dopo il
fix del 2026-09-21 sull'ancoraggio di `art.4-bis`/`art.31-oc` (vedi "Node id
da passare a ExportPublisher" sopra): quale nodo sia stato usato dipende dal
binding `schema_pubblicazione` presente AL MOMENTO della pubblicazione (pagina
se il binding esisteva, dataset come fallback altrimenti) - un lettore che
provasse a ricalcolare oggi userebbe il binding corrente, che può differire
da quello in vigore quando il file è stato scritto (es. un tenant che ha
appena aggiunto il binding: i file già pubblicati restano ancorati al nodo
del dataset finché il dato non cambia di nuovo, il ricalcolo darebbe un url
sbagliato per quelli).

**Soluzione**: `resolveAndPublish()` risolve e salva `urlCsv`/`urlJson`
(versione corrente, datata) e `urlLatestCsv`/`urlLatestJson` (alias `-latest`)
DENTRO il tracking stesso, nel momento in cui scrive i file - quando
`$this->rootNodeId` è ancora quello giusto (passato dal chiamante, cioè dal
cron). Ogni voce di `history` porta con sé i propri url già risolti allo
stesso modo. Un lettore fa quindi solo `new ExportPublisher($schemaIdentifier)`
(senza `$rootNodeId` - non serve per leggere) e `getVersions()`/`getLatestUrls()`;
non deve mai sapere quale nodo ha pubblicato quello schema.

**Migrazione dei tracking pre-esistenti**: i tracking scritti prima
dell'introduzione di questo meccanismo non hanno `urlCsv`/`urlLatestCsv` - e
senza un intervento non li avrebbero mai, perché il confronto hash in
`resolveAndPublish()` fa uscire prima di raggiungere il codice che li scrive,
finché il dato non cambia davvero (potenzialmente mai, per uno schema
stabile, su nessuno dei ~600 tenant). **Fix**: `backfillUrlsIfMissing()`
viene chiamato su ENTRAMBI i percorsi di uscita anticipata di
`resolveAndPublish()` (hash invariato, o già pubblicato oggi) - se manca
l'url per un formato che però ha già un `pathCsv`/`pathJson` (= è stato
scritto), lo calcola e lo salva, senza toccare date/hash/history (non è una
nuova pubblicazione). Verificato con test reale: un tracking scritto prima
del fix, alla prima esecuzione successiva del cron (dato invariato), acquisisce
gli url mancanti.

**Una voce di `history` senza url non viene mostrata**: caso limite,
osservato durante lo sviluppo - una voce finita in `history` PRIMA
dell'introduzione degli url pre-risolti (quando ancora si teneva solo la
data) non ha modo di essere retroattivamente arricchita con un url (il nodo
che l'ha pubblicata potrebbe non essere più quello corrente). `getVersions()`
scarta silenziosamente queste voci - il file resta comunque sul cluster
storage e raggiungibile se si conosce l'url, solo non compare nell'elenco.
Impatto pratico: sui siti già in produzione, la primissima voce storica (se
esisteva già prima di questo deploy) non comparirà nello storico mostrato in
pagina - tutte le successive sì.

### UI: blocco download + storico su `pagina_trasparenza.tpl`

`content_trasparenza.php` (service esistente, `openpa.ini` `[Services]`,
già usato da `pagina_trasparenza.tpl` per guide/figli/blocchi) espone
`has_anac_exports`/`anac_exports`: legge `SchemaPubblicazioneLookup::schemasForObject()`
sull'oggetto corrente, per ogni schema dichiarato istanzia `ExportPublisher($schema)`
(senza `$rootNodeId`, vedi sopra) e ne legge `getLatestUrls()`/`getVersions()`,
aggiungendo `label` (etichetta leggibile via `SchemaPubblicazioneLookup::labelForSchema()`).
Uno schema dichiarato ma **mai ancora pubblicato** (`getLatestUrls()` vuoto -
cron non ancora passato, o fallito, vedi "Gestione errori" sotto) viene
scartato silenziosamente, non mostrato come blocco vuoto/rotto.

Il template (`parts/amministrazione_trasparente/anac_export.tpl`) mostra **un
solo blocco per pagina** (non uno per schema, anche se la pagina ne dichiara
più di uno), sotto il titolo "Schemi pubblicazione ANAC", posizionato in
fondo al contenuto in `pagina_trasparenza.tpl`, prima del footer data
pubblicazione/modifica. Stile allineato al meccanismo "Open Data" preesistente
(`children_table_fields.tpl`), per restare coerente col resto della pagina:

- Un `<li>` per ogni formato di ogni schema pubblicato: icona `it-file` +
  link `label (FORMATO)` con classi `btn-link btn-xs p-0 text-decoration-underline`
  (senza la classe `btn`: con `btn` Bootstrap stila il link come pulsante,
  perdendo la sottolineatura coerente con gli altri link "Open Data" della
  pagina).
- "Versioni precedenti": link semplice (stesse classi, nessuna icona),
  mostrato solo se almeno uno schema della pagina ha più di una versione
  pubblicata (`count($export.versions)|gt(1)`). Un solo collassabile
  condiviso per pagina (`id="anac-export-versions"`), non uno per schema.
- Storico espanso: una riga per versione, sempre con nome completo dello
  schema + data + link al formato, es. "01/07/2026 — Ambito soggettivo —
  CSV". Gli schemi solo-JSON compaiono nello storico esattamente come i CSV -
  nessuna esclusione per formato.

**Copre anche i due schemi ancorati a un dataset** (`art.4-bis`, `art.31-oc`)
senza bisogno di toccare il template `dataset`: la pagina di trasparenza
gemella di ciascun dataset (es. "Dati sui pagamenti", `pagina_trasparenza`,
oggetto diverso dal dataset "Dati sui pagamenti" vero e proprio) ha anch'essa
`schema_pubblicazione` valorizzato, quindi il blocco compare lì - il dataset
stesso resta senza (nessun bisogno di modificarne il rendering).

Stringhe i18n nel contesto `bootstrapitalia/anac_export`: sorgente inglese in
`SchemaPubblicazioneLookup::LABELS` + `ezpI18n::tr()`/filtro `i18n()` nel
template, traduzioni in `translations/ita-IT/translation.ts`. **Attenzione**:
`php vendor/bin/oci18n -r` può cancellare traduzioni preesistenti non
correlate durante il pull - vedi root `CLAUDE.md`, sezione i18n, prima di
usarlo per aggiungere nuovi term a questo contesto.

I link allo storico sono `<a href>` renderizzati server-side dentro il
collassabile: sono presenti nell'HTML (quindi raggiungibili da un crawler)
anche a pannello chiuso, non solo dopo averlo aperto via JS. Questo è
intenzionale - vedi "Cosa manca", punto sull'indicizzazione.

### Il modulo `anac_export` — perché serve e due bug non ovvi

I file scritti da `ExportPublisher` vivono su `eZSys::cacheDirectory() . '/anac_export'`
(cluster storage). **Non sono raggiungibili staticamente**: verificato leggendo
la config nginx reale di `sito-comunale-dev` — nessuna regola serve
`cache/anac_export/...`, tutto cade nel catch-all che passa a `index.php` come
URI di contenuto normale (→ 404). Stesso motivo per cui il precedente
`ocexportas` (estensione separata, pattern simile ma per export "live") espone
i suoi file tramite un modulo eZ dedicato (`/customexport/...`) che legge da
cluster storage e streama — qui si fa lo stesso con un modulo nuovo.

`eZURLAliasML::storePath()` (l'API nativa con cui eZ Publish genera gli url
puliti dei nodi) supporta un'action `module:<modulo>/<view>/<parametri>` oltre
a `eznode:<id>` — è il meccanismo con cui `ExportPublisher` aggancia un path
pubblico "pulito" (tipo quello di un nodo) a `anac_export/file/<schema>/<filename>`.

**Due bug reali trovati con debug end-to-end, non ovvi dalla sola lettura del
codice — da non riscoprire in futuro:**

1. **I punti nel nome file vengono convertiti in trattini di default.**
   `storePath()` passa ogni segmento di path per `convertToAlias()`, che
   trasforma `.` in `-` (vedi il suo stesso docblock: `'myfile.tpl' =>
   'Myfile-tpl'`). Senza intervenire, `art.4-bis-latest.csv` sarebbe
   diventato qualcosa come `art-4-bis-latest-csv`, rompendo sia il prefisso
   `art.` sia l'estensione. **Fix**: settare `cleanupElements=false` (7°
   parametro posizionale di `storePath()`).

2. **Un modulo eZ nuovo resta sempre in HTTP 410 (access denied) per
   l'utente anonimo, anche con la policy di ruolo corretta**, se `module.php`
   definisce `$ViewList[...]['functions']` ma NON definisce anche
   `$FunctionList` con la stessa chiave. Causa: `eZUser::hasAccessToView()`
   (kernel/classes/datatypes/ezuser/ezuser.php) usa `$module->attribute('available_functions')`
   (= `$FunctionList`) per sostituire i nomi delle funzioni nell'espressione
   di accesso con `true`/`false`; se la chiave non c'è, la sostituzione non
   avviene, l'espressione risultante non è vuota, e il modulo scrive
   silenziosamente in log "There is a mistake in the functions array data...
   Please check the module.php file" e nega sempre l'accesso — indipendente
   dalla policy sul ruolo. Basta anche un array vuoto:
   `$FunctionList['file'] = array();` risolve. Visibile solo abilitando il
   debug output di eZ (`[DebugSettings]DebugOutput` a `enabled`) e cercando
   "Module start" / "Error" nel report — l'errore non compare nella pagina
   visibile all'utente.

Serve inoltre una policy esplicita sul ruolo Anonymous (`ModuleName:
anac_export, FunctionName: file`, nessuna limitazione) — questi export sono
dati di trasparenza obbligatoriamente pubblici, stesso trattamento già
riservato a `exportas/csv`. Vedi `installer/roles/Anonymous.yml`.

### `Art4BisSerializer` — vocabolario controllato

Il campo `categoria_di_spesa`/`tipologia_di_spesa`/`beneficiario` del dataset
sono testo libero lato redattore. Lo schema ANAC richiede invece stringhe
esatte da un vocabolario chiuso — verificato scaricando
`art.4-bis-v1.0.schema.json` (vedi sopra) il 2026-09-15. Se ANAC aggiorna lo
schema, aggiornare le costanti `CATEGORIA_*`/`TIPOLOGIE_PER_CATEGORIA`/
`BENEFICIARI_AMMESSI` in `Art4BisSerializer.php`:

- categoria: **minuscolo** `uscite correnti` / `uscite in conto capitale`
  (`categoria` è un `const` nello schema JSON) — **bug reale corretto lo
  stesso giorno**: un primo tentativo li aveva capitalizzati (`Uscite
  correnti`) basandosi su un riassunto automatico impreciso della pagina
  guida (non del file schema); l'esempio originale nella issue #475
  (minuscolo) era quello corretto fin dall'inizio.
- tipologia: dipende dalla categoria della riga (5 valori ammessi per
  ciascuna categoria, vedi costanti nel file) - occhio a
  `Acquisto di beni e di servizi` (con "di" ripetuto, non "Acquisto di beni
  e servizi" - altro dettaglio sbagliato nel primo tentativo).
- beneficiario: `Persona fisica` / `Altro soggetto pubblico e privato` /
  `Soggetto estero`

Il matching è case/spazi-insensitive (il redattore può scrivere "uscite
correnti" minuscolo, viene normalizzato alla stringa canonica), ma se il
valore non corrisponde a nessuna voce ammessa **l'export fallisce
esplicitamente** (`InvalidVocabolarioException`) invece di pubblicare un
valore non conforme — stesso principio già usato per il codice fiscale
mancante/malformato in `IntestazioneProvider` (`MissingCodiceFiscaleException`,
11 cifre numeriche richieste).

L'importo (`normalizeImporto()`) viene sempre riportato al formato ANAC
`n.nnn,dd` (punto delle migliaia, virgola decimale) qualunque sia la
convenzione di digitazione del redattore (`1550.33`, `1550,33`, `1.550,33`,
`1,550.33` producono tutti `1.550,33`) — euristica: se compaiono sia `,` che
`.`, l'ultimo dei due è il separatore decimale.

### `Art13Serializer` — solo profilo C1 per ora

Copre `art.13-as` (ambito soggettivo), `art.13-op` (organi di indirizzo
politico + uffici) e `art.13-pa` (JSON "file unico", che copre insieme
ambito soggettivo + organi). **In corso** `art.13-oa` (organi di
amministrazione e gestione - vedi sezione dedicata sotto, riguarda anche i
comuni C1, non solo C2). **Non copre** `art.13-org` (organigramma, sorgente
dati non individuata) né `art.13-rif` (fuori perimetro, dovuto solo a
ordini/collegi professionali C3). Vedi
`installer/modules/trasparenza-c1/CLAUDE.md` per il perimetro C1/C2/C3.
Collegato al cron (`cronjobs/anac_export.php`, `publishArt13()`) e
verificato con url pubblici reali sotto il nodo "Articolazione degli
uffici" (remote_id `ae441f5d2f78bf88f0b3e39a36743bdd`, patchato da
`trasparenza-c1`).

**Il JSON ha un identificativo proprio, diverso dai CSV**: `art.13-pa` per
Pubbliche Amministrazioni (C1), `art.13-se` per Società ed Enti (C2) - da
`guida-servizi.anticorruzione.it` (nomi dei file di esempio scaricabili).
Non dedurlo dal nome dei CSV (`art.13-as`/`art.13-op`) - sono file diversi,
con la propria pubblicazione/versione/tracking indipendente.

**Un ufficio incompleto sparisce dal JSON ma resta nel CSV**: verificato
scaricando `art.13-v1.0.schema.json` (vedi sopra), `Ufficio.nominativo`,
`.qualifica` e `.contatti` sono **obbligatori**, e `contatti` (definizione
condivisa `Riferimenti`) richiede a sua volta `recapitoTelefonico` + almeno
una tra `postaElettronicaOrdinaria`/`postaElettronicaCertificata`. Un
ufficio senza responsabile configurato o senza contatti completi produrrebbe
un JSON non valido - `filtraUfficiValidiPerJsonSchema()` lo esclude dal
blocco JSON (non dal CSV, che tollera celle vuote). Verificato con test
reale: un ufficio con solo `postaElettronicaOrdinaria` (senza telefono)
compare nel CSV ma sparisce dal JSON.

**Fonte dati**: tutta già esistente nel content model, nessun nuovo
attributo (a differenza di art. 31, dove `TIPO_DOCUMENTO` serve un campo
codificato nuovo):
- `organization.type` (eztags, tassonomia "Organizzazione / Tipo di
  struttura organizzativa") per distinguere organi (`Struttura politica`) da
  uffici (`Struttura amministrativa`).
- `organization.hold_employment` per collegare un ufficio al suo organo -
  **verificato che accetta anche un organo politico come target**, non solo
  un'Area amministrativa (vedi sotto, "hold_employment non è ristretto alle
  Aree").
- `organization.office_manager` (datatype `openparole`) → `OpenPARoles::getRoles()`
  per il responsabile dell'ufficio; il ruolo trovato ha sempre tag "Responsabile"
  (è il filtro con cui il widget lo trova), quindi `QUALIFICA_DIRIGENTE` resta
  sempre vuota - coerente con l'esempio ANAC stesso, dove quel campo è vuoto.
- `time_indexed_role.incarico_dirigenziale` (booleano) per la biforcazione
  `Ufficio dirigenziale`/`Ufficio non dirigenziale`.
- `online_contact_point.contact` per i contatti (vedi sotto, formato diverso
  dalla matrice contatti della Homepage).

#### `hold_employment` non è ristretto alle Aree — una falsa pista chiarita con un test pratico

Avevo inizialmente concluso (2026-09-15, poi corretto in giornata) che
`hold_employment` collegasse un ufficio SOLO a un'Area amministrativa,
basandomi sullo schema REST (`ocopenapi`): il campo lì dichiara
esplicitamente `"Resource uri from .../amministrazione/aree-amministrative/"`
e un tentativo di impostarlo a un organo politico via API veniva rifiutato
con "Invalid value for hold_employment". Verificato anche sui siti reali
Bugliano e Verona: stesso vincolo, stessi dati (nessun ufficio mai collegato
a un organo politico).

**Sbagliato**: è un vincolo imposto solo dallo schema OpenAPI (probabilmente
derivato dal `default_placement` della classe, riusato in modo troppo
restrittivo come vincolo di validazione), non un limite del datatype
`ezobjectrelationlist` sottostante, che ha solo `class_constraint_list:
organization` (nessuna restrizione di sotto-albero). **Verificato con un
test pratico** (Marco, dal backend, non dall'API): un ufficio creato con
`hold_employment` puntato a "Consiglio comunale" (organo politico) si salva
e si legge correttamente. Il design originale del serializer (basato su
`hold_employment` per trovare gli uffici di un organo) era quindi corretto -
l'errore era testare tramite un livello (l'API REST) più restrittivo del
dato reale. **Lezione**: quando un'API restituisce un errore di validazione,
non dare per scontato che rifletta un vincolo del modello dati - può essere
un vincolo aggiunto solo da quel layer.

#### Organi di amministrazione e gestione (`art.13-oa`) — riguarda anche i comuni C1, non solo C2

**Correzione di un assunto sbagliato (2026-09-22)**: si era concluso che
`art.13-op` fosse lo schema dei comuni (C1) e `art.13-oa` quello delle
società (C2) - un fork per tipologia di ente, come per il JSON
(`orgPubblicheAmministrazioni`/`orgSocietaEdEnti`). **Sbagliato**: verificato
sulla tabella campi della guida ANAC (`guida-servizi.anticorruzione.it`,
pagina art. 13) che `SchemaPubblicheAmministrazioni` (C1) ha lo stesso campo
`organi` di `SchemaSocietaEdEnti` (C2) - nessuna distinzione lì. E sui file
di esempio CSV scaricabili: `art.13-op` ha come esempio "Consiglio" (organo
di indirizzo politico), `art.13-oa` ha come esempio "Segreteria generale"
(organo di amministrazione e gestione) - sono due **categorie di organi**
(politici vs amministrativi/gestionali) che uno stesso ente pubblica
entrambe, non un fork C1/C2. L'installer C1 (`trasparenza-c1/installer.yml`)
oggi lega solo `art.13-op` alla pagina "Articolazione degli uffici" -
`art.13-oa` non è mai bindato per un comune, quindi oggi non viene mai
pubblicato lì.

**Verificato su due siti reali indipendenti** (comune.verona.it,
comune.bugliano.pi.it - stessa piattaforma, contenuti diversi):
`organization.type` sotto la sotto-tassonomia "Struttura amministrativa"
(`/891/1265/1278/`) non è piatto come "Struttura politica" - ha una vera
gerarchia via `hold_employment`, con oggetti di vertice (Verona: 8 "Aree",
tra cui "Area Segreteria Generale" e "Area Direzione Generale", tutte con
`hold_employment` vuoto) e sotto di loro altri livelli (Verona: decine di
"Direzioni", anch'esse taggate "Area", con `hold_employment` verso la loro
Area - **gerarchia reale a 3 livelli, Area → Direzione → Ufficio**, contro i
2 livelli Organo → Ufficio dello schema ANAC).

**Il criterio "hold_employment vuoto" da solo non basta** (dati reali più
disordinati di quanto sembrasse dal solo caso Verona) - su Bugliano si sono
trovati anche: oggetti di classe `organization` che riusano la classe per
tutt'altro (`type` = "Ente", es. "Comune di Bugliano" stesso, o un ente
esterno) con `hold_employment` vuoto ma non sono organi; uffici (`type` =
"Ufficio") orfani (nessun genitore) che non sono organi, sono solo dati
incompleti; un oggetto taggato con il tag radice "Struttura amministrativa"
stesso invece che con una foglia - caso ambiguo, quasi certamente un errore
di tagging del redattore.

**Criterio scelto**: un oggetto `organization` sotto il ramo "Struttura
amministrativa" diventa un **organo** (`art.13-oa`) se e solo se: (1) il tag
`type` è **esattamente "Area"** (non una foglia diversa, non il tag radice -
esclude "Ente" e il caso di tagging ambiguo), e (2) `hold_employment` è
**vuoto** (esclude le "Direzioni", che sono anch'esse taggate "Area" ma
hanno un genitore - quelle diventano uffici, non organi). Un oggetto
`type` = "Ufficio" non diventa mai un organo, nemmeno se orfano - se non ha
un genitore valorizzato viene semplicemente omesso (stesso principio già in
uso: meglio ometterlo che rappresentarlo male). Il caso del tag radice
ambiguo non viene recuperato automaticamente - va segnalato (warning nei
log del cron), non indovinato via euristica più aggressiva (che
riprenderebbe dentro anche "Ente").

**Gerarchia a 3 livelli, appiattita ricorsivamente**: `fetchUfficiFigli()`
richiama se stessa sui figli trovati - una "Direzione" (Area con genitore)
trovata come figlia di un'Area di vertice produce comunque una riga
"Ufficio dirigenziale"/"non dirigenziale" (dipende se ha un `office_manager`
con `incarico_dirigenziale`), e i SUOI figli (i veri uffici sotto la
Direzione) vengono aggiunti alla stessa lista piatta dell'organo di vertice,
non annidati - lo schema ANAC prevede solo Organo → Ufficio, un livello
solo, qualunque sia la profondità reale nel content model.

**`art.13-op` e `art.13-oa` non sono più alternativi, sono indipendenti**:
prima il cron sceglieva UNO dei due schemi in base a quale pagina fosse
bindata (`if ($opObject) ... elseif ($oaObject) ...`), usando la scelta
anche per derivare `$isC1`. Ora un comune C1 può avere **entrambi**
bindati contemporaneamente. `$isC1` resta derivato dalla presenza di
`art.13-op` (un ente ha "organi di indirizzo politico" solo se è una
pubblica amministrazione - un fork C2 puro, senza organi politici, avrebbe
solo `art.13-oa` bindato) - `art.13-oa`, se bindato, si pubblica **in più**,
indipendentemente da `$isC1`. Nel JSON, gli organi di
`fetchOrganiConUffici()` (politici, se `art.13-op` è bindato) e quelli di
`fetchOrganiAmministrativi()` (amministrativi, se `art.13-oa` è bindato) si
concatenano nello stesso array `organi`, sotto l'unica chiave scelta da
`$isC1` (`orgPubblicheAmministrazioni`/`orgSocietaEdEnti`) - lo schema non
distingue l'origine.

**Cosa manca perché sia completo**: il binding `art.13-oa` non esiste ancora
in `installer/modules/trasparenza-c1/installer.yml` (va aggiunto assieme a
`art.13-op` sulla stessa pagina "Articolazione degli uffici", non fatto in
questo lavoro - richiede una modifica al repo `installer`, non solo a
`openpa_bootstrapitalia`). Finché non viene aggiunto, `art.13-oa` non si
attiva su nessun sito C1 reale nonostante il codice lo supporti.

#### Struttura JSON reale — diversa da quella descritta nella issue #478

Verificato scaricando gli esempi reali ANAC il 2026-09-15 (non fidarsi
dell'esempio JSON nella issue, che è un paraphrase impreciso): **non esiste
un campo `ambitoSoggettivo` esplicito**. L'ambito è espresso solo dalla
chiave usata per il blocco organi:

```json
{
    "intestazione": { ... },
    "orgPubblicheAmministrazioni": {   // C1 - "orgSocietaEdEnti" per C2
        "organi": [ ... ],
        "organigramma": "https://..."  // solo per C1, dentro questo blocco
    }
}
```

`toJson()` sceglie la chiave in base al parametro `$isC1` passato esplicitamente dal chiamante (vedi sopra, derivato da quale schema e' davvero agganciato a una pagina reale).

#### `online_contact_point.contact` — formato diverso dalla matrice della Homepage

**Non riusare `OpenPAAttributeContactsHandler`** per questo campo: è
costruito per la matrice "contacts" della Homepage (2 colonne, nome/valore).
`online_contact_point.contact` è un `eZMatrix` a 3 colonne (`type`, `value`,
`contact`), una riga per contatto - va letto con
`$attribute->content()->attribute('rows')['sequential']`, poi per ogni riga
`row['columns'][0]` (tipo, testo libero: "Telefono", "email" minuscolo nei
dati reali visti, ecc.) e `row['columns'][1]` (valore). Il matching su
"Telefono"/"Email"/"PEC" è case-insensitive ma resta fragile: il campo `type`
è testo libero, non un vocabolario chiuso — un redattore che scrive "E-mail"
o "Posta elettronica" non verrebbe riconosciuto.

#### Insidie dell'API kernel scoperte scrivendo/testando questo serializer

Non ovvie dalla sola lettura del codice, trovate solo con test reali (vedi
anche la nota su art. 4-bis "Cluster storage, non filesystem" per lo stesso
principio):

- `eZContentObjectAttribute->content()` su un campo `ezobjectrelationlist`
  restituisce `['relation_list' => [...]]`, non un array semplice - usare
  `->toString()` + `explode('-', ...)` (stesso pattern di
  `BootstrapItaliaInstallerUtils::appendToHeaderLink` e di
  `OpenPARoles::getRolesPerPerson()`), non `content()`.
- `->content()` su un campo `eztags` restituisce un oggetto `eZTags`, non un
  array con chiave `keywords` - usare `->attribute('tags')` per ottenere i
  veri `eZTagsObject` (con `->attribute('path_string')`/`->attribute('keyword')`).
- `->content()` su un campo `ezxmltext`, poi `->attribute('output')`,
  restituisce un oggetto `eZXHTMLXMLOutput` - il testo è
  `->attribute('output')->attribute('output_text')`, non un array.
- `eZContentObject::fetchSameClassList()` vuole l'**ID numerico** della
  classe (`eZContentClass::fetchByIdentifier('organization')->attribute('id')`),
  non l'identifier stringa, e i parametri sono posizionali
  (`$asObject, $offset, $limit`), non un hash di opzioni.

### `Art31Serializer` — tre CSV + un JSON, due meccanismi diversi

Copre `art.31-oiv` (Organismi indipendenti di valutazione), `art.31-or`
(Organi di revisione) e `art.31-oc` (Corte dei conti), più il JSON "file
unico" (`art.31`, nessun suffisso — verificato scaricando il nome del file
di esempio reale, non dedotto da un riassunto della pagina guida, vedi
"Fonte di verità" sopra) che copre tutte e tre le sottosezioni insieme.
A differenza di `Art13Serializer`, `Art31Serializer` non ha mai un
parametro `$isC1`: lo schema ANAC non prevede output diverso per C1/C2 su
questi export, solo la pagina che li ancora cambia - nessun gate di
tipologia in `publishArt31()`, il binding reale su `schema_pubblicazione`
decide da solo quale pagina (C1 o C2, quale che sia installata) espone
ciascuno schema.

**Due meccanismi di esposizione diversi, NON unificati** (decisione presa
con Marco il 2026-09-15, motivata dalla natura diversa dei dati):

- **OIV e Organi di revisione**: nessun dataset dedicato. Sono documenti
  (classe `document`) taggati con il nuovo attributo `anac_document_type`
  (vedi `installer/modules/trasparenza/CLAUDE.md` per il perché di questa
  scelta di content model). `fetchDocumentsByKeys()` fa uno scan PHP
  dell'intera classe `document` (`eZContentObject::fetchSameClassList()`),
  non una query Solr — scelta deliberata: si è verificato che
  `Opencontent\...\QueryLanguage\Query` non ha modo comodo di filtrare su un
  campo custom nuovo senza prima capire la convenzione di naming Solr per
  `anac_document_type` (non ancora esplorata), e lo scan pieno è lo stesso
  pattern già accettato per `Art13Serializer::fetchOrganiConUffici()` — costo
  accettabile per un cron periodico, non per una richiesta utente.
- **Corte dei conti**: dataset reale (`opendatadataset`, remote_id
  `corte_dei_conti`), stesso pattern di `Art4BisSerializer` — colonne
  `data_di_pubblicazione`/`oggetto`/`documento` (vedi
  `installer/modules/anac-495-2024/contents/Corte-dei-conti.yml` o
  `trasparenza-c1/contents/Corte-dei-conti-Dataset.yml`).

**"Il documento più recente per chiave" per OIV/Organi di revisione**:
decisione 2026-09-15. Nello schema JSON ANAC, ciascuna delle 5 chiavi
(`validazioneRelazioneSullaPerformance`, `relazioneSistemaDiValutazione`,
`altriAttiOrganismoAnalogo`, `relazioneBilancioDiPrevisione`,
`relazioneContoConsuntivo`) è un blocco **singolare** (`DatiIdentificativiDocumento`,
un solo `dataPubblicazione`+`documento`, non un array) — ma niente impedisce
a un redattore di taggare più documenti con lo stesso `anac_document_type`
nel tempo (es. una nuova relazione ogni anno). Se succede, il JSON tiene solo
il documento con `publication_start_time` più recente per quella chiave; il
CSV invece li elenca **tutti** (nessuna riduzione), quindi CSV e JSON possono
avere cardinalità diverse per la stessa sottosezione — lo storico non si
perde comunque, resta nei file datati immutabili di `ExportPublisher`.

**Un documento incompleto sparisce da CSV e JSON**, non solo dal JSON (a
differenza di `Art13Serializer`): se manca il file allegato o la data di
pubblicazione, `fetchDocumentUrl()`/`fetchPublicationDate()` restituiscono
`null` e il documento viene scartato ovunque (`buildDatiIdentificativiBlock()`
e `toCsvDocumenti()` condividono lo stesso controllo). Diverso da art. 13
perché qui non c'è un CSV "meno esigente" dello schema JSON da preservare: un
documento senza file scaricabile non è comunque pubblicabile in nessuna
forma.

**Vocabolario "oggetto" della Corte dei conti — apostrofo, non accento**:
verificato scaricando `art.31-v1.0.schema.json` (definizione
`OggettoRilievoCorteDeiConti`): i valori ammessi sono `Organizzazione`,
`Attivita'` (con l'apostrofo dritto) e `Entrambe` — questo risolve
un'ambiguità che la issue #477 stessa segnalava come non chiarita tra la
tabella campi della guida online e l'Allegato 3 della delibera. Il redattore
scrive quasi certamente "Attività" con l'accento nel dataset (testo libero):
`normalizeOggetto()` confronta ignorando accenti/apostrofi/maiuscole, ma
**restituisce sempre la stringa canonica esatta dello schema** (con
l'apostrofo), non quella scritta dal redattore.

**Testato con dati reali in `sito-comunale-dev`** (2026-09-15): due document
esistenti taggati temporaneamente (`Validazione della Relazione sulla
Performance`, `Relazione al bilancio di previsione`), url `content/download`
reali generate, poi tag ripristinati a vuoto - vedi CSV/JSON di esempio nel
commit. Il dataset Corte dei conti era vuoto in dev: verificato solo che
CSV/JSON gestiscono correttamente il caso vuoto (CSV solo header, blocco
`attiOrganiDiControllo` omesso dal JSON) e la logica di normalizzazione
vocabolario/eccezione via chiamata diretta a `mapRilievo()`, non l'inserimento
reale di una riga nel dataset.

## Gestione errori e casi limite

### Le due eccezioni di dominio, e cosa succede davvero quando scattano

| Eccezione | Quando | Dove viene lanciata |
|---|---|---|
| `MissingCodiceFiscaleException` | Codice fiscale non compilato nei contatti Homepage, oppure compilato ma non 11 cifre numeriche | `IntestazioneProvider::getAmministrazione()` — **prima ancora di leggere una sola riga del dataset**, perché l'intestazione è comune a tutto l'export |
| `InvalidVocabolarioException` | Categoria/tipologia/beneficiario di UNA riga non corrisponde a nessuna voce del vocabolario ANAC (case/spazi-insensitive) | `Art4BisSerializer::matchVocabolario()`, chiamata da `mapItem()` dentro il loop di `toCsv()`/`toJson()` |
| `EmptyExportException` | Un array richiesto non vuoto dallo schema JSON ANAC (`minItems: 1`) risulterebbe vuoto — es. `datiSuiPagamenti` (art.4-bis) o `organi` (art.13) | `Art4BisSerializer::toJson()`, `Art13Serializer::toJson()` — dopo aver risolto i dati, prima di costruire l'output |

Ogni `publishXXX()` in `cronjobs/anac_export.php` è avvolto nel proprio
`try/catch (\Exception $e)` (un fallimento su uno schema non deve bloccare
gli altri): logga con `eZDebug::writeError()` + `$cli->error()`, quindi
visibile nei log del cron, non silenzioso.

Conseguenze concrete, non ovvie:

- **Tutto-o-niente per schema**: se anche una sola riga su mille ha un
  beneficiario scritto male, l'intero export (CSV e JSON) di quello schema
  fallisce — non viene generato un file parziale con le righe buone. Il file
  `-latest` esistente resta quello vecchio (non si aggiorna, ma non si rompe
  nemmeno: `ExportPublisher::publish()` non viene mai raggiunto perché il
  serializer lancia prima di restituire csv/json).
- **Nessuna notifica attiva**: il cron logga l'errore (visibile nei log), ma
  non manda un alert a redattori/RTD. Per un obbligo di trasparenza con
  scadenze legali il file pubblico può restare silenziosamente vecchio finché
  qualcuno non controlla i log - rischio reale, non solo un dettaglio tecnico.
- **Un errore sul codice fiscale (comune a tutti gli schemi) blocca TUTTI gli
  export**, non solo quello in corso — `IntestazioneProvider` è condiviso.
- **Scartare la singola riga malformata e pubblicare comunque le altre non è
  implementato** (rischio opposto: dato mancante silenziosamente, non errore
  bloccante ma incompletezza non segnalata) — il comportamento è
  deliberatamente tutto-o-niente per schema.

### `ExportPublisher` — comportamento silenzioso da conoscere

- **Idempotenza vera**: chiamare `publish()` più volte con lo stesso
  contenuto (hash identico) è un no-op completo — non riscrive i file, non
  tocca gli url alias. Chiamare il cron più volte al giorno per sicurezza non
  ha controindicazioni.
- **`$rootNodeId` che non risolve a un nodo valido fallisce in silenzio**:
  `publishUrlAlias()` fa solo `return` se `eZContentObjectTreeNode::fetch()`
  non trova il nodo — **il file viene comunque scritto su cluster storage**,
  ma resta senza url pubblico, senza nessun errore/warning. Scenario reale in
  cui questo capita: un ente ha ancora il vecchio modulo monolitico
  `anac-495-2024` (non ha `trasparenza-c1`), quindi il nodo con remote_id
  `dati_sui_pagamenti` esiste con un `node_id` diverso o addirittura con un
  layout diverso — se il cron gira con un node id sbagliato/non aggiornato
  per quel tenant, non si accorge di nulla. Da tenere a mente per un rollout
  multi-tenant a scaglioni (vedi [[project_nuova_trasparenza_anac]] in
  memoria).
- **Cluster storage, non filesystem**: `eZClusterFileHandler` astrae se il
  backend è locale o DB/S3 (`--embed-dfs-schema`) — in locale il file può non
  esistere su disco reale pur risultando `exists()` vero (verificato: in
  `sito-comunale-dev`, che pure gira in cluster mode DFS, `file_exists()` sul
  path grezzo dà `no` mentre `eZClusterFileHandler->exists()` dà `yes`). Non
  usare mai `file_exists()`/`file_get_contents()` diretti su questi path.

### Modulo `anac_export/file.php` — cosa restituisce e quando

- Filename non valido o con caratteri fuori whitelist (`[a-zA-Z0-9_.\-]`) o
  file non trovato su cluster storage → HTTP 404 (`eZError::KERNEL_NOT_FOUND`,
  non 410). Il 410 visto durante lo sviluppo era sempre `KERNEL_ACCESS_DENIED`
  (bug #2 sopra), non "file assente" — i due casi sono distinguibili dal
  codice HTTP.
- `basename()` sul parametro `Filename` prima di costruire il path: previene
  path traversal (`../../altra_cartella`) sul cluster storage, dato che il
  parametro arriva da URL pubblica non autenticata.
- Nessun controllo di accesso applicativo oltre alla policy di ruolo — a
  differenza di `ocexportas` (che nel costruttore di `AbstarctExporter` fa
  anche un controllo `checkAccess()` applicativo in aggiunta alla policy),
  qui non serve: sono dati obbligatoriamente pubblici, non c'è nessuna
  limitazione da applicare oltre "chiunque può leggerli".

## Cosa manca (non ancora costruito)

- **Art. 13 — `art.13-oa`**: vedi sezione dedicata sotto ("Organi di
  amministrazione e gestione") - **non è C2-only come si credeva
  inizialmente** (correzione 2026-09-22), riguarda anche i comuni C1.
- **Art. 13 — `art.13-org` (organigramma)**: non implementato,
  `Art13Serializer::fetchOrganigramma()` restituisce sempre `null`. Non
  individuata la sorgente dati reale nel content model (probabile immagine
  su un contenuto dedicato, non un campo di `organization`).
- **Art. 13 — riga CSV per organo senza uffici**: scelto (non verificato al
  100%) di omettere l'organo dal CSV `art.13-op` se non ha uffici collegati,
  mantenendolo nel JSON con `uffici: []`. Gli esempi ANAC scaricati il
  2026-09-15 hanno sempre almeno un ufficio per organo, non risolvono il
  caso in modo definitivo.
- **Cron/wiring**: copre art. 4-bis, art. 13 (C1 e C2) e art. 31 (C1 e C2)
  (`openpa_bootstrapitalia/cronjobs/anac_export.php`, registrato sotto
  `[CronjobPart-changesection]` in `settings/cronjob.ini.append.php` —
  scelta provvisoria: gruppo con semantica sbagliata ma zero costo
  infrastrutturale aggiuntivo sul cron SaaS, `CONCURRENCY=2` su ~600 tenant —
  da rivedere con un gruppo dedicato in futuro). Da estendere quando arriva
  art. 13/C2. `hasAnyAnacExportActive()` in cima al file esce subito, senza
  scansionare `pagina_trasparenza`, sui tenant senza nessuno schema ANAC
  attivo (la maggioranza dei ~600) — controlla sia `schema_pubblicazione` sia
  l'esistenza del dataset `dati_sui_pagamenti` (l'art.4-bis non dipende da
  `schema_pubblicazione`, vedi sopra: senza questo secondo controllo un sito
  con solo l'art.4-bis attivo verrebbe saltato per errore).
- **#479, retention (cosa succede ai file dopo i 5 anni dell'obbligo di
  conservazione)**: **nessuna rimozione automatica per ora**. Il rischio di
  cancellare per errore un dato ancora dovuto è più grave del costo di tenere
  file in più - un meccanismo di retention andrà deciso/implementato solo
  quando il primo schema arriverà davvero a 5 anni di storico reale. Non
  implementato, nessun codice a riguardo.
- **#479, indicizzazione (le versioni storiche vanno escluse dai motori di
  ricerca?)**: non deciso formalmente. I link allo storico nel template sono
  `<a href>` server-side, quindi raggiungibili da un crawler anche a pannello
  "Versioni precedenti" chiuso - le versioni superate sono di fatto
  scrapabili quanto la versione corrente. La Guida ANAC vieta di limitare
  l'accesso dei crawler alla sezione Amministrazione Trasparente in
  generale, e #479 stesso richiede un "indice o elenco delle versioni
  raggiungibile dal nodo AT" per assolvere l'obbligo di conservazione
  quinquennale (art. 8 co. 3 d.lgs. 33/2013) in modo utile: questo depone a
  favore di **non** aggiungere `noindex`/`robots.txt`, coerente sia col
  divieto sui crawler sia con l'obbligo di raggiungibilità. Resta comunque il
  punto con meno appiglio normativo dei cinque elencati in #479 - nessun
  `noindex`/`robots.txt` implementato per i file datati non-`-latest`.
- **Validazione JSON Schema ANAC**: resta un controllo manuale in QA, nessuna
  validazione automatica nel codice (decisione esplicita, non un gap
  dimenticato).
