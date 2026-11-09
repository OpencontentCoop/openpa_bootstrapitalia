<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

/**
 * art.12 co.1-bis - Scadenzario obblighi amministrativi (cms#485), schema ad
 * adesione volontaria. Dataset content object (classe dataset, csv_resource),
 * stesso pattern di Art4BisSerializer/Art31Serializer (sezione Corte dei
 * conti) - nessun attributo nuovo sul content model, solo righe del dataset.
 *
 * Solo profilo C1: il co.1-bis non si applica al profilo Società trasparente
 * (nessuna pagina equivalente in trasparenza-c2) - vedi cms#485.
 */
class Art12Serializer
{
    const SCHEMA_IDENTIFIER_CSV = 'art.12-scadenz';
    const SCHEMA_IDENTIFIER_JSON = 'art.12-pa-1bis';
    const SCHEMA_URL = 'https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.12-v1.0.schema.json';

    const DESTINATARIO_AMMESSI = ['Cittadino', 'Impresa', 'Entrambi'];

    /** @var \eZContentObjectAttribute */
    private $scadenzarioAttribute;

    public function __construct(\eZContentObjectAttribute $scadenzarioAttribute)
    {
        $this->scadenzarioAttribute = $scadenzarioAttribute;
    }

    public function fetchRigheGrezze()
    {
        $repository = new \OpendataDatasetSearchableRepository($this->scadenzarioAttribute);
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

    public function mapRiga(array $data)
    {
        $link = trim((string)$data['link']);
        if (!preg_match('/^https?:\/\//', $link)) {
            throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
                "Valore '{$link}' non valido per il campo 'link': deve essere un URL completo con http:// o https:// (schema ANAC art.12, definizione commons 'Url', verificato su commons-v1.0.schema.json)"
            );
        }

        return [
            'destinatario' => $this->normalizeDestinatario($data['destinatario']),
            'dataEfficacia' => $this->normalizeData($data['data_efficacia']),
            'denominazione' => trim($data['denominazione']),
            'descrizione' => trim((string)$data['descrizione']),
            'riferimento' => trim((string)$data['riferimento']),
            'link' => $link,
        ];
    }

    /**
     * Stesso formato dataset di Art31Serializer::normalizeData() (campo
     * "date", accetta sia stringa DD/MM/YYYY sia timestamp numerico).
     */
    private function normalizeData($raw)
    {
        if (is_numeric($raw) && (int)$raw > 0) {
            return date('d/m/Y', (int)$raw);
        }

        return trim((string)$raw);
    }

    private function normalizeDestinatario($raw)
    {
        $normalized = mb_strtolower(trim((string)$raw), 'UTF-8');

        foreach (self::DESTINATARIO_AMMESSI as $valoreCanonico) {
            if ($normalized === mb_strtolower($valoreCanonico, 'UTF-8')) {
                return $valoreCanonico;
            }
        }

        throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
            "Valore '{$raw}' non ammesso per il campo 'destinatario' (vocabolario ANAC schema art.12, scadenzario obblighi amministrativi)"
        );
    }

    /**
     * Converte gg/mm/aaaa in un timestamp per l'ordinamento - le righe del
     * dataset arrivano in ordine di inserimento, non per data: il CSV deve
     * uscire ordinato per data di efficacia crescente (requisito esplicito
     * cms#485, non presente in nessun serializer esistente).
     */
    private function dataEfficaciaTimestamp(array $riga)
    {
        $parts = explode('/', $riga['dataEfficacia']);
        if (count($parts) !== 3) {
            return 0;
        }

        return mktime(0, 0, 0, (int)$parts[1], (int)$parts[0], (int)$parts[2]);
    }

    private function fetchRigheOrdinate()
    {
        $righe = array_map([$this, 'mapRiga'], $this->fetchRigheGrezze());

        usort($righe, function ($a, $b) {
            return $this->dataEfficaciaTimestamp($a) <=> $this->dataEfficaciaTimestamp($b);
        });

        return $righe;
    }

    public function toCsvScadenz()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
            'DESTINATARIO', 'DATA_EFFICACIA', 'DENOMINAZIONE', 'DESCRIZIONE', 'RIFERIMENTO', 'LINK',
        ])];

        foreach ($this->fetchRigheOrdinate() as $riga) {
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
                $riga['destinatario'], $riga['dataEfficacia'], $riga['denominazione'],
                $riga['descrizione'], $riga['riferimento'], $riga['link'],
            ]);
        }

        return implode("\n", $lines) . "\n";
    }

    /**
     * @return array|null null se non ci sono righe — a differenza di altri
     *         serializer (es. Art31Serializer), QUI non significa "ometti il
     *         blocco JSON": lo schema reale (art.12-v1.0.schema.json,
     *         definizione SchemaPubblicheAmministrazioni, prima alternativa
     *         del suo oneOf interno) ammette un oggetto vuoto senza campi
     *         required - vedi toJsonPa1Bis(), che pubblica sempre un JSON
     *         valido, con `attiPubblicheAmministrazioni: {}` quando null.
     */
    public function getScadenzario()
    {
        $righe = array_map(function ($riga) {
            return [
                'destinatario' => $riga['destinatario'],
                'dataEfficacia' => $riga['dataEfficacia'],
                'denominazione' => $riga['denominazione'],
                'descrizione' => $riga['descrizione'],
                'riferimento' => $riga['riferimento'],
                'link' => $riga['link'],
            ];
        }, $this->fetchRigheOrdinate());

        return empty($righe) ? null : $righe;
    }

    /**
     * $scadenzario null (dataset senza righe) produce
     * `"attiPubblicheAmministrazioni": {}` - un oggetto vuoto, non un array
     * vuoto: `new \stdClass()` e' necessario, un array PHP vuoto verrebbe
     * serializzato come `[]` da json_encode(), non valido contro lo schema
     * (che si aspetta un "object", vedi SchemaPubblicheAmministrazioni).
     */
    public function toJsonPa1Bis($dataPrimaPubblicazione, $dataUltimaModifica, array $scadenzario = null)
    {
        $data = [
            '$schema' => self::SCHEMA_URL,
            'intestazione' => [
                'amministrazione' => \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione(),
                'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
                'dataUltimaModifica' => $dataUltimaModifica,
            ],
            'attiPubblicheAmministrazioni' => $scadenzario !== null
                ? ['scadenzario' => $scadenzario]
                : new \stdClass(),
        ];

        return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }
}
