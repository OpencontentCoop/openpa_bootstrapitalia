<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Espone a template/view i provvedimenti di Art23Serializer (classe
 * `document`, filtrati per tag document_type) senza passare dal formato
 * CSV/JSON - stesso principio di PageArt31DocumentiProvider.
 *
 * Registrata in LiveRenderingRegistry sotto gli schemi art.23-org/
 * art.23-altra-tipologia.
 */
class PageProvvedimentiProvider
{
    private $serializer;

    public function __construct(Serializer\Art23Serializer $serializer = null)
    {
        $this->serializer = $serializer ?: new Serializer\Art23Serializer();
    }

    public function getOrganiRowsJson()
    {
        return $this->rowsJson($this->serializer->getOrgani());
    }

    public function getDirigentiRowsJson()
    {
        return $this->rowsJson($this->serializer->getDirigenti());
    }

    /**
     * @return array righe {denominazione, data, numero, oggetto,
     *         strutturaResponsabile, organizzazioni, anno,
     *         pubblicazioneInizio, pubblicazioneFine, url} - MAI
     *         provvedimento/allegati (confermato: "in tabella non li
     *         visualizziamo", solo nell'export).
     *
     * data/numero/strutturaResponsabile delegati a Art23Serializer (stessa
     * catena di fallback usata da CSV/JSON) invece di essere ricalcolati qui
     * - una copia duplicata era gia' divergente da quella del serializer
     * (numero null qui, stringa vuota li') prima di questo fix, trovato
     * dalla review finale whole-branch. anno/pubblicazioneInizio/
     * pubblicazioneFine/url restano qui: servono solo alla tabella live,
     * non a CSV/JSON. `organizzazioni` (id+nome, da
     * Art23Serializer::resolveOrganizzazioni()) idem - serve al filtro
     * "Unita' organizzativa" per id stabile (spec §2.1,
     * unitaOrganizzativaId): `strutturaResponsabile` resta la stringa
     * concatenata per la sola visualizzazione in tabella, non e' piu' usata
     * per il filtro (un documento con piu' organizzazioni collegate non
     * compariva filtrando per una sola di esse, solo per la combinazione
     * esatta visualizzata - trovato dalla review finale whole-branch).
     */
    private function flattenRows(array $rows)
    {
        $flattened = [];
        foreach ($rows as $row) {
            $object = $row['object'];
            $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);

            $dataNumero = $this->serializer->resolveDataNumero($object, $dataMap);

            // Stesso ordine di campi e stessa logica di resolveDataNumero()
            // (break al primo timestamp valido) - 'anno'/'dataTimestamp'
            // devono riferirsi alla STESSA fonte gia' risolta in 'data', non
            // a publication_start_time a prescindere (potrebbe non essere il
            // campo che ha vinto il fallback).
            $dataTimestamp = 0;
            $anno = null;
            foreach (['act_date', 'data_di_firma', 'publication_start_time'] as $field) {
                if (!isset($dataMap[$field])) {
                    continue;
                }
                $timestamp = (int)$dataMap[$field]->toString();
                if ($timestamp > 0) {
                    $dataTimestamp = $timestamp;
                    $anno = date('Y', $timestamp);
                    break;
                }
            }

            $pubblicazioneInizio = isset($dataMap['publication_start_time']) ? (int)$dataMap['publication_start_time']->toString() : 0;
            $pubblicazioneFine = isset($dataMap['publication_end_time']) ? (int)$dataMap['publication_end_time']->toString() : 0;

            $flattened[] = [
                'denominazione' => $row['denominazione'],
                'data' => $dataNumero['data'],
                'dataTimestamp' => $dataTimestamp,
                'numero' => $dataNumero['numero'],
                'oggetto' => trim($object->attribute('name')),
                'strutturaResponsabile' => $this->serializer->resolveStrutturaResponsabile($dataMap),
                'organizzazioni' => $this->serializer->resolveOrganizzazioni($dataMap),
                'anno' => $anno,
                'pubblicazioneInizio' => $pubblicazioneInizio,
                'pubblicazioneFine' => $pubblicazioneFine,
                'url' => $this->resolveDocumentPageUrl($object),
            ];
        }

        return $flattened;
    }

    private function resolveDocumentPageUrl(\eZContentObject $object)
    {
        $node = $object->attribute('main_node');
        if (!$node instanceof \eZContentObjectTreeNode) {
            return null;
        }

        return '/' . $node->attribute('url_alias');
    }

    private function rowsJson(array $rows)
    {
        return json_encode(
            $this->flattenRows($rows),
            JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_UNICODE
        );
    }
}
