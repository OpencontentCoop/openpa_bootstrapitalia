<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

/**
 * art.20 - Performance e premi (cms#486), schema ad adesione volontaria,
 * SOLO C1 (il profilo co.2 ha un dubbio aperto sul perimetro soggettivo,
 * nessuna variante ridotta nello schema reale - vedi issue, "Note aperte").
 * Due dataset content object distinti (classe dataset, csv_resource) - nessun
 * attributo nuovo sul content model, stesso pattern di Art12Serializer/
 * Art36Serializer.
 *
 * A differenza di tutti gli altri schemi ANAC gia' implementati, il JSON
 * rappresenta UNA SOLA annualita' per blocco (oggetto singolo, non array -
 * verificato scaricando art.20-v1.0.schema.json il 2026-11-13,
 * PremiStanziati/TrattamentoAccessorio), mentre il dataset/CSV restano
 * multi-riga (una riga per anno, come richiesto dall'issue). Risolto con lo
 * stesso principio gia' in uso in Art31Serializer per OIV/Organi di
 * revisione ("il documento piu' recente per chiave nel JSON, tutti nel
 * CSV"): qui la chiave di raggruppamento e' l'anno (co.1) o anno+tipologia
 * (co.2), non un document_type.
 */
class Art20Serializer
{
    const SCHEMA_IDENTIFIER_CSV_PREMI = 'art.20-premi';
    const SCHEMA_IDENTIFIER_JSON_CO1 = 'art.20';
    const SCHEMA_IDENTIFIER_CSV_DIRIG = 'art.20-dirig';
    const SCHEMA_IDENTIFIER_CSV_NON_DIRIG = 'art.20-non-dirig';
    const SCHEMA_IDENTIFIER_JSON_CO2 = 'art.20-c2';
    const SCHEMA_URL = 'https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.20-v1.0.schema.json';

    /** @var \eZContentObjectAttribute */
    private $ammontarePremiAttribute;

    /** @var \eZContentObjectAttribute */
    private $datiPremiAttribute;

    public function __construct(
        \eZContentObjectAttribute $ammontarePremiAttribute,
        \eZContentObjectAttribute $datiPremiAttribute
    ) {
        $this->ammontarePremiAttribute = $ammontarePremiAttribute;
        $this->datiPremiAttribute = $datiPremiAttribute;
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

    /**
     * A parita' di anno piu' alto, vince l'ultima riga nell'ordine
     * restituito dal repository - nessuna richiesta esplicita di
     * deduplicazione nell'issue, comportamento accettato (vedi spec).
     *
     * @param array $righe righe gia' mappate, ciascuna con chiave 'anno' (int)
     * @return array|null la riga con 'anno' piu' alto, null se $righe e' vuoto
     */
    public function pickRigaPiuRecente(array $righe)
    {
        $scelta = null;
        foreach ($righe as $riga) {
            if ($scelta === null || $riga['anno'] >= $scelta['anno']) {
                $scelta = $riga;
            }
        }

        return $scelta;
    }

    // ---------------------------------------------------------------
    // co.1 - Ammontare complessivo dei premi
    // ---------------------------------------------------------------

    public function fetchRigheAmmontarePremi()
    {
        return $this->fetchRighe($this->ammontarePremiAttribute);
    }

    public function mapRigaAmmontarePremi(array $data)
    {
        return [
            'anno' => (int)trim((string)$data['anno']),
            'premiStanziati' => trim((string)$data['premi_stanziati']),
            'premiErogati' => trim((string)$data['premi_erogati']),
        ];
    }

    public function toCsvPremi()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line(['ANNO', 'PREMI_STANZIATI', 'PREMI_EROGATI'])];

