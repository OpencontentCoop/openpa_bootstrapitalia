<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

/**
 * Export art. 31 (#477): tre CSV a se stanti (OIV, Organi di revisione,
 * Corte dei conti) + un JSON "file unico" che li copre tutti e tre insieme.
 *
 * Meccanismo di esposizione volutamente NON unificato tra le tre
 * sottosezioni (decisione 2026-09-15, vedi classes/anac/CLAUDE.md): OIV e
 * Organi di revisione sono contenuti editoriali reali (classe `document`,
 * filtrati per il nuovo attributo `anac_document_type` -
 * installer/modules/trasparenza/classes/document.yml), mentre Corte dei
 * conti e' un dataset tabellare gia' costruito per #475 (stesso pattern di
 * Art4BisSerializer).
 *
 * Struttura JSON verificata scaricando lo schema reale il 2026-09-15:
 * https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.31-v1.0.schema.json
 * (vedi classes/anac/CLAUDE.md, "Fonte di verita'") - non dedurla da
 * riassunti della pagina guida.
 */
class Art31Serializer
{
    const SCHEMA_IDENTIFIER_OIV = 'art.31-oiv';
    const SCHEMA_IDENTIFIER_OR = 'art.31-or';
    const SCHEMA_IDENTIFIER_OC = 'art.31-oc';

    /** Il JSON "file unico" non ha suffisso C1/C2/sottosezione, a differenza di art. 13 */
    const SCHEMA_IDENTIFIER_JSON = 'art.31';

    const KEY_VALIDAZIONE_PERFORMANCE = 'validazioneRelazioneSullaPerformance';
    const KEY_RELAZIONE_SISTEMA_VALUTAZIONE = 'relazioneSistemaDiValutazione';
    const KEY_ALTRI_ATTI_ORGANISMO = 'altriAttiOrganismoAnalogo';
    const KEY_RELAZIONE_BILANCIO_PREVISIONE = 'relazioneBilancioDiPrevisione';
    const KEY_RELAZIONE_CONTO_CONSUNTIVO = 'relazioneContoConsuntivo';

    const OIV_KEYS = [
        self::KEY_VALIDAZIONE_PERFORMANCE,
        self::KEY_RELAZIONE_SISTEMA_VALUTAZIONE,
        self::KEY_ALTRI_ATTI_ORGANISMO,
    ];

    const OR_KEYS = [
        self::KEY_RELAZIONE_BILANCIO_PREVISIONE,
        self::KEY_RELAZIONE_CONTO_CONSUNTIVO,
    ];

    /** remote_id del tag anac_document_type (installer/modules/trasparenza/tagtree_csv/anac_document_type.csv) => chiave ANAC */
    const TAG_REMOTE_ID_TO_KEY = [
        'anac_document_type_validazione_relazione_performance' => self::KEY_VALIDAZIONE_PERFORMANCE,
        'anac_document_type_relazione_sistema_valutazione' => self::KEY_RELAZIONE_SISTEMA_VALUTAZIONE,
        'anac_document_type_altri_atti_organismo' => self::KEY_ALTRI_ATTI_ORGANISMO,
        'anac_document_type_relazione_bilancio_previsione' => self::KEY_RELAZIONE_BILANCIO_PREVISIONE,
        'anac_document_type_relazione_conto_consuntivo' => self::KEY_RELAZIONE_CONTO_CONSUNTIVO,
    ];

    /**
     * TIPO_DOCUMENTO per il CSV (dalla tabella nella issue #477). Per
     * "altriAttiOrganismoAnalogo" non c'e' una stringa fissa: si usa il
     * titolo del documento stesso (vedi mapDocumentoToCsvRow()).
     */
    const TIPO_DOCUMENTO_CSV = [
        self::KEY_VALIDAZIONE_PERFORMANCE => 'Documento di validazione della Relazione sulla Performance',
        self::KEY_RELAZIONE_SISTEMA_VALUTAZIONE => "Relazione sul funzionamento complessivo del Sistema di valutazione, trasparenza e integrità dei controlli interni",
        self::KEY_RELAZIONE_BILANCIO_PREVISIONE => 'Relazione amministrativa e contabile al bilancio di previsione o budget e alle relative variazioni',
        self::KEY_RELAZIONE_CONTO_CONSUNTIVO => 'Relazioni amministrativa e contabile al conto consuntivo o al bilancio di esercizio',
    ];

