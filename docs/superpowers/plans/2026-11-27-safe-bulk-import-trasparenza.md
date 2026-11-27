# Import massivo CSV sicuro per i redattori — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dare ai redattori un caricamento massivo (CSV in zip) che non può produrre dati sbagliati né scrivere dove l'utente non potrebbe scrivere: o si importa tutto correttamente, o non si importa nulla e si spiega riga per riga cosa correggere.

**Architecture:** Import in due fasi. Fase 1 "Controlla" (sincrona, nessuna scrittura): validazione di ogni riga contro la definizione di classe, con risoluzione esatta di relazioni/tag/selezioni e verifica permessi; se anche un solo errore, niente import e report scaricabile. Fase 2 "Conferma": accodamento dell'import, che rivalida prima di scrivere e gira con i permessi dell'utente che ha caricato. Tutto è attivabile per classe e spento di default: nessun impatto sui ~600 enti finché non si abilita.

**Tech Stack:** eZ Publish legacy (PHP 7.4, niente sintassi PHP 8), estensioni `occsvimport` (logica) e `sqliimport` (coda), `openpa_bootstrapitalia` (widget/template). Nessuna modifica all'installer: la pagina sandbox si crea a mano in locale. Test PHP standalone `php tests/test_*.php` (stesso pattern di `tests/test_art29_serializer.php`) + prove in browser sulla pagina sandbox.

**Spec:** non c'è un documento separato: la sezione "Analisi" qui sotto è la specifica. Contesto: cms#556 (art. 29, dove è nata l'esigenza) e piani art. 35 (`2026-11-26-…art35…piani-alternativi.md` sul branch `trasparenza-additional-scheme-35`).

## Global Constraints

