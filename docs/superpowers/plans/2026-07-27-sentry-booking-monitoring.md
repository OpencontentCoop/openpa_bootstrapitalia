# Sentry Booking Monitoring (v1, solo browser) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Caricare l'SDK Sentry JS anche per i visitatori anonimi, ma solo nelle pagine del wizard di prenotazione, riusando il toggle per-tenant già esistente ("Monitoraggio performance redazione").

**Architecture:** Nuovo template `sentry_init.tpl` incluso in testa a `booking.tpl`, che replica esattamente il pattern di caricamento/init Sentry già usato in `page_footer_script.tpl` per gli utenti loggati, ma con condizione di attivazione invertita (si attiva quando l'utente NON è loggato). Nessun codice PHP nuovo: solo template eZ Publish Legacy.

**Tech Stack:** eZ Publish Legacy template engine (file `.tpl`), Sentry JavaScript Loader (già in uso).

## Global Constraints

- Nessuna modifica al comportamento per utenti loggati o per pagine diverse da quelle di booking (spec: "Non-goal").
- Nessuna modifica al backend PHP, al CSP handler, o a nuove impostazioni per-tenant (spec: "Non-goal").
- Riusare esattamente la stessa funzione template `sentry_script_loader()` e lo stesso pattern `Sentry.init({ environment: ... })` già presenti in `page_footer_script.tpl` — non introdurre una configurazione Sentry diversa.
- Se il toggle per-tenant (`sentry_script_loader()`) è vuoto, il comportamento per quel tenant non deve cambiare rispetto a oggi.

**Nota sul testing:** questo repo (eZ Publish Legacy) non ha un framework di test automatico per i template (`tests/` contiene un solo script isolato, nessun phpunit/behat configurato). La verifica di ogni task è quindi manuale/browser-based, come già indicato nella spec — non ci sono unit test da scrivere per file `.tpl`.

---

### Task 1: Creare il template `sentry_init.tpl`

**Files:**
- Create: `design/bootstrapitalia2/templates/bootstrapitalia/booking/sentry_init.tpl`

**Interfaces:**
- Consumes: template operator `sentry_script_loader()` (già definito in `autoloads/openpabootstrapitaliaoperators.php:636` e registrato in `autoloads/eztemplateautoload.php:50`); template operator `openpa_instance_identifier()` (definito nel pacchetto dipendente `openpa-ls`, già usato in `design/bootstrapitalia2/templates/page_footer_script.tpl:13`); fetch `user`/`current_user` con attributo `is_logged_in` (stesso fetch già usato in `page_footer_script.tpl:4`).
- Produces: markup HTML/JS che carica lo script loader Sentry e chiama `Sentry.init(...)` quando incluso in una pagina — nessuna funzione esposta ad altri task, è un include "foglia".

- [ ] **Step 1: Scrivere il contenuto del template**

Crea il file con questo contenuto esatto:

```
{if fetch( 'user', 'current_user' ).is_logged_in|not()}
{def $sentry_script_loader = sentry_script_loader()}
{if $sentry_script_loader}
<script src="{$sentry_script_loader}" crossorigin="anonymous"></script>
<script>
  window.Sentry && Sentry.onLoad(function() {ldelim}
    Sentry.init({ldelim}
      environment: "{openpa_instance_identifier()}"
    {rdelim});
  {rdelim});
</script>
{/if}
{undef $sentry_script_loader}
{/if}
```

Questo è lo stesso identico pattern di `page_footer_script.tpl:4-19`, con l'unica differenza che qui si attiva quando l'utente **non** è loggato (lì si attiva nel ramo `{else}`, cioè quando è loggato).

- [ ] **Step 2: Verificare la sintassi del template**

Non essendoci un compilatore standalone dei template disponibile in locale, verifica manualmente che le parentesi graffe siano bilanciate e che ogni `{if}`/`{def}` abbia il suo `{/if}`/`{undef}` corrispondente contando i blocchi nel file:

```bash
grep -c '{if ' design/bootstrapitalia2/templates/bootstrapitalia/booking/sentry_init.tpl
grep -c '{/if}' design/bootstrapitalia2/templates/bootstrapitalia/booking/sentry_init.tpl
```

Expected: entrambi i comandi restituiscono lo stesso numero (2).

- [ ] **Step 3: Commit**

```bash
git add design/bootstrapitalia2/templates/bootstrapitalia/booking/sentry_init.tpl
git commit -m "feat: aggiunge template init Sentry per utenti anonimi sul booking"
```

---

### Task 2: Includere `sentry_init.tpl` in `booking.tpl`

**Files:**
- Modify: `design/bootstrapitalia2/templates/bootstrapitalia/booking.tpl:1`

**Interfaces:**
- Consumes: il template `bootstrapitalia/booking/sentry_init.tpl` prodotto in Task 1 (nessun parametro in ingresso).
- Produces: nessuna interfaccia consumata da altri task — è l'ultimo step di integrazione.

- [ ] **Step 1: Aggiungere l'include in testa al file**

Il file oggi inizia così:

```
{if $offices|count()|eq(0)}
{include uri='design:bootstrapitalia/booking/breadcrumb.tpl'}
```

Modificalo aggiungendo l'include **prima** della riga `{if $offices|count()|eq(0)}`, così l'inizializzazione Sentry avviene indipendentemente dal fatto che il servizio abbia sedi disponibili o meno:

```
{include uri='design:bootstrapitalia/booking/sentry_init.tpl'}
{if $offices|count()|eq(0)}
{include uri='design:bootstrapitalia/booking/breadcrumb.tpl'}
```

- [ ] **Step 2: Verificare che il resto del file sia invariato**

```bash
git diff design/bootstrapitalia2/templates/bootstrapitalia/booking.tpl
```

Expected: l'unica differenza è la riga `{include uri='design:bootstrapitalia/booking/sentry_init.tpl'}` aggiunta come prima riga del file. Nessun'altra riga toccata.

- [ ] **Step 3: Commit**

```bash
git add design/bootstrapitalia2/templates/bootstrapitalia/booking.tpl
git commit -m "feat: carica Sentry per utenti anonimi nel wizard di prenotazione"
```

---

### Task 3: Verifica manuale end-to-end

**Files:** nessuno (solo verifica, nessun codice da modificare)

**Interfaces:**
- Consumes: le modifiche dei Task 1 e 2, deployate su un'istanza di test/staging con il toggle "Monitoraggio performance redazione" configurato (campo `EditorPerformanceMonitor` in `/bootstrapitalia/info`, visibile solo all'utente `admin`).
- Produces: conferma che il comportamento atteso è verificato prima di aprire la PR.

