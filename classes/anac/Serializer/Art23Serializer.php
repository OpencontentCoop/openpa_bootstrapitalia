<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

/**
 * Export art. 23 (cms#489): Provvedimenti amministrativi adottati dagli
 * organi di indirizzo politico e dai dirigenti, profilo C1. Risoluzione tag
 * per remote_id hardcoded (vedi REMOTE_ID_TO_INFO sotto), stesso pattern di
 * Art31Serializer::TAG_REMOTE_ID_TO_KEY - NON per keyword (il keyword e'
 * l'etichetta mostrata al redattore, editabile da backend; un matching per
 * testo fallirebbe silenziosamente a una rinomina anche minima, vedi nota di
 * design nel piano di implementazione, Task 5).
 *
 * Struttura JSON verificata scaricando lo schema reale in questa sessione:
 * https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.23-v1.0.schema.json
 * (fixture locale in classes/anac/schema/, vedi JsonSchemaValidator).
 *
 * `provvedimentiDirigDiSceltaContraente` omesso: fuori scope (nessun
 * attributo oggi distingue una determina di scelta del contraente da
 * un'altra determina).
 */
class Art23Serializer
{
    const SCHEMA_IDENTIFIER_ORGANI = 'art.23-org';
    const SCHEMA_IDENTIFIER_DIRIGENTI = 'art.23-altra-tipologia';
    const SCHEMA_IDENTIFIER_JSON = 'art.23';

    const SCHEMA_URL = 'https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.23-v1.0.schema.json';

    /**
     * remote_id del tag document_type (ramo "Tipo di documento -> Documenti
     * Albo Pretorio -> Atto amministrativo") => ['denominazione' => tag
     * padre nella tassonomia, es. 'Decreto', 'group' => 'organi'|'dirigenti'].
     * Verificato su installer/tagtree_csv/documenti.csv (vedi spec §1.3 e
     * piano, Task 5, tabella remote_id/keyword/denominazione/gruppo).
     */
    const REMOTE_ID_TO_INFO = [
        'ccf6761810b5ac50d32eade1fbe17fca' => ['denominazione' => 'Decreto', 'group' => 'organi'],
        '99af81198d42521cfc45090770824e26' => ['denominazione' => 'Determinazione', 'group' => 'organi'],
        '2039d8bedb749132b8bf4301f4c6aeb6' => ['denominazione' => 'Ordinanza', 'group' => 'organi'],
        '4271686f78f9dbc0fb871f32553ffb6c' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '19123462b045f0b8977ce0b1a9047032' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '7634e3355a07d671094fe120d7919653' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '7bda99bae095fde15daa1fe54af6861c' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '5b1e0b73926e47e0e8691c727a2a57df' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '2a8a6817a8f54531c77be68f03655833' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        '173d943cedd25729d8707a753b12280c' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
        'fd0176933fb88cb62d6a3ad4be3cdaa2' => ['denominazione' => 'Decreto', 'group' => 'dirigenti'],
        'f3431b7c90f441bab1a0b2e3068325d4' => ['denominazione' => 'Determinazione', 'group' => 'dirigenti'],
        '4bdaece33ace3d1c3911b3b43c554b47' => ['denominazione' => 'Ordinanza', 'group' => 'dirigenti'],

        // Tag padre generico (es. un documento taggato semplicemente
        // "Deliberazione", senza specificare quale organo) - confermato con
        // Marco di includerli. 'Deliberazione' (remote_id sotto) e' l'unico
        // dei 4 padri generici non ambiguo: TUTTI i suoi figli oggi sono
        // 'organi' (nessun "Deliberazione del Dirigente" esiste nella
        // tassonomia) - verificato su tagtree_csv/documenti.csv (parent_id
        // di tutti i 7 figli = 69, lo stesso id di questo tag). I padri
        // generici "Decreto"/"Determinazione"/"Ordinanza" restano VOLUTAMENTE
        // fuori: hanno entrambi un figlio 'organi' E uno 'dirigenti' (del
        // Sindaco vs del Dirigente), quindi il gruppo per il tag generico
        // da solo e' ambiguo - decisione in sospeso, vedi classes/anac/CLAUDE.md.
        '5cf98dba69d46a79d7afa5fcbeea364a' => ['denominazione' => 'Deliberazione', 'group' => 'organi'],
    ];

    private $amministrazione;

    /** @var array|null tagId (int) => ['denominazione' => string, 'group' => 'organi'|'dirigenti'], risolto una sola volta per istanza */
    private $tagMap;

