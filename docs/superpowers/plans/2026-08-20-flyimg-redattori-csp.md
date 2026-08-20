# Flyimg per tutte le thumbnail redattori (rimozione CSP S3) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Far sì che ogni thumbnail/anteprima immagine mostrata nell'interfaccia redattori di OpenCity (sia siteaccess `frontend` sia siteaccess `backend`) passi dal proxy CDN flyimg invece che da un URL diretto verso lo storage (S3 o Minio), così da poter rimuovere in sicurezza la regola CSP che whitelista il dominio S3 grezzo.

**Architecture:** Dove il rendering è server-side (template `.tpl`), si riusa il meccanismo già esistente `BootstrapItaliaImage::process()` / operator di template `render_image`. Dove il rendering è client-side (widget JS alimentati da JSON di estensioni condivise `ezjscore`/`ocopendata` che non vogliamo toccare per non rompere la API pubblica), si introduce un piccolo endpoint `ezjscore` che espone la stessa configurazione flyimg (`openpa.ini` `[ImageSettings]`) in JSON, e un helper JS che replica lato client la stessa logica di costruzione URL, applicato nei punti di rendering `<img>`.

**Tech Stack:** eZ Publish legacy (PHP 7.4), template engine eZ (`.tpl`), jQuery, `ezjscore` (ajax RPC), Docker Compose dev env (`sito-comunale-dev`, container `sito-comunale-dev-app-1`, flyimg su `static-opencity.localtest.me`, Minio come storage locale).

