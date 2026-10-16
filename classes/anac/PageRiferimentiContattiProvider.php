<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Espone a template/view i riferimenti e contatti (art.13-rif) senza passare
 * dal formato CSV - stessa fonte dell'export (Art13Serializer::fetchRiferimentiContatti(),
 * query su tutti gli `online_contact_point` del sito, non filtrata per pagina,
 * vedi CLAUDE.md), presentazione diversa (HTML/DataTables invece di file).
 * Nessuna logica di business qui, stesso principio di PageArticolazioneUfficiProvider -
 * classe separata perche' il dato non ha nulla a che fare con organi/uffici
 * (nessuna gerarchia organo->ufficio, solo un elenco piatto di contatti).
 *
 * Registrata in LiveRenderingRegistry sotto lo schema art.13-rif.
 */
class PageRiferimentiContattiProvider
{
    private $serializer;

    public function __construct(Serializer\Art13Serializer $serializer = null)
    {
        $this->serializer = $serializer ?: new Serializer\Art13Serializer();
    }

    /**
     * @return string JSON di righe {denominazione, telefono, email, pec} -
     *         una riga per `online_contact_point` trovato. `denominazione`
     *         (nome dell'oggetto) e' una colonna in piu' rispetto al CSV
     *         (Art13Serializer::toCsvRiferimenti()), solo per il rendering
     *         live - lo schema ANAC per questo export non prevede un nome,
     *         solo i tre recapiti.
     */
    public function getRiferimentiContattiRowsJson()
    {
        $rows = array_map(function ($riferimento) {
            return [
                'denominazione' => $riferimento['denominazione'] ?? '',
                'telefono' => $riferimento['recapitoTelefonico'] ?? '',
                'email' => $riferimento['postaElettronicaOrdinaria'] ?? '',
                'pec' => $riferimento['postaElettronicaCertificata'] ?? '',
            ];
        }, $this->serializer->fetchRiferimentiContatti());

        return json_encode(
            $rows,
            JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_UNICODE
        );
    }
}
