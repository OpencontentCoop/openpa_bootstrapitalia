# Rollout CSP strict in produzione

## Contesto

Tracciato in [GitLab issue #433](https://gitlab.com/opencity-labs/sito-istituzionale/cms/-/issues/433)
"Protezione inserimento contenuti sito tramite CSP", milestone 2026-Q3,
**scadenza 2026-09-30**.

Oggi i redattori CMS possono inserire qualsiasi contenuto esterno (immagini, script)
senza restrizioni. Obiettivo: attivare la Content-Security-Policy in modalita' **strict**
(non solo Report-Only) in produzione sui nuovi siti e sui siti degli enti SaaS che
rientrano nella normativa NIS2 (comuni sopra i 100.000 abitanti e ASL). Prima di attivare
lo strict su un tenant serve analizzare le violazioni Report-Only per non rompere nulla.

## Elenco siti da migrare

La checklist con l'elenco degli enti coinvolti e l'ordine di migrazione e' nella issue
#433 stessa. La mappatura completa siteaccess/tenant per ciascun ente e' nel
[GitLab work item #368](https://gitlab.com/opencity-labs/sito-istituzionale/cms/-/work_items/368)
"Mappatura prodotti e clienti da migrare dietro WAF Cloudflare" — **non riportare qui
nomi di enti o hostname specifici**, consultare sempre quelle due fonti per lo stato
aggiornato.

Nota generale sulla topologia: gli enti sono ospitati o su infrastruttura **SaaS**
(EC2/Ansible, repo `saasopenpa-settings`) o su **Boat** (Docker Swarm). Alcuni hanno
anche prodotti satellite (OpenAgenda per eventi, un servizio "Sensor"/SensorCivico per
le segnalazioni disservizi) su tenant/hostname separati dal sito principale.

## Risorse

- Dashboard Grafana "Content Security Policy Monitor" (prod):
  https://grafana.opencontent.it/d/id1xYoZ4z/content-security-policy-monitor-csp?orgId=1&var-app=cms&var-env=production
  (MCP server `grafana` disponibile in `openpa_bootstrapitalia` per interrogare Loki
  direttamente da Claude Code)
- Validatore regole: https://csp-evaluator.withgoogle.com/
- Tester/reviewer menzionato nella issue: `@rluccisano`

## Procedura, sito per sito

1. Analizzare le violazioni Report-Only su Grafana/Loki, **sempre filtrando per
   `metadata_app="cms"`** — altrimenti si mescolano i log di altre app (es. SDC/Stanza
   del Cittadino, che ha una CSP completamente separata e puo' gia' essere in modalita'
   enforce).
2. Per ogni `blocked_uri` trovato, distinguere:
   - **rumore/malware lato client** (adware, browser hijacker, estensioni) → ignore-list
     del CSP collector, non tocca il csp.ini
   - **regola legittima generica** (dominio/servizio usato potenzialmente da tutti i
     siti) → `openpa_bootstrapitalia/settings/csp.ini` (file condiviso da tutti i tenant)
   - **regola legittima sito-specifica** (hostname che contiene il nome dell'ente, o
     servizio di terze parti integrato solo li') → vedi sezione "Dove vanno le regole"
     sotto
3. Validare la policy risultante con csp-evaluator.
4. Attivare strict in produzione per quel tenant — **operazione che tocca un sito
   comunale live, richiede sempre conferma esplicita** prima del deploy, anche se gia'
   validato in Report-Only.
5. Attendere qualche giorno, riverificare i log, poi passare al sito successivo.

### Verifica dei falsi positivi — IMPORTANTE

Un `blocked_uri` nel report CSP **non e' prova che il sito lo chiami davvero**. Molte
violazioni osservate sono generate da estensioni del browser del visitatore (ad-block,
toolbar, tool AI, ecc.) o da adware/malware sul suo dispositivo, non dal sito. Un
segnale ambiguo tipico: un dominio che sembra *gia' coperto* dalla policy incorporata
nello stesso report (es. un dominio esplicitamente presente in `img-src` ma comunque
segnalato come violazione).

**Prima di aggiungere una regola per un dominio dubbio**, aprire la pagina reale
(`document_uri` del log) in un browser pulito e leggere le richieste di rete effettive
(strumenti Claude in Chrome: `navigate` + `read_network_requests`). Nell'analisi
condotta finora, diversi domini "sospetti" (un CDN esterno per font, un widget JS di
terze parti, gli script del player YouTube con Widget API) si sono rivelati **tutti
falsi positivi**: la pagina reale non li chiamava affatto — verosimilmente iniettati da
estensioni del browser del visitatore. Solo dopo questa verifica un dominio va
classificato come rumore o come regola legittima; anche un falso positivo puo' comunque
essere promosso a regola globale, se il servizio a cui si riferisce e' comunque
plausibile come pattern legittimo generico (vedi esempio YouTube piu' sotto).

### Attenzione ai filtri troppo ampi sull'URL della pagina

Quando si interroga Loki filtrando per `document_uri`, un pattern troppo generico (es.
un match libero sul nome a dominio dell'ente) puo' includere per errore sottodomini o
sistemi completamente estranei che condividono solo una parte del nome — ad esempio
sottodomini di uffici/servizi periferici su un CMS legacy diverso, che per eredita'
storica puntano ancora allo stesso `report-uri`. Usare sempre un match il piu' stretto
possibile sul dominio pubblico effettivo del sito che si sta analizzando (es. l'host
esatto `www.<dominio-ente>`, non un pattern che matcha qualsiasi sottodominio).

## Dove vanno le regole legittime sito-specifiche

`openpa_bootstrapitalia/settings/csp.ini` e' il default **globale**, condiviso da tutti
i siti che usano quella versione dell'estensione — **non ci vanno regole specifiche di
un singolo tenant** (es. un hostname che contiene il nome del comune, o un servizio di
terze parti integrato solo li').

- **Siti SaaS**: repo `saasopenpa-settings`, file
  `siteaccess/<tenant>_frontend/csp.ini.append.php`. Aggiungere le direttive nelle
  sezioni `[ContentSecurityPolicy]` e `[ContentSecurityPolicyReportOnly]` con la
  sintassi standard eZ Publish `direttiva[]=valore` — essendo un file
  `.ini.append.php`, il comportamento nativo per le variabili array e' l'**append**
  alla lista definita nel file globale, non la sovrascrittura.
- **Siti su Boat** (Docker Swarm): via variabile d'ambiente sul servizio, formato:
  ```
  EZINIMERGE_csp__<Sezione>__<direttiva>__<indice>=valore
  ```
  Esempio: `EZINIMERGE_csp__ContentSecurityPolicyReportOnly__connect-src__0=esempio.dominio.it`

  Verificato leggendo `lib/ezutils/classes/ezini.php` (righe 217-259, 1479-1491): il
  meccanismo fa un `array_merge()` tra l'array esistente e il valore iniettato — quindi
  **append, non sovrascrive nulla**. L'indice finale (`__0`, `__1`, ...) **non e' una
  posizione** nell'array risultante (PHP rinumera le chiavi numeriche in `array_merge`),
  serve solo a distinguere piu' valori iniettati sulla stessa direttiva.

Una regola va nel file globale `openpa_bootstrapitalia/settings/csp.ini` solo se e'
davvero generica (es. un dominio di servizio condiviso potenzialmente usato da tutti i
siti — analytics, font, CDN interni, player video), non un hostname o servizio
specifico di un tenant.

### Verificare sempre il siteaccess giusto, non fidarsi della mappatura esterna

La mappatura del work item #368 non e' sempre affidabile: in un caso il siteaccess
li' indicato per un ente non aveva nemmeno un `csp.ini.append.php`, e il suo `SiteURL`
puntava a un dominio interno (`*.openpa.opencontent.io`), non al dominio pubblico
dell'ente. Il sito reale rispondeva invece a un siteaccess con nome completamente
diverso.

**Prima di applicare una regola CSP per un ente**, verificare sempre quale siteaccess
risponde davvero al dominio pubblico cercando la riga `HostUriMatchMapItems[]=<dominio
pubblico>;...;<siteaccess>` in `saasopenpa-settings/override/site.ini.append.php` (o nel
`site.ini.append.php` del singolo siteaccess per `SiteURL=`). Ricordarsi anche delle
eventuali varianti lingua (stesso ente, siteaccess diversi per ogni lingua) — la regola
va replicata su tutte.

## Toggle per-tenant CSP — dove si trova

- Per i tenant SaaS: repo `saasopenpa-settings`,
  `siteaccess/<tenant>_frontend/csp.ini.append.php` — sezione `[Settings]`:
  `ContentSecurityPolicy=enabled` (strict) oppure `ContentSecurityPolicyReportOnly=enabled`.
  Default globale (solo `report-uri`) in `override/csp.ini.append.php`.
- Report-Only e' gia' attivo in produzione su diversi tenant SaaS (branch
  `enable-csp-report-main-tenants`, mergiato in master il 26/02/2026) e strict e' gia'
  attivo su un template per i nuovi siti e su un ambiente QA — per lo stato aggiornato
  di quali tenant hanno quale modalita' attiva, controllare direttamente i file
  `csp.ini.append.php` in `saasopenpa-settings` (non tenerne un elenco qui, cambia
  spesso durante il rollout).
- Per i siti su Boat: vedi sezione EZINIMERGE sopra per le regole custom; il toggle
  strict/report-only per Boat non e' ancora stato verificato in questo rollout.

## Pattern ricorrenti gia' incontrati

### Legittimi, sito-specifici (via csp.ini.append.php o EZINIMERGE)

- Servizio "SensorCivico" segnalazioni disservizi — hostname tipo
  `sensor.comune.<ente>.it` o `sensorcivico.comune.<ente>.it`. Su `connect-src`, pagina
  `/segnala_disservizio`.
- Sottodomini OpenAgenda/eventi specifici del tenant (es. `eventi.comune.<ente>.it`) —
  `img-src` (immagini) e `script-src`/`script-src-elem` (ricerca JSONP).
- Sottodomini "ufficio stampa" con widget di ricerca comunicati via JSONP (es.
  `www.ufficiostampa.<dominio-ente>`) — `script-src-elem`. Variante: talvolta e'
  invece un iframe embed diretto di un comunicato — stesso sottodominio ma su
  `frame-src`.

### Legittimi, generici (candidati per il csp.ini globale)

- `*.comuni-chiamo.com` — widget di segnalazione disservizi di terze parti (ComuniChiamo),
  riutilizzabile su piu' siti. `connect-src` + `font-src`.
- `m1.openfpcdn.io` (FingerprintJS) — usato dal servizio Satisfy, condiviso su piu'
  siti. `connect-src`.
- `*.webanalytics.italia.it` su **`img-src`** (oltre che su `connect-src` gia'
  presente) — il pixel di tracciamento Matomo (`ingestion.webanalytics.italia.it/matomo.php`)
  viene caricato anche come immagine, non solo via XHR.
- YouTube widget/IFrame API — `script-src[]=https://www.youtube.com` (copre sia
  `www-widgetapi.js` che `/iframe_api`) e `img-src[]=https://img.youtube.com`
  (thumbnail, dominio diverso da `*.ytimg.com` gia' presente). `frame-src` aveva gia'
  `*.youtube.com` per l'iframe semplice. **Nota**: nella pagina specifica dove sono
  comparsi la verifica browser ha mostrato che non erano chiamati (falso positivo lato
  client in quel caso) — abilitati comunque globalmente su decisione di Marco, perche'
  il player YouTube con widget API e' un pattern legittimo generico che puo'
  presentarsi su altri contenuti/redattori.
- `frame-src[]=https://www.raiplaysound.it` — embed audio RAI, abilitato globalmente
  per lo stesso motivo (pattern di embed multimediale generico, anche se osservato una
  sola volta).
- `frame-src[]=https://youtu.be` — link breve YouTube incollato da un redattore come
  iframe embed, invece del formato completo `youtube.com/embed/...`. **Confermato
  reale** con verifica browser (iframe presente nel DOM) — dominio diverso da
  `*.youtube.com` gia' presente.
- `frame-src[]=https://api.webanalytics.italia.it` — iframe di dashboard Matomo
  embeddate sulla pagina di sistema `/statistiche` (funzionalita' standard del tema,
  non contenuto redazionale libero). **Confermato reale**: 5 iframe verso questo
  dominio trovati nel DOM della pagina.

### Rumore / malware lato client (ignore-list del CSP collector, NON nel csp.ini)

`browser-update.org`, `ad-ninja.net`, `junklip.com`, `safesearchinc.com` (browser
hijacker/adware), `www.google.com/s2/favicons`, `frontend-cdn.perplexity.ai`,
`cdn.scite.ai`, `cdnjs.cloudflare.com` (font-awesome — verificato: il sito lo serve da
`static.opencityitalia.it`, non da cdnjs), `static.opencityitalia.it/widgets/satisfy/...`
(risultava violazione ma non e' mai chiamato dalla pagina reale), un dominio di terze
parti comparso come favicon di un link esterno in una pagina (su decisione di Marco,
non generalizzabile a whitelist).

La ignore-list vera e propria vive nel CSP collector (repo/config non ancora
individuato — Marco la applica manualmente). Aggiunti anche altri domini
palesemente adware/malware lato client (URL con parametri offuscati/base64,
riferimenti a toolbar o hijacker noti) via decisione diretta senza verifica browser
quando il pattern e' inequivocabile.

### Da valutare (visti una volta sola, non ancora classificati)

- Sprite emoji di Facebook (`static.xx.fbcdn.net/images/emoji.php/...`) — visto in
  pagine `/content/edit/...` (backend redattore). Non chiaro se widget legittimo o
  estensione lato client del redattore.
- `s3.eu-west-1.amazonaws.com` (con **punto**) su `connect-src` — presigned URL per
  bucket `static.stanzadelcittadino.it/uploads/...` (upload/anteprima allegati SDC).
  Il csp.ini attuale ha solo `s3-eu-west-1.amazonaws.com` (con **trattino**, vecchio
  formato endpoint AWS) e solo su `img-src` — sono due host CSP diversi, quindi questo
  non e' coperto. Sospetto sia generico (bucket SDC condiviso) ma da confermare se
  ricompare su altri siti.
- Un viewer documenti Office di terze parti su `frame-src` — visto in una pagina di
  concorso/bando; al momento della verifica il contenuto non era piu' presente sulla
  pagina (probabile bando scaduto/rimosso), non confermabile con certezza.
- `use.typekit.net` (Adobe TypeKit) su `font-src` — verificato con browser reale:
  nessuna traccia nel DOM al momento della visita (ne' `<link>` ne' `<script>` con quel
  dominio), probabile estensione browser tipo "font inspector" del visitatore. Lasciato
  tra i dubbi anziche' in ignore-list su indicazione di Marco.

## Nota tecnica: due host AWS S3 diversi

`s3-eu-west-1.amazonaws.com` (trattino) e `s3.eu-west-1.amazonaws.com` (punto) sono
**due hostname DNS realmente diversi** — il primo e' il vecchio formato di endpoint
regionale S3, il secondo quello piu' recente. Per la CSP, che fa match esatto
sull'hostname, sono due domini completamente scollegati: coprire uno non copre l'altro.