**Spec:** nessuno spec doc separato — i requisiti sono discussi e concordati in conversazione (obiettivo dichiarato dall'utente: poter rimuovere la regola CSP per il dominio S3 grezzo; nessuna strada infrastrutturale/proxy davanti a S3; solo interventi applicativi).

## Global Constraints

- Nessun push su remoto: tutto resta locale sul branch `feature/335-flyimg-thumbnail-redattori` (creato da `master`), in attesa di conferma esplicita dell'utente.
- Non toccare i repository `ocopendata` o `ezjscore` (core condiviso): dove i dati arrivano da lì, il fix è lato client (JS), mai lato server in quei repo.
- Non modificare il contratto della API REST pubblica (`/opendata/api/content/search/`, `/api/openapi/...`): nessuna modifica ai serializer `AttributeConverter`.
- Quando flyimg è disabilitato per un tenant (`FlyImgBaseUrl` vuoto in `openpa.ini`), il comportamento deve restare invariato rispetto a oggi (URL diretto, nessuna rottura).
- Ogni fix template deve riusare `BootstrapItaliaImage::process()` / operator `render_image`, mai reinventare la logica di building URL lato PHP.
- Ogni fix JS deve riusare lo stesso helper `OpenPAFlyImg.rewrite(url, alias)` duplicato identico in ogni file che lo richiede (il progetto duplica già interi file JS per design, quindi duplicare un piccolo helper è coerente con il pattern esistente — non introdurre un nuovo meccanismo di loading condiviso tra design diversi).
- Verifica manuale nel browser (Chrome via MCP) richiesta per ogni task che tocca un file: login admin `admin`/`changethispassword` su `https://opencity.localtest.me/backend` per siteaccess backend, editing diretto su `https://opencity.localtest.me/content/edit/...` per siteaccess frontend.
- Prima di ogni verifica: svuotare la cache eZ con `docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all`.

---

## Task 1: Endpoint `ezjscore` che espone la configurazione flyimg in JSON

**Files:**
- Create: `classes/ezjscore/ezjscflyimg.php`
- Modify: `settings/ezjscore.ini.append.php`

**Interfaces:**
- Produces: endpoint ajax `GET /ezjscore/call/ezjscflyimg::config` che risponde `{"content": {"enabled": bool, "baseUrl": string, "backendBaseUrl": string, "backendBaseScheme": string, "defaultFilter": string, "filters": {"reference": {"w":2500,"h":2500}, "large": {"w":800,"h":800}, "imagelargeoverlay": {"w":800,"h":800}, "medium": {"w":400,"h":400}, "small": {"w":200,"h":200}, "mini": {"w":180,"h":180}, "rss": {"w":100,"h":100}}}, ...}`. Questi valori replicano esattamente `BootstrapItaliaImage::generateFilters()` (`classes/BootstrapItaliaImage.php:124-171`) e la lettura ini in `BootstrapItaliaImage::__construct()` (righe 35-38).

- [ ] **Step 1: Creare la classe PHP**

```php
<?php

class ezjscFlyImg extends ezjscServerFunctions
{
    /**
     * @param array $args
     * @return array
     */
    public static function config($args)
    {
        $baseUrl = rtrim(OpenPAINI::variable('ImageSettings', 'FlyImgBaseUrl', ''), '/');

        return array(
            'enabled' => $baseUrl !== '',
            'baseUrl' => $baseUrl,
            'backendBaseUrl' => OpenPAINI::variable('ImageSettings', 'BackendBaseUrl', ''),
            'backendBaseScheme' => OpenPAINI::variable('ImageSettings', 'BackendBaseScheme', ''),
            'defaultFilter' => OpenPAINI::variable('ImageSettings', 'FlyImgDefaultFilter', ''),
            'filters' => array(
                'reference' => array('w' => 2500, 'h' => 2500),
                'large' => array('w' => 800, 'h' => 800),
                'imagelargeoverlay' => array('w' => 800, 'h' => 800),
                'medium' => array('w' => 400, 'h' => 400),
                'small' => array('w' => 200, 'h' => 200),
                'mini' => array('w' => 180, 'h' => 180),
                'rss' => array('w' => 100, 'h' => 100),
            ),
        );
    }
}
```

- [ ] **Step 2: Registrare la funzione in `settings/ezjscore.ini.append.php`**

Il file attuale (righe 1-33) registra `ezjscbrowse` così:
```ini
[eZJSCore]
Packer=2
LoadFromCDN=disabled
LocalScripts[jqueryUI]=jquery-ui.min.js
FunctionList[]=ezjscbrowse

[ezjscServer_ezjscbrowse]
Class=ezjscBrowse
```

Aggiungere, seguendo lo stesso pattern, una riga `FunctionList[]=ezjscflyimg` dopo quella di `ezjscbrowse`, e un nuovo blocco `[ezjscServer_ezjscflyimg]` con `Class=ezjscFlyImg`, inserito subito dopo il blocco `[ezjscServer_ezjscbrowse]` (righe 15-16 del file attuale).

- [ ] **Step 3: Svuotare la cache e verificare l'endpoint**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
docker exec sito-comunale-dev-app-1 curl -s "http://localhost/ezjscore/call/ezjscflyimg::config"
```

Expected: risposta JSON con `"enabled":true` (dato che l'ambiente dev ha `FlyImgBaseUrl` configurato) e `"baseUrl":"https://static-opencity.localtest.me/upload"` (senza slash finale), più la mappa `filters` come sopra.

- [ ] **Step 4: Commit**

```bash
git add classes/ezjscore/ezjscflyimg.php settings/ezjscore.ini.append.php
git commit -m "Aggiunge endpoint ezjscore per esporre la config flyimg ai widget JS"
```

---

## Task 2: Fix `design/backend/templates/content/datatype/view/ezimage.tpl` (nuovo override)

Copre in un colpo solo: popup classico "Content browse" in vista griglia (`thumbnail/image_browse.tpl`), tab "Relazioni" di un oggetto (`content/related/thumbnail.tpl`), e la vista `content/view/full` di un content object di classe immagine sotto `/backend` (verificato dal vivo: `https://opencity.localtest.me/backend/Media/Images/Competenze-digitali.png` mostra oggi `.../Competenze-digitali.png_large.png` diretto) — tutti e tre passano da `{attribute_view_gui attribute=... image_class=...}`, che senza un override in `design/backend` ricade sul template kernel `design/standard/templates/content/datatype/view/ezimage.tpl`.

**Files:**
- Create: `design/backend/templates/content/datatype/view/ezimage.tpl`

**Interfaces:**
- Consumes: operator `render_image` (già registrato globalmente via `autoloads/eztemplateautoload.php`, disponibile in qualunque siteaccess/design).

- [ ] **Step 1: Creare il file, basato sul kernel `design/standard/templates/content/datatype/view/ezimage.tpl`, con un solo cambio: la riga `<img src=...>`**

```
{* DO NOT EDIT THIS FILE! Use an override template instead. *}
{*
Input:
 image_class - Which image alias to show, default is large
 css_class     - Optional css class to wrap around the <img> tag, the
                 class will be placed in a <div> tag.
 alignment     - How to align the image, use 'left', 'right' or false().
 link_to_image - boolean, if true the url_alias will be fetched and
                 used as link.
 href          - Optional string, if set it will create a <a> tag
                 around the image with href as the link.
 border_size   - Size of border around image, default is 0
*}
{default image_class=large
         css_class=false()
         alignment=false()
         link_to_image=false()
         href=false()
         target=false()
         hspace=false()
         border_size=0
         border_color=''
         border_style=''
         margin_size=''
         alt_text=''
         title=''}

{let image_content = $attribute.content}

{if $image_content.is_valid}

    {let image        = $image_content[$image_class]
         inline_style = ''}

    {if $link_to_image}
        {set href = $image_content['original'].url|ezroot}
    {/if}
    {switch match=$alignment}
    {case match='left'}
        <div class="imageleft">
    {/case}
    {case match='right'}
        <div class="imageright">
    {/case}
    {case/}
    {/switch}

    {if $css_class}
        <div class="{$css_class|wash}">
    {/if}

    {if and( is_set( $image ), $image )}
        {if $alt_text|not}
            {if $image.text}
                {set $alt_text = $image.text}
            {else}
                {set $alt_text = $attribute.object.name}
            {/if}
        {/if}
        {if $title|not}
            {set $title = $alt_text}
        {/if}
        {if $border_size|trim|ne('')}
            {set $inline_style = concat( $inline_style, 'border: ', $border_size, 'px ', $border_style, ' ', $border_color, ';' )}
        {/if}
        {if $margin_size|trim|ne('')}
            {set $inline_style = concat( $inline_style, 'margin: ', $margin_size, 'px;' )}
        {/if}
        {if $href}<a href={$href}{if and( is_set( $link_class ), $link_class )} class="{$link_class}"{/if}{if and( is_set( $link_id ), $link_id )} id="{$link_id}"{/if}{if $target} target="{$target}"{/if}{if and( is_set( $link_title ), $link_title )} title="{$link_title|wash}"{/if}>{/if}
        <img src="{render_image($image_content, hash('alias', $image_class)).src}" width="{$image.width}" height="{$image.height}" {if $hspace}hspace="{$hspace}"{/if} style="{$inline_style}" alt="{$alt_text|wash(xhtml)}" title="{$title|wash(xhtml)}" />
        {if $href}</a>{/if}
    {/if}

    {if $css_class}
        </div>
    {/if}

    {switch match=$alignment}
    {case match='left'}
        </div>
    {/case}
    {case match='right'}
        </div>
    {/case}
    {case/}
    {/switch}

    {/let}

{/if}

{/let}

{/default}
```

- [ ] **Step 2: Svuotare la cache**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
```

- [ ] **Step 3: Verificare nel browser (siteaccess backend)**

Con Chrome MCP, login su `https://opencity.localtest.me/backend` (`admin`/`changethispassword`), poi navigare su `https://opencity.localtest.me/backend/Media/Images/Competenze-digitali.png` ed eseguire:
```js
Array.from(document.querySelectorAll('img')).map(img => img.src).filter(s => s.includes('opencity-bucket') || s.includes('static-opencity'))
```
Expected: nessun risultato con `opencity-bucket` (URL diretto), almeno un risultato con `static-opencity.localtest.me/upload/`.

- [ ] **Step 4: Commit**

```bash
git add design/backend/templates/content/datatype/view/ezimage.tpl
git commit -m "Aggiunge override backend per ezimage view: thumbnail via flyimg anche in siteaccess backend"
```

---

## Task 3: ~~Fix `design/backend/override/templates/embed_image.tpl`~~ — SALTATO

**Decisione esplicita dell'utente (2026-08-20): non applicare questo fix.** Nessuna azione da eseguire per questo task. Lasciato in elenco solo per tracciabilità della numerazione dei task successivi.

---

## Task 4: Fix `design/backend/override/templates/embed-inline_image.tpl` (nuovo override)

Stessa tecnica `render_image` già usata negli altri override (vedi Task 2), per la variante "inline" dell'embed (regola `[embed-inline_image]`, già dichiarata, `Source=content/view/embed-inline.tpl`).

**Files:**
- Create: `design/backend/override/templates/embed-inline_image.tpl`

- [ ] **Step 1: Creare il file**

```
{let image_variation="false"
     attribute_parameters=$object_parameters}
{if is_set($attribute_parameters.size)}
{set size=$attribute_parameters.size}
{else}
{set size=ezini( 'ImageSettings', 'DefaultEmbedAlias', 'content.ini' )}
{/if}
{set image_variation=$object.data_map.image.content[$size]}
<img src="{render_image($object.data_map.image.content, hash('alias', $size)).src}" alt="{$object.data_map.image.content.alternative_text|wash(xhtml)}"
    {cond( $attribute_parameters.align, concat( ' class="embed-inline-', $attribute_parameters.align, '"' ), '' )} />
{/let}
```

- [ ] **Step 2: Svuotare la cache**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
```

- [ ] **Step 3: Verificare nel browser**

Login su `https://opencity.localtest.me/backend`, aprire in edit un content object con un campo `ezxmltext` (es. l'oggetto id 229, tab "Descrizione"), aprire l'editor WYSIWYG, inserire/aprire un embed "in linea"/inline di un'immagine, selezionare un'immagine e verificare (via `javascript_tool` su `document.querySelectorAll('img')`, o chiedendo all'utente di copiare l'indirizzo se il dialog non è raggiungibile dagli strumenti Chrome MCP) che l'anteprima non contenga più `opencity-bucket` ma `static-opencity.localtest.me/upload/`.

- [ ] **Step 4: Commit**

```bash
git add design/backend/override/templates/embed-inline_image.tpl
git commit -m "Aggiunge override backend per embed-inline_image: preview embed inline WYSIWYG via flyimg"
```

---

## Task 5: Fix `design/backend/override/templates/tiny_image.tpl` (nuovo override)

Stessa tecnica, per la vista "tiny" (bookmark/cronologia toolbar admin, regola `[tiny_image]`, `Source=content/view/tiny.tpl`).

**Files:**
- Create: `design/backend/override/templates/tiny_image.tpl`

- [ ] **Step 1: Creare il file**

```
{default $object_parameters=array()}
{let image_variation="false"
     align="center"
     attribute_parameters=$object_parameters}
{if is_set($attribute_parameters.size)}
{set size=$attribute_parameters.size}
{else}
{set size=ezini( 'ImageSettings', 'DefaultEmbedAlias', 'content.ini' )}
{/if}
{set image_variation=$object.data_map.image.content[$size]}

{if is_set($link_parameters.href)}<a href={$link_parameters.href|ezurl} target="{$link_parameters.target|wash}"{if is_set($link_parameters.class)} class="{$link_parameters.class|wash}"{/if}{if is_set($link_parameters['xhtml:id'])} id="{$link_parameters['xhtml:id']|wash}"{/if}{if is_set($link_parameters['xhtml:title'])} title="{$link_parameters['xhtml:title']|wash}"{/if}>{/if}
<img src="{render_image($object.data_map.image.content, hash('alias', $size)).src}" alt="{$object.data_map.image.content.alternative_text|wash(xhtml)}" />
{if is_set($link_parameters.href)}</a>{/if}
{/let}
{/default}
```

- [ ] **Step 2: Svuotare la cache**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
```

- [ ] **Step 3: Verificare nel browser**

Login su `https://opencity.localtest.me/backend`, aggiungere un'immagine ai "preferiti"/bookmark (o consultare la lista "visti di recente" nella toolbar admin, se presente per il tipo immagine), e verificare via `javascript_tool` che l'`<img>` mostrato punti a `static-opencity.localtest.me/upload/` e non a `opencity-bucket`.

- [ ] **Step 4: Commit**

```bash
git add design/backend/override/templates/tiny_image.tpl
git commit -m "Aggiunge override backend per tiny_image: vista tiny (bookmark/cronologia) via flyimg"
```

---

## Task 6: Popup classico "Content browse" sotto siteaccess backend — nessuna azione separata

**Decisione esplicita dell'utente (2026-08-20):** il popup che si apre cliccando "Aggiungi oggetti"/"Cerca oggetti" su un campo `ezobjectrelationlist` sotto `/backend` (es. "Galleria immagini" dell'oggetto 229) non è un template server-side separato da investigare: è renderizzato dallo stesso widget JS coperto da `jquery.relationsbrowse.js` e/o `jquery.opendatabrowse.js` (Task 7-10). Nessuna azione aggiuntiva pianificata qui — la verifica di questo specifico caso d'uso è spostata nella checklist del Task 13 (siteaccess backend), che deve includere esplicitamente il click su "Aggiungi oggetti"/"Cerca oggetti" del campo "Galleria immagini" come controllo a sé.

