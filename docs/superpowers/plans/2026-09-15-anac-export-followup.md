# ANAC Export — Sync, Validazione, Riconferma e UI Downloads Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Portare a uno stato solido e approvato il lavoro sull'export ANAC (#477/#478/#479): sincronizzare un fix già esistente ma mancante sul branch, validare rigorosamente l'output reale contro gli schemi/esempi ANAC scaricabili, ripristinare lo stato pre-UI (la UI attuale non è stata approvata prima di essere scritta), riconfermare esplicitamente il meccanismo di storico versioni, e ricostruire la UI di download passando prima da un design approvato in chat.

**Architecture:** Due repository coinvolti — `openpa_bootstrapitalia` (branch `feature/anac-export-serializers`) per cron/serializer/UI, `installer` (branch `feature/trasparenza-modules-split`) per il content model. Il meccanismo dati (`ExportPublisher`, `SchemaPubblicazioneLookup`, `Art31Serializer`, cron) è già scritto e testato funzionalmente — questo piano NON lo riscrive, ne valida rigorosamente l'output contro ANAC, riconferma il design con Marco, e ci costruisce sopra una UI la cui forma esatta va decisa in chat prima di toccare codice.

**Tech Stack:** eZ Publish Legacy (PHP 7.4, template engine `.tpl`), PostgreSQL, ambiente di verifica `sito-comunale-dev` (docker compose), Python 3 + libreria `jsonschema` (disponibile in locale sull'host, non nel container) per la validazione JSON Schema.

**Spec:** Non un documento singolo formale, ma tre fonti da trattare come vincolanti insieme:
1. Le issue GitLab `opencity-labs/sito-istituzionale/cms#477` (art. 31), `#478` (art. 13), `#479` (naming/versionamento/UI).
2. `~/Documents/analisi-nuova-trasparenza-2026-09-04.md` (analisi tecnica di una sessione precedente, 2026-09-04/09-14) — **letta e incorporata in questo piano, poi cancellata su richiesta di Marco** (2026-09-15); il suo contenuto rilevante è qui e nei `CLAUDE.md` dei due repo.
3. Gli schemi JSON reali scaricabili da `https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/<schema>-v1.0.schema.json` — fonte di verità sui vocabolari/campi obbligatori, non i riassunti della pagina guida (vedi `classes/anac/CLAUDE.md`, sezione "Fonte di verità").

## Contesto (perché questo piano esiste)

Lavorando su #477/#479 in sessione, è stata costruita una UI di download+storico versioni su `pagina_trasparenza.tpl` **senza presentarne prima il design** — copy in inglese, layout, comportamento della tendina "versioni precedenti" decisi unilateralmente. Marco ha fermato il lavoro esplicitamente: fai un punto della situazione, verifica cosa resta da approvare, aggiorna il piano, segui il piano.

Durante l'audit sono emersi altri due punti, non correlati alla UI:
- Un metodo (`BootstrapItaliaInstallerUtils::resetOpendataClassCache`) che il content model di `installer` (branch `feature/trasparenza-modules-split`, commit `c7791d6` di una sessione precedente) si aspetta di trovare su `feature/anac-export-serializers`, ma che lì non esiste — esiste invece già, completo e testato, sul branch `fix/opendata-class-repository-static-cache` (commit `d1bcf55d`), mai portato su `feature/anac-export-serializers`.
- Il file di analisi in `~/Documents` (non letto all'inizio di questa sessione) conferma quasi tutte le decisioni prese, e descrive un'ottimizzazione non ancora implementata: un early-exit SQL nel cron per i siti senza `schema_pubblicazione` attivo (necessario perché il cron gira 2 volte al giorno su ~600 siti SaaS, la maggior parte dei quali non ha ancora questa trasparenza).

Marco ha inoltre chiesto esplicitamente una fase di test che verifichi la correttezza reale dell'output prodotto contro ANAC, scaricando se necessario i file di esempio ufficiali — non solo "il codice gira senza errori". Ha anche chiesto e ottenuto una conferma rigorosa (test pratico, non solo lettura di codice) che il binding schema↔pagina e' realmente letto dall'attributo `schema_pubblicazione` e non hardcoded — verificato svuotando l'attributo su una pagina reale e osservando che il cron smette di trovarla, poi ripristinandolo.

## Global Constraints

- **Niente codice prima dell'approvazione esplicita del design per la UI** (Task 5) — questa è la regola che è stata violata, non ripeterla.
- Copy della UI **in italiano**, non in inglese (l'errore fatto la prima volta).
- Nessuna rimozione automatica dei file dopo 5 anni (decisione presa con Marco su #479 — "nessuna rimozione per ora").
- Naming file invariato: `art.<N>[-suffisso]-YYYYMMDD-YYYYMMDD.<ext>` + alias `-latest.<ext>` (già implementato in `ExportPublisher`, non toccare la logica di naming in questo piano).
- Ogni task che tocca `sito-comunale-dev` va verificato con un test reale (curl e/o browser) prima di considerarlo concluso — questo repo non ha un framework di test automatico per template/cron eZ Publish Legacy.
- Commit locali finché non esplicitamente confermato: **nessun push** senza conferma esplicita di Marco per ciascun repo (regola di profilo, vale sempre).
- Non introdurre nuovi attributi/step installer non strettamente necessari — il content model (`schema_pubblicazione`, `anac_document_type`) è già completo per lo scopo di questo piano.
- Fonte di verità per vocabolari/campi obbligatori ANAC: lo schema JSON scaricato via `curl`, mai un riassunto della pagina guida (vedi `classes/anac/CLAUDE.md`).

---

### Task 1: Sincronizzare `resetOpendataClassCache` sul branch ANAC — ✅ COMPLETATO (2026-09-15)

**Files:**
- Modify (via cherry-pick, non a mano): `classes/BootstrapItaliaInstallerUtils.php`

**Interfaces:**
- Consumes: nessuna — il metodo è già scritto e autocontenuto (usa solo `\Opencontent\Opendata\Api\ClassRepository` e `eZContentClass`, entrambe già disponibili).
- Produces: `BootstrapItaliaInstallerUtils::resetOpendataClassCache()` (metodo statico, nessun parametro) — consumato dallo step `type: php_callable, identifier: 'BootstrapItaliaInstallerUtils::resetOpendataClassCache'` già presente in `installer/modules/base-trasparenza/installer.yml` (repo diverso, non toccato da questo task).

- [x] **Step 1: Verificare che il cherry-pick sia pulito (dry run)** — pulito, nessun conflitto.
- [x] **Step 2: Completare il cherry-pick con un commit pulito** — commit `ed5c99f8` (messaggio/autore/data originali preservati).
- [x] **Step 3: Verifica sintattica** — `No syntax errors detected`.
- [x] **Step 4: Verifica funzionale in `sito-comunale-dev`** — **bug reale trovato**: il commit cherry-pickato chiamava `eZContentClass::classIdentifiersHash()`, che nel kernel reale è `protected` (verificato: `kernel/classes/ezcontentclass.php:1837`), non chiamabile da `BootstrapItaliaInstallerUtils` — falliva con un fatal error mai incontrato prima (il commit originale, a giudicare dal messaggio, non era mai stato eseguito con successo su questo identico kernel). **Fix**: sostituito con `eZContentClass::fetchList(eZContentClass::VERSION_STATUS_DEFINED, true)` (pubblico, stessa semantica — tutti gli identifier di classe), commit separato `98c45a1e`. Ritestato: `OK, nessuna eccezione`.
- [x] **Step 5**: nessuna azione aggiuntiva necessaria (il cherry-pick stesso è il commit).

---

### Task 2: Validare l'output reale contro schemi ed esempi ANAC — ✅ COMPLETATO (2026-09-15)

**Esito finale** (dopo discussione con Marco su rischi/corner case, non solo il primo fix "ovvio"):

1. **`Art4BisSerializer` usava il tab come separatore CSV invece di `;`** — verificato byte-per-byte contro l'esempio reale, corretto (commit `9657044d`).
2. **Terminatore di riga CSV**: tutti i serializzatori (`Art4Bis`/`Art13`/`Art31`) usavano CRLF, tutti gli esempi ANAC scaricati usano solo LF — standardizzato a LF ovunque (commit `9657044d`, `46715272`, `38164bd9`), su richiesta esplicita di Marco ("standardizza come anac").
3. **Array richiesti non vuoti (`minItems: 1`) potevano risultare vuoti**: `datiSuiPagamenti` (art.4-bis) e `organi` (art.13) — trovato validando il JSON reale con la libreria Python `jsonschema` (dataset di test vuoto in `sito-comunale-dev`). Discusso esplicitamente il rischio di uno skip silenzioso (rischiava di lasciare `-latest` bloccato su dati vecchi senza segnalazione, o di mascherare un bug reale per art.13 - vedi conversazione). **Decisione**: nuova `EmptyExportException` (commit `0733471b`), che blocca la pubblicazione e finisce nei log tramite il try/catch già esistente nel cron - stesso principio di `MissingCodiceFiscaleException`. Verificato con test reale: il dataset "Dati sui pagamenti" in dev è davvero vuoto, l'export ora si blocca con un errore chiaro invece di pubblicare un JSON non conforme; `art.13-pa` (organi non vuoti in dev) continua a pubblicare normalmente. Verificato anche che un tentativo bloccato non tocca/corrompe il file `-latest` esistente.

**Confermato conforme** (validazione JSON Schema reale): `art.13-pa`, `art.31` (combinato) - **VALIDI**. Header CSV di tutti gli schemi identici agli esempi ANAC (colonne, ordine, separatore, terminatore di riga).


Questo task non tocca codice a meno che non trovi difformità reali — verifica che i CSV/JSON già prodotti da `Art4BisSerializer`/`Art13Serializer`/`Art31Serializer` siano davvero conformi, non solo "hanno il formato giusto a colpo d'occhio". Richiesto esplicitamente da Marco.

**Files:** eventuali fix a `classes/anac/Serializer/*.php` SOLO se questo task trova una difformità reale — non prevedibili in anticipo, quindi non elencati qui.

- [ ] **Step 1: Scaricare gli schemi JSON reali (se non già presenti da sessioni precedenti)**

```bash
mkdir -p /tmp/anac-validation
for schema in commons art.4-bis art.13 art.31; do
  curl -s "https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/${schema}-v1.0.schema.json" \
    -o "/tmp/anac-validation/${schema}.schema.json"
done
ls -la /tmp/anac-validation/
```

Atteso: 4 file JSON non vuoti.

- [ ] **Step 2: Scaricare almeno un file di esempio CSV per ciascuno schema (per confrontare header/formato)**

```bash
for name in "art.4-bis" "art.13-as" "art.13-op" "art.13-pa" "art.31-oiv" "art.31-or" "art.31-oc"; do
  curl -s "https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/csv/${name}-YYYYMMDD-YYYYMMDD.v1.0.csv" \
    -o "/tmp/anac-validation/example-${name}.csv"
done
```

Alcuni di questi URL potrebbero non esistere con questo pattern esatto (verificato in sessione che alcuni file di esempio hanno nomi leggermente diversi, es. `art.31cc` invece di `art.31-oc` per un'incongruenza nella documentazione ANAC stessa — vedi `classes/anac/CLAUDE.md`). Se un download fallisce (file vuoto o HTML di errore), cercarlo manualmente sulla pagina guida corrispondente prima di saltarlo.

- [ ] **Step 3: Generare l'output reale dai dati di test in `sito-comunale-dev`**

Riusare gli script PHP già scritti in questa sessione (vedi `classes/anac/CLAUDE.md` per i riferimenti esatti agli script di test già usati per `Art31Serializer`) per produrre CSV e JSON reali di ciascuno schema con dati di test, salvandoli su file locali (non solo stampati a schermo) per poterli validare:

```bash
docker exec -w /var/www/html sito-comunale-dev-app-1 php bin/php/<script-di-test>.php > /tmp/anac-validation/output-<schema>.json
```

- [ ] **Step 4: Validare ogni JSON prodotto contro il proprio schema con `jsonschema` (Python)**

```bash
python3 -c "
import json, jsonschema, sys

schema_file = sys.argv[1]
instance_file = sys.argv[2]

with open(schema_file) as f:
    schema = json.load(f)
with open(instance_file) as f:
    instance = json.load(f)

# I \$ref dello schema ANAC puntano a commons-v1.0.schema.json via URL assoluto:
# serve un resolver che li risolva ai file locali scaricati, non alla rete.
resolver = jsonschema.RefResolver(
    base_uri='https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/',
    referrer=schema,
    handlers={'https': lambda uri: json.load(open('/tmp/anac-validation/' + uri.rsplit('/', 1)[-1].replace('-v1.0.schema.json', '.schema.json')))}
)

jsonschema.validate(instance=instance, schema=schema, resolver=resolver)
print('VALIDO:', instance_file)
" "/tmp/anac-validation/art.4-bis.schema.json" "/tmp/anac-validation/output-art.4-bis.json"
```

Ripetere per art.13 (contro `art.13-pa` JSON prodotto) e art.31 (contro il JSON combinato). Se la risoluzione dei `$ref` via handler locale non funziona al primo tentativo (gli URL reali negli schemi vanno letti con `cat` prima per capire il pattern esatto, non assunti), risolvere il problema di resolver prima di concludere che l'output è invalido — un errore di resolver e un vero errore di validazione hanno messaggi diversi (`RefResolutionError` vs `ValidationError`), non confonderli.

Atteso: `VALIDO: ...` per ciascun file, oppure un `ValidationError` con messaggio preciso su quale campo/vincolo fallisce.

- [ ] **Step 5: Confrontare gli header CSV prodotti con gli esempi scaricati**

```bash
head -1 /tmp/anac-validation/output-art.4-bis.csv
head -1 /tmp/anac-validation/example-art.4-bis.csv
```

Confrontare a mano: stesso separatore, stessi nomi di colonna, stesso ordine. Ripetere per ciascuno schema CSV (art.13-as/op, art.31-oiv/or/oc).

- [ ] **Step 6: Se emergono difformità reali, correggerle nel serializzatore interessato**

Non qui elencabili in anticipo (dipendono dall'esito degli step precedenti). Se emerge un fix, applicarlo con lo stesso rigore già usato in questa sessione per i bug trovati su `Art4BisSerializer`/`Art13Serializer` (vocabolario minuscolo, "Acquisto di beni e di servizi", ecc.): verificare la stringa esatta nello schema scaricato, non in un riassunto, e ri-testare da capo (Step 3-5) dopo il fix.

- [ ] **Step 7: Riportare a Marco l'esito (validato / difformità trovate e corrette / difformità trovate non ancora risolte)**

---

### Task 3: Ripristinare lo stato pre-UI (revert del lavoro non approvato) — ✅ COMPLETATO (2026-09-15)

Revert pulito (`62f820c6`), nessun conflitto. Verificato in `sito-comunale-dev`: il blocco non compare più su nessuna pagina.


**Files:**
- Revert (via `git revert`, non modifica manuale): tutti i file toccati dal commit `d38d1073` in `feature/anac-export-serializers` — verificarli con `git show --stat d38d1073` prima di procedere, dovrebbero essere:
  - `classes/services/content_trasparenza.php`
  - `design/bootstrapitalia2/templates/openpa/full/pagina_trasparenza.tpl`
  - `design/bootstrapitalia2/templates/openpa/full/parts/amministrazione_trasparente/anac_export.tpl` (creato da quel commit — il revert lo rimuove)

**Interfaces:**
- Consumes: nessuna.
- Produces: nessuna — questo task rimuove codice, non ne aggiunge. Dopo questo task, `ExportPublisher::getVersions()`/`getLatestUrls()` restano intatti e disponibili per il Task 6 di questo piano.

- [ ] **Step 1: Identificare l'hash esatto del commit da revertare**

```bash
git log --oneline --grep="mostra download" -i
```

Atteso: trova `d38d1073 feat: mostra download + versioni precedenti export ANAC in pagina` (o l'hash corrente se il branch è stato riscritto nel frattempo - verificare che il messaggio corrisponda prima di procedere).

- [ ] **Step 2: Revert**

```bash
git revert --no-edit d38d1073
```

- [ ] **Step 3: Verificare che il revert non abbia toccato altro**

```bash
git show --stat HEAD
```

Atteso: stessi 3 file del commit originale, con diff invertito. Se il revert produce conflitti (possibile se `classes/anac/CLAUDE.md`, committato dopo, referenzia gli stessi blocchi di codice — ma quel file non è tra quelli del commit originale, quindi non dovrebbe succedere), FERMARSI e mostrare a Marco.

- [ ] **Step 4: Verifica in `sito-comunale-dev`**

```bash
docker exec -w /var/www/html sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
curl -sk "https://opencity.localtest.me/Amministrazione-Trasparente/Pagamenti-dell-amministrazione/Dati-sui-pagamenti" | grep -c "anac-export"
```

Atteso: `0` (il blocco non c'è più).

---

### Task 4: Riconferma del meccanismo storico versioni (`ExportPublisher`) — ✅ COMPLETATO (2026-09-15)

Riepilogo presentato in chat (in linguaggio semplice, su richiesta), discussa anche l'alternativa "tabella SQL dedicata invece di eZSiteData" (domanda diretta di Marco) - confermato eZSiteData: nessuna migrazione da distribuire su ~600 siti, evolvibile senza toccare lo schema DB, stesso pattern già usato per il version-tracking dei moduli installer. Una tabella dedicata sarebbe preferibile solo per reportistica trasversale multi-sito, non necessaria oggi. Confermato da Marco, si procede.


Questo task non produce codice nuovo — `ExportPublisher::getVersions()`/`getLatestUrls()`/`backfillUrlsIfMissing()` restano quelli già scritti (non toccati da Task 3, che ha revertato solo la UI). L'obiettivo è ottenere una conferma esplicita di Marco su un meccanismo che è stato costruito senza discuterne il design prima.

**Files:** nessuno (task di revisione).

- [ ] **Step 1: Preparare un riepilogo conciso da presentare in chat**

Il riepilogo deve coprire, in 5-6 righe:
1. Cosa fa: ogni pubblicazione passata di uno schema resta elencata (data + url), non solo l'ultima.
2. Dove vive il dato: dentro il tracking `eZSiteData` già esistente (`anac_export_<schema>`), campo `history` — nessuna nuova tabella (coerente con l'analisi di sessione precedente, che inizialmente proponeva una tabella SQL dedicata poi scartata a favore di questo pattern).
3. Perché gli url sono pre-risolti al momento della scrittura e non ricalcolati a lettura (il caso concreto: la pagina "Corte dei conti" dichiara lo schema ma il file vive sul nodo del dataset, un oggetto diverso).
4. Il backfill automatico per i tracking scritti prima di questo meccanismo.
5. Il limite noto: una voce di storico antecedente all'introduzione del meccanismo non è recuperabile (nessun url salvato per quella).

- [ ] **Step 2: Presentare il riepilogo a Marco e attendere una risposta esplicita**

Non procedere al Task 5/6 finché Marco non conferma esplicitamente ("va bene così", o indica modifiche). Se chiede modifiche, questo task si riapre con una nuova iterazione — non è una formalità da superare in automatico.

---

### Task 5: Design della UI di download — SOLO chat, nessun codice — ✅ COMPLETATO (2026-09-15)

**Design finale approvato** (dopo diverse iterazioni in chat, con verifica su un sito reale — comune.bugliano.pi.it — per allinearsi allo stile già esistente "Open Data" invece di inventarne uno nuovo):
- Titolo: "Schemi pubblicazione ANAC" (non "Dati in formato aperto" come da prima proposta - scartata).
- Nessun testo descrittivo sotto il titolo (rimosso su richiesta).
- Un solo blocco per pagina (non uno per schema) - unificato dopo la prima prova, che ripeteva il blocco N volte quando una pagina espone più schemi.
- Ogni riga: icona `it-file` + link con etichetta leggibile (da `SchemaPubblicazioneLookup::LABELS`, es. "Ambito soggettivo", non l'identificativo tecnico `art.13-as`) + formato tra parentesi.
- Link piccoli, senza aspetto da bottone: classi `btn-link btn-xs p-0 text-decoration-underline` (niente classe `btn` - toglierla è stata una correzione esplicita, altrimenti Bootstrap la stila come pulsante invece che come link).
- "Versioni precedenti": link semplice senza icona (icona `it-collapse` provata e poi rimossa), mostrato solo se almeno uno schema della pagina ha più di una versione pubblicata.
- Storico espanso: una riga per versione, sempre con **nome completo dello schema** (non solo per pagine con più schemi) + formato, es. "01/07/2026 — Ambito soggettivo — CSV". Confermato che gli schemi solo-JSON compaiono nello storico esattamente come i CSV (nessuna esclusione per formato).
- Verificato con simulazioni reali (dati finti temporanei in `eZSiteData`, sempre ripuliti dopo) tutti i casi: pagina con 1 schema, pagina con 3 schemi misti CSV+JSON, storico con più versioni su schemi diversi contemporaneamente.

**Files:** nessuno — questo task produce una decisione condivisa, non codice. Il gate esplicito richiesto da Marco dopo l'incidente della UI non approvata.

- [ ] **Step 1: Proporre un design testuale conciso**

La proposta deve specificare, in italiano:
- Dove appare il blocco nella pagina (es. sotto il titolo, sopra le guide — posizione esatta in `pagina_trasparenza.tpl`).
- Il testo esatto dei pulsanti/label (in italiano, non placeholder).
- Come si presenta lo storico versioni (sempre visibile, collassato di default, quante versioni mostrare).
- Un mockup testuale o markup HTML di esempio, non solo una descrizione a parole.

- [ ] **Step 2: Attendere l'approvazione esplicita di Marco**

Nessuna implementazione finché non arriva un "sì, procedi" (o equivalente) specificamente su QUESTO design. Se Marco chiede modifiche, tornare allo Step 1 con la proposta corretta - non passare al Task 6 con un design "abbastanza buono".

---

### Task 6: Implementare la UI approvata — ✅ COMPLETATO (2026-09-15)

Implementato secondo il design del Task 5: `classes/services/content_trasparenza.php` (logica invariata rispetto al codice revertato, solo l'etichetta leggibile è nuova, letta da `SchemaPubblicazioneLookup::labelForSchema()`), template riscritto da zero (non il file revertato) in base al design realmente approvato.

**Files:**
- Modify: `classes/services/content_trasparenza.php` (aggiungere `has_anac_exports`/`anac_exports` — la logica PHP già scritta in questa sessione è riusabile: leggere `SchemaPubblicazioneLookup::schemasForObject()`, per ogni schema istanziare `ExportPublisher($schema)` senza `$rootNodeId` e leggerne `getLatestUrls()`/`getVersions()`)
- Create: template del blocco (path e nome esatti da definire in base al design approvato nel Task 5 — non necessariamente `anac_export.tpl`, dipende da cosa emerge dal design)
- Modify: `design/bootstrapitalia2/templates/openpa/full/pagina_trasparenza.tpl` (include del blocco)

**Interfaces:**
- Consumes: `SchemaPubblicazioneLookup::schemasForObject(\eZContentObject $object): string[]`, `ExportPublisher::getLatestUrls(): array`, `ExportPublisher::getVersions(): array` (tutti già esistenti, non toccati da questo piano).
- Produces: markup HTML per la pagina — nessuna interfaccia consumata da altri task.

- [ ] **Step 1: Implementare la logica PHP nel service**

Riusare esattamente la logica già scritta e testata (verificarla con `git show d38d1073 -- classes/services/content_trasparenza.php` per recuperare il codice, dato che è stata revertata al Task 3) — cambia solo il markup del template in base al Task 5, non la logica PHP di raccolta dati.

- [ ] **Step 2: Scrivere il template secondo il design approvato**

Usare esattamente il copy/layout deciso nel Task 5 - non improvvisare varianti "migliorative" rispetto a quanto approvato.

- [ ] **Step 3: Includere il blocco in `pagina_trasparenza.tpl`**

Nella posizione esatta decisa nel Task 5.

- [ ] **Step 4: Verifica sintattica PHP**

```bash
php -l classes/services/content_trasparenza.php
```

- [ ] **Step 5: Commit**

```bash
git add classes/services/content_trasparenza.php design/bootstrapitalia2/templates/openpa/full/pagina_trasparenza.tpl design/bootstrapitalia2/templates/openpa/full/parts/amministrazione_trasparente/<nome-file-scelto>.tpl
git commit -m "feat: mostra download + versioni precedenti export ANAC in pagina (design approvato)"
```

---

### Task 7: Test end-to-end della UI in `sito-comunale-dev` — ✅ COMPLETATO (2026-09-15)

Verificato sistematicamente con dati reali e simulati (vedi tabella nella conversazione): più schemi sulla stessa pagina, un solo schema (CSV o JSON), pagina che dichiara lo schema ma il file vive su un nodo diverso (Corte dei conti → dataset), schema mai pubblicato con successo (art.4-bis, dataset vuoto, correttamente nessun blocco mostrato), storico versioni con più elementi su schemi diversi contemporaneamente, storico su uno schema solo-JSON. Unico caso non verificabile in dev per mancanza di dati reali: uno schema che pubblica CSV e JSON insieme nella stessa riga (solo `art.4-bis` ha questo pattern, bloccato dalla guardia `EmptyExportException` con il dataset di test vuoto) - stesso ciclo di rendering già verificato per gli altri casi, rischio basso.

**Files:** nessuno (solo verifica).

- [ ] **Step 1: Pulire la cache e ricaricare le pagine coinvolte**

```bash
docker exec -w /var/www/html sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
```

- [ ] **Step 2: Verificare via curl su tutte le pagine con `schema_pubblicazione` valorizzato**

```bash
for path in \
  "Amministrazione-Trasparente/Pagamenti-dell-amministrazione/Dati-sui-pagamenti" \
  "Amministrazione-Trasparente/Controlli-e-rilievi-sull-amministrazione/Corte-dei-conti" \
  "Amministrazione-Trasparente/Controlli-e-rilievi-sull-amministrazione/Organismi-indipendenti-di-valutazione-nuclei-di-valutazione-o-altri-organismi-con-funzioni-analoghe" \
  "Amministrazione-Trasparente/Controlli-e-rilievi-sull-amministrazione/Organi-di-revisione-amministrativa-e-contabile" \
  "Amministrazione-Trasparente/Controlli-e-rilievi-sull-amministrazione" \
  "Amministrazione-Trasparente/Organizzazione/Articolazione-degli-uffici"; do
  echo "=== $path ==="
  curl -sk "https://opencity.localtest.me/$path" -o /dev/null -w "HTTP %{http_code}\n"
done
```

Atteso: `HTTP 200` per tutte.

- [ ] **Step 3: Verificare visivamente con screenshot browser (mcp claude-in-chrome)**

Su almeno una pagina con dataset (Dati sui pagamenti) e una con storico se disponibile, prendere uno screenshot e confrontarlo con il design approvato nel Task 5 - non solo "c'è del testo", ma "corrisponde a quanto approvato".

- [ ] **Step 4: Mostrare gli screenshot a Marco prima di considerare il task concluso**

---

### Task 8: Early-exit SQL nel cron per i siti senza schema attivo

Ottimizzazione descritta nell'analisi di sessione precedente (`~/Documents/analisi-nuova-trasparenza-2026-09-04.md`, sezione 5j, ora cancellata), non ancora implementata: il cron gira 2 volte al giorno sul gruppo `changesection`, condiviso con ~600 siti SaaS, la maggior parte dei quali non ha ancora questa trasparenza attiva. Oggi `SchemaPubblicazioneLookup::fetchAllBindings()` fa comunque uno scan PHP completo della classe `pagina_trasparenza` anche su quei siti.

**Files:**
- Modify: `cronjobs/anac_export.php` (aggiungere un early-exit prima di chiamare `SchemaPubblicazioneLookup::fetchAllBindings()`)

**Interfaces:**
- Consumes: nessuna nuova - solo query dirette su `ezcontentclass_attribute`/`ezcontentobject_attribute` (tabelle eZ Publish standard).
- Produces: nessuna nuova interfaccia PHP - è un controllo interno al cron.

- [ ] **Step 1: Scrivere la query di verifica**

Nel punto giusto in `cronjobs/anac_export.php` (prima di `$schemaBindings = \SchemaPubblicazioneLookup::fetchAllBindings();`), aggiungere:

```php
function hasAnyAnacExportActive()
{
    $db = eZDB::instance();
    $attributeRow = $db->arrayQuery(
        "SELECT ca.id FROM ezcontentclass_attribute ca
         JOIN ezcontentclass c ON c.id = ca.contentclass_id
         WHERE c.identifier = 'pagina_trasparenza' AND ca.identifier = 'schema_pubblicazione'
         LIMIT 1"
    );
    if (empty($attributeRow)) {
        return false;
    }
    $attributeId = $attributeRow[0]['id'];

    $valueRow = $db->arrayQuery(
        "SELECT 1 FROM ezcontentobject_attribute
         WHERE contentclassattribute_id = " . (int)$attributeId . "
         AND data_text IS NOT NULL AND data_text != '' AND data_text != '0'
         LIMIT 1"
    );

    return !empty($valueRow);
}

if (!hasAnyAnacExportActive()) {
    $cli->notice('anac_export: nessuno schema attivo su questo sito, uscita immediata');
    return;
}
```

- [ ] **Step 2: Verificare sintatticamente**

```bash
php -l cronjobs/anac_export.php
```

- [ ] **Step 3: Testare in `sito-comunale-dev` (dove schemi SONO attivi - verifica che non blocchi il caso normale)**

```bash
docker exec -w /var/www/html sito-comunale-dev-app-1 php runcronjobs.php -s backend changesection 2>&1 | grep -A2 "anac_export.php"
```

Atteso: il cron procede normalmente (non esce subito), esattamente come prima di questo task.

- [ ] **Step 4: Testare il caso "nessuno schema attivo" con uno script isolato (senza smontare `sito-comunale-dev`)**

Non disinstallare `schema_pubblicazione` da `sito-comunale-dev` per testare il caso negativo (romperebbe l'ambiente per gli altri task). Invece, estrarre `hasAnyAnacExportActive()` in un file temporaneo, sostituire l'identifier di classe con uno inventato (es. `pagina_trasparenza_inesistente`) per simulare "attributo non trovato", eseguirlo isolato:

```php
<?php
require_once 'autoload.php';
$script = eZScript::instance(['description' => 'test early-exit']);
$script->startup();
$script->initialize();
$db = eZDB::instance();
$row = $db->arrayQuery(
    "SELECT ca.id FROM ezcontentclass_attribute ca
     JOIN ezcontentclass c ON c.id = ca.contentclass_id
     WHERE c.identifier = 'pagina_trasparenza_inesistente' AND ca.identifier = 'schema_pubblicazione'
     LIMIT 1"
);
echo empty($row) ? "OK: nessun attributo trovato, early-exit corretto\n" : "ERRORE: doveva essere vuoto\n";
$script->shutdown();
```

Cancellare lo script dal container dopo il test.

- [ ] **Step 5: Commit**

```bash
git add cronjobs/anac_export.php
git commit -m "feat: early-exit SQL nel cron per siti senza schema ANAC attivo"
```

---

### Task 9: Aggiornare la documentazione

**Files:**
- Modify: `classes/anac/CLAUDE.md` (la sezione "UI: blocco download + storico" scritta in sessione precedente descrive un design mai approvato - va corretta per riflettere il design REALMENTE approvato ed implementato; aggiungere anche l'esito della validazione del Task 2 e l'early-exit del Task 8)
- Modify (se non già coperto): nota sulla proposta `X-Robots-Tag: noindex` per le versioni storiche non-`latest` (da `~/Documents/analisi-nuova-trasparenza-2026-09-04.md`, sezione 4.6, ora cancellata) nella sezione "Cosa manca" — non implementata, resta una proposta aperta, non confermata da Marco.

- [ ] **Step 1: Rileggere la sezione esistente e correggerla**

Non limitarsi ad aggiornare i dettagli di copy - verificare che ogni affermazione (posizione del blocco, comportamento) corrisponda a quanto implementato nel Task 6, non a quanto scritto in precedenza.

- [ ] **Step 2: Aggiungere l'esito della validazione ANAC (Task 2)**

Una sezione breve: cosa è stato validato, con quali strumenti (schema JSON + libreria Python `jsonschema`), esito.

- [ ] **Step 3: Commit**

```bash
git add classes/anac/CLAUDE.md
git commit -m "docs: aggiorna la documentazione al design approvato e all'esito della validazione"
```

---

### Task 10: Traduzioni i18n (follow-up, se necessario dopo il Task 5)

**Files:** `translations/untranslated/translation.ts`, `translations/ita-IT/translation.ts` (o altre lingue coinvolte).

- [ ] **Step 1: Verificare se il copy approvato nel Task 5 richiede nuove stringhe i18n o riusa stringhe già esistenti nel contesto `bootstrapitalia`**

Se il Task 5 ha prodotto testo in italiano diretto nel template (non tramite `i18n()`), questo task potrebbe non essere necessario - verificare prima di procedere.

- [ ] **Step 2: Se servono nuove stringhe, aggiungerle via API POEditor**

Pattern già documentato in `CLAUDE.md` (root), sezione i18n - push term + traduzione via curl, poi pull con `php vendor/bin/oci18n -r`.

---

### Task 11: Revisione finale e conferma push

**Files:** nessuno.

- [ ] **Step 1: Mostrare il diff completo di entrambi i branch a Marco**

```bash
cd /Volumes/Repos/sviluppo-sito-comunale/openpa_bootstrapitalia && git log --oneline master..feature/anac-export-serializers
cd /Volumes/Repos/sviluppo-sito-comunale/installer && git log --oneline main..feature/trasparenza-modules-split
```

- [ ] **Step 2: Attendere conferma esplicita per il push di ciascun branch separatamente**

Nessun push senza un "sì" esplicito per ENTRAMBI i repo (possono essere confermati in momenti diversi).
