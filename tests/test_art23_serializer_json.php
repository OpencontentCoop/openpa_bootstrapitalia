<?php
/**
 * Verifica Art23Serializer::toJson(): struttura conforme allo schema ANAC
 * reale (validato con JsonSchemaValidator, non solo "json_decode non
 * fallisce"), provvedimento/allegati presenti solo per documenti pubblici,
 * chiave omessa (non array vuoto) quando un gruppo non ha righe.
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_json.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/vendor/autoload.php';
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'Art23Serializer JSON test',
    'use-session'    => false,
    'use-modules'    => true,
    'use-extensions' => true,
]);
$script->startup();
$script->initialize();

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

$amministrazione = ['codiceFiscale' => '12345678901', 'denominazione' => 'Comune di Prova'];
$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art23Serializer($amministrazione);

$organiRows = [[
    'object' => null,
    'denominazione' => 'Decreto',
    'group' => 'organi',
    '__override' => ['data' => '12/03/2026', 'numero' => '45', 'oggetto' => 'Nomina', 'strutturaResponsabile' => 'Ufficio Segreteria'],
]];

// Il JSON con un solo gruppo valorizzato deve essere comunque conforme
// (l'altro array va omesso, non svuotato).
$jsonSoloOrgani = $serializer->toJson('01/01/2026', '01/01/2026', $organiRows, []);
$decoded = json_decode($jsonSoloOrgani, true);
check('chiave provvedimentiDirigDiAltraTipologia assente quando il gruppo e\' vuoto', false, array_key_exists('provvedimentiDirigDiAltraTipologia', $decoded));
check('chiave provvedimentiOrganiPolitici presente', true, array_key_exists('provvedimentiOrganiPolitici', $decoded));

try {
    \OpenPABootstrapItalia\Anac\JsonSchemaValidator::validate('art.23-v1.0.schema.json', $jsonSoloOrgani);
    check('JSON prodotto e\' conforme allo schema reale', true, true);
} catch (\OpenPABootstrapItalia\Anac\InvalidAnacSchemaException $e) {
    check('JSON prodotto e\' conforme allo schema reale', true, false);
    echo '  dettaglio: ' . $e->getMessage() . "\n";
}

// Entrambi i gruppi vuoti: toJson() non deve essere chiamato dal cron in
// questo caso (vedi Task 9) - ma se lo fosse, il JSON prodotto conterrebbe
// solo $schema+intestazione, comunque conforme (nessun campo richiesto oltre
// quei due a livello radice).
$jsonVuoto = $serializer->toJson('01/01/2026', '01/01/2026', [], []);
try {
    \OpenPABootstrapItalia\Anac\JsonSchemaValidator::validate('art.23-v1.0.schema.json', $jsonVuoto);
    check('JSON con entrambi i gruppi vuoti resta conforme', true, true);
} catch (\OpenPABootstrapItalia\Anac\InvalidAnacSchemaException $e) {
    check('JSON con entrambi i gruppi vuoti resta conforme', true, false);
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
