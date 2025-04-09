## Per eseguire la build dei css e dei js
```
#nvm use 18
cd ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/
npm i
npm run build
```

La build crea i file css nella cartella `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/stylesheets`
relativi a ciascun file presente in  `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/src/scss` 
che non ha prefisso `_`

Ogni file è un tema a eccezione di `common.css` che raccoglie stili generici 

Il file di tema principale è `default.scss` che contiene gli import previsti da bootstrap-italia e da design-comuni-pagine-statiche

La directory `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/src/scss/opencity` 
contiene le customizzazioni e gli override delle regole scss importati in `default` e in `common`.

## Dev mode
Per poter testare gli aggiornamenti in ambienti con cache condivisa creare il file `extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/dev-mode` e rieseguire la build 

## Per aggiornare le dipendenze

Dipendenze:
- versione 2.8.4 `24d20907b` di [bootstrap-italia](https://github.com/italia/bootstrap-italia.git)
- versione 2.3.3 `65b3e12` di [design-comuni-pagine-statiche](https://github.com/italia/design-comuni-pagine-statiche.git)

Installare bootstrap-italia in una directory dedicata
```
git clone git@github.com:italia/bootstrap-italia.git
cd bootstrap-italia
npm i
```

Copiare i sorgenti nella cartella di _build:
```
cp -rv src/scss/* ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/src/scss
cp -rv src/js/* ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/src/js
cp -rv src/svg/* ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/src/svg
```

Modificare il file `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/package.json` 
per aggiornare le dipendenze

Cherry picking tra `rollup.config.js` e `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/rollup.config.js`
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
cp -rv src/stylesheets/* ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/design-comuni-pagine-statiche
cd /src/components
mkdir _export
find . -name \*.scss -exec cp {} _export \;
cp _export ${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/design-comuni-pagine-statiche
rm _export
```

Eseguire un merge di  `bootstrap-italia/src/scss/bootstrap-italia.scss` e di  `design-comuni-pagine-statiche/src/stylesheets/styles.scss` 
in `${OPENCITY_DIRECTORY}/html/extension/openpa_bootstrapitalia/design/bootstrapitalia284/_build/src/scss/default.scss` 
e verificare se ancora necessari gli override 

Aggiunta classe oc-card-title-clamp per contenere su tre righe i testi in overlay delle card image.