**Files:** nessuna modifica in questo task.

---

## Task 7: Helper JS condiviso `OpenPAFlyImg.rewrite` + applicazione in `jquery.opendatabrowse.js` (bootstrapitalia2)

**Files:**
- Modify: `design/bootstrapitalia2/javascript/jquery.opendatabrowse.js`

**Interfaces:**
- Consumes: endpoint `GET /ezjscore/call/ezjscflyimg::config` (Task 1).
- Produces: `OpenPAFlyImg.rewrite(url, alias)` — funzione globale nello scope del file, riusata identica negli altri task JS.

- [ ] **Step 1: Aggiungere l'helper in cima al file (prima della definizione del plugin jQuery)**

```js
var OpenPAFlyImg = (function ($) {
    var config = null;

    function loadConfig() {
        if (config !== null) {
            return;
        }
        config = {enabled: false};
        $.ajax({
            url: '/ezjscore/call/ezjscflyimg::config',
            async: false,
            dataType: 'json'
        }).done(function (data) {
            if (data && data.content && data.content.enabled) {
                config = data.content;
            }
        });
    }

    function rewrite(url, alias) {
        if (!url) {
            return url;
        }
        loadConfig();
        if (!config.enabled) {
            return url;
        }
        var filter = config.filters[alias] || config.filters.reference;
        var filters = ['rf_1'];
        if (config.defaultFilter) {
            filters.push(config.defaultFilter);
        }
        filters.push('w_' + filter.w);
        filters.push('h_' + filter.h);

        var sourceUrl = url;
        if (config.backendBaseUrl) {
            var a = document.createElement('a');
            a.href = url;
            sourceUrl = url.replace(a.host, config.backendBaseUrl);
            if (config.backendBaseScheme) {
                sourceUrl = sourceUrl.replace(a.protocol.replace(':', ''), config.backendBaseScheme);
            }
        }

        return config.baseUrl + '/' + filters.join(',') + '/' + encodeURIComponent(sourceUrl);
    }

    return {rewrite: rewrite};
})(jQuery);
```

