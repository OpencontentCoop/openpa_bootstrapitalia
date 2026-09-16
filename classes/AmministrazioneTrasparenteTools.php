<?php

/**
 * Tipologia ente ai fini ANAC (art. 2-bis, comma 1 o 2, d.lgs. 33/2013):
 * C1 = pubblica amministrazione, C2 = societa'/ente in controllo pubblico.
 * Prerequisito per #477/#478 (perimetro degli export, valore di
 * "ambitoSoggettivo") - vedi openpa_bootstrapitalia/classes/anac/CLAUDE.md.
 */
class AmministrazioneTrasparenteTools
{
    const TIPOLOGIA_C1 = 'C1';
    const TIPOLOGIA_C2 = 'C2';

    /** Amministrazione Trasparente, radice comune a trasparenza e trasparenza-c1 */
    const REMOTE_ID_ROOT_C1 = '5399ef12f98766b90f1804e5d52afd75';

    /** Società trasparente, radice di trasparenza-c2 */
    const REMOTE_ID_ROOT_C2 = 't_c2_root';

    /**
     * @return string|null self::TIPOLOGIA_C1, self::TIPOLOGIA_C2, o null se
     *         non determinabile (nessuna alberatura di trasparenza installata)
     */
    public static function getTipologiaEnte()
    {
        $configured = \eZINI::instance('openpa.ini')->variable('Trasparenza', 'TipologiaEnte');
        if ($configured === self::TIPOLOGIA_C1 || $configured === self::TIPOLOGIA_C2) {
            return $configured;
        }

        return self::guessTipologiaEnteFromInstalledModules();
    }

    /**
     * Euristica di transizione per i siti gia' installati prima
     * dell'introduzione di [Trasparenza]TipologiaEnte in openpa.ini: deriva
     * la tipologia dalla presenza del nodo radice caratteristico di
     * trasparenza-c1 o trasparenza-c2. Se sono presenti entrambi (caso non
     * atteso: un ente non dovrebbe essere contemporaneamente C1 e C2), vince C1.
     */
    private static function guessTipologiaEnteFromInstalledModules()
    {
        if (\eZContentObject::fetchByRemoteID(self::REMOTE_ID_ROOT_C1) instanceof \eZContentObject) {
            return self::TIPOLOGIA_C1;
        }

        if (\eZContentObject::fetchByRemoteID(self::REMOTE_ID_ROOT_C2) instanceof \eZContentObject) {
            return self::TIPOLOGIA_C2;
        }

        return null;
    }
}
