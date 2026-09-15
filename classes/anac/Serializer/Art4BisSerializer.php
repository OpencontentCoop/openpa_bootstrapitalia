<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

class Art4BisSerializer
{
    const SCHEMA_IDENTIFIER = 'art.4-bis';

    /**
     * Vocabolario controllato dallo schema JSON ufficiale scaricabile
     * (guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.4-bis-v1.0.schema.json,
     * verificato il 2026-09-15 scaricando il file, non un riassunto della
     * pagina guida). "categoria" e' un "const" nello schema: minuscolo,
     * esattamente "uscite correnti"/"uscite in conto capitale" - un
     * tentativo precedente li aveva capitalizzati basandosi su un riassunto
     * automatico impreciso della pagina guida, sbagliando: l'esempio
     * originale nella issue (minuscolo) era quello corretto.
     */
    const CATEGORIA_USCITE_CORRENTI = 'uscite correnti';
    const CATEGORIA_USCITE_CONTO_CAPITALE = 'uscite in conto capitale';

    const TIPOLOGIE_PER_CATEGORIA = [
        self::CATEGORIA_USCITE_CORRENTI => [
            'Acquisto di beni e di servizi',
            'Contributi in conto esercizio',
            'Interessi passivi',
            'Altre spese per attività finanziarie',
            'Altre spese correnti',
        ],
        self::CATEGORIA_USCITE_CONTO_CAPITALE => [
            'Investimenti in beni materiali',
            'Investimenti in beni immateriali',
            'Investimenti in attività finanziarie',
            'Contributi in conto capitale',
            'Altre spese in conto capitale',
        ],
    ];

    const BENEFICIARI_AMMESSI = [
        'Persona fisica',
        'Altro soggetto pubblico e privato',
        'Soggetto estero',
    ];

    /** @var \eZContentObjectAttribute */
    private $attribute;

    private $amministrazione;

    /**
     * @param \eZContentObjectAttribute $attribute attributo csv_resource del dataset "Dati sui pagamenti"
     * @param array|null $amministrazione override di ['codiceFiscale' => ..., 'denominazione' => ...],
     *        default: risolto da IntestazioneProvider (usato nei test)
     */
    public function __construct(\eZContentObjectAttribute $attribute, array $amministrazione = null)
    {
        $this->attribute = $attribute;
        $this->amministrazione = $amministrazione ?: \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione();
    }

    public function getCsvHeaders()
    {
        return ['ANNO', 'TRIMESTRE', 'CATEGORIA_DI_SPESA', 'TIPOLOGIA_DI_SPESA', 'IMPORTO', 'BENEFICIARIO'];
    }

    /**
     * Le date NON sono uno stato dell'oggetto: arrivano da ExportPublisher::publish(),
     * che le risolve confrontando il dato con l'ultima pubblicazione (vedi
     * ExportPublisher::publish() e CLAUDE.md). Passarle a toJson() invece che al
     * costruttore evita di doverle conoscere prima ancora di sapere se il dato e'
     * davvero cambiato.
     */
    public function getIntestazione($dataPrimaPubblicazione, $dataUltimaModifica)
    {
        return [
            'amministrazione' => $this->amministrazione,
            'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
            'dataUltimaModifica' => $dataUltimaModifica,
        ];
    }

