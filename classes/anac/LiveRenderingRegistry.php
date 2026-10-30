<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Mappa schema ANAC -> fornitore di rendering live, per permettere a
 * QUALUNQUE pagina di trasparenza di mostrare dati live (invece del
 * meccanismo dichiarativo fields/datatable) quando dichiara uno schema qui
 * registrato - nessun nuovo interruttore sul content model: l'attivazione
 * dipende solo da schema_pubblicazione, gia' esistente (stesso principio di
 * SchemaPubblicazioneLookup, "un solo punto decide").
 *
 * Uno schema assente da questo registro significa semplicemente "nessun
 * fornitore di rendering live pronto per questo schema" - la pagina
 * continua a usare il meccanismo fields/datatable esistente, automaticamente,
 * senza bisogno di escluderlo esplicitamente da nessuna parte. Esempi di
 * schemi NON qui (e perche' non sono adattabili allo stesso modo): art.4-bis
 * e art.31-cc leggono da un oggetto `dataset` (righe inserite direttamente
 * in tabella, non un fetch Solr), non da una query sulla pagina.
 */
class LiveRenderingRegistry
{
    /**
     * schema ANAC => [classe fornitore, nome del metodo che restituisce il
     * JSON di righe gia' pronto per l'incorporamento sicuro in pagina].
     */
    const PROVIDERS = [
        'art.13-op' => [PageArticolazioneUfficiProvider::class, 'getOrganiPoliticiRowsJson'],
        'art.13-oa' => [PageArticolazioneUfficiProvider::class, 'getOrganiAmministrativiRowsJson'],
        'art.13-rif' => [PageRiferimentiContattiProvider::class, 'getRiferimentiContattiRowsJson'],
        'art.31-oiv' => [PageArt31DocumentiProvider::class, 'getOivRowsJson'],
        'art.31-or' => [PageArt31DocumentiProvider::class, 'getOrganiDiRevisioneRowsJson'],
    ];

    /**
     * schema ANAC => identifier della classe eZ che il suo rendering live
     * sostituisce nella tabella dichiarativa `fields` esistente - usato per
     * non mostrare due volte lo stesso dato (tabella dichiarativa E blocco
     * live una sotto l'altra) quando uno schema qui registrato e' attivo su
     * una pagina. Non e' detto che coincida 1:1 con PROVIDERS: potrebbe
     * esistere uno schema con fornitore live ma nessuna tabella dichiarativa
     * da sostituire (nessuna voce necessaria in quel caso).
     */
    const REPLACES_CLASS_IDENTIFIER = [
        'art.13-op' => 'organization',
        'art.13-oa' => 'organization',
        'art.13-rif' => 'online_contact_point',
        'art.31-oiv' => 'document',
        'art.31-or' => 'document',
    ];

    /**
     * Interruttore esplicito (openpa.ini, [Trasparenza] EnableAnacLiveRendering,
     * default disabled): finche' non e' enabled su un tenant, nessuna pagina
     * passa al rendering live, a prescindere da quali schemi dichiara - un
     * solo punto controlla il flag, non serve ripeterlo in ogni chiamante
     * (getLiveRenderingBlocks()/getLiveRenderingReplacedClasses() in
     * content_trasparenza.php passano gia' tutte da qui). Con il flag
     * disabled il comportamento e' lo stesso di "nessun provider registrato
     * per questo schema": la pagina resta sul meccanismo fields/datatable
     * esistente, automaticamente (vedi docblock di classe).
     */
    public static function hasProvider($schemaIdentifier)
    {
        if (\OpenPAINI::variable('Trasparenza', 'EnableAnacLiveRendering', 'disabled') !== 'enabled') {
            return false;
        }

        return isset(self::PROVIDERS[$schemaIdentifier]);
    }

    /**
     * @return string|null JSON di righe pronto per DataTables, o null se lo
     *         schema non ha un fornitore registrato
     */
    public static function render($schemaIdentifier)
    {
        if (!self::hasProvider($schemaIdentifier)) {
            return null;
        }

        [$providerClass, $method] = self::PROVIDERS[$schemaIdentifier];
        $provider = new $providerClass();

        return $provider->$method();
    }

    /**
     * Invalida la cache HTTP di ogni pagina_trasparenza che ha attivo un
     * fornitore di rendering live qui registrato - chiamato sia dal plugin
     * di indicizzazione Solr (classes/indexplugins/index_live_rendering_cache_bust.php,
     * sulla pubblicazione di organization/time_indexed_role/online_contact_point)
     * sia dal cron di export ANAC (cronjobs/anac_export.php, come rete di
     * sicurezza incondizionata) - un unico punto che decide quali pagine
     * invalidare e come, cosi' le due chiamate non possono disallinearsi.
     *
     * Non mira a sapere QUALE pagina specifica e' stata effettivamente
     * modificata (richiederebbe risalire schema_pubblicazione per ogni
     * pubblicazione in modo mirato, costoso e fragile) - invalida tutte le
     * pagine con un fornitore attivo. Il numero di pagina_trasparenza per
     * tenant e' tipicamente poche unita', quindi il costo resta contenuto.
     *
     * @param array|null $bindings risultato gia' calcolato di
     *        SchemaPubblicazioneLookup::fetchAllBindings(), per evitare una
     *        scansione duplicata quando il chiamante lo ha gia' - se omesso,
     *        viene calcolato qui.
     */
    public static function clearAllCaches(array $bindings = null)
    {
        $bindings = $bindings !== null ? $bindings : \SchemaPubblicazioneLookup::fetchAllBindings();

        foreach (array_keys(self::PROVIDERS) as $schema) {
            if (!isset($bindings[$schema])) {
                continue;
            }

            \eZContentCacheManager::clearContentCacheIfNeeded($bindings[$schema]->attribute('id'));
        }
    }
}
