<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

/**
 * art.36 - IBAN e pagamenti informatici (cms#488), schema ad adesione
 * volontaria, valido per C1 e C2. Stesso pattern di Art12Serializer: dataset
 * content object, nessun attributo nuovo sul content model.
 *
 * Perimetro: solo "Pubbliche Amministrazioni" (C1, ambito soggettivo fisso,
 * schema "utilizzo esclusivo PagoPA") e "Società in controllo pubblico"/
 * "Enti di diritto privato" (C2, configurabile per ente - vedi
 * Art36AmbitoSoggettivoC2 -, schema "utilizzo NON esclusivo PagoPA"). Ordini
 * professionali, enti pubblici economici, soggetti non tenuti a PagoPA,
 * art.2-bis co.3 sono esplicitamente fuori perimetro (cms#488) - i restanti
 * ambiti soggettivi previsti dallo schema ANAC (8 in totale) non sono
 * implementati da questa classe.
 *
 * Due dataset DISTINTI a monte (Task 3, vocabolario diverso per profilo):
 * questa classe non valida "quali valori arrivano dal dataset giusto", si
 * fida del vocabolario già ristretto a monte - valida solo le combinazioni
 * (vedi buildModalitaDiPagamento()).
 */
class Art36Serializer
{
    const SCHEMA_IDENTIFIER_AS = 'art.36-as';
    const SCHEMA_IDENTIFIER = 'art.36';
    const SCHEMA_URL = 'https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.36-v1.0.schema.json';

    const MODALITA_AMMESSE_C1 = [
        'PagoPA', 'Conto corrente', 'Delega unica F24', 'Sepa Direct Debit (SDD)', 'Per cassa', 'Altro servizio',
    ];
    const MODALITA_AMMESSE_C2 = [
        'PagoPA', 'Delega unica F24', 'Sepa Direct Debit (SDD)', 'Per cassa', 'Altro servizio',
    ];

    /** @var \eZContentObjectAttribute */
    private $pagamentiAttribute;

    /** @var bool */
    private $isC1;

    public function __construct(\eZContentObjectAttribute $pagamentiAttribute, $isC1)
    {
        $this->pagamentiAttribute = $pagamentiAttribute;
        $this->isC1 = $isC1;
    }

    public function fetchRigheGrezze()
    {
        $repository = new \OpendataDatasetSearchableRepository($this->pagamentiAttribute);
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

    public function mapPagamento(array $data)
    {
        $modalita = $this->normalizeModalita($data['modalita_pagamento']);
        $linkPagoPa = trim((string)$data['link_pagopa']);

        if ($modalita === 'PagoPA' && $linkPagoPa === '') {
            throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
                "Campo 'link_pagopa' obbligatorio quando 'modalita_pagamento' = PagoPA (vocabolario ANAC schema art.36)"
            );
        }
        if ($modalita !== 'PagoPA' && $linkPagoPa !== '') {
            throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
                "Campo 'link_pagopa' valorizzato ma 'modalita_pagamento' non e' PagoPA (vocabolario ANAC schema art.36)"
            );
        }

