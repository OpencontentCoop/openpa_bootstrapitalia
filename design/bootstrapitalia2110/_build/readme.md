## Per eseguire la build dei css e dei js
```
#nvm use 20
cd ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/
npm i
npm run build
```

La build crea i file css nella cartella `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/stylesheets`
relativi a ciascun file presente in  `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/src/scss` 
che non ha prefisso `_`

Ogni file è un tema a eccezione di `common.css` che raccoglie stili generici 

Il file di tema principale è `default.scss` che contiene gli import previsti da bootstrap-italia e da design-comuni-pagine-statiche

La directory `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/src/scss/opencity` 
contiene le customizzazioni e gli override delle regole scss importati in `default` e in `common`.

## Dev mode
Per poter testare gli aggiornamenti in ambienti con cache condivisa creare il file `extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/dev-mode` e rieseguire la build 

## Per aggiornare le dipendenze

Dipendenze:
- versione v2.11.0 `b41fe0f8c` di [bootstrap-italia](https://github.com/italia/bootstrap-italia.git)
- versione >v2.4.0 `50c4938` di [design-comuni-pagine-statiche](https://github.com/italia/design-comuni-pagine-statiche.git)

Installare bootstrap-italia in una directory dedicata
```
git clone git@github.com:italia/bootstrap-italia.git
cd bootstrap-italia
npm i
```

Copiare i sorgenti nella cartella di _build:
```
cp -rv src/scss/* html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/src/scss
cp -rv src/js/* html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/src/js
cp -rv src/svg/* html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/src/svg
```

Modificare il file `html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/package.json` 
per aggiornare le dipendenze

Cherry picking tra `rollup.config.js` e `html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/rollup.config.js`
per mantenere le regole di build specifiche

Installare design-comuni-pagine-statiche in una directory separata:
```
git clone git@github.com:italia/design-comuni-pagine-statiche.git
cd design-comuni-pagine-statiche
nvm use 16
npm i
```

Copiare i sorgenti scss nella cartella di _build:
```
cp -rv src/stylesheets/* /Users/lrealdi/git/AWS/openpa-saas-distribution/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/design-comuni-pagine-statiche
cd /src/components
mkdir _export
find . -name \*.scss -exec cp {} _export \;
mv _export /Users/lrealdi/git/AWS/openpa-saas-distribution/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/design-comuni-pagine-statiche/components
```

Eseguire un merge di  `bootstrap-italia/src/scss/bootstrap-italia.scss` e di  `design-comuni-pagine-statiche/src/stylesheets/styles.scss` 
in `/Users/lrealdi/git/AWS/openpa-saas-distribution/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2110/_build/src/scss/default.scss` 
e verificare se ancora necessari gli override 

Il plugin masonry.js è stato modificato per essere eseguito dopo che i font siano stati caricati, in modo da evitare problemi di spaziature

```
  document.fonts.ready.then(() => {
    masonries.forEach((masonry) => {
      Masonry.getOrCreateInstance(masonry)
    })
  });
```

Aggiunta classe `oc-card-title-clamp` per contenere su tre righe i testi in overlay delle card image.

Aggiunta classe `oc-box-shadow-border` per il bordo dell'instestazione sticky della tabella permessi utenti.

Aggiunta classe `oc-overlay-gradient-bottom-md-right` per il gradiente di sfondo del blocco ricerca se abilitato il campo logo.

Sovrascritte le classi `leaflet-popup-content-wrapper`, `leaflet-popup-content`, `leaflet-popup-close-button` per migliorare lo stile delle card come popup delle mappe.

Utilizzato `scroll-padding-top` sul tag `html` per la gestione dello spazio verticale nell'utilizzo dei link ancora. Questo non viene utilizzato correttamente dal componente Navscroll, che richiede quindi la classe `anchor-offset` sulle sezioni della pagina che controlla.

Modificato lo script Masonry per calcolare gli spazi dopo il caricamento dei font ed evitare spaziature sbagliate.

Utilizzato selettore `html[lang^="de"]` per mandare a capo correttamente le parole tedesche molto lunghe.

Utilizza la classe `oc-table-responsive` per avere una tabella con prima riga e prima colonna sempre visibili.

Utilizzato `oc-placeholder` per correggere il colore del placeholder della barra di ricerca.