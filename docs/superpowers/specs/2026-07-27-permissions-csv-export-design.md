# Design: Export CSV elenco redattori

**Data:** 2026-07-27
**Branch:** `feature/permissions-csv-export`
**Repo:** `openpa_bootstrapitalia`

## Contesto

La pagina `/bootstrapitalia/permissions` mostra l'elenco dei redattori del CMS con i relativi ruoli (gruppi `user_group` figli del nodo `editors_base`). Attualmente non esiste modo di esportare questi dati.

## Obiettivo

Aggiungere un bottone "Scarica CSV" che permetta all'amministratore di scaricare l'elenco completo dei redattori con i relativi ruoli assegnati.

## Requisiti

- L'export contiene **tutti** gli utenti, indipendentemente da qualsiasi filtro attivo nella UI
- L'export contiene **tutti** i ruoli (nessun filtro per gruppo)
- Il file è scaricato direttamente dal browser (non AJAX)
- Il file ha nome `redattori-YYYY-MM-DD.csv`

## Colonne CSV

| Colonna | Fonte dati | Tipo |
|---|---|---|
| Nome | `metadata.name` (lingua `ita-IT`) | stringa |
| Email | attributo `email` della classe `user` | stringa |
| Username | attributo `login` della classe `user` | stringa |
| Abilitato | attributo `is_enabled` della classe `user` | `Sì` / `No` |
| [nome ruolo 1] | confronto `parentNodes` vs `node_id` del gruppo | `X` / vuoto |
| [nome ruolo N] | idem | `X` / vuoto |

Le colonne dei ruoli sono **dinamiche**: vengono generate a runtime leggendo tutti i `user_group` figli di `editors_base`, nell'ordine alfabetico già usato dalla UI (`sort_by name asc`).

## Architettura

### Nessuna modifica alla routing eZ Publish

Il modulo `bootstrapitalia` ha già una entry `permissions` in `module.php`. Si aggiunge semplicemente una nuova branch `csv` nell'`if` delle action già gestite in `permissions.php`.

URL risultante: `GET /bootstrapitalia/permissions/csv`

### Flusso lato server (`permissions.php`)

1. Legge il parametro action dai `$Params`; se è `csv`, entra nel branch di export
2. Fetch dei gruppi: `eZContentObjectTreeNode::subTreeByNodeID` (oppure `fetch content list`) sul nodo `editors_base`, filtro classe `user_group`, ordinati per nome
3. Fetch iterativa degli utenti: query sulla content search con `class_filter_type = include`, `class_filter_array = ['user']`, `parent_node_id = editors_base_node_id`, offset incrementato di 100 a ogni iterazione, finché il risultato è vuoto
4. Per ogni utente: legge `name`, `email`, `login`, `is_enabled`; per ogni gruppo controlla se il `node_id` del gruppo è presente nei `parentNodes` dell'utente
5. Imposta gli header HTTP: `Content-Type: text/csv; charset=utf-8`, `Content-Disposition: attachment; filename="redattori-YYYY-MM-DD.csv"`
6. Scrive l'header CSV (prima riga) e poi una riga per utente con `fputcsv`
7. Termina con `eZExecution::cleanExit()`

### Modifica al template (`permissions.tpl`)

Aggiunta di un link/bottone Bootstrap nella barra in cima alla tabella, accanto ai controlli esistenti:

```html
<a href={'/bootstrapitalia/permissions/csv'|ezurl} class="btn btn-outline-secondary btn-sm">
    <svg ...><!-- icona download --></svg>
    Scarica CSV
</a>
```

## File modificati

| File | Tipo modifica |
|---|---|
| `modules/bootstrapitalia/permissions.php` | aggiunta branch `csv` (~60 righe) |
| `design/bootstrapitalia2/templates/bootstrapitalia/permissions.tpl` | aggiunta bottone (~4 righe) |

Nessun file di routing, nessun nuovo modulo, nessuna dipendenza nuova.

## Casi limite

- **Nessun utente:** il CSV contiene solo la riga di intestazione
- **Nessun gruppo:** le colonne dei ruoli sono assenti, il CSV ha solo le 4 colonne base
- **Utente senza ruoli:** tutte le celle dei ruoli sono vuote
- **Utente con più assegnazioni allo stesso gruppo:** la logica di confronto con `parentNodes` rimane corretta (presenza/assenza)
- **Molti utenti:** il loop con offset di 100 gestisce qualsiasi volume senza caricare tutto in memoria
