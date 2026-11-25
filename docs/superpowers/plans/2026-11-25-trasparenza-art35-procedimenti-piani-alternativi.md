# Trasparenza art. 35 "Tipologie di procedimento" — due piani alternativi

> Documento di confronto, non ancora una decisione. Copre solo profilo C1, solo italiano (niente tedesco in questo giro). Issue di riferimento da aprire su GitLab dopo la scelta dell'approccio.

**Pagina di test:** https://www.comune-qa.bugliano.pi.it/Amministrazione-Trasparente/Attivita-e-procedimenti/Tipologie-di-procedimento — oggi pagina di trasparenza vuota (solo testo libero), nessun dato strutturato.

**Schema di riferimento:** `art.35-v1.0.schema.json` (scaricato e verificato), 4 CSV ufficiali (`art.35-proc`, `art.35-uff`, `art.35-uff-istanze`, `art.35-uff-sost`) + 1 JSON (`art.35-*.json`).

**Repo coinvolti:** `installer` (content model) e `openpa_bootstrapitalia` (serializer/export), branch `trasparenza-additional-scheme-35` su entrambi, da `main`/`master`.

---

## Piano A — Content Type dedicato

### Modello dati

Nuova classe eZ `administrative_procedure` (installer YAML) — identificatori in inglese, come il resto delle classi del prodotto (`organization`, `public_service`, `public_person`, `opening_hours_specification`), etichette e descrizioni in italiano:

| Identificatore | Etichetta italiana | Tipo | Obbligatorio | Descrizione per il redattore |
|---|---|---|---|---|
| `title` | Denominazione | ezstring | sì | Nome del procedimento, facilmente comprensibile dal cittadino |
| `procedure_type` | Tipologia | ezstring | sì | Categoria del procedimento secondo la classificazione interna dell'ente (testo libero, nessun vocabolario imposto: ogni ente ha la propria tabella dei procedimenti) |
| `description` | Descrizione | ezxmltext | sì | Breve descrizione del procedimento e del suo oggetto |
| `legal_references` | Riferimenti normativi | ezstring | sì | Norme (legge, regolamento) che disciplinano il procedimento |
| `organizational_unit` | Unità organizzativa | ezstring | no | Denominazione dell'unità organizzativa competente, se diversa dall'ufficio responsabile indicato sotto |
| `responsible_office` | Ufficio responsabile | ezobjectrelation (singola) → `organization` | sì | Ufficio che istruisce il procedimento — seleziona l'unità organizzativa già censita in Organizzazione: da lì si prendono automaticamente denominazione e contatti |
| `competent_office` | Ufficio competente | ezobjectrelation (singola) → `organization` | no | Ufficio che adotta il provvedimento finale, solo se diverso dall'ufficio responsabile — il nominativo del responsabile si deriva da `organization.office_manager` (ruolo "Responsabile") |
| `information_access` | Accesso alle informazioni | ezstring | sì | Come un interessato può avere informazioni sullo stato del proprio procedimento (es. telefono, PEC, sportello) |
| `completion_term` | Conclusione del procedimento | ezstring | sì | Termine entro cui il procedimento si conclude (es. "90 giorni dalla presentazione dell'istanza") |
| `substitute_declaration` | Dichiarazione sostitutiva | select/bool SI-NO | sì | Indica se il provvedimento finale può essere sostituito da un'autocertificazione dell'interessato |
| `tacit_consent` | Silenzio assenso | select/bool SI-NO | sì | Indica se il silenzio dell'amministrazione, decorso il termine, equivale ad accoglimento della richiesta |
| `legal_remedies` | Strumenti di tutela | ezstring | sì | Come un interessato può opporsi all'esito del procedimento (es. ricorso al TAR, ricorso gerarchico) |
| `related_public_service` | Servizio pubblico collegato | ezobjectrelation (singola) → `public_service` | no | Scheda del Servizio pubblico da cui si accede online al procedimento, se esiste — la sua pagina diventa il link di accesso al servizio |
| `service_activation_time` | Tempi di attivazione servizio | ezstring | no | Da compilare solo se non c'è un servizio online collegato: indica quando sarà disponibile (vincolo "almeno uno tra i due" solo in guida, non bloccante — stesso schema di PEO/PEC su art.26-27) |
| `online_payments` | Pagamenti informatici | ezurl | sì | Link alla pagina dove effettuare eventuali pagamenti collegati al procedimento |
| `substitute_power_holder` | Titolare potere sostitutivo | ezobjectrelation (singola) → `public_person` | no | Persona a cui rivolgersi in caso di inerzia del responsabile del procedimento — qualifica derivata dal ruolo della persona |
| `substitute_power_activation` | Attivazione potere sostitutivo | ezstring | no | Come attivare il potere sostitutivo (es. "PEC all'indirizzo istituzionale") |
| `application_office` | Ufficio istanze | ezobjectrelation (singola) → `organization` | no | Compila solo se il procedimento si avvia su richiesta del cittadino: seleziona l'ufficio dove presentare la domanda (anche se coincide con l'ufficio responsabile sopra). **Se lasci vuoto questo campo, il procedimento è considerato avviato d'ufficio** e questa parte non viene pubblicata |

