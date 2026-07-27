# Sentry monitoring sul wizard di prenotazione (v1, solo browser)

## Contesto

Alcuni cittadini segnalano problemi durante la procedura di prenotazione appuntamenti (wizard booking) che non riusciamo a riprodurre internamente. Il sistema ha già un'integrazione Sentry JS (progetto Sentry condiviso `opencontent/opencity-cms`, DSN `https://6135970e1f4d71ac96e4115d277fbe10@o408094.ingest.us.sentry.io/4506053449678848`), ma oggi si attiva solo per utenti **loggati** (redattori/admin nel backend eZ Publish), tramite il toggle per-tenant "Monitoraggio performance redazione" (`eZSiteData` chiave `sentry_script_loader`, impostato in `/bootstrapitalia/info`).

Il wizard di prenotazione è usato prevalentemente da cittadini **anonimi** (l'autenticazione SPID/CIE avviene solo a metà flusso), quindi con la configurazione attuale gli errori JS che occorrono durante buona parte della procedura non vengono mai catturati.

## Obiettivo di questa iterazione

Estendere il caricamento di Sentry JS anche ai visitatori anonimi, **limitatamente alle pagine del wizard di prenotazione**, riusando lo stesso toggle esistente. Nessuna modifica al backend PHP, nessuna nuova infrastruttura Sentry, nessun tag/breadcrumb custom — solo "accendere" la cattura errori di default del loader Sentry dove oggi manca.

## Non-goal (esplicitamente fuori scope per questa iterazione)

- Cattura errori lato backend PHP (bridge verso "Stanza del Cittadino")
- Tag/contesto custom (step del wizard, service id, ecc.) o breadcrumb applicativi
- Modifiche al comportamento per utenti loggati o per pagine non-booking
- Nuovo progetto/DSN Sentry o nuove impostazioni per-tenant

Questi possono diventare iterazioni successive una volta valutati i primi dati raccolti.

## Design

### Comportamento attuale (invariato)

`design/bootstrapitalia2/templates/page_footer_script.tpl` carica lo script loader Sentry solo se:
1. l'utente corrente è loggato (`fetch('user','current_user').is_logged_in`), **e**
2. il toggle per-tenant è valorizzato (`sentry_script_loader()` non vuoto)

Questa logica non viene toccata.

### Modifica

Il caricamento per gli **anonimi** viene agganciato non al footer globale, ma direttamente al template d'ingresso del wizard, `design/bootstrapitalia2/templates/bootstrapitalia/booking.tpl` (il wrapper `<div data-booking>`). Motivo: il routing/modulo che porta a questa pagina vive nel pacchetto separato `openpa_booking-ls` (non in questo repo) — agganciarsi al template piuttosto che al modulo evita di dipendere da quel routing.

Nuovo template `design/bootstrapitalia2/templates/bootstrapitalia/booking/sentry_init.tpl`, incluso in testa a `booking.tpl`, con questa logica:

```
{if fetch('user','current_user').is_logged_in|not()}
  {def $sentry_script_loader = sentry_script_loader()}
  {if $sentry_script_loader}
    <script src="{$sentry_script_loader}" crossorigin="anonymous"></script>
    <script>
      window.Sentry && Sentry.onLoad(function() {
        Sentry.init({
          environment: "{openpa_instance_identifier()}"
        });
      });
    </script>
  {/if}
  {undef $sentry_script_loader}
{/if}
```

Se l'utente è già loggato, il template non fa nulla (Sentry è già caricato dal footer globale — nessun doppio init). Se l'utente è anonimo, riusa esattamente la stessa funzione `sentry_script_loader()` e lo stesso pattern di init già usato in `page_footer_script.tpl` — comportamento identico, cambia solo la condizione di attivazione (pagina booking invece di stato di login).

### Effetti collaterali attesi (già gestiti, nessuna modifica necessaria)

- **CSP**: `classes/csp/ContentSecurityPolicyHandler.php` whitelist già dinamicamente il dominio dello script loader quando `AutoEmbedPerformanceMonitor` è abilitato — la logica è indipendente dalla pagina, quindi funziona automaticamente anche per le pagine booking.
- **Tenant senza monitoring**: se `sentry_script_loader()` è vuoto per un tenant, il nuovo include non fa nulla — nessun cambiamento di comportamento per i tenant che non hanno mai attivato il toggle.

### Cosa cattura

Errori JS non gestiti (eccezioni, promise rejection) nel browser durante il wizard di prenotazione — comportamento di default del Sentry Loader, taggati con l'`environment` dell'istanza (permette di distinguere il tenant, dato che il progetto Sentry è condiviso da tutto il SaaS).

### Testing

- Verifica manuale: su un'istanza con il toggle "Monitoraggio performance redazione" configurato, aprire il wizard di prenotazione **senza login** e controllare (devtools → network/console) che lo script loader Sentry venga caricato e che `Sentry.init` venga eseguito.
- Verifica che su un'istanza **senza** il toggle configurato non cambi nulla (nessuno script caricato).
- Verifica che per un utente **loggato** non ci sia doppio caricamento/doppio init dello script.
- Provocare un errore JS di test nel wizard (es. da console) e confermare che compaia come nuovo issue nel progetto Sentry `opencontent/opencity-cms`, taggato con l'environment dell'istanza di test.