- [ ] **Step 2: Applicare l'helper in `makeListItem` (riga 712 nel file attuale)**

Sostituire:
```js
makeListItem: function(item){        
    var self = this;
    var name;
    var lineHeightStyle = item.thumbnail_url ? 'height: 80px;' : '';
```
con:
```js
makeListItem: function(item){        
    var self = this;
    var name;
    item.thumbnail_url = OpenPAFlyImg.rewrite(item.thumbnail_url, 'small');
    var lineHeightStyle = item.thumbnail_url ? 'height: 80px;' : '';
```

Questo copre sia la modalità sfoglia-albero (che alimenta `item.thumbnail_url` alla riga 395 con `thumbnail_url: this.thumbnail_url`, dati da `ezjscnode::subtree`) sia la modalità ricerca testuale (che lo alimenta alla riga 659 con `thumbnail_url: thumbnail`, dati da `data.image.url` della search API `ocopendata`, alias `original`) — in entrambi i casi il valore finale passa da `item.thumbnail_url` prima di essere iniettato nell'`<img>` alla riga 816 (`listItem.append('<img src="'+item.thumbnail_url+'" ...`).

- [ ] **Step 3: Svuotare la cache**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
```

- [ ] **Step 4: Verificare nel browser (siteaccess frontend, editing diretto)**

