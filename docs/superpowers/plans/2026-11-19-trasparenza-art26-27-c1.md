# Sovvenzioni, contributi, sussidi, vantaggi economici (artt. 26-27, profilo C1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pubblicare gli export CSV/JSON conformi allo schema ANAC artt. 26-27 (Sovvenzioni, contributi, sussidi, vantaggi economici) per il profilo C1, con due nuovi dataset redazionali ("Criteri e modalità di concessione", "Atti di concessione") e il relativo wiring cron/installer.

**Architecture:** Due nuovi content object di classe `dataset` (stesso pattern già in produzione per art.20/art.36 in `trasparenza-additional-anac-schemes`), un nuovo serializzatore `Art2627Serializer` che legge le righe dei due dataset e produce CSV (sempre) e JSON (con `intestazione` comune, omesso se il dataset è vuoto), pubblicati via `ExportPublisher` sotto 4 identificativi di schema distinti con nomi file coerenti con gli esempi reali della Guida ANAC. **Entrambe le pagine esistono già** nell'alberatura base di `trasparenza-c1` ("Criteri e modalità", remote_id `5f467d7b4dc96527d061f8d8bf96168d`, e "Atti di concessione", remote_id `90b631e882ab0f966d03aababf3d9f15`) con contenuto legacy pre-ANAC — nessuna pagina nuova da creare, solo due `patch_content` simmetrici che sostituiscono guida/messaggio e agganciano i due dataset. Un interruttore ini opzionale (Registro Nazionale degli Aiuti) sopprime dataset+export della sola sezione "Atti di concessione" quando configurato.

**Tech Stack:** PHP 7.4, eZ Publish Legacy, `OpendataDatasetSearchableRepository` (lettura righe dataset), `eZClusterFileHandler` (scrittura file), YAML installer (`ocinstaller`).

**Spec:** Issue GitLab #527 (https://gitlab.com/opencity-labs/sito-istituzionale/cms/-/work_items/527, profilo C1 — il profilo C2 è nella issue collegata #555, non in questo piano). I due dataset vanno costruiti esattamente come già configurati da Federica su un tenant QA (oggetti reali, letti via API il 2026-11-19 — vedi Task 3 e Task 7 per i valori esatti verificati, fonte di verità più affidabile della sola tabella dell'issue).

## Global Constraints

