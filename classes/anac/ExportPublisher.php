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

    /**
     * @var int|null Nodo radice dell'alberatura (es. Amministrazione Trasparente)
     * sotto cui pubblicare l'url alias pubblico. Se null, publish() scrive
     * solo su cluster storage senza creare un url pubblico (retro-compatibile).
     */
    private $rootNodeId;

    public function __construct($schemaIdentifier, $rootNodeId = null)
    {
        $this->schemaIdentifier = $schemaIdentifier;
        $this->rootNodeId = $rootNodeId;
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
     * @param string $csv contenuto CSV gia' serializzato: rappresenta per intero
     *        il dato (stesse righe/campi del JSON), e NON contiene le date di
     *        pubblicazione - per questo il confronto "e' cambiato qualcosa?" si
     *        fa sul suo hash, non su quello del JSON (vedi CLAUDE.md, sezione
     *        "Perche' il JSON si costruisce con una callback").
     * @param callable $jsonBuilder function(string $dataPrimaPubblicazione, string $dataUltimaModifica): string
     *        costruisce il JSON finale SOLO dopo che le date sono state risolte
     *        confrontando con la pubblicazione precedente. Non puo' essere una
     *        stringa gia' pronta: il chiamante non puo' sapere in anticipo se
     *        dataUltimaModifica deve restare quella di ieri (dato invariato) o
     *        diventare oggi (dato cambiato) - lo decide questo metodo.
     * @return array tracking aggiornato (invariato se il dato non e' cambiato)
     */
    public function publish($csv, callable $jsonBuilder)
    {
        return $this->resolveAndPublish($csv, function ($first, $last) use ($csv, $jsonBuilder) {
            return ['csv' => $csv, 'json' => $jsonBuilder($first, $last)];
        });
    }

    /**
     * Per schemi con un solo formato pubblicato (es. art.13-as/art.13-op,
     * solo CSV; art.13-pa, solo JSON "file unico") - a differenza di
     * publish(), qui il contenuto non dipende dalle date risolte, quindi non
     * serve una callback: il contenuto e' gia' completo cosi' com'e'.
     *
     * @param string $content
     * @param string $extension 'csv' o 'json'
     * @return array tracking aggiornato (invariato se il dato non e' cambiato)
     */
    public function publishSingle($content, $extension)
    {
        return $this->resolveAndPublish($content, function () use ($content, $extension) {
            return [$extension => $content];
        });
    }

    /**
     * Per un file singolo il cui contenuto dipende dalle date risolte (es.
     * un JSON con un blocco "intestazione" che le incorpora, ma senza un CSV
     * gemello su cui calcolare l'hash come fa publish()). Il chiamante deve
     * fornire separatamente un hash della sola parte-dato, senza date, altrimenti
     * si ricade nello stesso problema (vedi "Perche' il JSON si costruisce
     * con una callback" in publish()/CLAUDE.md).
     *
     * @param string $dataHashSource rappresentazione del solo dato, senza date
     * @param callable $contentBuilder function(string $dataPrimaPubblicazione, string $dataUltimaModifica): string
     * @param string $extension 'csv' o 'json'
     */
    public function publishWithDates($dataHashSource, callable $contentBuilder, $extension)
    {
        return $this->resolveAndPublish($dataHashSource, function ($first, $last) use ($contentBuilder, $extension) {
            return [$extension => $contentBuilder($first, $last)];
        });
    }

    /**
     * Nucleo comune a publish()/publishSingle()/publishWithDates(): confronta l'hash, risolve le
     * date (al massimo una pubblicazione al giorno, vedi commento sotto),
     * poi chiede a $filesBuilder(dataPrimaPubblicazione, dataUltimaModifica)
     * la mappa estensione => contenuto da scrivere.
     */
    private function resolveAndPublish($dataForHash, callable $filesBuilder)
    {
        $dataHash = md5($dataForHash);
        $tracking = $this->getTracking();

        if ($tracking !== null && $tracking['dataHash'] === $dataHash) {
            return $tracking;
        }

        $today = date('d/m/Y');

        // Una pubblicazione avviene al massimo una volta al giorno: se oggi
        // abbiamo gia' pubblicato (dataUltimaModifica == oggi), un ulteriore
        // cambiamento nello stesso giorno non genera una nuova pubblicazione -
        // "{schema}-latest.ext" e' solo un riferimento all'ultimo file datato
        // pubblicato (cosi' come richiesto dalla issue), non un mirror in tempo
        // reale indipendente da esso. Il nuovo dato verra' colto dalla prossima
        // esecuzione del cron, il giorno dopo.
        if ($tracking !== null && $tracking['dataUltimaModifica'] === $today) {
            return $tracking;
        }

        $dataPrimaPubblicazione = $tracking !== null ? $tracking['dataPrimaPubblicazione'] : $today;
        $dataUltimaModifica = $today;

        $files = $filesBuilder($dataPrimaPubblicazione, $dataUltimaModifica);

        $firstPublishedDate = \DateTime::createFromFormat('d/m/Y', $dataPrimaPubblicazione)->format('Ymd');
        $lastModifiedDate = \DateTime::createFromFormat('d/m/Y', $dataUltimaModifica)->format('Ymd');

        $tracking = [
            'dataHash' => $dataHash,
            'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
            'dataUltimaModifica' => $dataUltimaModifica,
        ];
        foreach ($files as $extension => $content) {
            $tracking['path' . ucfirst($extension)] = $this->writeVersionedFile($content, $extension, $firstPublishedDate, $lastModifiedDate);
        }
        $this->setTracking($tracking);

        return $tracking;
    }

    /**
     * Scrive datato e "-latest" insieme, stesso contenuto: "-latest" e' solo
     * un riferimento all'ultimo file datato pubblicato (vedi guardia "una
     * pubblicazione al massimo al giorno" in publish()), non un mirror
     * indipendente - altrimenti potrebbero divergere se il dato cambiasse piu'
     * volte nello stesso giorno.
     */
    private function writeVersionedFile($content, $extension, $firstPublishedDate, $lastModifiedDate)
    {
        $mimeType = $extension === 'json' ? 'application/json' : 'text/csv';
        $datedName = "{$this->schemaIdentifier}-{$firstPublishedDate}-{$lastModifiedDate}.{$extension}";
        $latestName = "{$this->schemaIdentifier}-latest.{$extension}";

        foreach ([$datedName, $latestName] as $name) {
            $fileHandler = \eZClusterFileHandler::instance("{$this->baseDir}/{$name}");
            $fileHandler->storeContents($content, 'anac-export', $mimeType);
            $this->publishUrlAlias($name);
        }

        return "{$this->baseDir}/{$datedName}";
    }

    /**
     * Espone il file appena scritto su cluster storage con un url pubblico nel
     * formato richiesto da ANAC (#479): <path-alberatura>/<nomefile>, servito
     * dal modulo anac_export (vedi modules/anac_export/file.php).
     *
     * cleanupElements=false (7o parametro) e' cruciale: eZURLAliasML converte
     * altrimenti i punti nel nome file in trattini (vedi convertToAlias, usato
     * di default da storePath), rompendo l'estensione e il prefisso "art."
     * richiesti dal pattern ANAC.
     */
    private function publishUrlAlias($filename)
    {
        if ($this->rootNodeId === null) {
            return;
        }

        $rootNode = \eZContentObjectTreeNode::fetch($this->rootNodeId);
        if (!$rootNode instanceof \eZContentObjectTreeNode) {
            return;
        }

        $albeturaPath = trim($rootNode->attribute('url_alias'), '/');
        $publicPath = $albeturaPath . '/' . $filename;
        $action = 'module:anac_export/file/' . $this->schemaIdentifier . '/' . $filename;

        \eZURLAliasML::storePath($publicPath, $action, false, false, true, false, false, false, true, true);
    }
}
