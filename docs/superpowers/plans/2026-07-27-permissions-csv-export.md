# Permissions CSV Export — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aggiungere un bottone "Scarica CSV" nella pagina dei redattori che scarica un file con Nome, Abilitato, e una colonna per ogni ruolo.

**Architecture:** Nuovo file PHP `permissions_csv.php` (view separata nel modulo `bootstrapitalia`, stesso pattern di `valuation/csv.php`), registrato in `module.php`, con bottone nel template `permissions.tpl`.

**Tech Stack:** eZ Publish PHP (legacy), eZTemplate (Smarty-like), Bootstrap 4/5 per il template.

## Global Constraints

- PHP 7.4 — no named arguments, no match expression, no union types
- Usare `eZExecution::cleanExit()` per terminare l'output CSV (non `exit()` diretto)
- Chiamare `ob_get_clean()` prima degli header HTTP per svuotare qualsiasi output accumulato da eZ
- Separatore CSV: virgola (default di `fputcsv`)
- Encoding: UTF-8 (aggiungere BOM per compatibilità con Excel: `"\xEF\xBB\xBF"`)
- La view `permissions_csv` deve usare `functions => ['permissions']` per ereditare lo stesso controllo accessi della view `permissions`
- Il bottone nel template usa classe `btn btn-secondary btn-sm rounded-0` (stesso stile bottoni esistenti)
- Nessuna icona nel bottone

---

### Task 1: Endpoint PHP — registrazione view e logica CSV

**Files:**
- Modify: `modules/bootstrapitalia/module.php`
- Create: `modules/bootstrapitalia/permissions_csv.php`

**Interfaces:**
- Produces: `GET /bootstrapitalia/permissions_csv` → risposta `text/csv` con BOM UTF-8

---

- [ ] **Step 1: Aggiungi la view in `module.php`**

In `modules/bootstrapitalia/module.php`, subito dopo il blocco `$ViewList['permissions']` (riga ~13-19), inserire:

```php
$ViewList['permissions_csv'] = [
    'functions' => ['permissions'],
    'script' => 'permissions_csv.php',
    'params' => [],
    'unordered_params' => [],
    "default_navigation_part" => 'ezsetupnavigationpart',
];
```

E subito dopo `$FunctionList['permissions'] = [];` (riga ~101), aggiungere:

```php
$FunctionList['permissions_csv'] = [];
```

- [ ] **Step 2: Crea `modules/bootstrapitalia/permissions_csv.php`**

```php
<?php

$module = $Params['Module'];

$editorObject = eZContentObject::fetchByRemoteID('editors_base');
if (!$editorObject) {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}
$editorNodeId = $editorObject->attribute('main_node_id');

// Fetch dei gruppi (ruoli), ordinati per nome come nella UI
$groups = eZContentObjectTreeNode::subTreeByNodeID([
    'ClassFilterType'  => 'include',
    'ClassFilterArray' => ['user_group'],
    'SortBy'           => [['name', true]],
    'Limit'            => false,
], $editorNodeId);
if (!is_array($groups)) {
    $groups = [];
}

// Fetch iterativa di tutti gli utenti (100 alla volta)
$users  = [];
$offset = 0;
$limit  = 100;
do {
    $batch = eZContentObjectTreeNode::subTreeByNodeID([
        'ClassFilterType'  => 'include',
        'ClassFilterArray' => ['user'],
        'SortBy'           => [['name', true]],
        'Offset'           => $offset,
        'Limit'            => $limit,
    ], $editorNodeId);
    if (!is_array($batch)) {
        break;
    }
    $users  = array_merge($users, $batch);
    $offset += $limit;
} while (count($batch) === $limit);

// Output CSV
ob_get_clean();
$filename = 'redattori-' . date('Y-m-d') . '.csv';
header('X-Powered-By: eZ Publish');
header('Content-Description: File Transfer');
header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename="' . $filename . '"');
header('Pragma: no-cache');
header('Expires: 0');

$output = fopen('php://output', 'w');

// BOM UTF-8 per compatibilità Excel
fwrite($output, "\xEF\xBB\xBF");

// Riga di intestazione
$headers = ['Nome', 'Abilitato'];
foreach ($groups as $group) {
    $headers[] = $group->attribute('name');
}
fputcsv($output, $headers);

// Righe dati
foreach ($users as $userNode) {
    $contentObject = $userNode->object();
    $ezUser        = eZUser::fetch($contentObject->attribute('id'));
    $isEnabled     = ($ezUser instanceof eZUser && $ezUser->isEnabled()) ? 'Sì' : 'No';

    // Nodi parent dell'utente (per determinare i ruoli assegnati)
    $assignedParentNodeIds = [];
    foreach ($contentObject->assignedNodes() as $assignedNode) {
        $assignedParentNodeIds[] = $assignedNode->attribute('parent_node_id');
    }

    $row = [$contentObject->attribute('name'), $isEnabled];
    foreach ($groups as $group) {
        $row[] = in_array($group->attribute('node_id'), $assignedParentNodeIds) ? 'X' : '';
    }

    fputcsv($output, $row);
}

flush();
eZExecution::cleanExit();
```