- Branch di lavoro in inglese, da `master`: `feature/safe-bulk-import-trasparenza` (openpa_bootstrapitalia). Branch omonimo in `occsvimport` al momento dell'esecuzione, da `master`. Nessuna modifica a `installer`.
- Mai push senza conferma esplicita di Marco; mai commit senza che Marco lo chieda.
- Nessuna sintassi PHP 8 (la CI usa PHPStan per 7.4).
- Tutto spento di default per ente: nessun cambio di comportamento di `csvimport/import` esistente (lo usa anche l'assistente migrazione).
- Testi per i redattori in italiano, con terminologia PA corretta e senza gergo inglese; stringhe nel contesto i18n `bootstrapitalia/csvimport`, `.ts` aggiornati e poi POEditor (progetto 740564).
- Nessun nome di comune o dominio reale in file versionati (piani, doc, test, commit).
- Open source e standard esistenti: nessuna dipendenza nuova; niente servizi esterni (i dati dei cittadini non escono dall'infrastruttura).
- Nessuna nuova tabella DB: il rollout su ~600 tenant non deve richiedere migrazioni.
- I file caricati (possono contenere dati personali) vanno cancellati sempre: a import finito, a validazione fallita, dopo una scadenza.

## Analisi

### Cosa succede oggi (verificato nel codice e con una prova locale il 2026-11-27)

| # | Fatto | Dove | Conseguenza |
|---|---|---|---|
| F1 | Nessuna validazione: i campi si impostano e l'oggetto si pubblica | `occsvimport/classes/sourcehandlers/csvimporthandler.php` `process()` (99-287) | Creati 2 oggetti con un campo obbligatorio (relazione) vuoto, senza errori |
| F2 | Relazioni per `remote_id`, altrimenti ricerca full-text con primo risultato; non trovato = saltato in silenzio | `getRelations()` (294-339) | Aggancio al nodo sbagliato o relazione vuota, nessun avviso |
| F3 | Float "12,5" diventa 12 | prova locale | Dato numerico errato in silenzio |
| F4 | Tag cercati solo per parola chiave, `@todo find parent`; non trovato = scartato | `getTags()` (513) | Stessa parola sotto rami diversi: tag sbagliato o assente |
| F5 | Data: legge `$parts[2]` senza controllo, non interpretabile = `null` | `getTimestamp()` (423) | Avviso PHP o data vuota in silenzio |
| F6 | Errori registrati solo per file non trovato ed eccezioni, la riga continua; vanno in `progression_notes` | `registerError()` (55), `getProgressionNotes()` (503) | Import parziale, il redattore non lo vede |
| F7 | Nessun controllo `can_create`; nodo di destinazione preso dal form; l'import gira come `RobotUserID` (in locale è l'admin); il publisher usa le operazioni di contenuto, che non controllano le policy | `modules/csvimport/import.php`, `sqliimport/classes/sqliimportfactory.php:136`, `sqlicontentpublisher.php:144` | Chi ha una policy `csvimport` importa dove non potrebbe scrivere |
| F8 | Accesso alla vista: la vista `import` non dichiara funzioni, quindi basta una qualsiasi policy sul modulo; la policy non ha limitazioni per classe o sottoalbero | `modules/csvimport/module.php`, `ezuser.php:2423` | Non si può limitare con i ruoli: il controllo va nel codice |
| F9 | Il widget compare solo in `pagina_trasparenza`, solo dentro il ciclo `table_fields` e nascosto quando la regola è sostituita dal live-render | `design/bootstrapitalia2/templates/openpa/full/pagina_trasparenza.tpl:139-150` | Con live-render (art. 13/31 oggi, art. 35 domani) il widget non c'è |
| F10 | Import in coda, eseguito solo dal cron `sqliimport_run`; in locale non gira nessun cron | `extension/sqliimport/cronjobs` | Il redattore vede "in coda" senza spiegazioni |
| F11 | Zip con file dal nome esatto `<classe>.csv`, separatore `;` da ini, estrazione con `ezcArchive` senza controllo esplicito dei percorsi | `occsvimporthandler.php` (`extractZip`) | Rischio "zip slip", errori di formato facili |
| F12 | Esiste un punto di estensione per classe: `SQLIImportHandler_<classe>` (precedente: `csvimporthandlerlotto`) | `settings/csvimport.ini`, `addImport()` (437) | Si può specializzare senza toccare il comportamento di default |
| F13 | `Editor Trasparenza` crea, modifica e cancella già `partecipazione_societaria` (oltre a `document`, `bando`…) sotto Amministrazione Trasparente | `installer/modules/trasparenza-c1/roles/Editor-Trasparenza.yml` | Per la prova non serve nessun ruolo nuovo |

### Il test case: `partecipazione_societaria` (17 attributi, 3 obbligatori)

Obbligatori: `anno` (`ezinteger`), `organizzazione` (`ezobjectrelationlist`, ammette **solo** `private_organization`), `percentuale_partecipazione` (`ezfloat`). Facoltativi: `tipologia` e `partecipazione` (`ezselection`), `durata_impegno`, `data_di_inizio_partecipazione`, `data_di_fine_partecipazione` (`ezdate`), `funzioni_attribuite` (`ezstring`), `onere_complessivo`, `numero_rappresentanti` (`ezinteger`), `rappresentante` (relazione), `url`, `amministratori_societa_url` (`ezurl`), tre `ezmatrix` (amministratori, bilanci recenti). Scelta con Marco (2026-11-27): si prova solo su questa classe, perché l'importatore la gestisce già e l'Editor Trasparenza la crea già. Copre gli errori reali visti: relazione vuota, "12,5" diventato 12, obbligatorio vuoto pubblicato.

**Fuori scope:** `public_service` (49 attributi, 13 obbligatori, con tag, testi ricchi, file e un tipo non gestito dall'import). Si potrà provare dopo, come prova di stress: il sistema deve **rifiutare di abilitare una classe con un attributo obbligatorio non supportato**, e questa regola si prova comunque con test sulla logica pura (Compito 3).

### Decisioni di progetto

- **D1 Controllo sincrono, import asincrono.** La validazione gira nella richiesta web (il redattore vede subito gli errori); limite di righe configurabile (default 500) per tenere la richiesta breve.
- **D2 Tutto o niente.** Un solo errore = nessuna scrittura. Avvisi (campi facoltativi vuoti) ammessi.
- **D3 Risoluzione esatta, mai ricerca.** Relazioni: `remote_id`, poi nome identico (senza distinzione di maiuscole/spazi multipli) tra gli oggetti pubblicati delle classi ammesse dal campo; 0 trovati o più di 1 = errore con indicazione della riga. Tag: nome unico, oppure percorso `Padre/Figlio`; ambiguo = errore. Selezioni: etichetta o identificatore dell'opzione. Date: solo `gg/mm/aaaa` e `aaaa-mm-gg`, rigorose. Numeri: virgola o punto come decimale, altro = errore.
- **D4 Tipi non supportati bloccano la classe.** Esiste una tabella "tipo di attributo → supportato/non supportato"; se la classe ha un attributo **obbligatorio** non supportato, il widget non si attiva e il motivo è scritto nel log; un attributo **facoltativo** non supportato è ignorato e segnalato come colonna non importabile.
- **D5 Chi carica è chi scrive.** Il nodo di destinazione non arriva dal form: si ricava dalla pagina da cui parte il widget e si firma. Si verificano `can_create` (classe + nodo padre) dell'utente sia al controllo sia prima della scrittura, e l'import gira con l'utente che ha caricato.
- **D6 Rivalidazione all'avvio.** Tra il controllo e il cron i dati possono cambiare (un ufficio cancellato, un tag rinominato): prima di scrivere si rivalida tutto, e se cambia l'esito non si scrive nulla.
- **D7 Widget slegato dalla regola di tabella.** Compare se la classe è abilitata (`ShowCsvImportWidget_<classe>`), la pagina dichiara quella classe (regola di tabella **oppure** schema live-render tramite `LiveRenderingRegistry::REPLACES_CLASS_IDENTIFIER`) e l'utente può crearla lì.
- **D8 Import ripetibile per chiave (C1, confermata da Marco).** Nessun `remoteId` deciso da noi: lo genera eZ alla creazione. Ogni classe abilitata dichiara una **chiave** (colonne che identificano una riga; per `partecipazione_societaria`: `anno` + `organizzazione`) in `csvimport.ini` (`ImportKey_<classe>`); senza chiave la classe non si abilita. Nel controllo, ogni riga è confrontata con i figli esistenti della pagina di destinazione: **nuova** (si crea), **già presente e identica** (saltata, senza errore), **stessa chiave ma valori diversi** (errore, mai sovrascrittura). Righe con la stessa chiave dentro lo stesso file = errore. Conseguenza: dopo un'interruzione si ricarica lo stesso file e si creano solo le righe mancanti; il doppio caricamento è innocuo; i contenuti nel cestino non contano.
- **D9 Annulla import nella v1 (C5, confermata da Marco).** L'handler salva l'elenco degli id degli oggetti creati nel record dell'import (`sqliimport_item`, già esistente: nessuna nuova tabella). "Annulla questo import" sposta nel cestino quei contenuti con i permessi dell'utente (`remove` controllato su ogni oggetto), si ferma sui contenuti modificati dopo l'import segnalandoli senza cancellarli, ed è disponibile per 7 giorni (configurabile). Necessario perché con C2 (solo creazione) è l'unico modo di correggere un import valido ma sbagliato nel merito.
- **D10 Fuori scope v1 (YAGNI):** import da Google Sheet nel widget, modello con menu a tendina, esecuzione sincrona dell'import, aggiornamento di contenuti esistenti.

### Decisioni da confermare (ognuna con la mia proposta)

| # | Domanda | Proposta | Perché |
|---|---|---|---|
| C1 | Import interrotto a metà (guasto durante la scrittura)? | **CONFERMATA (Marco, 2026-11-27): import ripetibile per chiave** (vedi D8), senza `remoteId` nostro | Un solo meccanismo copre interruzione e doppio caricamento; stima circa 1-2 giorni in più |
| C2 | Un file può **aggiornare** contenuti esistenti? | **CONFERMATA (Marco, 2026-11-27): v1 solo creazione.** Colonna `remoteId` non ammessa (errore chiaro). Stessa chiave e valori identici = saltata; stessa chiave con valori diversi = errore "esiste già con dati diversi" | Sovrascrivere dati da un CSV è la cosa più pericolosa. L'aggiornamento si fa dopo, con anteprima delle differenze |
| C3 | Suggerire il nome simile quando un ufficio non si trova | **DECISO (Marco, 2026-11-27): no**, solo "non trovato" con rimando all'elenco dei nomi validi | Meno codice e nessuna ambiguità |
| C4 | Limiti | **500 righe per file e file cancellati dopo 60 minuti: confermati (Marco, 2026-11-27). La soglia "15 minuti in coda" è da rivedere con C7** (in produzione l'import può partire dopo ore); tutti configurabili in ini | Valori ragionevoli per una prima versione, nessuna misura reale ancora |
| C5 | "Annulla questo import" | **CONFERMATA (Marco, 2026-11-27): nella v1**, elenco id nel record dell'import, 7 giorni, circa 1 giorno in più | Con C2 è l'unico modo di correggere un import valido ma sbagliato nel merito |
| C6 | Chi importa vede un'anteprima delle prime righe prima di confermare | **CONFERMATA (Marco, 2026-11-27): sì**, prime 5 righe come le vedrà il cittadino (organizzazione risolta col nome del contenuto trovato) | Fa vedere subito se l'ufficio agganciato è quello giusto |

### Decisione emersa dalle verifiche

| # | Domanda | Proposta |
|---|---|---|
| C7 | Quando parte l'import dopo il clic su "Importa"? | **CONFERMATA (Marco, 2026-11-27): subito**, con lo stesso meccanismo dell'importatore interno (accoda e lancia `sqliimport_run` in background); il cron resta come ripiego. Se dopo 15 minuti è ancora in coda, il widget lo dice e rimanda all'assistenza | Nessun supervisor, nessuna modifica di cron o infrastruttura, già in uso in produzione per l'importatore interno; `sqliimport` ha un blocco che impedisce due esecuzioni insieme |

### Verifiche fatte (2026-11-27)

| Verifica | Esito | Fonte | Conseguenza per il piano |
|---|---|---|---|
| Quando parte l'import in coda in produzione? | **Dal cron: lento.** SaaS (bastion `/srv/CLAUDE.md`, sezione Cron, e `saasopenpa-distribution-prod/cron/crontab`): `sqliimport_run` su tutte le ~525 istanze alle **02:30 e 17:30**; `elenco_istanze_import` (5 istanze) ogni 5 minuti lun-ven 8-20; crontab generata da Ansible. Boat: servizio cron Swarm `oc_frequent` (include `sqliimport_run`) **ogni 6 ore** (`boat-ez-tools/scripts/fill-swarm.sh:86`). **Ma l'importatore interno parte subito per un altro motivo:** dopo aver messo l'import in coda lancia da solo `php runcronjobs.php -q -s<siteaccess> sqliimport_run > /dev/null &` in background (`occsvimport/classes/migration/OCMigrationSpreadsheet.php:226-228`). Non c'è nessun supervisor dedicato: è quella riga. Marco conferma che su Boat funziona | file citati; lettura del bastion in sola lettura | Il widget può usare lo stesso trucco dopo "Conferma": import subito, il cron resta solo come ripiego (C7) |
| `RobotUserID` in produzione | **14 = Administrator**, ovunque: nell'ini dell'estensione `occsvimport`, nell'override SaaS (`saasopenpa-settings/override`) e in quello del prodotto (`prodotto-sito-comunale/conf.d`) | file citati; oggetto 14 verificato in locale (`Administrator User`) | Oggi ogni import in produzione scrive come amministratore, qualunque sia il redattore: lo "scrivere come l'utente che ha caricato" (D5) è indispensabile, non un di più |
| `SQLIContent::create` con `remote_id` già esistente | **Aggiorna, non duplica**: `fetchByRemoteID` trova l'oggetto e lavora su quello. Senza colonna `remoteId` (la nostra scelta, C2) **crea sempre un oggetto nuovo**: quindi il riconoscimento delle righe già presenti deve farlo il nostro controllo (D8), l'import da solo duplicherebbe | `sqliimport/classes/content/sqlicontent.php:152-167`; `csvimporthandler.php:123` (il `remoteId` si usa solo se è la prima colonna) | D8 confermata come necessaria |

### Stima grossolana

Compiti 1-6 sono il nucleo: circa 7-9 giorni (include import ripetibile per chiave, C1, e annulla import, C5). Compiti 7-9: circa 2 giorni. Stima non misurata sul codice, da riconfermare dopo il Compito 2.

## Review Focus

1. **Codifica e formato del file** (BOM UTF-8, Windows-1252 esportato da Excel, separatore `,` invece di `;`, righe vuote, colonna intestata con maiuscole/spazi diversi): atteso errore chiaro, mai caratteri corrotti importati. Test al Compito 1 e 4.
2. **Zip ostile o enorme** (percorsi `../`, troppi file, oltre il limite di righe/dimensione, più di un CSV): atteso rifiuto, nessun file scritto fuori dalla cartella dell'import. Compito 4.
3. **Doppio invio e concorrenza** (doppio clic su "Conferma", due import sulla stessa pagina, stesso file caricato due volte): atteso un solo import, il secondo rifiutato con messaggio. Compito 4.
4. **Dati che cambiano tra controllo e cron** (ufficio nel cestino, tag rimosso, utente che perde il permesso): atteso nessuna scrittura e messaggio. Compito 5.
5. **Valori ostili nei campi di testo** (HTML/script in `funzioni_attribuite`, stringhe lunghissime, formule tipo `=…`, caratteri di controllo): atteso errore o testo che in pagina appare come testo, mai HTML eseguibile. Compiti 1 (controlli) e 8 (verifica del rendering).

---

## UX del redattore

### Principi

1. **Un solo risultato per ogni caricamento, mai ambiguo:** "Errori da correggere", "Pronto da confermare", "In coda", "In corso", "Completato", "Non eseguito (con il motivo)". Mai un import parziale presentato come riuscito.
2. **Ogni messaggio dice cosa è successo, dove e cosa fare**, in italiano semplice, senza gergo (niente "relazione", "attributo", "remote id": si dice "ufficio", "colonna", "codice").
3. **Si corregge dal proprio file:** si scarica il file con una colonna "Esito" aggiunta riga per riga, si corregge e si ricarica. Non si riparte da capo.
4. **Si prepara bene prima di caricare:** modello scaricabile con intestazioni giuste e una riga di esempio, più l'elenco dei valori ammessi (selezioni, uffici).
5. **Niente sorprese:** prima di confermare, riepilogo di cosa verrà creato (e di cosa verrà aggiornato, se il file ha il codice `remoteId`).
6. **Sempre un riferimento per l'assistenza:** ogni caricamento ha un codice (es. `IMP-1234`) mostrato in ogni stato.
7. **Accessibile:** componenti Bootstrap Italia (avvisi `alert`, tabella, barra di avanzamento), messaggi annunciati agli screen reader (`role="alert"`), tutto raggiungibile da tastiera.

### Flusso a video (pagina "Caricamento massivo")

`Scarica il modello` → `Scegli il file` → `Controlla il file` → *(se errori)* tabella errori + `Scarica il file con gli errori segnati` → *(se nessun errore)* riepilogo (nuove / già presenti saltate) + anteprima delle prime 5 righe con i nomi agganciati + `Importa N contenuti` → stato che si aggiorna da solo → `Completato: N contenuti creati` con link all'elenco e pulsante `Annulla questo import` (per 7 giorni).

### Cosa succede per ogni ostacolo

**Il file (blocca subito, un solo messaggio, nessuna riga analizzata)**

| Ostacolo | Cosa vede il redattore | Cosa può fare |
|---|---|---|
| Il file non è uno zip | "Il file deve essere un archivio .zip che contiene un solo file CSV." | Comprimere il CSV e ricaricare |
| Zip senza CSV, con più CSV o con il nome sbagliato | "Nell'archivio deve esserci un solo file chiamato `partecipazione_societaria.csv`. Ho trovato: …" | Rinominare/lasciare un solo file |
| Archivio sospetto (percorsi con `../`, troppi file) | "Il file non è valido." (nessun dettaglio tecnico) | Preparare un nuovo zip |
| File vuoto o solo intestazioni | "Il file non contiene righe da importare." | Compilare il modello |
| Troppo grande o oltre il limite di righe | "Il file ha 812 righe: il massimo è 500. Dividilo in più file." | Dividere e caricare in più volte |
| Codifica non UTF-8 (tipico di Excel) | "Il file non è salvato in UTF-8. In Excel: Salva con nome → CSV UTF-8." | Risalvare |
| Separatore sbagliato (`,` invece di `;`) | "Le colonne devono essere separate da punto e virgola (;)." | Risalvare o usare il modello |
| Colonna obbligatoria assente dall'intestazione | "Manca la colonna **Anno**. Usa il modello per avere le intestazioni giuste." | Aggiungerla |
| Colonna sconosciuta | **Avviso** (giallo, non blocca): "La colonna **Note interne** non è prevista e verrà ignorata." | Eventualmente rimuoverla |

**Le righe (si mostrano tutte le righe con errore, non solo la prima; il file con "Esito" ha tutte)**

| Ostacolo | Messaggio (riga e colonna sempre indicate) | Aiuto |
|---|---|---|
| Campo obbligatorio vuoto | "Riga 4 · **Percentuale**: è obbligatoria." | — |
| Numero non valido | "Riga 7 · **Percentuale**: `12a` non è un numero." | Si accettano `12,5` e `12.5` |
| Intero con decimali | "Riga 3 · **Anno**: deve essere un numero intero (hai scritto `2025,5`)." | — |
| Data non valida | "Riga 5 · **Data inizio**: `31/02/2025` non esiste. Usa gg/mm/aaaa." | — |
| Valore non ammesso in un elenco | "Riga 6 · **Tipologia**: `Controllata` non è tra i valori ammessi: Diretta, Indiretta, …" | Mostra le opzioni |
| Ufficio non trovato | "Riga 8 · **Organizzazione**: non trovo `Societa Alfa` tra le organizzazioni del sito." | Rimanda all'elenco dei nomi validi (link o scheda del modello) |
| Ufficio con nome ambiguo | "Riga 9 · **Organizzazione**: esistono 2 contenuti chiamati `Società Beta`. Indica il codice del contenuto." | Il modello spiega dove trovare il codice |
| Riga duplicata nel file | "Riga 11: stessa riga della 4 (codice `X`)." | — |
| Testo troppo lungo / caratteri non ammessi | "Riga 12 · **Funzioni**: massimo 255 caratteri (ne hai scritti 310)." | — |
| Riga completamente vuota | Ignorata senza messaggio | — |

**Il sistema (dopo aver premuto Importa)**

| Ostacolo | Cosa vede il redattore | Cosa succede ai dati |
|---|---|---|
| Non ha il permesso | Il blocco "Caricamento massivo" non compare. Se tenta comunque: "Non hai il permesso di creare questi contenuti qui." | Nulla |
| C'è già un import in corso su questa pagina | "Un altro caricamento è in corso (IMP-1233). Attendi che finisca." | Nulla |
| Doppio clic su Importa | Un solo import parte; il secondo clic non fa nulla | Un solo import |
| I dati sono cambiati tra controllo e importazione (un ufficio è stato cancellato, un valore non è più valido, il permesso è stato revocato) | "Non è stato importato nulla: nel frattempo l'ufficio `Società Alfa S.p.A.` non esiste più. Ricontrolla il file." | **Nulla viene scritto** (rivalidazione prima di scrivere) |
| L'import resta in coda oltre 15 minuti | "L'importazione è in attesa da 15 minuti. Contatta l'assistenza indicando IMP-1234." | Nulla finché non parte |
| Errore imprevisto durante la scrittura | "L'importazione si è interrotta: creati 7 contenuti su 12. Ricarica lo stesso file: le righe già create verranno riconosciute e saltate. Se si ripete, contatta l'assistenza indicando IMP-1234." | Parziale, ma ripetibile senza duplicati (vedi sotto) |
| Completato | "Completato: creati 12 contenuti (IMP-1234)." con link all'elenco e pulsante "Annulla questo import" | Tutto scritto |
| Annulla questo import | Conferma: "Verranno spostati nel cestino 12 contenuti creati da IMP-1234. Continuare?" Poi: "Annullato: 11 contenuti nel cestino. 1 contenuto è stato modificato dopo l'importazione e non è stato toccato: `Società Alfa`." | I contenuti vanno nel cestino (recuperabili); quelli modificati dopo restano |
| Annulla dopo più di 7 giorni | Il pulsante non c'è più; messaggio "L'annullamento non è più disponibile" | Nulla |

**Interruzione a metà scrittura (risolta con D8).** eZ Publish non scrive più contenuti in un'unica transazione, quindi un guasto a metà può lasciare un import parziale. Grazie all'import ripetibile il redattore non deve pulire nulla: ricarica lo stesso file, le righe già create sono riconosciute e saltate, si creano solo le mancanti.

### Testi

Tutti i messaggi stanno in un catalogo unico (`CsvImportMessages`), con codice, testo e segnaposto: stessa fonte per schermo, file con "Esito" e log. Si rivedono insieme in un solo posto e si traducono con POEditor. Nei test si verifica che ogni codice usato dal validatore abbia un testo (nessun messaggio mancante o in inglese).

---

## File Structure

| File | Repo | Ruolo |
|---|---|---|
| `classes/import/CsvImportReport.php` + `CsvImportMessages.php` (nuovi) | occsvimport | Raccolta errori/avvisi per riga e colonna, file con colonna "Esito", catalogo unico dei messaggi per i redattori |
| `classes/import/CsvValueNormalizer.php` (nuovo) | occsvimport | Logica pura: numeri, date, URL, stringhe, selezioni |
| `classes/import/CsvRowValidator.php` (nuovo) | occsvimport | Validazione riga contro descrittore di classe; usa un `ReferenceResolver` iniettato |
| `classes/import/ReferenceResolver.php` + `EzReferenceResolver.php` (nuovi) | occsvimport | Interfaccia + implementazione eZ per relazioni/tag/selezioni (solo questa tocca il kernel) |
| `classes/import/ClassImportability.php` (nuovo) | occsvimport | Tabella tipi supportati; decide se una classe è importabile |
| `classes/import/ImportGuard.php` (nuovo) | occsvimport | Permessi (`can_create`), firma del nodo, limiti, scadenze |
| `modules/csvimport/validate.php`, `confirm.php`, `error_report.php` (nuovi) + `module.php` | occsvimport | Viste Fase 1, Fase 2, report scaricabile; la vista `import` non cambia |
| `classes/sourcehandlers/csvimportvalidatedhandler.php` (nuovo) | occsvimport | Handler della coda: rivalida, scrive come utente richiedente |
| `tests/test_csv_*.php` (nuovi) | occsvimport | Test logica pura |
| `design/bootstrapitalia2/templates/openpa/full/pagina_trasparenza.tpl` (+ variante `2110`) e `parts/csv_import_widget.tpl` | openpa_bootstrapitalia | Widget slegato da `table_fields`, nuovo flusso Controlla/Conferma |
| `classes/services/content_trasparenza.php` | openpa_bootstrapitalia | Espone `csv_import_class` della pagina (regola o live-render) |
| `translations/ita-IT/translation.ts` | openpa_bootstrapitalia | Testi nuovi |
| — | — | La pagina sandbox, gli utenti e gli uffici di prova si creano a mano in locale (Compito 7): nessun file in `installer` |

---

### Task 1: Normalizzatori e report (logica pura)

**Files:**
- Create: `occsvimport/classes/import/CsvValueNormalizer.php`, `occsvimport/classes/import/CsvImportReport.php`, `occsvimport/classes/import/CsvImportMessages.php`
- Test: `occsvimport/tests/test_csv_value_normalizer.php`, `occsvimport/tests/test_csv_import_report.php`, `occsvimport/tests/test_csv_import_messages.php`

**Interfaces:**
- Produces: `CsvValueNormalizer::number(string $raw, bool $integer): array{ok:bool,value:?string,code:?string}`; `::date(string $raw): array{ok,value:?int,code}` (timestamp locale mezzanotte); `::url(string $raw)`; `::text(string $raw, int $maxLength)` (rimuove caratteri di controllo, errore se oltre); `CsvImportMessages::text(string $code, array $params = []): string` (catalogo unico dei messaggi, vedi sezione "UX del redattore"; ogni codice ha un testo italiano con segnaposto); `CsvImportReport::addError(int $row, string $column, string $code, array $params = [])`, `::addWarning(...)`, `::hasErrors(): bool`, `::rows(): array`, `::toAnnotatedCsv(array $headers, array $originalRows): string` (il file originale con una colonna "Esito" in più, riga per riga).

- [ ] **Step 0: Catalogo messaggi**: scrivere i codici e i testi della sezione "UX del redattore" in `CsvImportMessages` e il test `test_csv_import_messages.php` che verifica: ogni codice restituito dai normalizzatori e dal validatore ha un testo italiano; i segnaposto (`{riga}`, `{colonna}`, `{valore}`) sono sostituiti; nessun testo contiene gergo tecnico (`relazione`, `attributo`, `remote`).
- [ ] **Step 1: Scrivere i test falliti** in `test_csv_value_normalizer.php` con il pattern `check($label, $expected, $actual)`: `number('12,5', false)` → `12.5`; `number('12.5', false)` → `12.5`; `number('1.250,5', false)` → errore; `number('12,5', true)` → errore "numero intero"; `number('', false)` → ok con valore vuoto; `date('31/02/2025')` → errore; `date('2025-02-28')` e `date('28/02/2025')` → stesso timestamp; `date('28/02/25')` → errore (anno a 2 cifre non ammesso); `text("a\x00b", 100)` → errore carattere di controllo; `text(str_repeat('x', 300), 255)` → errore lunghezza.
- [ ] **Step 2: Eseguire** `php tests/test_csv_value_normalizer.php`. Atteso: FAIL (classe mancante).
- [ ] **Step 3: Implementare** `CsvValueNormalizer` e `CsvImportReport` (nessun kernel eZ, solo PHP 7.4). `toCsv()` produce `riga;colonna;messaggio` UTF-8 con BOM, separatore `;`.
- [ ] **Step 4: Eseguire** entrambi i test. Atteso: tutti PASS.
- [ ] **Step 5: Commit** (solo su richiesta di Marco): `feat: normalizzatori e report errori per import CSV`.

### Task 2: Validatore di riga con risolutori di riferimenti

**Files:**
- Create: `occsvimport/classes/import/ReferenceResolver.php`, `CsvRowValidator.php`, `EzReferenceResolver.php`
- Test: `occsvimport/tests/test_csv_row_validator.php` (con `ReferenceResolver` finto)

**Interfaces:**
- Consumes: `CsvValueNormalizer`, `CsvImportReport` (Task 1).
- Produces: `ExistingRowMatcher::classify(array $normalizedRow, array $existingChildren, array $keyColumns): array{status:'new'|'identical'|'conflict',existingId:?int}` (logica pura: confronta chiave e valori normalizzati); `interface ReferenceResolver { relation(string $name, array $classIdentifiers): array{status:'ok'|'none'|'ambiguous',id:?int,count:int}; tag(string $pathOrName, int $rootTagId): array{...}; selection(string $value, array $options): array{...}; }`; `CsvRowValidator::__construct(array $attributes, ReferenceResolver $resolver)` dove `$attributes` è la lista di descrittori `['identifier','type','required','options','classConstraints','rootTagId']`; `::validate(int $rowNumber, array $row, CsvImportReport $report): array` (restituisce la riga normalizzata, vuota se ci sono errori).

- [ ] **Step 1: Scrivere i test falliti** con un resolver finto (più, per `ExistingRowMatcher`: stessa chiave e stessi valori → `identical`; stessa chiave, un valore diverso → `conflict`; chiave assente tra i figli → `new`; chiave con maiuscole/spazi diversi nel nome dell'ufficio → riconosciuta; figlio nel cestino → non conta): campo obbligatorio vuoto → errore alla riga e colonna giuste; colonna sconosciuta → avviso, non errore; relazione `none` → errore "non trovato"; relazione `ambiguous` con 2 candidati → errore che dice quanti; tag ambiguo → errore; selezione non valida → errore con le opzioni ammesse; due righe con la stessa chiave nello stesso file → errore sulla seconda; colonna `remoteId` presente → errore "colonna non ammessa"; riga completamente vuota → ignorata; intestazione con maiuscole/spazi diversi (` Anno `) → riconosciuta; colonna obbligatoria assente dall'intestazione → errore di file, non di riga.
- [ ] **Step 2: Eseguire** `php tests/test_csv_row_validator.php`. Atteso: FAIL.
- [ ] **Step 3: Implementare** `CsvRowValidator` (nessun kernel) e `EzReferenceResolver`: relazioni con una query sui nomi (`ezcontentobject_name`) filtrata per classi ammesse e stato pubblicato, confronto in minuscolo con spazi normalizzati, con memoria per richiesta; selezione dalle opzioni dell'attributo; tag (`eztags_keyword`, percorso `Padre/Figlio`) previsti dall'interfaccia ma non usati da questa classe, da coprire quando serve (YAGNI). Niente `eZSearch`.
- [ ] **Step 4: Eseguire** il test. Atteso: PASS.
- [ ] **Step 5: Prova nel kernel** su `partecipazione_societaria` locale con 3-4 `private_organization` create per l'occasione (in locale non ne esiste nessuna): nome esistente, inesistente, doppio (due uffici con lo stesso nome). Atteso: ok / errore / errore "ambiguo". Commit su richiesta.

### Task 3: Importabilità della classe (tipi supportati e non)

**Files:**
- Create: `occsvimport/classes/import/ClassImportability.php`
- Test: `occsvimport/tests/test_csv_class_importability.php`

**Interfaces:**
- Consumes: descrittori di classe del Task 2.
- Produces: `ClassImportability::evaluate(array $attributes): array{importable:bool,blocking:string[],ignored:string[]}`; tabella `const SUPPORTED = [...]` per tipo.

- [ ] **Step 1: Test falliti** (descrittori di esempio, nessun kernel): classe con tutti i tipi supportati → importabile; classe con un attributo obbligatorio di tipo non supportato (es. `openpacomuniitaliani`) → non importabile, `blocking` lo contiene; attributo facoltativo non supportato (`openpareverserelationlist`, `ezmatrix`) → importabile, finisce in `ignored`; descrittore reale di `partecipazione_societaria` (anno, organizzazione, percentuale obbligatori) → importabile con le 3 matrici in `ignored`.
- [ ] **Step 2: Eseguire.** Atteso: FAIL.
- [ ] **Step 3: Implementare** la tabella (supportati: stringa, testo, intero, float, data, data/ora, URL, selezione, relazione; non supportati: tutto il resto, da estendere solo con un test dedicato). Il widget non si attiva per una classe non importabile e il motivo va nel log.
- [ ] **Step 4: Eseguire** i test. Atteso: PASS.
- [ ] **Step 5: Verificare** nel kernel locale che i descrittori letti da `eZContentClass` per `partecipazione_societaria` diano lo stesso esito del test. Commit su richiesta.

### Task 4: Viste Controlla / Conferma, report e sicurezza del file

**Files:**
- Create: `occsvimport/modules/csvimport/validate.php`, `confirm.php`, `error_report.php`, `occsvimport/classes/import/ImportGuard.php`
- Modify: `occsvimport/modules/csvimport/module.php`, `occsvimport/settings/csvimport.ini`
- Test: `occsvimport/tests/test_csv_import_guard.php`

**Interfaces:**
- Produces: `ImportGuard::checkArchive(array $entryPaths, int $uncompressedBytes): array{ok,error}` (rifiuta `../`, percorsi assoluti, più di un CSV, oltre `MaxFileSizeBytes`); `::checkRowCount(int $n)` (default `MaxRows=500`); `::signNode(int $nodeId, string $class, int $userId): string` e `::verifyNode(...)`; `::acquireLock(int $nodeId, string $class): bool` (un solo import per pagina e classe).
- Viste: `csvimport/validate` (POST: file + token nodo firmato → report), `csvimport/confirm` (POST: id validazione → accoda **e lancia subito** `php runcronjobs.php -q -s<siteaccess> sqliimport_run > /dev/null 2>&1 &` in background, come fa `OCMigrationSpreadsheet.php:226-228`; il nome del siteaccess viene da `eZSiteAccess::current()` ed è passato a `escapeshellarg`; il cron resta come ripiego), `csvimport/error_report/<id>` (CSV scaricabile).

- [ ] **Step 1: Test falliti** su `ImportGuard`: `../x.csv` rifiutato; zip con due CSV rifiutato; 501 righe rifiutate; token con nodo alterato rifiutato; seconda `acquireLock` sulla stessa pagina e classe → false.
- [ ] **Step 2: Eseguire.** Atteso: FAIL.
- [ ] **Step 3: Implementare** `ImportGuard` e le tre viste. Intestazioni/BOM/separatore: riconoscere BOM UTF-8, rifiutare file non UTF-8 con messaggio che spiega come salvarlo, accettare `;` e rifiutare `,` con messaggio. File temporanei cancellati sempre (validazione fallita, conferma, scadenza `RetentionMinutes=60`). Il form usa il token anti-CSRF già attivo (`ezuserformtoken`).
- [ ] **Step 4: Eseguire** i test. Atteso: PASS. Poi **provare in browser** (sandbox, Compito 7): zip ostile, doppio clic su Conferma (un solo import e un solo processo in background), file con BOM, file Windows-1252; verificare che dopo "Conferma" l'import parta da solo in locale senza lanciare il cron a mano.
- [ ] **Step 5: Commit** su richiesta.

### Task 5: Esecuzione con i permessi dell'utente e rivalidazione

**Files:**
- Create: `occsvimport/classes/sourcehandlers/csvimportvalidatedhandler.php`
- Modify: `occsvimport/settings/csvimport.ini` (`SQLIImportHandler_<classe>` per le classi abilitate), `occsvimport/classes/occsvimporthandler.php` (stato)
- Test: scenari in browser (non è logica pura)

**Interfaces:**
- Consumes: `CsvRowValidator`, `ImportGuard`.
- Produces: handler che in `initialize()` rivalida l'intero file e, se emergono errori nuovi, esce senza scrivere e scrive l'esito nelle note di avanzamento; in `process()` verifica `can_create` dell'utente richiedente e imposta lui come utente corrente per la scrittura (proprietario degli oggetti = chi ha caricato).

- [ ] **Step 1: Verificare** nel codice di `sqliimportfactory.php` come l'utente robot viene impostato e se un handler può cambiarlo senza effetti collaterali sugli import successivi (ripristino a fine riga). Annotare l'esito.
- [ ] **Step 2: Implementare** l'handler con la rivalidazione (D6) e il controllo permessi per riga (D5); stato finale esplicito: `completato`, `rifiutato (dati cambiati)`, `rifiutato (permessi)`.
- [ ] **Step 3: Prove in browser** con due utenti: uno con `can_create` e uno senza (Compito 7). Atteso: il secondo è fermato già al Controlla; se il permesso viene revocato tra Controlla e cron, l'import è rifiutato e non scrive nulla. Prova di dati cambiati: cancellare un ufficio referenziato dopo il Controlla. Atteso: nessuna scrittura.
- [ ] **Step 4: Verificare** il proprietario degli oggetti creati (`owner_id` = utente richiedente) e che un import normale con `csvimport/import` (flusso vecchio) non sia cambiato.
- [ ] **Step 5: Commit** su richiesta.

### Task 5b: Annulla questo import

**Files:**
- Modify: `occsvimport/classes/sourcehandlers/csvimportvalidatedhandler.php` (salva gli id creati), `occsvimport/modules/csvimport/module.php`
- Create: `occsvimport/modules/csvimport/undo.php`, `occsvimport/classes/import/ImportUndo.php`
- Test: `occsvimport/tests/test_csv_import_undo.php` (logica pura: scelta di cosa annullare)

**Interfaces:**
- Produces: `ImportUndo::plan(array $createdObjects, int $importCompletedAt, int $now, int $retentionDays): array{removable:int[],modified:int[],expired:bool}` dove `$createdObjects` è `[['id'=>int,'modified'=>int], ...]`; la vista `csvimport/undo/<importId>` (POST con conferma) sposta nel cestino i `removable` controllando `remove` dell'utente su ciascuno.

- [ ] **Step 1: Test falliti**: oggetto non modificato dopo l'import → `removable`; oggetto con `modified` successivo al completamento → `modified`; import più vecchio di 7 giorni → `expired=true` e nessun `removable`; elenco vuoto → niente da annullare.
- [ ] **Step 2: Eseguire** `php tests/test_csv_import_undo.php`. Atteso: FAIL.
- [ ] **Step 3: Implementare** `ImportUndo::plan` e il salvataggio degli id creati (aggiornato a ogni riga scritta, così anche un import interrotto ha l'elenco) nel record dell'import; la vista `undo` con conferma e controllo `remove` per oggetto.
- [ ] **Step 4: Prove in browser** (sandbox): annullare un import completo; annullare dopo aver modificato a mano un contenuto (resta, segnalato); utente senza `remove` (non vede il pulsante); doppio clic su Annulla; annullare un import interrotto a metà. Atteso: solo i contenuti dell'elenco vanno nel cestino, mai altri della pagina.
- [ ] **Step 5: Commit** su richiesta.

### Task 6: Widget slegato dalla regola di tabella e nuovo flusso a video

**Files:**
- Modify: `design/bootstrapitalia2/templates/openpa/full/pagina_trasparenza.tpl` (e `bootstrapitalia2110`), `design/bootstrapitalia2/templates/parts/csv_import_widget.tpl` (spostato in openpa_bootstrapitalia o esteso dalla copia di `occsvimport`), `classes/services/content_trasparenza.php`, `translations/ita-IT/translation.ts`
- Test: `tests/test_csv_import_widget_class.php` (logica pura della scelta della classe)

**Interfaces:**
- Produces: `ContentTrasparenzaService` espone `csv_import_class`: identificatore della classe importabile dichiarata dalla pagina, cercandola prima tra le regole di tabella (parent = nodo corrente) e poi tra gli schemi live-render (`LiveRenderingRegistry::REPLACES_CLASS_IDENTIFIER`), oppure `false`. Il template mostra la sezione "Caricamento massivo" solo se `csv_import_class` esiste, `ShowCsvImportWidget_<classe>` è `enabled`, la classe è importabile (`ClassImportability`) e `can_create` dell'utente è vero.

- [ ] **Step 1: Test falliti**: pagina con regola per `partecipazione_societaria` → `partecipazione_societaria`; pagina live-render `art.31-oiv` → `document`; pagina senza regola né schema → `false`; regola con `parent:` diverso dal nodo corrente → `false`.
- [ ] **Step 2: Eseguire** `php tests/test_csv_import_widget_class.php`. Atteso: FAIL.
- [ ] **Step 3: Implementare** `csv_import_class` e spostare il blocco del widget **fuori** dal ciclo `table_fields`. Il widget nuovo ha (anteprima delle prime 5 righe inclusa, con le relazioni risolte per nome): scelta file, pulsante "Controlla file", e dopo il controllo o l'elenco errori con "Scarica elenco errori" oppure il riepilogo "Verranno creati N contenuti di tipo X in Y" con "Conferma importazione"; dopo la conferma mostra stato (in coda / in corso / completato / non eseguito, con il motivo) e storico. Testi in italiano semplice, spiegati a un redattore non tecnico.
- [ ] **Step 4: Eseguire** il test, poi verificare in browser che sulla pagina sandbox (regola di tabella) e su una pagina con live-render attivo (art. 13 o 31, con `ShowCsvImportWidget_<classe>` abilitata solo per la prova) il widget compaia e **non** compaia per classi non abilitate.
- [ ] **Step 5: Traduzioni**: aggiungere il blocco a mano in `translations/ita-IT/translation.ts` (non fare `oci18n -r`, vedi CLAUDE.md), poi POEditor. Commit su richiesta.

### Task 7: Pagina sandbox a mano in locale (nessun modulo installer)

Scelta di Marco (2026-11-27): la pagina di prova si crea a mano in locale, senza modulo nell'installer, così non c'è nulla da mantenere né rischio che finisca in produzione. Nessun file versionato; si documenta la procedura in coda al documento dei risultati (Compito 8).

- [ ] **Step 1: Creare** dal backend, sotto Amministrazione Trasparente, una pagina di classe `pagina_trasparenza` chiamata "Sandbox import", con nel campo delle regole di rappresentazione: `partecipazione_societaria|anno,organizzazione,percentuale_partecipazione|1` (senza `parent:`, quindi sul nodo stesso).
- [ ] **Step 2: Creare** 3-4 `private_organization` di prova (in locale non ce n'è nessuna), tra cui due con lo stesso nome per provare l'ambiguità.
- [ ] **Step 3: Creare** due utenti di prova: uno con il ruolo Editor Trasparenza più le policy `csvimport` e `sqliimport`, uno senza `can_create` sul sottoalbero. Le policy di prova si aggiungono **solo al ruolo locale**, senza toccare i file dei ruoli nell'installer.
- [ ] **Step 4: Impostare** in locale `ShowCsvImportWidget_partecipazione_societaria=enabled` e `ImportKey_partecipazione_societaria=anno,organizzazione` (override del container, non versionato) e verificare che il widget compaia con l'utente autorizzato e non compaia per l'altro.
- [ ] **Step 5: Annotare** la procedura nel documento dei risultati (Compito 8), per poterla ripetere.

---

### Task 8: Matrice di prove su `partecipazione_societaria` e relazione finale

**Files:**
- Create: `docs/superpowers/plans/2026-11-27-safe-bulk-import-risultati-prove.md` (esito prove)
- Create: file di prova CSV/zip nello scratchpad (non versionati)

- [ ] **Step 1: Preparare** i file: valido (3 partecipazioni); un file per ogni errore (campo obbligatorio vuoto, ufficio inesistente, ufficio ambiguo, selezione errata, data 31/02, percentuale con virgola e con punto, anno decimale, `remoteId` duplicato, colonna sconosciuta, colonna obbligatoria mancante); BOM; Windows-1252; separatore `,`; 501 righe; zip con `../`; due CSV; HTML/script in `funzioni_attribuite` (poi verificare che in pagina compaia come testo); stringa di 5000 caratteri.
- [ ] **Step 2: Eseguire** ogni file dalla pagina sandbox con l'utente con ruolo (Chrome) e annotare per ognuno: messaggio mostrato, cosa è stato scritto (conteggio oggetti prima/dopo nel DB). Atteso: per ogni file con errore, **zero oggetti creati** e messaggio comprensibile.
- [ ] **Step 3: Provare** permessi (utente senza ruolo; nodo di destinazione alterato nel form; revoca del permesso tra Controlla e cron), concorrenza (doppio clic, due caricamenti), rivalidazione (cancellare un ufficio dopo il Controlla), idempotenza (ricaricare il file valido con `remoteId`: aggiorna e non duplica).
- [ ] **Step 4: Verificare** che l'import parta da solo dopo "Conferma" (avvio in background) e che il cron manuale `php runcronjobs.php -s backend sqliimport_run` funzioni come ripiego quando l'avvio immediato non parte (simulare: blocco `sqliimport` attivo). Stato visibile nel widget.
- [ ] **Step 5: Scrivere** l'esito con tabella "scenario / atteso / ottenuto" e l'elenco di ciò che resta aperto; **mostrarlo a Marco prima di dire che è pronto per i redattori**. Aggiungere una prova di leggibilità: far leggere i messaggi a una persona non tecnica (redattore reale o collega non sviluppatore) per ognuno degli ostacoli della sezione "UX del redattore" e correggere i testi che non capisce al primo colpo.

### Task 9: Documentazione e attivazione per classe

**Files:**
- Modify: `openpa_bootstrapitalia/CLAUDE.md` (sezione breve sul caricamento massivo), `occsvimport/README` o `CLAUDE.md` se presente, `openpa_bootstrapitalia/settings/openpa.ini.append.php` (commento sulle chiavi, nessuna classe abilitata di default)

- [ ] **Step 1:** Documentare il flusso a due fasi, le chiavi ini (`ShowCsvImportWidget_<classe>`, `MaxRows`, `MaxFileSizeBytes`, `RetentionMinutes`), come si abilita una classe e perché una classe può risultare non importabile.
- [ ] **Step 2:** Scrivere una scheda breve per i redattori in italiano semplice (come preparare il file, cosa significa ogni messaggio d'errore), da passare a Marco per il manuale.
- [ ] **Step 3: Commit** su richiesta; **push e PR solo dopo conferma esplicita di Marco**.

---

## Self-review

- **Copertura:** F1-F13 sono coperti — F1/F3/F5 dai Compiti 1-2, F2/F4 dal Compito 2 (D3), F6 dal D2 (tutto o niente), F7/F8 dai Compiti 4-5 (D5), F9 dal Compito 6 (D7), F10 dai Compiti 6 e 8, F11 dal Compito 4, F12 dal Compito 5, F13 dal Compito 7.
- **Decisioni:** C1-C7 tutte decise da Marco (2026-11-27) in attesa di conferma di Marco (sezione "Decisioni da confermare"). `public_service` e i tipi tag/testo ricco/file sono fuori scope per scelta di Marco.
- **Rischi noti non risolti da questo piano:** il cron `sqliimport_run` in produzione è da verificare (se non c'è, nessun import parte: va controllato prima del rilascio); il valore di `RobotUserID` in produzione; il comportamento di `SQLIContent` con `remoteId` esistente (aggiornamento) è da provare al Compito 8, non l'ho verificato.
- **Coerenza dei tipi:** `ReferenceResolver` (Compito 2) è consumato dal validatore e dall'handler (Compito 5); `ImportGuard` (Compito 4) è consumato dall'handler (Compito 5) e dal widget (firma del nodo, Compito 6).