    /**
     * Vocabolario reale (schema JSON, definizione OggettoRilievoCorteDeiConti):
     * "Attivita'" con l'apostrofo, non "Attività" con l'accento - verificato
     * anche sulla tabella campi della guida online, coincide.
     */
    const OGGETTO_AMMESSI = ["Organizzazione", "Attivita'", 'Entrambe'];

    private $amministrazione;

    /** @var \eZContentObjectAttribute attributo csv_resource del dataset "Rilievi della Corte dei conti" (remote_id corte_dei_conti) */
    private $corteDeiContiAttribute;

    public function __construct(\eZContentObjectAttribute $corteDeiContiAttribute, array $amministrazione = null)
    {
        $this->corteDeiContiAttribute = $corteDeiContiAttribute;
        $this->amministrazione = $amministrazione ?: \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione();
    }

    // ==================== OIV / Organi di revisione (classe document) ====================

    /**
     * @param string[] $keys sottoinsieme di OIV_KEYS o OR_KEYS
     * @return \eZContentObject[][] chiave ANAC => lista di document object con quel anac_document_type
     */
    public function fetchDocumentsByKeys(array $keys)
    {
        $result = [];
        foreach ($keys as $key) {
            $result[$key] = [];
        }

        $class = \eZContentClass::fetchByIdentifier('document');
        if (!$class instanceof \eZContentClass) {
            return $result;
        }

        foreach (\eZContentObject::fetchSameClassList($class->attribute('id'), true) as $object) {
            $dataMap = $object->dataMap();
            if (!isset($dataMap['anac_document_type'])) {
                continue;
            }

            /** @var \eZTags $tags */
            $tags = $dataMap['anac_document_type']->content();
            if (!$tags instanceof \eZTags) {
                continue;
            }

            foreach ($tags->attribute('tags') as $tag) {
                $remoteId = $tag->attribute('remote_id');
                if (!isset(self::TAG_REMOTE_ID_TO_KEY[$remoteId])) {
                    continue;
                }
                $key = self::TAG_REMOTE_ID_TO_KEY[$remoteId];
                if (in_array($key, $keys, true)) {
                    $result[$key][] = $object;
                }
                break;
            }
        }

        return $result;
    }

    /**
     * @return string|null url assoluta https del file allegato, o null se il documento non ha un file
     */
    private function fetchDocumentUrl(\eZContentObject $object)
    {
        $dataMap = $object->dataMap();
        if (!isset($dataMap['file']) || !$dataMap['file']->hasContent()) {
            return null;
        }

        $siteUrl = trim(\eZINI::instance()->variable('SiteSettings', 'SiteURL'), '/');

        return 'https://' . $siteUrl . '/content/download/' . $object->attribute('id') . '/' . $dataMap['file']->attribute('id');
    }

    /**
     * @return string|null data di pubblicazione in formato gg/mm/aaaa, o null se non impostata
     */
    private function fetchPublicationDate(\eZContentObject $object)
    {
        $dataMap = $object->dataMap();
        if (!isset($dataMap['publication_start_time'])) {
            return null;
        }
        $timestamp = (int)$dataMap['publication_start_time']->toString();

        return $timestamp > 0 ? date('d/m/Y', $timestamp) : null;
    }