Riprodurre esattamente il test già fatto in questa sessione: login, `https://opencity.localtest.me/content/edit/229/3/ita-IT`, campo "Galleria immagini", bottone "Seleziona dalla libreria", sia in modalità sfoglia-albero (default apertura) sia in modalità "Cerca in Images" (digitare "viale", cliccare Cerca). In entrambi i casi, via `javascript_tool`:
```js
Array.from(document.querySelectorAll('img')).map(img => img.src).filter(s => s.includes('opencity-bucket'))
```
Expected: array vuoto (nessuna immagine con URL diretto residuo in questo widget).

- [ ] **Step 5: Commit**

```bash
git add design/bootstrapitalia2/javascript/jquery.opendatabrowse.js
git commit -m "Riscrive le thumbnail del widget opendatabrowse (bootstrapitalia2) via flyimg lato client"
```

---

## Task 8: Stessa fix in `jquery.opendatabrowse.js` (bootstrapitalia)

**Files:**
- Modify: `design/bootstrapitalia/javascript/jquery.opendatabrowse.js`

- [ ] **Step 1: Aggiungere lo stesso helper `OpenPAFlyImg` del Task 7 Step 1, identico, in cima al file**

- [ ] **Step 2: Applicare l'helper in `makeListItem` (riga 749 nel file attuale)**

Sostituire:
```js
if (item.thumbnail_url){
    listItem.append('<img src="'+item.thumbnail_url+'" style="object-fit: contain;width: 80px;height: 80px;margin-right: 10px;" />');
}
```
con:
```js
item.thumbnail_url = OpenPAFlyImg.rewrite(item.thumbnail_url, 'small');
if (item.thumbnail_url){
    listItem.append('<img src="'+item.thumbnail_url+'" style="object-fit: contain;width: 80px;height: 80px;margin-right: 10px;" />');
}
```

(In questa copia il campo è consumato direttamente al punto di rendering, non all'inizio di `makeListItem` come in bootstrapitalia2 — verificare comunque con `grep -n "makeListItem" design/bootstrapitalia/javascript/jquery.opendatabrowse.js` che non ci siano altri usi di `item.thumbnail_url` prima di questo punto nello stesso file; se ce ne sono, spostare la riga di rewrite all'inizio della funzione come nel Task 7.)