    public function __construct(array $amministrazione = null)
    {
        $this->amministrazione = $amministrazione;
    }

    private function getAmministrazione()
    {
        if ($this->amministrazione === null) {
            $this->amministrazione = \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione();
        }

        return $this->amministrazione;
    }

    /**
     * Risolve REMOTE_ID_TO_INFO (13 voci fisse) in tagId => info, una sola
     * query per remote_id (nessuna risoluzione per keyword/tree-walk - vedi
     * docblock di classe). Un remote_id che non risolve piu' a un tag
     * esistente (tassonomia cancellata a mano, mai il caso su un'istanza
     * reale non manomessa) viene saltato, non blocca l'intero export.
     *
     * Include anche i SINONIMI di ciascun tag (es. "Decreto sindacale" per
     * "Decreto del Sindaco" - vedi `tagtree_csv/documenti.csv`, colonna
     * `synonyms_it`, tutte e 13 le voci ne hanno uno), mappati alla stessa
     * denominazione/group del tag principale. Necessario: `eztags.ini`
     * (`[SearchSettings] IndexSynonyms`) e' `enabled` in questo progetto (non
     * sovrascritto), e `ezfSolrDocumentFieldeZTags::processTag()` a quel
     * punto NON risolve un sinonimo al suo tag principale prima di indicizzare
     * - un documento taggato con un sinonimo viene indicizzato con l'id DEL
     * SINONIMO, non quello del tag principale. Senza questa espansione, un
     * documento taggato "Decreto sindacale" invece di "Decreto del Sindaco"
     * sparirebbe silenziosamente dalla query (il suo tag id non e' tra quelli
     * cercati) - trovato dalla review finale whole-branch, verificato
     * leggendo `ezfSolrDocumentFieldeZTags::processTag()`.
     *
     * @return array tagId => ['denominazione' => string, 'group' => 'organi'|'dirigenti']
     */
    public function resolveTagMap()
    {
        if ($this->tagMap !== null) {
            return $this->tagMap;
        }

        $this->tagMap = [];
        foreach (self::REMOTE_ID_TO_INFO as $remoteId => $info) {
            $tag = \eZTagsObject::fetchByRemoteID($remoteId);
            if (!$tag instanceof \eZTagsObject) {
                continue;
            }
            $this->tagMap[(int)$tag->attribute('id')] = $info;
            foreach ($tag->getSynonyms() as $synonym) {
                if ($synonym instanceof \eZTagsObject) {
                    $this->tagMap[(int)$synonym->attribute('id')] = $info;
                }
            }
        }

        return $this->tagMap;
    }