- [ ] **Step 1: Verificare il caricamento anonimo su istanza con toggle attivo**

Su un'istanza di test con il campo "Monitoraggio performance redazione" compilato: aprire il wizard di prenotazione **in navigazione anonima** (o senza login), aprire i devtools del browser (tab Network e Console), e confermare che:
- venga richiesto lo script il cui URL corrisponde al valore configurato nel toggle
- in Console non compaiano errori di sintassi/init di Sentry
- l'oggetto globale `window.Sentry` sia definito dopo il caricamento (digitare `window.Sentry` in console)

- [ ] **Step 2: Verificare l'assenza di cambiamenti su istanza senza toggle**

Su un'istanza di test **senza** il toggle configurato (campo vuoto): aprire il wizard di prenotazione in anonimo e confermare nei devtools che nessuno script Sentry venga richiesto — nessun cambiamento rispetto al comportamento pre-modifica.

- [ ] **Step 3: Verificare l'assenza di doppio caricamento per utenti loggati**

Sulla stessa istanza con il toggle attivo: fare login e aprire il wizard di prenotazione. Confermare nei devtools (tab Network) che lo script Sentry venga richiesto **una sola volta** (non due), dato che sia `page_footer_script.tpl` che il nuovo `sentry_init.tpl` sono presenti nella pagina ma solo uno dei due rami `{if is_logged_in}` è attivo alla volta.

- [ ] **Step 4: Provocare un errore di test e confermarlo su Sentry**

Con il wizard aperto in anonimo su un'istanza con toggle attivo, forzare un errore JS da console (es. `undefined.foo()`), poi verificare che compaia un nuovo issue nel progetto Sentry `opencontent/opencity-cms` (https://opencontent.sentry.io/issues/?project=4506053449678848) taggato con l'`environment` corrispondente all'identificativo dell'istanza di test.

- [ ] **Step 5: Aggiornare la spec con l'esito della verifica**

Se tutti i controlli precedenti passano, non serve nessuna modifica al codice. Se emerge un problema, tornare ai Task 1/2 per correggerlo prima di procedere.

---

## Self-Review

- **Spec coverage:** "Modifica" (Task 1+2), "Effetti collaterali attesi" (nessuna azione richiesta, solo verificati in Task 3 Step 2/3), "Cosa cattura" (verificato in Task 3 Step 4), "Testing" della spec (mappato 1:1 su Task 3). Nessun gap.
- **Placeholder scan:** nessun TBD/TODO; ogni step ha contenuto completo (codice template esatto, comandi esatti).
- **Type/naming consistency:** il nome file `sentry_init.tpl` e il path `bootstrapitalia/booking/sentry_init.tpl` sono usati in modo identico in Task 1 (creazione) e Task 2 (include) e nella spec.
