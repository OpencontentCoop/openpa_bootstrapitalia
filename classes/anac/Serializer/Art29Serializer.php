<?php

namespace OpenPABootstrapItalia\Anac\Serializer;

/**
 * art. 29 d.lgs. 33/2013 - Bilanci (cms#556), schema ad adesione volontaria,
 * profilo C1, per gli enti che NON trasmettono a BDAP. Due dataset content
 * object distinti (classe dataset, csv_resource, remote_id
 * bilancio_preventivo/bilancio_consuntivo) - stesso pattern di
 * Art2627Serializer, un solo serializzatore per entrambe le sotto-sezioni,
 * piu' il file costante art.29-as (ambito soggettivo, nessun dato da
 * dataset).
 *
 * Nessun JSON: la Guida Online ANAC non pubblica uno schema JSON per questo
 * articolo (verificato: art.29-v1.0.schema.json risponde 404), solo 3 CSV.
 *
 * I campi importo/percentuale dei due dataset sono gia' normalizzati al
 * formato ANAC dal framework Dataset stesso (OpendataDatasetNumberNormalizer,
 * occustomfind) al momento del salvataggio (form, API, import) - a
 * differenza di art.4-bis/art.26-27 (dove i campi importo sono ancora type
 * "string" e la normalizzazione avviene nel serializer via
 * ImportoNormalizer), qui NON serve richiamare nessun normalizzatore: il
 * dato arriva gia' pronto, un trim() basta.
 */
class Art29Serializer
{
    const SCHEMA_IDENTIFIER_AS = 'art.29-as';
    const SCHEMA_IDENTIFIER_PA_PREV = 'art.29-PA-prev';
    const SCHEMA_IDENTIFIER_PA_CONS = 'art.29-PA-cons';

    const AMBITO_SOGGETTIVO = 'Pubbliche amministrazioni in contabilità finanziaria';

    /** @var \eZContentObjectAttribute|null */
    private $preventivoAttribute;

    /** @var \eZContentObjectAttribute|null */
    private $consuntivoAttribute;

    /**
     * Entrambi gli argomenti sono nullable, stesso motivo di
     * Art2627Serializer: i due dataset sono installati come content
     * indipendenti, ciascuno puo' mancare su un sito senza impedire
     * all'altro di funzionare (e senza impedire la pubblicazione di
     * art.29-as, che non dipende da nessuno dei due).
     */
    public function __construct(
        \eZContentObjectAttribute $preventivoAttribute = null,
        \eZContentObjectAttribute $consuntivoAttribute = null
    ) {
        $this->preventivoAttribute = $preventivoAttribute;
        $this->consuntivoAttribute = $consuntivoAttribute;
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

    public function fetchRighePreventivo()
    {
        return $this->preventivoAttribute !== null ? $this->fetchRighe($this->preventivoAttribute) : [];
    }

    public function fetchRigheConsuntivo()
    {
        return $this->consuntivoAttribute !== null ? $this->fetchRighe($this->consuntivoAttribute) : [];
    }

    /**
     * Mapping riga->colonne per art.29-PA-prev, nell'ordine ESATTO del CSV
     * ANAC (issue cms#556). Field identifier verificati dal vivo su QA
     * (non derivati per analogia) - vedi il design doc, Appendice.
     *
     * @return string[] 21 colonne, stesso ordine dell'intestazione di toCsvPreventivo()
     */
    private function mapRigaPreventivo(array $data)
    {
        return [
            trim((string)$data['anno']),
            trim((string)$data['url_preventivo']),
            trim((string)$data['entrate_correnti']),
            trim((string)$data['uscite_correnti']),
            trim((string)$data['differenza_c_d']),
            trim((string)$data['entrate_totali']),
            trim((string)$data['uscite_totali']),
            trim((string)$data['differenza_f_g']),
            trim((string)$data['liq_crediti']),
            trim((string)$data['liq_debiti']),
            trim((string)$data['differenza_i_j']),
            trim((string)$data['cassa_crediti']),
            trim((string)$data['cassa_debiti']),
            trim((string)$data['differenza_l_m']),
            trim((string)$data['valore_produzione']),
            trim((string)$data['costi_produzione']),
            trim((string)$data['differenza_o_p']),
            trim((string)$data['comp_positivi_reddito']),
            trim((string)$data['comp_negativi_reddito']),
            trim((string)$data['differenza_r_s']),
            trim((string)$data['url_piano_indicatori']),
        ];
    }

    /**
     * Mapping riga->colonne per art.29-PA-cons. Attenzione alle 3
     * corrispondenze non deducibili dal nome (segnalate da Marco
     * sull'issue): `url_bilancio` -> colonna URL_BILANCIO (non
     * URL_CONSUNTIVO), `differenza_p_q` -> colonna "DIFFERENZA (P-Q)",
     * `patrimonio_netto_u_v` -> colonna "PATRIMONIO_NETTO (U-V)".
     *
     * @return string[] 27 colonne, stesso ordine dell'intestazione di toCsvConsuntivo()
     */
    private function mapRigaConsuntivo(array $data)
    {
        return [
            trim((string)$data['anno']),
            trim((string)$data['url_bilancio']),
            trim((string)$data['entrate_correnti']),
            trim((string)$data['uscite_correnti']),
            trim((string)$data['differenza_c_d']),
            trim((string)$data['entrate_totali']),
            trim((string)$data['uscite_totali']),
            trim((string)$data['differenza_f_g']),
            trim((string)$data['liq_crediti']),
            trim((string)$data['liq_debiti']),
            trim((string)$data['differenza_i_j']),
            trim((string)$data['cassa_crediti']),
            trim((string)$data['cassa_debiti']),
            trim((string)$data['differenza_l_m']),
            trim((string)$data['valore_produzione']),
            trim((string)$data['costi_produzione']),
            trim((string)$data['differenza_p_q']),
            trim((string)$data['comp_positivi_reddito']),
            trim((string)$data['comp_negativi_reddito']),
            trim((string)$data['differenza_r_s']),
            trim((string)$data['totale_attivo']),
            trim((string)$data['totale_passivo']),
            trim((string)$data['patrimonio_netto_u_v']),
            trim((string)$data['contributi_pubblici']),
            trim((string)$data['contributi_totali']),
            trim((string)$data['perc_contribuzione_pubblica']),
            trim((string)$data['url_piano_indicatori']),
        ];
    }

    /**
     * @return string sempre valorizzato con la costante di questo profilo
     *         (C1) - non dipende da nessun dataset, una sola riga di dato.
     */
    public function toCsvAs()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line(['AMBITO_SOGGETTIVO'])];
        $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line([self::AMBITO_SOGGETTIVO]);

