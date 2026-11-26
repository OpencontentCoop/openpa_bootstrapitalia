# Trasparenza art. 29 "Bilanci" (C1) — piano

> Issue di riferimento: [cms#556](https://gitlab.com/opencity-labs/sito-istituzionale/cms/-/work_items/556). Solo profilo C1, solo italiano. Nessuna logica di switch BDAP sì/no: stesso approccio del registro delle sovvenzioni — il redattore gestisce il proprio caso dopo l'installazione (nota di trasparenza se trasmette a BDAP, altrimenti compila i dataset). Repo: `installer` + `openpa_bootstrapitalia`, branch `trasparenza-additional-scheme-29` su entrambi, da `main`/`master`.

## ✅ Sblocco (2026-11-26)

`trasparenza-additional-scheme-26-27` è stato mergeato su `master` (PR [#191](https://github.com/OpencontentCoop/openpa_bootstrapitalia/pull/191)) e `trasparenza-additional-scheme-29` è stato ribasato sul master aggiornato — `Art2627Serializer.php` e `HideExportIfEmpty` sono ora presenti sul branch. Si procede con l'implementazione task-by-task.

**Bump versione modulo `trasparenza-c1` (installer)**: SOLO alla fine, dopo aver verificato che il lavoro è corretto — non ad ogni modifica. Durante lo sviluppo/test, reinstallare con `--force` invece di bumpare la versione ad ogni iterazione (vedi [[feedback_no_bump_per_edit_same_branch]], [[feedback_version_bump_on_request_only]]).

## Cosa esiste già (verificato in questa sessione)

- **I due dataset esistono già, ma solo su QA** (creati a mano, non nell'installer): [Bilancio preventivo](https://www.comune-qa.bugliano.pi.it/Amministrazione/Documenti-e-dati/Dataset/Bilancio-preventivo-Valori-di-sintesi) (21 campi) e [Bilancio consuntivo](https://www.comune-qa.bugliano.pi.it/content/view/full/40478) (24 campi, 3 in più: totale attivo/passivo, patrimonio netto, contributi pubblici/totali, percentuale di contribuzione). Etichette e descrizioni campo per campo già scritte e verificate dal vivo — vanno portate nell'installer come `content` (classe `dataset` generica), non reinventate.
- **Classe "Nota trasparenza" matura** (`modules/trasparenza/classes/nota_trasparenza.yml`), il meccanismo "Aggiungi nota trasparenza" è già generico — nessun codice nuovo per il caso BDAP, solo documentazione per il redattore (testo di riferimento + dove inserire il link).
- **Il nodo Bilanci esiste già** nel modulo `trasparenza-c1`, con questa gerarchia e questi remote_id (corretto il 2026-11-26 — avevo saltato il nodo padre):
  - **"Bilanci"** (pagina padre, dove vanno `schema_pubblicazione` E i due blocchi "Singolo" — vedi sotto): `d6ad94ccfef19c49a43fef6cef576d21` (`installer/modules/trasparenza-c1/contenttrees/Trasparenza-Ammi-Tras/Bilanci.yml`)
    - "Bilancio preventivo e consuntivo" (sottopagina): `a9d59c0a74d2a7e03448e2bbea8e8458`
      - "Bilancio preventivo" (foglia): `d936dcdabc71967dac70995b1dcd0ecf` (oggi mostra solo i Documenti con `document_type = "Bilancio preventivo"` — resta invariata, non tocchiamo questa pagina)
      - "Bilancio consuntivo" (foglia): `ab203526bbe9eb8b8fb82c4c48b43f0b` (idem, `document_type = "Bilancio consuntivo"` — resta invariata)
    - "Piano degli indicatori e dei risultati attesi di bilancio" (sottopagina): `8866fd5f4b6c38137922770c28079ab9`
- **L'attributo `schema_pubblicazione`** esiste già sulla classe `pagina_trasparenza` (`modules/trasparenza/classes/pagina_trasparenza.yml:229-230`), ma non è ancora valorizzato su nessuna di queste pagine.
- **Permessi: non serve nessuna nuova policy.** `Editor Dataset` (`roles/Editor-Dataset.yml`, ruolo di base, non del modulo trasparenza) ha già `content/create` (sul nodo `$contenttree_Documenti-e-dati_Dataset_node`), `edit`, `remove`, `state/assign` sulla classe `dataset` generica — i due dataset Bilanci sono oggetti `dataset` come "Atti di concessione", non una sottoclasse dedicata (a differenza di `dataset_lotto`, che invece è specifico e già presente su `Editor Trasparenza`). Nessuna modifica di ruolo necessaria.
- **Nessun JSON Schema pubblicato da ANAC per l'art. 29** (verificato: `art.29-v1.0.schema.json` risponde 404) — solo 3 CSV, coerente con quanto dice l'issue stessa. Niente validazione JSON Schema da implementare per questo schema.
- **Collocazione: dataset vs. blocchi — corretto il 2026-11-26.** L'issue (sezione "Punti decisi") dice "Collocazione dei dataset: nelle rispettive pagine" — fuorviante, **non va seguito alla lettera**. I due oggetti `dataset` (il contenuto vero e proprio, con le righe) vanno creati nella cartella generica **Documenti e dati > Dataset**, stesso nodo di "Atti di concessione" e degli altri dataset esistenti (coerente con dove sono già, a mano, su QA — vedi sopra).
- **Come si mostra il dataset in pagina: blocco "Singolo" sulla pagina "Bilanci" (padre), non live-rendering, non sulle sottopagine.** Verificato in `installer/modules/trasparenza-c1/installer.yml`: gli altri due schemi ancorati a un dataset (`art.4-bis` "Dati sui pagamenti", `art.31-cc` "Corte dei conti") NON usano `LiveRenderingRegistry` — anzi quella classe li esclude esplicitamente a docblock ("leggono da un oggetto `dataset`... non sono adattabili allo stesso modo"). Il meccanismo reale è un `patch_content` con `fields_blocks` che aggiunge un blocco di tipo **"Singolo"** nella zona della pagina, con `valid_items: [<remote_id del dataset>]` — il dataset viene incorporato come blocco (stesso meccanismo dei blocchi homepage), mostrando la sua vista nativa (tabella + "Download CSV" + "Aggiungi record" ecc., già vista dal vivo su QA). Zero codice nuovo, solo configurazione installer. **Corretto il 2026-11-26** (avevo sbagliato, mettendo questo sulle sottopagine "Bilancio preventivo"/"Bilancio consuntivo"): sia `schema_pubblicazione` sia i DUE blocchi "Singolo" (uno con `valid_items: [bilancio_preventivo]`, uno con `valid_items: [bilancio_consuntivo]`) vanno sulla pagina **"Bilanci"** (il nodo padre, remote_id `d6ad94ccfef19c49a43fef6cef576d21`), coerente con l'URL di esempio degli export nell'issue (`https://trasparenza.ente.it/[Bilanci]/art.29-as-...`, ancorato a questo nodo, non alle sottopagine). Le sottopagine "Bilancio preventivo"/"Bilancio consuntivo" restano invariate (continuano a mostrare solo i Documenti per `document_type`).
- **`HideExportIfEmpty`** (meccanismo costruito per art.26-27 nel commit `be37cd06`, branch `trasparenza-additional-scheme-26-27`, solo su `dev`): **non sopprime la pubblicazione del cron**, nasconde solo il link nel blocco "Schemi pubblicazione ANAC" in pagina quando il dato sorgente è vuoto adesso. Il cron continua comunque a scrivere un CSV con sola intestazione (zero righe), raggiungibile se si conosce l'URL. **Decisione 2026-11-26** (vedi anche nota aggiunta nell'issue cms#556): per il caso "C1 con BDAP" questo è accettabile così com'è — niente nuova logica nel cron per sopprimere la pubblicazione, coerente con "nessuno switch di profilo". Si riusa aggiungendo `art.29-as`/`art.29-PA-prev`/`art.29-PA-cons` alla lista ini — ma solo dopo che la feature art.26-27 (di cui questo meccanismo fa parte) sarà su `master` (vedi blocco in cima al documento).

## Cosa manca

1. **Portare i due dataset nell'installer** (`content` YAML, classe `dataset`, 21+27 campi con etichette/descrizioni già verificate su QA — da trascrivere, non da inventare), creati sotto il nodo **Documenti e dati > Dataset** (`$contenttree_Documenti-e-dati_Dataset_node`), NON sotto le pagine Bilanci.
2. **`patch_content` sulla pagina "Bilanci"** (remote_id `d6ad94ccfef19c49a43fef6cef576d21`, NON sulle sottopagine): valorizzare `schema_pubblicazione` (stesso meccanismo già in produzione per art.13/23/26-27/35) E aggiungere DUE blocchi `fields_blocks` di tipo "Singolo", uno con `valid_items: [bilancio_preventivo]` e uno con `valid_items: [bilancio_consuntivo]` (remote_id dei due dataset) — stesso pattern già usato per `dati_sui_pagamenti`/`corte_dei_conti` — nessun codice nuovo, solo configurazione.
3. **`Art29Serializer`** (nuovo, in `classes/anac/Serializer/`): legge i due dataset, scrive 3 CSV con le intestazioni ESATTE date nell'issue (non derivabili per analogia — vanno copiate carattere per carattere, incluse le diciture incoerenti tipo `DIFFERENZA (P-Q)` sul consuntivo). Attenzione alle 3 corrispondenze non deducibili dal nome già segnalate da Marco nell'issue: `url_preventivo`→`URL_PREVENTIVO`, `url_bilancio`→`URL_BILANCIO` (non `URL_CONSUNTIVO`), `differenza_p_q`→`DIFFERENZA (P-Q)`.
4. **`art.29-as`**: unico campo `AMBITO_SOGGETTIVO`, valore fisso `"Pubbliche amministrazioni in contabilità finanziaria"` — non viene da nessun dataset, è una costante nel serializer per questo profilo (C1).
5. **Cron + `ExportPublisher`**: stesso lavoro standard di ogni altro schema ANAC già fatto.
6. **Verifica incrociata import CSV/Google Sheet del framework Dataset** con questi nuovi campi numerici — stesso import già usato per gli altri dataset, solo da testare con 21-27 colonne.

## Tipi "amount"/"percentage": validazione reale + descrizione per campo (corretto il 2026-11-26)

**Primo tentativo di verifica sbagliato** (avevo letto solo `opendatadatasettype.php`, che mostra solo lo schema generico/placeholder, non la validazione vera). Verifica corretta: `occustomfind` ha una classe dedicata, **`OpendataDatasetNumberNormalizer`** (`datatypes/opendatadataset/OpendataDatasetNumberNormalizer.php`, commit `cc7433a` "Dataset: tipi importo e percentuale, descrizione dei campi, import tutto-o-niente", già su master dal 2026-11-12), applicata da `OpendataDatasetDefinition::create()` — **vale per form, API REST e import**, non solo all'export:

- **`amount`**: salvato sempre in formato ANAC `n.nnn,dd` (punto migliaia, virgola decimale, due decimali) — accetta `1550`, `1550,33`, `1.550,33`, `1.550`, `1.000.000`, tollera `€`/spazi; **non** accetta il formato inglese (`1550.33`). Rifiuta tutto il resto con errore indicato al redattore (form), e lo stesso in API/import.
- **`percentage`**: salvato come numero con virgola, senza simbolo, senza zeri finali, fino a 4 decimali, non negativo — accetta `12`, `12,5`, `12.5`, `12,5%`, `12,5 %`.

**Conseguenza per `Art29Serializer`**: dato che il framework Dataset normalizza già il valore al formato ANAC corretto PRIMA che arrivi al serializer, **non serve chiamare `ImportoNormalizer`** (quello di `classes/anac/`, usato invece per art.4-bis/art.26-27 dove i dataset usano ancora `type: string` per l'importo) — basta leggere il valore e scriverlo nel CSV così com'è (trim, nessuna normalizzazione). Stesso discorso per `perc_contribuzione_pubblica` (type `percentage`): già nel formato giusto, nessuna trasformazione da fare.

**Bonus dello stesso commit**: nuova proprietà **`description`** per campo (testo libero, mostrato come aiuto sotto il campo nel form, per lingua) — è esattamente il meccanismo dietro le descrizioni viste dal vivo su QA ("Anno del bilancio preventivo.", ecc., già raccolte in Appendice). Il formato "Formato: 1.550,33..." visto sotto i campi `amount`/`percentage` è invece generato automaticamente dal tipo stesso (`getNumberFieldHint()`), non va scritto a mano nella `description`.

**Campi YAML reali per ogni field** (verificato in `OpendataDatasetFieldDefinitionConnector::getSchema()`): `identifier` (string), `label` (string), `description` (string, opzionale), `type` (string, enum), `required` (**boolean**, non stringa — l'esempio `Dati-sui-pagamenti-Dataset.yml` usa `required: 'false'` come stringa ma lo schema reale vuole booleano: usare `required: true` non quotato).

## Gestione del valore `n/a` — decisione presa

**Deciso con Marco il 2026-11-26** (confrontato anche con una collega): per ora i campi numerici **restano tutti obbligatori**, con lo stesso formato importo rigido già in uso su QA ("Formato: 1.550,33") — **nessuna modifica al dataset reale né al tipo di campo "amount" del framework Dataset**. Il caso "voce non prevista dall'ordinamento contabile dell'ente" non viene gestito in questo giro: si rimanda a dopo una review con alcuni comuni, per capire quanto il caso si presenta davvero in pratica prima di introdurre un'eccezione (facoltativa o `n/a` letterale) nel tipo di campo condiviso con gli altri schemi Dataset-based.

Conseguenza pratica: il serializer esporta i valori così come sono nel dataset (tutti valorizzati, nessun campo può restare vuoto); non c'è logica di fallback a `n/a` da scrivere. Se in futuro la review coi comuni conferma la necessità, si riprende la stessa alternativa A/B già scartata qui: campi facoltativi con `n/a` implicito, oppure eccezione esplicita nel tipo "amount".

## Stima

Lavoro contenuto rispetto ad art.35/art.26-27: niente content_type nuovo, niente relazioni, permessi già a posto, niente JSON da validare, niente modifica al tipo di campo condiviso del framework Dataset (rimandata). Il grosso è: trascrizione dei 48 campi totali nell'installer, il serializer con le intestazioni esatte.

## Appendice — campi reali dei due dataset (estratti dal vivo su QA, 2026-11-26)

Estratti navigando i form "Aggiungi record" su QA ed estraendo gli `input[name]` via JS — identificatori reali, non derivati per analogia. Ordine = ordine del form = ordine delle colonne CSV ANAC (coerente con quanto dice l'issue).

### Bilancio preventivo (21 campi, identificatore dataset da definire in installer)

| # | Identificatore | Etichetta | Obbligatorio | Descrizione per il redattore | Formato |
|---|---|---|---|---|---|
| 1 | `anno` | Anno | sì | Anno del bilancio preventivo. | — |
| 2 | `url_preventivo` | Preventivo completo di allegati | sì | Indirizzo della pagina in cui sono pubblicati il bilancio preventivo e i suoi allegati. | URL |
| 3 | `entrate_correnti` | Entrate correnti previste | sì | — | 1.550,33 (virgola decimali, punto migliaia) |
| 4 | `uscite_correnti` | Uscite correnti previste | sì | — | idem |
| 5 | `differenza_c_d` | Differenza (C-D) | sì | Avanzo, disavanzo o pareggio di parte corrente previsto: entrate correnti meno uscite correnti. | idem |
| 6 | `entrate_totali` | Entrate totali previste | sì | — | idem |
| 7 | `uscite_totali` | Uscite totali previste | sì | — | idem |
| 8 | `differenza_f_g` | Differenza (F-G) | sì | Avanzo, disavanzo o pareggio totale previsto: entrate totali meno uscite totali. | idem |
| 9 | `liq_crediti` | Cassa e crediti previsti | sì | Indice di liquidità a breve. | idem |
| 10 | `liq_debiti` | Debiti previsti | sì | Indice di liquidità a breve. | idem |
| 11 | `differenza_i_j` | Differenza (I-J) | sì | Risultato di amministrazione previsto: cassa e crediti meno debiti. | idem |
| 12 | `cassa_crediti` | Entrate riscosse previste | sì | Previsione di cassa. | idem |
| 13 | `cassa_debiti` | Uscite pagate previste | sì | Previsione di cassa. | idem |
| 14 | `differenza_l_m` | Differenza (L-M) | sì | Saldo di cassa previsto: entrate riscosse meno uscite pagate. | idem |
| 15 | `valore_produzione` | Valore della produzione (A) previsto | sì | Gestione caratteristica. | idem |
| 16 | `costi_produzione` | Costi della produzione (B) previsti | sì | Gestione caratteristica. | idem |
| 17 | `differenza_o_p` | Differenza (O-P) | sì | Differenza tra valore e costi della produzione (A-B) prevista. | idem |
| 18 | `comp_positivi_reddito` | Componenti positivi di reddito previsti | sì | Previsione economica dell'esercizio. | idem |
| 19 | `comp_negativi_reddito` | Componenti negativi di reddito previsti | sì | Previsione economica dell'esercizio. | idem |
| 20 | `differenza_r_s` | Differenza (R-S) | sì | Utile, perdita o pareggio d'esercizio previsto. | idem |
| 21 | `url_piano_indicatori` | Piano degli indicatori e dei risultati attesi | sì | Indirizzo del Piano degli indicatori e dei risultati attesi di bilancio per l'anno del preventivo. | URL |

**Attenzione identificatore #2**: `url_preventivo`, non "url_bilancio" — corrisponde a `URL_PREVENTIVO` nel CSV (confermato, coerente con l'issue).

### Bilancio consuntivo (27 campi, identificatore dataset da definire in installer)

| # | Identificatore | Etichetta | Obbligatorio | Descrizione per il redattore | Formato |
|---|---|---|---|---|---|
| 1 | `anno` | Anno | sì | Anno del bilancio consuntivo (rendiconto). | — |
| 2 | `url_bilancio` | Consuntivo completo di allegati | sì | Indirizzo della pagina in cui sono pubblicati il bilancio consuntivo e i suoi allegati. | URL |
| 3 | `entrate_correnti` | Entrate correnti accertate | sì | — | 1.550,33 |
| 4 | `uscite_correnti` | Uscite correnti impegnate | sì | — | idem |
| 5 | `differenza_c_d` | Differenza (C-D) | sì | Avanzo, disavanzo o pareggio di parte corrente: entrate correnti meno uscite correnti. | idem |
| 6 | `entrate_totali` | Entrate totali accertate | sì | — | idem |
| 7 | `uscite_totali` | Uscite totali impegnate | sì | — | idem |
| 8 | `differenza_f_g` | Differenza (F-G) | sì | Avanzo, disavanzo o pareggio totale: entrate totali meno uscite totali. | idem |
| 9 | `liq_crediti` | Cassa e crediti | sì | Indice di liquidità a breve. | idem |
| 10 | `liq_debiti` | Debiti | sì | Indice di liquidità a breve. | idem |
| 11 | `differenza_i_j` | Differenza (I-J) | sì | Risultato di amministrazione: cassa e crediti meno debiti. | idem |
| 12 | `cassa_crediti` | Entrate riscosse | sì | Gestione di cassa. | idem |
| 13 | `cassa_debiti` | Uscite pagate | sì | Gestione di cassa. | idem |
| 14 | `differenza_l_m` | Differenza (L-M) | sì | Saldo di cassa: entrate riscosse meno uscite pagate. | idem |
| 15 | `valore_produzione` | Valore della produzione (A) | sì | Conto economico, gestione caratteristica. | idem |
| 16 | `costi_produzione` | Costi della produzione (B) | sì | Conto economico, gestione caratteristica. | idem |
| 17 | `differenza_p_q` | Differenza (P-Q) | sì | Differenza tra valore e costi della produzione (A-B). L'etichetta riprende quella dello schema ANAC. | idem |
| 18 | `comp_positivi_reddito` | Componenti positivi di reddito | sì | Conto economico dell'esercizio. | idem |
| 19 | `comp_negativi_reddito` | Componenti negativi di reddito | sì | Conto economico dell'esercizio. | idem |
| 20 | `differenza_r_s` | Differenza (R-S) | sì | Utile, perdita o pareggio d'esercizio. | idem |
| 21 | `totale_attivo` | Totale attivo | sì | Stato patrimoniale. | idem |
| 22 | `totale_passivo` | Totale passivo | sì | Stato patrimoniale, esclusi il patrimonio netto. | idem |
| 23 | `patrimonio_netto_u_v` | Patrimonio netto (U-V) | sì | Totale attivo meno totale passivo. | idem |
| 24 | `contributi_pubblici` | Contributi pubblici | sì | Contributi ricevuti da pubbliche amministrazioni. | idem |
| 25 | `contributi_totali` | Contributi totali | sì | Totale dei contributi ricevuti. | idem |
| 26 | `perc_contribuzione_pubblica` | Percentuale di contribuzione pubblica | sì | Contributi pubblici sul totale dei contributi. | 12,5 oppure 12,5% |
| 27 | `url_piano_indicatori` | Piano degli indicatori e dei risultati di bilancio | sì | Indirizzo del Piano degli indicatori e dei risultati di bilancio allegato al rendiconto. | URL |

**Attenzione identificatore #2**: `url_bilancio`, non "url_consuntivo" — corrisponde a `URL_BILANCIO` nel CSV (confermato, coerente con l'issue).

**Nota per le descrizioni nell'installer**: nessun riferimento a `n/a` nelle descrizioni campo (coerente con la decisione sopra — i campi restano obbligatori, il caso non è gestito in questo giro).

### Intestazioni CSV esatte (da issue cms#556, copiare carattere per carattere)

`art.29-PA-prev`:
```
ANNO;URL_PREVENTIVO;ENTRATE_CORRENTI;USCITE_CORRENTI;DIFFERENZA (C-D);ENTRATE_TOTALI;USCITE_TOTALI;DIFFERENZA (F-G);LIQ_CREDITI;LIQ_DEBITI;DIFFERENZA (I-J);CASSA_CREDITI;CASSA_DEBITI;DIFFERENZA (L-M);VALORE_PRODUZIONE;COSTI_PRODUZIONE;DIFFERENZA (O-P);COMP_POSITIVI_REDDITO;COMP_NEGATIVI_REDDITO;DIFFERENZA (R-S);URL_PIANO_INDICATORI
```

`art.29-PA-cons`:
```
ANNO;URL_BILANCIO;ENTRATE_CORRENTI;USCITE_CORRENTI;DIFFERENZA (C-D);ENTRATE_TOTALI;USCITE_TOTALI;DIFFERENZA (F-G);LIQ_CREDITI;LIQ_DEBITI;DIFFERENZA (I-J);CASSA_CREDITI;CASSA_DEBITI;DIFFERENZA (L-M);VALORE_PRODUZIONE;COSTI_PRODUZIONE;DIFFERENZA (P-Q);COMP_POSITIVI_REDDITO;COMP_NEGATIVI_REDDITO;DIFFERENZA (R-S);TOTALE_ATTIVO;TOTALE_PASSIVO;PATRIMONIO_NETTO (U-V);CONTRIBUTI_PUBBLICI;CONTRIBUTI_TOTALI;PERC_CONTRIBUZIONE_PUBBLICA;URL_PIANO_INDICATORI
```

`art.29-as`: singola colonna `AMBITO_SOGGETTIVO`, valore costante `Pubbliche amministrazioni in contabilità finanziaria`.

Mapping campo→colonna è 1:1 per posizione (stesso ordine form = stesso ordine CSV), identificatori ↔ nomi colonna derivabili per maiuscolo tranne le eccezioni già segnalate nell'issue (`url_preventivo`→`URL_PREVENTIVO`, `url_bilancio`→`URL_BILANCIO`, `differenza_p_q`→`DIFFERENZA (P-Q)` sul consuntivo, già tutte verificate sopra).
