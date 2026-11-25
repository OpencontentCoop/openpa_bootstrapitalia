# Trasparenza art. 35 "Tipologie di procedimento" — due piani alternativi

> Documento di confronto, non ancora una decisione. Copre solo profilo C1, solo italiano (niente tedesco in questo giro). Issue di riferimento da aprire su GitLab dopo la scelta dell'approccio.

**Pagina di test:** https://www.comune-qa.bugliano.pi.it/Amministrazione-Trasparente/Attivita-e-procedimenti/Tipologie-di-procedimento — oggi pagina di trasparenza vuota (solo testo libero), nessun dato strutturato.

**Schema di riferimento:** `art.35-v1.0.schema.json` (scaricato e verificato), 4 CSV ufficiali (`art.35-proc`, `art.35-uff`, `art.35-uff-istanze`, `art.35-uff-sost`) + 1 JSON (`art.35-*.json`).

**Scope comune a entrambi i piani (deciso con Marco):**
- `tipologia` resta testo libero (nessun vocabolario: ANAC non impone un elenco e ogni ente ha la propria tabella dei procedimenti).
- `accessoInformazioni` e `potereSostitutivo.attivazione` restano testo libero (ANAC non vincola un enum su questi campi; nessuna evidenza sufficiente per un vocabolario condiviso tra i 600 enti).
- **`infoInoltroIstanze` (modulistica istanze di parte + array di fasce orarie) — INCLUSO nel Piano A, escluso nel Piano B.** Analisi approfondita con Marco: il blocco è molto più economico di una prima stima, grazie al riuso delle relazioni già previste.
  - **Trigger implicito (idea di Marco, più pulita del boolean separato):** niente campo SI/NO a parte — è la relazione `application_office` stessa a fare da segnale. Se valorizzata → istanza di parte, si emette `infoInoltroIstanze`; se vuota → blocco omesso. Il redattore la seleziona esplicitamente anche quando l'ufficio è lo stesso del responsabile (nessun fallback automatico silenzioso, per non avere un segnale ambiguo).
  - **Ufficio (denominazione/indirizzo/contatti):** derivato da `application_office`, attraversando `organization.has_spatial_coverage → place.has_address` (indirizzo) e `place.opening_hours_specification` (orari) — stessa catena di relazioni già usata per `responsible_office`, solo un'altra relazione dello stesso tipo.
  - **Modulistica:** non è un campo per-record. È un **URL fisso di sito**, risolto a export-time dal `remote_id` della pagina Modulistica del tenant (default `cfd0a916ca48eb7d4a78bb6beb7821f9`, verificato in locale su "Comune di Marcon": `/Amministrazione/Documenti-e-dati/Modulistica`) tramite `eZContentObject::fetchByRemoteID()` + `url_alias` del nodo principale — robusto a traduzioni/rinomina del path. Da valutare se serve renderlo configurabile per ente in futuro (stesso pattern ini già visto altrove in questo modulo), non necessario ora.
  - **Orari:** derivati dalla matrice `opening_hours_specification.opening_hours` (colonne fisse Lunedì-Domenica, **valore di cella testo libero**, es. "9:00-12:00") — serve un parser per estrarre `oraInizio`/`oraFine` nel formato richiesto da ANAC. **Decisione di Marco: se anche un solo giorno non è interpretabile, l'export per questo schema va in errore** (stesso meccanismo già esistente di gestione errori per-schema nel cron, es. `recordAnacExportError()`), non uno skip silenzioso del giorno — così l'errore è visibile e correggibile dal redattore/amministratore, invece di pubblicare dati silenziosamente incompleti.
  - Resta comunque il quarto CSV (`art.35-uff-istanze`) da scrivere nel serializer, con le sue colonne e righe ripetute per fascia oraria — lavoro meccanico, non più "il blocco più costoso".
  - **Nel Piano B (Dataset) resta escluso:** il framework Dataset non ha relazioni (niente riuso di ufficio/orari) né un tipo di campo ripetibile/array (niente modo pulito di rappresentare più fasce orarie per riga) — includerlo lì richiederebbe duplicare tutto a mano per ogni procedimento, senza nessuno dei riusi che lo rendono economico nel Piano A.
- Repo coinvolti: `installer` (content model) e `openpa_bootstrapitalia` (serializer/export), branch `trasparenza-additional-scheme-35` su entrambi, da `main`/`master`.

---

