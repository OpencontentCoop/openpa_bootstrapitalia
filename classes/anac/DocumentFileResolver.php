<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Risolve l'url pubblico del file allegato a un oggetto `document`, qualunque
 * sia il campo usato per caricarlo: `file` (ezbinaryfile, singolo, legacy) o
 * `attachments` (ocmultibinary, multipli, quello usato oggi dall'interfaccia
 * di caricamento) - un redattore puo' avere valorizzato l'uno, l'altro, o
 * entrambi (`resolveUrl()` preferisce `file` in quel caso, `resolveAllUrls()`
 * restituisce gli url di entrambi, `file` per primo - vedi i due metodi).
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

        if (isset($dataMap['file']) && $dataMap['file']->hasContent()) {
            return self::buildFileDownloadUrl($object, $dataMap['file']);
        }

        if (isset($dataMap['attachments']) && $dataMap['attachments']->hasContent()) {
            $attachmentsAttribute = $dataMap['attachments'];
            // reset() vuole una variabile, non il risultato diretto di una
            // funzione (PHP notice "Only variables should be passed by
            // reference" su ogni chiamata, PHP 7.4 - trovato dalla review
            // finale whole-branch). Condiviso da Art13Serializer/Art31Serializer.
            $validFiles = self::fetchValidBinaryFiles($attachmentsAttribute);
            $file = reset($validFiles);
            if ($file instanceof \eZMultiBinaryFile) {
                return self::buildMultiBinaryUrl($object, $attachmentsAttribute, $file);
            }
        }

        return null;
    }

    /**
     * @return string[] TUTTI gli url dei file allegati, nell'ordine di
     *         visualizzazione (stesso ordine di resolveUrl(), che ne prende
     *         solo il primo) - [] se il documento non ha nessun file. Se sia
     *         `file` sia `attachments` sono popolati (resolveUrl() in quel
     *         caso prende solo `file`), qui compaiono ENTRAMBI: prima l'url
     *         di `file`, poi tutti quelli di `attachments` - nessun early
     *         return su `file` da solo, a differenza di una prima versione
     *         di questo metodo che perdeva silenziosamente gli allegati in
     *         quello scenario. Usato da Art23Serializer: il primo e'
     *         'provvedimento', il resto sono 'allegati' - un unico oggetto
     *         document rappresenta un provvedimento con il proprio file
     *         principale piu' eventuali allegati aggiuntivi sullo stesso
     *         oggetto.
     */
    public static function resolveAllUrls(\eZContentObject $object)
    {
        $dataMap = $object->fetchDataMap(false, \SchemaPubblicazioneLookup::EXPORT_LANGUAGE);

        $urls = [];

        if (isset($dataMap['file']) && $dataMap['file']->hasContent()) {
            $urls[] = self::buildFileDownloadUrl($object, $dataMap['file']);
        }

        if (isset($dataMap['attachments']) && $dataMap['attachments']->hasContent()) {
            $attachmentsAttribute = $dataMap['attachments'];
            foreach (self::fetchValidBinaryFiles($attachmentsAttribute) as $file) {
                $urls[] = self::buildMultiBinaryUrl($object, $attachmentsAttribute, $file);
            }
        }

        return $urls;
    }

    /**
     * Solo l'host del SiteURL: letto dal siteaccess attivo, il cron gira
     * sotto il siteaccess backend, dove SiteURL include un path aggiuntivo
     * (es. "example.it/backend") - serve solo l'host, mai il path del
     * siteaccess che ha generato il link (stesso fix di ExportPublisher).
     *
     * @return string
     */
    private static function resolveSiteHost()
    {
        $rawSiteUrl = trim(\eZINI::instance()->variable('SiteSettings', 'SiteURL'), '/');

        return explode('/', $rawSiteUrl, 2)[0];
    }

    /**
     * @return string
     */
    private static function buildFileDownloadUrl(\eZContentObject $object, $fileAttribute)
    {
        return 'https://' . self::resolveSiteHost() . '/content/download/' . $object->attribute('id') . '/' . $fileAttribute->attribute('id');
    }

    /**
     * @return string
     */
    private static function buildMultiBinaryUrl(\eZContentObject $object, $attachmentsAttribute, \eZMultiBinaryFile $file)
    {
        return 'https://' . self::resolveSiteHost() . '/ocmultibinary/download/' . $object->attribute('id') . '/' . $attachmentsAttribute->attribute('id') . '/' . $attachmentsAttribute->attribute('version') . '/' . $file->attribute('filename') . '/file/' . rawurlencode($file->attribute('original_filename'));
    }

    /**
     * Tutti i file di `attachments`, nell'ordine di visualizzazione reale,
     * filtrati alle sole istanze valide (`eZMultiBinaryFile`) - stesso
     * elenco/ordine usato sia da resolveUrl() (che ne prende solo il primo,
     * via reset()) sia da resolveAllUrls() (che li usa tutti): un solo punto
     * che decide "cos'e' un file valido e in che ordine", cosi' i due metodi
     * non possono divergere silenziosamente sullo stesso documento.
     *
     * getBinaryFiles() e' protetto ma e' l'unica fonte di verita' per
     * l'ordine reale (usort su display_order, la decorazione scelta dal
     * redattore in fase di caricamento - fallback alfabetico per
     * original_filename solo se nessuna decorazione e' stata impostata).
     * Richiamato via reflection invece di duplicare la logica di
     * parseDecorations()/findMatchingDecorationKey() qui: un ordinamento
     * ricostruito a mano rischierebbe di divergere da quello mostrato
     * pubblicamente in pagina.
     *
     * @return \eZMultiBinaryFile[]
     */
    private static function fetchValidBinaryFiles($attachmentsAttribute)
    {
        $datatype = $attachmentsAttribute->dataType();
        $method = new \ReflectionMethod($datatype, 'getBinaryFiles');
        $method->setAccessible(true);
        $files = (array)$method->invoke($datatype, $attachmentsAttribute, $attachmentsAttribute->attribute('version'));

        return array_values(array_filter($files, function ($file) {
            return $file instanceof \eZMultiBinaryFile;
        }));
    }
}
