## Creare un nuovo tema

Per creare un nuovo schema di colori è necessario 

### Installare le dipendenze con

```
cd <document-root>/extension/openpa_bootstrapitalia

npm i
```

### Modificare il file `color-vars.scss` 
Modificare il file `<document-root>/extension/openpa_bootstrapitalia/node_modules/bootstrap-italia/src/scss/utilities/colors_vars.scss`
alle righe 202:214 aggiungendo `!default` prima del punto e virgola di ciascuna riga 

```scss
$primary-a12: hsb($primary-h, $primary-s, 20) !default;
$primary-a11: hsb($primary-h, $primary-s, 30) !default;
$primary-a10: hsb($primary-h, $primary-s, 40) !default;
$primary-a9: hsb($primary-h, $primary-s, 50) !default;
$primary-a8: hsb($primary-h, $primary-s, 60) !default;
$primary-a7: hsb($primary-h, $primary-s, 70) !default;
$primary-a6: hsb($primary-h, $primary-s, 80) !default;
$primary-a5: hsb($primary-h, $primary-s - 15, 84) !default;
$primary-a4: hsb($primary-h, $primary-s - 30, 88) !default;
$primary-a3: hsb($primary-h, $primary-s - 45, 92) !default;
$primary-a2: hsb($primary-h, $primary-s - 60, 96) !default;
$primary-a1: hsb($primary-h, $primary-s - 75, 100) !default;
```

Con questo hack è possibile modificare a piacimento i colori fondamentali del sito

### Creare un nuovo file scss 
Creare il nuovo tema in `<document-root>/extension/openpa_bootstrapitalia/src/NOME-TEMA.scss` con il codice customizzato
importando `default`

Ad esempio `elegance.scss`:
```scss
$primary-a7: #000000;
$primary-a6: #292929;
$primary-a10: #555555;
$primary-a12: #444444;

$primary-h: 0;
$primary-s: 0;
$primary-b: 3.92;

@import "default";
```

### Eseguire la build
```
cd <document-root>/extension/openpa_bootstrapitalia

gulp
```