    /**
     * Query Solr sempre su tutto il sito (subtree [RootNode], stesso
     * principio di Art13Serializer::fetchRiferimentiContatti()/
     * Art31Serializer::fetchDocumentsByKeys()): un provvedimento con questo
     * tag va trovato ovunque sia pubblicato, non solo sotto "Provvedimenti".
     *
     * `limit 1000`: stesso motivo gia' documentato in Art13Serializer
     * (fetchVerticeAmministrativi()/fetchOrganizzazioniByTagPath()) - senza
     * un limite esplicito la ricerca applica la paginazione di default (10
     * risultati), troncando silenziosamente CSV/JSON/tabelle live a 10 atti
     * su qualunque ente reale - trovato dalla review finale whole-branch
     * (confermato dal vivo: 10 risultati tornati su 29 reali disponibili).
     *
     * `sort [...]`: ordine esplicito e deterministico (data piu' recente
     * prima, `published` come tiebreaker) - senza un sort esplicito l'ordine
     * dipende dall'ordine interno dell'indice Solr, che puo' cambiare a ogni
     * reindicizzazione e generare una nuova versione datata dell'export
     * anche a dato invariato (il principio "pubblica solo se cambia" di
     * ExportPublisher si basa sull'hash del CSV, quindi un riordino spurio
     * delle righe lo romperebbe).
     *
     * `'Limitation' => array()`: senza, `eZSolr::search()` applica la
     * policy dell'utente corrente (vedi `policyLimitationFilterQuery()` in
     * ezfind) - il cron gira come Anonymous (nessun login esplicito in
     * `cronjobs/anac_export.php`), il cui ruolo limita `content/read` ai soli
     * contenuti `privacy.public` (`installer/roles/Anonymous.yml`): senza
     * questo bypass i provvedimenti privati sparirebbero del tutto dalla
     * query, non solo da `provvedimento`/`allegati` (che e' invece il
     * comportamento voluto, gia' garantito da `isPublic()` in
     * `buildRigaConAllegati()` - vedi spec §4.2) - trovato dalla stessa
     * review finale, verificato tracciando `eZSolr::search()` ->
     * `policyLimitationFilterQuery()`: senza la chiave `Limitation` nei
     * parametri, `$limitation` e' `null` e si usa
     * `eZUser::currentUser()->hasAccessTo('content','read')` (limitato);
     * passando `array()` esplicito si ottiene `accessWord = 'yes'` (nessuna
     * restrizione) - stesso idioma gia' in uso altrove in questo progetto
     * per lo stesso scopo (vedi `OpenPABootstrapItaliaPrivacyFactory.php`).
     *
     * @return array righe {object: eZContentObject, denominazione: string, group: 'organi'|'dirigenti'}
     */
    public function fetchProvvedimenti()
    {
        $tagMap = $this->resolveTagMap();
        if (empty($tagMap)) {
            return [];
        }

        $rootNodeId = (int)\eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');
        $tagIds = array_keys($tagMap);
        $query = 'classes [document] and raw[subattr_document_type___tag_ids____si] in [' . implode(',', $tagIds) . '] and subtree [' . $rootNodeId . ']'
            . ' sort [publication_start_time=>desc, published=>desc] limit 1000';
        $queryBuilder = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
        $queryObject = $queryBuilder->instanceQuery($query);

        // eZFunctionHandler::execute('ezfind', ...) richiede un dispatch di
        // modulo completo - non disponibile in un contesto cron/CLI (stesso
        // motivo gia' documentato in Art31Serializer::fetchDocumentsByKeys()).
        $solr = new \eZSolr();
        $params = (array)$queryObject->convert();
        $params['Limitation'] = array();
        $searchResult = $solr->search('', $params);

        $rows = [];
        foreach ($searchResult['SearchResult'] as $resultNode) {
            $object = $resultNode->attribute('object');
            if (!$object instanceof \eZContentObject) {
                continue;
            }
            $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
            if (!isset($dataMap['document_type'])) {
                continue;
            }
            $tags = $dataMap['document_type']->content();
            if (!$tags instanceof \eZTags) {
                continue;
            }
            foreach ($tags->attribute('tags') as $tag) {
                $tagId = (int)$tag->attribute('id');
                if (!isset($tagMap[$tagId])) {
                    continue;
                }
                $rows[] = [
                    'object' => $object,
                    'denominazione' => $tagMap[$tagId]['denominazione'],
                    'group' => $tagMap[$tagId]['group'],
                ];
                break;
            }
        }

        return $rows;
    }

    public function getOrgani(array $provvedimenti = null)
    {
        $provvedimenti = $provvedimenti !== null ? $provvedimenti : $this->fetchProvvedimenti();

        return array_values(array_filter($provvedimenti, function ($row) {
            return $row['group'] === 'organi';
        }));
    }

    public function getDirigenti(array $provvedimenti = null)
    {
        $provvedimenti = $provvedimenti !== null ? $provvedimenti : $this->fetchProvvedimenti();

        return array_values(array_filter($provvedimenti, function ($row) {
            return $row['group'] === 'dirigenti';
        }));
    }

    /**
     * Catena di fallback data/numero (spec §4): act_date/act_number
     * possono essere DEL TUTTO ASSENTI dalla classe (solo il modulo
     * opzionale albo-pretorio li aggiunge), non solo vuoti - isset() prima
     * di controllare se l'attributo e' valorizzato.
     *
     * Pubblico (non piu' solo uso interno di buildRigaBase()): riusato anche
     * da PageProvvedimentiProvider::flattenRows() per la tabella live, che
     * prima duplicava la stessa catena per conto proprio - trovato dalla
     * review finale whole-branch, le due copie erano gia' divergenti
     * (questa tornava '' per 'numero' assente, l'altra null).
     *
     * @return array{data: string|null, numero: string} 'data' in formato gg/mm/aaaa, null se nessuna fonte disponibile;
     *         'numero' stringa vuota (mai null - lo schema ANAC richiede string) se nessuna fonte disponibile
     */
    public function resolveDataNumero(\eZContentObject $object, array $dataMap)
    {
        $data = null;
        foreach (['act_date', 'data_di_firma', 'publication_start_time'] as $field) {
            if (!isset($dataMap[$field])) {
                continue;
            }
            $timestamp = (int)$dataMap[$field]->toString();
            if ($timestamp > 0) {
                $data = date('d/m/Y', $timestamp);
                break;
            }
        }

        $numero = '';
        foreach (['act_number', 'has_code'] as $field) {
            if (!isset($dataMap[$field])) {
                continue;
            }
            $value = trim((string)$dataMap[$field]->content());
            if ($value !== '') {
                $numero = $value;
                break;
            }
        }

        return ['data' => $data, 'numero' => $numero];
    }

