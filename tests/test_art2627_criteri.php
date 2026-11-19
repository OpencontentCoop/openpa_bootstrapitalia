<?php
/**
 * Test di Art2627Serializer::mapRigaCriteri()/raggruppaPerAttoNormativo()/
 * toCsvCriteri()/toJsonCriteri() (logica pura su righe gia' mappate - non
 * richiede il kernel eZ, stesso principio di test_anac_importo_normalizer.php).
 * Run: php tests/test_art2627_criteri.php
 */

require __DIR__ . '/../classes/anac/CsvLineBuilder.php';
require __DIR__ . '/../classes/anac/Serializer/Art2627Serializer.php';

use OpenPABootstrapItalia\Anac\Serializer\Art2627Serializer;

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

// Nota: Art2627Serializer non espone un costruttore senza argomenti per i
// metodi statici/puri - li chiamiamo via Reflection per non dover costruire
// due eZContentObjectAttribute finti solo per testare logica che non li usa.
$ref = new ReflectionClass(Art2627Serializer::class);
$instance = $ref->newInstanceWithoutConstructor();

$mapRiga = $ref->getMethod('mapRigaCriteri');
$mapRiga->setAccessible(true);
$raggruppa = $ref->getMethod('raggruppaPerAttoNormativo');
$raggruppa->setAccessible(true);

// --- mapRigaCriteri() ---
$rigaConAttuativo = $mapRiga->invoke($instance, [
    'numero_atto_normativo' => 'N. 175',
    'anno_atto_normativo' => '2022',
    'link_atto_normativo' => 'https://esempio.it/atto175',
    'numero_atto_attuativo' => 'Bando 3',
    'anno_atto_attuativo' => '2023',
    'link_atto_attuativo' => 'https://esempio.it/bando3',
]);
check('mapRigaCriteri numeroAttoNormativo', 'N. 175', $rigaConAttuativo['numeroAttoNormativo']);
check('mapRigaCriteri annoAttoNormativo (int)', 2022, $rigaConAttuativo['annoAttoNormativo']);
check('mapRigaCriteri numeroAttoAttuativo', 'Bando 3', $rigaConAttuativo['numeroAttoAttuativo']);
check('mapRigaCriteri annoAttoAttuativo (int)', 2023, $rigaConAttuativo['annoAttoAttuativo']);

$rigaSenzaAttuativo = $mapRiga->invoke($instance, [
    'numero_atto_normativo' => 'N. 10',
    'anno_atto_normativo' => '2021',
    'link_atto_normativo' => 'https://esempio.it/atto10',
    'numero_atto_attuativo' => '',
    'anno_atto_attuativo' => '',
    'link_atto_attuativo' => '',
]);
check('mapRigaCriteri senza attuativo -> null', null, $rigaSenzaAttuativo['numeroAttoAttuativo']);

// --- raggruppaPerAttoNormativo() ---
$rigaConAttuativo2 = $mapRiga->invoke($instance, [
    'numero_atto_normativo' => 'N. 175',
    'anno_atto_normativo' => '2022',
    'link_atto_normativo' => 'https://esempio.it/atto175',
    'numero_atto_attuativo' => 'Avviso 7',
    'anno_atto_attuativo' => '2023',
    'link_atto_attuativo' => 'https://esempio.it/avviso7',
]);

$gruppi = $raggruppa->invoke($instance, [$rigaConAttuativo, $rigaConAttuativo2, $rigaSenzaAttuativo]);
check('raggruppaPerAttoNormativo: 2 gruppi', 2, count($gruppi));

$gruppoConDueAttuativi = null;
$gruppoSenzaAttuativi = null;
foreach ($gruppi as $gruppo) {
    if ($gruppo['attoNormativo']['numero'] === 'N. 175') {
        $gruppoConDueAttuativi = $gruppo;
    }
    if ($gruppo['attoNormativo']['numero'] === 'N. 10') {
        $gruppoSenzaAttuativi = $gruppo;
    }
}
check('gruppo N.175 ha 2 attiAmministrativi', 2, count($gruppoConDueAttuativi['attiAmministrativi']));
check('gruppo N.10 non ha attiAmministrativi (omesso)', true, $gruppoSenzaAttuativi['attiAmministrativi'] === null);

// --- toCsvCriteri() / toJsonCriteri() via metodi pubblici puri separati ---
// (coperti dal test kernel-dipendente nella issue GitLab #527, sezione Test
// punti 3-5 - qui testiamo solo che il motore di raggruppamento/mappatura
// sia corretto, che è la parte a rischio di bug logici.)

echo "\nPassed: $passed, Failed: $failed\n";
exit($failed > 0 ? 1 : 0);