- [ ] **Step 3: Verifica manuale dell'endpoint nel container**

```bash
OUT=$(docker exec cms-app-1 /usr/local/bin/php -r '
chdir("/var/www/html");
require_once "/var/www/html/autoload.php";
$obj = eZContentObject::fetchByRemoteID("editors_base");
echo $obj ? "OK: " . $obj->attribute("name") . "\n" : "FAIL: editors_base non trovato\n";
' 2>&1); echo "$OUT"
```

Output atteso: `OK: <nome nodo editors_base>` (conferma che la fetch funziona).

Poi verifica l'endpoint HTTP:

```bash
curl -s -u admin:changethispassword \
  "http://opencity.localtest.me/bootstrapitalia/permissions_csv" \
  -o /tmp/test_redattori.csv && head -3 /tmp/test_redattori.csv
```

Output atteso: prima riga con `Nome,Abilitato,<ruolo1>,<ruolo2>,...`, seconda riga con un utente.

- [ ] **Step 4: Commit**

```bash
cd /Volumes/Repos/sviluppo-sito-comunale/openpa_bootstrapitalia
git add modules/bootstrapitalia/module.php modules/bootstrapitalia/permissions_csv.php
git commit -m "feat: aggiunge endpoint CSV export redattori con ruoli"
```

---

### Task 2: Bottone nel template

**Files:**
- Modify: `design/bootstrapitalia2/templates/bootstrapitalia/permissions.tpl`

**Interfaces:**
- Consumes: URL `/bootstrapitalia/permissions_csv` prodotto dal Task 1

---

- [ ] **Step 1: Aggiungi il bottone nel template**

In `design/bootstrapitalia2/templates/bootstrapitalia/permissions.tpl`, dopo la chiusura del `<div class="col-1">` che contiene il bottone `AddContent` (riga ~32), aggiungere:

```smarty
        <div class="col-12 text-right mb-2">
            <a href={'/bootstrapitalia/permissions_csv'|ezurl(no)} class="btn btn-secondary btn-sm rounded-0">Scarica CSV</a>
        </div>
```

- [ ] **Step 2: Verifica visiva nel browser**

Aprire `https://opencity.localtest.me/bootstrapitalia/permissions` e verificare:
- Il bottone "Scarica CSV" è visibile sotto la barra di ricerca, allineato a destra
- Cliccandolo il browser scarica un file `.csv` con nome `redattori-YYYY-MM-DD.csv`
- Il file aperto in un editor di testo mostra la riga intestazione e le righe dati corrette
- Il file aperto in Excel mostra caratteri accentuati corretti (grazie al BOM UTF-8)

- [ ] **Step 3: Commit**

```bash
cd /Volumes/Repos/sviluppo-sito-comunale/openpa_bootstrapitalia
git add design/bootstrapitalia2/templates/bootstrapitalia/permissions.tpl
git commit -m "feat: aggiunge bottone Scarica CSV nella pagina redattori"
```