- [ ] **Step 3: Svuotare la cache e verificare**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
```
Stessa procedura di verifica del Task 7 Step 4 (il design `bootstrapitalia` è quello risolto quando il siteaccess frontend non ha `bootstrapitalia2` in cima alla propria catena — verificare quale dei due file è effettivamente servito controllando l'URL del file JS caricato dalla pagina, es. via `javascript_tool`: `performance.getEntriesByType('resource').map(r=>r.name).filter(n=>n.includes('opendatabrowse'))`, oppure verificando semplicemente che la thumbnail sia corretta in entrambe le copie indipendentemente da quale sia effettivamente caricata).

- [ ] **Step 4: Commit**

```bash
git add design/bootstrapitalia/javascript/jquery.opendatabrowse.js
git commit -m "Riscrive le thumbnail del widget opendatabrowse (bootstrapitalia) via flyimg lato client"
```

---

## Task 9: Stessa fix in `jquery.opendatabrowse.js` (bootstrapitalia2110)

**Files:**
- Modify: `design/bootstrapitalia2110/javascript/jquery.opendatabrowse.js`

- [ ] **Step 1: Aggiungere lo stesso helper `OpenPAFlyImg` del Task 7 Step 1, identico, in cima al file**

- [ ] **Step 2: Applicare l'helper in `makeListItem` (riga 919 per `lineHeightStyle`, riga 1020 per l'`<img>`, nel file attuale)**

Sostituire:
```js
makeListItem: function(item){        
```
(la riga immediatamente successiva alla dichiarazione della funzione, prima di `var lineHeightStyle = item.thumbnail_url ? 'height: 80px;' : '';` alla riga 919) aggiungendo:
```js
item.thumbnail_url = OpenPAFlyImg.rewrite(item.thumbnail_url, 'small');
```
subito dopo l'apertura della funzione `makeListItem`, prima del calcolo di `lineHeightStyle`.

- [ ] **Step 3: Svuotare la cache e verificare**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
```
Stessa procedura di verifica del Task 7 Step 4.

- [ ] **Step 4: Commit**

```bash
git add design/bootstrapitalia2110/javascript/jquery.opendatabrowse.js
git commit -m "Riscrive le thumbnail del widget opendatabrowse (bootstrapitalia2110) via flyimg lato client"
```

---

## Task 10: Verificare ed eventualmente correggere `jquery.relationsbrowse.js` (bootstrapitalia, bootstrapitalia2110)

Variante legacy di `jquery.opendatabrowse.js` senza motore di ricerca testuale, presente solo in due dei tre design. Non ancora confermato se è ancora usata da qualche campo/vista attiva nell'ambiente di test.

**Files:**
- Modify (se applicabile): `design/bootstrapitalia/javascript/jquery.relationsbrowse.js`
- Modify (se applicabile): `design/bootstrapitalia2110/javascript/jquery.relationsbrowse.js`

- [ ] **Step 1: Verificare se il file costruisce thumbnail con lo stesso pattern**

```bash
grep -n "thumbnail_url\|\.image\.url\|<img" /Volumes/Repos/sviluppo-sito-comunale/openpa_bootstrapitalia/design/bootstrapitalia/javascript/jquery.relationsbrowse.js
grep -n "thumbnail_url\|\.image\.url\|<img" /Volumes/Repos/sviluppo-sito-comunale/openpa_bootstrapitalia/design/bootstrapitalia2110/javascript/jquery.relationsbrowse.js
```

- [ ] **Step 2: Decidere l'azione**

- **Se emergono righe che costruiscono un `<img src=...>` da un campo tipo `thumbnail_url`/`.image.url`**: applicare lo stesso helper `OpenPAFlyImg` (Task 7 Step 1) e lo stesso pattern di rewrite del Task 8/9, adattando il nome esatto della variabile trovata al grep.
- **Se il file non mostra alcuna anteprima immagine** (es. gestisce solo liste testuali nome/tipo): nessuna azione, annotare nel report finale (Task 14).

- [ ] **Step 3: Se sono state fatte modifiche, svuotare la cache, verificare nel browser (individuare un campo che usa questo widget invece del moderno opendatabrowse — verificarlo controllando quale file JS viene effettivamente caricato dalla pagina come nel Task 8 Step 3), e committare**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
git add <file modificati>
git commit -m "Riscrive le thumbnail di jquery.relationsbrowse.js via flyimg lato client"
```

---

## Task 11: Fix del dialog embed classico WYSIWYG (`popup_utils.js`) — copia frontend e copia backend

**Files:**
- Modify: `design/bootstrapitalia/javascript/ezoe/popup_utils.js`
- Create o Modify (in base all'investigazione): file equivalente sotto `design/backend/`

**Interfaces:**
- Consumes: `OpenPAFlyImg.rewrite(url, alias)` (stesso helper del Task 7, duplicato in questo file).

- [ ] **Step 1: Aggiungere l'helper `OpenPAFlyImg` (identico al Task 7 Step 1) in cima a `design/bootstrapitalia/javascript/ezoe/popup_utils.js`**

- [ ] **Step 2: Applicare il rewrite in `browseCallBack` (righe 846-847 nel file attuale)**

Sostituire:
```js
var previewUrl = ed.settings.ez_root_url + encodeURI( n.data_map[ n.image_attributes[imageIndex] ].content[eZOEPopupUtils.settings.browseImageAlias].url )
tag.innerHTML += ' <a href="#">' + ed.getLang('preview.preview_desc')  + '<img src="' + previewUrl + '" /></a>';
```
con:
```js
var previewUrl = OpenPAFlyImg.rewrite( ed.settings.ez_root_url + encodeURI( n.data_map[ n.image_attributes[imageIndex] ].content[eZOEPopupUtils.settings.browseImageAlias].url ), eZOEPopupUtils.settings.browseImageAlias )
tag.innerHTML += ' <a href="#">' + ed.getLang('preview.preview_desc')  + '<img src="' + previewUrl + '" /></a>';
```

- [ ] **Step 3: Svuotare la cache e verificare (siteaccess frontend)**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
```
Riprodurre il test già fatto in sessione: editing diretto su `https://opencity.localtest.me/content/edit/229/3/ita-IT`, tab "Descrizione", editor WYSIWYG, aprire il dialog embed, tab "Browse" (o "Search"), selezionare un'immagine, e verificare (chiedendo eventualmente all'utente di copiare l'indirizzo dell'anteprima come già fatto in precedenza, se il dialog non è raggiungibile dagli strumenti Chrome MCP) che l'URL sia ora su `static-opencity.localtest.me/upload/`.

