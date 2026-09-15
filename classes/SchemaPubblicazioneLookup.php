<?php

/**
 * Binding pagina <-> schema di pubblicazione ANAC, tramite l'attributo
 * `schema_pubblicazione` (ezselection, multi-valore) su `pagina_trasparenza`
 * (installer/modules/trasparenza/classes/pagina_trasparenza.yml), valorizzato
 * da `trasparenza-c1` (patch_content) per ogni pagina reale.
 *
 * Sostituisce i remote_id hardcoded che il cron ANAC usava prima (decisione
 * con Marco il 2026-09-15): un solo binding vero, letto sia dal cron sia dai
 * template - non piu' due copie della stessa mappa da tenere allineate.
 *
 * Non usato per gli schemi ancorati a un oggetto `dataset` (art.4-bis,
 * art.31-oc): la classe `dataset` non ha `schema_pubblicazione` (l'attributo
 * esiste solo su `pagina_trasparenza`), e il remote_id del dataset stesso
 * (es. `dati_sui_pagamenti`, `corte_dei_conti`) e' gia' un identificativo
 * deliberato e leggibile, non un hash opaco - non e' il problema che questa
 * classe risolve. Vedi openpa_bootstrapitalia/classes/anac/CLAUDE.md.
 */
class SchemaPubblicazioneLookup
{
    /**
     * Deve restare sincronizzato con le opzioni dell'ezselection in
     * installer/modules/trasparenza/classes/pagina_trasparenza.yml
     * (schema_pubblicazione.data_text5) - stessi id, stessi nomi.
     */
    const OPTION_IDS = [
        'art.4-bis' => 1,
        'art.13-as' => 2,
        'art.13-op' => 3,
        'art.13-oa' => 4,
        'art.13-org' => 5,
        'art.31-oiv' => 6,
        'art.31-or' => 7,
        'art.31-oc' => 8,
        'art.13-pa' => 9,
        'art.13-se' => 10,
        'art.31' => 11,
    ];

    /**
     * Un solo scan della classe `pagina_trasparenza` per tutti gli schemi
     * insieme, non uno scan per schema - il cron risolve tutti i nodi che
     * gli servono con una sola chiamata a inizio funzione.
     *
     * @return \eZContentObject[] schemaIdentifier => oggetto pagina_trasparenza che lo espone
     */
    public static function fetchAllBindings()
    {
        $idToName = array_flip(self::OPTION_IDS);
        $bindings = [];

        $class = \eZContentClass::fetchByIdentifier('pagina_trasparenza');
        if (!$class instanceof \eZContentClass) {
            return $bindings;
        }

        foreach (\eZContentObject::fetchSameClassList($class->attribute('id'), true) as $object) {
            $dataMap = $object->dataMap();
            if (!isset($dataMap['schema_pubblicazione'])) {
                continue;
            }

            foreach ($dataMap['schema_pubblicazione']->content() as $selectedId) {
                if (isset($idToName[(int)$selectedId])) {
                    $bindings[$idToName[(int)$selectedId]] = $object;
                }
            }
        }

        return $bindings;
    }

    /**
     * @return string[] identificatori schema (es. ['art.13-op', 'art.13-pa']) associati a questo oggetto, vuoto se nessuno
     */
    public static function schemasForObject(\eZContentObject $object)
    {
        $dataMap = $object->dataMap();
        if (!isset($dataMap['schema_pubblicazione'])) {
            return [];
        }

        $idToName = array_flip(self::OPTION_IDS);
        $result = [];
        foreach ($dataMap['schema_pubblicazione']->content() as $selectedId) {
            if (isset($idToName[(int)$selectedId])) {
                $result[] = $idToName[(int)$selectedId];
            }
        }

        return $result;
    }
}