## Piano A — Content Type dedicato

### Modello dati

Nuova classe eZ `administrative_procedure` (installer YAML) — identificatori in inglese, come il resto delle classi del prodotto (`organization`, `public_service`, `public_person`, `opening_hours_specification`), etichette in italiano:

| Identificatore | Etichetta italiana | Tipo | Obbligatorio | Note |
|---|---|---|---|---|
| `title` | Denominazione | ezstring | sì | nome oggetto |
| `procedure_type` | Tipologia | ezstring | sì | testo libero |
| `description` | Descrizione | eztext | sì | |
| `legal_references` | Riferimenti normativi | eztext | sì | |
| `organizational_unit` | Unità organizzativa | ezstring | no | |
| `responsible_office` | Ufficio responsabile | ezobjectrelation → `organization` | sì | contatti e nome ufficio derivati dalla relazione |
| `competent_office` | Ufficio competente | ezobjectrelation → `organization` | no | `nominativoResponsabile` derivato da `organization.office_manager` (ruolo "Responsabile") |
| `information_access` | Accesso alle informazioni | eztext | sì | |
| `completion_term` | Conclusione del procedimento | eztext | sì | |
| `substitute_declaration` | Dichiarazione sostitutiva | select/bool SI-NO | sì | |
| `tacit_consent` | Silenzio assenso | select/bool SI-NO | sì | |
| `legal_remedies` | Strumenti di tutela | eztext | sì | |
| `related_public_service` | Servizio pubblico collegato | ezobjectrelation → `public_service` | no | `servizioOnline.urlServizio` = pagina del servizio |
| `service_activation_time` | Tempi di attivazione servizio | ezstring | no | alternativa a `related_public_service` (vincolo "almeno uno" solo in guida, non bloccante — stesso schema di PEO/PEC su art.26-27) |
| `online_payments` | Pagamenti informatici | ezurl | sì | |
| `substitute_power_holder` | Titolare potere sostitutivo | ezobjectrelation → `public_person` | no | qualifica derivata dal ruolo della persona |
| `substitute_power_activation` | Attivazione potere sostitutivo | eztext | no | testo libero |
| `application_office` | Ufficio istanze | ezobjectrelation → `organization` | no | **fa anche da trigger**: se valorizzato, il procedimento è a istanza di parte e si emette `infoInoltroIstanze` (denominazione/indirizzo/contatti/orari derivati da questo ufficio); se vuoto, il blocco è omesso. Il redattore lo seleziona esplicitamente anche quando coincide con `responsible_office` — nessun fallback automatico, per evitare ambiguità sul segnale |

**Da verificare in fase di build (non bloccante per questo piano):** se il ruolo di `public_person` porta con sé anche l'ufficio di appartenenza (per `potereSostitutivo.ufficio`), o se serve un campo/relazione in più.

### ⚠️ Problema individuato e risolto: figli diretti della pagina

**Decisione di Marco: i `administrative_procedure` si creano come figli diretti del nodo "Tipologie di procedimento"** — sono contenuti di trasparenza specifici di quella pagina, a differenza di `document` (riusato altrove per più scopi), non ha senso farli vivere in un nodo separato.

Verificato nel codice che questo **funziona, con una piccola correzione**. Il template `pagina_trasparenza.tpl` ha due blocchi indipendenti che oggi non si escludono a vicenda:
- la tabella live-render (`{if $trasparenza.live_rendering_blocks}`, riga 221-227)
- "altri contenuti": **tutti** i figli diretti tranne una lista di classi escluse (`{if $trasparenza.count_children_extra}`, riga 229, calcolata da `getExcludeClassesForExtraChildren()` in `classes/services/content_trasparenza.php:601-636`)

Quella funzione di esclusione oggi **non consulta mai `LiveRenderingRegistry`** — finora non si è mai visto il problema perché le classi gestite da live-rendering (`document` per Provvedimenti, `organization` per Articolazione uffici) non sono mai state figlie dirette della pagina trasparenza, quindi il blocco "altri contenuti" era vuoto per caso, non per esclusione esplicita. Se `administrative_procedure` diventa figlio diretto, comparirebbe anche lì, duplicando la tabella.

**Fix, piccolo e localizzato:** estendere `getExcludeClassesForExtraChildren()` perché includa anche le classi gestite da `LiveRenderingRegistry` per quello schema (la stessa lista già letta altrove, riga 665, per il messaggio "regole di rappresentazione ignorate") nel merge di riga 631. Una riga di codice in un metodo esistente, non un redesign — va aggiunto come task esplicito del piano.

