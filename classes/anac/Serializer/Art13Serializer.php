<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

/**
 * Export art. 13 (#478), profili C1 (pubblica amministrazione) e C2
 * (societa' ed enti) - la tipologia si deriva dal binding reale
 * (schema_pubblicazione), vedi classes/anac/CLAUDE.md, "SchemaPubblicazioneLookup".
 *
 * Fonte dati, tutta gia' esistente (nessun nuovo attributo nel content model,
 * a differenza di art. 31): classe `organization` (organi/uffici, campo
 * eztags `type` su tassonomia "Organizzazione / Tipo di struttura
 * organizzativa") e classe `time_indexed_role` (responsabile di un
 * organo/ufficio, raggiunto tramite l'attributo `office_manager` di
 * `organization` - datatype `openparole`, gia' filtrato su ruolo
 * "Responsabile" - campo booleano `incarico_dirigenziale`, campo eztags
 * `role` per la qualifica).
 */
class Art13Serializer
{
    const SCHEMA_IDENTIFIER_AS = 'art.13-as';
    const SCHEMA_IDENTIFIER_OP = 'art.13-op';
    const SCHEMA_IDENTIFIER_OA = 'art.13-oa';
    const SCHEMA_IDENTIFIER_ORG = 'art.13-org';
    const SCHEMA_IDENTIFIER_RIF = 'art.13-rif';

    const SCHEMA_URL = 'https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.13-v1.0.schema.json';

    /**
     * Il JSON e' un "file unico" con un identificativo proprio, diverso da
     * quelli dei CSV: "pa" per Pubbliche Amministrazioni (C1), "se" per
     * Societa' ed Enti (C2) - da guida-servizi.anticorruzione.it (nomi dei
     * file di esempio scaricabili, es. art.13-pa-YYYYMMDD-YYYYMMDD.v1.0.json).
     */
    const SCHEMA_IDENTIFIER_JSON_C1 = 'art.13-pa';
    const SCHEMA_IDENTIFIER_JSON_C2 = 'art.13-se';

    const AMBITO_C1 = 'Pubbliche amministrazioni';
    const AMBITO_C2 = 'Società ed Enti';

    /**
     * Id numerico del tag "Struttura amministrativa" (tagtree_csv/organizzazione.csv),
     * per le query Solr (subattr_type___tag_ids____si contiene l'id del tag
     * assegnato PIU' tutti i suoi antenati, verificato su dati reali il
     * 2026-09-23 - basta cercare l'id della radice per includere qualunque
     * discendente).
     */
    const TAG_ID_STRUTTURA_AMMINISTRATIVA = 1278;

    /**
     * Id numerico del tag "Struttura politica" (tagtree_csv/organizzazione.csv),
     * stesso principio di TAG_ID_STRUTTURA_AMMINISTRATIVA: basta l'id della
     * radice per includere ogni discendente (Sindaco, Giunta, Assessorati,
     * Consiglio, Commissioni, ecc.) via subattr_type___tag_ids____si.
     */
    const TAG_ID_STRUTTURA_POLITICA = 1266;

    private $amministrazione;

    public function __construct(array $amministrazione = null)
    {
        $this->amministrazione = $amministrazione;
    }

    /**
     * Lazy: il codice fiscale non serve per i metodi usati dal rendering
     * live (fetchOrganiConUffici()/fetchOrganiAmministrativi(), dati grezzi
     * senza intestazione) - calcolarlo sempre nel costruttore romperebbe con
     * MissingCodiceFiscaleException anche solo per mostrare la tabella live,
     * su un sito che non ha ancora compilato il codice fiscale ma non sta
     * nemmeno chiedendo un export. Richiesto solo da toJson().
     */
    private function getAmministrazione()
    {
        if ($this->amministrazione === null) {
            $this->amministrazione = \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione();
        }

        return $this->amministrazione;
    }

    /**
     * @param bool $isC1 stessa scelta di toJson(): va passata dal chiamante,
     *        derivata da quale schema e' davvero agganciato a una pagina
     *        reale (art.13-op per C1, art.13-oa per C2) - non da una fonte
     *        esterna separata, altrimenti l'AMBITO_SOGGETTIVO scritto in
     *        questo file potrebbe disallinearsi dalla chiave/dal CSV organi
     *        effettivamente pubblicati (due fonti di verita' diverse nello
     *        stesso export).
     */
    public function getAmbitoSoggettivo($isC1)
    {
        return $isC1 ? self::AMBITO_C1 : self::AMBITO_C2;
    }

