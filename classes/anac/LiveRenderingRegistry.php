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
 * e art.31-oc leggono da un oggetto `dataset` (righe inserite direttamente
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
    ];

    public static function hasProvider($schemaIdentifier)
    {
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
     * Tag di cache condiviso per la pagina, usato sia nel template (Task 6,
     * `response_tag_list`) sia dal listener di invalidazione (Task 7) - un
     * unico punto che genera questa stringa, cosi' le due parti non possono
     * disallinearsi scrivendola a mano in due posti diversi. Generico (non
     * specifico di "articolazione uffici"): qualunque pagina futura che
     * attivi il rendering live tramite questo registro riusa lo stesso
     * schema di naming.
     */
    public static function getCacheTag(\eZContentObjectTreeNode $pageNode)
    {
        return 'trasparenza-live-rendering-' . $pageNode->attribute('node_id');
    }
}
