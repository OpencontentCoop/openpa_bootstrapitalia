<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

/**
 * Export art. 13 (#478), solo profilo C1 (pubblica amministrazione) per ora -
 * vedi classes/anac/CLAUDE.md per la convenzione C2 (nessun modello dati
 * condiviso, fork manuali con tassonomia propria sotto lo stesso attributo
 * organization.type - non generalizzato qui, da adattare caso per caso).
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

    /** Radice della sotto-tassonomia "Struttura politica" (tagtree_csv/organizzazione.csv) */
    const TAG_PATH_STRUTTURA_POLITICA = '/891/1265/1266/';

    /** Radice della sotto-tassonomia "Struttura amministrativa" */
    const TAG_PATH_STRUTTURA_AMMINISTRATIVA = '/891/1265/1278/';

    private $amministrazione;

    public function __construct(array $amministrazione = null)
    {
        $this->amministrazione = $amministrazione ?: \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione();
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
     * @return array organi con i loro uffici, gia' pronti per CSV/JSON:
     *         [['denominazione','competenze','uffici' => [['tipologia','denominazione','competenze','nominativo','qualifica','contatti']]]]
     */
    public function fetchOrganiConUffici()
    {
        $organi = [];
        foreach ($this->fetchOrganizzazioniByTagPath(self::TAG_PATH_STRUTTURA_POLITICA) as $organoObject) {
            $organi[] = [
                'denominazione' => $organoObject->attribute('name'),
                'competenze' => $this->plainText($organoObject->dataMap()['main_function']),
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
        foreach ($this->fetchOrganizzazioniByTagPath(self::TAG_PATH_STRUTTURA_AMMINISTRATIVA) as $candidato) {
            $dataMap = $candidato->dataMap();
            if (!isset($dataMap['type']) || !$this->isTaggedArea($dataMap['type'])) {
                continue;
            }

            $holdEmployment = isset($dataMap['hold_employment']) ? $this->relatedObjectIds($dataMap['hold_employment']) : [];
            if (!empty($holdEmployment)) {
                continue;
            }

            $organi[] = [
                'denominazione' => $candidato->attribute('name'),
                'competenze' => $this->plainText($dataMap['main_function']),
                'uffici' => $this->fetchUfficiFigli($candidato),
            ];
        }

        return $organi;
    }

    private function isTaggedArea(\eZContentObjectAttribute $attribute)
    {
        $tags = $attribute->content();
        if (!$tags instanceof \eZTags) {
            return false;
        }

        foreach ($tags->attribute('tags') as $tagObject) {
            if ($tagObject->attribute('keyword') === 'Area') {
                return true;
            }
        }

        return false;
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

        foreach ($this->fetchOrganizzazioniByTagPath(self::TAG_PATH_STRUTTURA_AMMINISTRATIVA, $organo->attribute('id')) as $ufficioObject) {
            if (in_array((int)$ufficioObject->attribute('id'), $visitedIds, true)) {
                continue;
            }

            $responsabile = $this->fetchResponsabile($ufficioObject);

            $uffici[] = [
                'tipologia' => $responsabile !== null && $responsabile['incaricoDirigenziale'] ? 'Ufficio dirigenziale' : 'Ufficio non dirigenziale',
                'denominazione' => $ufficioObject->attribute('name'),
                'competenze' => $this->plainText($ufficioObject->dataMap()['main_function']),
                'nominativo' => $responsabile['nominativo'] ?? '',
                'qualifica' => $responsabile['qualifica'] ?? '',
                'contatti' => $this->fetchContatti($ufficioObject),
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

            return $organo;
        }, $organi);
    }

    private function contattiCompletiPerSchema(array $contatti)
    {
        if (empty($contatti['recapitoTelefonico'])) {
            return false;
        }

        return !empty($contatti['postaElettronicaOrdinaria']) || !empty($contatti['postaElettronicaCertificata']);
    }

    /**
     * @param string $tagPath path della sotto-tassonomia (Struttura politica / Struttura amministrativa)
     * @param int|null $holdEmploymentObjectId se presente, filtra solo le organization il cui
     *        campo hold_employment punta a questo object id (uffici figli di un organo)
     * @return \eZContentObject[]
     */
    private function fetchOrganizzazioniByTagPath($tagPath, $holdEmploymentObjectId = null)
    {
        $result = [];
        $class = \eZContentClass::fetchByIdentifier('organization');
        if (!$class instanceof \eZContentClass) {
            return $result;
        }

        $objects = \eZContentObject::fetchSameClassList($class->attribute('id'), true);

        foreach ($objects as $object) {
            $dataMap = $object->dataMap();
            if (!isset($dataMap['type']) || !$this->tagMatchesPath($dataMap['type'], $tagPath)) {
                continue;
            }

            if ($holdEmploymentObjectId !== null) {
                $relatedIds = isset($dataMap['hold_employment']) ? $this->relatedObjectIds($dataMap['hold_employment']) : [];
                if (!in_array((string)$holdEmploymentObjectId, $relatedIds)) {
                    continue;
                }
            }

            $result[] = $object;
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

    private function tagMatchesPath(\eZContentObjectAttribute $attribute, $tagPath)
    {
        /** @var \eZTags $tags */
        $tags = $attribute->content();
        if (!$tags instanceof \eZTags) {
            return false;
        }

        foreach ($tags->attribute('tags') as $tagObject) {
            if (strpos($tagObject->attribute('path_string'), $tagPath) === 0) {
                return true;
            }
        }

        return false;
    }

    /**
     * @return array|null ['nominativo' => ..., 'qualifica' => ..., 'incaricoDirigenziale' => bool]
     */
    private function fetchResponsabile(\eZContentObject $organizationObject)
    {
        $dataMap = $organizationObject->dataMap();
        if (!isset($dataMap['office_manager'])) {
            return null;
        }

        $roles = \OpenPARoles::instance($dataMap['office_manager'])->getRoles();
        $roleObject = reset($roles);
        if (!$roleObject instanceof \eZContentObject) {
            return null;
        }

        $roleDataMap = $roleObject->dataMap();

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
        $dataMap = $organizationObject->dataMap();
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
        $contactDataMap = $contactPointObject->dataMap();
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

        return $contatti;
    }

    /**
     * Export `art.13-rif` (Riferimenti e contatti, #478 - vedi CLAUDE.md,
     * "Riferimenti e contatti"). A differenza degli altri fetch di questa
     * classe (scan PHP di tutta la classe `organization`), qui si usa una
     * query Solr - lo stesso pattern gia' scelto per
     * Art31Serializer::fetchDocumentsByKeys(), per lo stesso motivo (evitare
     * uno scan completo su una classe che puo' avere molti oggetti nel sito)
     * e per poter ricevere una query gia' vincolata al subtree della pagina
     * "Telefono e posta elettronica" (vedi cronjobs/anac_export.php,
     * resolvePageTableQuery()) invece di cercare in tutto il sito.
     *
     * @param string $baseQuery query gia' compilata (query language
     *        Opencontent), es. "classes [online_contact_point] subtree [123]"
     * @return array lista di Riferimenti, uno per ogni online_contact_point
     *         trovato - nessun filtro sulla completezza (stessa tolleranza
     *         gia' usata per le celle vuote nel CSV di art.13-op/oa, a
     *         differenza del JSON che invece li scarterebbe - ma qui non
     *         esiste un JSON per questo schema, vedi CLAUDE.md)
     */
    public function fetchRiferimentiContatti($baseQuery)
    {
        $riferimenti = [];

        $queryBuilder = new \Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder();
        $queryObject = $queryBuilder->instanceQuery($baseQuery);

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
    public function toJson($dataPrimaPubblicazione, $dataUltimaModifica, array $organi = null, $isC1)
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
            // TODO: sorgente dell'organigramma non ancora individuata nel
            // content model - vedi classes/anac/CLAUDE.md, "Cosa manca".
            $organigramma = $this->fetchOrganigramma();
            if ($organigramma !== null) {
                $organiBlock['organigramma'] = $organigramma;
            }
        } else {
            $key = 'orgSocietaEdEnti';
        }

        $data = [
            'intestazione' => [
                'amministrazione' => $this->amministrazione,
                'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
                'dataUltimaModifica' => $dataUltimaModifica,
            ],
            $key => $organiBlock,
        ];

        return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }

    /**
     * @return string|null url assoluto dell'immagine/documento organigramma, o null se non ancora disponibile
     */
    private function fetchOrganigramma()
    {
        // Non ancora implementato: non individuata la sorgente dati reale
        // (probabile immagine/allegato su un contenuto dedicato, non un
        // campo di `organization`). Vedi CLAUDE.md.
        return null;
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
