# Piano di lavoro — Fix lock_edit homepage: distruzione blocchi per pool vuota

## Contesto

### Il bug

Il form lock_edit della homepage (`HomepageLockEditClassConnector`) legge lo stato delle sezioni dalla `ezm_pool` tramite `mapListaManualeToRelations()`. Se la pool è vuota per un blocco ListaManuale, la funzione restituisce `null`, e `getData()` imposta `add_section_X = false`.

Questo nasconde il checkbox della sezione ad Alpaca. Quando il redattore salva (anche senza toccare nulla), `mapSection*()` riceve `add_section_X = false` (o assente) → restituisce `null` → il blocco non è incluso nel salvataggio → `createXML()` lo cancella permanentemente da `ezm_block`.

**Incidente documentato:** 5 giugno 2026, Rovereto. Il redattore apre il form e salva dopo 24 secondi. La pool era vuota. Risultato: 7 sezioni su 8 distrutte irreversibilmente.

### Root cause

Il disaccoppiamento tra due sistemi:
- `ezm_pool`: fonte di verità per il form lock_edit (items selezionati per sezione)
- XML `data_text` dell'oggetto eZ: fonte di verità per il rendering della homepage

La homepage si renderizza dall'XML anche se la pool è vuota, quindi il problema è invisibile ai visitatori. Il form lock_edit invece crasha silenziosamente quando la pool si svuota.

### File coinvolto

**Solo un file da modificare:**
`classes/connectors/LockEdit/HomepageLockEditClassConnector.php`

---

## Soluzione

**Principio:** un blocco deve essere rimosso dall'XML solo se il redattore lo disattiva _esplicitamente_ (deseleziona il checkbox `add_section_X`). Se il checkbox non esiste nell'interfaccia (sezioni senza checkbox: management, places) il blocco deve essere preservato anche se l'elenco item è vuoto.

---

## Modifiche dettagliate

### 1. `getData()` — flag `add_section_*` basati su esistenza blocco in XML

**Problema attuale (righe 73-76):**
```php
'add_section_news'   => $hasLatestNews || $hasNews,
'add_section_events' => $hasNextEvents || $hasEvents,
'add_section_banner' => is_array($hasBanner),
'add_section_search' => is_array($hasLinks) || is_array($hasSearchBg),
```
Se pool vuota → `$hasNews = null`, `$hasBanner = null` → flag = false → sezioni nascoste.

**Fix:**
```php
'add_section_news'   => $hasLatestNews || $hasNews   || $this->findBlockById(self::SECTION_NEWS) !== null,
'add_section_events' => $hasNextEvents || $hasEvents || $this->findBlockById(self::SECTION_NEXT_EVENTS) !== null,
'add_section_banner' => is_array($hasBanner)         || $this->findBlockById(self::SECTION_BANNER) !== null,
'add_section_search' => is_array($hasLinks) || is_array($hasSearchBg) || $this->findBlockById(self::SEARCH) !== null,
```
Il blocco esiste nell'XML → la sezione è mostrata come attiva nel form, indipendentemente dalla pool.

---

### 2. `mapSectionBanner()` — preservare il blocco se il checkbox è attivo

**Problema attuale (riga 671):** il gate è sull'esistenza degli items:
```php
if (isset($data['section_banner'][0]['id'])) { ... }
return null;
```
Con fix 1, `add_section_banner = true` nel form, ma se l'utente non aggiunge items → POST con lista vuota → `isset(...[0])` = false → blocco eliminato.

**Fix:** cambiare il gate da "ha items" a "checkbox attivo":
```php
private function mapSectionBanner($data): ?array
{
    if (!($data['add_section_banner'] ?? false)) {
        return null; // redattore ha esplicitamente disattivato la sezione
    }
    $originalBlock = $this->findBlockById(self::SECTION_BANNER, true)
        ?? $this->findBlockById(self::SECTION_BANNER);
    $originalBlock['name'] = $data['title_banner'] ?? '';
    $originalBlock['type'] = 'ListaManuale';
    $originalCustomAttributes = $originalBlock['custom_attributes'];
    $originalBlock['custom_attributes'] = [
        'elementi_per_riga' => $originalCustomAttributes['elementi_per_riga'],
        'color_style'       => $originalCustomAttributes['color_style'],
        'container_style'   => $originalCustomAttributes['container_style'],
        'intro_text'        => $originalCustomAttributes['intro_text'],
    ];
    $remoteIdList = [];
    foreach ((array)($data['section_banner'] ?? []) as $item) {
        $object = eZContentObject::fetch((int)$item['id']);
        if ($object instanceof eZContentObject) {
            $remoteIdList[] = $object->attribute('remote_id');
        }
    }
    $originalBlock['valid_items'] = $remoteIdList; // può essere [] — blocco preservato
    return $originalBlock;
}
```