        return implode("\n", $lines) . "\n";
    }

    public function toCsvPreventivo()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
            'ANNO', 'URL_PREVENTIVO', 'ENTRATE_CORRENTI', 'USCITE_CORRENTI', 'DIFFERENZA (C-D)',
            'ENTRATE_TOTALI', 'USCITE_TOTALI', 'DIFFERENZA (F-G)', 'LIQ_CREDITI', 'LIQ_DEBITI',
            'DIFFERENZA (I-J)', 'CASSA_CREDITI', 'CASSA_DEBITI', 'DIFFERENZA (L-M)',
            'VALORE_PRODUZIONE', 'COSTI_PRODUZIONE', 'DIFFERENZA (O-P)', 'COMP_POSITIVI_REDDITO',
            'COMP_NEGATIVI_REDDITO', 'DIFFERENZA (R-S)', 'URL_PIANO_INDICATORI',
        ])];

        foreach ($this->fetchRighePreventivo() as $data) {
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line($this->mapRigaPreventivo($data));
        }

        return implode("\n", $lines) . "\n";
    }

    public function toCsvConsuntivo()
    {
        $lines = [\OpenPABootstrapItalia\Anac\CsvLineBuilder::line([
            'ANNO', 'URL_BILANCIO', 'ENTRATE_CORRENTI', 'USCITE_CORRENTI', 'DIFFERENZA (C-D)',
            'ENTRATE_TOTALI', 'USCITE_TOTALI', 'DIFFERENZA (F-G)', 'LIQ_CREDITI', 'LIQ_DEBITI',
            'DIFFERENZA (I-J)', 'CASSA_CREDITI', 'CASSA_DEBITI', 'DIFFERENZA (L-M)',
            'VALORE_PRODUZIONE', 'COSTI_PRODUZIONE', 'DIFFERENZA (P-Q)', 'COMP_POSITIVI_REDDITO',
            'COMP_NEGATIVI_REDDITO', 'DIFFERENZA (R-S)', 'TOTALE_ATTIVO', 'TOTALE_PASSIVO',
            'PATRIMONIO_NETTO (U-V)', 'CONTRIBUTI_PUBBLICI', 'CONTRIBUTI_TOTALI',
            'PERC_CONTRIBUZIONE_PUBBLICA', 'URL_PIANO_INDICATORI',
        ])];

        foreach ($this->fetchRigheConsuntivo() as $data) {
            $lines[] = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line($this->mapRigaConsuntivo($data));
        }

        return implode("\n", $lines) . "\n";
    }
}