    /**
     * @return array righe grezze del dataset, una per pagamento, chiavi = identifier di campo
     */
    public function fetchRows()
    {
        $repository = new \OpendataDatasetSearchableRepository($this->attribute);
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

    public function mapItem(array $data)
    {
        $categoria = $this->normalizeCategoria($data['categoria_di_spesa']);

        return [
            'anno' => (int)$data['anno'],
            'trimestre' => (int)$data['trimestre'],
            'categoria' => $categoria,
            'tipologia' => $this->normalizeTipologia($data['tipologia_di_spesa'], $categoria),
            'importo' => $this->normalizeImporto($data['importo']),
            'beneficiario' => $this->normalizeBeneficiario($data['beneficiario']),
        ];
    }

    /**
     * Il campo e' testo libero lato redattore: nel dataset reale (Bugliano) contiene
     * ancora il simbolo di valuta ("€ 1.464,00"), che lo schema ANAC non ammette.
     * Normalizza sempre al formato ANAC n.nnn,dd (punto delle migliaia, virgola
     * decimale), qualunque sia la convenzione usata dal redattore in ingresso
     * (1550.33, 1550,33, 1.550,33, 1,550.33 producono tutti "1.550,33").
     */
    public function normalizeImporto($raw)
    {
        $value = trim(str_replace(["\xe2\x82\xac", ' '], '', $raw));

        $hasComma = strpos($value, ',') !== false;
        $hasDot = strpos($value, '.') !== false;

        if ($hasComma && $hasDot) {
            if (strrpos($value, ',') > strrpos($value, '.')) {
                $value = str_replace('.', '', $value);
                $value = str_replace(',', '.', $value);
            } else {
                $value = str_replace(',', '', $value);
            }
        } elseif ($hasComma) {
            $value = str_replace(',', '.', $value);
        }

        return number_format((float)$value, 2, ',', '.');
    }

    public function normalizeCategoria($raw)
    {
        return $this->matchVocabolario($raw, [self::CATEGORIA_USCITE_CORRENTI, self::CATEGORIA_USCITE_CONTO_CAPITALE], 'categoria_di_spesa');
    }

    public function normalizeTipologia($raw, $categoriaCanonica)
    {
        $ammesse = isset(self::TIPOLOGIE_PER_CATEGORIA[$categoriaCanonica]) ? self::TIPOLOGIE_PER_CATEGORIA[$categoriaCanonica] : [];

        return $this->matchVocabolario($raw, $ammesse, 'tipologia_di_spesa');
    }

    public function normalizeBeneficiario($raw)
    {
        return $this->matchVocabolario($raw, self::BENEFICIARI_AMMESSI, 'beneficiario');
    }

    /**
     * Confronto case/spazi-insensitive contro il vocabolario ANAC: il redattore
     * scrive testo libero, ma l'export deve riportare esattamente le stringhe
     * canoniche. Se non c'e' corrispondenza, fallisce esplicitamente invece di
     * pubblicare un valore non conforme (stesso principio di
     * MissingCodiceFiscaleException).
     */
    private function matchVocabolario($raw, array $ammessi, $campo)
    {
        $normalized = trim(preg_replace('/\s+/', ' ', (string)$raw));
        foreach ($ammessi as $valoreCanonico) {
            if (mb_strtolower($normalized, 'UTF-8') === mb_strtolower($valoreCanonico, 'UTF-8')) {
                return $valoreCanonico;
            }
        }

        throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
            "Valore '{$raw}' non ammesso per il campo '{$campo}' (vocabolario ANAC schema art.4-bis)"
        );
    }

    public function mapToCsvRow(array $item)
    {
        return [
            $item['anno'],
            $item['trimestre'],
            $item['categoria'],
            $item['tipologia'],
            $item['importo'],
            $item['beneficiario'],
        ];
    }

    public function toCsv()
    {
        $lines = [implode(';', $this->getCsvHeaders())];

        foreach ($this->fetchRows() as $raw) {
            $lines[] = implode(';', $this->mapToCsvRow($this->mapItem($raw)));
        }

        return implode("\r\n", $lines) . "\r\n";
    }

    public function toJson($dataPrimaPubblicazione, $dataUltimaModifica)
    {
        $data = [
            'intestazione' => $this->getIntestazione($dataPrimaPubblicazione, $dataUltimaModifica),
            'datiSuiPagamenti' => array_map(
                function ($raw) {
                    $item = $this->mapItem($raw);

                    return [
                        'anno' => $item['anno'],
                        'trimestre' => $item['trimestre'],
                        'categoria' => $item['categoria'],
                        'tipologia' => $item['tipologia'],
                        'importo' => $item['importo'],
                        'beneficiario' => $item['beneficiario'],
                    ];
                },
                $this->fetchRows()
            ),
        ];

        return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }
}