        foreach ($this->fetchRigheAmmontarePremi() as $raw) {
            $riga = $this->mapRigaAmmontarePremi($raw);
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
                $riga['anno'], $riga['premiStanziati'], $riga['premiErogati'],
            ]);
        }

        return implode("\n", $lines) . "\n";
    }

    /**
     * @return array|null la riga con anno piu' alto, null se il dataset non
     *         ha righe - il chiamante (publishArt20(), Task 7) deve allora
     *         omettere del tutto co.1 (nessuno stato vuoto valido nello
     *         schema reale: ammontareComplessivoPremiStanziati e' required
     *         nella prima alternativa del oneOf, vedi toJsonCo1()).
     */
    public function getAmmontarePremiPiuRecente()
    {
        $righe = array_map([$this, 'mapRigaAmmontarePremi'], $this->fetchRigheAmmontarePremi());

        return $this->pickRigaPiuRecente($righe);
    }

    /**
     * $ammontarePremi deve essere il valore (non-null) di
     * getAmmontarePremiPiuRecente() - a differenza di Art12Serializer::toJsonPa1Bis(),
     * QUI non esiste nessuno stato "vuoto" valido da rappresentare.
     */
    public function toJsonCo1($dataPrimaPubblicazione, $dataUltimaModifica, array $ammontarePremi)
    {
        $data = [
            '$schema' => self::SCHEMA_URL,
            'intestazione' => [
                'amministrazione' => \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione(),
                'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
                'dataUltimaModifica' => $dataUltimaModifica,
            ],
            'ammontareComplessivoPremiStanziati' => [
                'anno' => $ammontarePremi['anno'],
                'premiStanziati' => $ammontarePremi['premiStanziati'],
                'premiErogati' => $ammontarePremi['premiErogati'],
            ],
        ];

        return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }

    const TIPOLOGIA_DIRIGENZIALE = 'Dirigenziale';
    const TIPOLOGIA_NON_DIRIGENZIALE = 'Non dirigenziale';

    // ---------------------------------------------------------------
    // co.2 - Dati relativi ai premi
    // ---------------------------------------------------------------

    public function fetchRigheDatiPremi()
    {
        return $this->fetchRighe($this->datiPremiAttribute);
    }

    public function mapRigaDatiPremi(array $data)
    {
        return [
            'tipologia' => $this->normalizeTipologia($data['tipologia_personale']),
            'anno' => (int)trim((string)$data['anno']),
            'criteriUtilizzati' => trim((string)$data['criteri']),
            'premioComplessivoStanziato' => trim((string)$data['premio_stanziato']),
            'premioComplessivoErogato' => trim((string)$data['premio_erogato']),
            'premioMediamentePercepito' => trim((string)$data['premio_mediamente_percepito']),
            'gradoDifferenziazione' => trim((string)$data['grado_di_differenziazione']),
        ];
    }

    private function normalizeTipologia($raw)
    {
        $normalized = mb_strtolower(trim((string)$raw), 'UTF-8');

        foreach ([self::TIPOLOGIA_DIRIGENZIALE, self::TIPOLOGIA_NON_DIRIGENZIALE] as $valoreCanonico) {
            if ($normalized === mb_strtolower($valoreCanonico, 'UTF-8')) {
                return $valoreCanonico;
            }
        }

        throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
            "Valore '{$raw}' non ammesso per il campo 'tipologia_personale' (vocabolario ANAC schema art.20, dati relativi ai premi)"
        );
    }

    private function righePerTipologia($tipologia)
    {
        return array_values(array_filter(
            array_map([$this, 'mapRigaDatiPremi'], $this->fetchRigheDatiPremi()),
            function ($riga) use ($tipologia) {
                return $riga['tipologia'] === $tipologia;
            }
        ));
    }

    private function toCsvTipologia($tipologia)
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
            'ANNO', 'CRITERI', 'PREMIO_STANZIATO', 'PREMIO_EROGATO', 'PREMIO_MEDIAMENTE_PERCEPITO', 'GRADO_DI_DIFFERENZIAZIONE',
        ])];

        foreach ($this->righePerTipologia($tipologia) as $riga) {
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
                $riga['anno'], $riga['criteriUtilizzati'], $riga['premioComplessivoStanziato'],
                $riga['premioComplessivoErogato'], $riga['premioMediamentePercepito'], $riga['gradoDifferenziazione'],
            ]);
        }

        return implode("\n", $lines) . "\n";
    }

    public function toCsvDirig()
    {
        return $this->toCsvTipologia(self::TIPOLOGIA_DIRIGENZIALE);
    }

    public function toCsvNonDirig()
    {
        return $this->toCsvTipologia(self::TIPOLOGIA_NON_DIRIGENZIALE);
    }

    /**
     * @return array|null la riga piu' recente di questa tipologia, null se
     *         non esiste nessuna riga - il chiamante (publishArt20(), Task 7)
     *         deve allora omettere sia il CSV sia la chiave JSON di questa
     *         tipologia (richiesta esplicita issue, "ove previsti dai CCNL").
     */
    public function getDirigPiuRecente()
    {
        return $this->pickRigaPiuRecente($this->righePerTipologia(self::TIPOLOGIA_DIRIGENZIALE));
    }

    public function getNonDirigPiuRecente()
    {
        return $this->pickRigaPiuRecente($this->righePerTipologia(self::TIPOLOGIA_NON_DIRIGENZIALE));
    }

    private function buildTrattamentoAccessorio(array $riga)
    {
        return [
            'anno' => $riga['anno'],
            'criteriUtilizzati' => $riga['criteriUtilizzati'],
            'premioComplessivoStanziato' => $riga['premioComplessivoStanziato'],
            'premioComplessivoErogato' => $riga['premioComplessivoErogato'],
            'premioMediamentePercepito' => $riga['premioMediamentePercepito'],
            'gradoDifferenziazione' => $riga['gradoDifferenziazione'],
        ];
    }

    /**
     * $dirig/$nonDirig: valore di getDirigPiuRecente()/getNonDirigPiuRecente(),
     * entrambi possono essere null ma non insieme - il chiamante
     * (publishArt20(), Task 7) non deve invocare questo metodo se sono
     * entrambi null (nessuno stato "entrambi assenti" valido da pubblicare,
     * stesso principio di toJsonCo1()). Lo schema reale richiede solo
     * $schema+intestazione: nessuno dei due blocchi tipologia e' required,
     * per questo qui si aggiunge la chiave solo se il valore non e' null,
     * invece di valorizzarla sempre.
     */
    public function toJsonCo2($dataPrimaPubblicazione, $dataUltimaModifica, array $dirig = null, array $nonDirig = null)
    {
        $data = [
            '$schema' => self::SCHEMA_URL,
            'intestazione' => [
                'amministrazione' => \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione(),
                'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
                'dataUltimaModifica' => $dataUltimaModifica,
            ],
        ];

        if ($dirig !== null) {
            $data['trattamentoAccessorioPersonaleDirigenziale'] = $this->buildTrattamentoAccessorio($dirig);
        }
        if ($nonDirig !== null) {
            $data['trattamentoAccessorioPersonaleNonDirigenziale'] = $this->buildTrattamentoAccessorio($nonDirig);
        }

        return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }
}
