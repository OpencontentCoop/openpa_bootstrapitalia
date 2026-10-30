<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Espone a template/view i documenti OIV/Organi di revisione di
 * Art31Serializer (classe `document`, filtrati per tag `document_type`)
 * senza passare dal formato CSV/JSON - stesso principio di
 * PageArticolazioneUfficiProvider/PageRiferimentiContattiProvider.
 *
 * A differenza di quelle due classi, qui il fetch dipende dalla pagina
 * specifica che lo richiede: Art31Serializer::fetchDocumentsByKeys() accetta
 * una query opzionale gia' compilata dal campo `fields` della pagina (stesso
 * principio gia' in uso dal cron, vedi resolvePageTableQuery() in
 * cronjobs/anac_export.php), cosi' pagina mostrata e pagina esportata
 * condividono lo stesso subtree/filtro invece di due risoluzioni
 * indipendenti. Per questo i metodi qui accettano l'oggetto pagina - passato
 * da LiveRenderingRegistry::render(), che lo riceve a sua volta da
 * content_trasparenza.php (il chiamante conosce gia' su quale pagina si
 * trova).
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

    public function getOivRowsJson(\eZContentObject $pageObject = null)
    {
        return $this->rowsJson(Serializer\Art31Serializer::OIV_KEYS, $pageObject);
    }

    public function getOrganiDiRevisioneRowsJson(\eZContentObject $pageObject = null)
    {
        return $this->rowsJson(Serializer\Art31Serializer::OR_KEYS, $pageObject);
    }

    private function rowsJson(array $keys, \eZContentObject $pageObject = null)
    {
        $baseQuery = $pageObject !== null ? $this->resolvePageTableQuery($pageObject, 'document') : null;
        $documentsByKey = $this->serializer->fetchDocumentsByKeys($keys, $baseQuery);

        return $this->toSafeJson($this->flattenRows($keys, $documentsByKey));
    }

    /**
     * @return array righe {tipo, data, documento, url} - tutti i documenti
     *         trovati per ciascuna chiave (non solo il piu' recente: stesso
     *         comportamento di Art31Serializer::toCsvDocumenti(), a
     *         differenza del JSON ANAC che tiene solo il piu' recente per
     *         chiave). Un documento senza file allegato o senza data di
     *         pubblicazione viene omesso, stesso criterio del CSV.
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
     * Stesso meccanismo gia' usato da resolvePageTableQuery() in
     * cronjobs/anac_export.php (non riusabile direttamente: una funzione
     * globale in un file cron, non una classe autoloadabile) - duplicato
     * qui minimamente, stessa fonte di verita' sotto (parseTableFieldsParameter()).
     *
     * @return string|null null se la pagina non ha una tabella `fields`
     *         configurata per quella classe
     */
    private function resolvePageTableQuery(\eZContentObject $pageObject, $classIdentifier)
    {
        $dataMap = $pageObject->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        if (!isset($dataMap['fields']) || !$dataMap['fields']->attribute('has_content')) {
            return null;
        }

        $string = $dataMap['fields']->toString();
        foreach (explode('&', $string) as $tableString) {
            $table = \ObjectHandlerServiceContentTrasparenza::parseTableFieldsParameter($tableString, $pageObject->attribute('main_node'));
            if (is_array($table) && isset($table['class_identifier'], $table['query']) && $table['class_identifier'] === $classIdentifier) {
                return $table['query'];
            }
        }

        return null;
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