- [ ] **Step 4: Determinare se serve una copia separata per il siteaccess backend**

```bash
docker exec sito-comunale-dev-app-1 sh -c "find /var/www/html/design/admin /var/www/html/design/admin2 /var/www/html/design/ezflow /var/www/html/extension/ezoe/design/standard -path '*ezoe*popup_utils.js'"
```
- **Se l'unico file esistente nella catena backend è quello del kernel `ezoe`** (cioè né `admin`, `admin2`, `ezflow`, né `design/backend` hanno una propria copia): copiare il contenuto del file kernel trovato in `design/backend/javascript/ezoe/popup_utils.js`, applicandovi lo stesso fix del Step 1-2 (stesso helper, stessa riga `previewUrl` da adattare al numero di riga effettivo nel file kernel — cercare `previewUrl =` nel file copiato con `grep -n`).
- **Se `design/backend` (o un design della sua catena) ha già una propria copia**: applicare lo stesso fix Step 1-2 direttamente su quel file, invece di crearne uno nuovo.

- [ ] **Step 5: Se creato/modificato un file per il backend, svuotare la cache e verificare (siteaccess backend)**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
```
Stessa procedura del Step 3 ma su `https://opencity.localtest.me/backend/content/edit/229/3/ita-IT`.

- [ ] **Step 6: Commit**

```bash
git add design/bootstrapitalia/javascript/ezoe/popup_utils.js <eventuale file backend>
git commit -m "Riscrive l'anteprima del dialog embed WYSIWYG via flyimg lato client (frontend e backend)"
```

---

## Task 12: Investigare i bottoni "Anteprima" e "Modifica" nel widget `opendatabrowse`

**Files:** nessuna modifica pianificabile in anticipo — dipende dall'esito dell'investigazione.

- [ ] **Step 1: Individuare il connector Alpaca/JS coinvolto**

```bash
docker exec sito-comunale-dev-app-1 sh -c "grep -rln 'opendataFormEdit\|view.*display.*object' /var/www/html/extension/ocopendata/design/*/javascript/ 2>/dev/null"
docker exec sito-comunale-dev-app-1 sh -c "grep -rln \"'view':'display'\" /var/www/html/extension/ocopendata/ 2>/dev/null"
```

- [ ] **Step 2: Riprodurre nel browser e catturare la risposta di rete**

Riaprire il widget "Seleziona dalla libreria" (come già fatto in questa sessione su `https://opencity.localtest.me/content/edit/229/3/ita-IT`), cliccare "Anteprima" su un elemento della lista, e con `read_network_requests` (dopo un `clear:true` preventivo) catturare l'endpoint chiamato e, se JSON, il campo usato per l'eventuale immagine mostrata nel form Alpaca che si apre.