    /**
     * @return string nomi delle organization collegate (has_organization,
     *         ezobjectrelationlist multi-valore), separate da ", " se piu' di una
     */
    public function resolveStrutturaResponsabile(array $dataMap)
    {
        if (!isset($dataMap['has_organization']) || !$dataMap['has_organization']->hasContent()) {
            return '';
        }
        $content = $dataMap['has_organization']->content();
        $names = [];
        foreach ((array)($content['relation_list'] ?? []) as $item) {
            $relatedObject = \eZContentObject::fetch((int)$item['contentobject_id']);
            if ($relatedObject instanceof \eZContentObject) {
                $names[] = trim($relatedObject->attribute('name'));
            }
        }

        return implode(', ', $names);
    }

    /**
     * @return array{data: string|null, numero: string, denominazione: string, oggetto: string, strutturaResponsabile: string}
     *         campi comuni a CSV e JSON, SENZA provvedimento/allegati (vedi
     *         buildRigaConAllegati() in Task 6, solo per l'export)
     */
    private function buildRigaBase(array $row)
    {
        $object = $row['object'];
        $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        $dataNumero = $this->resolveDataNumero($object, $dataMap);

        return [
            'data' => $dataNumero['data'],
            'numero' => $dataNumero['numero'],
            'denominazione' => $row['denominazione'],
            'oggetto' => trim($object->attribute('name')),
            'strutturaResponsabile' => $this->resolveStrutturaResponsabile($dataMap),
        ];
    }

