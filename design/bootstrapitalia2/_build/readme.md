
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