**Tutte le relazioni sono a selezione singola (`ezobjectrelation`), non a lista.** Lo schema JSON ANAC definisce `ufficioResponsabile`, `ufficioCompetente`, `servizioOnline`, `potereSostitutivo` e `infoInoltroIstanze` come **oggetti singoli**, non array: se la relazione permettesse più selezioni non ci sarebbe un modo univoco di scegliere quale oggetto mappare in quel campo del JSON. Nessuna di queste relazioni deve quindi essere una `ezobjectrelationlist`.

**Verificato: `potereSostitutivo.qualifica`/`ufficio` si risolvono tramite relazione inversa a `time_indexed_role`** (classe esistente "Ruolo di una persona nel tempo", già usata per art.13 "Titolari di incarichi politici"): il serializer cerca gli oggetti `time_indexed_role` il cui campo `person` include `substitute_power_holder`, e legge `role` (tag → qualifica) e `for_entity` (relazione a `organization` → ufficio).

**Scelta del ruolo "attuale" quando la persona ne ha più di uno: zero logica nuova da scrivere, esiste già.** `OpenPARoles` (`datatypes/openparole/openparoles.php`) è la classe già usata da tutto il sito per questa stessa selezione — incluso `Art13Serializer::fetchResponsabile()`, che risolve `office_manager` esattamente allo stesso modo. Filtra per validità temporale (`start_time`/`end_time`, scarta i ruoli scaduti), ordina per `priorita` discendente, prende il primo risultato (`reset($roles)`). Per `substitute_power_holder` basta lo stesso identico pattern. (`ruolo_principale` non c'entra con questa selezione: è usato altrove, per il raggruppamento dell'organigramma.)

### Cosa si vede in pagina

Una sola tabella live-render "Tipologie di procedimento" (DataTables, stesso stile di Provvedimenti/art.23), con filtri Tipologia / Ufficio responsabile / Anno (se rilevante) e ricerca testuale. Nessun elenco figli nativo, nessun link di dettaglio per riga (decisione di Marco: niente pagina di dettaglio individuale, a meno che non diventi necessario). Il blocco "altri contenuti" della pagina va escluso per questa classe — vedi dettaglio tecnico sotto Stima e rischi.

### Cosa viene esportato

