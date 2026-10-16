<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Espone a template/view i metodi di raccolta dati di Art13Serializer senza
 * passare dal formato CSV/JSON - stessa fonte dell'export, presentazione
 * diversa (HTML/DataTables invece di file). Nessuna logica di business qui:
 * questa classe non decide COSA mostrare (quello resta in Art13Serializer),
 * solo come renderlo disponibile in una forma pronta per il rendering live
 * (righe appiattite, JSON gia' incorporabile in sicurezza in pagina).
 *
 * Registrata in LiveRenderingRegistry sotto gli schemi art.13-op/art.13-oa -
 * e' quella classe, non questa, a decidere SE una pagina entra in modalita'
 * live (in base a quali schemi_pubblicazione dichiara).
 */
class PageArticolazioneUfficiProvider
{
    private $serializer;

    public function __construct(Serializer\Art13Serializer $serializer = null)
    {
        $this->serializer = $serializer ?: new Serializer\Art13Serializer();
    }

    public function getOrganiPolitici()
    {
        return $this->serializer->fetchOrganiConUffici();
    }

    public function getOrganiAmministrativi()
    {
        return $this->serializer->fetchOrganiAmministrativi();
    }

    /**
     * @return string JSON di righe {organo, competenzeOrgano, denominazione,
     *         url, tipologia, competenze, nominativo, telefono, email} - una
     *         riga per ufficio, stesso appiattimento organo->uffici gia'
     *         fatto da Art13Serializer::toCsvOrganiUffici() ma qui per
     *         DataTables lato client invece che per un file CSV. Un organo
     *         senza uffici non produce nessuna riga - stesso comportamento
     *         del CSV. `tipologia` (Ufficio dirigenziale/non dirigenziale) e'
     *         calcolata allo stesso modo per qualunque ufficio, politico o
     *         amministrativo (fetchUfficiFigli() non fa differenza) - e il
     *         CSV di questo stesso schema la usa gia' (due colonne
     *         DENOMINAZIONE_UFFICIO_DIRIGENZIALE/NON_DIRIGENZIALE), quindi va
     *         mostrata anche qui per restare coerenti con l'export.
     */
    public function getOrganiPoliticiRowsJson()
    {
        return $this->toSafeJson($this->flattenRows($this->getOrganiPolitici()));
    }

    public function getOrganiAmministrativiRowsJson()
    {
        return $this->toSafeJson($this->flattenRows($this->getOrganiAmministrativi()));
    }

    private function flattenRows(array $organi)
    {
        $rows = [];
        foreach ($organi as $organo) {
            foreach ($organo['uffici'] as $ufficio) {
                $rows[] = [
                    'organo' => $organo['denominazione'],
                    'competenzeOrgano' => $organo['competenze'],
                    'denominazione' => $ufficio['denominazione'],
                    'url' => $ufficio['url'] ?? null,
                    'tipologia' => $ufficio['tipologia'],
                    'competenze' => $ufficio['competenze'],
                    'nominativo' => $ufficio['nominativo'],
                    'telefono' => $ufficio['contatti']['recapitoTelefonico'] ?? '',
                    'email' => $ufficio['contatti']['postaElettronicaOrdinaria'] ?? '',
                ];
            }
        }

        return $rows;
    }

    /**
     * I valori di `denominazione`/`competenze`/`nominativo` sono testo a
     * cura di redattori CMS, non input anonimo - ma vengono incorporati in
     * pagina dentro un blocco <script> come JSON, non mostrati tramite un
     * normale output HTML con escaping automatico del template engine. Un
     * valore che contenga letteralmente la stringa `</script>` chiuderebbe
     * il tag prematuramente e inietterebbe JavaScript arbitrario nella
     * pagina. JSON_HEX_TAG converte `<`/`>` in `<`/`>`, quindi
     * quella sequenza non puo' mai comparire nell'output, qualunque sia il
     * contenuto del campo - JSON_HEX_AMP/APOS/QUOT per lo stesso motivo su
     * `&`/`'`/`"`, che potrebbero altrimenti rompere l'attributo HTML se
     * questo JSON finisse mai incorporato anche li' invece che solo in un
     * blocco <script>.
     */
    private function toSafeJson(array $rows)
    {
        return json_encode(
            $rows,
            JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_UNICODE
        );
    }
}
