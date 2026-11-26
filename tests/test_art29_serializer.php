<?php
/**
 * Test di Art29Serializer (logica pura, nessun kernel eZ): intestazioni CSV
 * esatte, costante art.29-as, mapping riga->colonna per preventivo/consuntivo
 * incluse le 3 corrispondenze non deducibili dal nome (url_preventivo,
 * url_bilancio, differenza_p_q/patrimonio_netto_u_v) - vedi issue cms#556.
 * toCsvPreventivo()/toCsvConsuntivo() senza attributo passato al costruttore
 * restituiscono solo l'intestazione (fetchRighe*() ritorna [] se l'attributo
 * e' null, nessuna query, nessun kernel necessario) - stesso principio di
 * test_art2627_criteri.php.
 * Run: php tests/test_art29_serializer.php
 */

require __DIR__ . '/../classes/anac/CsvLineBuilder.php';
require __DIR__ . '/../classes/anac/Serializer/Art29Serializer.php';

use OpenPABootstrapItalia\Anac\Serializer\Art29Serializer;

$passed = 0;
$failed = 0;
function check($label, $expected, $actual)
{
    global $passed, $failed;
    if ($expected === $actual) {
        $passed++;
        return;
    }
    $failed++;
    echo "FAIL $label\n  atteso:   " . var_export($expected, true) . "\n  ottenuto: " . var_export($actual, true) . "\n";
}

$serializer = new Art29Serializer();

// --- art.29-as: costante, nessun dataset ---
check(
    'toCsvAs() intestazione + valore costante',
    "AMBITO_SOGGETTIVO\nPubbliche amministrazioni in contabilità finanziaria\n",
    $serializer->toCsvAs()
);

// --- intestazioni CSV esatte, senza righe (nessun attributo al costruttore) ---
$headerPrev = "ANNO;URL_PREVENTIVO;ENTRATE_CORRENTI;USCITE_CORRENTI;DIFFERENZA (C-D);ENTRATE_TOTALI;USCITE_TOTALI;DIFFERENZA (F-G);LIQ_CREDITI;LIQ_DEBITI;DIFFERENZA (I-J);CASSA_CREDITI;CASSA_DEBITI;DIFFERENZA (L-M);VALORE_PRODUZIONE;COSTI_PRODUZIONE;DIFFERENZA (O-P);COMP_POSITIVI_REDDITO;COMP_NEGATIVI_REDDITO;DIFFERENZA (R-S);URL_PIANO_INDICATORI\n";
check('toCsvPreventivo() intestazione esatta (nessuna riga)', $headerPrev, $serializer->toCsvPreventivo());

$headerCons = "ANNO;URL_BILANCIO;ENTRATE_CORRENTI;USCITE_CORRENTI;DIFFERENZA (C-D);ENTRATE_TOTALI;USCITE_TOTALI;DIFFERENZA (F-G);LIQ_CREDITI;LIQ_DEBITI;DIFFERENZA (I-J);CASSA_CREDITI;CASSA_DEBITI;DIFFERENZA (L-M);VALORE_PRODUZIONE;COSTI_PRODUZIONE;DIFFERENZA (P-Q);COMP_POSITIVI_REDDITO;COMP_NEGATIVI_REDDITO;DIFFERENZA (R-S);TOTALE_ATTIVO;TOTALE_PASSIVO;PATRIMONIO_NETTO (U-V);CONTRIBUTI_PUBBLICI;CONTRIBUTI_TOTALI;PERC_CONTRIBUZIONE_PUBBLICA;URL_PIANO_INDICATORI\n";
check('toCsvConsuntivo() intestazione esatta (nessuna riga)', $headerCons, $serializer->toCsvConsuntivo());

// --- mapRigaPreventivo()/mapRigaConsuntivo() via Reflection: mapping riga->colonna ---
$ref = new ReflectionClass(Art29Serializer::class);
$mapPrev = $ref->getMethod('mapRigaPreventivo');
$mapPrev->setAccessible(true);
$mapCons = $ref->getMethod('mapRigaConsuntivo');
$mapCons->setAccessible(true);

// Ogni valore e' uguale al nome del proprio identificatore di campo (non un
// valore plausibile condiviso come "1.000,00" ripetuto su piu' campi): uno
// scambio tra due colonne qualsiasi (es. liq_crediti <-> cassa_crediti, o le
// 3 eccezioni url_preventivo/url_bilancio/differenza_p_q) produce un valore
// nel posto sbagliato e fa fallire il confronto sull'intero array atteso,
// non solo su un campione di colonne - trovato in revisione (2026-11-26):
// la versione precedente di questo test usava valori ripetuti ('1.000,00'
// su piu' campi), che non avrebbero rilevato uno scambio tra due colonne
// con lo stesso valore.
$datiPrev = [
    'anno' => 'anno',
    'url_preventivo' => 'url_preventivo',
    'entrate_correnti' => 'entrate_correnti',
    'uscite_correnti' => 'uscite_correnti',
    'differenza_c_d' => 'differenza_c_d',
    'entrate_totali' => 'entrate_totali',
    'uscite_totali' => 'uscite_totali',
    'differenza_f_g' => 'differenza_f_g',
    'liq_crediti' => 'liq_crediti',
    'liq_debiti' => 'liq_debiti',
    'differenza_i_j' => 'differenza_i_j',
    'cassa_crediti' => 'cassa_crediti',
    'cassa_debiti' => 'cassa_debiti',
    'differenza_l_m' => 'differenza_l_m',
    'valore_produzione' => 'valore_produzione',
    'costi_produzione' => 'costi_produzione',
    'differenza_o_p' => 'differenza_o_p',
    'comp_positivi_reddito' => 'comp_positivi_reddito',
    'comp_negativi_reddito' => 'comp_negativi_reddito',
    'differenza_r_s' => 'differenza_r_s',
    'url_piano_indicatori' => 'url_piano_indicatori',
];
$rigaPrev = $mapPrev->invoke($serializer, $datiPrev);
// L'atteso e' la lista dei valori nell'ordine ESATTO delle colonne CSV
// (non l'ordine delle chiavi di $datiPrev, che e' l'ordine dei field del
// dataset - coincide qui, ma il confronto e' sui valori attesi per
// colonna, non un giro dell'array di input).
check('mapRigaPreventivo() intero array nell\'ordine colonna per colonna', [
    'anno', 'url_preventivo', 'entrate_correnti', 'uscite_correnti', 'differenza_c_d',
    'entrate_totali', 'uscite_totali', 'differenza_f_g', 'liq_crediti', 'liq_debiti',
    'differenza_i_j', 'cassa_crediti', 'cassa_debiti', 'differenza_l_m',
    'valore_produzione', 'costi_produzione', 'differenza_o_p', 'comp_positivi_reddito',
    'comp_negativi_reddito', 'differenza_r_s', 'url_piano_indicatori',
], $rigaPrev);