- [ ] **Step 3: Decidere l'azione**

- **Se il form Alpaca mostra un'immagine con URL diretto, e il rendering è lato client (JS dentro `ocopendata` o dentro `openpa_bootstrapitalia`)**: se il file JS responsabile vive dentro `openpa_bootstrapitalia` (verificabile con `grep -rn` sul nome della funzione trovata al Step 1 nella cartella `design/` di questo repo), applicare lo stesso helper `OpenPAFlyImg.rewrite` nel punto esatto di rendering. Se il file vive solo dentro `ocopendata` (core), **non modificarlo** (vincolo di progetto) — annotare il punto scoperto nel report finale (Task 14) come rischio residuo esplicito, utile per decidere se rimandarlo a un secondo intervento.
- **Se il form Alpaca non mostra alcuna immagine** (es. mostra solo metadati testuali): nessuna azione, annotare nel report finale.

- [ ] **Step 4: Se sono state fatte modifiche, svuotare la cache, verificare, e committare**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
git add <file modificati>
git commit -m "Riscrive l'anteprima Alpaca del widget opendatabrowse via flyimg lato client"
```

---

## Task 13: Verifica end-to-end su entrambi i siteaccess

**Files:** nessuna modifica — solo verifica.

- [ ] **Step 1: Svuotare la cache una ultima volta**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
```

- [ ] **Step 2: Checklist di verifica siteaccess `frontend` (editing diretto, es. `https://opencity.localtest.me/content/edit/229/3/ita-IT`)**

Per ciascuno dei seguenti, usare `javascript_tool` con `Array.from(document.querySelectorAll('img')).map(img => img.src).filter(s => s.includes('opencity-bucket'))` e verificare che sia sempre `[]` (array vuoto):
- [ ] Anteprima campo "Galleria immagini" (vista già presente, senza aprire alcun widget)
- [ ] Widget "Seleziona dalla libreria", modalità sfoglia-albero
- [ ] Widget "Seleziona dalla libreria", modalità ricerca testuale
- [ ] Dialog embed WYSIWYG, tab Browse
- [ ] Dialog embed WYSIWYG, tab Search
- [ ] Anteprima/Modifica del widget opendatabrowse (se coperti dal Task 12)

- [ ] **Step 3: Checklist di verifica siteaccess `backend` (login `https://opencity.localtest.me/backend`)**

Stessa checklist del Step 2, ripetuta su:
- [ ] `https://opencity.localtest.me/backend/Media/Images/Competenze-digitali.png` (vista full)
- [ ] Edit di un content object con campo `ezobjectrelationlist` immagine (es. `https://opencity.localtest.me/backend/content/edit/229/3/ita-IT`, campo "Galleria immagini"), bottoni "Aggiungi oggetti"/"Cerca oggetti"
- [ ] Vista a griglia thumbnail nel browsing dei contenuti (`/backend/Media/Images` con vista a icone, se disponibile)
- [ ] Dialog embed WYSIWYG (tab Browse e Search) in un content object sotto `/backend`
- [ ] Vista "tiny" (bookmark/cronologia toolbar admin)
- [ ] Tab "Relazioni" di un content object con relazioni verso oggetti immagine

- [ ] **Step 4: Documentare eventuali punti ancora scoperti**

Se uno o più controlli della checklist falliscono (mostrano ancora `opencity-bucket`), NON procedere alla chiusura del lavoro: tornare al task corrispondente, o se il punto non era stato mappato da nessun task precedente, annotarlo esplicitamente come nuovo punto scoperto e discuterlo con l'utente prima di considerare l'intervento concluso (obiettivo dichiarato: rimuovere la regola CSP per S3 richiede copertura totale, non parziale).

---

## Task 14: Riepilogo finale (nessun push)

**Files:** nessuna modifica.

- [ ] **Step 1: Rivedere il log dei commit sul branch**

```bash
git log master..feature/335-flyimg-thumbnail-redattori --oneline
```

- [ ] **Step 2: Preparare un riepilogo per l'utente**

Elencare: tutti i file toccati/creati, i punti confermati coperti (checklist Task 13), eventuali punti rimasti scoperti/rimandati (es. connector Alpaca `ocopendata` se non modificabile, Task 10/6 se hanno concluso "nessuna azione necessaria" — specificare perché), e il promemoria esplicito che il branch **non è stato pushato** e resta in attesa di conferma esplicita dell'utente prima di qualunque `git push`, per la regola di branching del progetto.

- [ ] **Step 3: Attendere conferma esplicita dell'utente prima di qualsiasi `git push`**

Nessun comando da eseguire in autonomia in questo step: è un checkpoint di attesa.
