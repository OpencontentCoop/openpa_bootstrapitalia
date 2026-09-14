<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

class Art4BisSerializer
{
    const SCHEMA_IDENTIFIER = 'art.4-bis';

    /** @var \eZContentObjectAttribute */
    private $attribute;

    private $amministrazione;

    private $dataPrimaPubblicazione;

    private $dataUltimaModifica;

    /**
     * @param \eZContentObjectAttribute $attribute attributo csv_resource del dataset "Dati sui pagamenti"
     * @param array|null $amministrazione override di ['codiceFiscale' => ..., 'denominazione' => ...],
     *        default: risolto da IntestazioneProvider (usato nei test)
     */
    public function __construct(
        \eZContentObjectAttribute $attribute,
        $dataPrimaPubblicazione,
        $dataUltimaModifica,
        array $amministrazione = null
    ) {
        $this->attribute = $attribute;
        $this->dataPrimaPubblicazione = $dataPrimaPubblicazione;
        $this->dataUltimaModifica = $dataUltimaModifica;
        $this->amministrazione = $amministrazione ?: \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione();
    }

    public function getCsvHeaders()
    {
        return ['ANNO', 'TRIMESTRE', 'CATEGORIA_DI_SPESA', 'TIPOLOGIA_DI_SPESA', 'IMPORTO', 'BENEFICIARIO'];
    }

    public function getIntestazione()
    {
        return [
            'amministrazione' => $this->amministrazione,
            'dataPrimaPubblicazione' => $this->dataPrimaPubblicazione,
            'dataUltimaModifica' => $this->dataUltimaModifica,
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
        return [
            'anno' => (int)$data['anno'],
            'trimestre' => (int)$data['trimestre'],
            'categoria' => $this->normalizeCategoria($data['categoria_di_spesa']),
            'tipologia' => trim($data['tipologia_di_spesa']),
            'importo' => $this->normalizeImporto($data['importo']),
            'beneficiario' => trim($data['beneficiario']),
        ];
    }

    /**
     * Il campo e' testo libero lato redattore: nel dataset reale (Bugliano) contiene
     * ancora il simbolo di valuta ("€ 1.464,00"), che lo schema ANAC non ammette.
     */
    public function normalizeImporto($raw)
    {
        $value = str_replace(["\xe2\x82\xac", ' '], '', $raw);

        return trim($value);
    }

    public function normalizeCategoria($raw)
    {
        return mb_strtolower(trim($raw), 'UTF-8');
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
        $lines = [implode("\t", $this->getCsvHeaders())];

        foreach ($this->fetchRows() as $raw) {
            $lines[] = implode("\t", $this->mapToCsvRow($this->mapItem($raw)));
        }

        return implode("\r\n", $lines) . "\r\n";
    }

    public function toJson()
    {
        $data = [
            'intestazione' => $this->getIntestazione(),
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
