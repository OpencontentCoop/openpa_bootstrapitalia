<?php
/**
 * Test di Art2627Serializer::mapRigaAtti() (logica pura - non richiede il
 * kernel eZ).
 * Run: php tests/test_art2627_atti.php
 */

require __DIR__ . '/../classes/anac/CsvLineBuilder.php';
require __DIR__ . '/../classes/anac/InvalidImportoException.php';
require __DIR__ . '/../classes/anac/ImportoNormalizer.php';
require __DIR__ . '/../classes/anac/InvalidTelefonoException.php';
require __DIR__ . '/../classes/anac/TelefonoNormalizer.php';
require __DIR__ . '/../classes/anac/Serializer/Art2627Serializer.php';

use OpenPABootstrapItalia\Anac\Serializer\Art2627Serializer;
use OpenPABootstrapItalia\Anac\InvalidTelefonoException;

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

$ref = new ReflectionClass(Art2627Serializer::class);
$instance = $ref->newInstanceWithoutConstructor();
$mapRigaAtti = $ref->getMethod('mapRigaAtti');
$mapRigaAtti->setAccessible(true);

$rigaBase = [
    'numero' => '123', 'anno' => '2026', 'beneficiario' => 'Acme S.r.l. - 12345678901',
    'importo' => '1500', 'identificativo_norma' => 'Delibera 5/2026',
    'nominativo_resp_proc' => 'Mario Rossi', 'qualifica_resp_proc' => 'Dirigente',
    'ufficio_resp_proc' => 'Ufficio Contributi', 'telefono_resp_proc' => '06 12345678',
    'peo' => 'contributi@comune.it', 'pec' => '', 'modalita_individuazione' => 'Avviso pubblico',
    'link_progetto' => '', 'numero_atto_revoca' => '', 'anno_atto_revoca' => '', 'motivazione_revoca' => '',
];

$riga = $mapRigaAtti->invoke($instance, $rigaBase);
check('mapRigaAtti importo normalizzato', '1.500,00', $riga['importo']);
check('mapRigaAtti telefono validato', '06 12345678', $riga['responsabile']['telefono']);
check('mapRigaAtti senza revoca -> null', null, $riga['revoca']);
check('mapRigaAtti peo presente', 'contributi@comune.it', $riga['responsabile']['peo'] ?? null);

$rigaConRevoca = $mapRigaAtti->invoke($instance, array_merge($rigaBase, [
    'numero_atto_revoca' => '7', 'anno_atto_revoca' => '2026', 'motivazione_revoca' => 'Rinuncia del beneficiario',
]));
check('mapRigaAtti con revoca: numero', '7', $rigaConRevoca['revoca']['numero']);
check('mapRigaAtti con revoca: anno (int)', 2026, $rigaConRevoca['revoca']['anno']);
check('mapRigaAtti con revoca: motivazione', 'Rinuncia del beneficiario', $rigaConRevoca['revoca']['motivazione']);

// Telefono malformato: deve lanciare, non pubblicare un valore non conforme.
$harLanciato = false;
try {
    $mapRigaAtti->invoke($instance, array_merge($rigaBase, ['telefono_resp_proc' => 'non è un numero']));
} catch (InvalidTelefonoException $e) {
    $harLanciato = true;
}
check('telefono malformato lancia InvalidTelefonoException', true, $harLanciato);

echo "\nPassed: $passed, Failed: $failed\n";
exit($failed > 0 ? 1 : 0);
