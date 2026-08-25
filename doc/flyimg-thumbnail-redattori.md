# Flyimg per le thumbnail dell'interfaccia redattori

## Contesto

L'obiettivo è poter rimuovere dalla Content-Security-Policy la regola che whitelista il dominio S3 grezzo (es. `s3-eu-west-1.amazonaws.com`), oggi necessaria perché diverse superfici dell'interfaccia redattori (frontend, Lock Edit, backend admin) mostravano thumbnail con URL diretto verso lo storage invece che tramite il proxy CDN flyimg, già usato dal frontend pubblico ma mai esteso all'area redazionale.

Il meccanismo server-side esisteva già: la classe `BootstrapItaliaImage::process()` (invariata da questo lavoro) e l'operator di template `render_image`. Il lavoro consiste nell'estendere questo meccanismo, o un suo equivalente lato client, a ogni punto dell'interfaccia dove prima veniva mostrato un URL diretto.

## Architettura finale

**Lato server** (template `.tpl`): ogni punto riusa `render_image`/`BootstrapItaliaImage::process()` — nessuna logica di URL-building reimplementata in PHP.

**Lato client** (widget JS che consumano dati da estensioni condivise `ezjscore`/`ocopendata`, non modificabili): un endpoint `GET /ezjscore/call/ezjscflyimg::config` (`classes/ezjscore/ezjscflyimg.php`) espone la stessa configurazione flyimg in JSON. Un helper `OpenPAFlyImg.rewrite(url, alias)` la consuma e riscrive l'URL prima del render.

### L'helper `OpenPAFlyImg` è duplicato identico in 8 file

Il progetto duplica già interi file JS per design (`jquery.opendatabrowse.js`, `jquery.relationsbrowse.js`, `popup_utils.js` esistevano triplicati/duplicati prima di questo lavoro). Introdurre un meccanismo di caricamento condiviso per un helper di ~40 righe è stato giudicato un'astrazione non necessaria rispetto al rischio. Le 8 copie:

- `design/bootstrapitalia/javascript/jquery.opendatabrowse.js`
- `design/bootstrapitalia2/javascript/jquery.opendatabrowse.js`
- `design/bootstrapitalia2110/javascript/jquery.opendatabrowse.js`
- `design/bootstrapitalia/javascript/jquery.opendataform.js`
- `design/bootstrapitalia/javascript/jquery.relationsbrowse.js`
- `design/bootstrapitalia2110/javascript/jquery.relationsbrowse.js`
- `design/bootstrapitalia/javascript/ezoe/popup_utils.js`
- `design/backend/javascript/ezoe/popup_utils.js`

**Attenzione per manutenzione futura:** qualunque modifica alla funzione `rewrite()` va replicata identica in tutte e 8 le copie. Questo è già successo storicamente: due bug (vedi sotto) sono stati corretti in due giri perché il primo giro ha coperto solo 4 delle 8 copie. `tests/test_openpa_flyimg_rewrite.js` protegge meccanicamente questa invarianza — esegue la stessa batteria di test su ogni copia dell'helper, scoprendola dinamicamente (scansione di `design/` alla ricerca della firma della funzione), così una nona copia futura viene automaticamente inclusa.

### Un solo override quando possibile

`design/standard/templates/ezoe/` è l'ultimo anello di fallback comune sia alla catena di design frontend sia a quella backend — un file qui (es. `tag_embed_images.tpl`) copre entrambi i siteaccess senza bisogno di due copie separate.

## Bug trovati durante il testing manuale

Il progetto non ha alcun framework di test automatico (né PHPUnit né un runner JS). La verifica è stata interamente manuale, nell'ambiente Docker di sviluppo. Sono stati trovati e corretti 5 bug reali:

1. **Doppio proxy**: `OpenPAFlyImg.rewrite()` non era idempotente — chiamata due volte sullo stesso URL (accade in alcuni flussi di Lock Edit) produceva un URL annidato rotto. Fix: guardia che riconosce un URL già proxato (inizia già con `config.baseUrl`) e lo restituisce invariato.
2. **URL relativi trattati come assoluti**: alcuni campi (es. `/image/view/<id>/small`, un modulo interno che serve l'immagine same-origin senza mai toccare S3) venivano comunque passati a `rewrite()`, che li corrompeva. Fix: guardia che ignora gli URL non `http://`/`https://`.
3. **Dialog "Modifica embed" non coperto**: un template kernel eZ (`ezoe/tag_embed_images.tpl`) mai overriddato in questo progetto costruiva l'anteprima con URL diretto.
4. **Regressione**: il fix #2 ha reso inutilizzabile una riga preesistente in `popup_utils.js` (frontend) che prefissava l'URL con `ez_root_url` prima di passarlo a `rewrite()` — con `ForceVirtualHost=true` questo prefisso produce una stringa che la nuova guardia anti-relativi scarta come "già relativa", lasciando un `<img>` rotto. Rimosso il prefisso superfluo (la copia backend non l'ha mai avuto).
5. **Spreco di risorse su tenant senza flyimg**: `BootstrapItaliaImage::process()` genera sempre l'alias "reference" (potenzialmente costoso) anche quando il risultato viene scartato perché flyimg è disabilitato. I nuovi punti di chiamata in `classes/ezjscore/ezjscbrowse.php` pagavano questo costo inutilmente; ora guardati con `BootstrapItaliaImage::isEnabled()` (già esistente, mai usato prima).

## Limiti noti / debito tecnico

- **Mappa filtri triplicata**: i valori alias→dimensioni (es. `medium` → 400×400) sono duplicati in `classes/BootstrapItaliaImage.php`, `classes/ezjscore/ezjscflyimg.php` e nella fixture del test JS. Un refactoring che derivi le due copie aggiuntive da un'unica fonte eliminerebbe questo rischio di divergenza.
- **Piccole divergenze PHP/JS** nella costruzione dell'URL: `urlencode()` (PHP) vs `encodeURIComponent()` (JS) codificano gli spazi in modo diverso; `parse_url()` (PHP, ignora la porta) vs `a.host` (JS, la include); per un alias non nella mappa nota, il JS applica un fallback a 2500px mentre il PHP non applica alcun filtro di dimensione — un redattore che seleziona un alias "custom" (es. `listitem`, `articleimage`, presenti come alias in `image.ini` ma non nella mappa dei 7 alias standard) può vedere un'anteprima sovradimensionata nel dialog embed.
- **Copertura non verificabile end-to-end da questo ambiente dev**: `design/standard/templates/ezoe/tag_embed_images.tpl` ha portata universale (si applica a qualunque design chain), ma dipende da `OpenPAFlyImg` definito solo nelle copie di `popup_utils.js` presenti in `design/bootstrapitalia/` e `design/backend/`. Un tenant con una design chain che non passa da nessuno dei due (es. `SiteDesign=admin` diretto) avrebbe potuto incontrare un `ReferenceError` — mitigato con una guardia `typeof OpenPAFlyImg !== 'undefined'` che fa fallback all'URL diretto, ma non testabile dal vivo in questo ambiente (che ha solo le 2 catene frontend/backend).

## Verifica

```bash
node tests/test_openpa_flyimg_rewrite.js
```
