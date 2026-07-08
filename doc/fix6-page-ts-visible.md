# Fix 6 — Root cause: `Page.php` deve rendere items visibili immediatamente

**Repo:** `ocopendata`  
**File:** `lib/ocopendata/src/Opencontent/Opendata/Api/AttributeConverter/Page.php`  
**Status:** in analisi — non implementato

---

## 1. Root cause verificata

### Il problema

`AttributeConverter/Page.php::createXML()` inserisce items nel pool con `ts_visible=0`
(default della colonna PostgreSQL). La query `eZFlowPool::validNodes()` filtra:

```sql
WHERE block_id=? AND ts_visible>0 AND ts_hidden=0
```

Quindi gli items appena inseriti sono **invisibili** finché `eZFlowOperations::update()` non
li processa.

### Il meccanismo di visibilità atteso

Il sistema presuppone che `update()` venga chiamato durante il publish via `ezpagetype.php::onPublish()`:

```php
// ezflow/datatypes/ezpage/ezpagetype.php:1138-1145
if (eZFlowOperations::updateOnPublish()) {
    $nodeArray = [homepage_node_id];
    eZFlowOperations::update($nodeArray);  // → setta ts_visible = time()
}
```

`UpdateOnPublish=enabled` è configurato in `openpa_bootstrapitalia/settings/ezflow.ini.append.php`.

### Perché non funziona su Verona

Su Verona esiste un workflow globale **"Pre pubblicazione"** (`group_ezserial`, abilitato) che
causa il **DEFERRAL** del publish (status=10 nella tabella `ezworkflow_process`). Al momento
dell'analisi (luglio 2026): **466 processi deferred** accumulati dal ottobre 2024.

**Sequenza del bug:**

```
lock_edit salva
  → createXML() inserisce items con ts_visible=0
  → content/publish viene eseguito
  → workflow "Pre pubblicazione" intercetta
  → publish è DEFERRED (aspetta cron workflow)
  → ezpagetype.php::onPublish() NON gira
  → eZFlowOperations::update() NON gira
  → items restano ts_visible=0

Redattore riapre il form PRIMA che il cron processi il workflow
  → validNodes() non trova niente (ts_visible=0)
  → form mostra pool vuota
  → add_section_banner = false (toggle OFF)
  → salva → blocchi distrutti
```

### Perché la riga era commentata

In `ContentRepository.php:433`:
```php
//        eZFlowOperations::update([$object->mainNodeID()]);
```

Questa riga è stata aggiunta **già commentata** nel commit `bf50afe` del 1 ottobre 2025
("Add opendata v2 block read and put api", autore: luca.realdi). Era un TODO lasciato
intenzionalmente commentato — nessuna spiegazione nel commit message.

In `LockEditConnector.php:44`:
```php
//            eZINI::instance('ezflow.ini')->setVariable('eZFlowOperations', 'UpdateOnPublish', 'disabled');
```

Aggiunta commentata nel commit `995bf8e0` del 3 aprile 2023. Anche questa mai attiva.

### Perché succede solo su alcuni tenant

Richiede la combinazione di:
1. Workflow globale che causa DEFERRED della publish
2. Cron che non processa i workflow deferred (o li processa lentamente)

Tenant senza workflow, o con cron funzionante, non sono affetti.

---

## 2. Il fix proposto

In `Page.php::createXML()`, dopo `eZFlowPool::insertItems($flowPoolItems)`, aggiungere
un UPDATE che setta `ts_visible = time()` per gli items appena inseriti:

```php
\eZFlowPool::insertItems($flowPoolItems);

// Rendi visibili immediatamente gli items appena inseriti.
// eZFlowPool::insertItems() non imposta ts_visible (rimane 0, default PostgreSQL),
// rendendo gli items invisibili a validNodes() finché non gira eZFlowOperations::update().
// Su tenant con workflow deferred, update() potrebbe non girare per ore/giorni.
if (!empty($flowPoolItems)) {
    $db = \eZDB::instance();
    $now = time();
    foreach ($flowPoolItems as $item) {
        $db->query(
            "UPDATE ezm_pool SET ts_visible=$now" .
            " WHERE block_id='" . $db->escapeString($item['blockID']) . "'" .
            " AND object_id=" . (int)$item['objectID'] .
            " AND ts_visible=0 AND ts_hidden=0"
        );
    }
}
```

**Perché UPDATE separato e non modificare `insertItems()`**: `eZFlowPool::insertItems()`
non accetta `ts_visible` come parametro. Modificarne l'interfaccia avrebbe impatto su tutti
i chiamanti nel sistema eZ (non solo ocopendata). L'UPDATE separato è più chirurgico.

---

## 3. Analisi corner case

### CC1 — NumberOfValidItems temporaneamente violato

**Configurazione** (da `openpa/settings/block.ini.append.php`):

| Tipo blocco | NumberOfValidItems |
|-------------|-------------------|
| Singolo | 1 |
| ListaManuale | 15 |
| Argomenti | 15 |
| Ricerca | 15 |
| ListaAutomatica | 1 |
| Eventi | 3 |

