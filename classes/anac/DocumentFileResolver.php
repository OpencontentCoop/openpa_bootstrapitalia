<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Risolve l'url pubblico del file allegato a un oggetto `document`, qualunque
 * sia il campo usato per caricarlo: `file` (ezbinaryfile, singolo, legacy) o
 * `attachments` (ocmultibinary, multipli, quello usato oggi dall'interfaccia
 * di caricamento) - un redattore puo' avere valorizzato l'uno, l'altro, o
 * entrambi. Si preferisce `file` quando presente (caso piu' semplice, un
 * solo url possibile), altrimenti il primo file di `attachments` nell'ordine
 * di visualizzazione scelto dal redattore in fase di caricamento.
 *
 * Condiviso tra i serializer ANAC che leggono documenti come fonte
 * dell'export (Art31Serializer per OIV/Organi di revisione, Art13Serializer
 * per l'organigramma).
 */
class DocumentFileResolver
{
    /**
     * @return string|null url assoluta https del file allegato, o null se il documento non ha un file
     */
    public static function resolveUrl(\eZContentObject $object)
    {
        $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);
        $siteUrl = trim(\eZINI::instance()->variable('SiteSettings', 'SiteURL'), '/');

        if (isset($dataMap['file']) && $dataMap['file']->hasContent()) {
            return 'https://' . $siteUrl . '/content/download/' . $object->attribute('id') . '/' . $dataMap['file']->attribute('id');
        }

        if (isset($dataMap['attachments']) && $dataMap['attachments']->hasContent()) {
            $attachmentsAttribute = $dataMap['attachments'];
            // getBinaryFiles() e' protetto ma e' l'unica fonte di verita' per
            // l'ordine reale (usort su display_order, la decorazione scelta
            // dal redattore in fase di caricamento - fallback alfabetico per
            // original_filename solo se nessuna decorazione e' stata
            // impostata). Richiamato via reflection invece di duplicare la
            // logica di parseDecorations()/findMatchingDecorationKey() qui:
            // un ordinamento ricostruito a mano rischierebbe di divergere da
            // quello mostrato pubblicamente in pagina.
            $datatype = $attachmentsAttribute->dataType();
            $method = new \ReflectionMethod($datatype, 'getBinaryFiles');
            $method->setAccessible(true);
            $files = (array)$method->invoke($datatype, $attachmentsAttribute, $attachmentsAttribute->attribute('version'));
            $file = reset($files);
            if ($file instanceof \eZMultiBinaryFile) {
                return 'https://' . $siteUrl . '/ocmultibinary/download/' . $object->attribute('id') . '/' . $attachmentsAttribute->attribute('id') . '/' . $attachmentsAttribute->attribute('version') . '/' . $file->attribute('filename') . '/file/' . rawurlencode($file->attribute('original_filename'));
            }
        }

        return null;
    }
}
