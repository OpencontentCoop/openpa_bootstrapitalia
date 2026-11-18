<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Traccia, per singolo schema ANAC, l'ultimo errore di export incontrato dal
 * cron (cronjobs/anac_export.php) - stesso meccanismo di tracking di
 * ExportPublisher (eZSiteData, una riga per schema), ma un namespace di nomi
 * separato ("anac_export_error_<schema>" invece di "anac_export_<schema>"):
 * sono due concetti distinti (stato dell'ultima pubblicazione riuscita vs.
 * stato dell'ultimo tentativo fallito) che possono convivere per lo stesso
 * schema (un export pubblicato con successo ieri, oggi fallisce - il vecchio
 * file "-latest" resta valido, ma l'errore odierno va comunque segnalato).
 *
 * Letto da content_trasparenza.php::getAnacExports() per mostrare un banner
 * ai soli utenti loggati (vedi classes/anac/CLAUDE.md, "Gestione errori" -
 * "nessuna notifica attiva" era il gap che questa classe colma).
 */
class ExportErrorTracker
{
    private $schemaIdentifier;

    public function __construct($schemaIdentifier)
    {
        $this->schemaIdentifier = $schemaIdentifier;
    }

    /**
     * Registra l'errore corrente, sovrascrivendo un eventuale errore
     * precedente per lo stesso schema (non si accumulano, interessa solo
     * l'ultimo tentativo).
     *
     * $relatedObject e' l'oggetto della pagina di trasparenza che espone
     * questo schema (quando noto al chiamante): una scrittura su eZSiteData
     * non passa dal ciclo di pubblicazione di un content object, quindi non
     * invalida da sola la cache della pagina che legge questo errore
     * (content_trasparenza.php::getAnacExports()) - senza invalidarla
     * esplicitamente qui, il banner puo' restare non visibile (o un banner
     * vecchio restare visibile dopo clear()) finche' la cache non scade o
     * viene svuotata per un motivo non correlato. Stesso principio gia' in
     * uso da LiveRenderingRegistry::clearAllCaches().
     */
    public function recordError($message, \eZContentObject $relatedObject = null)
    {
        $value = json_encode([
            'message' => $message,
            'date' => (new \DateTime())->format('d/m/Y'),
        ]);

        $siteData = \eZSiteData::fetchByName($this->getSiteDataName());
        if ($siteData instanceof \eZSiteData) {
            $siteData->setAttribute('value', $value);
        } else {
            $siteData = \eZSiteData::create($this->getSiteDataName(), $value);
        }
        $siteData->store();

        if ($relatedObject instanceof \eZContentObject) {
            \eZContentCacheManager::clearContentCacheIfNeeded($relatedObject->attribute('id'));
        }
    }

    /**
     * Rimuove l'errore tracciato per questo schema, se presente - chiamato
     * dal cron subito dopo una pubblicazione riuscita, cosi' un banner non
     * resta visibile dopo che il dato e' stato corretto. Vedi recordError()
     * per il perche' di $relatedObject.
     */
    public function clear(\eZContentObject $relatedObject = null)
    {
        $siteData = \eZSiteData::fetchByName($this->getSiteDataName());
        if ($siteData instanceof \eZSiteData) {
            $siteData->remove();

            if ($relatedObject instanceof \eZContentObject) {
                \eZContentCacheManager::clearContentCacheIfNeeded($relatedObject->attribute('id'));
            }
        }
    }

    /**
     * @return array|null ['message' => string, 'date' => 'gg/mm/aaaa'] o null se nessun errore tracciato per questo schema
     */
    public function getError()
    {
        $siteData = \eZSiteData::fetchByName($this->getSiteDataName());
        if (!$siteData instanceof \eZSiteData) {
            return null;
        }

        return json_decode($siteData->attribute('value'), true);
    }

    private function getSiteDataName()
    {
        return 'anac_export_error_' . $this->schemaIdentifier;
    }
}
