# Trasparenza art. 29 "Bilanci" (C1) — Implementazione

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pubblicare lo schema ANAC art. 29 "Bilanci" (profilo C1, adesione volontaria): due dataset "valori di sintesi" (preventivo/consuntivo) installabili via `installer`, mostrati come blocco sulla pagina "Bilanci", esportati in 3 CSV (`art.29-as`, `art.29-PA-prev`, `art.29-PA-cons`) dal cron ANAC esistente.

**Architecture:** Segue esattamente il pattern già in produzione per schemi ancorati a un dataset (art.4-bis "Dati sui pagamenti", art.26-27 "Atti di concessione", appena mergeato): due oggetti `dataset` generici nell'installer, un nuovo `Art29Serializer` che legge le righe e scrive CSV con `CsvLineBuilder`, un nuovo `publishArt29()` nel cron che usa `ExportPublisher::publishSingle()` tre volte. Nessun JSON, nessuna logica di switch BDAP, nessuna modifica a classi condivise del framework Dataset.

**Tech Stack:** eZ Publish Legacy, PHP 7.4, YAML (installer `ocinstaller`), framework Dataset (`occustomfind`/`opendatadataset`).

**Spec:** `docs/superpowers/plans/2026-11-25-trasparenza-art29-bilanci-c1.md` (questo repo) — contiene tutte le decisioni prese con Marco, la tabella completa dei 48 campi reali (identificatori/etichette/descrizioni), le intestazioni CSV esatte, e i riferimenti di codice verificati. Issue di riferimento: [cms#556](https://gitlab.com/opencity-labs/sito-istituzionale/cms/-/work_items/556) (contiene la checklist di test completa, già riscritta in 6 blocchi tematici).

## Global Constraints

- Solo profilo C1, solo italiano (nessun tedesco in questo giro).
- Nessuna logica di switch BDAP/non-BDAP: il redattore gestisce il proprio caso a mano dopo l'installazione.
- Tutti i campi dei due dataset sono obbligatori (`required: true`), nessun supporto a `n/a` in questo giro — rimandato a una review con alcuni comuni.
- I due dataset vanno creati sotto "Documenti e dati > Dataset" (`$datasets_node`), MAI sotto le pagine Bilanci.
- `schema_pubblicazione` e i blocchi di visualizzazione vanno SOLO sulla pagina padre "Bilanci" (remote_id `d6ad94ccfef19c49a43fef6cef576d21`), MAI sulle sottopagine "Bilancio preventivo"/"Bilancio consuntivo" (che restano invariate).
- Nessuna validazione JSON Schema (nessuno schema pubblicato da ANAC per l'art. 29).
- Nessuna modifica di permessi/ruoli (`Editor Dataset` copre già tutto).
- Bump di versione del modulo `trasparenza-c1` SOLO come Task 8, ultimo, dopo verifica — durante lo sviluppo reinstallare con `--force`.
- Due repo: `installer` e `openpa_bootstrapitalia`, branch `trasparenza-additional-scheme-29` in entrambi, già pronti (ribasati su master aggiornato, che include già `art.26-27`/`HideExportIfEmpty`).

## Review Focus

- **Valore con `;` o a capo in un campo testo/URL** (es. `url_preventivo` con query string) — il CSV non deve spaccarsi: `CsvLineBuilder` già gestisce il quoting RFC 4180, ma va verificato con un test dedicato su questi due nuovi serializer (Task 4).
- **Un solo dei due dataset installato** (es. tenant con solo "Bilancio preventivo") — il cron deve pubblicare `art.29-as`/`art.29-PA-prev` e saltare silenziosamente `art.29-PA-cons`, senza errori (Task 5, Task 7).
- **`schema_pubblicazione` non ancora valorizzato** su un tenant che ha solo aggiornato `openpa_bootstrapitalia` ma non ancora `installer` — l'export deve comunque ancorarsi a un nodo valido (fallback al nodo di uno dei due dataset), non fallire (Task 5, già nel design del fallback).
- **`art.29-as` nascosto solo se ENTRAMBI i dataset sono vuoti**, non se solo uno dei due lo è — un errore facile da introdurre copiando la logica di art.26-27 (dove è un solo dataset) senza adattarla (Task 6, test esplicito).
- **Due annualità nello stesso dataset** devono produrre due righe distinte nell'ordine di inserimento, non una riga sovrascritta o duplicata (Task 7, verifica manuale su QA).

---

## Task 1: Installer — content model dei due dataset Bilanci

**Files:**
- Create: `installer/modules/trasparenza-c1/contents/Bilancio-preventivo-Dataset.yml`
- Create: `installer/modules/trasparenza-c1/contents/Bilancio-consuntivo-Dataset.yml`
- Modify: `installer/modules/trasparenza-c1/installer.yml` (variabile `bilanci` + due step `content`)

**Interfaces:**
- Produce: due oggetti `dataset` con remote_id `bilancio_preventivo` e `bilancio_consuntivo`, sotto il nodo `$datasets_node` ("Documenti e dati > Dataset") — questi remote_id sono usati da Task 2 (`valid_items` dei blocchi) e dal cron (Task 5, `eZContentObject::fetchByRemoteID()`).

- [ ] **Step 1: Crea `installer/modules/trasparenza-c1/contents/Bilancio-preventivo-Dataset.yml`**

```yaml
metadata:
    remoteId: bilancio_preventivo
    classIdentifier: dataset
    languages:
        - ita-IT
    parentNodes:
        - $datasets_node
data:
    ita-IT:
        title: 'Bilancio preventivo - Valori di sintesi'
        abstract: 'Questo dataset raccoglie i valori di sintesi del bilancio di previsione, un record per annualità, secondo lo schema di pubblicazione ANAC art. 29 (Allegato 9 alla Delibera 495/2024).'
        theme:
            - 'Governo e settore pubblico'
        format:
            - CSV
        license:
            - 'Creative Commons Attribution 4.0 International (CC BY 4.0)'
        csv_resource:
            apiEnabled: false
            extraUsers: null
            itemName: item
            views:
                - table
            fields:
                -
                    identifier: anno
                    label: 'Anno'
                    description: 'Anno del bilancio preventivo.'
                    type: integer
                    required: true
                    js_label: 'Anno'
                -
                    identifier: url_preventivo
                    label: 'Preventivo completo di allegati'
                    description: 'Indirizzo della pagina in cui sono pubblicati il bilancio preventivo e i suoi allegati.'
                    type: url
                    required: true
                    js_label: 'Preventivo completo di allegati'
                -
                    identifier: entrate_correnti
                    label: 'Entrate correnti previste'
                    type: amount
                    required: true
                    js_label: 'Entrate correnti previste'
                -
                    identifier: uscite_correnti
                    label: 'Uscite correnti previste'
                    type: amount
                    required: true
                    js_label: 'Uscite correnti previste'
                -
                    identifier: differenza_c_d
                    label: 'Differenza (C-D)'
                    description: 'Avanzo, disavanzo o pareggio di parte corrente previsto: entrate correnti meno uscite correnti.'
                    type: amount
                    required: true
                    js_label: 'Differenza (C-D)'
                -
                    identifier: entrate_totali
                    label: 'Entrate totali previste'
                    type: amount
                    required: true
                    js_label: 'Entrate totali previste'
                -
                    identifier: uscite_totali
                    label: 'Uscite totali previste'
                    type: amount
                    required: true
                    js_label: 'Uscite totali previste'
                -
                    identifier: differenza_f_g
                    label: 'Differenza (F-G)'
                    description: 'Avanzo, disavanzo o pareggio totale previsto: entrate totali meno uscite totali.'
                    type: amount
                    required: true
                    js_label: 'Differenza (F-G)'
                -
                    identifier: liq_crediti
                    label: 'Cassa e crediti previsti'
                    description: 'Indice di liquidità a breve.'
                    type: amount
                    required: true
                    js_label: 'Cassa e crediti previsti'
                -
                    identifier: liq_debiti
                    label: 'Debiti previsti'
                    description: 'Indice di liquidità a breve.'
                    type: amount
                    required: true
                    js_label: 'Debiti previsti'
                -
                    identifier: differenza_i_j
                    label: 'Differenza (I-J)'
                    description: 'Risultato di amministrazione previsto: cassa e crediti meno debiti.'
                    type: amount
                    required: true
                    js_label: 'Differenza (I-J)'
                -
                    identifier: cassa_crediti
                    label: 'Entrate riscosse previste'
                    description: 'Previsione di cassa.'
                    type: amount
                    required: true
                    js_label: 'Entrate riscosse previste'
                -
                    identifier: cassa_debiti
                    label: 'Uscite pagate previste'
                    description: 'Previsione di cassa.'
                    type: amount
                    required: true
                    js_label: 'Uscite pagate previste'
                -
                    identifier: differenza_l_m
                    label: 'Differenza (L-M)'
                    description: 'Saldo di cassa previsto: entrate riscosse meno uscite pagate.'
                    type: amount
                    required: true
                    js_label: 'Differenza (L-M)'
                -
                    identifier: valore_produzione
                    label: 'Valore della produzione (A) previsto'
                    description: 'Gestione caratteristica.'
                    type: amount
                    required: true
                    js_label: 'Valore della produzione (A) previsto'
                -
                    identifier: costi_produzione
                    label: 'Costi della produzione (B) previsti'
                    description: 'Gestione caratteristica.'
                    type: amount
                    required: true
                    js_label: 'Costi della produzione (B) previsti'
                -
                    identifier: differenza_o_p
                    label: 'Differenza (O-P)'
                    description: 'Differenza tra valore e costi della produzione (A-B) prevista.'
                    type: amount
                    required: true
                    js_label: 'Differenza (O-P)'
                -
                    identifier: comp_positivi_reddito
                    label: 'Componenti positivi di reddito previsti'
                    description: 'Previsione economica dell''esercizio.'
                    type: amount
                    required: true
                    js_label: 'Componenti positivi di reddito previsti'
                -
                    identifier: comp_negativi_reddito
                    label: 'Componenti negativi di reddito previsti'
                    description: 'Previsione economica dell''esercizio.'
                    type: amount
                    required: true
                    js_label: 'Componenti negativi di reddito previsti'
                -
                    identifier: differenza_r_s
                    label: 'Differenza (R-S)'
                    description: 'Utile, perdita o pareggio d''esercizio previsto.'
                    type: amount
                    required: true
                    js_label: 'Differenza (R-S)'
                -
                    identifier: url_piano_indicatori
                    label: 'Piano degli indicatori e dei risultati attesi'
                    description: 'Indirizzo del Piano degli indicatori e dei risultati attesi di bilancio per l''anno del preventivo.'
                    type: url
                    required: true
                    js_label: 'Piano degli indicatori e dei risultati attesi'
            facetsSettings:
                - anno
            isEnabledSearchInput: true
            calendarSettings: {  }
            tableSettings:
                show_fields:
                    - anno
                    - url_preventivo
                    - entrate_correnti
                    - uscite_correnti
                    - differenza_c_d
                    - entrate_totali
                    - uscite_totali
                    - differenza_f_g
                    - liq_crediti
                    - liq_debiti
                    - differenza_i_j
                    - cassa_crediti
                    - cassa_debiti
                    - differenza_l_m
                    - valore_produzione
                    - costi_produzione
                    - differenza_o_p
                    - comp_positivi_reddito
                    - comp_negativi_reddito
                    - differenza_r_s
                    - url_piano_indicatori
                view: default
            chartSettings: null
            counterSettings:
                count_field: 'false'
            openingView: table
        rights_holder:
            - site-link
        accrualperiodicity:
            - Annuale
        spatial:
            - $comune_nome
        modified: $now
        issued: $now
        language:
            - Italiano
```

- [ ] **Step 2: Crea `installer/modules/trasparenza-c1/contents/Bilancio-consuntivo-Dataset.yml`**

```yaml
metadata:
    remoteId: bilancio_consuntivo
    classIdentifier: dataset
    languages:
        - ita-IT
    parentNodes:
        - $datasets_node
data:
    ita-IT:
        title: 'Bilancio consuntivo - Valori di sintesi'
        abstract: 'Questo dataset raccoglie i valori di sintesi del bilancio consuntivo (rendiconto), un record per annualità, secondo lo schema di pubblicazione ANAC art. 29 (Allegato 9 alla Delibera 495/2024).'
        theme:
            - 'Governo e settore pubblico'
        format:
            - CSV
        license:
            - 'Creative Commons Attribution 4.0 International (CC BY 4.0)'
        csv_resource:
            apiEnabled: false
            extraUsers: null
            itemName: item
            views:
                - table
            fields:
                -
                    identifier: anno
                    label: 'Anno'
                    description: 'Anno del bilancio consuntivo (rendiconto).'
                    type: integer
                    required: true
                    js_label: 'Anno'
                -
                    identifier: url_bilancio
                    label: 'Consuntivo completo di allegati'
                    description: 'Indirizzo della pagina in cui sono pubblicati il bilancio consuntivo e i suoi allegati.'
                    type: url
                    required: true
                    js_label: 'Consuntivo completo di allegati'
                -
                    identifier: entrate_correnti
                    label: 'Entrate correnti accertate'
                    type: amount
                    required: true
                    js_label: 'Entrate correnti accertate'
                -
                    identifier: uscite_correnti
                    label: 'Uscite correnti impegnate'
                    type: amount
                    required: true
                    js_label: 'Uscite correnti impegnate'
                -
                    identifier: differenza_c_d
                    label: 'Differenza (C-D)'
                    description: 'Avanzo, disavanzo o pareggio di parte corrente: entrate correnti meno uscite correnti.'
                    type: amount
                    required: true
                    js_label: 'Differenza (C-D)'
                -
                    identifier: entrate_totali
                    label: 'Entrate totali accertate'
                    type: amount
                    required: true
                    js_label: 'Entrate totali accertate'
                -
                    identifier: uscite_totali
                    label: 'Uscite totali impegnate'
                    type: amount
                    required: true
                    js_label: 'Uscite totali impegnate'
                -
                    identifier: differenza_f_g
                    label: 'Differenza (F-G)'
                    description: 'Avanzo, disavanzo o pareggio totale: entrate totali meno uscite totali.'
                    type: amount
                    required: true
                    js_label: 'Differenza (F-G)'
                -
                    identifier: liq_crediti
                    label: 'Cassa e crediti'
                    description: 'Indice di liquidità a breve.'
                    type: amount
                    required: true
                    js_label: 'Cassa e crediti'
                -
                    identifier: liq_debiti
                    label: 'Debiti'
                    description: 'Indice di liquidità a breve.'
                    type: amount
                    required: true
                    js_label: 'Debiti'
                -
                    identifier: differenza_i_j
                    label: 'Differenza (I-J)'
                    description: 'Risultato di amministrazione: cassa e crediti meno debiti.'
                    type: amount
                    required: true
                    js_label: 'Differenza (I-J)'
                -
                    identifier: cassa_crediti
                    label: 'Entrate riscosse'
                    description: 'Gestione di cassa.'
                    type: amount
                    required: true
                    js_label: 'Entrate riscosse'
                -
                    identifier: cassa_debiti
                    label: 'Uscite pagate'
                    description: 'Gestione di cassa.'
                    type: amount
                    required: true
                    js_label: 'Uscite pagate'
                -
                    identifier: differenza_l_m
                    label: 'Differenza (L-M)'
                    description: 'Saldo di cassa: entrate riscosse meno uscite pagate.'
                    type: amount
                    required: true
                    js_label: 'Differenza (L-M)'
                -
                    identifier: valore_produzione
                    label: 'Valore della produzione (A)'
                    description: 'Conto economico, gestione caratteristica.'
                    type: amount
                    required: true
                    js_label: 'Valore della produzione (A)'
                -
                    identifier: costi_produzione
                    label: 'Costi della produzione (B)'
                    description: 'Conto economico, gestione caratteristica.'
                    type: amount
                    required: true
                    js_label: 'Costi della produzione (B)'
                -
                    identifier: differenza_p_q
                    label: 'Differenza (P-Q)'
                    description: 'Differenza tra valore e costi della produzione (A-B). L''etichetta riprende quella dello schema ANAC.'
                    type: amount
                    required: true
                    js_label: 'Differenza (P-Q)'
                -
                    identifier: comp_positivi_reddito
                    label: 'Componenti positivi di reddito'
                    description: 'Conto economico dell''esercizio.'
                    type: amount
                    required: true
                    js_label: 'Componenti positivi di reddito'
                -
                    identifier: comp_negativi_reddito
                    label: 'Componenti negativi di reddito'
                    description: 'Conto economico dell''esercizio.'
                    type: amount
                    required: true
                    js_label: 'Componenti negativi di reddito'
                -
                    identifier: differenza_r_s
                    label: 'Differenza (R-S)'
                    description: 'Utile, perdita o pareggio d''esercizio.'
                    type: amount
                    required: true
                    js_label: 'Differenza (R-S)'
                -
                    identifier: totale_attivo
                    label: 'Totale attivo'
                    description: 'Stato patrimoniale.'
                    type: amount
                    required: true
                    js_label: 'Totale attivo'
                -
                    identifier: totale_passivo
                    label: 'Totale passivo'
                    description: 'Stato patrimoniale, esclusi il patrimonio netto.'
                    type: amount
                    required: true
                    js_label: 'Totale passivo'
                -
                    identifier: patrimonio_netto_u_v
                    label: 'Patrimonio netto (U-V)'
                    description: 'Totale attivo meno totale passivo.'
                    type: amount
                    required: true
                    js_label: 'Patrimonio netto (U-V)'
                -
                    identifier: contributi_pubblici
                    label: 'Contributi pubblici'
                    description: 'Contributi ricevuti da pubbliche amministrazioni.'
                    type: amount
                    required: true
                    js_label: 'Contributi pubblici'
                -
                    identifier: contributi_totali
                    label: 'Contributi totali'
                    description: 'Totale dei contributi ricevuti.'
                    type: amount
                    required: true
                    js_label: 'Contributi totali'
                -
                    identifier: perc_contribuzione_pubblica
                    label: 'Percentuale di contribuzione pubblica'
                    description: 'Contributi pubblici sul totale dei contributi.'
                    type: percentage
                    required: true
                    js_label: 'Percentuale di contribuzione pubblica'
                -
                    identifier: url_piano_indicatori
                    label: 'Piano degli indicatori e dei risultati di bilancio'
                    description: 'Indirizzo del Piano degli indicatori e dei risultati di bilancio allegato al rendiconto.'
                    type: url
                    required: true
                    js_label: 'Piano degli indicatori e dei risultati di bilancio'
            facetsSettings:
                - anno
            isEnabledSearchInput: true
            calendarSettings: {  }
            tableSettings:
                show_fields:
                    - anno
                    - url_bilancio
                    - entrate_correnti
                    - uscite_correnti
                    - differenza_c_d
                    - entrate_totali
                    - uscite_totali
                    - differenza_f_g
                    - liq_crediti
                    - liq_debiti
                    - differenza_i_j
                    - cassa_crediti
                    - cassa_debiti
                    - differenza_l_m
                    - valore_produzione
                    - costi_produzione
                    - differenza_p_q
                    - comp_positivi_reddito
                    - comp_negativi_reddito
                    - differenza_r_s
                    - totale_attivo
                    - totale_passivo
                    - patrimonio_netto_u_v
                    - contributi_pubblici
                    - contributi_totali
                    - perc_contribuzione_pubblica
                    - url_piano_indicatori
                view: default
            chartSettings: null
            counterSettings:
                count_field: 'false'
            openingView: table
        rights_holder:
            - site-link
        accrualperiodicity:
            - Annuale
        spatial:
            - $comune_nome
        modified: $now
        issued: $now
        language:
            - Italiano
```

- [ ] **Step 3: Aggiungi la variabile `bilanci` in `installer/modules/trasparenza-c1/installer.yml`**

Nella sezione `variables:`, subito dopo `dati_sui_pagamenti` (circa riga 43):

```yaml
    -   name: dati_sui_pagamenti
        value: 47dd6ba753c3ad8963279dea8d8d1835
    -   name: bilanci
        value: d6ad94ccfef19c49a43fef6cef576d21
```

- [ ] **Step 4: Aggiungi i due step `content` in `installer/modules/trasparenza-c1/installer.yml`**

Subito dopo lo step `Dati-sui-pagamenti-Dataset` (circa riga 129):

```yaml
    -   type: content
        identifier: Dati-sui-pagamenti-Dataset
        update: true

    -   type: content
        identifier: Bilancio-preventivo-Dataset
        update: true

    -   type: content
        identifier: Bilancio-consuntivo-Dataset
        update: true
```

- [ ] **Step 5: Verifica manuale (nessun test automatico — step installer, richiede kernel eZ)**

Reinstallare il modulo su un tenant Boat QA di sviluppo (`--force`, non bump — vedi Global Constraints):

```bash
php html/vendor/bin/ocinstall -s <IDENTIFIER>_backend path/to/installer/modules/trasparenza-c1/ --force
```

Verificare dal backend che i due oggetti dataset esistano sotto "Documenti e dati > Dataset", con tutti i campi (21 per preventivo, 27 per consuntivo), etichette e descrizioni corrette, tutti obbligatori.

- [ ] **Step 6: Commit**

```bash
git add modules/trasparenza-c1/contents/Bilancio-preventivo-Dataset.yml modules/trasparenza-c1/contents/Bilancio-consuntivo-Dataset.yml modules/trasparenza-c1/installer.yml
git commit -m "feat: aggiunge i dataset Bilancio preventivo/consuntivo (art.29, cms#556)"
```

---

## Task 2: Installer — `schema_pubblicazione` + blocchi "Singolo" sulla pagina "Bilanci"

**Files:**
- Modify: `installer/modules/trasparenza/classes/pagina_trasparenza.yml` (ezselection XML, nuove opzioni)
- Modify: `installer/modules/trasparenza-c1/installer.yml` (patch_content su `$bilanci`)

**Interfaces:**
- Consuma: remote_id `bilancio_preventivo`/`bilancio_consuntivo` (Task 1), variabile `$bilanci` (Task 1).
- Produce: opzioni ezselection id 22/23/24 per `art.29-as`/`art.29-PA-prev`/`art.29-PA-cons` — consumate da `SchemaPubblicazioneLookup::OPTION_IDS` (Task 3, DEVONO restare sincronizzate, stessi id).

**⚠️ Rischio noto**: il branch `installer` `trasparenza-additional-scheme-26-27` (non ancora mergeato) probabilmente aggiunge anch'esso opzioni 22-25 a questo stesso file XML per i propri schemi — quando verrà mergeato ci sarà un conflitto di id da risolvere a mano (rinumerare uno dei due gruppi). Non bloccante ora, da segnalare a chi fa il merge.

- [ ] **Step 1: Aggiungi le 3 nuove opzioni all'ezselection in `installer/modules/trasparenza/classes/pagina_trasparenza.yml`**

Nel campo `data_text5` dell'attributo `schema_pubblicazione` (circa riga 241), il valore XML termina con `<option id="21" name="art.20-c2"/></options>` — sostituire con:

```xml
<option id="21" name="art.20-c2"/><option id="22" name="art.29-as"/><option id="23" name="art.29-PA-prev"/><option id="24" name="art.29-PA-cons"/></options>
```

(l'intera riga `data_text5` resta una singola stringa YAML, solo questo frammento finale cambia)

- [ ] **Step 2: Aggiungi il `patch_content` su `$bilanci` in `installer/modules/trasparenza-c1/installer.yml`**

Dopo lo step `patch_content` per `$dati_sui_pagamenti` (circa riga 276, prima del commento "Il contenttree di queste due pagine..."):

```yaml
    -   type: patch_content
        identifier: $bilanci
        ignore_error: true
        attributes:
            schema_pubblicazione:
                - art.29-as
                - art.29-PA-prev
                - art.29-PA-cons
            fields_blocks:
                zone_layout: desItaGlobal
                global:
                    zone_id: bilanci.zone
                    blocks:
                        -   block_id: bilancio.preventivo.dataset
                            name: ''
                            type: Singolo
                            view: default
                            valid_items:
                                - bilancio_preventivo
                            custom_attributes:
                                color_style: ''
                                container_style: ''
                                intro_text: ''
                        -   block_id: bilancio.consuntivo.dataset
                            name: ''
                            type: Singolo
                            view: default
                            valid_items:
                                - bilancio_consuntivo
                            custom_attributes:
                                color_style: ''
                                container_style: ''
                                intro_text: ''
```

- [ ] **Step 3: Verifica manuale**

Reinstallare con `--force`, aprire la pagina "Bilanci" (`/Amministrazione-Trasparente/Bilanci`) e verificare che mostri DUE blocchi (uno per dataset, vista nativa con tabella + "Aggiungi record" + "Download CSV"). Verificare che le sottopagine "Bilancio preventivo"/"Bilancio consuntivo" siano rimaste invariate (solo Documenti).

- [ ] **Step 4: Commit**

```bash
git add modules/trasparenza/classes/pagina_trasparenza.yml modules/trasparenza-c1/installer.yml
git commit -m "feat: valorizza schema_pubblicazione e aggiunge i blocchi dataset sulla pagina Bilanci (art.29, cms#556)"
```

---

## Task 3: openpa_bootstrapitalia — `SchemaPubblicazioneLookup` + traduzioni

**Files:**
- Modify: `classes/SchemaPubblicazioneLookup.php`
- Modify: `translations/ita-IT/translation.ts`

**Interfaces:**
- Consuma: id 22/23/24 (Task 2, DEVONO combaciare esattamente).
- Produce: `SchemaPubblicazioneLookup::labelForSchema('art.29-PA-prev')` ecc. — usato da `content_trasparenza.php::getAnacExports()` (già esistente, nessuna modifica necessaria lì oltre Task 6) per mostrare l'etichetta nel blocco "Schemi pubblicazione ANAC".

- [ ] **Step 1: Estendi `OPTION_IDS` in `classes/SchemaPubblicazioneLookup.php`**

```php
    const OPTION_IDS = [
        // ... voci esistenti invariate ...
        'art.26-27-criteri' => 22,
        'art.26-27-atti-concessione' => 23,
        'art.26-27-atto-revoca' => 24,
        'art.26-27-atti' => 25,
        'art.29-as' => 26,
        'art.29-PA-prev' => 27,
        'art.29-PA-cons' => 28,
    ];
```

- [ ] **Step 2: Estendi `LABELS` in `classes/SchemaPubblicazioneLookup.php`**

```php
    const LABELS = [
        // ... voci esistenti invariate ...
        'art.26-27-atti' => 'Grant acts',
        'art.29-as' => 'Subjective scope',
        'art.29-PA-prev' => 'Draft budget',
        'art.29-PA-cons' => 'Final budget',
    ];
```

(`'art.29-as' => 'Subjective scope'` riusa la stessa stringa sorgente di `art.13-as` — già tradotta "Ambito soggettivo" in `translations/ita-IT/translation.ts`, nessuna nuova voce necessaria per questa.)

- [ ] **Step 2b: Aggiungi 2 nuove traduzioni in `translations/ita-IT/translation.ts`**

Nel blocco `<context><name>bootstrapitalia/anac_export</name>...</context>` (cercare `<name>bootstrapitalia/anac_export</name>`), subito prima del tag `</context>` di chiusura di quel blocco (dopo l'ultimo `<message>` esistente, quello di "Grant revocation acts"):

```xml
    <message>
      <source>Draft budget</source>
      <translation>Bilancio preventivo</translation>
    </message>
    <message>
      <source>Final budget</source>
      <translation>Bilancio consuntivo</translation>
    </message>
```

**Non usare `php vendor/bin/oci18n -r`** per questo — editare l'XML direttamente (vedi root `CLAUDE.md`, sezione i18n: il pull può cancellare traduzioni preesistenti non correlate). Dopo l'edit, verificare con `git diff --stat` che siano cambiate solo le righe attese.

- [ ] **Step 3: Verifica (nessun test automatico dedicato — copertura tramite Task 7)**

```bash
docker exec sito-comunale-dev-app-1 php bin/php/ezcache.php --clear-all
docker exec sito-comunale-dev-app-1 php -r '
require_once "autoload.php";
$script = eZScript::instance(["description" => "check i18n"]);
$script->startup(); $script->initialize();
echo ezpI18n::tr("bootstrapitalia/anac_export", "Draft budget") . "\n";
echo ezpI18n::tr("bootstrapitalia/anac_export", "Final budget") . "\n";
$script->shutdown();
'
```

Atteso: `Bilancio preventivo` e `Bilancio consuntivo`.

- [ ] **Step 4: Commit**

```bash
git add classes/SchemaPubblicazioneLookup.php translations/ita-IT/translation.ts
git commit -m "feat: aggiunge gli identificativi di schema art.29 a SchemaPubblicazioneLookup"
```

---

## Task 4: openpa_bootstrapitalia — `Art29Serializer` + test puro

**Files:**
- Create: `classes/anac/Serializer/Art29Serializer.php`
- Create: `tests/test_art29_serializer.php`

**Interfaces:**
- Consuma: `\OpenPABootstrapItalia\Anac\CsvLineBuilder::line()` (esistente).
- Produce: `Art29Serializer::SCHEMA_IDENTIFIER_AS`/`SCHEMA_IDENTIFIER_PA_PREV`/`SCHEMA_IDENTIFIER_PA_CONS` (costanti, usate da Task 5 e Task 6), metodi pubblici `toCsvAs()`, `toCsvPreventivo()`, `toCsvConsuntivo()` (usati da Task 5), costruttore `__construct(?eZContentObjectAttribute $preventivoAttribute, ?eZContentObjectAttribute $consuntivoAttribute)`.

- [ ] **Step 1: Crea `classes/anac/Serializer/Art29Serializer.php`**

```php
<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

/**
 * art. 29 d.lgs. 33/2013 - Bilanci (cms#556), schema ad adesione volontaria,
 * profilo C1, per gli enti che NON trasmettono a BDAP. Due dataset content
 * object distinti (classe dataset, csv_resource, remote_id
 * bilancio_preventivo/bilancio_consuntivo) - stesso pattern di
 * Art2627Serializer, un solo serializzatore per entrambe le sotto-sezioni,
 * piu' il file costante art.29-as (ambito soggettivo, nessun dato da
 * dataset).
 *
 * Nessun JSON: la Guida Online ANAC non pubblica uno schema JSON per questo
 * articolo (verificato: art.29-v1.0.schema.json risponde 404), solo 3 CSV.
 *
 * I campi importo/percentuale dei due dataset sono gia' normalizzati al
 * formato ANAC dal framework Dataset stesso (OpendataDatasetNumberNormalizer,
 * occustomfind) al momento del salvataggio (form, API, import) - a
 * differenza di art.4-bis/art.26-27 (dove i campi importo sono ancora type
 * "string" e la normalizzazione avviene nel serializer via
 * ImportoNormalizer), qui NON serve richiamare nessun normalizzatore: il
 * dato arriva gia' pronto, un trim() basta.
 */
class Art29Serializer
{
    const SCHEMA_IDENTIFIER_AS = 'art.29-as';
    const SCHEMA_IDENTIFIER_PA_PREV = 'art.29-PA-prev';
    const SCHEMA_IDENTIFIER_PA_CONS = 'art.29-PA-cons';

    const AMBITO_SOGGETTIVO = 'Pubbliche amministrazioni in contabilità finanziaria';

    /** @var \eZContentObjectAttribute|null */
    private $preventivoAttribute;

    /** @var \eZContentObjectAttribute|null */
    private $consuntivoAttribute;

    /**
     * Entrambi gli argomenti sono nullable, stesso motivo di
     * Art2627Serializer: i due dataset sono installati come content
     * indipendenti, ciascuno puo' mancare su un sito senza impedire
     * all'altro di funzionare (e senza impedire la pubblicazione di
     * art.29-as, che non dipende da nessuno dei due).
     */
    public function __construct(
        \eZContentObjectAttribute $preventivoAttribute = null,
        \eZContentObjectAttribute $consuntivoAttribute = null
    ) {
        $this->preventivoAttribute = $preventivoAttribute;
        $this->consuntivoAttribute = $consuntivoAttribute;
    }

    private function fetchRighe(\eZContentObjectAttribute $attribute)
    {
        $repository = new \OpendataDatasetSearchableRepository($attribute);
        $total = $repository->countSearchableObjects();

        $rows = [];
        $limit = 200;
        $offset = 0;
        while ($offset < $total) {
            foreach ($repository->fetchSearchableObjectList($limit, $offset) as $searchableObject) {
                $rows[] = $searchableObject->getDataset()->getData();
            }
            $offset += $limit;
        }

        return $rows;
    }

    public function fetchRighePreventivo()
    {
        return $this->preventivoAttribute !== null ? $this->fetchRighe($this->preventivoAttribute) : [];
    }

    public function fetchRigheConsuntivo()
    {
        return $this->consuntivoAttribute !== null ? $this->fetchRighe($this->consuntivoAttribute) : [];
    }

    /**
     * Mapping riga->colonne per art.29-PA-prev, nell'ordine ESATTO del CSV
     * ANAC (issue cms#556). Field identifier verificati dal vivo su QA
     * (non derivati per analogia) - vedi il design doc, Appendice.
     *
     * @return string[] 21 colonne, stesso ordine dell'intestazione di toCsvPreventivo()
     */
    private function mapRigaPreventivo(array $data)
    {
        return [
            trim((string)$data['anno']),
            trim((string)$data['url_preventivo']),
            trim((string)$data['entrate_correnti']),
            trim((string)$data['uscite_correnti']),
            trim((string)$data['differenza_c_d']),
            trim((string)$data['entrate_totali']),
            trim((string)$data['uscite_totali']),
            trim((string)$data['differenza_f_g']),
            trim((string)$data['liq_crediti']),
            trim((string)$data['liq_debiti']),
            trim((string)$data['differenza_i_j']),
            trim((string)$data['cassa_crediti']),
            trim((string)$data['cassa_debiti']),
            trim((string)$data['differenza_l_m']),
            trim((string)$data['valore_produzione']),
            trim((string)$data['costi_produzione']),
            trim((string)$data['differenza_o_p']),
            trim((string)$data['comp_positivi_reddito']),
            trim((string)$data['comp_negativi_reddito']),
            trim((string)$data['differenza_r_s']),
            trim((string)$data['url_piano_indicatori']),
        ];
    }

    /**
     * Mapping riga->colonne per art.29-PA-cons. Attenzione alle 3
     * corrispondenze non deducibili dal nome (segnalate da Marco
     * sull'issue): `url_bilancio` -> colonna URL_BILANCIO (non
     * URL_CONSUNTIVO), `differenza_p_q` -> colonna "DIFFERENZA (P-Q)",
     * `patrimonio_netto_u_v` -> colonna "PATRIMONIO_NETTO (U-V)".
     *
     * @return string[] 27 colonne, stesso ordine dell'intestazione di toCsvConsuntivo()
     */
    private function mapRigaConsuntivo(array $data)
    {
        return [
            trim((string)$data['anno']),
            trim((string)$data['url_bilancio']),
            trim((string)$data['entrate_correnti']),
            trim((string)$data['uscite_correnti']),
            trim((string)$data['differenza_c_d']),
            trim((string)$data['entrate_totali']),
            trim((string)$data['uscite_totali']),
            trim((string)$data['differenza_f_g']),
            trim((string)$data['liq_crediti']),
            trim((string)$data['liq_debiti']),
            trim((string)$data['differenza_i_j']),
            trim((string)$data['cassa_crediti']),
            trim((string)$data['cassa_debiti']),
            trim((string)$data['differenza_l_m']),
            trim((string)$data['valore_produzione']),
            trim((string)$data['costi_produzione']),
            trim((string)$data['differenza_p_q']),
            trim((string)$data['comp_positivi_reddito']),
            trim((string)$data['comp_negativi_reddito']),
            trim((string)$data['differenza_r_s']),
            trim((string)$data['totale_attivo']),
            trim((string)$data['totale_passivo']),
            trim((string)$data['patrimonio_netto_u_v']),
            trim((string)$data['contributi_pubblici']),
            trim((string)$data['contributi_totali']),
            trim((string)$data['perc_contribuzione_pubblica']),
            trim((string)$data['url_piano_indicatori']),
        ];
    }

    /**
     * @return string sempre valorizzato con la costante di questo profilo
     *         (C1) - non dipende da nessun dataset, una sola riga di dato.
     */
    public function toCsvAs()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line(['AMBITO_SOGGETTIVO'])];
        $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([self::AMBITO_SOGGETTIVO]);

        return implode("\n", $lines) . "\n";
    }

    public function toCsvPreventivo()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
            'ANNO', 'URL_PREVENTIVO', 'ENTRATE_CORRENTI', 'USCITE_CORRENTI', 'DIFFERENZA (C-D)',
            'ENTRATE_TOTALI', 'USCITE_TOTALI', 'DIFFERENZA (F-G)', 'LIQ_CREDITI', 'LIQ_DEBITI',
            'DIFFERENZA (I-J)', 'CASSA_CREDITI', 'CASSA_DEBITI', 'DIFFERENZA (L-M)',
            'VALORE_PRODUZIONE', 'COSTI_PRODUZIONE', 'DIFFERENZA (O-P)', 'COMP_POSITIVI_REDDITO',
            'COMP_NEGATIVI_REDDITO', 'DIFFERENZA (R-S)', 'URL_PIANO_INDICATORI',
        ])];

        foreach ($this->fetchRighePreventivo() as $data) {
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line($this->mapRigaPreventivo($data));
        }

        return implode("\n", $lines) . "\n";
    }

    public function toCsvConsuntivo()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
            'ANNO', 'URL_BILANCIO', 'ENTRATE_CORRENTI', 'USCITE_CORRENTI', 'DIFFERENZA (C-D)',
            'ENTRATE_TOTALI', 'USCITE_TOTALI', 'DIFFERENZA (F-G)', 'LIQ_CREDITI', 'LIQ_DEBITI',
            'DIFFERENZA (I-J)', 'CASSA_CREDITI', 'CASSA_DEBITI', 'DIFFERENZA (L-M)',
            'VALORE_PRODUZIONE', 'COSTI_PRODUZIONE', 'DIFFERENZA (P-Q)', 'COMP_POSITIVI_REDDITO',
            'COMP_NEGATIVI_REDDITO', 'DIFFERENZA (R-S)', 'TOTALE_ATTIVO', 'TOTALE_PASSIVO',
            'PATRIMONIO_NETTO (U-V)', 'CONTRIBUTI_PUBBLICI', 'CONTRIBUTI_TOTALI',
            'PERC_CONTRIBUZIONE_PUBBLICA', 'URL_PIANO_INDICATORI',
        ])];

        foreach ($this->fetchRigheConsuntivo() as $data) {
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line($this->mapRigaConsuntivo($data));
        }

        return implode("\n", $lines) . "\n";
    }
}
```

- [ ] **Step 2: Crea `tests/test_art29_serializer.php`**

```php
<?php
/**
 * Test di Art29Serializer (logica pura, nessun kernel eZ): intestazioni CSV
 * esatte, costante art.29-as, mapping riga->colonna per preventivo/consuntivo
 * incluse le 3 corrispondenze non deducibili dal nome (url_preventivo,
 * url_bilancio, differenza_p_q/patrimonio_netto_u_v) - vedi issue cms#556.
 * toCsvPreventivo()/toCsvConsuntivo() senza attributo passato al costruttore
 * restituiscono solo l'intestazione (fetchRighe*() ritorna [] se l'attributo
 * e' null, nessuna query, nessun kernel necessario) - stesso principio di
 * test_art2627_criteri.php.
 * Run: php tests/test_art29_serializer.php
 */

require __DIR__ . '/../classes/anac/CsvLineBuilder.php';
require __DIR__ . '/../classes/anac/Serializer/Art29Serializer.php';

use OpenPABootstrapItalia\Anac\Serializer\Art29Serializer;

$passed = 0;
$failed = 0;
function check($label, $expected, $actual)
{
    global $passed, $failed;
    if ($expected === $actual) {
        $passed++;
        return;
    }
    $failed++;
    echo "FAIL $label\n  atteso:   " . var_export($expected, true) . "\n  ottenuto: " . var_export($actual, true) . "\n";
}

$serializer = new Art29Serializer();

// --- art.29-as: costante, nessun dataset ---
check(
    'toCsvAs() intestazione + valore costante',
    "AMBITO_SOGGETTIVO\nPubbliche amministrazioni in contabilità finanziaria\n",
    $serializer->toCsvAs()
);

// --- intestazioni CSV esatte, senza righe (nessun attributo al costruttore) ---
$headerPrev = "ANNO;URL_PREVENTIVO;ENTRATE_CORRENTI;USCITE_CORRENTI;DIFFERENZA (C-D);ENTRATE_TOTALI;USCITE_TOTALI;DIFFERENZA (F-G);LIQ_CREDITI;LIQ_DEBITI;DIFFERENZA (I-J);CASSA_CREDITI;CASSA_DEBITI;DIFFERENZA (L-M);VALORE_PRODUZIONE;COSTI_PRODUZIONE;DIFFERENZA (O-P);COMP_POSITIVI_REDDITO;COMP_NEGATIVI_REDDITO;DIFFERENZA (R-S);URL_PIANO_INDICATORI\n";
check('toCsvPreventivo() intestazione esatta (nessuna riga)', $headerPrev, $serializer->toCsvPreventivo());

$headerCons = "ANNO;URL_BILANCIO;ENTRATE_CORRENTI;USCITE_CORRENTI;DIFFERENZA (C-D);ENTRATE_TOTALI;USCITE_TOTALI;DIFFERENZA (F-G);LIQ_CREDITI;LIQ_DEBITI;DIFFERENZA (I-J);CASSA_CREDITI;CASSA_DEBITI;DIFFERENZA (L-M);VALORE_PRODUZIONE;COSTI_PRODUZIONE;DIFFERENZA (P-Q);COMP_POSITIVI_REDDITO;COMP_NEGATIVI_REDDITO;DIFFERENZA (R-S);TOTALE_ATTIVO;TOTALE_PASSIVO;PATRIMONIO_NETTO (U-V);CONTRIBUTI_PUBBLICI;CONTRIBUTI_TOTALI;PERC_CONTRIBUZIONE_PUBBLICA;URL_PIANO_INDICATORI\n";
check('toCsvConsuntivo() intestazione esatta (nessuna riga)', $headerCons, $serializer->toCsvConsuntivo());

// --- mapRigaPreventivo()/mapRigaConsuntivo() via Reflection: mapping riga->colonna ---
$ref = new ReflectionClass(Art29Serializer::class);
$mapPrev = $ref->getMethod('mapRigaPreventivo');
$mapPrev->setAccessible(true);
$mapCons = $ref->getMethod('mapRigaConsuntivo');
$mapCons->setAccessible(true);

$rigaPrev = $mapPrev->invoke($serializer, [
    'anno' => '2024',
    'url_preventivo' => 'https://esempio.it/preventivo-2024',
    'entrate_correnti' => '4.850.000,00',
    'uscite_correnti' => '4.720.500,00',
    'differenza_c_d' => '129.500,00',
    'entrate_totali' => '5.000.000,00',
    'uscite_totali' => '4.900.000,00',
    'differenza_f_g' => '100.000,00',
    'liq_crediti' => '1.000,00',
    'liq_debiti' => '500,00',
    'differenza_i_j' => '500,00',
    'cassa_crediti' => '900,00',
    'cassa_debiti' => '400,00',
    'differenza_l_m' => '500,00',
    'valore_produzione' => '10.000,00',
    'costi_produzione' => '9.000,00',
    'differenza_o_p' => '1.000,00',
    'comp_positivi_reddito' => '2.000,00',
    'comp_negativi_reddito' => '1.500,00',
    'differenza_r_s' => '500,00',
    'url_piano_indicatori' => 'https://esempio.it/piano-indicatori',
]);
check('mapRigaPreventivo() numero di colonne', 21, count($rigaPrev));
check('mapRigaPreventivo() anno in colonna 1', '2024', $rigaPrev[0]);
check('mapRigaPreventivo() url_preventivo in colonna 2 (URL_PREVENTIVO)', 'https://esempio.it/preventivo-2024', $rigaPrev[1]);
check('mapRigaPreventivo() url_piano_indicatori in ultima colonna', 'https://esempio.it/piano-indicatori', $rigaPrev[20]);

$rigaCons = $mapCons->invoke($serializer, [
    'anno' => '2023',
    'url_bilancio' => 'https://esempio.it/consuntivo-2023',
    'entrate_correnti' => '4.912.340,55',
    'uscite_correnti' => '4.698.120,30',
    'differenza_c_d' => '214.220,25',
    'entrate_totali' => '5.000.000,00',
    'uscite_totali' => '4.900.000,00',
    'differenza_f_g' => '100.000,00',
    'liq_crediti' => '1.000,00',
    'liq_debiti' => '500,00',
    'differenza_i_j' => '500,00',
    'cassa_crediti' => '900,00',
    'cassa_debiti' => '400,00',
    'differenza_l_m' => '500,00',
    'valore_produzione' => '10.000,00',
    'costi_produzione' => '9.000,00',
    'differenza_p_q' => '1.000,00',
    'comp_positivi_reddito' => '2.000,00',
    'comp_negativi_reddito' => '1.500,00',
    'differenza_r_s' => '500,00',
    'totale_attivo' => '50.000,00',
    'totale_passivo' => '30.000,00',
    'patrimonio_netto_u_v' => '20.000,00',
    'contributi_pubblici' => '5.000,00',
    'contributi_totali' => '10.000,00',
    'perc_contribuzione_pubblica' => '50',
    'url_piano_indicatori' => 'https://esempio.it/piano-indicatori-2023',
]);
check('mapRigaConsuntivo() numero di colonne', 27, count($rigaCons));
check('mapRigaConsuntivo() url_bilancio in colonna 2 (URL_BILANCIO, non URL_CONSUNTIVO)', 'https://esempio.it/consuntivo-2023', $rigaCons[1]);
check('mapRigaConsuntivo() differenza_p_q in colonna 17 (DIFFERENZA (P-Q))', '1.000,00', $rigaCons[16]);
check('mapRigaConsuntivo() patrimonio_netto_u_v in colonna 23 (PATRIMONIO_NETTO (U-V))', '20.000,00', $rigaCons[22]);
check('mapRigaConsuntivo() url_piano_indicatori in ultima colonna', 'https://esempio.it/piano-indicatori-2023', $rigaCons[26]);

// --- Review Focus: un valore con ";" non deve spaccare il CSV (CsvLineBuilder, RFC 4180) ---
$rigaConPuntoVirgola = $mapPrev->invoke($serializer, [
    'anno' => '2024',
    'url_preventivo' => 'https://esempio.it/preventivo?a=1;b=2',
    'entrate_correnti' => '1.000,00',
    'uscite_correnti' => '1.000,00',
    'differenza_c_d' => '0,00',
    'entrate_totali' => '1.000,00',
    'uscite_totali' => '1.000,00',
    'differenza_f_g' => '0,00',
    'liq_crediti' => '0,00',
    'liq_debiti' => '0,00',
    'differenza_i_j' => '0,00',
    'cassa_crediti' => '0,00',
    'cassa_debiti' => '0,00',
    'differenza_l_m' => '0,00',
    'valore_produzione' => '0,00',
    'costi_produzione' => '0,00',
    'differenza_o_p' => '0,00',
    'comp_positivi_reddito' => '0,00',
    'comp_negativi_reddito' => '0,00',
    'differenza_r_s' => '0,00',
    'url_piano_indicatori' => 'https://esempio.it/piano',
]);
$rigaCsv = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line($rigaConPuntoVirgola);
check('un valore con ";" viene racchiuso tra virgolette (CsvLineBuilder)', true, strpos($rigaCsv, '"https://esempio.it/preventivo?a=1;b=2"') !== false);
// 21 campi -> 20 separatori reali + 1 ";" letterale dentro il valore quotato = 21 totali nella riga
check('il ";" dentro il valore quotato non introduce un campo in più (21 campi = 20 separatori + 1 interno)', 21, substr_count($rigaCsv, ';'));

echo "\nPassed: $passed, Failed: $failed\n";
exit($failed > 0 ? 1 : 0);
```

- [ ] **Step 3: Esegui il test e verifica che passi**

Run: `php tests/test_art29_serializer.php`
Expected: `Passed: <N>, Failed: 0` (nessuna riga `FAIL` in output)

- [ ] **Step 4: Commit**

```bash
git add classes/anac/Serializer/Art29Serializer.php tests/test_art29_serializer.php
git commit -m "feat: aggiunge Art29Serializer (Bilanci, art.29, cms#556)"
```

---

## Task 5: openpa_bootstrapitalia — registrazione nel cron (`publishArt29`)

**Files:**
- Modify: `cronjobs/anac_export.php`

**Interfaces:**
- Consuma: `Art29Serializer` (Task 4), remote_id `bilancio_preventivo`/`bilancio_consuntivo` (Task 1), `SchemaPubblicazioneLookup::OPTION_IDS['art.29-as']` ecc. (Task 3, tramite `$schemaBindings`), `ExportPublisher::publishSingle()` (esistente).
- Produce: tre file pubblicati, raggiungibili da Task 7 per la verifica manuale.

- [ ] **Step 1: Aggiungi la funzione `publishArt29()` in `cronjobs/anac_export.php`**

Subito dopo la fine di `publishArt2627()` (dopo la sua chiusura `}`):

```php
function publishArt29(eZCLI $cli, array $schemaBindings)
{
    $preventivoObject = eZContentObject::fetchByRemoteID('bilancio_preventivo');
    $consuntivoObject = eZContentObject::fetchByRemoteID('bilancio_consuntivo');
    if (!$preventivoObject instanceof eZContentObject && !$consuntivoObject instanceof eZContentObject) {
        // Caso normale per la maggioranza dei tenant: schema opzionale,
        // modulo trasparenza-c1 non aggiornato a questa versione su questo
        // sito (o "Schemi di pubblicazione non obbligatori" non attivato).
        // Nota: `&&`, non `||` - uno dei due dataset puo' mancare senza che
        // sia questo caso (vedi Review Focus del piano).
        return;
    }

    $preventivoAttribute = null;
    if ($preventivoObject instanceof eZContentObject) {
        $preventivoDataMap = $preventivoObject->fetchDataMap(false, SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        $preventivoAttribute = $preventivoDataMap['csv_resource'] ?? null;
        if ($preventivoAttribute === null) {
            $cli->error('anac_export: attributo csv_resource non trovato sul dataset Bilancio preventivo, schema art.29-PA-prev saltato');
        }
    }

    $consuntivoAttribute = null;
    if ($consuntivoObject instanceof eZContentObject) {
        $consuntivoDataMap = $consuntivoObject->fetchDataMap(false, SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        $consuntivoAttribute = $consuntivoDataMap['csv_resource'] ?? null;
        if ($consuntivoAttribute === null) {
            $cli->error('anac_export: attributo csv_resource non trovato sul dataset Bilancio consuntivo, schema art.29-PA-cons saltato');
        }
    }

    $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art29Serializer($preventivoAttribute, $consuntivoAttribute);

    // Nodo di ancoraggio comune ai tre file: la pagina "Bilanci"
    // (schema_pubblicazione), stesso principio di publishArt2627() -
    // fallback al nodo di uno dei due dataset solo se il binding manca
    // (tenant con openpa_bootstrapitalia aggiornato ma installer non ancora
    // aggiornato a questa versione del modulo trasparenza-c1).
    $asIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art29Serializer::SCHEMA_IDENTIFIER_AS;
    $fallbackObject = $preventivoObject instanceof eZContentObject ? $preventivoObject : $consuntivoObject;
    $bilanciPageObject = isset($schemaBindings[$asIdentifier]) ? $schemaBindings[$asIdentifier] : null;
    $rootNodeId = $bilanciPageObject instanceof eZContentObject
        ? $bilanciPageObject->attribute('main_node')->attribute('node_id')
        : $fallbackObject->attribute('main_node')->attribute('node_id');

    try {
        $asPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($asIdentifier, $rootNodeId);
        $asTracking = $asPublisher->publishSingle($serializer->toCsvAs(), 'csv');
        $cli->notice("anac_export: schema {$asIdentifier} ok, ultima modifica {$asTracking['dataUltimaModifica']}");
    } catch (\Exception $e) {
        eZDebug::writeError($e->getMessage(), 'anac_export.php: art.29-as');
        $cli->error('anac_export: schema art.29-as fallito: ' . $e->getMessage());
    }

    if ($preventivoAttribute !== null) {
        try {
            $prevIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art29Serializer::SCHEMA_IDENTIFIER_PA_PREV;
            $prevPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($prevIdentifier, $rootNodeId);
            $prevTracking = $prevPublisher->publishSingle($serializer->toCsvPreventivo(), 'csv');
            $cli->notice("anac_export: schema {$prevIdentifier} ok, ultima modifica {$prevTracking['dataUltimaModifica']}");
        } catch (\Exception $e) {
            eZDebug::writeError($e->getMessage(), 'anac_export.php: art.29-PA-prev');
            $cli->error('anac_export: schema art.29-PA-prev fallito: ' . $e->getMessage());
        }
    }

    if ($consuntivoAttribute !== null) {
        try {
            $consIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art29Serializer::SCHEMA_IDENTIFIER_PA_CONS;
            $consPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($consIdentifier, $rootNodeId);
            $consTracking = $consPublisher->publishSingle($serializer->toCsvConsuntivo(), 'csv');
            $cli->notice("anac_export: schema {$consIdentifier} ok, ultima modifica {$consTracking['dataUltimaModifica']}");
        } catch (\Exception $e) {
            eZDebug::writeError($e->getMessage(), 'anac_export.php: art.29-PA-cons');
            $cli->error('anac_export: schema art.29-PA-cons fallito: ' . $e->getMessage());
        }
    }
}
```

- [ ] **Step 2: Registra la chiamata nella sequenza principale del cron**

Dopo `publishArt2627($cli, $schemaBindings);` (circa riga 87):

```php
publishArt2627($cli, $schemaBindings);
publishArt29($cli, $schemaBindings);
```

- [ ] **Step 3: Verifica manuale (richiede kernel eZ — nessun test automatico qui, copertura in Task 7)**

Lanciare il cron a mano su un tenant di test con almeno un record in uno dei due dataset:

```bash
php bin/php/runcronjobs.php changesection
```

Verificare nei log del cron (`$cli->notice`) che `art.29-as`, e almeno uno tra `art.29-PA-prev`/`art.29-PA-cons`, vengano pubblicati senza errori. **Review Focus**: ripetere con SOLO un dataset installato (rimuovere/rinominare temporaneamente l'altro) e verificare che non ci siano errori fatali, solo lo `notice`/`error` atteso per lo schema mancante.

- [ ] **Step 4: Commit**

```bash
git add cronjobs/anac_export.php
git commit -m "feat: aggiunge publishArt29 al cron ANAC (art.29, cms#556)"
```

---

## Task 6: openpa_bootstrapitalia — `HideExportIfEmpty` per i 3 schemi + ini

**Files:**
- Modify: `classes/services/content_trasparenza.php`
- Modify: `settings/openpa.ini.append.php`

**Interfaces:**
- Consuma: remote_id `bilancio_preventivo`/`bilancio_consuntivo` (Task 1), `Art29Serializer::SCHEMA_IDENTIFIER_*` (Task 4).
- Produce: comportamento di `getAnacExports()` (esistente, nessuna firma cambiata) esteso ai 3 nuovi schemi.

- [ ] **Step 1: Aggiungi le due proprietà di cache in cima alla classe `ObjectHandlerServiceContentTrasparenza`**

Subito dopo `private $attiDiConcessioneRigheCache = null;`:

```php
    /** @var array|null memoizzazione di fetchBilancioRighe('bilancio_preventivo') */
    private $bilancioPreventivoRigheCache = null;

    /** @var array|null memoizzazione di fetchBilancioRighe('bilancio_consuntivo') */
    private $bilancioConsuntivoRigheCache = null;
```

- [ ] **Step 2: Aggiungi il metodo `fetchBilancioRighe()`**

Subito dopo la chiusura di `fetchAttiDiConcessioneRighe()`:

```php
    /**
     * Righe del dataset "Bilancio preventivo" o "Bilancio consuntivo"
     * (art.29, cms#556) - memoizzate per richiesta, stesso principio di
     * fetchAttiDiConcessioneRighe() sopra.
     *
     * @param string $remoteId 'bilancio_preventivo' o 'bilancio_consuntivo'
     * @return array righe grezze, [] se il dataset non esiste su questo
     *         sito o non ha righe
     */
    private function fetchBilancioRighe($remoteId)
    {
        $cacheProperty = $remoteId === 'bilancio_preventivo' ? 'bilancioPreventivoRigheCache' : 'bilancioConsuntivoRigheCache';
        if ($this->$cacheProperty === null) {
            $this->$cacheProperty = [];
            $object = \eZContentObject::fetchByRemoteID($remoteId);
            if ($object instanceof \eZContentObject) {
                $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
                $attribute = $dataMap['csv_resource'] ?? null;
                if ($attribute !== null) {
                    $repository = new \OpendataDatasetSearchableRepository($attribute);
                    $total = $repository->countSearchableObjects();
                    $rows = [];
                    $limit = 200;
                    $offset = 0;
                    while ($offset < $total) {
                        foreach ($repository->fetchSearchableObjectList($limit, $offset) as $searchableObject) {
                            $rows[] = $searchableObject->getDataset()->getData();
                        }
                        $offset += $limit;
                    }
                    $this->$cacheProperty = $rows;
                }
            }
        }

        return $this->$cacheProperty;
    }
```

- [ ] **Step 3: Estendi lo `switch` di `isAnacSchemaSourceEmpty()`**

Aggiungere questi `case` (l'ordine nello switch non è rilevante, ma vanno aggiunti prima di `default`):

```php
            case \OpenPABootstrapItalia\Anac\Serializer\Art29Serializer::SCHEMA_IDENTIFIER_PA_PREV:
                return empty($this->fetchBilancioRighe('bilancio_preventivo'));

            case \OpenPABootstrapItalia\Anac\Serializer\Art29Serializer::SCHEMA_IDENTIFIER_PA_CONS:
                return empty($this->fetchBilancioRighe('bilancio_consuntivo'));

            case \OpenPABootstrapItalia\Anac\Serializer\Art29Serializer::SCHEMA_IDENTIFIER_AS:
                // "Ambito soggettivo" da solo non ha senso se NESSUNO dei
                // due dataset ha righe - nascosto solo in quel caso
                // (Review Focus: non nascondere se solo UNO dei due e'
                // vuoto, l'altro schema resta comunque pubblicato).
                return empty($this->fetchBilancioRighe('bilancio_preventivo'))
                    && empty($this->fetchBilancioRighe('bilancio_consuntivo'));
```

- [ ] **Step 4: Aggiungi i 3 identificatori a `HideExportIfEmpty[]` in `settings/openpa.ini.append.php`**

Dopo `HideExportIfEmpty[]=art.26-27-atti`:

```ini
HideExportIfEmpty[]=art.29-as
HideExportIfEmpty[]=art.29-PA-prev
HideExportIfEmpty[]=art.29-PA-cons
```

- [ ] **Step 5: Verifica manuale (richiede kernel eZ)**

Su un tenant di test con `EnableAnacExport=enabled`: con ENTRAMBI i dataset vuoti, verificare che il blocco "Schemi pubblicazione ANAC" sulla pagina "Bilanci" sia del tutto assente (tutti e 3 nascosti). Popolare SOLO il dataset preventivo con una riga: verificare che compaiano `art.29-as` e `art.29-PA-prev`, ma NON `art.29-PA-cons` (**Review Focus**: punto critico, verificare esplicitamente che `art.29-as` NON sparisca quando solo uno dei due è vuoto).

- [ ] **Step 6: Commit**

```bash
git add classes/services/content_trasparenza.php settings/openpa.ini.append.php
git commit -m "feat: estende HideExportIfEmpty ai 3 schemi art.29 (Bilanci, cms#556)"
```

---

## Task 7: Verifica end-to-end su QA (checklist issue cms#556)

Nessun file nuovo. Eseguire per intero la sezione "Test" dell'issue [cms#556](https://gitlab.com/opencity-labs/sito-istituzionale/cms/-/work_items/556) (6 blocchi: inserimento record, visualizzazione, esposizione file, contenuto CSV, formati, attivazione/profili) su un tenant QA con entrambi i repo (`installer` + `openpa_bootstrapitalia`) reinstallati con `--force`.

- [ ] **Step 1**: Reinstallare `trasparenza-c1` con `--force` sul tenant di test (NON bump versione — vedi Task 8).
- [ ] **Step 2**: Eseguire la sezione "1. Inserimento dei record" dell'issue (inclusi i test di validazione: campo obbligatorio mancante, formato importo valido/non valido, import CSV/Google Sheet).
- [ ] **Step 3**: Eseguire la sezione "2. Visualizzazione nelle pagine di Amministrazione trasparente".
- [ ] **Step 4**: Eseguire la sezione "3. Esposizione dei file" (richiede almeno un ciclo di cron, `php bin/php/runcronjobs.php changesection`, o attendere lo scheduling reale).
- [ ] **Step 5**: Eseguire la sezione "4. Contenuto dei file CSV" (confronto carattere per carattere con le intestazioni dell'issue).
- [ ] **Step 6**: Eseguire la sezione "5. Formati dei campi".
- [ ] **Step 7**: Eseguire la sezione "6. Attivazione e profili" (caso con BDAP, caso senza BDAP, modulo non attivato, stato "appena installato").
- [ ] **Step 8**: Annotare in chat con Marco eventuali scostamenti trovati — **non modificare l'issue GitLab senza una decisione esplicita presa insieme**, stesso principio seguito finora in questa sessione.

---

## Task 8: Bump versione modulo `trasparenza-additional-anac-schemes` (SOLO a verifica completata)

**Corretto in revisione finale (2026-11-26)**: il piano originale indicava `trasparenza-c1`, sbagliato — il lavoro (dataset + patch_content) vive in `trasparenza-additional-anac-schemes` (vedi Ruling Task 1+2 nel ledger). `trasparenza-c1` non va toccato da questo task.

**Da eseguire SOLO dopo che Marco ha confermato che Task 7 è passato interamente.** Non prima, non "nel frattempo" — vedi Global Constraints e [[feedback_no_bump_per_edit_same_branch]]/[[feedback_version_bump_on_request_only]].

**Ordine di rollout su un sito già installato (vedi `installer/modules/trasparenza-additional-anac-schemes/CLAUDE.md`)**: il modulo base `trasparenza` (classi, incluso l'ezselection `schema_pubblicazione` con le nuove opzioni 29/30/31) **non bumpa versione** per questo tipo di modifica (scelta esistente, non di questo piano) — va quindi riapplicato con `--force` PRIMA di questo modulo opzionale, altrimenti il `patch_content` che valorizza `schema_pubblicazione` cita opzioni che l'ezselection non conosce ancora e fallisce in silenzio (`ignore_error: true`).

**Files:**
- Modify: `installer/modules/trasparenza-additional-anac-schemes/installer.yml` (campo `version:` in testa al file, oggi `0.1.0`)

- [ ] **Step 1**: Chiedere conferma esplicita a Marco prima di procedere.
- [ ] **Step 2**: Incrementare `version:` in `installer/modules/trasparenza-additional-anac-schemes/installer.yml`.
- [ ] **Step 3**: Commit

```bash
git add modules/trasparenza-additional-anac-schemes/installer.yml
git commit -m "chore: bump versione modulo trasparenza-additional-anac-schemes (art.29, cms#556)"
```

- [ ] **Step 4**: Mostrare il diff a Marco e attendere conferma esplicita prima di push (vedi regola generale CLAUDE.md: mai push senza conferma).
- [ ] **Step 5**: Documentare nella procedura di rilascio (non in questo piano) che un sito già installato richiede prima `trasparenza --force`, poi questo modulo.
