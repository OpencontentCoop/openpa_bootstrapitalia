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
        $previousTracking = $this->getTracking();

        if ($previousTracking !== null && $previousTracking['dataHash'] === $dataHash) {
            return $this->backfillUrlsIfMissing($previousTracking);
        }

        $today = date('d/m/Y');

        // Una pubblicazione avviene al massimo una volta al giorno: se oggi
        // abbiamo gia' pubblicato (dataUltimaModifica == oggi), un ulteriore
        // cambiamento nello stesso giorno non genera una nuova pubblicazione -
        // "{schema}-latest.ext" e' solo un riferimento all'ultimo file datato
        // pubblicato (cosi' come richiesto dalla issue), non un mirror in tempo
        // reale indipendente da esso. Il nuovo dato verra' colto dalla prossima
        // esecuzione del cron, il giorno dopo.
        if ($previousTracking !== null && $previousTracking['dataUltimaModifica'] === $today) {
            return $this->backfillUrlsIfMissing($previousTracking);
        }

        $dataPrimaPubblicazione = $previousTracking !== null ? $previousTracking['dataPrimaPubblicazione'] : $today;
        $dataUltimaModifica = $today;

        $files = $filesBuilder($dataPrimaPubblicazione, $dataUltimaModifica);

        $firstPublishedDate = \DateTime::createFromFormat('d/m/Y', $dataPrimaPubblicazione)->format('Ymd');
        $lastModifiedDate = \DateTime::createFromFormat('d/m/Y', $dataUltimaModifica)->format('Ymd');

        /**
         * Storico delle pubblicazioni passate (#479, discoverability: "non
         * basta conservare le versioni se sono raggiungibili solo indovinando
         * le date nell'url" - serve un elenco). La versione che sto per
         * sostituire (se esiste) va in `history` prima di essere sovrascritta
         * - vedi getVersions().
         *
         * Gli url di ogni versione (corrente e storiche) sono risolti e
         * salvati QUI, al momento della scrittura - non ricalcolati a
         * lettura. Motivo: la lettura (dai template, per mostrare "versioni
         * precedenti") puo' avvenire da un nodo diverso da quello con cui
         * questo schema e' stato pubblicato (es. la pagina di trasparenza
         * "Corte dei conti" dichiara di esporre art.31-oc, ma il file e'
         * fisicamente ancorato al nodo del DATASET, non a quello della
         * pagina - vedi classes/anac/CLAUDE.md). Se calcolassimo l'url a
         * lettura usando il nodo corrente, per questi schemi otterremmo un
         * url sbagliato. Salvando l'url gia' risolto (con il $rootNodeId
         * CORRETTO, quello del chiamante di publish()), un lettore non deve
         * mai piu' sapere quale nodo ancora quello schema - solo il suo
         * identificativo.
         */
        $history = $previousTracking !== null && isset($previousTracking['history']) ? $previousTracking['history'] : [];
        if ($previousTracking !== null) {
            $historyEntry = ['dataUltimaModifica' => $previousTracking['dataUltimaModifica']];
            foreach (['Csv', 'Json'] as $suffix) {
                if (isset($previousTracking['url' . $suffix])) {
                    $historyEntry['url' . $suffix] = $previousTracking['url' . $suffix];
                }
            }
            $history[] = $historyEntry;
        }

        $tracking = [
            'dataHash' => $dataHash,
            'dataPrimaPubblicazione' => $dataPrimaPubblicazione,
            'dataUltimaModifica' => $dataUltimaModifica,
            'history' => $history,
        ];
        foreach ($files as $extension => $content) {
            $written = $this->writeVersionedFile($content, $extension, $firstPublishedDate, $lastModifiedDate);
            $tracking['path' . ucfirst($extension)] = $written['path'];
            $tracking['url' . ucfirst($extension)] = $written['url'];
            $tracking['urlLatest' . ucfirst($extension)] = $written['urlLatest'];
        }
        $this->setTracking($tracking);

        return $tracking;
    }

    /**
     * Migrazione (2026-09-15, #479): i tracking scritti da questo schema
     * prima che venissero introdotti gli url pre-risolti (vedi commento in
     * resolveAndPublish()) non li hanno - e non li avrebbero mai, perche' il
     * confronto hash impedisce di raggiungere il codice che li scrive finche'
     * il dato non cambia davvero (potenzialmente mai, per uno schema stabile).
     * Qui, ogni volta che il cron gira e trova un tracking esistente SENZA
     * l'url dell'alias -latest per un formato che pero' ha gia' un pathCsv/
     * pathJson (= e' stato scritto), lo calcola e lo salva - senza toccare
     * date/hash/history, non e' una nuova pubblicazione.
     */
    private function backfillUrlsIfMissing(array $tracking)
    {
        $changed = false;
        foreach (['csv', 'json'] as $extension) {
            $pathKey = 'path' . ucfirst($extension);
            $urlLatestKey = 'urlLatest' . ucfirst($extension);
            if (!isset($tracking[$pathKey]) || isset($tracking[$urlLatestKey])) {
                continue;
            }

            $tracking[$urlLatestKey] = $this->getPublicUrl("{$this->schemaIdentifier}-latest.{$extension}");

            $firstYmd = \DateTime::createFromFormat('d/m/Y', $tracking['dataPrimaPubblicazione'])->format('Ymd');
            $lastYmd = \DateTime::createFromFormat('d/m/Y', $tracking['dataUltimaModifica'])->format('Ymd');
            $tracking['url' . ucfirst($extension)] = $this->getPublicUrl("{$this->schemaIdentifier}-{$firstYmd}-{$lastYmd}.{$extension}");

            $changed = true;
        }

        if ($changed) {
            $this->setTracking($tracking);
        }

        return $tracking;
    }

    /**
     * Elenco di tutte le pubblicazioni passate, dalla piu' recente alla piu'
     * vecchia (#479, discoverability). Legge solo dal tracking gia' salvato -
     * non serve conoscere il nodo che ha pubblicato questo schema (vedi nota
     * in resolveAndPublish()), quindi funziona anche costruendo
     * `new ExportPublisher($schemaIdentifier)` senza $rootNodeId, da un
     * template su un nodo qualunque.
     *
     * @return array [] se non pubblicato mai, altrimenti lista di
     *         ['dataUltimaModifica' => 'gg/mm/aaaa', 'isLatest' => bool, 'urls' => ['csv' => '...', 'json' => '...']]
     */
    public function getVersions()
    {
        $tracking = $this->getTracking();
        if ($tracking === null) {
            return [];
        }

        $versions = [$this->extractVersion($tracking, true)];
        foreach (($tracking['history'] ?? []) as $historyEntry) {
            $version = $this->extractVersion($historyEntry, false);
            if (empty($version['urls'])) {
                // versione storica antecedente all'introduzione degli url
                // pre-risolti (migrazione 2026-09-15): nessun modo di
                // ricostruirne l'url a posteriori (il nodo che l'ha
                // pubblicata potrebbe non essere piu' quello corrente), non
                // mostrabile - il file resta comunque sul cluster storage,
                // solo non piu' elencato qui.
                continue;
            }
            $versions[] = $version;
        }

        usort($versions, function ($a, $b) {
            return \DateTime::createFromFormat('d/m/Y', $b['dataUltimaModifica']) <=> \DateTime::createFromFormat('d/m/Y', $a['dataUltimaModifica']);
        });

        return $versions;
    }

    private function extractVersion(array $entry, $isLatest)
    {
        $urls = [];
        foreach (['csv', 'json'] as $extension) {
            if (isset($entry['url' . ucfirst($extension)])) {
                $urls[$extension] = $entry['url' . ucfirst($extension)];
            }
        }

        return [
            'dataUltimaModifica' => $entry['dataUltimaModifica'],
            'isLatest' => $isLatest,
            'urls' => $urls,
        ];
    }

    /**
     * @return array ['csv' => '...', 'json' => '...'] url pubblici dell'alias -latest per ogni formato pubblicato, [] se mai pubblicato
     */
    public function getLatestUrls()
    {
        $tracking = $this->getTracking();
        if ($tracking === null) {
            return [];
        }

        $urls = [];
        foreach (['csv', 'json'] as $extension) {
            if (isset($tracking['urlLatest' . ucfirst($extension)])) {
                $urls[$extension] = $tracking['urlLatest' . ucfirst($extension)];
            }
        }

        return $urls;
    }

    /**
     * Scrive datato e "-latest" insieme, stesso contenuto: "-latest" e' solo
     * un riferimento all'ultimo file datato pubblicato (vedi guardia "una
     * pubblicazione al massimo al giorno" in publish()), non un mirror
     * indipendente - altrimenti potrebbero divergere se il dato cambiasse piu'
     * volte nello stesso giorno.
     *
     * @return array ['path' => cluster storage path del file datato, 'url' => url pubblico del file datato, 'urlLatest' => url pubblico dell'alias -latest]
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

        return [
            'path' => "{$this->baseDir}/{$datedName}",
            'url' => $this->getPublicUrl($datedName),
            'urlLatest' => $this->getPublicUrl($latestName),
        ];
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
        $publicPath = $this->getPublicPath($filename);
        if ($publicPath === null) {
            return;
        }

        $action = 'module:anac_export/file/' . $this->schemaIdentifier . '/' . $filename;

        \eZURLAliasML::storePath($publicPath, $action, false, false, true, false, false, false, true, true);
    }

    /**
     * @return string|null path pubblico (senza slash iniziale, senza host) per un nome file gia' scritto da questo schema, null se $rootNodeId non risolve
     */
    private function getPublicPath($filename)
    {
        if ($this->rootNodeId === null) {
            return null;
        }

        $rootNode = \eZContentObjectTreeNode::fetch($this->rootNodeId);
        if (!$rootNode instanceof \eZContentObjectTreeNode) {
            return null;
        }

        $albeturaPath = trim($rootNode->attribute('url_alias'), '/');

        return $albeturaPath . '/' . $filename;
    }

    /**
     * @return string|null url assoluta (con host, https) per un nome file gia' scritto da questo schema, null se $rootNodeId non risolve
     */
    public function getPublicUrl($filename)
    {
        $publicPath = $this->getPublicPath($filename);
        if ($publicPath === null) {
            return null;
        }

        $siteUrl = trim(\eZINI::instance()->variable('SiteSettings', 'SiteURL'), '/');

        return 'https://' . $siteUrl . '/' . $publicPath;
    }
}
