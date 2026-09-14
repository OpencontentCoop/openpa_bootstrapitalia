<?php

namespace OpenPABootstrapItalia\Anac;

/**
 * Blocco "intestazione" comune a tutti gli schemi ANAC (#479): codice fiscale
 * e denominazione dell'ente. Nessuna nuova fonte dati: si riusano gli stessi
 * campi gia' mostrati pubblicamente sul sito, con lo stesso codice gia' in
 * produzione (SiteInfo.php):
 *
 * - denominazione: eZINI SiteSettings.SiteName - stesso valore usato da
 *   SiteInfo.php per il <title> (via slug logo, riga 64) e per la nota di
 *   default nel footer (riga 185). Verificato sul sito di riferimento
 *   (Bugliano): <title>Comune di Bugliano</title> e footer "Comune di
 *   Bugliano" coincidono, nel formato "Comune di ..." richiesto da ANAC.
 * - codiceFiscale: riga "Codice fiscale" (identifier codice_fiscale) della
 *   matrice "contacts" sulla Homepage, la stessa letta da SiteInfo.php:315
 *   per l'oggetto 'cf' esposto ai widget SDC.
 *
 * codiceFiscale e' un campo obbligatorio dello schema ANAC (Amministrazione):
 * se il redattore non l'ha compilato, getAmministrazione() lancia
 * MissingCodiceFiscaleException invece di produrre un export incompleto -
 * decisione esplicita di Marco il 2026-09-14, non un default prudente.
 */
class IntestazioneProvider
{
    /**
     * @throws MissingCodiceFiscaleException se il codice fiscale non e' compilato sulla Homepage
     */
    public static function getAmministrazione()
    {
        $codiceFiscale = self::getCodiceFiscale();
        if ($codiceFiscale === '') {
            throw new MissingCodiceFiscaleException(
                'Codice fiscale non compilato nei contatti della Homepage: impossibile generare export ANAC'
            );
        }

        return [
            'codiceFiscale' => $codiceFiscale,
            'denominazione' => \eZINI::instance()->variable('SiteSettings', 'SiteName'),
        ];
    }

    private static function getCodiceFiscale()
    {
        $homeNode = \OpenPaFunctionCollection::fetchHome();
        if (!$homeNode instanceof \eZContentObjectTreeNode) {
            return '';
        }

        $dataMap = $homeNode->attribute('object')->attribute('data_map');
        if (!isset($dataMap['contacts'])) {
            return '';
        }

        $contacts = \OpenPAAttributeContactsHandler::getContactsData($dataMap['contacts']);

        return $contacts['codice_fiscale'] ?? '';
    }
}
