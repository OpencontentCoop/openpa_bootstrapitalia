<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Espone a template/view i documenti OIV/Organi di revisione di
 * Art31Serializer (classe `document`, filtrati per tag `document_type`)
 * senza passare dal formato CSV/JSON - stesso principio di
 * PageArticolazioneUfficiProvider/PageRiferimentiContattiProvider.
 *
 * Come quelle due classi, il fetch non dipende dalla pagina che lo
 * richiede: Art31Serializer::fetchDocumentsByKeys() interroga sempre tutto
 * il sito (subtree RootNode, stesso principio di
 * Art13Serializer::fetchRiferimentiContatti() per art.13-rif) - un
 * documento con quel tag va trovato ovunque sia pubblicato, non solo sotto
 * la pagina che lo esporta.
 *
 * Registrata in LiveRenderingRegistry sotto gli schemi art.31-oiv/art.31-or.
 */
class PageArt31DocumentiProvider
{
    private $serializer;

    public function __construct(Serializer\Art31Serializer $serializer = null)
    {
        $this->serializer = $serializer ?: new Serializer\Art31Serializer();
    }

    public function getOivRowsJson()
    {
        return $this->rowsJson(Serializer\Art31Serializer::OIV_KEYS);
    }

    public function getOrganiDiRevisioneRowsJson()
    {
        return $this->rowsJson(Serializer\Art31Serializer::OR_KEYS);
    }

    private function rowsJson(array $keys)
    {
        $documentsByKey = $this->serializer->fetchDocumentsByKeys($keys);

        return $this->toSafeJson($this->flattenRows($keys, $documentsByKey));
    }

    /**
     * @return array righe {tipo, data, documento, url} - tutti i documenti
     *         trovati per ciascuna chiave (non solo il piu' recente: stesso
     *         comportamento di Art31Serializer::toCsvDocumenti(), a
     *         differenza del JSON ANAC che tiene solo il piu' recente per
     *         chiave). Un documento senza file allegato o senza data di
     *         pubblicazione viene omesso, stesso criterio del CSV (la
     *         validita' resta legata al file allegato, anche se il link
     *         mostrato in tabella punta altrove - vedi sotto). `url` e' la
     *         pagina del documento (content object), non il file allegato:
     *         nella tabella live il titolo deve portare alla scheda del
     *         documento sul sito, non al download diretto - l'export
     *         CSV/JSON invece continua a usare il file diretto
     *         (Art31Serializer::fetchDocumentUrl(), richiesto dallo schema
     *         ANAC), nessun impatto su di esso.
     */
    private function flattenRows(array $keys, array $documentsByKey)
    {
        $rows = [];
        foreach ($keys as $key) {
            foreach ($documentsByKey[$key] as $object) {
                $fileUrl = $this->serializer->fetchDocumentUrl($object);
                $date = $this->serializer->fetchPublicationDate($object);
                if ($fileUrl === null || $date === null) {
                    continue;
                }
                $tipo = $this->translateTipo($key, $object);

                $rows[] = [
                    'tipo' => $tipo,
                    'data' => $date,
                    'documento' => trim($object->attribute('name')),
                    'url' => $this->resolveDocumentPageUrl($object),
                ];
            }
        }

        return $rows;
    }

    /**
     * `Art31Serializer::TIPO_DOCUMENTO_CSV` resta in italiano fino a qui: e'
     * la stringa TIPO_DOCUMENTO letterale richiesta dalla tabella ANAC
     * (issue #477) per il CSV/JSON, non traducibile li' senza rompere
     * l'export - stesso principio di
     * PageArticolazioneUfficiProvider::translateTipologia() per `tipologia`.
     * Qui invece il valore finisce solo nella tabella HTML mostrata al
     * visitatore, quindi si traduce esclusivamente qui. Per
     * KEY_ALTRI_ATTI_ORGANISMO (nessuna voce in TIPO_DOCUMENTO_CSV, per
     * design: issue #477 non prevede una stringa fissa) resta il titolo del
     * documento, non traducibile da noi.
     */
    private function translateTipo($key, \eZContentObject $object)
    {
        $sources = [
            Serializer\Art31Serializer::KEY_VALIDAZIONE_PERFORMANCE =>
                'Performance report validation document',
            Serializer\Art31Serializer::KEY_RELAZIONE_SISTEMA_VALUTAZIONE =>
                'Report on the overall functioning of the evaluation, transparency and internal control integrity system',
            Serializer\Art31Serializer::KEY_RELAZIONE_BILANCIO_PREVISIONE =>
                'Administrative and accounting report on the budget estimate or budget and related amendments',
            Serializer\Art31Serializer::KEY_RELAZIONE_CONTO_CONSUNTIVO =>
                'Administrative and accounting report on the financial statement or annual accounts',
        ];

        if (!isset($sources[$key])) {
            return trim($object->attribute('name'));
        }

        return \ezpI18n::tr('bootstrapitalia/anac_export', $sources[$key]);
    }

    /**
     * @return string|null url della pagina del documento (content object),
     *         non del file allegato - stesso principio di
     *         Art13Serializer::resolveUfficioUrl() per il link sulla
     *         denominazione dell'ufficio nella tabella Articolazione uffici.
     */
    private function resolveDocumentPageUrl(\eZContentObject $object)
    {
        $node = $object->attribute('main_node');
        if (!$node instanceof \eZContentObjectTreeNode) {
            return null;
        }

        return '/' . $node->attribute('url_alias');
    }

    /**
     * Stesso motivo/meccanismo di PageArticolazioneUfficiProvider::toSafeJson()
     * (JSON incorporato in un blocco <script>, non in output HTML con
     * escaping automatico del template engine).
     */
    private function toSafeJson(array $rows)
    {
        return json_encode(
            $rows,
            JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_UNICODE
        );
    }
}