    /**
     * "Il documento piu' recente per chiave" - decisione 2026-09-15 (vedi
     * classes/anac/CLAUDE.md): se piu' documenti hanno lo stesso
     * anac_document_type, nel JSON si tiene solo il piu' recente per data di
     * pubblicazione. Lo storico non si perde: resta nei file datati
     * immutabili di ExportPublisher.
     *
     * @param array|null $documentsByKey risultato gia' calcolato di fetchDocumentsByKeys($keys), per evitare
     *        di ripetere lo scan della classe document quando lo stesso set serve sia per il CSV che per il JSON
     *        (vedi cronjobs/anac_export.php)
     * @return array chiave ANAC => ['dataPubblicazione' => ..., 'documento' => ...] (solo le chiavi con almeno un documento valido)
     */
    private function buildDatiIdentificativiBlock(array $keys, array $documentsByKey = null)
    {
        $documentsByKey = $documentsByKey !== null ? $documentsByKey : $this->fetchDocumentsByKeys($keys);
        $block = [];

        foreach ($keys as $key) {
            $latest = null;
            $latestTimestamp = -1;
            foreach ($documentsByKey[$key] as $object) {
                $timestamp = (int)$object->dataMap()['publication_start_time']->toString();
                if ($timestamp > $latestTimestamp) {
                    $latestTimestamp = $timestamp;
                    $latest = $object;
                }
            }

            if ($latest === null) {
                continue;
            }

            $url = $this->fetchDocumentUrl($latest);
            $date = $this->fetchPublicationDate($latest);
            if ($url === null || $date === null) {
                // dati incompleti (nessun file allegato o nessuna data di
                // pubblicazione): omesso, non pubblicato come non valido -
                // stesso principio di Art13Serializer.
                continue;
            }

            $block[$key] = [
                'dataPubblicazione' => $date,
                'documento' => $url,
            ];
        }

        return $block;
    }

    public function getAttiOrganiDiValutazione(array $documentsByKey = null)
    {
        return $this->buildDatiIdentificativiBlock(self::OIV_KEYS, $documentsByKey);
    }

    public function getAttiOrganiDiRevisione(array $documentsByKey = null)
    {
        return $this->buildDatiIdentificativiBlock(self::OR_KEYS, $documentsByKey);
    }

    private function toCsvDocumenti(array $keys, array $documentsByKey = null)
    {
        $lines = [implode(';', ['TIPO_DOCUMENTO', 'DATA_PUBBLICAZIONE', 'DOCUMENTO'])];

        $documentsByKey = $documentsByKey !== null ? $documentsByKey : $this->fetchDocumentsByKeys($keys);
        foreach ($keys as $key) {
            foreach ($documentsByKey[$key] as $object) {
                $url = $this->fetchDocumentUrl($object);
                $date = $this->fetchPublicationDate($object);
                if ($url === null || $date === null) {
                    continue;
                }
                $tipoDocumento = isset(self::TIPO_DOCUMENTO_CSV[$key]) ? self::TIPO_DOCUMENTO_CSV[$key] : trim($object->attribute('name'));
                $lines[] = implode(';', [$tipoDocumento, $date, $url]);
            }
        }

        return implode("\r\n", $lines) . "\r\n";
    }

    public function toCsvOiv(array $documentsByKey = null)
    {
        return $this->toCsvDocumenti(self::OIV_KEYS, $documentsByKey);
    }

    public function toCsvOr(array $documentsByKey = null)
    {
        return $this->toCsvDocumenti(self::OR_KEYS, $documentsByKey);
    }

    // ==================== Corte dei conti (dataset) ====================

