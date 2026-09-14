<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Meccanismo di esposizione comune per tutti gli schemi ANAC (#479):
 * naming datato + alias "-latest", file immutabili su storage cluster.
 *
 * Trigger: NON post_publish - un dataset (opendatadataset) puo' cambiare
 * senza mai passare da onPublish() (verificato in opendatadatasettype.php:
 * l'inserimento riga e' un INSERT diretto, non un publish di versione).
 * Il chiamante di publish() e' quindi un cron periodico che rigenera ogni
 * schema attivo; qui dentro si confronta l'hash e si scrive un nuovo file
 * SOLO se il contenuto e' cambiato dall'ultima esecuzione.
 *
 * Stato di tracking: eZSiteData (non una nuova tabella SQL - stesso pattern
 * gia' usato dall'installer per il version-tracking dei moduli), una riga
 * per schema con nome "anac_export_<schemaIdentifier>".
 */
class ExportPublisher
{
    private $schemaIdentifier;

    private $baseDir;

    public function __construct($schemaIdentifier)
    {
        $this->schemaIdentifier = $schemaIdentifier;
        $this->baseDir = \eZSys::cacheDirectory() . '/anac_export';
    }

    /**
     * @return array|null tracking corrente (hash, dataPrimaPubblicazione, dataUltimaModifica, pathCsv, pathJson) o null se mai pubblicato
     */
    public function getTracking()
    {
        $siteData = \eZSiteData::fetchByName($this->getSiteDataName());
        if (!$siteData instanceof \eZSiteData) {
            return null;
        }

        return json_decode($siteData->attribute('value'), true);
    }

    private function setTracking(array $tracking)
    {
        $siteData = \eZSiteData::fetchByName($this->getSiteDataName());
        if ($siteData instanceof \eZSiteData) {
            $siteData->setAttribute('value', json_encode($tracking));
        } else {
            $siteData = \eZSiteData::create($this->getSiteDataName(), json_encode($tracking));
        }
        $siteData->store();
    }

    private function getSiteDataName()
    {
        return 'anac_export_' . $this->schemaIdentifier;
    }

    /**
     * @param string $csv
     * @param string $json
     * @return array tracking aggiornato (invariato se il contenuto non e' cambiato)
     */
    public function publish($csv, $json)
    {
        $hash = md5($csv . "\0" . $json);
        $tracking = $this->getTracking();
        $today = date('Ymd');

        if ($tracking !== null && $tracking['hash'] === $hash) {
            return $tracking;
        }

        $dataPrimaPubblicazione = $tracking !== null ? $tracking['dataPrimaPubblicazione'] : date('d/m/Y');
        $firstPublishedDate = \DateTime::createFromFormat('d/m/Y', $dataPrimaPubblicazione)->format('Ymd');

        $pathCsv = $this->writeVersionedFile($csv, 'csv', $firstPublishedDate, $today);
        $pathJson = $this->writeVersionedFile($json, 'json', $firstPublishedDate, $today);

        $tracking = [
            'hash' => $hash,
            'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
            'dataUltimaModifica' => date('d/m/Y'),
            'pathCsv' => $pathCsv,
            'pathJson' => $pathJson,
        ];
        $this->setTracking($tracking);

        return $tracking;
    }

    private function writeVersionedFile($content, $extension, $firstPublishedDate, $today)
    {
        $datedFilename = "{$this->baseDir}/{$this->schemaIdentifier}-{$firstPublishedDate}-{$today}.{$extension}";
        $latestFilename = "{$this->baseDir}/{$this->schemaIdentifier}-latest.{$extension}";

        foreach ([$datedFilename, $latestFilename] as $filename) {
            $fileHandler = \eZClusterFileHandler::instance($filename);
            $fileHandler->storeContents($content, 'anac-export', $extension === 'json' ? 'application/json' : 'text/csv');
        }

        return $datedFilename;
    }
}
