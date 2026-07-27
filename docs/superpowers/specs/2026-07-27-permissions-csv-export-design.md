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
| Abilitato | attributo `is_enabled` della classe `user` | `Sì` / `No` |
| [nome ruolo 1] | confronto `parentNodes` vs `node_id` del gruppo | `X` / vuoto |
| [nome ruolo N] | idem | `X` / vuoto |

Le colonne dei ruoli sono **dinamiche**: vengono generate a runtime leggendo tutti i `user_group` figli di `editors_base`, nell'ordine alfabetico già usato dalla UI (`sort_by name asc`).

Email e username sono esclusi intenzionalmente per ridurre l'esposizione di dati personali.

## Architettura

### Pattern di riferimento: `modules/valuation/csv.php`

L'estensione ha già un export CSV identico per struttura nel modulo `valuation`. Si segue lo stesso pattern: file PHP separato, stessi header HTTP, `fopen('php://output', 'w')`, `fputcsv`, `flush()`, `eZExecution::cleanExit()`.

### Nuovo file: `modules/bootstrapitalia/permissions_csv.php`

Registrato come nuova view `permissions_csv` in `module.php` del modulo `bootstrapitalia`.

URL risultante: `GET /bootstrapitalia/permissions_csv`

Flusso:
1. Fetch dei gruppi: content list sul nodo `editors_base`, filtro classe `user_group`, ordinati per nome
2. Fetch iterativa degli utenti: `eZContentObjectTreeNode::subTreeByNodeID` con `class_filter_array = ['user']`, offset incrementato di 100 a ogni iterazione fino a esaurimento
3. Per ogni utente: legge `name` e `is_enabled`; per ogni gruppo controlla se il `node_id` è presente nei `parentNodes`
4. `ob_get_clean()`, header HTTP (`Content-Type: text/csv; charset=utf-8`, `Content-Disposition: attachment; filename="redattori-YYYY-MM-DD.csv"`, `Pragma: no-cache`, `Expires: 0`)
5. `fputcsv` riga di intestazione + una riga per utente
6. `flush()` + `eZExecution::cleanExit()`

### Modifica al template (`permissions.tpl`)

Aggiunta di un link senza icona, con la stessa classe dei bottoni già presenti nella pagina:

```smarty
<a href={'/bootstrapitalia/permissions_csv'|ezurl(no)} class="btn btn-secondary btn-sm rounded-0">Scarica CSV</a>
```

## File modificati

| File | Tipo modifica |
|---|---|
| `modules/bootstrapitalia/module.php` | aggiunta view `permissions_csv` |
| `modules/bootstrapitalia/permissions_csv.php` | nuovo file, ~60 righe (pattern da `valuation/csv.php`) |
| `design/bootstrapitalia2/templates/bootstrapitalia/permissions.tpl` | aggiunta bottone (~1 riga) |

## Casi limite

- **Nessun utente:** il CSV contiene solo la riga di intestazione
- **Nessun gruppo:** le colonne dei ruoli sono assenti, il CSV ha solo le 2 colonne base
- **Utente senza ruoli:** tutte le celle dei ruoli sono vuote
- **Molti utenti:** il loop con offset di 100 gestisce qualsiasi volume senza caricare tutto in memoria