    /**
     * @return array righe grezze del dataset "Rilievi della Corte dei conti"
     */
    public function fetchRilieviGrezzi()
    {
        $repository = new \OpendataDatasetSearchableRepository($this->corteDeiContiAttribute);
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

    public function mapRilievo(array $data)
    {
        return [
            'dataPubblicazione' => $this->normalizeData($data['data_di_pubblicazione']),
            'oggetto' => $this->normalizeOggetto($data['oggetto']),
            'documento' => trim($data['documento']),
        ];
    }

    /**
     * Il campo dataset e' di tipo "date" (date_format DD/MM/YYYY): accetta
     * sia una stringa gia' nel formato giusto sia un timestamp numerico, per
     * non assumere quale delle due forme restituisca getData() in tutti i casi.
     */
    private function normalizeData($raw)
    {
        if (is_numeric($raw) && (int)$raw > 0) {
            return date('d/m/Y', (int)$raw);
        }

        return trim((string)$raw);
    }

    /**
     * Confronto tollerante ad accento vs apostrofo ("Attività" scritta dal
     * redattore vs "Attivita'" richiesta dallo schema) - normalizza entrambi
     * i lati rimuovendo accenti e apostrofi prima di confrontare, ma
     * restituisce sempre la stringa canonica esatta dello schema.
     */
    private function normalizeOggetto($raw)
    {
        $normalized = $this->stripAccentiEApostrofi(mb_strtolower(trim((string)$raw), 'UTF-8'));

        foreach (self::OGGETTO_AMMESSI as $valoreCanonico) {
            if ($normalized === $this->stripAccentiEApostrofi(mb_strtolower($valoreCanonico, 'UTF-8'))) {
                return $valoreCanonico;
            }
        }

        throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
            "Valore '{$raw}' non ammesso per il campo 'oggetto' (vocabolario ANAC schema art.31, rilievi Corte dei conti)"
        );
    }

    private function stripAccentiEApostrofi($s)
    {
        return str_replace(["à", "'", ' '], ['a', '', ''], $s);
    }

    public function toCsvOc()
    {
        $lines = [implode(';', ['DATA_PUBBLICAZIONE', 'OGGETTO', 'DOCUMENTO'])];

        foreach ($this->fetchRilieviGrezzi() as $raw) {
            $item = $this->mapRilievo($raw);
            $lines[] = implode(';', [$item['dataPubblicazione'], $item['oggetto'], $item['documento']]);
        }

        return implode("\r\n", $lines) . "\r\n";
    }

    /**
     * @return array|null null se non ci sono rilievi (il blocco JSON va omesso, non un array vuoto - vedi toJson())
     */
    public function getRilieviCorteDeiConti()
    {
        $rilievi = array_map(function ($raw) {
            $item = $this->mapRilievo($raw);

            return [
                'dataPubblicazione' => $item['dataPubblicazione'],
                'oggetto' => $item['oggetto'],
                'documento' => $item['documento'],
            ];
        }, $this->fetchRilieviGrezzi());

        return empty($rilievi) ? null : $rilievi;
    }

    // ==================== JSON "file unico" ====================

    /**
     * Verificato scaricando art.31-v1.0.schema.json il 2026-09-15: solo
     * "intestazione" e' obbligatoria a livello root - "attiOrganiDiValutazione",
     * "attiOrganiDiRevisione", "attiOrganiDiControllo" sono tutti opzionali
     * (per gli enti non tenuti a quell'obbligo) e vanno OMESSI del tutto se
     * vuoti, non inclusi come oggetto/array vuoto.
     */
    public function toJson($dataPrimaPubblicazione, $dataUltimaModifica, array $oivDocumentsByKey = null, array $orDocumentsByKey = null)
    {
        $data = [
            'intestazione' => [
                'amministrazione' => $this->amministrazione,
                'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
                'dataUltimaModifica' => $dataUltimaModifica,
            ],
        ];

        $attiOrganiDiValutazione = $this->getAttiOrganiDiValutazione($oivDocumentsByKey);
        if (!empty($attiOrganiDiValutazione)) {
            $data['attiOrganiDiValutazione'] = $attiOrganiDiValutazione;
        }

        $attiOrganiDiRevisione = $this->getAttiOrganiDiRevisione($orDocumentsByKey);
        if (!empty($attiOrganiDiRevisione)) {
            $data['attiOrganiDiRevisione'] = $attiOrganiDiRevisione;
        }

        $rilievi = $this->getRilieviCorteDeiConti();
        if ($rilievi !== null) {
            $data['attiOrganiDiControllo'] = ['rilieviCorteDeiConti' => $rilievi];
        }

        return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }
}