| File | Prodotto? | Contenuto |
|---|---|---|
| `art.35-proc-*.csv` | ✅ sì | tutti i campi piatti + riferimenti a ufficio/servizio risolti dalle relazioni |
| `art.35-uff-*.csv` | ✅ sì | **derivato dalle relazioni**: una riga per ogni `organization` effettivamente referenziata (come `responsible_office` o `competent_office`) da almeno un procedimento — nessuna duplicazione, nessun rischio di disallineamento nomi |
| `art.35-uff-istanze-*.csv` | ✅ sì | derivato da `application_office` + `opening_hours_specification`, una riga per fascia oraria interpretabile, solo per i procedimenti dove `application_office` è valorizzato |
| `art.35-uff-sost-*.csv` | ✅ sì | derivato dalla relazione a `public_person`, una riga per titolare distinto |
| `art.35-*.json` | ✅ sì | `procedimenti[]` completo con `ufficioResponsabile`, `ufficioCompetente` (se presente), `servizioOnline`, `potereSostitutivo` (se presente), `infoInoltroIstanze` (se `application_office` valorizzato) |

### Permessi

Nuova policy `content/create` + `content/edit` (+ `content/remove`, per coerenza con le altre classi dello stesso ruolo) per la classe `administrative_procedure`, aggiunta al ruolo **Editor Trasparenza** (`installer/modules/trasparenza-c1/roles/Editor-Trasparenza.yml`) — lo stesso ruolo che oggi gestisce già `document`, `public_person`, `link`, `nota_trasparenza`, ecc. sotto `Subtree: $content_Amministrazione-Trasparente_path_string`. La policy di `create` va vincolata con `ParentClass: classid(pagina_trasparenza)` (coerente con l'essere figli diretti della pagina "Tipologie di procedimento", che è una `pagina_trasparenza`) — stesso pattern già usato per le altre classi di questo ruolo. Nessun ruolo nuovo da creare, nessuna policy aggiuntiva per l'export pubblico dei file (già coperta in modo generico dalla policy `anac_export/file` sul ruolo `Anonymous`).

### Stima e rischi
- Classe + policy sul ruolo Editor Trasparenza: poche ore, lavoro meccanico.
- Fix a `getExcludeClassesForExtraChildren()` (figli diretti della pagina, vedi sotto): piccolo, un'ora circa.
- Binding `schema_pubblicazione` sulla pagina "Tipologie di procedimento" (patch_content, stesso meccanismo già usato per art.13/23/26-27): poche ore.
- Form di inserimento: **gratis** (nativo eZ, incluso il picker per le relazioni).
- Nuovo provider live-rendering: ~1 giorno, pattern collaudato 3 volte (art.13/23/31).
- Parser orari (`opening_hours_specification` → `FasciaOraria` ANAC) + gestione errore per-schema se un giorno non è interpretabile: mezza giornata circa.
- Serializer + cron + `ExportPublisher` + validazione JSON Schema: lavoro standard, stesso di qualunque nuovo schema ANAC già fatto.
- **Totale indicativo: qualche giorno in più del piano B**, ma zero duplicazione dati, relazione nativa, export "uffici"/"potere sostitutivo"/"istanze" correttamente normalizzati, copertura quasi completa dello schema.

#### Figli diretti della pagina — problema individuato e risolto

Decisione di Marco: i procedimenti si creano come figli diretti della pagina "Tipologie di procedimento" (contenuti di trasparenza specifici di quella pagina, a differenza di `document`, riusato altrove). **L'idea è semplice: li lasciamo vivere lì, ma configuriamo il sistema perché non vengano elencati in automatico — si vedono solo attraverso la tabella live-render.**

Oggi questo "spegnimento" dell'elenco automatico non è previsto per una classe con figli reali: il template della pagina ha un elenco generico "altri contenuti" che mostra tutti i figli diretti tranne una lista di classi escluse, e quella lista di esclusione non sa nulla della tabella live-render — mostrerebbe i procedimenti due volte (elenco automatico + tabella). **Fix:** aggiungere la nuova classe a quella lista di esclusione (`getExcludeClassesForExtraChildren()` in `classes/services/content_trasparenza.php:601-636`) — una riga in un metodo già esistente, non un redesign.

---

## Piano B — Dataset generico (come "Atti di concessione")

### Modello dati

Uno o due dataset (framework `occustomfind/datatypes/opendatadataset/`, stesso meccanismo di "Atti di concessione"):

- **Opzione B1 (un solo dataset "Tipologie di procedimento")**: una riga = un procedimento, con TUTTI i campi di `responsible_office`/`competent_office`/`substitute_power_holder` **appiattiti e duplicati** sulla riga stessa (denominazione ufficio, telefono, PEO/PEC inseriti a mano ogni volta; stesso per il titolare del potere sostitutivo). Nessuna relazione: il framework Dataset non la supporta (verificato nel codice, nessun tipo di campo `relation` esiste).
- **Opzione B2 (due dataset, "Procedimenti" + "Uffici")**: un secondo dataset "Uffici" riusabile, collegato al primo per **nome/denominazione testuale** (stesso meccanismo usato da ANAC nei propri CSV di esempio) — evita di ridigitare i contatti, ma introduce un rischio concreto di disallineamento (nome scritto in modo leggermente diverso = aggancio che si rompe), senza un vero vincolo di integrità.

Consiglio, se si va di Dataset: **B1**, perché B2 introduce fragilità senza eliminarla del tutto (vedi sotto, l'import CSV/Google Sheet dovrebbe comunque fare matching per nome).

I dataset non creano oggetti-figlio nell'albero: i record vivono dentro un'unica tabella in un attributo dell'oggetto "Tipologie di procedimento" stesso. Il problema dei "figli diretti" del Piano A non esiste in questo piano.

### Cosa si vede in pagina

Tabella generica del framework Dataset (stessa UX di "Atti di concessione"): ricerca, filtro per Anno/Ufficio già pronti, nessun codice nuovo.

### Cosa viene esportato

| File | Prodotto? | Contenuto |
|---|---|---|
| `art.35-proc-*.csv` | ✅ sì | tutti i campi, incluse le colonne ufficio/titolare duplicate riga per riga |
| `art.35-uff-*.csv` | ⚠️ parziale/da decidere | per essere conforme all'esempio ANAC (una riga per ufficio distinto) servirebbe comunque una deduplica a posteriori nel serializer, sui valori testuali inseriti dai redattori — **stesso rischio di disallineamento per typo già discusso con Marco**; alternativa più semplice e più robusta: non generarlo affatto e lasciare i dati ufficio solo dentro `art.35-proc.csv` (si perde un po' di aderenza alla forma "esempio" di ANAC, resta comunque dato valido) |
| `art.35-uff-istanze-*.csv` | ❌ no | escluso — nessuna relazione, nessun campo ripetibile nel framework Dataset per rappresentare più fasce orarie |
| `art.35-uff-sost-*.csv` | ⚠️ stesso discorso di `art.35-uff` | stessa scelta da fare: deduplica fragile o non generarlo |
| `art.35-*.json` | ✅ sì | stessa completezza del Piano A (il JSON non richiede normalizzazione, solo oggetti annidati) — unica differenza: i valori di `ufficioResponsabile`/`potereSostitutivo` vengono dai campi piatti del dataset, non da una relazione viva |

### Stima e rischi
- Nessun nuovo content_type, nessun nuovo provider: riusa l'infrastruttura Dataset esistente al 100%.
- Binding `schema_pubblicazione` sulla pagina: stesso lavoro del Piano A.
- Serializer + cron + `ExportPublisher` + validazione JSON Schema: stesso lavoro del Piano A.
- **Totale indicativo: qualche giorno in meno del piano A**, ma: dati ufficio/titolare duplicati a ogni inserimento (nessuna fonte unica, un cambio di PEC richiede modifica manuale su ogni riga che lo cita), e i 2 CSV "lookup" (`art.35-uff`, `art.35-uff-sost`) o sono generati con un rischio di frammentazione per typo, o vengono omessi (minore aderenza al formato di esempio ANAC, ma dato comunque valido). `infoInoltroIstanze` escluso del tutto.

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
| Permessi | nuova policy su ruolo esistente (Editor Trasparenza) | nuova policy su ruolo esistente (Editor Dataset, da verificare) |
| Sforzo totale stimato | qualche giorno in più | più snello |

Nessuna raccomandazione finale in questo documento: la scelta dipende dai giorni effettivamente disponibili e da quanto pesa, per Marco, la qualità/normalizzazione dei 2 CSV "lookup" rispetto al tempo risparmiato.

---

## Scope comune a entrambi i piani (deciso con Marco)

- `tipologia` resta testo libero (nessun vocabolario: ANAC non impone un elenco e ogni ente ha la propria tabella dei procedimenti).
- `accessoInformazioni` e `potereSostitutivo.attivazione` restano testo libero (ANAC non vincola un enum su questi campi; nessuna evidenza sufficiente per un vocabolario condiviso tra i 600 enti).
- **`infoInoltroIstanze` (modulistica istanze di parte + array di fasce orarie) — INCLUSO nel Piano A, escluso nel Piano B.** Il blocco è molto più economico di una prima stima, grazie al riuso delle relazioni già previste:
  - **Trigger implicito (idea di Marco):** niente campo SI/NO a parte — è la relazione `application_office` stessa a fare da segnale. Se valorizzata → istanza di parte, si emette `infoInoltroIstanze`; se vuota → blocco omesso. Il redattore la seleziona esplicitamente anche quando l'ufficio è lo stesso del responsabile (nessun fallback automatico silenzioso, per non avere un segnale ambiguo).
  - **Ufficio (denominazione/indirizzo/contatti):** derivato da `application_office`, attraversando `organization.has_spatial_coverage → place.has_address` (indirizzo) e `place.opening_hours_specification` (orari) — stessa catena di relazioni già usata per `responsible_office`, solo un'altra relazione dello stesso tipo.
  - **Modulistica:** non è un campo per-record. È un **URL fisso di sito**, risolto a export-time dal `remote_id` della pagina Modulistica del tenant (default `cfd0a916ca48eb7d4a78bb6beb7821f9`, verificato in locale su "Comune di Marcon": `/Amministrazione/Documenti-e-dati/Modulistica`) tramite `eZContentObject::fetchByRemoteID()` + `url_alias` del nodo principale — robusto a traduzioni/rinomina del path. Da valutare se serve renderlo configurabile per ente in futuro (stesso pattern ini già visto altrove in questo modulo), non necessario ora.
  - **Orari:** derivati dalla matrice `opening_hours_specification.opening_hours` (colonne fisse Lunedì-Domenica, **valore di cella testo libero**, es. "9:00-12:00") — serve un parser per estrarre `oraInizio`/`oraFine` nel formato richiesto da ANAC. **Decisione di Marco: se anche un solo giorno non è interpretabile, l'export per questo schema va in errore** (stesso meccanismo già esistente di gestione errori per-schema nel cron, es. `recordAnacExportError()`), non uno skip silenzioso — così l'errore è visibile e correggibile dal redattore/amministratore, invece di pubblicare dati silenziosamente incompleti.
  - Resta comunque il quarto CSV (`art.35-uff-istanze`) da scrivere nel serializer, con le sue colonne e righe ripetute per fascia oraria — lavoro meccanico.
  - **Nel Piano B (Dataset) resta escluso:** il framework Dataset non ha relazioni (niente riuso di ufficio/orari) né un tipo di campo ripetibile/array — includerlo lì richiederebbe duplicare tutto a mano per ogni procedimento, senza nessuno dei riusi che lo rendono economico nel Piano A.
- **Binding `schema_pubblicazione`:** la pagina "Tipologie di procedimento" deve dichiarare gli identificatori schema ANAC che pubblica tramite l'attributo `schema_pubblicazione` (ezselection su `pagina_trasparenza`), stesso meccanismo già in produzione per art.13/23/26-27 (vedi `installer/modules/trasparenza-c1/CLAUDE.md`, tabella "Binding schema ANAC ↔ contenuto") — serve un `patch_content` dedicato nell'installer, comune a entrambi i piani.