        return [
            'modalitaPagamento' => $modalita,
            'informazioniPagamento' => trim((string)$data['informazioni_pagamento']),
            'linkPagoPa' => $linkPagoPa,
        ];
    }

    private function normalizeModalita($raw)
    {
        $ammessi = $this->isC1 ? self::MODALITA_AMMESSE_C1 : self::MODALITA_AMMESSE_C2;
        $normalized = mb_strtolower(trim((string)$raw), 'UTF-8');

        foreach ($ammessi as $valoreCanonico) {
            if ($normalized === mb_strtolower($valoreCanonico, 'UTF-8')) {
                return $valoreCanonico;
            }
        }

        $ambito = $this->isC1 ? 'Pubbliche Amministrazioni (C1)' : 'Società in controllo pubblico/Enti di diritto privato (C2)';
        throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
            "Valore '{$raw}' non ammesso per il campo 'modalita_pagamento' per l'ambito soggettivo {$ambito} (vocabolario ANAC schema art.36)"
        );
    }

    public function toCsvAs()
    {
        $valore = $this->isC1
            ? 'Pubbliche Amministrazioni'
            : \OpenPAINI::variable('Trasparenza', 'Art36AmbitoSoggettivoC2', 'SocietaInControlloPubblico');

        $lines = [
            \OpenPABootstrapItalia\Anac\CsvLineBuilder::line(['AMBITO_SOGGETTIVO']),
            \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([$valore]),
        ];

        return implode("\n", $lines) . "\n";
    }

    public function toCsv()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line(['MOD_PAGAMENTO', 'INFO_PAGAMENTO', 'URL_PAGO_PA'])];

        foreach ($this->fetchRigheGrezze() as $raw) {
            $item = $this->mapPagamento($raw);
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
                $item['modalitaPagamento'], $item['informazioniPagamento'], $item['linkPagoPa'],
            ]);
        }

        return implode("\n", $lines) . "\n";
    }

    /**
     * @return array|null null se non c'e' nessuna riga nel dataset - in tal
     *         caso il chiamante (publishArt36(), Task 6) deve omettere del
     *         tutto la pubblicazione del JSON quella volta (non costruire un
     *         "oggetto vuoto": a differenza di Art12Serializer, QUI lo
     *         schema non ammette nessuno stato vuoto valido - vedi toJson()).
     *         Un array non-null ma con una combinazione non valida (es. C2
     *         senza nessuna riga PagoPA) non torna qui: l'errore emerge solo
     *         quando si prova a costruire il JSON, in toJson().
     */
    public function getPagamenti()
    {
        $pagamenti = array_map([$this, 'mapPagamento'], $this->fetchRigheGrezze());

        return empty($pagamenti) ? null : $pagamenti;
    }

    /**
     * Costruisce il blocco "modalitaDiPagamento" raggruppando le righe per
     * categoria - NON un elenco piatto (vedi docblock di classe). Valida le
     * combinazioni vietate dallo schema reale (oneOf per C1, required per
     * C2) - su dati gia' individualmente validi (mapPagamento() e' gia'
     * passato per ogni riga tramite getPagamenti()).
     */
    private function buildModalitaDiPagamento(array $pagamenti)
    {
        $pagoPaRows = array_values(array_filter($pagamenti, function ($p) {
            return $p['modalitaPagamento'] === 'PagoPA';
        }));
        $contoCorrenteRows = array_values(array_filter($pagamenti, function ($p) {
            return $p['modalitaPagamento'] === 'Conto corrente';
        }));
        $altriRows = array_values(array_filter($pagamenti, function ($p) {
            return !in_array($p['modalitaPagamento'], ['PagoPA', 'Conto corrente'], true);
        }));

        if (count($pagoPaRows) > 1) {
            throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
                "Più di una riga 'PagoPA' configurata: ammessa una sola riga (schema ANAC art.36)"
            );
        }
        if (count($contoCorrenteRows) > 1) {
            throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
                "Più di una riga 'Conto corrente' configurata: ammessa una sola riga (schema ANAC art.36)"
            );
        }

        $modalitaDiPagamento = [];

        if ($this->isC1) {
            // oneOf: esattamente una tra PagoPA e Conto corrente, mai
            // entrambe, mai nessuna (art.36-v1.0.schema.json,
            // SchemaUtilizzoEsclusivoPagoPA).
            if (count($pagoPaRows) === 1 && count($contoCorrenteRows) === 1) {
                throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
                    "'PagoPA' e 'Conto corrente' non possono essere configurati insieme: sono alternativi per questo ambito soggettivo (schema ANAC art.36)"
                );
            }
            if (count($pagoPaRows) === 0 && count($contoCorrenteRows) === 0) {
                throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
                    "Serve almeno una riga 'PagoPA' o 'Conto corrente': obbligatorio uno dei due per questo ambito soggettivo (schema ANAC art.36)"
                );
            }
            $modalitaDiPagamento = count($pagoPaRows) === 1
                ? ['pagoPA' => $this->buildPagoPA($pagoPaRows[0])]
                : ['contoCorrenteBancario' => $this->buildContoCorrenteBancario($contoCorrenteRows[0])];
        } else {
            // required: ["pagoPA"] (art.36-v1.0.schema.json,
            // SchemaUtilizzoNonEsclusivoPagoPA) - "Conto corrente" non
            // dovrebbe mai arrivare qui (il dataset C2 non lo offre, Task 3),
            // ma validato comunque in profondita' (es. CSV bulk futuro).
            if (count($contoCorrenteRows) > 0) {
                throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
                    "'Conto corrente' non ammesso per questo ambito soggettivo (schema ANAC art.36, Società in controllo pubblico/Enti di diritto privato)"
                );
            }
            if (count($pagoPaRows) === 0) {
                throw new \OpenPABootstrapItalia\Anac\InvalidVocabolarioException(
                    "Serve almeno una riga 'PagoPA': obbligatoria per questo ambito soggettivo (schema ANAC art.36, Società in controllo pubblico/Enti di diritto privato)"
                );
            }
            $modalitaDiPagamento['pagoPA'] = $this->buildPagoPA($pagoPaRows[0]);
        }

        if (!empty($altriRows)) {
            $modalitaDiPagamento['altriMetodi'] = array_map([$this, 'buildMetodoAlternativo'], $altriRows);
        }

        return $modalitaDiPagamento;
    }

    private function buildPagoPA(array $pagamento)
    {
        return [
            'adesionePagoPA' => $pagamento['informazioniPagamento'],
            'sezioneWebPagoPA' => $pagamento['linkPagoPa'],
        ];
    }

    private function buildContoCorrenteBancario(array $pagamento)
    {
        return ['iban' => $pagamento['informazioniPagamento']];
    }

    /**
     * "Altro servizio" si mappa su AltroServizio.denominazione (testo
     * libero); gli altri tre valori ammessi (Delega unica F24/SDD/Per cassa)
     * sono gia' le stringhe esatte di MetodiAlternativiEnum.
     */
    private function buildMetodoAlternativo(array $pagamento)
    {
        if ($pagamento['modalitaPagamento'] === 'Altro servizio') {
            return ['altroServizio' => ['denominazione' => $pagamento['informazioniPagamento']]];
        }

        return ['denominazione' => $pagamento['modalitaPagamento']];
    }

    private function schemaKey()
    {
        if ($this->isC1) {
            return 'schemaPubblicheAmministrazioni';
        }

        $ambito = \OpenPAINI::variable('Trasparenza', 'Art36AmbitoSoggettivoC2', 'SocietaInControlloPubblico');

        return $ambito === 'EntiDiDirittoPrivato' ? 'schemaEntiDirittoPrivato' : 'schemaSocietaInControlloPubblico';
    }

    /**
     * $pagamenti deve essere il valore (non-null) di getPagamenti() - il
     * chiamante (publishArt36(), Task 6) non deve invocare questo metodo se
     * getPagamenti() e' null (dataset vuoto): a differenza di
     * Art12Serializer::toJsonPa1Bis(), QUI non esiste nessuno stato "vuoto"
     * valido da rappresentare (vedi buildModalitaDiPagamento(), che rifiuta
     * sia "nessuna riga PagoPA/Conto corrente" per C1 sia "nessuna riga
     * PagoPA" per C2).
     */
    public function toJson($dataPrimaPubblicazione, $dataUltimaModifica, array $pagamenti)
    {
        $data = [
            '$schema' => self::SCHEMA_URL,
            'intestazione' => [
                'amministrazione' => \OpenPABootstrapItalia\Anac\IntestazioneProvider::getAmministrazione(),
                'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
                'dataUltimaModifica' => $dataUltimaModifica,
            ],
            $this->schemaKey() => [
                'modalitaDiPagamento' => $this->buildModalitaDiPagamento($pagamenti),
            ],
        ];

        return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }
}
