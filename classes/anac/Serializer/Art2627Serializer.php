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
     * verificati sull'oggetto reale (buglianoqa, id 40403) il 2026-11-19,
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
