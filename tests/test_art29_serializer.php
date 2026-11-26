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

$rigaPrev = $mapPrev->invoke($serializer, [
    'anno' => '2024',
    'url_preventivo' => 'https://esempio.it/preventivo-2024',
    'entrate_correnti' => '4.850.000,00',
    'uscite_correnti' => '4.720.500,00',
    'differenza_c_d' => '129.500,00',
    'entrate_totali' => '5.000.000,00',
    'uscite_totali' => '4.900.000,00',
    'differenza_f_g' => '100.000,00',
    'liq_crediti' => '1.000,00',
    'liq_debiti' => '500,00',
    'differenza_i_j' => '500,00',
    'cassa_crediti' => '900,00',
    'cassa_debiti' => '400,00',
    'differenza_l_m' => '500,00',
    'valore_produzione' => '10.000,00',
    'costi_produzione' => '9.000,00',
    'differenza_o_p' => '1.000,00',
    'comp_positivi_reddito' => '2.000,00',
    'comp_negativi_reddito' => '1.500,00',
    'differenza_r_s' => '500,00',
    'url_piano_indicatori' => 'https://esempio.it/piano-indicatori',
]);
check('mapRigaPreventivo() numero di colonne', 21, count($rigaPrev));
check('mapRigaPreventivo() anno in colonna 1', '2024', $rigaPrev[0]);
check('mapRigaPreventivo() url_preventivo in colonna 2 (URL_PREVENTIVO)', 'https://esempio.it/preventivo-2024', $rigaPrev[1]);
check('mapRigaPreventivo() url_piano_indicatori in ultima colonna', 'https://esempio.it/piano-indicatori', $rigaPrev[20]);

$rigaCons = $mapCons->invoke($serializer, [
    'anno' => '2023',
    'url_bilancio' => 'https://esempio.it/consuntivo-2023',
    'entrate_correnti' => '4.912.340,55',
    'uscite_correnti' => '4.698.120,30',
    'differenza_c_d' => '214.220,25',
    'entrate_totali' => '5.000.000,00',
    'uscite_totali' => '4.900.000,00',
    'differenza_f_g' => '100.000,00',
    'liq_crediti' => '1.000,00',
    'liq_debiti' => '500,00',
    'differenza_i_j' => '500,00',
    'cassa_crediti' => '900,00',
    'cassa_debiti' => '400,00',
    'differenza_l_m' => '500,00',
    'valore_produzione' => '10.000,00',
    'costi_produzione' => '9.000,00',
    'differenza_p_q' => '1.000,00',
    'comp_positivi_reddito' => '2.000,00',
    'comp_negativi_reddito' => '1.500,00',
    'differenza_r_s' => '500,00',
    'totale_attivo' => '50.000,00',
    'totale_passivo' => '30.000,00',
    'patrimonio_netto_u_v' => '20.000,00',
    'contributi_pubblici' => '5.000,00',
    'contributi_totali' => '10.000,00',
    'perc_contribuzione_pubblica' => '50',
    'url_piano_indicatori' => 'https://esempio.it/piano-indicatori-2023',
]);
check('mapRigaConsuntivo() numero di colonne', 27, count($rigaCons));
check('mapRigaConsuntivo() url_bilancio in colonna 2 (URL_BILANCIO, non URL_CONSUNTIVO)', 'https://esempio.it/consuntivo-2023', $rigaCons[1]);
check('mapRigaConsuntivo() differenza_p_q in colonna 17 (DIFFERENZA (P-Q))', '1.000,00', $rigaCons[16]);
check('mapRigaConsuntivo() patrimonio_netto_u_v in colonna 23 (PATRIMONIO_NETTO (U-V))', '20.000,00', $rigaCons[22]);
check('mapRigaConsuntivo() url_piano_indicatori in ultima colonna', 'https://esempio.it/piano-indicatori-2023', $rigaCons[26]);

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
