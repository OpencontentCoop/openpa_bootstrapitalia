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
     *         strutturaResponsabile, anno, pubblicazioneInizio,
     *         pubblicazioneFine, url} - MAI provvedimento/allegati (confermato:
     *         "in tabella non li visualizziamo", solo nell'export).
     */
    private function flattenRows(array $rows)
    {
        $flattened = [];
        foreach ($rows as $row) {
            $object = $row['object'];
            $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);

            $data = null;
            $anno = null;
            foreach (['act_date', 'data_di_firma', 'publication_start_time'] as $field) {
                if (!isset($dataMap[$field])) {
                    continue;
                }
                $timestamp = (int)$dataMap[$field]->toString();
                if ($timestamp > 0) {
                    $data = date('d/m/Y', $timestamp);
                    $anno = date('Y', $timestamp);
                    break;
                }
            }

            $numero = null;
            foreach (['act_number', 'has_code'] as $field) {
                if (!isset($dataMap[$field])) {
                    continue;
                }
                $value = trim((string)$dataMap[$field]->content());
                if ($value !== '') {
                    $numero = $value;
                    break;
                }
            }

            $pubblicazioneInizio = isset($dataMap['publication_start_time']) ? (int)$dataMap['publication_start_time']->toString() : 0;
            $pubblicazioneFine = isset($dataMap['publication_end_time']) ? (int)$dataMap['publication_end_time']->toString() : 0;

            $strutturaResponsabile = '';
            if (isset($dataMap['has_organization']) && $dataMap['has_organization']->hasContent()) {
                $names = [];
                foreach ((array)($dataMap['has_organization']->content()['relation_list'] ?? []) as $item) {
                    $relatedObject = \eZContentObject::fetch((int)$item['contentobject_id']);
                    if ($relatedObject instanceof \eZContentObject) {
                        $names[] = trim($relatedObject->attribute('name'));
                    }
                }
                $strutturaResponsabile = implode(', ', $names);
            }

            $flattened[] = [
                'denominazione' => $row['denominazione'],
                'data' => $data,
                'numero' => $numero,
                'oggetto' => trim($object->attribute('name')),
                'strutturaResponsabile' => $strutturaResponsabile,
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
