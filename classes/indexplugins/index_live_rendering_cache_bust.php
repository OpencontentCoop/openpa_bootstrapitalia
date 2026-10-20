<?php

/**
 * Invalida la cache HTTP delle pagine di trasparenza con rendering live
 * (vedi OpenPABootstrapItalia\Anac\LiveRenderingRegistry) quando viene
 * pubblicato uno degli oggetti che quelle pagine leggono a runtime
 * (organization, time_indexed_role, online_contact_point) - la pagina
 * aggrega dati di oggetti pubblicati altrove, quindi un publish "normale"
 * di quegli oggetti non tocca mai la cache della pagina stessa.
 *
 * Agganciato all'indicizzazione Solr (General[], non Class[]: organization e
 * time_indexed_role hanno gia' un plugin assegnato in quello slot, che e'
 * un singolo valore per classe, non un array - vedi ezsolr.php::addObject())
 * invece che a un workflow/trigger di pubblicazione: e' l'unico punto di
 * estensione di questo codebase che gira su OGNI pubblicazione, su tutti i
 * tenant, senza richiedere una modifica al content model/installer - che
 * servirebbe per attaccare un workflow a classi gia' installate su ~600
 * enti, e non si applicherebbe comunque ai tenant finche' non rieseguono
 * l'installer.
 *
 * eZContentCacheManager::clearContentCacheIfNeeded() e' la stessa funzione
 * kernel gia' usata da un publish normale (vedi actions/content_actionhandler.php)
 * e dal cron di export ANAC per lo stesso identico problema di pagina
 * aggregata (classes/anac/ExportPublisher::clearRootNodeCache()) - innesca
 * l'evento 'content/cache', lo stesso punto di aggancio che l'estensione
 * ocfoshttpcache usa per invalidare Varnish via xkey. Funziona quindi allo
 * stesso modo indipendentemente dall'ambiente (Boat/docker locale o SaaS):
 * non dipende da un meccanismo di cache specifico, e' l'estensione di cache
 * realmente attiva (quale che sia) a reagire a questo evento standard del
 * kernel, non il contrario.
 *
 * Non enumera quali pagine_trasparenza invalidare in base a quale oggetto
 * specifico e' stato pubblicato (richiederebbe risalire schema_pubblicazione
 * per ogni pubblicazione in modo mirato, costoso e fragile) - banna tutte le
 * pagine con un fornitore di rendering live registrato, ogni volta che una
 * delle classi rilevanti viene pubblicata. Il numero di pagina_trasparenza
 * per tenant e' tipicamente poche unita', quindi il costo resta contenuto.
 *
 * Rete di sicurezza: cronjobs/anac_export.php esegue la stessa invalidazione
 * in modo incondizionato 2 volte al giorno su tutti i tenant SaaS, quindi
 * un'eventuale mancata invocazione di questo plugin (indicizzazione asincrona
 * disabilitata, coda in ritardo, ecc.) limita comunque la finestra di dati
 * stantii a poche ore, non a tempo indeterminato.
 */
class ezfIndexLiveRenderingCacheBust implements ezfIndexPlugin
{
    const RELEVANT_CLASSES = ['organization', 'time_indexed_role', 'online_contact_point'];

    public function modify(eZContentObject $contentObject, &$docList)
    {
        if (!in_array($contentObject->attribute('class_identifier'), self::RELEVANT_CLASSES, true)) {
            return;
        }

        \OpenPABootstrapItalia\Anac\LiveRenderingRegistry::clearAllCaches();
    }
}
