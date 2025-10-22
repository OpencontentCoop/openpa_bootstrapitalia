
## Build css e js

```
#nvm use 18
cd ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2/_build/
npm i
npm run build
```


## Aggiornare le dipendenze

```
git clone git@github.com:italia/bootstrap-italia.git
cd bootstrap-italia
git checkout v2.2.0
npm i

cp -rv src/scss/* ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2/_build/src/scss
cp -rv src/js/* ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2/_build/src/js
cp -rv src/svg/* ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2/_build/src/svg
```

Controllare le differenze tra `src/scss/bootstrap-italia-comuni.scss` e `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2/_build/src/scss/default.scss`
Cherry picking tra `package.json` e `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2/_build/package.json`
Cherry picking tra `rollup.config.js` e `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2/_build/rollup.config.js`
```
git clone git@github.com:italia/design-comuni-pagine-statiche.git
cd design-comuni-pagine-statiche
nvm use 16
npm i

cp -rv src/stylesheets/* ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2/_build/design-comuni-pagine-statiche
cp -rv src/components ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2/_build/design-comuni-pagine-statiche
cp -rv src/elements ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia2/_build/design-comuni-pagine-statiche
```

Aggiunta classe `oc-card-title-clamp` per contenere su tre righe i testi in overlay delle card image.

Aggiunta classe `oc-box-shadow-border` per il bordo dell'instestazione sticky della tabella permessi utenti.

Aggiunta classe `oc-overlay-gradient-bottom-md-right` per il gradiente di sfondo del blocco ricerca se abilitato il campo logo.

Sovrascritte le classi `leaflet-popup-content-wrapper`, `leaflet-popup-content`, `leaflet-popup-close-button` per migliorare lo stile delle card come popup delle mappe.

Utilizzato `scroll-padding-top` sul tag `html` per la gestione dello spazio verticale nell'utilizzo dei link ancora. Questo non viene utilizzato correttamente dal componente Navscroll, che richiede quindi la classe `anchor-offset` sulle sezioni della pagina che controlla.

Modificato lo script Masonry per calcolare gli spazi dopo il caricamento dei font ed evitare spaziature sbagliate.

Utilizzato selettore `html[lang^="de"]` per mandare a capo correttamente le parole tedesche molto lunghe.

Utilizzato `oc-placeholder` per correggere il colore del placeholder della barra di ricerca.