---

### 3. `mapSectionManagement()` — preservare blocco se non ci sono items ma esiste nell'XML

**Problema attuale (riga 571):**
```php
if (isset($data['section_management'][0]['id'])) { ... }
return null;
```
Non esiste `add_section_management`. Se pool vuota il form mostra la lista vuota; se l'utente salva senza item → blocco eliminato.

**Fix:** se nessun item nel POST ma il blocco esiste nell'XML corrente, restituire il blocco con lista vuota:
```php
private function mapSectionManagement($data, $hasMainNews): ?array
{
    if (!isset($data['section_management'][0]['id'])) {
        $existingBlock = $this->findBlockById(self::SECTION_MANAGEMENT);
        if ($existingBlock !== null) {
            $existingBlock['valid_items'] = [];
            return $existingBlock; // blocco preservato, lista vuota
        }
        return null;
    }
    // logica esistente per costruire il blocco con gli items
    $originalBlockManagement = $this->findBlockById(self::SECTION_MANAGEMENT, true);
    $managementRemoteIdList = [];
    foreach ($data['section_management'] as $managementItem) {
        $management = eZContentObject::fetch((int)$managementItem['id']);
        if ($management instanceof eZContentObject) {
            $managementRemoteIdList[] = $management->attribute('remote_id');
        }
    }
    $originalBlockManagement['valid_items'] = $managementRemoteIdList;
    if (!$hasMainNews) {
        $originalBlockManagement['custom_attributes']['container_style'] = false;
    }
    return $originalBlockManagement;
}
```

---

### 4. `mapSectionPlaces()` — stesso pattern di management

**Fix:** stesso approccio di modifica 3, applicato a `SECTION_PLACE`:
```php
private function mapSectionPlaces($data): ?array
{
    if (!isset($data['section_place'][0]['id'])) {
        $existingBlock = $this->findBlockById(self::SECTION_PLACE);
        if ($existingBlock !== null) {
            $existingBlock['valid_items'] = [];
            return $existingBlock;
        }
        return null;
    }
    // logica esistente invariata
    ...
}
```

---

### 5. `mapSectionNews()` e `mapSectionEvents()` — fallback se sezione attiva ma nessuna modalità selezionata

Con il fix 1, se il blocco SECTION_NEWS esiste nell'XML ma è ListaManuale con pool vuota, il form mostra la sezione news come attiva (`add_section_news = true`), ma né `section_latest_news` né `section_news` avranno items. In questo caso `mapSectionNews()` attuale restituisce `null`.

**Fix:** aggiungere un ramo `elseif` che preserva il blocco corrente quando `add_section_news = true` ma nessuna modalità è attiva:
```php
} elseif ($data['add_section_news'] ?? false) {
    // sezione attiva nel form ma nessuna configurazione: preserva il blocco corrente
    $currentBlock = $this->findBlockById(self::SECTION_NEWS) ?? $originalBlockNews;
    $currentBlock['name'] = $originalBlockNews['name'];
    return $currentBlock;
}
```

Stesso pattern per `mapSectionEvents()`.

---

## Comportamento dopo il fix

| Stato pool | Azione redattore | Prima | Dopo |
|-----------|-----------------|-------|------|
| Vuota | Salva senza toccare | Blocchi eliminati ❌ | Blocchi preservati ✅ |
| Vuota | Deseleziona `add_section_banner` | Blocco eliminato | Blocco eliminato ✅ |
| Popolata | Salva normale | Funziona | Funziona ✅ |
| Popolata | Rimuove tutti gli items banner | Blocco eliminato | Blocco eliminato ✅ |
| Qualsiasi | Salva con items | Funziona | Funziona ✅ |

---

## Verifica

1. **Setup locale:** aprire bugliano-qa o un'istanza con homepage configurata
2. **Simulare pool vuota:** `DELETE FROM ezm_pool WHERE block_id IN ('3213d4722665b8ca7155847fb767eb62', 'd406949b1e96173e51f6a5492c699daf')` sulla DB locale
3. **Aprire il form:** `https://<istanza>/forms/connector/lock_edit/?object=<homepage_id>` — verificare che le sezioni siano mostrate come attive (checkbox checked)
4. **Salvare senza modifiche** — verificare che `ezm_block` conservi tutti i blocchi:
   ```sql
   SELECT id, block_type FROM ezm_block WHERE node_id = <homepage_node_id>
   ```
5. **Test regressione:** salvare con items normali e verificare che tutto funzioni come prima
6. **Test rimozione intenzionale:** deselezionare `add_section_banner` e salvare — verificare che il blocco venga rimosso correttamente