**Conseguenza positiva:** niente nuovo nodo contenitore, niente nuovo Role/Policy per un nodo separato — i redattori creano i procedimenti con il normale permesso di creazione contenuti sotto quel nodo (stesso pattern di qualunque altra sotto-pagina), serve solo il Role/Policy standard per la nuova classe.

**Altri problemi dello stesso tipo, individuati per analogia:**
- **Pagina di dettaglio per procedimento — decisione di Marco: niente link, a meno che non diventi necessario.** Resta solo la tabella, senza vista di dettaglio individuale per ora.
- **Bozza/privato.** Un procedimento in bozza o reso privato deve produrre zero righe sia in tabella sia in export — stesso meccanismo già verificato e funzionante per Provvedimenti/art.23 (stessa infrastruttura `LiveRenderingRegistry` + `ExportPublisher`), quindi atteso corretto "gratis", ma da confermare in test.

### Cosa si vede in pagina

Una sola tabella live-render "Tipologie di procedimento" (DataTables, stesso stile di Provvedimenti/art.23), con filtri Tipologia / Ufficio responsabile / Anno (se rilevante) e ricerca testuale. Il blocco "altri contenuti" (figli diretti) va esplicitamente escluso per questa classe (vedi fix sopra) — nessun elenco figli nativo, nessun link di dettaglio per riga.

### Cosa viene esportato

| File | Prodotto? | Contenuto |
|---|---|---|
| `art.35-proc-*.csv` | ✅ sì | tutti i campi piatti + riferimenti a ufficio/servizio risolti dalle relazioni |
| `art.35-uff-*.csv` | ✅ sì | **derivato dalle relazioni**: una riga per ogni `organization` effettivamente referenziata (come `responsible_office` o `competent_office`) da almeno un procedimento — nessuna duplicazione, nessun rischio di disallineamento nomi |
| `art.35-uff-istanze-*.csv` | ✅ sì | derivato da `application_office` + `opening_hours_specification`, una riga per fascia oraria interpretabile, solo per i procedimenti dove `application_office` è valorizzato |
| `art.35-uff-sost-*.csv` | ✅ sì | derivato dalla relazione a `public_person`, una riga per titolare distinto |
| `art.35-*.json` | ✅ sì | `procedimenti[]` completo con `ufficioResponsabile`, `ufficioCompetente` (se presente), `servizioOnline`, `potereSostitutivo` (se presente), `infoInoltroIstanze` (se `application_office` valorizzato) |

### Stima e rischi
- Classe + ruoli/policy: poche ore, lavoro meccanico.
- Fix a `getExcludeClassesForExtraChildren()`: piccolo, un'ora circa.
- Form di inserimento: **gratis** (nativo eZ, incluso il picker per le relazioni).
- Nuovo provider live-rendering: ~1 giorno, pattern collaudato 3 volte (art.13/23/31).
- Parser orari (`opening_hours_specification` → `FasciaOraria` ANAC) + gestione errore per-schema se un giorno non è interpretabile: mezza giornata circa.
- Serializer + cron + `ExportPublisher` + validazione JSON Schema: lavoro standard, stesso di qualunque nuovo schema ANAC già fatto.
- **Totale indicativo: qualche giorno in più del piano B**, ma zero duplicazione dati, relazione nativa, export "uffici"/"potere sostitutivo"/"istanze" correttamente normalizzati, copertura quasi completa dello schema (solo `ufficioCompetente.nominativoResponsabile` e simili restano da confermare in build).

---

## Piano B — Dataset generico (come "Atti di concessione")

### Modello dati

Uno o due dataset (framework `occustomfind/datatypes/opendatadataset/`, stesso meccanismo di "Atti di concessione"):

- **Opzione B1 (un solo dataset "Tipologie di procedimento")**: una riga = un procedimento, con TUTTI i campi di `responsible_office`/`competent_office`/`substitute_power_holder` **appiattiti e duplicati** sulla riga stessa (denominazione ufficio, telefono, PEO/PEC inseriti a mano ogni volta; stesso per il titolare del potere sostitutivo). Nessuna relazione: il framework Dataset non la supporta (verificato nel codice, nessun tipo di campo `relation` esiste).
- **Opzione B2 (due dataset, "Procedimenti" + "Uffici")**: un secondo dataset "Uffici" riusabile, collegato al primo per **nome/denominazione testuale** (stesso meccanismo usato da ANAC nei propri CSV di esempio) — evita di ridigitare i contatti, ma introduce un rischio concreto di disallineamento (nome scritto in modo leggermente diverso = aggancio che si rompe), senza un vero vincolo di integrità.