    public function toCsvAmbitoSoggettivo($isC1)
    {
        return "AMBITO_SOGGETTIVO\n" . $this->getAmbitoSoggettivo($isC1) . "\n";
    }

    /**
     * L'organigramma (solo C1, non previsto per i C2 - vedi #478) e' anche un
     * CSV a se' stante oltre al campo `organigramma` dentro il JSON "file
     * unico" - verificato scaricando l'esempio reale ANAC
     * (art.13-org-YYYYMMDD-YYYYMMDD.v1.0.csv): header ORGANIGRAMMA, una sola
     * riga con l'url.
     *
     * @param string $organigramma url gia' risolto (vedi Art13Serializer::fetchOrganigramma())
     */
    public function toCsvOrganigramma($organigramma)
    {
        return "ORGANIGRAMMA\n" . $organigramma . "\n";
    }

    /**
     * @return array organi con i loro uffici, gia' pronti per CSV/JSON:
     *         [['denominazione','competenze','uffici' => [['tipologia','denominazione','competenze','nominativo','qualifica','contatti']]]]
     */
    public function fetchOrganiConUffici()
    {
        $organi = [];
        foreach ($this->fetchOrganizzazioniByTagPath(self::TAG_ID_STRUTTURA_POLITICA) as $organoObject) {
            $organi[] = [
                'denominazione' => $organoObject->attribute('name'),
                'competenze' => $this->plainText($organoObject->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE)['main_function']),
                'uffici' => $this->fetchUfficiFigli($organoObject),
            ];
        }