$datiCons = [
    'anno' => 'anno',
    'url_bilancio' => 'url_bilancio',
    'entrate_correnti' => 'entrate_correnti',
    'uscite_correnti' => 'uscite_correnti',
    'differenza_c_d' => 'differenza_c_d',
    'entrate_totali' => 'entrate_totali',
    'uscite_totali' => 'uscite_totali',
    'differenza_f_g' => 'differenza_f_g',
    'liq_crediti' => 'liq_crediti',
    'liq_debiti' => 'liq_debiti',
    'differenza_i_j' => 'differenza_i_j',
    'cassa_crediti' => 'cassa_crediti',
    'cassa_debiti' => 'cassa_debiti',
    'differenza_l_m' => 'differenza_l_m',
    'valore_produzione' => 'valore_produzione',
    'costi_produzione' => 'costi_produzione',
    'differenza_p_q' => 'differenza_p_q',
    'comp_positivi_reddito' => 'comp_positivi_reddito',
    'comp_negativi_reddito' => 'comp_negativi_reddito',
    'differenza_r_s' => 'differenza_r_s',
    'totale_attivo' => 'totale_attivo',
    'totale_passivo' => 'totale_passivo',
    'patrimonio_netto_u_v' => 'patrimonio_netto_u_v',
    'contributi_pubblici' => 'contributi_pubblici',
    'contributi_totali' => 'contributi_totali',
    'perc_contribuzione_pubblica' => 'perc_contribuzione_pubblica',
    'url_piano_indicatori' => 'url_piano_indicatori',
];
$rigaCons = $mapCons->invoke($serializer, $datiCons);
check('mapRigaConsuntivo() intero array nell\'ordine colonna per colonna (incluse le 3 eccezioni url_bilancio/differenza_p_q/patrimonio_netto_u_v)', [
    'anno', 'url_bilancio', 'entrate_correnti', 'uscite_correnti', 'differenza_c_d',
    'entrate_totali', 'uscite_totali', 'differenza_f_g', 'liq_crediti', 'liq_debiti',
    'differenza_i_j', 'cassa_crediti', 'cassa_debiti', 'differenza_l_m',
    'valore_produzione', 'costi_produzione', 'differenza_p_q', 'comp_positivi_reddito',
    'comp_negativi_reddito', 'differenza_r_s', 'totale_attivo', 'totale_passivo',
    'patrimonio_netto_u_v', 'contributi_pubblici', 'contributi_totali',
    'perc_contribuzione_pubblica', 'url_piano_indicatori',
], $rigaCons);

// --- Review Focus: un valore con ";" non deve spaccare il CSV (CsvLineBuilder, RFC 4180) ---
$rigaConPuntoVirgola = $mapPrev->invoke($serializer, [
    'anno' => '2024',
    'url_preventivo' => 'https://esempio.it/preventivo?a=1;b=2',
    'entrate_correnti' => '1.000,00',
    'uscite_correnti' => '1.000,00',
    'differenza_c_d' => '0,00',
    'entrate_totali' => '1.000,00',
    'uscite_totali' => '1.000,00',
    'differenza_f_g' => '0,00',
    'liq_crediti' => '0,00',
    'liq_debiti' => '0,00',
    'differenza_i_j' => '0,00',
    'cassa_crediti' => '0,00',
    'cassa_debiti' => '0,00',
    'differenza_l_m' => '0,00',
    'valore_produzione' => '0,00',
    'costi_produzione' => '0,00',
    'differenza_o_p' => '0,00',
    'comp_positivi_reddito' => '0,00',
    'comp_negativi_reddito' => '0,00',
    'differenza_r_s' => '0,00',
    'url_piano_indicatori' => 'https://esempio.it/piano',
]);
$rigaCsv = \OpenPABootstrapItalia\Anac\CsvLineBuilder::line($rigaConPuntoVirgola);
check('un valore con ";" viene racchiuso tra virgolette (CsvLineBuilder)', true, strpos($rigaCsv, '"https://esempio.it/preventivo?a=1;b=2"') !== false);
// 21 campi -> 20 separatori reali + 1 ";" letterale dentro il valore quotato = 21 totali nella riga
check('il ";" dentro il valore quotato non introduce un campo in più (21 campi = 20 separatori + 1 interno)', 21, substr_count($rigaCsv, ';'));

echo "\nPassed: $passed, Failed: $failed\n";
exit($failed > 0 ? 1 : 0);