Consiglio, se si va di Dataset: **B1**, perché B2 introduce fragilità senza eliminarla del tutto (vedi sotto, l'import CSV/Google Sheet dovrebbe comunque fare matching per nome).

### Nessun problema di "figli nella pagina"

I dataset non creano oggetti-figlio nell'albero: i record vivono dentro un'unica tabella in un attributo dell'oggetto "Tipologie di procedimento" stesso. Il problema individuato nel Piano A **non esiste** in questo piano.

### Cosa si vede in pagina

Tabella generica del framework Dataset (stessa UX di "Atti di concessione"): ricerca, filtro per Anno/Ufficio già pronti, nessun codice nuovo.

### Cosa viene esportato

| File | Prodotto? | Contenuto |
|---|---|---|
| `art.35-proc-*.csv` | ✅ sì | tutti i campi, incluse le colonne ufficio/titolare duplicate riga per riga |
| `art.35-uff-*.csv` | ⚠️ parziale/da decidere | per essere conforme all'esempio ANAC (una riga per ufficio distinto) servirebbe comunque una deduplica a posteriori nel serializer, sui valori testuali inseriti dai redattori — **stesso rischio di disallineamento per typo già discusso con Marco**; alternativa più semplice e più robusta: non generarlo affatto e lasciare i dati ufficio solo dentro `art.35-proc.csv` (si perde un po' di aderenza alla forma "esempio" di ANAC, resta comunque dato valido) |
| `art.35-uff-istanze-*.csv` | ❌ no | escluso (vedi scope comune) |
| `art.35-uff-sost-*.csv` | ⚠️ stesso discorso di `art.35-uff` | stessa scelta da fare: deduplica fragile o non generarlo |
| `art.35-*.json` | ✅ sì | stessa completezza del Piano A (il JSON non richiede normalizzazione, solo oggetti annidati) — unica differenza: i valori di `ufficioResponsabile`/`potereSostitutivo` vengono dai campi piatti del dataset, non da una relazione viva |

### Stima e rischi
- Nessun nuovo content_type, nessun nuovo provider: riusa l'infrastruttura Dataset esistente al 100%.
- Serializer + cron + `ExportPublisher` + validazione JSON Schema: stesso lavoro del Piano A.
- **Totale indicativo: qualche giorno in meno del piano A**, ma: dati ufficio/titolare duplicati a ogni inserimento (nessuna fonte unica, un cambio di PEC richiede modifica manuale su ogni riga che lo cita), e i 2 CSV "lookup" (`art.35-uff`, `art.35-uff-sost`) o sono generati con un rischio di frammentazione per typo, o vengono omessi (minore aderenza al formato di esempio ANAC, ma dato comunque valido).

---

## Confronto rapido

| | Piano A — Content Type | Piano B — Dataset |
|---|---|---|
| Relazione a Ufficio/Persona | nativa, zero duplicazione | assente, dati duplicati per riga |
| Figli diretti in pagina | sì (voluto), serve piccolo fix a `getExcludeClassesForExtraChildren()` (~1h) | non applicabile (nessun figlio, i record vivono in un attributo) |
| CSV `art.35-uff` / `art.35-uff-sost` | normalizzati correttamente | a rischio typo, o omessi |
| `infoInoltroIstanze` / `art.35-uff-istanze` | ✅ incluso, costo contenuto grazie al riuso delle relazioni | ❌ escluso (nessuna relazione, nessun campo ripetibile nel framework Dataset) |
| Form di inserimento | gratis (nativo eZ + picker relazione) | gratis (Alpaca, già pronto) |
| Tabella pubblica con filtri | da costruire (~1 giorno, pattern collaudato) | già pronta, zero codice |
| Sforzo totale stimato | qualche giorno in più | più snello |

Nessuna raccomandazione finale in questo documento: la scelta dipende dai giorni effettivamente disponibili e da quanto pesa, per Marco, la qualità/normalizzazione dei 2 CSV "lookup" rispetto al tempo risparmiato.
