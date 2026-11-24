<?php
/**
 * Test di JsonSchemaValidator contro lo schema reale art.23 (logica pura +
 * libreria vendor, nessun kernel eZ - a differenza dei test che leggono
 * contenuti, qui serve solo l'autoload Composer per JsonSchema\Validator).
 *
 * Run (container, serve il vendor/autoload.php di Composer):
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_anac_json_schema_validator.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
require_once $ezRoot . '/vendor/autoload.php';
require __DIR__ . '/../classes/anac/InvalidAnacSchemaException.php';
require __DIR__ . '/../classes/anac/JsonSchemaValidator.php';

use OpenPABootstrapItalia\Anac\JsonSchemaValidator;
use OpenPABootstrapItalia\Anac\InvalidAnacSchemaException;

$PASSED = 0;
$FAILED = 0;
function check($label, $expected, $actual)
{
    global $PASSED, $FAILED;
    if ($expected === $actual) {
        $PASSED++;
        return;
    }
    $FAILED++;
    echo "FAIL $label\n  atteso:   " . var_export($expected, true) . "\n  ottenuto: " . var_export($actual, true) . "\n";
}
function validates($json)
{
    try {
        JsonSchemaValidator::validate('art.23-v1.0.schema.json', $json);
        return true;
    } catch (InvalidAnacSchemaException $e) {
        return false;
    }
}

$validPayload = [
    '$schema' => 'https://guida-servizi.anticorruzione.it/help/trasparenza/schemi/json/art.23-v1.0.schema.json',
    'intestazione' => [
        'amministrazione' => ['codiceFiscale' => '12345678901', 'denominazione' => 'Comune di Prova'],
        'dataPrimaPubblicazione' => '01/01/2026',
        'dataUltimaModifica' => '01/01/2026',
    ],
    'provvedimentiOrganiPolitici' => [[
        'data' => '12/03/2026',
        'numero' => '45',
        'denominazione' => 'Decreto',
        'oggetto' => 'Nomina responsabile',
        'strutturaResponsabile' => 'Ufficio Segreteria',
    ]],
];

check('payload valido passa', true, validates(json_encode($validPayload)));

check('intestazione mancante fallisce', false, validates(json_encode(['$schema' => 'x'])));

$badDate = $validPayload;
$badDate['provvedimentiOrganiPolitici'][0]['data'] = '2026-03-12';
check('data in formato sbagliato fallisce', false, validates(json_encode($badDate)));

$missingField = $validPayload;
unset($missingField['provvedimentiOrganiPolitici'][0]['strutturaResponsabile']);
check('campo obbligatorio mancante fallisce', false, validates(json_encode($missingField)));

$badUrl = $validPayload;
$badUrl['provvedimentiOrganiPolitici'][0]['provvedimento'] = 'www.example.org/senza-protocollo';
check('url senza http(s) fallisce', false, validates(json_encode($badUrl)));

$noDirigenti = $validPayload;
unset($noDirigenti['provvedimentiDirigDiAltraTipologia']);
check('chiave array opzionale assente passa (nessun provvedimento dirigenziale quel giorno)', true, validates(json_encode($noDirigenti)));

$emptyArray = $validPayload;
$emptyArray['provvedimentiDirigDiAltraTipologia'] = [];
check('array vuoto presente fallisce (minItems:1, va omesso non svuotato)', false, validates(json_encode($emptyArray)));

try {
    JsonSchemaValidator::validate('art.23-v1.0.schema.json', 'non e\' json valido {{{');
    check('json malformato lancia eccezione', true, false);
} catch (InvalidAnacSchemaException $e) {
    check('json malformato lancia eccezione', true, true);
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
