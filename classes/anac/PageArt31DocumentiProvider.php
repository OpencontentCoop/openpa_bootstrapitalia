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
     *         pubblicazione viene omesso, stesso criterio del CSV. `url` e'
     *         il link al file allegato (stesso usato dall'export), non alla
     *         pagina del documento.
     */
    private function flattenRows(array $keys, array $documentsByKey)
    {
        $rows = [];
        foreach ($keys as $key) {
            foreach ($documentsByKey[$key] as $object) {
                $url = $this->serializer->fetchDocumentUrl($object);
                $date = $this->serializer->fetchPublicationDate($object);
                if ($url === null || $date === null) {
                    continue;
                }
                $tipo = isset(Serializer\Art31Serializer::TIPO_DOCUMENTO_CSV[$key])
                    ? Serializer\Art31Serializer::TIPO_DOCUMENTO_CSV[$key]
                    : trim($object->attribute('name'));

                $rows[] = [
                    'tipo' => $tipo,
                    'data' => $date,
                    'documento' => trim($object->attribute('name')),
                    'url' => $url,
                ];
            }
        }

        return $rows;
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