    private function toCsvGruppo(array $rows)
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line(['DATA', 'NUMERO', 'DENOMINAZIONE', 'OGGETTO', 'STRUTTURA_RESPONSABILE'])];

        foreach ($rows as $row) {
            $riga = $this->buildRigaBase($row);
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
                (string)$riga['data'], (string)$riga['numero'], $riga['denominazione'], $riga['oggetto'], $riga['strutturaResponsabile'],
            ]);
        }

        return implode("\n", $lines) . "\n";
    }

    public function toCsvOrgani(array $provvedimenti = null)
    {
        return $this->toCsvGruppo($this->getOrgani($provvedimenti));
    }

    public function toCsvDirigenti(array $provvedimenti = null)
    {
        return $this->toCsvGruppo($this->getDirigenti($provvedimenti));
    }

    private function isPublic(\eZContentObject $object)
    {
        $publicStates = \OpenPABase::initStateGroup('privacy', ['public']);
        $publicStateId = (int)$publicStates['privacy.public']->attribute('id');

        // 'state_id_array' e' valorizzato come STRINGHE (driver DB) - un
        // confronto stretto in_array(..., true) contro un (int) non
        // matcherebbe mai. Stesso bug/fix gia' documentato in
        // BootstrapItaliaInstallerUtils::hideContentWithRedirect() (Task 2) -
        // normalizzato con array_map('intval', ...).
        $currentStateIdArray = array_map('intval', (array)$object->attribute('state_id_array'));

        return in_array($publicStateId, $currentStateIdArray, true);
    }

    /**
     * @return array{...} stessi campi di buildRigaBase() + 'provvedimento'
     *         (string|null, primo url) e 'allegati' (string[], resto degli
     *         url) - solo se il Documento e' pubblico, altrimenti entrambi
     *         vuoti (la riga resta comunque, con gli altri campi).
     */
    private function buildRigaConAllegati(array $row)
    {
        $riga = $this->buildRigaBase($row);
        $riga['provvedimento'] = null;
        $riga['allegati'] = [];

        $object = $row['object'];
        if ($this->isPublic($object)) {
            $urls = \OpenPABootstrapItalia\Anac\DocumentFileResolver::resolveAllUrls($object);
            if (!empty($urls)) {
                $riga['provvedimento'] = array_shift($urls);
                $riga['allegati'] = $urls;
            }
        }

        return $riga;
    }

    /**
     * Formato verificato sull'esempio CSV reale ANAC (spec §4.2):
     * DATA;NUMERO;DENOMINAZIONE;OGGETTO;STRUTTURA_RESPONSABILE;PROVVEDIMENTO;ALLEGATO
     * (ALLEGATO singolare) - con piu' allegati per lo stesso atto, una riga
     * ripetuta per allegato (stessi DATA/NUMERO/.../PROVVEDIMENTO, cambia
     * solo ALLEGATO), non una colonna multivalore. Un atto senza allegati
     * produce comunque una riga (ALLEGATO vuoto).
     */
    private function toCsvGruppoConAllegati(array $rows)
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
            'DATA', 'NUMERO', 'DENOMINAZIONE', 'OGGETTO', 'STRUTTURA_RESPONSABILE', 'PROVVEDIMENTO', 'ALLEGATO',
        ])];

        foreach ($rows as $row) {
            $riga = $this->buildRigaConAllegati($row);
            $base = [(string)$riga['data'], (string)$riga['numero'], $riga['denominazione'], $riga['oggetto'], $riga['strutturaResponsabile'], (string)$riga['provvedimento']];
            if (empty($riga['allegati'])) {
                $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line(array_merge($base, ['']));
            } else {
                foreach ($riga['allegati'] as $allegato) {
                    $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line(array_merge($base, [$allegato]));
                }
            }
        }

        return implode("\n", $lines) . "\n";
    }

    public function toCsvOrganiConAllegati(array $provvedimenti = null)
    {
        return $this->toCsvGruppoConAllegati($this->getOrgani($provvedimenti));
    }

    public function toCsvDirigentiConAllegati(array $provvedimenti = null)
    {
        return $this->toCsvGruppoConAllegati($this->getDirigenti($provvedimenti));
    }

    /**
     * @param array $organi righe gia' filtrate (getOrgani()), puo' essere []
     * @param array $dirigenti righe gia' filtrate (getDirigenti()), puo' essere []
     * @return string JSON, gia' validato contro art.23-v1.0.schema.json
     * @throws \OpenPABootstrapItalia\Anac\InvalidAnacSchemaException se il JSON costruito non e' conforme
     */
    public function toJson($dataPrimaPubblicazione, $dataUltimaModifica, array $organi, array $dirigenti)
    {
        $data = [
            '$schema' => self::SCHEMA_URL,
            'intestazione' => [
                'amministrazione' => $this->getAmministrazione(),
                'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
                'dataUltimaModifica' => $dataUltimaModifica,
            ],
        ];

        $organiJson = $this->buildJsonProvvedimenti($organi);
        if (!empty($organiJson)) {
            $data['provvedimentiOrganiPolitici'] = $organiJson;
        }

        $dirigentiJson = $this->buildJsonProvvedimenti($dirigenti);
        if (!empty($dirigentiJson)) {
            $data['provvedimentiDirigDiAltraTipologia'] = $dirigentiJson;
        }

        $json = json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        \OpenPABootstrapItalia\Anac\JsonSchemaValidator::validate('art.23-v1.0.schema.json', $json);

        return $json;
    }

    /**
     * Accetta sia righe grezze {object: eZContentObject, denominazione,
     * group} (da fetchProvvedimenti(), caso reale) sia righe di test gia'
     * "appiattite" con una chiave '__override' (vedi
     * tests/test_art23_serializer_json.php) - hook esplicito di test, non
     * un'eccezione silenziosa: evita di dover costruire un vero
     * eZContentObject pubblicato solo per verificare la FORMA del JSON
     * prodotto. Il percorso con un vero eZContentObject (buildRigaConAllegati())
     * resta l'unico usato in produzione, dal cron (Task 9).
     *
     * @return array righe pronte per il JSON ANAC
     */
    private function buildJsonProvvedimenti(array $rows)
    {
        $items = [];
        foreach ($rows as $row) {
            $riga = $row['object'] instanceof \eZContentObject
                ? $this->buildRigaConAllegati($row)
                : array_merge($row['__override'], ['denominazione' => $row['denominazione'], 'provvedimento' => null, 'allegati' => []]);

            $item = [
                'data' => $riga['data'],
                'numero' => $riga['numero'],
                'denominazione' => $riga['denominazione'],
                'oggetto' => $riga['oggetto'],
                'strutturaResponsabile' => $riga['strutturaResponsabile'],
            ];
            if ($riga['provvedimento'] !== null) {
                $item['provvedimento'] = $riga['provvedimento'];
            }
            if (!empty($riga['allegati'])) {
                $item['allegati'] = $riga['allegati'];
            }
            $items[] = $item;
        }

        return $items;
    }
}