        return $organi;
    }

    /**
     * @return array organi amministrativi di vertice (art.13-oa), stesso
     *         formato di fetchOrganiConUffici(). Un oggetto sotto "Struttura
     *         amministrativa" e' un organo di vertice solo se taggato
     *         ESATTAMENTE "Area" (non una foglia diversa, non il tag radice)
     *         E con `hold_employment` vuoto - verificato su comune.verona.it
     *         e comune.bugliano.pi.it che il solo `hold_employment` vuoto non
     *         basta: prenderebbe anche uffici orfani (dati incompleti, non
     *         organi) e oggetti che riusano la classe `organization` per
     *         altro (es. tag "Ente" per l'ente stesso o un ente esterno).
     *         Vedi CLAUDE.md, "Organi di amministrazione e gestione".
     */
    public function fetchOrganiAmministrativi()
    {
        $organi = [];
        foreach ($this->fetchVerticeAmministrativi() as $candidato) {
            $dataMap = $candidato->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);

            $organi[] = [
                'denominazione' => $candidato->attribute('name'),
                'competenze' => $this->plainText($dataMap['main_function']),
                'uffici' => $this->fetchUfficiFigli($candidato),
            ];
        }

        return $organi;
    }

    /**
     * @return \eZContentObject[] organization taggati ESATTAMENTE "Area" (non
     *         una foglia diversa, non il tag radice) E con hold_employment
     *         vuoto - stessa doppia condizione di prima (il solo tag "Area"
     *         prenderebbe anche le Direzioni, che sono taggate Area ma hanno
     *         hold_employment valorizzato; il solo hold_employment vuoto
     *         prenderebbe anche uffici orfani o oggetti che riusano la
     *         classe `organization` per altro, es. tag "Ente"), ora espressa
     *         come un'unica query Solr invece di scan + due controlli PHP.
     *
     * `limit 1000`: stesso motivo di fetchOrganizzazioniByTagPath() - senza
     * un limite esplicito la ricerca applica la paginazione di default (10
     * risultati), che taglierebbe fuori organi di vertice oltre il decimo su
     * un ente con molte Aree (verificato con uno spike dedicato, Task 1 del
     * piano collegato).
     */
    private function fetchVerticeAmministrativi()
    {
        $result = [];

        $query = 'classes [organization]'
            . ' and type in [\'"Area"\']'
            . ' and raw[submeta_hold_employment___id____si] !range [*,*]'
            . ' limit 1000';

        $queryBuilder = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
        $queryObject = $queryBuilder->instanceQuery($query);

        $solr = new \eZSolr();
        $searchResult = $solr->search('', (array)$queryObject->convert());

        foreach ($searchResult['SearchResult'] as $resultNode) {
            $object = $resultNode->attribute('object');
            if ($object instanceof \eZContentObject) {
                $result[] = $object;
            }
        }

        return $result;
    }

    /**
     * @param int[] $visitedIds guardia anti-ciclo per la ricorsione sotto -
     *        non dovrebbe mai servire su dati reali (hold_employment non
     *        dovrebbe formare cicli), ma un cron non deve andare in loop
     *        infinito per un dato malformato.
     */
    private function fetchUfficiFigli(\eZContentObject $organo, array $visitedIds = [])
    {
        $uffici = [];
        $visitedIds[] = (int)$organo->attribute('id');

        foreach ($this->fetchFigliDiOrgano($organo) as $ufficioObject) {
            if (in_array((int)$ufficioObject->attribute('id'), $visitedIds, true)) {
                continue;
            }

            $responsabile = $this->fetchResponsabile($ufficioObject);

            $uffici[] = [
                'tipologia' => $responsabile !== null && $responsabile['incaricoDirigenziale'] ? 'Ufficio dirigenziale' : 'Ufficio non dirigenziale',
                'denominazione' => $ufficioObject->attribute('name'),
                'competenze' => $this->plainText($ufficioObject->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE)['main_function']),
                'nominativo' => $responsabile['nominativo'] ?? '',
                'qualifica' => $responsabile['qualifica'] ?? '',
                'contatti' => $this->fetchContatti($ufficioObject),
                // Solo per il rendering live (vedi PageArticolazioneUfficiProvider) -
                // MAI esposta nel JSON pubblico: lo schema ANAC dichiara
                // "additionalProperties": false sull'oggetto Ufficio
                // (verificato su art.13-v1.0.schema.json), quindi questa
                // chiave viene rimossa esplicitamente in
                // filtraUfficiValidiPerJsonSchema() prima di json_encode().
                // Il CSV non e' a rischio: toCsvOrganiUffici() legge le
                // colonne una per una per nome, mai l'array intero.
                'url' => $this->resolveUfficioUrl($ufficioObject),
            ];

            // Gerarchia amministrativa reale fino a 3 livelli (Area ->
            // Direzione -> Ufficio, verificato su comune.verona.it): un
            // "ufficio" trovato qui puo' avere a sua volta altri uffici sotto
            // di se'. Lo schema ANAC prevede solo due livelli (Organo ->
            // Ufficio), quindi si appiattiscono tutti sotto lo stesso organo
            // di vertice invece di annidarli.
            foreach ($this->fetchUfficiFigli($ufficioObject, $visitedIds) as $nipote) {
                $uffici[] = $nipote;
            }
        }

        return $uffici;
    }

    /**
     * Lo schema JSON reale (art.13-v1.0.schema.json, scaricato il 2026-09-15)
     * richiede `nominativo`, `qualifica` e `contatti` come obbligatori per
     * ogni ufficio - e `contatti` a sua volta richiede `recapitoTelefonico`
     * + almeno una tra `postaElettronicaOrdinaria`/`postaElettronicaCertificata`
     * (definizione condivisa `Riferimenti` in commons-v1.0.schema.json). Un
     * ufficio senza responsabile configurato o senza contatti completi
     * produrrebbe un JSON non conforme allo schema - si preferisce OMETTERLO
     * dal blocco JSON piuttosto che pubblicare dati non validi, stesso
     * principio gia' usato per il vocabolario di art. 4-bis. **Solo per il
     * JSON**: il CSV non ha questo vincolo (tollera gia' celle vuote, es.
     * QUALIFICA_DIRIGENTE e' sempre vuota per costruzione - vedi sopra), e
     * mostra quindi tutti gli uffici trovati, incompleti o meno.
     */
    private function filtraUfficiValidiPerJsonSchema(array $organi)
    {
        return array_map(function ($organo) {
            $organo['uffici'] = array_values(array_filter($organo['uffici'], function ($ufficio) {
                // "qualifica" e' sempre vuota per costruzione (vedi fetchResponsabile) -
                // non e' un criterio di filtro utile, si controllano solo nominativo/contatti.
                return $ufficio['nominativo'] !== '' && $this->contattiCompletiPerSchema($ufficio['contatti']);
            }));
            $organo['uffici'] = array_map([$this, 'sanitizeUfficioPerJsonSchema'], $organo['uffici']);

            return $organo;
        }, $organi);
    }

    /**
     * L'oggetto Ufficio dello schema ANAC dichiara "additionalProperties":
     * false (verificato su art.13-v1.0.schema.json) - qualunque chiave
     * aggiunta all'array condiviso con CSV/rendering live (es. 'url', vedi
     * fetchUfficiFigli()) andrebbe altrimenti a finire anche nel JSON
     * pubblico, rendendolo non conforme. Allow-list esplicita delle sole
     * chiavi richieste dallo schema, invece di confidare che nessuno ne
     * aggiunga altre in futuro.
     */
    private function sanitizeUfficioPerJsonSchema(array $ufficio)
    {
        return [
            'tipologia' => $ufficio['tipologia'],
            'denominazione' => $ufficio['denominazione'],
            'competenze' => $ufficio['competenze'],
            'nominativo' => $ufficio['nominativo'],
            'qualifica' => $ufficio['qualifica'],
            'contatti' => $ufficio['contatti'],
        ];
    }

    /**
     * @return string|null url assoluto della pagina dell'ufficio (nodo
     *         principale dell'oggetto `organization`), o null se l'oggetto
     *         non ha un nodo pubblicato (caso limite, non dovrebbe succedere
     *         per un ufficio trovato via Solr).
     */
    private function resolveUfficioUrl(\eZContentObject $ufficioObject)
    {
        $node = $ufficioObject->attribute('main_node');
        if (!$node instanceof \eZContentObjectTreeNode) {
            return null;
        }

        return '/' . $node->attribute('url_alias');
    }

    private function contattiCompletiPerSchema(array $contatti)
    {
        if (empty($contatti['recapitoTelefonico'])) {
            return false;
        }

        return !empty($contatti['postaElettronicaOrdinaria']) || !empty($contatti['postaElettronicaCertificata']);
    }

    /**
     * @param int $tagId id numerico della radice del ramo tassonomico
     *        (TAG_ID_STRUTTURA_POLITICA o TAG_ID_STRUTTURA_AMMINISTRATIVA)
     * @return \eZContentObject[]
     *
     * Query Solr diretta (stesso pattern di fetchFigliDiOrgano() sotto):
     * subattr_type___tag_ids____si contiene l'id del tag assegnato piu'
     * tutti i suoi antenati, quindi cercare l'id della radice include
     * qualunque discendente - sostituisce lo scan PHP completo della classe
     * organization che faceva prima questa funzione (poteva esaurire la
     * memoria PHP su un sito con molti oggetti, stesso motivo per cui
     * Art31Serializer::fetchDocumentsByKeys() evita lo scan per `document`).
     *
     * `limit 1000`: senza un limite esplicito la ricerca applica la
     * paginazione di default (10 risultati) - verificato con uno spike
     * dedicato (vedi commit collegato) che un ente con piu' di 10 organi
     * politici o amministrativi perderebbe silenziosamente quelli oltre il
     * decimo. 1000 e' un tetto ampiamente superiore a quanti organi/uffici
     * possa avere realisticamente un singolo ente.
     */
    private function fetchOrganizzazioniByTagPath($tagId)
    {
        $result = [];

        $query = 'classes [organization] and raw[subattr_type___tag_ids____si] in [' . (int)$tagId . '] limit 1000';

        $queryBuilder = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
        $queryObject = $queryBuilder->instanceQuery($query);

        $solr = new \eZSolr();
        $searchResult = $solr->search('', (array)$queryObject->convert());

        foreach ($searchResult['SearchResult'] as $resultNode) {
            $object = $resultNode->attribute('object');
            if ($object instanceof \eZContentObject) {
                $result[] = $object;
            }
        }

        return $result;
    }

    /**
     * @return \eZContentObject[] oggetti "Struttura amministrativa" il cui
     *         hold_employment punta a $organo (uffici figli, un livello) -
     *         query Solr mirata invece di uno scan PHP completo della classe
     *         organization: questo metodo viene chiamato una volta per OGNI
     *         nodo nella ricorsione di fetchUfficiFigli(), quindi uno scan
     *         completo qui si moltiplicherebbe per la profondita' reale
     *         della gerarchia (fino a 3 livelli, Area -> Direzione ->
     *         Ufficio, verificato su comune.verona.it). Campi Solr verificati
     *         su dati reali di dev il 2026-09-23: subattr_type___tag_ids____si
     *         contiene l'id del tag assegnato piu' tutti i suoi antenati
     *         (basta cercare la radice "Struttura amministrativa" per
     *         includere qualunque discendente), submeta_hold_employment___id____si
     *         contiene l'id dell'oggetto puntato da hold_employment.
     */
    private function fetchFigliDiOrgano(\eZContentObject $organo)
    {
        $result = [];

        $query = 'classes [organization]'
            . ' and raw[subattr_type___tag_ids____si] in [' . self::TAG_ID_STRUTTURA_AMMINISTRATIVA . ']'
            . ' and raw[submeta_hold_employment___id____si] in [' . (int)$organo->attribute('id') . ']';

        $queryBuilder = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
        $queryObject = $queryBuilder->instanceQuery($query);

        $solr = new \eZSolr();
        $searchResult = $solr->search('', (array)$queryObject->convert());

        foreach ($searchResult['SearchResult'] as $resultNode) {
            $object = $resultNode->attribute('object');
            if ($object instanceof \eZContentObject) {
                $result[] = $object;
            }
        }

        return $result;
    }

    /**
     * @return string[] contentobject_id come stringhe (formato di eZObjectRelationListType::toString())
     */
    private function relatedObjectIds(\eZContentObjectAttribute $attribute)
    {
        $string = $attribute->toString();

        return $string === '' ? [] : explode('-', $string);
    }

    /**
     * @return array|null ['nominativo' => ..., 'qualifica' => ..., 'incaricoDirigenziale' => bool]
     */
    private function fetchResponsabile(\eZContentObject $organizationObject)
    {
        $dataMap = $organizationObject->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        if (!isset($dataMap['office_manager'])) {
            return null;
        }

        $roles = \OpenPARoles::instance($dataMap['office_manager'])->getRoles();
        $roleObject = reset($roles);
        if (!$roleObject instanceof \eZContentObject) {
            return null;
        }

        $roleDataMap = $roleObject->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);

        $personName = '';
        if (isset($roleDataMap['person'])) {
            $personIds = $this->relatedObjectIds($roleDataMap['person']);
            if (!empty($personIds)) {
                $personObject = \eZContentObject::fetch((int)$personIds[0]);
                if ($personObject instanceof \eZContentObject) {
                    $personName = $personObject->attribute('name');
                }
            }
        }

        // QUALIFICA_DIRIGENTE: il tag "role" di questo time_indexed_role e'
        // sempre "Responsabile" per costruzione (e' il filtro con cui
        // office_manager trova questo ruolo, vedi OpenPARoles::getRoleFilter())
        // - non e' una qualifica nel senso ANAC del termine, e il nostro
        // content model non ha un campo distinto per il titolo formale del
        // dirigente. Lasciato vuoto: coerente con l'esempio ANAC stesso, dove
        // QUALIFICA_DIRIGENTE e' vuota negli esempi scaricabili.
        $qualifica = '';

        $incaricoDirigenziale = isset($roleDataMap['incarico_dirigenziale']) && (bool)$roleDataMap['incarico_dirigenziale']->content();

        return [
            'nominativo' => $personName,
            'qualifica' => $qualifica,
            'incaricoDirigenziale' => $incaricoDirigenziale,
        ];
    }

    private function fetchContatti(\eZContentObject $organizationObject)
    {
        $dataMap = $organizationObject->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        if (!isset($dataMap['has_online_contact_point'])) {
            return [];
        }

        $relatedIds = $this->relatedObjectIds($dataMap['has_online_contact_point']);
        if (empty($relatedIds)) {
            return [];
        }

        $contactPointObject = \eZContentObject::fetch((int)$relatedIds[0]);
        if (!$contactPointObject instanceof \eZContentObject) {
            return [];
        }

        return $this->parseContattiMatrix($contactPointObject);
    }

    /**
     * @param \eZContentObject $contactPointObject oggetto di classe `online_contact_point`
     * @return array ['recapitoTelefonico'=>..., 'postaElettronicaOrdinaria'=>..., 'postaElettronicaCertificata'=>...] (solo le chiavi con un valore)
     */
    private function parseContattiMatrix(\eZContentObject $contactPointObject)
    {
        $contactDataMap = $contactPointObject->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        if (!isset($contactDataMap['contact'])) {
            return [];
        }

        // online_contact_point.contact e' un ezmatrix a 3 colonne (type/value/contact,
        // una riga per contatto) - struttura diversa dalla matrice "contacts" a 2
        // colonne (nome/valore) della Homepage: NON riusare OpenPAAttributeContactsHandler
        // qui, e' per l'altra struttura e darebbe dati sbagliati.
        /** @var \eZMatrix $matrix */
        $matrix = $contactDataMap['contact']->content();
        if (!$matrix instanceof \eZMatrix) {
            return [];
        }

        $rows = $matrix->attribute('rows');
        $rows = is_array($rows) && isset($rows['sequential']) ? $rows['sequential'] : [];

        $contatti = [];
        foreach ($rows as $row) {
            $tipo = isset($row['columns'][0]) ? trim($row['columns'][0]) : '';
            $valore = isset($row['columns'][1]) ? trim($row['columns'][1]) : '';
            if ($valore === '') {
                continue;
            }
            if (strcasecmp($tipo, 'Telefono') === 0) {
                $contatti['recapitoTelefonico'] = $valore;
            } elseif (strcasecmp($tipo, 'Email') === 0) {
                $contatti['postaElettronicaOrdinaria'] = $valore;
            } elseif (strcasecmp($tipo, 'PEC') === 0) {
                $contatti['postaElettronicaCertificata'] = $valore;
            }
        }

        // Solo per il rendering live (vedi PageRiferimentiContattiProvider) -
        // MAI esposta nel CSV pubblico: toCsvRiferimenti() legge le tre
        // colonne una per una per chiave esplicita, mai l'array intero, quindi
        // questa chiave in piu' non vi finisce mai (stesso principio gia'
        // usato per 'url' su Art13Serializer::fetchUfficiFigli()).
        $contatti['denominazione'] = $contactPointObject->attribute('name');

        return $contatti;
    }

    /**
     * Export `art.13-rif` (Riferimenti e contatti, #478 - vedi CLAUDE.md,
     * "Riferimenti e contatti"). Hardcoded come gli altri fetch di questa
     * classe (fetchOrganizzazioniByTagPath()) - non dipende dal campo
     * `fields` di nessuna pagina (stesso principio adottato poi anche per
     * Art31Serializer::fetchDocumentsByKeys(), vedi il suo docblock): la
     * sorgente e' sempre la radice reale del
     * sito (`[NodeSettings]RootNode`, content.ini - lo stesso nodo "Homepage"
     * da cui discende tutto il content model), indipendentemente da quale
     * pagina dichiari `schema_pubblicazione: art.13-rif`. Questo disaccoppia
     * "da dove si legge il dato" (qui) da "dove si pubblica l'url" (il nodo
     * passato a ExportPublisher in cronjobs/anac_export.php) - stesso
     * principio gia' in uso per art.4-bis/art.31-cc (dataset per remote_id
     * fisso, vedi CLAUDE.md "Node id da passare a ExportPublisher").
     *
     * Resta una query Solr (non uno scan PHP come fetchOrganizzazioniByTagPath()):
     * a differenza di `organization`, `online_contact_point` non ha un
     * attributo di tipo su cui filtrare, quindi uno scan completo
     * includerebbe anche eventuali altri usi dello stesso content type nel
     * sito - lo stesso motivo per cui Art31Serializer::fetchDocumentsByKeys()
     * usa Solr invece di uno scan per `document`.
     *
     * @return array lista di Riferimenti, uno per ogni online_contact_point
     *         trovato - nessun filtro sulla completezza (stessa tolleranza
     *         gia' usata per le celle vuote nel CSV di art.13-op/oa, a
     *         differenza del JSON che invece li scarterebbe - ma qui non
     *         esiste un JSON per questo schema, vedi CLAUDE.md)
     */
    public function fetchRiferimentiContatti()
    {
        $riferimenti = [];

        $rootNodeId = (int)\eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode');
        $queryBuilder = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
        $queryObject = $queryBuilder->instanceQuery("classes [online_contact_point] subtree [{$rootNodeId}]");

        $solr = new \eZSolr();
        $searchResult = $solr->search('', (array)$queryObject->convert());

        foreach ($searchResult['SearchResult'] as $resultNode) {
            $object = $resultNode->attribute('object');
            if (!$object instanceof \eZContentObject) {
                continue;
            }

            $riferimenti[] = $this->parseContattiMatrix($object);
        }

        return $riferimenti;
    }

    public function toCsvRiferimenti(array $riferimenti = null)
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line(['RECAPITO_TELEFONICO', 'POSTA_ELETTRONICA_ORDINARIA', 'POSTA_ELETTRONICA_CERTIFICATA'])];

        foreach (($riferimenti !== null ? $riferimenti : []) as $riferimento) {
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
                $riferimento['recapitoTelefonico'] ?? '',
                $riferimento['postaElettronicaOrdinaria'] ?? '',
                $riferimento['postaElettronicaCertificata'] ?? '',
            ]);
        }

        return implode("\n", $lines) . "\n";
    }

    /**
     * strip_tags() da solo incolla senza spazio il testo di paragrafi/righe
     * consecutivi (verificato su dati reali: "...dipendenti.Le funzioni..."
     * da due <p> distinti, "</p><p>" nell'output_text) e lascia intatti
     * eventuali ritorni a capo gia' presenti nell'output (es. da interruzioni
     * di riga dentro un paragrafo) - questi ultimi rompono il CSV se non
     * quotati (bug segnalato da Federica su cms#478). Si inserisce uno spazio
     * ai confini dei tag di blocco/interruzione riga PRIMA di spogliare i
     * tag, poi si comprime qualunque spazio bianco residuo (spazi multipli,
     * ma anche ritorni a capo gia' nell'output) in un singolo spazio: il
     * risultato e' sempre una stringa su una riga sola.
     */
    private function plainText($attribute)
    {
        if (!$attribute instanceof \eZContentObjectAttribute) {
            return '';
        }

        $content = $attribute->content();
        if ($content instanceof \eZXMLText) {
            $html = $content->attribute('output')->attribute('output_text');
            $html = preg_replace('/<\/(p|div|li|h[1-6])>|<br\s*\/?>/i', ' ', $html);

            return trim(preg_replace('/\s+/u', ' ', strip_tags($html)));
        }

        return trim(preg_replace('/\s+/u', ' ', (string)$content));
    }

    /**
     * @param array|null $organi risultato gia' pronto di fetchOrganiConUffici(),
     *        per evitare di ricalcolarlo se il chiamante lo ha gia' fatto
     *        (es. per l'hash di ExportPublisher::publishWithDates())
     */
    /**
     * @param bool $isC1 quale delle due strutture ANAC usare (chiave root
     *        "orgPubblicheAmministrazioni" o "orgSocietaEdEnti") - va passato
     *        esplicitamente dal chiamante, derivato da quale schema e'
     *        davvero agganciato a una pagina reale (schema_pubblicazione:
     *        art.13-op per C1, art.13-oa per C2). Non derivato qui da una
     *        fonte esterna separata: sarebbe una seconda fonte di verita'
     *        che potrebbe disallinearsi da quale pagina e' realmente
     *        configurata (es. un fork mal configurato) - un solo punto
     *        decide, il chiamante lo passa gia' deciso.
     */
    /**
     * @param string|null $organigramma url gia' risolto (vedi fetchOrganigramma())
     *        - passato gia' pronto dal chiamante, non ricalcolato qui, cosi'
     *        puo' entrare nell'hash di ExportPublisher::publishWithDates()
     *        insieme a $organi: un cambiamento del solo organigramma deve
     *        far scattare una nuova pubblicazione tanto quanto un cambiamento
     *        degli organi.
     */
    public function toJson($dataPrimaPubblicazione, $dataUltimaModifica, array $organi = null, $isC1, $organigramma = null)
    {
        // Verificato sui file di esempio scaricati da ANAC il 2026-09-15: NON
        // esiste un campo "ambitoSoggettivo" esplicito in questo JSON (a
        // differenza di quanto suggeriva l'esempio nella issue #478 - un
        // paraphrase impreciso, non il file reale). L'ambito e' espresso
        // solo dalla chiave usata: "orgPubblicheAmministrazioni" (C1) o
        // "orgSocietaEdEnti" (C2). "organigramma" sta dentro questo blocco,
        // non a livello root, e solo per C1.
        $organi = $organi !== null ? $organi : $this->fetchOrganiConUffici();
        if (empty($organi)) {
            // Lo schema richiede "organi" non vuoto (minItems: 1). Per un
            // comune reale, zero organi (nessun Consiglio/Giunta trovato) e'
            // quasi certamente un bug (query rotta, tag organization.type
            // mancante), non uno stato legittimo - blocca invece di
            // pubblicare un file non conforme (decisione con Marco il
            // 2026-09-15, vedi EmptyExportException).
            throw new \OpenPABootstrapItalia\Anac\EmptyExportException(
                'Nessun organo trovato: lo schema ANAC richiede organi non vuoto, export art.13 (JSON) bloccato'
            );
        }
        $organiBlock = ['organi' => $this->filtraUfficiValidiPerJsonSchema($organi)];

        if ($isC1) {
            $key = 'orgPubblicheAmministrazioni';
            if ($organigramma !== null) {
                $organiBlock['organigramma'] = $organigramma;
            }
        } else {
            $key = 'orgSocietaEdEnti';
        }

        $data = [
            '$schema' => self::SCHEMA_URL,
            'intestazione' => [
                'amministrazione' => $this->getAmministrazione(),
                'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
                'dataUltimaModifica' => $dataUltimaModifica,
            ],
            $key => $organiBlock,
        ];

        return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }

    /**
     * L'organigramma (art. 13, co. 1, lett. b, d.lgs. 33/2013 - stesso punto
     * normativo di "Articolazione degli uffici", non un obbligo a se stante)
     * e' un documento pubblicato come figlio della stessa pagina "Articolazione
     * degli uffici": nessun tag o attributo dedicato lo identifica, e' il
     * documento stesso a far fede. Se ne esiste piu' di uno (es. una versione
     * aggiornata caricata senza rimuovere la precedente), vince il piu'
     * recente per data di pubblicazione - stesso principio gia' usato per i
     * duplicati di Art31Serializer.
     *
     * @return string|null url assoluto del file organigramma, o null se nessun documento e' stato pubblicato lì
     */
    public function fetchOrganigramma($rootNodeId)
    {
        if ($rootNodeId === null) {
            return null;
        }

        $query = 'classes [document] subtree [' . (int)$rootNodeId . ']';
        $queryBuilder = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
        $queryObject = $queryBuilder->instanceQuery($query);
        $solr = new \eZSolr();
        $searchResult = $solr->search('', (array)$queryObject->convert());

        $latestObject = null;
        $latestPublicationTime = null;
        foreach ($searchResult['SearchResult'] as $resultNode) {
            $object = $resultNode->attribute('object');
            if (!$object instanceof \eZContentObject) {
                continue;
            }
            $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
            $publicationTime = isset($dataMap['publication_start_time']) ? (int)$dataMap['publication_start_time']->toString() : 0;
            if ($latestObject === null || $publicationTime > $latestPublicationTime) {
                $latestObject = $object;
                $latestPublicationTime = $publicationTime;
            }
        }

        if ($latestObject === null) {
            return null;
        }

        return \OpenPABootstrapItalia\Anac\DocumentFileResolver::resolveUrl($latestObject);
    }

    public function toCsvOrganiUffici(array $organi = null)
    {
        $headers = [
            'DENOMINAZIONE_ORGANO', 'COMPETENZE_ORGANO',
            'DENOMINAZIONE_UFFICIO_DIRIGENZIALE', 'DENOMINAZIONE_UFFICIO_NON_DIRIGENZIALE',
            'COMPETENZE_UFFICIO', 'NOMINATIVO_DIRIGENTE', 'QUALIFICA_DIRIGENTE',
            'RECAPITO_TELEFONICO', 'POSTA_ELETTRONICA_ORDINARIA', 'POSTA_ELETTRONICA_CERTIFICATA',
        ];
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line($headers)];

        foreach (($organi !== null ? $organi : $this->fetchOrganiConUffici()) as $organo) {
            foreach ($organo['uffici'] as $ufficio) {
                $isDirigenziale = $ufficio['tipologia'] === 'Ufficio dirigenziale';
                $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
                    $organo['denominazione'],
                    $organo['competenze'],
                    $isDirigenziale ? $ufficio['denominazione'] : '',
                    $isDirigenziale ? '' : $ufficio['denominazione'],
                    $ufficio['competenze'],
                    $ufficio['nominativo'],
                    $ufficio['qualifica'],
                    $ufficio['contatti']['recapitoTelefonico'] ?? '',
                    $ufficio['contatti']['postaElettronicaOrdinaria'] ?? '',
                    $ufficio['contatti']['postaElettronicaCertificata'] ?? '',
                ]);
            }
        }

        return implode("\n", $lines) . "\n";
    }
}