- Solo profilo **C1** in questo piano — nessun file/step per C2 (alberatura "Società trasparente", trasparenza-c2).
- Due identificativi di schema per il JSON, **mai** l'identificativo nudo `art.26-27`: `art.26-27-criteri` (CSV+JSON criteri, stesso identificativo per entrambi i formati) e `art.26-27-atti` (solo JSON atti — CSV atti-concessione e CSV atto-revoca hanno i propri identificativi separati, `art.26-27-atti-concessione` e `art.26-27-atto-revoca`). Nomi file risultanti: `art.26-27-criteri-YYYYMMDD-YYYYMMDD.{csv,json}`, `art.26-27-atti-concessione-YYYYMMDD-YYYYMMDD.csv`, `art.26-27-atto-revoca-YYYYMMDD-YYYYMMDD.csv`, `art.26-27-atti-YYYYMMDD-YYYYMMDD.json` — verificati uguali ai file di esempio scaricabili dalla Guida Online ANAC.
- **Nessuna validazione incrociata tra campi del dataset** (es. PEO/PEC, revoca parziale, atto attuativo parziale): confermato con Marco il 2026-11-19, non esiste un meccanismo per questo nei dataset e non va costruito. L'unica guida è testuale, nel campo `description` di ciascun field (mostrato come helper sotto il campo nel form) — replicare esattamente i testi già scritti da Federica (Task 3/7), non inventarne di nuovi.
- **Validazione del telefono invece sì**: `telefono_resp_proc` deve rispettare il pattern ANAC per numeri italiani prima della pubblicazione (export-time, non form-time) — lanciare un'eccezione di dominio dedicata (`InvalidTelefonoException`), mai pubblicare un valore non conforme. Decisione esplicita di Marco il 2026-11-19.
- `anno_atto_revoca` è di tipo **integer** nel dataset (verificato sull'oggetto reale su QA, id 40402) — non `string`.
- Importi sempre tramite `\OpenPABootstrapItalia\Anac\ImportoNormalizer::normalize()` (riuso, non reinventare la validazione formato).
- Ogni `patch_content`/`content` nell'installer segue il pattern già in uso in `trasparenza-additional-anac-schemes/installer.yml`: creazione del dataset condizionata a `content_exists()` sulla pagina target, `zone_id`/`block_id` **mai riusati** da altri schemi dello stesso modulo.
- **Solo ita-IT in questo lavoro, niente ger-DE**: decisione esplicita di Marco il 2026-11-19 — le traduzioni tedesche (dataset, pagine, guide) si faranno tutte insieme nel 2027, non ora. Nessuno step `php_callable: patchContentAttributeForLanguage` per ger-DE in questo piano, nessun blocco `ger-DE:` nei nuovi file YAML — le pagine esistenti restano con il loro `ger-DE:` legacy invariato (verrà aggiornato nel 2027, insieme al resto).
- Nessun bump di versione per le nuove opzioni `schema_pubblicazione` (additivo, stesso precedente di art.20 — vedi `trasparenza-additional-anac-schemes/CLAUDE.md`, sezione "Nessun bump di versione di trasparenza").
- "L'adesione allo schema deve restare una scelta dell'ente" (issue #527): già soddisfatto dal modulo opzionale esistente (`trasparenza-additional-anac-schemes`, installato per singolo ente via `ocinstall`) — nessun interruttore aggiuntivo da costruire per questo. Il solo caso che richiede un interruttore dedicato è il Registro Nazionale degli Aiuti (Task 12), che riguarda la sola sezione "Atti di concessione" — e lì l'interruttore agisce all'installazione (il dataset/blocco non viene proprio installato), non solo a runtime.

## Review Focus

- **Dataset "Criteri e modalità" vuoto**: il JSON deve essere omesso del tutto (schema reale, `criteriModalita` ha `minItems: 1`), non pubblicato come array vuoto — la parte pura (`raggruppaPerAttoNormativo([]) === []`, che fa scattare il `return null` di `toJsonCriteri()`) è implicita nel test del Task 3; il comportamento end-to-end va confermato manualmente in Task 13 (fetchRighe* richiede il kernel, non testabile in isolamento).
- **Dataset "Atti di concessione" vuoto**: stesso principio per `attiDiConcessione` (`minItems: 1`) — il CSV si pubblica comunque (solo header), il JSON va omesso (guardia esplicita in `publishArt2627()`, Task 10, prima di chiamare `publishWithDates()`) — comportamento end-to-end da confermare manualmente in Task 13, stesso motivo di sopra.
- **Telefono malformato**: una riga con `telefono_resp_proc` che non rispetta il pattern italiano deve far fallire l'intero export dello schema `art.26-27-atti`/`art.26-27-atti-concessione` con un errore esplicito in log, non pubblicare un JSON/CSV con un valore che lo schema ANAC rifiuterebbe — testato in Task 5.
- **Due atti normativi con numero/anno/link identici ma su righe diverse** (stesso atto normativo, più atti attuativi) devono confluire in un unico blocco `AttoNormativo` nel JSON, con `attiAmministrativi` come array — non in due blocchi separati, non in un `attiAmministrativi` innestato dentro se stesso — testato in Task 4.
- **Entrambe le pagine già esistenti hanno contenuto legacy**: "Atti di concessione" rimanda al vecchio meccanismo a tag "Sovvenzione/contributo", "Criteri e modalità" rimanda a "aggiungere la collocazione del Regolamento per la concessione di contributi" (entrambe pre-ANAC) — i due `patch_content` devono sostituire `guida_alla_compilazione`/`messaggio_di_consiglio`, non limitarsi ad aggiungere `schema_pubblicazione` lasciando il testo vecchio fuorviante — testato in Task 9.
- **Un dataset assente o un errore su un lato non deve bloccare l'altro**: su un ente con Registro Nazionale degli Aiuti configurato, "Atti di concessione" non esiste affatto (Task 6/9) — "Criteri e modalità" deve comunque pubblicarsi. E un telefono malformato in un atto di concessione (eccezione, Task 1) non deve impedire la pubblicazione dei criteri nella stessa esecuzione del cron, né viceversa — per questo `publishArt2627()` (Task 10) ha due try/catch indipendenti, non uno unico per entrambi i lati.

---

## Task 1: `InvalidTelefonoException` + `TelefonoNormalizer`

**Files:**
- Create: `classes/anac/InvalidTelefonoException.php`
- Create: `classes/anac/TelefonoNormalizer.php`
- Test: `tests/test_anac_telefono_normalizer.php`

**Interfaces:**
- Produces: `\OpenPABootstrapItalia\Anac\TelefonoNormalizer::normalize(string $raw): string` (throws `InvalidTelefonoException`), usata da `Art2627Serializer::mapRigaAtti()` (Task 5).

- [ ] **Step 1: Scrivere il test (fallirà, le classi non esistono ancora)**

```php
<?php
/**
 * Test di TelefonoNormalizer (logica pura, nessun kernel eZ).
 * Run: php tests/test_anac_telefono_normalizer.php
 */

require __DIR__ . '/../classes/anac/InvalidTelefonoException.php';
require __DIR__ . '/../classes/anac/TelefonoNormalizer.php';

use OpenPABootstrapItalia\Anac\TelefonoNormalizer;
use OpenPABootstrapItalia\Anac\InvalidTelefonoException;

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
function run($raw)
{
    try {
        return TelefonoNormalizer::normalize($raw);
    } catch (InvalidTelefonoException $e) {
        return 'EXC';
    }
}

// Validi (esempi dallo schema commons-v1.0.schema.json)
check('fisso con prefisso', '+39 06 12345678', run('+39 06 12345678'));
check('fisso senza prefisso', '06 12345678', run('06 12345678'));
check('fisso provincia lunga', '+39 0382 123456', run('+39 0382 123456'));
check('cellulare senza prefisso', '333 1234567', run('333 1234567'));
check('cellulare con prefisso', '+39 333 1234567', run('+39 333 1234567'));
check('fisso senza spazi', '0612345678', run('0612345678'));
check('cellulare senza spazi', '3331234567', run('3331234567'));
check('con trim esterno', '06 12345678', run('  06 12345678  '));

// Non validi
check('vuoto', 'EXC', run(''));
check('testo', 'EXC', run('non è un numero'));
check('url', 'EXC', run('https://esempio.it/telefono'));
check('troppo corto', 'EXC', run('123'));
check('email', 'EXC', run('ufficio@esempio.it'));

echo "\nPassed: $passed, Failed: $failed\n";
exit($failed > 0 ? 1 : 0);
```

- [ ] **Step 2: Eseguire il test, verificare che fallisca**

Run: `php tests/test_anac_telefono_normalizer.php`
Expected: errore fatale, `InvalidTelefonoException`/`TelefonoNormalizer` non trovate (i file non esistono ancora).

- [ ] **Step 3: Creare l'eccezione**

```php
<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Numero di telefono non conforme al pattern ANAC per numeri italiani
 * (schema commons-v1.0.schema.json, definizione Telefono): l'export fallisce
 * esplicitamente invece di pubblicare un valore che lo schema JSON ANAC
 * rifiuterebbe - stesso principio di InvalidVocabolarioException/
 * InvalidImportoException/MissingCodiceFiscaleException.
 */
class InvalidTelefonoException extends \Exception
{
}
```

- [ ] **Step 4: Creare il normalizzatore**

```php
<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Valida un recapito telefonico contro il pattern ANAC per numeri italiani
 * (schema commons-v1.0.schema.json, definizione Telefono - verificato
 * scaricando lo schema il 2026-11-19):
 *   ^(\+39)?\s?(0\d{1,4}[\s\-]?\d{4,8}|3\d{2}[\s\-]?\d{6,7})$
 *
 * A differenza di ImportoNormalizer, non trasforma il valore in una forma
 * canonica diversa - lo schema ammette varianti di spaziatura equivalenti
 * (es. "06 12345678" e "0612345678" sono entrambe valide) - si limita a
 * un trim e alla validazione del pattern, restituendo il valore cosi'
 * com'e' se valido.
 */
class TelefonoNormalizer
{
    const PATTERN = '/^(\+39)?\s?(0\d{1,4}[\s\-]?\d{4,8}|3\d{2}[\s\-]?\d{6,7})$/';

    /**
     * @param mixed $raw
     * @return string
     * @throws InvalidTelefonoException
     */
    public static function normalize($raw)
    {
        $value = trim((string)$raw);

        if ($value === '' || !preg_match(self::PATTERN, $value)) {
            throw new InvalidTelefonoException(
                "Numero di telefono '" . (string)$raw . "' non conforme al pattern ANAC per numeri italiani "
                . "(es. '06 12345678', '+39 333 1234567')"
            );
        }

        return $value;
    }
}
```

- [ ] **Step 5: Eseguire il test, verificare che passi**

Run: `php tests/test_anac_telefono_normalizer.php`
Expected: `Passed: 13, Failed: 0`

- [ ] **Step 6: Commit**

```bash
git add classes/anac/InvalidTelefonoException.php classes/anac/TelefonoNormalizer.php tests/test_anac_telefono_normalizer.php
git commit -m "feat: aggiunge TelefonoNormalizer per validare i recapiti ANAC art.26-27"
```

---

## Task 2: `SchemaPubblicazioneLookup` — nuovi identificativi di schema

**Files:**
- Modify: `classes/SchemaPubblicazioneLookup.php:35-57` (OPTION_IDS), `:68-88` (LABELS)

**Interfaces:**
- Produces: 4 nuove chiavi in `OPTION_IDS`/`LABELS`, usate da `cronjobs/anac_export.php` (Task 10) per risolvere i nodi via `$schemaBindings` e dal template (già generico, nessuna modifica necessaria).

- [ ] **Step 1: Aggiungere le 4 chiavi a `OPTION_IDS`** (prossimi id liberi: 22-25, verificato — l'ultimo usato è 21 per `art.20-c2`)

In `classes/SchemaPubblicazioneLookup.php`, nel blocco `const OPTION_IDS = [...]`, dopo `'art.20-c2' => 21,`:

```php
        'art.26-27-criteri' => 22,
        'art.26-27-atti-concessione' => 23,
        'art.26-27-atto-revoca' => 24,
        'art.26-27-atti' => 25,
```

- [ ] **Step 2: Aggiungere le etichette a `LABELS`**

Nel blocco `const LABELS = [...]`, dopo `'art.20-c2' => 'Staff bonus allocation criteria',`:

```php
        'art.26-27-criteri' => 'Grant criteria and procedures',
        'art.26-27-atti-concessione' => 'Grant acts',
        'art.26-27-atto-revoca' => 'Grant acts',
        'art.26-27-atti' => 'Grant acts',
```

(Stesso principio già in uso per `art.13-pa`/`art.13-se`, che condividono l'etichetta "Organisation": più identificativi tecnici della stessa famiglia logica condividono l'etichetta leggibile dal cittadino.)

- [ ] **Step 3: Verificare che il file sia sintatticamente valido**

Run: `php -l classes/SchemaPubblicazioneLookup.php`
Expected: `No syntax errors detected`

- [ ] **Step 4: Commit**

```bash
git add classes/SchemaPubblicazioneLookup.php
git commit -m "feat: aggiunge gli identificativi di schema art.26-27 a SchemaPubblicazioneLookup"
```

---

## Task 3: `Art2627Serializer` — criteri e modalità (art. 26 co. 1)

**Files:**
- Create: `classes/anac/Serializer/Art2627Serializer.php`
- Test: `tests/test_art2627_criteri.php`

**Interfaces:**
- Consumes: `\OpenPABootstrapItalia\Anac\TelefonoNormalizer::normalize()` (Task 1, usato nella parte "atti" di Task 5, non qui), `\OpenPABootstrapItalia\Anac\CsvLineBuilder::line(array $fields, $delimiter = ';')`, `\OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione()`.
- Produces: `Art2627Serializer::__construct(\eZContentObjectAttribute $criteriAttribute = null, \eZContentObjectAttribute $attiAttribute = null)` (entrambi nullable, vedi nota nel codice), `::mapRigaCriteri(array $data): array`, `::raggruppaPerAttoNormativo(array $righeMappate): array`, `::toCsvCriteri(): string`, `::toJsonCriteri($dataPrimaPubblicazione, $dataUltimaModifica): string|null`. Consumato da `cronjobs/anac_export.php` (Task 10).

Il dataset reale "Criteri e modalità di concessione" su un tenant QA (oggetto 40403, letto via API il 2026-11-19) ha questi field identifier nel `csv_resource`: `numero_atto_normativo`, `anno_atto_normativo`, `link_atto_normativo`, `numero_atto_attuativo`, `anno_atto_attuativo`, `link_atto_attuativo` — usarli esattamente così (non quelli ipotizzati nella issue, se mai divergessero).

- [ ] **Step 1: Scrivere il test delle funzioni pure (fallirà, la classe non esiste)**

```php
<?php
/**
 * Test di Art2627Serializer::mapRigaCriteri()/raggruppaPerAttoNormativo()/
 * toCsvCriteri()/toJsonCriteri() (logica pura su righe gia' mappate - non
 * richiede il kernel eZ, stesso principio di test_anac_importo_normalizer.php).
 * Run: php tests/test_art2627_criteri.php
 */

require __DIR__ . '/../classes/anac/CsvLineBuilder.php';
require __DIR__ . '/../classes/anac/Serializer/Art2627Serializer.php';

use OpenPABootstrapItalia\Anac\Serializer\Art2627Serializer;

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

// Nota: Art2627Serializer non espone un costruttore senza argomenti per i
// metodi statici/puri - li chiamiamo via Reflection per non dover costruire
// due eZContentObjectAttribute finti solo per testare logica che non li usa.
$ref = new ReflectionClass(Art2627Serializer::class);
$instance = $ref->newInstanceWithoutConstructor();

$mapRiga = $ref->getMethod('mapRigaCriteri');
$mapRiga->setAccessible(true);
$raggruppa = $ref->getMethod('raggruppaPerAttoNormativo');
$raggruppa->setAccessible(true);

// --- mapRigaCriteri() ---
$rigaConAttuativo = $mapRiga->invoke($instance, [
    'numero_atto_normativo' => 'N. 175',
    'anno_atto_normativo' => '2022',
    'link_atto_normativo' => 'https://esempio.it/atto175',
    'numero_atto_attuativo' => 'Bando 3',
    'anno_atto_attuativo' => '2023',
    'link_atto_attuativo' => 'https://esempio.it/bando3',
]);
check('mapRigaCriteri numeroAttoNormativo', 'N. 175', $rigaConAttuativo['numeroAttoNormativo']);
check('mapRigaCriteri annoAttoNormativo (int)', 2022, $rigaConAttuativo['annoAttoNormativo']);
check('mapRigaCriteri numeroAttoAttuativo', 'Bando 3', $rigaConAttuativo['numeroAttoAttuativo']);
check('mapRigaCriteri annoAttoAttuativo (int)', 2023, $rigaConAttuativo['annoAttoAttuativo']);

$rigaSenzaAttuativo = $mapRiga->invoke($instance, [
    'numero_atto_normativo' => 'N. 10',
    'anno_atto_normativo' => '2021',
    'link_atto_normativo' => 'https://esempio.it/atto10',
    'numero_atto_attuativo' => '',
    'anno_atto_attuativo' => '',
    'link_atto_attuativo' => '',
]);
check('mapRigaCriteri senza attuativo -> null', null, $rigaSenzaAttuativo['numeroAttoAttuativo']);

// --- raggruppaPerAttoNormativo() ---
$rigaConAttuativo2 = $mapRiga->invoke($instance, [
    'numero_atto_normativo' => 'N. 175',
    'anno_atto_normativo' => '2022',
    'link_atto_normativo' => 'https://esempio.it/atto175',
    'numero_atto_attuativo' => 'Avviso 7',
    'anno_atto_attuativo' => '2023',
    'link_atto_attuativo' => 'https://esempio.it/avviso7',
]);

$gruppi = $raggruppa->invoke($instance, [$rigaConAttuativo, $rigaConAttuativo2, $rigaSenzaAttuativo]);
check('raggruppaPerAttoNormativo: 2 gruppi', 2, count($gruppi));

$gruppoConDueAttuativi = null;
$gruppoSenzaAttuativi = null;
foreach ($gruppi as $gruppo) {
    if ($gruppo['attoNormativo']['numero'] === 'N. 175') {
        $gruppoConDueAttuativi = $gruppo;
    }
    if ($gruppo['attoNormativo']['numero'] === 'N. 10') {
        $gruppoSenzaAttuativi = $gruppo;
    }
}
check('gruppo N.175 ha 2 attiAmministrativi', 2, count($gruppoConDueAttuativi['attiAmministrativi']));
check('gruppo N.10 non ha attiAmministrativi (omesso)', true, $gruppoSenzaAttuativi['attiAmministrativi'] === null);

// --- toCsvCriteri() / toJsonCriteri() via metodi pubblici puri separati ---
// (coperti dal test kernel-dipendente nella issue GitLab #527, sezione Test
// punti 3-5 - qui testiamo solo che il motore di raggruppamento/mappatura
// sia corretto, che è la parte a rischio di bug logici.)

echo "\nPassed: $passed, Failed: $failed\n";
exit($failed > 0 ? 1 : 0);
```

- [ ] **Step 2: Eseguire il test, verificare che fallisca**

Run: `php tests/test_art2627_criteri.php`
Expected: errore, classe `Art2627Serializer` non trovata.

- [ ] **Step 3: Creare la classe (solo la parte "criteri" per ora)**

```php
<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

/**
 * artt. 26-27 d.lgs. 33/2013 - Sovvenzioni, contributi, sussidi, vantaggi
 * economici (cms#527), schema ad adesione volontaria, profilo C1. Due
 * dataset content object distinti (classe dataset, csv_resource) - stesso
 * pattern di Art20Serializer/Art4BisSerializer, un solo serializzatore per
 * entrambe le sotto-sezioni (stessa famiglia logica, come Art20Serializer
 * per co.1/co.2).
 *
 * Due identificativi JSON distinti CON NOMI FILE distinti (non uno nudo
 * "art.26-27" condiviso) - verificato scaricando sia il JSON Schema reale
 * (art.26-27-v1.0.schema.json, vincolo oneOf: un file contiene o
 * criteriModalita o attiDiConcessione, mai entrambi) sia la pagina della
 * Guida Online (link di esempio "art.26-27-criteri-...json" e
 * "art.26-27-atti-...json", nomi distinti) il 2026-11-19.
 */
class Art2627Serializer
{
    const SCHEMA_IDENTIFIER_CRITERI = 'art.26-27-criteri';
    const SCHEMA_IDENTIFIER_ATTI_CONCESSIONE = 'art.26-27-atti-concessione';
    const SCHEMA_IDENTIFIER_ATTO_REVOCA = 'art.26-27-atto-revoca';
    const SCHEMA_IDENTIFIER_ATTI = 'art.26-27-atti';
    const SCHEMA_URL = 'https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.26-27-v1.0.schema.json';

    /** @var \eZContentObjectAttribute|null */
    private $criteriAttribute;

    /** @var \eZContentObjectAttribute|null */
    private $attiAttribute;

    /**
     * Entrambi gli argomenti sono nullable: a differenza di Art20Serializer
     * (dove i due dataset della stessa famiglia sono sempre installati
     * insieme), qui "Atti di concessione" può mancare da solo quando il
     * Registro Nazionale degli Aiuti è configurato per l'ente (il dataset
     * non viene proprio installato in quel caso - vedi
     * BootstrapItaliaInstallerUtils::canInstallAttiConcessioneDataset()) -
     * "Criteri e modalità" deve continuare a funzionare comunque. Il
     * chiamante (publishArt2627(), Task 10) passa null per l'attributo del
     * dataset che non esiste su questo sito, e chiama solo i metodi del
     * lato corrispondente.
     */
    public function __construct(
        \eZContentObjectAttribute $criteriAttribute = null,
        \eZContentObjectAttribute $attiAttribute = null
    ) {
        $this->criteriAttribute = $criteriAttribute;
        $this->attiAttribute = $attiAttribute;
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

    // ---------------------------------------------------------------
    // art. 26 co. 1 - Criteri e modalità
    // ---------------------------------------------------------------

    public function fetchRigheCriteri()
    {
        return $this->fetchRighe($this->criteriAttribute);
    }

    /**
     * Field identifier del dataset "Criteri e modalità di concessione" -
     * verificati sull'oggetto reale (tenant QA, id 40403) il 2026-11-19,
     * non ipotizzati dalla sola issue.
     *
     * numeroAttoAttuativo/annoAttoAttuativo/linkAttoAttuativo sono null se
     * il campo numero_atto_attuativo e' vuoto - una riga senza atto
     * attuativo (issue: "un atto normativo senza atti attuativi") non ha
     * nessuno dei tre valorizzato.
     */
    public function mapRigaCriteri(array $data)
    {
        $numeroAttuativo = trim((string)($data['numero_atto_attuativo'] ?? ''));

        return [
            'numeroAttoNormativo' => trim((string)$data['numero_atto_normativo']),
            'annoAttoNormativo' => (int)trim((string)$data['anno_atto_normativo']),
            'linkAttoNormativo' => trim((string)$data['link_atto_normativo']),
            'numeroAttoAttuativo' => $numeroAttuativo !== '' ? $numeroAttuativo : null,
            'annoAttoAttuativo' => $numeroAttuativo !== '' ? (int)trim((string)$data['anno_atto_attuativo']) : null,
            'linkAttoAttuativo' => $numeroAttuativo !== '' ? trim((string)$data['link_atto_attuativo']) : null,
        ];
    }

    /**
     * Raggruppa le righe (gia' mappate con mapRigaCriteri()) per atto
     * normativo (chiave: numero+anno+link, la stessa tripla si ripete su
     * ogni riga del CSV per lo stesso atto - vedi issue #527): righe con la
     * stessa tripla confluiscono in un unico blocco con 'attiAmministrativi'
     * come array, nell'ordine di prima comparsa. Un atto normativo le cui
     * righe non hanno mai un atto attuativo produce un gruppo con
     * 'attiAmministrativi' = null (da omettere nel JSON, mai [] vuoto - lo
     * schema reale non ha minItems su questo array annidato ma l'esempio
     * ANAC lo omette per coerenza con l'assenza del dato).
     *
     * @param array $righeMappate righe gia' passate per mapRigaCriteri()
     * @return array lista di ['attoNormativo' => ['numero','anno','link'], 'attiAmministrativi' => array|null]
     */
    public function raggruppaPerAttoNormativo(array $righeMappate)
    {
        $gruppi = [];
        $ordine = [];

        foreach ($righeMappate as $riga) {
            $chiave = $riga['numeroAttoNormativo'] . '|' . $riga['annoAttoNormativo'] . '|' . $riga['linkAttoNormativo'];

            if (!isset($gruppi[$chiave])) {
                $gruppi[$chiave] = [
                    'attoNormativo' => [
                        'numero' => $riga['numeroAttoNormativo'],
                        'anno' => $riga['annoAttoNormativo'],
                        'link' => $riga['linkAttoNormativo'],
                    ],
                    'attiAmministrativi' => null,
                ];
                $ordine[] = $chiave;
            }

            if ($riga['numeroAttoAttuativo'] !== null) {
                if ($gruppi[$chiave]['attiAmministrativi'] === null) {
                    $gruppi[$chiave]['attiAmministrativi'] = [];
                }
                $gruppi[$chiave]['attiAmministrativi'][] = [
                    'numero' => $riga['numeroAttoAttuativo'],
                    'anno' => $riga['annoAttoAttuativo'],
                    'link' => $riga['linkAttoAttuativo'],
                ];
            }
        }

        return array_map(function ($chiave) use ($gruppi) {
            return $gruppi[$chiave];
        }, $ordine);
    }

    /**
     * CSV: una riga per riga di dataset (NON raggruppato - l'atto normativo
     * si ripete, forma richiesta dal CSV ANAC, diversa dalla forma JSON).
     */
    public function toCsvCriteri()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
            'NUM_ATTO_NORMATIVO', 'ANNO_ATTO_NORMATIVO', 'LINK_ATTO_NORMATIVO',
            'NUM_ATTO_AMMINISTRATIVO_ATTUATIVO', 'ANNO_ATTO_AMMINISTRATIVO_ATTUATIVO', 'LINK_ATTO_AMMINISTRATIVO_ATTUATIVO',
        ])];

        foreach (array_map([$this, 'mapRigaCriteri'], $this->fetchRigheCriteri()) as $riga) {
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
                $riga['numeroAttoNormativo'], $riga['annoAttoNormativo'], $riga['linkAttoNormativo'],
                $riga['numeroAttoAttuativo'] ?? '', $riga['annoAttoAttuativo'] ?? '', $riga['linkAttoAttuativo'] ?? '',
            ]);
        }

        return implode("\n", $lines) . "\n";
    }

    /**
     * @return string|null null se il dataset e' vuoto - il chiamante
     *         (publishArt2627() in cronjobs/anac_export.php, Task 10) deve
     *         allora omettere del tutto il JSON (schema reale:
     *         criteriModalita ha minItems: 1, nessuno stato vuoto valido).
     */
    public function toJsonCriteri($dataPrimaPubblicazione, $dataUltimaModifica)
    {
        $righeMappate = array_map([$this, 'mapRigaCriteri'], $this->fetchRigheCriteri());
        $gruppi = $this->raggruppaPerAttoNormativo($righeMappate);

        if (empty($gruppi)) {
            return null;
        }

        $criteriModalita = array_map(function ($gruppo) {
            $atto = ['attoNormativo' => $gruppo['attoNormativo']];
            if ($gruppo['attiAmministrativi'] !== null) {
                $atto['attiAmministrativi'] = $gruppo['attiAmministrativi'];
            }

            return $atto;
        }, $gruppi);

        $data = [
            '$schema' => self::SCHEMA_URL,
            'intestazione' => [
                'amministrazione' => \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione(),
                'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
                'dataUltimaModifica' => $dataUltimaModifica,
            ],
            'criteriModalita' => $criteriModalita,
        ];

        return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }
}
```

- [ ] **Step 4: Eseguire il test, verificare che passi**

Run: `php tests/test_art2627_criteri.php`
Expected: `Passed: 8, Failed: 0`

- [ ] **Step 5: Commit**

```bash
git add classes/anac/Serializer/Art2627Serializer.php tests/test_art2627_criteri.php
git commit -m "feat: aggiunge Art2627Serializer, parte criteri e modalita (art.26 co.1)"
```

---

## Task 4: Verifica manuale JSON criteri (atto normativo senza atti attuativi)

Questo task non aggiunge codice: verifica a mano, prima di proseguire, che `toJsonCriteri()` ometta `attiAmministrativi` (non `[]`) per un atto normativo senza atti attuativi — il punto della issue #527 più a rischio di bug silenzioso (un array vuoto invece di una chiave omessa passa inosservato se non lo si controlla esplicitamente).

- [ ] **Step 1: Script di verifica manuale (scratch, non committare)**

```bash
php -r '
require "classes/anac/CsvLineBuilder.php";
require "classes/anac/Serializer/Art2627Serializer.php";
$ref = new ReflectionClass(\OpenPABootstrapItalia\Anac\Serializer\Art2627Serializer::class);
$instance = $ref->newInstanceWithoutConstructor();
$raggruppa = $ref->getMethod("raggruppaPerAttoNormativo");
$raggruppa->setAccessible(true);
$mapRiga = $ref->getMethod("mapRigaCriteri");
$mapRiga->setAccessible(true);
$riga = $mapRiga->invoke($instance, [
    "numero_atto_normativo" => "N. 10", "anno_atto_normativo" => "2021", "link_atto_normativo" => "https://x",
    "numero_atto_attuativo" => "", "anno_atto_attuativo" => "", "link_atto_attuativo" => "",
]);
$gruppi = $raggruppa->invoke($instance, [$riga]);
var_dump(array_key_exists("attiAmministrativi", $gruppi[0]) && $gruppi[0]["attiAmministrativi"] === null);
'
```

Expected: `bool(true)` — conferma che il gruppo ha la chiave `attiAmministrativi` ma valorizzata `null` (che `toJsonCriteri()` traduce in "chiave omessa dal JSON", non in `[]`).

- [ ] **Step 2: Nessun commit (verifica, non modifica di codice)**

---

## Task 5: `Art2627Serializer` — atti di concessione (artt. 26 co. 2 e 27)

**Files:**
- Modify: `classes/anac/Serializer/Art2627Serializer.php` (aggiunge la parte "atti")
- Test: `tests/test_art2627_atti.php`

**Interfaces:**
- Consumes: `\OpenPABootstrapItalia\Anac\ImportoNormalizer::normalize()`, `\OpenPABootstrapItalia\Anac\TelefonoNormalizer::normalize()` (Task 1), `\OpenPABootstrapItalia\Anac\InvalidTelefonoException`.
- Produces: `::mapRigaAtti(array $data): array` (può lanciare `InvalidTelefonoException`), `::toCsvAttiConcessione(): string`, `::toCsvAttoRevoca(): string`, `::toJsonAtti($dataPrimaPubblicazione, $dataUltimaModifica): string|null`.

Field identifier del dataset reale "Atti di concessione" (tenant QA, id 40402, letto il 2026-11-19): `numero`, `anno`, `beneficiario`, `importo`, `identificativo_norma`, `nominativo_resp_proc`, `qualifica_resp_proc`, `ufficio_resp_proc`, `telefono_resp_proc`, `peo`, `pec`, `modalita_individuazione`, `link_progetto`, `numero_atto_revoca`, `anno_atto_revoca` (**integer**), `motivazione_revoca`.

- [ ] **Step 1: Scrivere il test (fallirà, i metodi non esistono ancora)**

```php
<?php
/**
 * Test di Art2627Serializer::mapRigaAtti() (logica pura - non richiede il
 * kernel eZ).
 * Run: php tests/test_art2627_atti.php
 */

require __DIR__ . '/../classes/anac/CsvLineBuilder.php';
require __DIR__ . '/../classes/anac/InvalidImportoException.php';
require __DIR__ . '/../classes/anac/ImportoNormalizer.php';
require __DIR__ . '/../classes/anac/InvalidTelefonoException.php';
require __DIR__ . '/../classes/anac/TelefonoNormalizer.php';
require __DIR__ . '/../classes/anac/Serializer/Art2627Serializer.php';

use OpenPABootstrapItalia\Anac\Serializer\Art2627Serializer;
use OpenPABootstrapItalia\Anac\InvalidTelefonoException;

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

$ref = new ReflectionClass(Art2627Serializer::class);
$instance = $ref->newInstanceWithoutConstructor();
$mapRigaAtti = $ref->getMethod('mapRigaAtti');
$mapRigaAtti->setAccessible(true);

$rigaBase = [
    'numero' => '123', 'anno' => '2026', 'beneficiario' => 'Acme S.r.l. - 12345678901',
    'importo' => '1500', 'identificativo_norma' => 'Delibera 5/2026',
    'nominativo_resp_proc' => 'Mario Rossi', 'qualifica_resp_proc' => 'Dirigente',
    'ufficio_resp_proc' => 'Ufficio Contributi', 'telefono_resp_proc' => '06 12345678',
    'peo' => 'contributi@comune.it', 'pec' => '', 'modalita_individuazione' => 'Avviso pubblico',
    'link_progetto' => '', 'numero_atto_revoca' => '', 'anno_atto_revoca' => '', 'motivazione_revoca' => '',
];

$riga = $mapRigaAtti->invoke($instance, $rigaBase);
check('mapRigaAtti importo normalizzato', '1.500,00', $riga['importo']);
check('mapRigaAtti telefono validato', '06 12345678', $riga['responsabile']['telefono']);
check('mapRigaAtti senza revoca -> null', null, $riga['revoca']);
check('mapRigaAtti peo presente', 'contributi@comune.it', $riga['responsabile']['peo'] ?? null);

$rigaConRevoca = $mapRigaAtti->invoke($instance, array_merge($rigaBase, [
    'numero_atto_revoca' => '7', 'anno_atto_revoca' => '2026', 'motivazione_revoca' => 'Rinuncia del beneficiario',
]));
check('mapRigaAtti con revoca: numero', '7', $rigaConRevoca['revoca']['numero']);
check('mapRigaAtti con revoca: anno (int)', 2026, $rigaConRevoca['revoca']['anno']);
check('mapRigaAtti con revoca: motivazione', 'Rinuncia del beneficiario', $rigaConRevoca['revoca']['motivazione']);

// Telefono malformato: deve lanciare, non pubblicare un valore non conforme.
$harLanciato = false;
try {
    $mapRigaAtti->invoke($instance, array_merge($rigaBase, ['telefono_resp_proc' => 'non è un numero']));
} catch (InvalidTelefonoException $e) {
    $harLanciato = true;
}
check('telefono malformato lancia InvalidTelefonoException', true, $harLanciato);

echo "\nPassed: $passed, Failed: $failed\n";
exit($failed > 0 ? 1 : 0);
```

- [ ] **Step 2: Eseguire il test, verificare che fallisca**

Run: `php tests/test_art2627_atti.php`
Expected: errore, metodo `mapRigaAtti` non trovato.

- [ ] **Step 3: Aggiungere la parte "atti" alla classe** (append dopo `toJsonCriteri()`, prima della chiusura `}`)

```php

    // ---------------------------------------------------------------
    // artt. 26 co. 2 e 27 - Atti di concessione
    // ---------------------------------------------------------------

    public function fetchRigheAtti()
    {
        return $this->fetchRighe($this->attiAttribute);
    }

    /**
     * Field identifier del dataset "Atti di concessione" - verificati
     * sull'oggetto reale (tenant QA, id 40402) il 2026-11-19.
     *
     * 'revoca' e' null se numero_atto_revoca e' vuoto (nessuna validazione
     * incrociata sulla completezza di numero/anno/motivazione - decisione
     * esplicita di Marco il 2026-11-19, la guida alla compilazione del
     * campo lo richiama solo testualmente).
     *
     * @throws \OpenPABootstrapItalia\Anac\InvalidTelefonoException se
     *         telefono_resp_proc non rispetta il pattern ANAC per numeri
     *         italiani - blocca l'intero export (stesso principio di
     *         InvalidVocabolarioException/InvalidImportoException), mai un
     *         valore pubblicato che lo schema rifiuterebbe.
     */
    public function mapRigaAtti(array $data)
    {
        $numeroRevoca = trim((string)($data['numero_atto_revoca'] ?? ''));

        return [
            'numero' => trim((string)$data['numero']),
            'anno' => (int)trim((string)$data['anno']),
            'beneficiario' => trim((string)$data['beneficiario']),
            'importo' => \OpenPABootstrapItalia\Anac\ImportoNormalizer::normalize($data['importo']),
            'norma' => trim((string)$data['identificativo_norma']),
            'responsabile' => [
                'nominativo' => trim((string)$data['nominativo_resp_proc']),
                'qualifica' => trim((string)$data['qualifica_resp_proc']),
                'ufficio' => trim((string)$data['ufficio_resp_proc']),
                'telefono' => \OpenPABootstrapItalia\Anac\TelefonoNormalizer::normalize($data['telefono_resp_proc']),
                'peo' => trim((string)($data['peo'] ?? '')) !== '' ? trim((string)$data['peo']) : null,
                'pec' => trim((string)($data['pec'] ?? '')) !== '' ? trim((string)$data['pec']) : null,
            ],
            'modalita' => trim((string)$data['modalita_individuazione']),
            'linkProgetto' => trim((string)($data['link_progetto'] ?? '')) !== '' ? trim((string)$data['link_progetto']) : null,
            'revoca' => $numeroRevoca !== '' ? [
                'numero' => $numeroRevoca,
                'anno' => (int)trim((string)$data['anno_atto_revoca']),
                'motivazione' => trim((string)$data['motivazione_revoca']),
            ] : null,
        ];
    }

    public function toCsvAttiConcessione()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
            'NUMERO', 'ANNO', 'BENEFICIARIO', 'IMPORTO', 'IDENTIFICATIVO_NORMA',
            'NOMINATIVO_RESP_PROC', 'QUALIFICA_RESP_PROC', 'UFFICIO_RESP_PROC', 'TELEFONO_UFFICIO_RESP_PROC',
            'PEO', 'PEC', 'MODALITA_INDIVIDUAZIONE_BENEFICIARIO', 'LINK_INFO_PROGETTO',
        ])];

        foreach (array_map([$this, 'mapRigaAtti'], $this->fetchRigheAtti()) as $riga) {
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
                $riga['numero'], $riga['anno'], $riga['beneficiario'], $riga['importo'], $riga['norma'],
                $riga['responsabile']['nominativo'], $riga['responsabile']['qualifica'], $riga['responsabile']['ufficio'],
                $riga['responsabile']['telefono'], $riga['responsabile']['peo'] ?? '', $riga['responsabile']['pec'] ?? '',
                $riga['modalita'], $riga['linkProgetto'] ?? '',
            ]);
        }

        return implode("\n", $lines) . "\n";
    }

    /**
     * Una riga per ciascun record con revoca valorizzata (issue #527: "il
     * CSV ha solo NUMERO;ANNO;MOTIVAZIONE e non contiene alcun riferimento
     * alla concessione revocata") - i tre campi sono quelli della REVOCA,
     * non dell'atto di concessione a cui appartiene il record.
     */
    public function toCsvAttoRevoca()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line(['NUMERO', 'ANNO', 'MOTIVAZIONE'])];

        foreach (array_map([$this, 'mapRigaAtti'], $this->fetchRigheAtti()) as $riga) {
            if ($riga['revoca'] === null) {
                continue;
            }
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
                $riga['revoca']['numero'], $riga['revoca']['anno'], $riga['revoca']['motivazione'],
            ]);
        }

        return implode("\n", $lines) . "\n";
    }

    /**
     * @return string|null null se il dataset e' vuoto - il chiamante
     *         (publishArt2627() in cronjobs/anac_export.php, Task 10) deve
     *         allora omettere del tutto il JSON (schema reale:
     *         attiDiConcessione ha minItems: 1).
     */
    public function toJsonAtti($dataPrimaPubblicazione, $dataUltimaModifica)
    {
        $righe = array_map([$this, 'mapRigaAtti'], $this->fetchRigheAtti());

        if (empty($righe)) {
            return null;
        }

        $attiDiConcessione = array_map(function ($riga) {
            $atto = [
                'numero' => $riga['numero'],
                'anno' => $riga['anno'],
                'beneficiario' => $riga['beneficiario'],
                'importo' => $riga['importo'],
                'norma' => $riga['norma'],
                'responsabile' => array_filter([
                    'nominativo' => $riga['responsabile']['nominativo'],
                    'qualifica' => $riga['responsabile']['qualifica'],
                    'ufficio' => $riga['responsabile']['ufficio'],
                    'contatti' => array_filter([
                        'recapitoTelefonico' => $riga['responsabile']['telefono'],
                        'postaElettronicaOrdinaria' => $riga['responsabile']['peo'],
                        'postaElettronicaCertificata' => $riga['responsabile']['pec'],
                    ], function ($v) {
                        return $v !== null;
                    }),
                ], function ($v) {
                    return $v !== null;
                }),
                'modalita' => $riga['modalita'],
            ];
            if ($riga['linkProgetto'] !== null) {
                $atto['linkProgetto'] = $riga['linkProgetto'];
            }
            if ($riga['revoca'] !== null) {
                $atto['attoDiRevoca'] = $riga['revoca'];
            }

            return $atto;
        }, $righe);

        $data = [
            '$schema' => self::SCHEMA_URL,
            'intestazione' => [
                'amministrazione' => \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione(),
                'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
                'dataUltimaModifica' => $dataUltimaModifica,
            ],
            'attiDiConcessione' => $attiDiConcessione,
        ];

        return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }
```

- [ ] **Step 4: Eseguire il test, verificare che passi**

Run: `php tests/test_art2627_atti.php`
Expected: `Passed: 7, Failed: 0`

- [ ] **Step 5: Verificare la sintassi dell'intero file**

Run: `php -l classes/anac/Serializer/Art2627Serializer.php`
Expected: `No syntax errors detected`

- [ ] **Step 6: Commit**

```bash
git add classes/anac/Serializer/Art2627Serializer.php tests/test_art2627_atti.php
git commit -m "feat: completa Art2627Serializer con atti di concessione e revoca (artt.26 co.2-27)"
```

---

## Task 6: `BootstrapItaliaInstallerUtils` — condizione combinata per il Registro Nazionale degli Aiuti

**Files:**
- Modify: `classes/BootstrapItaliaInstallerUtils.php`

**Interfaces:**
- Produces: `BootstrapItaliaInstallerUtils::canInstallAttiConcessioneDataset(): bool`, usata come variabile `condition` in `installer.yml` (Task 9) per gating sia della creazione del dataset "Atti di concessione" sia del `patch_content` che lo aggancia alla pagina.

**Perché serve una funzione dedicata invece di combinare due variabili installer**: `ocinstaller` valuta `condition:` come verità di una singola variabile già risolta (vedi `Steps.php::run()`, `(bool)$condition !== true`) — non supporta espressioni booleane (AND/OR) tra più variabili nella chiave `condition`. Per esprimere "la pagina esiste davvero **E** l'ente non ha configurato il Registro Nazionale degli Aiuti" serve quindi un'unica funzione PHP che faccia entrambi i controlli internamente, stesso principio già in uso per `resolveComuneSpatialName()`/`fixAnacDatasetSpatialDefault()` in questo stesso file (metodi statici senza argomenti, risolti da `InstallerVars::parseVarValue()` via la sintassi `ClassName::metodo`).

Decisione confermata con Marco il 2026-11-19: quando il Registro Nazionale degli Aiuti è configurato per un ente, **né il dataset né il blocco** "Atti di concessione" vanno installati — non solo nascosti a runtime. Questo evita la necessità di qualunque controllo duplicato lato template/cron (vedi Task 12): se il content/blocco non esiste, non c'è nulla da nascondere né da esportare.

- [ ] **Step 1: Aggiungere il metodo**

```php
    /**
     * Condizione combinata per il dataset "Atti di concessione" (art.26-27,
     * cms#527): va installato solo se la pagina esiste davvero (stesso
     * principio di content_exists(), già usato per gli altri dataset di
     * questo modulo) E se l'ente non ha configurato il rinvio al Registro
     * Nazionale degli Aiuti (openpa.ini, [Trasparenza] RegistroNazionaleAiutiUrl)
     * - in quel caso l'ente pubblica già quei dati lì, il dataset/blocco
     * non va installato affatto (decisione esplicita di Marco il 2026-11-19,
     * non un semplice "nascondilo a runtime"). "Criteri e modalità" non è
     * mai toccata da questa condizione - il Registro Nazionale degli Aiuti
     * non registra i criteri di concessione, solo gli atti.
     *
     * Una singola funzione invece di combinare due variabili installer:
     * ocinstaller non supporta espressioni booleane tra variabili nella
     * chiave `condition`, solo la verità di una singola variabile già
     * risolta - vedi ocinstaller/src/Opencontent/Installer/Steps.php, run().
     */
    public static function canInstallAttiConcessioneDataset()
    {
        $pageExists = \eZContentObject::fetchByRemoteID('90b631e882ab0f966d03aababf3d9f15') instanceof \eZContentObject;
        $registroUrl = trim((string)\OpenPAINI::variable('Trasparenza', 'RegistroNazionaleAiutiUrl', ''));

        return $pageExists && $registroUrl === '';
    }
```

Aggiungerlo accanto agli altri metodi statici senza argomenti già presenti in questo file (es. `resolveTrentinoComuneCode()`, `resolveSiteOrganizationRemoteId()`), stesso stile.

- [ ] **Step 2: Verificare la sintassi del file**

Run: `php -l classes/BootstrapItaliaInstallerUtils.php`
Expected: `No syntax errors detected`

- [ ] **Step 3: Verifica manuale** (nessun test automatico dedicato — stesso trattamento già riservato in questo file agli altri metodi statici di supporto installer, es. `resolveComuneSpatialName()`, mai testati in isolamento perché dipendono dal kernel eZ e da stato DB reale)

Run: `docker exec sito-comunale-dev-app-1 php -r '
require_once "autoload.php";
$script = eZScript::instance(["description" => "check canInstallAttiConcessioneDataset"]);
$script->startup(); $script->initialize();
var_dump(BootstrapItaliaInstallerUtils::canInstallAttiConcessioneDataset());
$script->shutdown();
'`

Expected (su un sito senza la pagina "Atti di concessione" o con l'ini configurata): `bool(false)`. Su un sito con la pagina e l'ini vuota: `bool(true)`.

- [ ] **Step 4: Commit**

```bash
git add classes/BootstrapItaliaInstallerUtils.php
git commit -m "feat: aggiunge la condizione combinata per il dataset Atti di concessione (RNA)"
```

---

## Task 7: Installer — classi dataset (contents YAML)

**Files (repo `installer`):**
- Create: `modules/trasparenza-additional-anac-schemes/contents/Criteri-Modalita-Concessione-Dataset.yml`
- Create: `modules/trasparenza-additional-anac-schemes/contents/Atti-Concessione-Dataset.yml`

**Interfaces:**
- Produces: due nuovi content object (remote_id `criteri_modalita_concessione`, `atti_di_concessione`), consumati da `installer.yml` (Task 9, `valid_items`) e dal cron (Task 10, `eZContentObject::fetchByRemoteID()`).

Contenuto verificato sugli oggetti reali già creati da Federica su un tenant QA (id 40403 "Criteri e modalità di concessione", id 40402 "Atti di concessione", letti via API il 2026-11-19) — replicare esattamente label/description/required/type di ogni field, **non** la versione della tabella nella issue se mai divergesse (la issue è stata scritta prima, l'oggetto reale su QA è la versione finale).

- [ ] **Step 1: Creare il dataset "Criteri e modalità di concessione"**

```yaml
metadata:
    remoteId: criteri_modalita_concessione
    classIdentifier: dataset
    languages:
        - ita-IT
    parentNodes:
        - $datasets_node
data:
    ita-IT:
        title: 'Criteri e modalità di concessione'
        abstract: 'Atti che stabiliscono i criteri e le modalità per concedere sovvenzioni, contributi, sussidi e vantaggi economici, con i relativi bandi e avvisi.'
        theme:
            - 'Governo e settore pubblico'
        format:
            - CSV
        license:
            - 'Creative Commons Attribution 4.0 International (CC BY 4.0)'
        csv_resource:
            apiEnabled: true
            extraUsers: null
            itemName: 'Criterio di concessione'
            views:
                - table
            fields:
                -
                    identifier: numero_atto_normativo
                    label: 'Numero atto normativo'
                    type: string
                    required: 'true'
                    js_label: 'Numero atto normativo'
                    description: 'Numero identificativo dell''atto (legge o regolamento)'
                -
                    identifier: anno_atto_normativo
                    label: 'Anno atto normativo'
                    type: string
                    required: 'true'
                    js_label: 'Anno atto normativo'
                -
                    identifier: link_atto_normativo
                    label: 'Link atto normativo'
                    type: url
                    required: 'true'
                    js_label: 'Link atto normativo'
                    description: 'Link al sito dove l''atto è pubblicato (es.: Normattiva)'
                -
                    identifier: numero_atto_attuativo
                    label: 'Numero atto attuativo'
                    type: string
                    required: 'false'
                    js_label: 'Numero atto attuativo'
                    description: 'Atto amministrativo generale adottato in attuazione (bando, avviso)'
                -
                    identifier: anno_atto_attuativo
                    label: 'Anno atto attuativo'
                    type: string
                    required: 'false'
                    js_label: 'Anno atto attuativo'
                    description: 'Obbligatorio se valorizzato il numero'
                -
                    identifier: link_atto_attuativo
                    label: 'Link atto attuativo'
                    type: url
                    required: 'false'
                    js_label: 'Link atto attuativo'
                    description: 'Obbligatorio se valorizzato il numero'
            facetsSettings:
                - anno_atto_normativo
            isEnabledSearchInput: true
            calendarSettings: {  }
            tableSettings:
                show_fields:
                    - numero_atto_normativo
                    - anno_atto_normativo
                    - link_atto_normativo
                    - numero_atto_attuativo
                    - anno_atto_attuativo
                    - link_atto_attuativo
                view: default
            chartSettings: null
            counterSettings:
                count_field: 'false'
                select_stat: count
            openingView: table
        rights_holder:
            - site-link
        accrualperiodicity:
            - 'In base alla necessità'
        spatial:
            - $comune_nome
        modified: $now
        issued: $now
        language:
            - Italiano
extradata:
    ita-IT:
        urlAlias: /Amministrazione/Documenti-e-dati/Dataset/Criteri-e-modalita-di-concessione
```

> Solo ita-IT (decisione di Marco il 2026-11-19): nessun blocco `ger-DE` qui, la traduzione si farà nel 2027 insieme a tutto il resto.

- [ ] **Step 2: Creare il dataset "Atti di concessione"**

```yaml
metadata:
    remoteId: atti_di_concessione
    classIdentifier: dataset
    languages:
        - ita-IT
    parentNodes:
        - $datasets_node
data:
    ita-IT:
        title: 'Atti di concessione'
        abstract: 'Sovvenzioni, contributi e vantaggi economici concessi dal Comune, con beneficiario, importo, norma di riferimento, responsabile del procedimento ed eventuale revoca.'
        theme:
            - 'Governo e settore pubblico'
        format:
            - CSV
        license:
            - 'Creative Commons Attribution 4.0 International (CC BY 4.0)'
        csv_resource:
            apiEnabled: true
            extraUsers: null
            itemName: 'Atto di concessione'
            views:
                - table
            fields:
                -
                    identifier: numero
                    label: Numero
                    type: string
                    required: 'true'
                    js_label: Numero
                    description: 'Numero identificativo del provvedimento'
                -
                    identifier: anno
                    label: Anno
                    type: string
                    required: 'true'
                    js_label: Anno
                    description: 'Anno di pubblicazione del provvedimento'
                -
                    identifier: beneficiario
                    label: Beneficiario
                    type: string
                    required: 'true'
                    js_label: Beneficiario
                    description: "Se persona giuridica inserire nominativo e CF/P.IVA di 11 cifre\nSe persona fisica inserire nominativo, oppure \"Soggetto privato\" dove emergono esigenze di tutela della riservatezza (art. 26 co. 4, Nota 5)"
                -
                    identifier: importo
                    label: Importo
                    type: amount
                    required: 'true'
                    js_label: Importo
                    description: 'Importo corrisposto, ossia liquidato'
                -
                    identifier: identificativo_norma
                    label: 'Identificativo della norma'
                    type: string
                    required: 'true'
                    js_label: 'Identificativo della norma'
                    description: 'Norma o titolo a base dell''attribuzione; testo o URL, anche rinvio ai criteri ex art. 26 co. 1'
                -
                    identifier: nominativo_resp_proc
                    label: 'Nominativo responsabile del procedimento'
                    type: string
                    required: 'true'
                    js_label: 'Nominativo responsabile del procedimento'
                    description: 'Nome e cognome'
                -
                    identifier: qualifica_resp_proc
                    label: Qualifica
                    type: string
                    required: 'true'
                    js_label: Qualifica
                    description: 'Qualifica rivestita dal responsabile'
                -
                    identifier: ufficio_resp_proc
                    label: Ufficio
                    type: string
                    required: 'true'
                    js_label: Ufficio
                    description: 'Denominazione dell''ufficio'
                -
                    identifier: telefono_resp_proc
                    label: 'Recapito telefonico ufficio'
                    type: string
                    required: 'true'
                    js_label: 'Recapito telefonico ufficio'
                    description: 'Numero telefonico istituzionale'
                -
                    identifier: peo
                    label: PEO
                    type: email
                    required: 'false'
                    js_label: PEO
                    description: 'Inserire almeno una tra PEO e PEC (campo obbligatorio per esportazione ANAC)'
                -
                    identifier: pec
                    label: PEC
                    type: email
                    required: 'false'
                    js_label: PEC
                    description: 'Inserire almeno una tra PEO e PEC (campo obbligatorio per esportazione ANAC)'
                -
                    identifier: modalita_individuazione
                    label: 'Modalità di individuazione del beneficiario'
                    type: string
                    required: 'true'
                    js_label: 'Modalità di individuazione del beneficiario'
                    description: 'Descrizione degli avvisi pubblici oppure URL alla sezione che li pubblica'
                -
                    identifier: link_progetto
                    label: 'Link al progetto'
                    type: string
                    required: 'false'
                    js_label: 'Link al progetto'
                    description: 'Progetto selezionato e curriculum; solo per vantaggi connessi alla presentazione di progetti'
                -
                    identifier: numero_atto_revoca
                    label: 'Numero atto di revoca'
                    type: string
                    required: 'false'
                    js_label: 'Numero atto di revoca'
                    description: 'Atto di modifica o revoca riferito a questo atto di concessione'
                -
                    identifier: anno_atto_revoca
                    label: 'Anno atto di revoca'
                    type: integer
                    required: 'false'
                    js_label: 'Anno atto di revoca'
                    description: 'Obbligatorio se valorizzato il numero'
                -
                    identifier: motivazione_revoca
                    label: 'Motivazione della revoca'
                    type: string
                    required: 'false'
                    js_label: 'Motivazione della revoca'
                    description: 'Obbligatoria se valorizzati numero e anno. Non riportare dati personali'
            facetsSettings:
                - anno
                - ufficio_resp_proc
            isEnabledSearchInput: true
            calendarSettings: {  }
            tableSettings:
                show_fields:
                    - numero
                    - anno
                    - beneficiario
                    - importo
                    - identificativo_norma
                    - nominativo_resp_proc
                    - qualifica_resp_proc
                    - ufficio_resp_proc
                    - telefono_resp_proc
                    - peo
                    - pec
                    - modalita_individuazione
                    - link_progetto
                    - numero_atto_revoca
                    - anno_atto_revoca
                    - motivazione_revoca
                view: default
            chartSettings: null
            counterSettings:
                count_field: 'false'
                select_stat: count
            openingView: table
        rights_holder:
            - site-link
        accrualperiodicity:
            - 'In base alla necessità'
        spatial:
            - $comune_nome
        modified: $now
        issued: $now
        language:
            - Italiano
extradata:
    ita-IT:
        urlAlias: /Amministrazione/Documenti-e-dati/Dataset/Atti-di-concessione
```

> Solo ita-IT, stesso motivo del dataset precedente.

- [ ] **Step 3: Validare la sintassi YAML di entrambi i file**

Run: `python3 -c "import yaml; yaml.safe_load(open('modules/trasparenza-additional-anac-schemes/contents/Criteri-Modalita-Concessione-Dataset.yml'))" && echo OK`
Run: `python3 -c "import yaml; yaml.safe_load(open('modules/trasparenza-additional-anac-schemes/contents/Atti-Concessione-Dataset.yml'))" && echo OK`
Expected: `OK` per entrambi.

- [ ] **Step 4: Commit**

```bash
git add modules/trasparenza-additional-anac-schemes/contents/Criteri-Modalita-Concessione-Dataset.yml modules/trasparenza-additional-anac-schemes/contents/Atti-Concessione-Dataset.yml
git commit -m "feat: aggiunge i dataset Criteri e modalita di concessione / Atti di concessione (art.26-27, C1)"
```

---

## Task 8: Installer — opzioni `schema_pubblicazione`

**Files (repo `installer`):**
- Modify: `modules/trasparenza/classes/pagina_trasparenza.yml:246` (XML `data_text5`)

**Interfaces:**
- Produces: 4 nuove opzioni nell'ezselection `schema_pubblicazione` (id 22-25, coerenti con Task 2), consumate dai due `patch_content` del Task 9.

**Correzione rispetto alla prima stesura di questo piano**: "Criteri e modalità" **esiste già** nell'alberatura base di `trasparenza-c1` — `modules/trasparenza-c1/contenttrees/Trasparenza-Ammi-Tras-Sovv-cont-suss/Criteri-e-modalita.yml`, remote_id `5f467d7b4dc96527d061f8d8bf96168d`, sibling esatto di "Atti di concessione" nella stessa cartella/genitore, con contenuto legacy pre-ANAC ("si consiglia di aggiungere la collocazione del Regolamento per la concessione di contributi"). Verificato il 2026-11-19 cercando per nome file invece che per "concession"/"Sovvenzioni" (la prima ricerca era sbagliata). Questo task quindi copre solo le opzioni `schema_pubblicazione` — nessuna pagina da creare, il Task 9 patcha entrambe le pagine in modo simmetrico.

- [ ] **Step 1: Aggiungere le 4 opzioni a `pagina_trasparenza.yml`**

In `modules/trasparenza/classes/pagina_trasparenza.yml:246`, dentro la stringa XML di `data_text5`, sostituire la chiusura `<option id="21" name="art.20-c2"/></options>` con:

```
<option id="21" name="art.20-c2"/><option id="22" name="art.26-27-criteri"/><option id="23" name="art.26-27-atti-concessione"/><option id="24" name="art.26-27-atto-revoca"/><option id="25" name="art.26-27-atti"/></options>
```

(Nessun bump di versione — additivo, stesso precedente di art.20. Per rieseguire lo step `classes` su un sito già installato: `ocinstall --update --force`.)

- [ ] **Step 2: Validare la sintassi YAML**

Run: `python3 -c "import yaml; yaml.safe_load(open('modules/trasparenza/classes/pagina_trasparenza.yml'))" && echo OK`
Expected: `OK`

- [ ] **Step 3: Validare che l'XML embedded resti ben formato**

Run: `python3 -c "
import yaml, xml.etree.ElementTree as ET
d = yaml.safe_load(open('modules/trasparenza/classes/pagina_trasparenza.yml'))
xml_str = d['schema_pubblicazione']['data_text5']
root = ET.fromstring(xml_str)
options = root.findall('.//option')
print(len(options), 'opzioni, ultime 4:', [(o.get('id'), o.get('name')) for o in options[-4:]])
"`
Expected: `26 opzioni, ultime 4: [('22', 'art.26-27-criteri'), ('23', 'art.26-27-atti-concessione'), ('24', 'art.26-27-atto-revoca'), ('25', 'art.26-27-atti')]`

- [ ] **Step 4: Commit**

```bash
git add modules/trasparenza/classes/pagina_trasparenza.yml
git commit -m "feat: aggiunge le opzioni schema_pubblicazione per art.26-27"
```

---

## Task 9: Installer — wiring `installer.yml` (patch simmetrico delle due pagine esistenti)

**Files (repo `installer`):**
- Modify: `modules/trasparenza-additional-anac-schemes/installer.yml`
- Modify: `modules/trasparenza-additional-anac-schemes/CLAUDE.md` (documentare il nuovo schema, stesso stile delle sezioni esistenti)

**Interfaces:**
- Consumes: `criteri_modalita_concessione`/`atti_di_concessione` (Task 7), remote_id esistenti delle due pagine legacy "Criteri e modalità" (`5f467d7b4dc96527d061f8d8bf96168d`) e "Atti di concessione" (`90b631e882ab0f966d03aababf3d9f15`), `BootstrapItaliaInstallerUtils::canInstallAttiConcessioneDataset()` (Task 6).
- Produces: alberatura C1 completa e navigabile per l'intero schema, pronta per il cron (Task 10).

Entrambe le pagine esistono già (vedi Task 8) — questo task le patcha in modo **quasi** simmetrico: "Criteri e modalità" segue il pattern standard `content_exists()` già visto per gli altri dataset del modulo; "Atti di concessione" usa invece la condizione combinata del Task 6, perché può restare non installata anche quando la pagina esiste, se l'ente ha configurato il Registro Nazionale degli Aiuti (Task 12).

- [ ] **Step 1: Aggiungere le variabili** (in `installer.yml`, dopo `has_dati_premi_c1_page`)

```yaml
    -   name: criteri_modalita_c1
        value: 5f467d7b4dc96527d061f8d8bf96168d
    -   name: has_criteri_modalita_c1_page
        value: 'content_exists(5f467d7b4dc96527d061f8d8bf96168d)'
    -   name: atti_concessione_c1
        value: 90b631e882ab0f966d03aababf3d9f15
    -   name: can_install_atti_concessione_dataset
        value: BootstrapItaliaInstallerUtils::canInstallAttiConcessioneDataset
```

`can_install_atti_concessione_dataset` sostituisce quello che altrove in questo modulo sarebbe un semplice `has_X_page`: incorpora già sia l'esistenza della pagina sia l'assenza del Registro Nazionale degli Aiuti (vedi Task 6 per il perché di una sola funzione invece di due variabili combinate).

- [ ] **Step 2: Aggiungere lo step che patcha "Criteri e modalità" (pagina esistente, contenuto legacy)**

```yaml
    # "Criteri e modalità" esiste gia' nell'alberatura base di trasparenza-c1
    # (contenuto legacy, guida_alla_compilazione che rimanda al vecchio
    # meccanismo manuale "aggiungere la collocazione del Regolamento") - qui
    # sostituiamo guida con quella del nuovo dataset strutturato, aggiungiamo
    # schema_pubblicazione e agganciamo il blocco "Singolo" del dataset.
    -   type: content
        identifier: Criteri-Modalita-Concessione-Dataset
        condition: $has_criteri_modalita_c1_page

    -   type: patch_content
        identifier: $criteri_modalita_c1
        ignore_error: true
        attributes:
            schema_pubblicazione:
                - art.26-27-criteri
            guida_alla_compilazione: '<p>In questa sezione viene messo a disposizione un Dataset che può essere popolato cliccando sul pulsante "Aggiungi Criterio di concessione". L''atto normativo va ripetuto su una riga per ciascun atto attuativo (bando/avviso) che lo richiama; un atto normativo senza atti attuativi va inserito con una sola riga, lasciando vuoti i campi relativi all''atto attuativo.</p>'
            fields_blocks:
                zone_layout: desItaGlobal
                global:
                    zone_id: art2627.criteri.zone
                    blocks:
                        -   block_id: art2627.criteri.dataset
                            name: ''
                            type: Singolo
                            view: default
                            valid_items:
                                - criteri_modalita_concessione
                            custom_attributes:
                                color_style: ''
                                container_style: ''
                                intro_text: ''
```

- [ ] **Step 3: Aggiungere lo step che patcha "Atti di concessione" (pagina esistente, contenuto legacy)**

```yaml
    # "Atti di concessione" esiste gia' nell'alberatura base di trasparenza-c1
    # (contenuto legacy, guida_alla_compilazione che rimanda al vecchio
    # meccanismo a tag "Sovvenzione/contributo") - qui sostituiamo guida e
    # messaggio con quelli del nuovo dataset, aggiungiamo gli schema_pubblicazione
    # e agganciamo il blocco "Singolo" del nuovo dataset strutturato.
    #
    # condition combinata (Task 6, non il solito content_exists() da solo):
    # se l'ente ha configurato il Registro Nazionale degli Aiuti, NE' il
    # dataset NE' il blocco vanno installati - decisione di Marco il
    # 2026-11-19, non un semplice "nascondilo a runtime" (vedi Task 12).
    -   type: content
        identifier: Atti-Concessione-Dataset
        condition: $can_install_atti_concessione_dataset

    -   type: patch_content
        identifier: $atti_concessione_c1
        condition: $can_install_atti_concessione_dataset
        ignore_error: true
        attributes:
            schema_pubblicazione:
                - art.26-27-atti-concessione
                - art.26-27-atto-revoca
                - art.26-27-atti
            guida_alla_compilazione: '<p>In questa sezione viene messo a disposizione un Dataset che può essere popolato cliccando sul pulsante "Aggiungi Atto di concessione".</p>'
            messaggio_di_consiglio: '<p>L''eventuale atto di modifica o revoca si inserisce negli appositi campi dello stesso record dell''atto di concessione a cui si riferisce, non come record separato.</p>'
            fields_blocks:
                zone_layout: desItaGlobal
                global:
                    zone_id: art2627.atti.zone
                    blocks:
                        -   block_id: art2627.atti.dataset
                            name: ''
                            type: Singolo
                            view: default
                            valid_items:
                                - atti_di_concessione
                            custom_attributes:
                                color_style: ''
                                container_style: ''
                                intro_text: ''
```

**Nessun `php_callable patchContentAttributeForLanguage` per ger-DE qui** (decisione di Marco: niente tedesco in questo lavoro, si fa tutto insieme nel 2027) — le due pagine restano con il loro `ger-DE:` legacy invariato per ora.

**Attenzione `zone_id`/`block_id`**: `art2627.criteri.*` e `art2627.atti.*` sono nuovi, mai usati da nessun altro step di questo modulo (verificare con `grep -rn "zone_id:" modules/trasparenza-additional-anac-schemes/installer.yml` prima di eseguire — devono comparire solo nei due blocchi appena aggiunti).

- [ ] **Step 4: Validare la sintassi YAML del file installer.yml completo**

Run: `python3 -c "import yaml; yaml.safe_load(open('modules/trasparenza-additional-anac-schemes/installer.yml'))" && echo OK`
Expected: `OK`

- [ ] **Step 5: Verificare che nessuno zone_id/block_id sia duplicato nel file**

Run: `grep -o 'zone_id: [a-z0-9.]*' modules/trasparenza-additional-anac-schemes/installer.yml | sort | uniq -d`
Expected: nessun output (nessun duplicato).

- [ ] **Step 6: Documentare nel `CLAUDE.md` del modulo** (append, stesso stile delle sezioni "art.20" esistenti)

Aggiungere in fondo a `modules/trasparenza-additional-anac-schemes/CLAUDE.md` una sezione `## artt. 26-27 - Sovvenzioni, contributi, sussidi, vantaggi economici (cms#527), quarto schema di questo modulo, solo C1` che descriva: entrambe le pagine ("Criteri e modalità", "Atti di concessione") esistono già nell'alberatura base di `trasparenza-c1` con contenuto legacy pre-ANAC, patchate qui (nessuna pagina creata da questo modulo, a differenza di quanto ipotizzato in una prima stesura di questo piano poi corretta); i due identificativi JSON distinti con nomi file distinti (`art.26-27-criteri`, `art.26-27-atti`) e perché (vedi Global Constraints di questo piano); `zone_id`/`block_id` nuovi (`art2627.criteri.*`, `art2627.atti.*`); nessuna validazione incrociata nei dataset (PEO/PEC, revoca, atto attuativo) — solo guida testuale nel campo `description`, decisione esplicita di Marco il 2026-11-19; solo ita-IT, nessuna traduzione ger-DE in questo lavoro (rimandata al 2027); **"Atti di concessione" non è installata in modo simmetrico a "Criteri e modalità"** — usa la condizione combinata `BootstrapItaliaInstallerUtils::canInstallAttiConcessioneDataset()` (Task 6) invece del solito `content_exists()` da solo, perché il Registro Nazionale degli Aiuti (Task 12) può far sì che quella pagina esista ma il dataset/blocco non vadano comunque installati — unico caso in questo modulo dove "la pagina esiste" non basta per decidere se installare.

- [ ] **Step 7: Commit**

```bash
git add modules/trasparenza-additional-anac-schemes/installer.yml modules/trasparenza-additional-anac-schemes/CLAUDE.md
git commit -m "feat: collega i dataset art.26-27 alle pagine Criteri e modalita / Atti di concessione (C1)"
```

---

## Task 10: Cron — `publishArt2627()` e wiring in `cronjobs/anac_export.php`

**Files (repo `openpa_bootstrapitalia`):**
- Modify: `cronjobs/anac_export.php`

**Interfaces:**
- Consumes: `Art2627Serializer` (Task 3/5), `ExportPublisher::publish()`/`publishSingle()`/`publishWithDates()`, `SchemaPubblicazioneLookup::fetchAllBindings()` (già chiamato in testa al file, riusato).
- Produces: 4 file pubblicati (CSV criteri, JSON criteri, CSV atti-concessione, CSV atto-revoca, JSON atti), tracciati sotto i 4 identificativi del Task 2.

- [ ] **Step 1: Aggiungere la funzione** (dopo `publishArt20()`, stesso file)

```php

/**
 * artt. 26-27 - Sovvenzioni, contributi, sussidi, vantaggi economici
 * (cms#527), solo C1. Due pagine, quattro file: "Criteri e modalità"
 * pubblica CSV+JSON sotto lo STESSO identificativo (art.26-27-criteri,
 * come art.4-bis); "Atti di concessione" pubblica CSV atti-concessione +
 * CSV atto-revoca + JSON atti sotto TRE identificativi distinti (come i
 * tre file separati di art.20) - vedi Art2627Serializer, docblock di classe.
 *
 * I due dataset sono verificati e pubblicati IN MODO INDIPENDENTE, con due
 * try/catch separati: "Atti di concessione" può non esistere da solo (il
 * Registro Nazionale degli Aiuti ne impedisce l'installazione, vedi
 * BootstrapItaliaInstallerUtils::canInstallAttiConcessioneDataset() e
 * Task 6/9/12) - "Criteri e modalità" deve continuare a funzionare in
 * quel caso, non essere bloccata da un controllo unico su entrambi. Stesso
 * principio vale per gli errori: un telefono malformato in un atto di
 * concessione non deve impedire la pubblicazione dei criteri, e viceversa.
 */
function publishArt2627(eZCLI $cli, array $schemaBindings)
{
    $criteriObject = eZContentObject::fetchByRemoteID('criteri_modalita_concessione');
    $attiObject = eZContentObject::fetchByRemoteID('atti_di_concessione');
    if (!$criteriObject instanceof eZContentObject && !$attiObject instanceof eZContentObject) {
        // Caso normale per la maggioranza dei tenant: schema opzionale,
        // modulo trasparenza-additional-anac-schemes non installato (o non
        // aggiornato a questa versione) su questo sito. Nota: `&&`, non
        // `||` - uno solo dei due può mancare (vedi Registro Nazionale
        // degli Aiuti) senza che sia questo caso.
        return;
    }

    $criteriAttribute = null;
    if ($criteriObject instanceof eZContentObject) {
        $criteriDataMap = $criteriObject->fetchDataMap(false, SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        $criteriAttribute = $criteriDataMap['csv_resource'] ?? null;
        if ($criteriAttribute === null) {
            $cli->error('anac_export: attributo csv_resource non trovato sul dataset Criteri e modalita, schema art.26-27-criteri saltato');
        }
    }

    $attiAttribute = null;
    if ($attiObject instanceof eZContentObject) {
        $attiDataMap = $attiObject->fetchDataMap(false, SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        $attiAttribute = $attiDataMap['csv_resource'] ?? null;
        if ($attiAttribute === null) {
            $cli->error('anac_export: attributo csv_resource non trovato sul dataset Atti di concessione, schema art.26-27-atti* saltato');
        }
    }

    $serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art2627Serializer($criteriAttribute, $attiAttribute);

    // --- art. 26 co. 1: Criteri e modalità (CSV+JSON stesso identificativo) ---
    if ($criteriAttribute !== null) {
        try {
            $criteriIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art2627Serializer::SCHEMA_IDENTIFIER_CRITERI;
            $criteriPageObject = isset($schemaBindings[$criteriIdentifier]) ? $schemaBindings[$criteriIdentifier] : null;
            $criteriRootNodeId = $criteriPageObject instanceof eZContentObject
                ? $criteriPageObject->attribute('main_node')->attribute('node_id')
                : $criteriObject->attribute('main_node')->attribute('node_id');

            $csvCriteri = $serializer->toCsvCriteri();
            $criteriPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($criteriIdentifier, $criteriRootNodeId);
            $criteriTracking = $criteriPublisher->publish($csvCriteri, function ($first, $last) use ($serializer) {
                return $serializer->toJsonCriteri($first, $last);
            });
            $cli->notice("anac_export: schema {$criteriIdentifier} ok, ultima modifica {$criteriTracking['dataUltimaModifica']}");
        } catch (\Exception $e) {
            eZDebug::writeError($e->getMessage(), 'anac_export.php: art.26-27-criteri');
            $cli->error('anac_export: schema art.26-27-criteri fallito: ' . $e->getMessage());
        }
    }

    // --- artt. 26 co. 2 e 27: Atti di concessione (3 identificativi distinti) ---
    if ($attiAttribute !== null) {
        try {
            $attiConcessioneIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art2627Serializer::SCHEMA_IDENTIFIER_ATTI_CONCESSIONE;
            $attiPageObject = isset($schemaBindings[$attiConcessioneIdentifier]) ? $schemaBindings[$attiConcessioneIdentifier] : null;
            $attiRootNodeId = $attiPageObject instanceof eZContentObject
                ? $attiPageObject->attribute('main_node')->attribute('node_id')
                : $attiObject->attribute('main_node')->attribute('node_id');

            $csvAttiConcessione = $serializer->toCsvAttiConcessione();
            $attiConcessionePublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($attiConcessioneIdentifier, $attiRootNodeId);
            $attiConcessioneTracking = $attiConcessionePublisher->publishSingle($csvAttiConcessione, 'csv');
            $cli->notice("anac_export: schema {$attiConcessioneIdentifier} ok, ultima modifica {$attiConcessioneTracking['dataUltimaModifica']}");

            $attoRevocaIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art2627Serializer::SCHEMA_IDENTIFIER_ATTO_REVOCA;
            $attoRevocaPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($attoRevocaIdentifier, $attiRootNodeId);
            $attoRevocaTracking = $attoRevocaPublisher->publishSingle($serializer->toCsvAttoRevoca(), 'csv');
            $cli->notice("anac_export: schema {$attoRevocaIdentifier} ok, ultima modifica {$attoRevocaTracking['dataUltimaModifica']}");

            // Il JSON "atti" va omesso del tutto se il dataset è vuoto
            // (schema reale: attiDiConcessione ha minItems: 1, nessuno
            // stato vuoto valido) - toJsonAtti() ritorna null in quel caso,
            // publishWithDates() non supporta l'omissione quindi il
            // controllo va fatto qui, PRIMA di chiamarlo (stesso pattern
            // di publishArt20() per i blocchi co.1/co.2).
            $righeAtti = $serializer->fetchRigheAtti();
            if (!empty($righeAtti)) {
                $attiIdentifier = \OpenPABootstrapItalia\Anac\Serializer\Art2627Serializer::SCHEMA_IDENTIFIER_ATTI;
                $attiPublisher = new \OpenPABootstrapItalia\Anac\ExportPublisher($attiIdentifier, $attiRootNodeId);
                $attiTracking = $attiPublisher->publishWithDates(
                    json_encode($righeAtti),
                    function ($first, $last) use ($serializer) {
                        return $serializer->toJsonAtti($first, $last);
                    },
                    'json'
                );
                $cli->notice("anac_export: schema {$attiIdentifier} ok, ultima modifica {$attiTracking['dataUltimaModifica']}");
            }
        } catch (\Exception $e) {
            eZDebug::writeError($e->getMessage(), 'anac_export.php: art.26-27-atti');
            $cli->error('anac_export: schema art.26-27-atti* fallito: ' . $e->getMessage());
        }
    }
}
```

- [ ] **Step 2: Registrare la chiamata nella sequenza principale**

In `cronjobs/anac_export.php`, dopo `publishArt20($cli, $schemaBindings);`:

```php
publishArt2627($cli, $schemaBindings);
```

- [ ] **Step 3: Verificare la sintassi del file**

Run: `php -l cronjobs/anac_export.php`
Expected: `No syntax errors detected`

- [ ] **Step 4: Verificare che non resti nessun riferimento a `recordAnacExportError`**

Run: `grep -n "recordAnacExportError" cronjobs/anac_export.php`
Expected: nessun output (quella funzione non esiste su questo branch, forkato da `master` — non introdurla per errore copiando pattern da altre fonti).

- [ ] **Step 5: Commit**

```bash
git add cronjobs/anac_export.php
git commit -m "feat: aggiunge publishArt2627 al cron ANAC (artt.26-27, profilo C1)"
```

---

## Task 11: Aggiornare `classes/anac/CLAUDE.md` (openpa_bootstrapitalia)

**Files:**
- Modify: `classes/anac/CLAUDE.md`

Scritto prima del Task 12 (Registro Nazionale degli Aiuti) perché quest'ultimo ne estende la sezione — ordine intenzionale, non arbitrario.

- [ ] **Step 1: Aggiungere una sezione `### Art2627Serializer`** (stesso stile delle sezioni Art20Serializer/Art31Serializer esistenti), descrivendo: i due identificativi JSON distinti con nomi file distinti e perché (il fix rispetto al precedente errato dell'issue, vedi Global Constraints di questo piano); il raggruppamento per atto normativo nel JSON criteri vs la forma piatta del CSV; la revoca sullo stesso record dell'atto di concessione; `InvalidTelefonoException`/`TelefonoNormalizer` come nuova validazione export-time; nessuna validazione incrociata nei dataset (rimando alla sezione aggiunta in `installer/modules/trasparenza-additional-anac-schemes/CLAUDE.md`, Task 9); una riga che anticipa il Registro Nazionale degli Aiuti con rimando alla sua sezione dedicata (Task 12, che la aggiunge subito sotto).

- [ ] **Step 2: Aggiungere una riga alla tabella "Cosa manca" se pertinente** (es. profilo C2, rimandato a #555 — già tracciato lì, menzionarlo qui solo come rimando, non duplicare lo scope).

- [ ] **Step 3: Commit**

```bash
git add classes/anac/CLAUDE.md
git commit -m "docs: documenta Art2627Serializer in classes/anac/CLAUDE.md"
```

---

## Task 12: Registro Nazionale degli Aiuti — link in pagina

**Files (repo `openpa_bootstrapitalia`):**
- Modify: `settings/openpa.ini.append.php`
- Modify: `classes/services/content_trasparenza.php` (nuova fn, nessuna modifica a `getAnacExports()`)
- Modify: `design/bootstrapitalia2/templates/openpa/full/parts/amministrazione_trasparente/anac_export.tpl`
- Modify: `classes/anac/CLAUDE.md` (documentazione dedicata — vedi Step 4, richiesta esplicita di Marco: questo meccanismo è design nuovo, nessun precedente da cui dedurlo, va documentato bene)

**Interfaces:**
- Produces: `$trasparenza.registro_nazionale_aiuti_url` (nuova variabile template), usata da `anac_export.tpl`.

**Il gate vero è già stato spostato all'installazione nel Task 6/9**: se l'ente ha configurato il Registro, il dataset/blocco "Atti di concessione" non viene proprio installato, quindi `getAnacExports()`/`publishArt2627()` non trovano niente da mostrare o esportare per quei 3 schemi — nessuna modifica necessaria lì, a differenza di quanto previsto in una stesura precedente di questo task (poi semplificata). L'unica cosa che resta davvero da fare qui è **mostrare il link** quando l'ini è valorizzata — un'unica lettura dell'ini, non tre controlli duplicati.

- [ ] **Step 1: Aggiungere l'ini** (in `settings/openpa.ini.append.php`, accanto alle altre chiavi `[Trasparenza]`)

```ini
# Rinvio al Registro Nazionale degli Aiuti (art. 26 co. 4, Nota 6 - cms#527):
# quando valorizzato, mostra un link al Registro sulla pagina "Atti di
# concessione" - il dataset/blocco di quella pagina non viene nemmeno
# installato in questo caso (vedi BootstrapItaliaInstallerUtils::
# canInstallAttiConcessioneDataset() nel repo openpa_bootstrapitalia,
# installer.yml nel repo installer), quindi questa ini qui serve solo per
# il link, non per nascondere nulla. "Criteri e modalità" non è toccata.
# Default vuoto = funzionalità non attiva.
RegistroNazionaleAiutiUrl=
```

- [ ] **Step 2: Esporre la variabile al template** (nel metodo `run()`, accanto a `$this->fnData['anac_exports']`)

```php
        $this->fnData['registro_nazionale_aiuti_url'] = 'getRegistroNazionaleAiutiUrl';
```

E il metodo (vicino a `getAnacExports()`):

```php
    /**
     * @return string url del Registro Nazionale degli Aiuti se configurato
     *         per questo tenant (Nota 6, cms#527), '' altrimenti - in quel
     *         caso il template mostra un link sulla pagina "Atti di
     *         concessione". Non serve nascondere nient'altro qui: se
     *         questa ini è valorizzata, il dataset/blocco di quella pagina
     *         non è mai stato installato (vedi Task 6/9) - niente di cui
     *         "getAnacExports()" possa già parlare.
     */
    protected function getRegistroNazionaleAiutiUrl()
    {
        return trim((string)OpenPAINI::variable('Trasparenza', 'RegistroNazionaleAiutiUrl', ''));
    }
```

- [ ] **Step 3: Aggiungere il blocco nel template** (in `anac_export.tpl`, dopo il blocco `{if count($exports)|gt(0)}...{/if}` esistente)

```smarty
{if $registro_nazionale_aiuti_url|ne('')}
    <div class="anac-export-rna mt-3">
        <p class="mb-0">
            {display_icon('it-link', 'svg', 'icon icon-sm icon-primary me-1')}
            <a class="btn-link p-0 text-decoration-underline" href="{$registro_nazionale_aiuti_url|wash()}">{'Registro Nazionale degli Aiuti'|i18n('bootstrapitalia/anac_export')}</a>
        </p>
    </div>
{/if}
```

- [ ] **Step 4: Documentare il meccanismo per esteso in `classes/anac/CLAUDE.md`** (richiesta esplicita di Marco il 2026-11-19 — è design nuovo di questa sessione, nessun precedente nel codice da cui un futuro lettore possa dedurlo, va spiegato bene)

Aggiungere una sezione dedicata `### Registro Nazionale degli Aiuti (RNA) — link opzionale su "Atti di concessione"`, dentro la sezione `Art2627Serializer` (Task 11, già scritta), che copra esplicitamente:

- **Perché esiste**: art. 26 co. 4 (Nota 6 della Guida ANAC) permette, dove i dati sono già pubblicati sul RNA, di sostituire la pubblicazione diretta con un link — evita doppia manutenzione dello stesso dato per gli enti che già alimentano il RNA.
- **Cosa copre e cosa no**: solo "Atti di concessione" (i tre schemi `art.26-27-atti-concessione`, `art.26-27-atto-revoca`, `art.26-27-atti`). "Criteri e modalità" (`art.26-27-criteri`) non è mai toccata — i criteri di concessione non sono dati che il RNA registra, non ha senso rimandarli lì.
- **Un solo punto di verità, non più tre**: la decisione vera ("questo ente usa il RNA, quindi niente dataset/blocco per Atti di concessione") si prende **una volta sola, all'installazione** (`BootstrapItaliaInstallerUtils::canInstallAttiConcessioneDataset()`, Task 6, usata da `installer.yml`, Task 9). A runtime non c'è nessun controllo equivalente da mantenere sincronizzato con quello: `getAnacExports()` e `publishArt2627()` si comportano correttamente DA SOLI perché il dataset/blocco semplicemente non esiste — l'unica lettura dell'ini rimasta (`getRegistroNazionaleAiutiUrl()`) serve solo a decidere se mostrare il link, non se nascondere qualcos'altro.
- **Limite noto, non risolto da questo piano**: la condizione a `canInstallAttiConcessioneDataset()` **non è retroattiva** (stesso principio già documentato altrove nel progetto per `Role::install()` - vedi `installer/modules/trasparenza/CLAUDE.md`) — se un ente ha già il dataset/blocco installato e configura il Registro DOPO, quel contenuto resta installato finché qualcuno non lo rimuove a mano o non si costruisce un passaggio di pulizia dedicato: l'installer non cancella mai contenuti da solo. Per un ente nuovo (ini già configurata al primo `ocinstall`), il comportamento è pulito fin da subito.

- [ ] **Step 5: Verificare la sintassi PHP**

Run: `php -l classes/services/content_trasparenza.php`
Expected: `No syntax errors detected`

- [ ] **Step 6: Commit**

```bash
git add settings/openpa.ini.append.php classes/services/content_trasparenza.php design/bootstrapitalia2/templates/openpa/full/parts/amministrazione_trasparente/anac_export.tpl classes/anac/CLAUDE.md
git commit -m "feat: aggiunge il link al Registro Nazionale degli Aiuti sulla pagina Atti di concessione"
```

---

## Task 13: Verifica end-to-end in locale (prima della consegna)

Non aggiunge codice — esegue la checklist già nota per i nuovi schemi ANAC (vedi memoria `feedback_anac_schema_checklist_lang_translations_local_test`), adattata a questo lavoro: **solo ita-IT** (nessuna traduzione ger-DE in questo piano, vedi Global Constraints), export testato in locale, poi la checklist della issue ripercorsa punto per punto su QA.

- [ ] **Step 1: Installare il modulo in locale** (ambiente `sito-comunale-dev`, stack che punta ai due branch `trasparenza-additional-scheme-26-27`)

Run: `docker exec sito-comunale-dev-app-1 php bin/php/ocinstall.php -s <siteaccess>_backend --update html/extension/installer/modules/trasparenza-additional-anac-schemes/`

Expected: step eseguiti senza errori, le due pagine "Criteri e modalità"/"Atti di concessione" mostrano il blocco dataset.

- [ ] **Step 2: Abilitare l'export** (ini locale, se non già abilitato)

Run: verificare `[Trasparenza] EnableAnacExport=enabled` sul siteaccess di test.

- [ ] **Step 3: Inserire dati di test e lanciare il cron manualmente**

Seguire esattamente la sezione "Test", punto 1, dell'issue GitLab #527 (già corretta in questa sessione) per i record da inserire, poi:

Run: `docker exec sito-comunale-dev-app-1 php bin/php/runcronjobs.php changesection`

Expected: nei log, righe `anac_export: schema art.26-27-criteri ok`, `anac_export: schema art.26-27-atti-concessione ok`, `anac_export: schema art.26-27-atto-revoca ok`, `anac_export: schema art.26-27-atti ok`.

- [ ] **Step 4: Verificare i file pubblicati** seguendo le sezioni "Test" punti 3-6 dell'issue #527 (nomi file, contenuto CSV, contenuto JSON contro lo schema reale, formati).

- [ ] **Step 5: Nessun commit** (verifica manuale) — se emergono bug, tornare al task specifico, correggere lì, e ripetere questo task.