**Scenario**: utente aggiunge 20 items a un blocco con limite=15.

Con il fix, tutti e 20 diventano visibili subito. Al prossimo cron, `update()` trova
20 items visibili → archivierà i 5 più vecchi (priorità più bassa).

**Valutazione**: rischio basso in pratica. `createXML` CANCELLA tutti gli items esistenti
prima di reinserire — il pool contiene solo ciò che l'utente ha selezionato nel form.
Superare il limite richiede che l'utente inserisca consapevolmente più di 15 items.
Anche se accade, il comportamento è temporaneo e si auto-corregge al prossimo cron.
**Non è una regressione** rispetto al comportamento attuale (senza fix, il cron gestisce
comunque il limite, ma dopo un ritardo).

### CC2 — Priority assignment

`insertItems()` usa `priority = validItemsCount - index`:
- Item 0 (primo nel form) → priority = 5 (più alta)
- Item 4 (ultimo) → priority = 1 (più bassa)

`validNodes()` ordina per `priority DESC` → primo item nel form = primo nella pagina.
**L'ordine è corretto e preserva la scelta dell'utente.**

Senza fix, `update()` riassegnerebbe le priority in sequenza crescente (1,2,3,4,5).
Il risultato visivo in pagina è identico: stessa sequenza, priority crescenti invece di
decrescenti ma stesso ordine di visualizzazione.

**Importantissimo**: `createXML` cancella SEMPRE tutti gli items esistenti prima di
reinserire. Non ci sono mai items "vecchi" con cui creare conflitti di priority.

**Valutazione**: non è un problema. L'ordine visivo è corretto in entrambi i casi.

### CC3 — Scope del fix (tutti i path ocopendata)

Il fix si applica ogni volta che `createXML()` inserisce items nel pool, ovvero:
- Salvataggio lock_edit ← caso principale
- API ocopendata v2 per aggiornare blocchi (`ContentRepository::updateBlock()`)
- Qualsiasi publish via `PublicationProcess` che include un page attribute

In tutti questi contesti, rendere items visibili immediatamente è il comportamento corretto.
**Non è una regressione.**

### CC4 — Blocchi con rotation_type != 0

I blocchi della homepage su tutti i tenant analizzati (roveretopnrr, verona, bolzano,
firenze, trento) hanno `rotation_type=0` e `rotation_interval=0` — verificato dal DB.

La logica di rotation in `update()` (move items back to queue) si attiva solo se
`rotation_type != 0`. Con rotation_type=0, nessun item viene rimesso in queue.

**Valutazione**: non applicabile alla homepage. Nessun rischio.

### CC5 — Idempotenza (double call)

`createXML()` chiamata due volte:
1. Prima chiamata: cancella pool, inserisce con ts_visible=0, UPDATE setta ts_visible=now
2. Seconda chiamata: cancella pool (include items appena resi visibili), reinserisce con ts_visible=0, UPDATE setta ts_visible=now

Il nostro UPDATE filtra `AND ts_visible=0` → se ts_visible è già > 0, non lo tocca.
Se i pool items vengono cancellati e reinseriti (seconda chiamata), sono di nuovo ts_visible=0
e l'UPDATE funziona correttamente.

**Valutazione**: idempotente. Nessun problema.

### CC6 — Race condition con cron parallelo

- Thread A (lock_edit save): cancella pool, inserisce ts_visible=0, UPDATE → ts_visible=now
- Thread B (cron `update()`): cerca items con `ts_visible=0 AND ts_hidden=0`

Se Thread A ha già settato ts_visible > 0 quando Thread B esegue la query, Thread B
non trova quegli items nella queue → non li tocca → nessun danno.

Se Thread B legge PRIMA che Thread A agisca (stale read), Thread B potrebbe trovare gli
items in queue e assegnargli priority diversa. Ma la transazione di Thread B non
sovrascrive items già visibili — al massimo crea una breve inconsistenza di priority
che non è critica.

**Valutazione**: nessuna race condition che causa data corruption.

### CC7 — Cache globale di validNodes()

`eZFlowPool::validNodes()` usa una cache in `$GLOBALS['eZFlowPool'][$blockID]`.
Dopo il nostro UPDATE, la cache potrebbe contenere i valori vecchi (ts_visible=0, no items).

Se `getData()` viene chiamata NELLA STESSA REQUEST HTTP dopo `createXML()`, leggerebbe
dalla cache stale e vedrebbe pool vuota.

**Analisi del flow reale**: `createXML()` viene chiamata durante il publish, che avviene
durante la submit. Dopo il submit, il browser viene reindirizzato. La prossima apertura
del form lock_edit è una **nuova request HTTP** → la cache `$GLOBALS` è fresca.

**Valutazione**: non è un problema per il caso lock_edit. La cache è per-request.

---

## 4. Confronto: fix difensivo vs fix root cause

