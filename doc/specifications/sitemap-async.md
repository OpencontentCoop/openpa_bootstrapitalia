# Sitemap asincrona — analisi e approccio

## Problema

La sitemap del sito (`/sitemap.xml`) non contiene tutti i contenuti pubblicati perché generarla a runtime sarebbe troppo pesante: ogni richiesta richiederebbe una scansione completa di tutti i contenuti pubblicati (articoli, documenti, eventi, servizi, ecc.).

## Requisiti

- La sitemap deve contenere tutti i contenuti pubblicati (articoli, documenti, eventi, servizi, luoghi, uffici, ecc.)
- Una sitemap per tenant (es. `https://www.comune.vicopisano.pi.it/sitemap.xml`)
- Latenza accettabile: alcune ore (Googlebot non fa poll continuo, la sitemap viene riletta ogni qualche giorno)
- Deve funzionare sia su **SaaS** (500+ tenant, PostgreSQL multi-tenant, cron centralizzato) sia su **Boat** (Docker Swarm, singolo sito per container)
- Non dipendere da Solr per la generazione (evita overload su istanza condivisa)

## Approccio scelto: `sitemap_url` table + workflow event + cron leggero

### Architettura

```
Content publish/delete
    → SitemapWorkflowEventType (nuovo evento workflow eZ Publish)
        → UPSERT / DELETE sulla tabella `sitemap_url` (DB del tenant)

Cron (ogni N ore):
    → legge `sitemap_url` per tenant
    → genera XML (stream row per row, nessun picco di memoria)
    → scrive file su DFS
    → nginx serve /sitemap.xml dal file DFS
```

### Tabella `sitemap_url`

```sql
CREATE TABLE sitemap_url (
    id          SERIAL PRIMARY KEY,
    loc         VARCHAR(2048) NOT NULL UNIQUE,
    lastmod     TIMESTAMP,
    changefreq  VARCHAR(20) DEFAULT 'weekly',
    priority    DECIMAL(2,1) DEFAULT 0.5
);
```

Popolata in tempo reale dal workflow event. Il cron non fa query Solr: fa solo una SELECT sulla tabella.

### Perché non Solr

Usare Solr per la generazione causerebbe:
- N query per sito per paginare i risultati (max 1000/query)
- Su 600 siti in parallelo: migliaia di query Solr in pochi minuti sull'istanza condivisa
- Overload prevedibile

La tabella `sitemap_url` rende il cron una semplice SELECT — trascurabile anche con `-j10` su 600 tenant.

### Differenza SaaS vs Boat

| | SaaS | Boat |
|---|---|---|
| Workflow event | ✅ identico | ✅ identico |
| Tabella DB | ✅ per-tenant | ✅ nel DB del sito |
| Generazione | Script `utils/generate_sitemap.php` via `ezcron` (centralizzato) | Stesso script, cron dentro il container |
| Nginx | Serve file DFS staticamente | Serve file DFS staticamente |

Il codice del workflow event e dello script di generazione è lo stesso per entrambi gli ambienti.

### Backfill iniziale

Una-tantum per ogni tenant: uno script che legge tutti i contenuti pubblicati (via DB o Solr) e popola la tabella `sitemap_url`. Da eseguire con `ezcron` su SaaS, manualmente o via deploy su Boat.

### Sitemap index per siti grandi

Per siti con >50k URL (limite Google per singolo file), si genera un `sitemap_index.xml` che punta a file separati per content type:

```xml
<sitemapindex>
  <sitemap><loc>/sitemap-notizie.xml</loc></sitemap>
  <sitemap><loc>/sitemap-servizi.xml</loc></sitemap>
  <sitemap><loc>/sitemap-pagine.xml</loc></sitemap>
</sitemapindex>
```

Per la maggior parte dei comuni italiani un singolo file è sufficiente.

## Estensioni coinvolte

| Componente | Dove |
|---|---|
| `SitemapWorkflowEventType` + schema SQL | `openpa_bootstrapitalia` (o nuova ext `ocsitemap`) |
| Script `generate_sitemap.php` + cron entry | `saasopenpa-distribution-prod` |
| Script generazione (single-site) + cron entry container | repo Boat |
| Regola nginx per servire file DFS | conf nginx di SaaS e Boat |

### Aperto: estensione dedicata o dentro `openpa_bootstrapitalia`?

Una nuova estensione `ocsitemap` sarebbe più pulita e attivabile selettivamente, ma aggiunge un repo da mantenere. Integrare in `openpa_bootstrapitalia` è più rapido. Decisione rimandata all'inizio dell'implementazione.

## Approcci scartati

### A — Cron + Solr (runtime full scan)
Scartato perché: Solr overload su 600 tenant in parallelo, memoria elevata per siti grandi, nessun diff (rigenera tutto anche senza modifiche).

### B — Kafka consumer incrementale
Scartato per complessità: richiede un consumer separato da deployare e mantenere, gestione offset replay se il consumer è down, complessità di scrittura atomica su file XML. Non giustificato vista la latenza accettabile di qualche ora.

### C — Workflow event + DB + render on-demand (senza cron)
Valutato ma scartato: il render on-demand funziona bene per tenant singoli (Boat) ma su SaaS con `/sitemap.xml` crawlata da Googlebot su 600 siti aggiunge carico PHP unpredictable. Il file statico su DFS è più robusto.