| Aspetto | Fix difensivo (già implementato) | Fix root cause (questo Fix 6) |
|---------|--------------------------------|-------------------------------|
| Dove interviene | Al momento del SAVE (server-side) | Al momento dell'INSERT in pool |
| Cosa preserva | Struttura XML (blocchi non distrutti) | Visibilità items in pool |
| Effetto visivo homepage | Sezione non renderizzata (ha_content=false) | Sezione si renderizza normalmente |
| Tenant affetti | Tutti i tenant con pool vuota | Solo tenant con workflow deferred |
| Necessario | Sì (protezione universale) | Sì (fix root cause specifica) |

**Sono complementari.** Con solo il fix difensivo: la homepage non viene distrutta,
ma alcune sezioni potrebbero essere invisibili ai visitatori finché il cron non gira.
Con solo il fix root cause: la pool è sempre visibile dopo il save, ma se si svuota
per altre ragioni (contenuti eliminati, cron anomalo), i blocchi verrebbero comunque
distrutti senza il fix difensivo.

---

## 5. Punti aperti da chiarire prima di implementare

1. **Perché la riga era commentata in ContentRepository?**
   L'analisi git mostra che era un TODO/reminder mai attivato. Non c'è evidenza di
   un motivo tecnico per non farlo. Ma vale la pena chiedere a Luca Realdi se c'era
   una ragione specifica.

2. **Il workflow "Pre pubblicazione" su Verona è intenzionale?**
   Se sì, deve continuare a funzionare. Il fix non interferisce con il workflow —
   lo bypassa solo per la visibilità degli items nel pool.

3. **I 466 processi deferred vanno processati?**
   Sono accumulati dal ottobre 2024. Potrebbero essere tutti relativi a homepage
   saves che hanno avuto problemi. Vanno analizzati prima di processarli in bulk,
   altrimenti potrebbero pubblicare stati di homepage obsoleti.

---

## 6. Verdict

**Il fix è sicuro da implementare** con le seguenti condizioni:

✅ Corner case CC1 (NumberOfValidItems): accettabile, auto-correzione al prossimo cron  
✅ Corner case CC2 (Priority): non è un problema  
✅ Corner case CC3 (Scope): comportamento corretto per tutti i path  
✅ Corner case CC4 (Rotation): non applicabile  
✅ Corner case CC5 (Idempotenza): nessun problema  
✅ Corner case CC6 (Race condition): nessun danno  
✅ Corner case CC7 (Cache): non applicabile per il flow lock_edit  

⚠️ **Da discutere prima di procedere**: i punti aperti 1, 2, 3 (vedi sezione 5).

---

## 7. Checklist di validazione (da completare prima dell'implementazione)

Questi punti richiedono risposta prima di scrivere codice.

### V1 — CC1 accettabile? [ ]

**Domanda:** il comportamento transitorio di CC1 è accettabile?

Con il fix, se un utente aggiunge più items del `NumberOfValidItems` configurato (es. 20
items su un blocco con limite 15), tutti e 20 diventano visibili subito invece dei 15
previsti. Il cron successivo li riduce a 15.

**Risposta attesa:** sì / no / condizionale

---

### V2 — Ragione del commento in ContentRepository? [ ]

**Domanda:** c'è una ragione tecnica per cui la riga in `ContentRepository.php:433`
era commentata fin dall'inizio?

```php
//        eZFlowOperations::update([$object->mainNodeID()]);
```

Il commit `bf50afe` (Luca Realdi, 1 ottobre 2025) l'ha aggiunta già commentata senza
spiegazione nel commit message.

Possibili ragioni:
- Performance (chiamare `update()` inline è costoso su sistemi con molti blocchi)
- Era un reminder da attivare solo in certi contesti
- Era già gestito da `ezpagetype.php::onPublish()` nel caso standard e il commento era ridondante
- C'era un bug noto nel chiamarla qui

**Risposta attesa:** spiegazione tecnica o conferma "era solo un TODO"

---

### V3 — 466 processi deferred su Verona: gestione separata? [ ]

**Domanda:** i 466 processi `ezworkflow_process` con status=10 accumulati dal ottobre 2024
su Verona devono essere processati/ripuliti prima o dopo questo fix? Come?

**Contesto:** sono tutti legati al workflow "Pre pubblicazione" (workflow_id=2).
Potrebbero contenere stati di homepage ormai obsoleti. Processarli in bulk potrebbe
pubblicare versioni vecchie di contenuti.

**Risposta attesa:**
- Processare in bulk con cron
- Cancellare (drop del backlog)
- Ignorare (restano deferred indefinitamente senza danni?)
- Investigare singolarmente

---

### V4 — Il workflow "Pre pubblicazione" è intenzionale e corretto? [ ]

**Domanda:** il workflow "Pre pubblicazione" (group_ezserial) su Verona è una configurazione
intenzionale del tenant o un residuo di una configurazione passata? Dovrebbe continuare
a girare dopo il fix?

**Impatto del fix sul workflow:** nessuno — il workflow continua a funzionare esattamente
come prima. Il fix interviene solo sulla visibilità degli items nel pool, non sul processo
di publish. Il contenuto continua ad andare in stato deferred se il workflow è attivo.

**Risposta attesa:** il workflow è attivo intenzionalmente / è un residuo da rimuovere
