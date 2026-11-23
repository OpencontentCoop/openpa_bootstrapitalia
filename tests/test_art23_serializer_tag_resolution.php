<?php
/**
 * Verifica che Art23Serializer::resolveTagMap() esponga esattamente i 13
 * remote_id attesi, nei due gruppi corretti - il gap che oggi esiste in
 * produzione (le due pagine attuali escludono Decreto/Ordinanza e mettono
 * erroneamente "Determinazione del Sindaco" tra i dirigenti).
 *
 * Include anche un controllo di coerenza contro la tassonomia LIVE: per
 * ciascuno dei 13 remote_id hardcoded, verifica che il tag esista ancora e
 * che il suo keyword corrisponda a quello atteso - se un domani un
 * redattore rinominasse un tag, questo test fallisce in modo rumoroso
 * invece di lasciare che l'export si impoverisca senza nessun segnale
 * (motivo per cui si e' scelto remote_id hardcoded invece di risoluzione
 * per keyword, vedi nota di design sopra).
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art23_serializer_tag_resolution.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'Art23Serializer tag resolution test',
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

$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art23Serializer();
$tagMap = $serializer->resolveTagMap();

check('13 tag foglia nella mappa', 13, count($tagMap));

$organiCount = 0;
$dirigentiCount = 0;
foreach ($tagMap as $info) {
    if ($info['group'] === 'organi') {
        $organiCount++;
    } elseif ($info['group'] === 'dirigenti') {
        $dirigentiCount++;
    }
}
check('10 remote_id nel gruppo organi', 10, $organiCount);
check('3 remote_id nel gruppo dirigenti (non Determinazione del Sindaco)', 3, $dirigentiCount);

// Controllo di coerenza con la tassonomia live: ogni remote_id hardcoded
// deve risolvere a un tag esistente il cui keyword coincide con
// l'etichetta attesa (documentata qui per leggibilita', non usata a
// runtime da resolveTagMap()).
$expectedKeywords = [
    'ccf6761810b5ac50d32eade1fbe17fca' => 'Decreto del Sindaco',
    '99af81198d42521cfc45090770824e26' => 'Determinazione del Sindaco',
    '2039d8bedb749132b8bf4301f4c6aeb6' => 'Ordinanza del Sindaco',
    '4271686f78f9dbc0fb871f32553ffb6c' => 'Deliberazione del Commissario ad acta',
    '19123462b045f0b8977ce0b1a9047032' => 'Deliberazione del Commissario straordinario',
    '7634e3355a07d671094fe120d7919653' => 'Deliberazione del Consiglio circoscrizionale',
    '7bda99bae095fde15daa1fe54af6861c' => 'Deliberazione del Consiglio comunale',
    '5b1e0b73926e47e0e8691c727a2a57df' => 'Deliberazione della Giunta comunale',
    '2a8a6817a8f54531c77be68f03655833' => "Deliberazione dell'Esecutivo circoscrizionale",
    '173d943cedd25729d8707a753b12280c' => 'Deliberazione di altri Organi',
    'fd0176933fb88cb62d6a3ad4be3cdaa2' => 'Decreto del Dirigente',
    'f3431b7c90f441bab1a0b2e3068325d4' => 'Determinazione del Dirigente',
    '4bdaece33ace3d1c3911b3b43c554b47' => 'Ordinanza del Dirigente',
];

foreach ($expectedKeywords as $remoteId => $expectedKeyword) {
    $tag = eZTagsObject::fetchByRemoteID($remoteId);
    check("tag '$remoteId' esiste ancora nella tassonomia", true, $tag instanceof eZTagsObject);
    if ($tag instanceof eZTagsObject) {
        check("keyword di '$remoteId' invariato", $expectedKeyword, $tag->getKeyword(SchemaPubblicazioneLookup::EXPORT_LANGUAGE));
    }
}

echo "\n$PASSED controlli ok, $FAILED falliti\n";
exit($FAILED === 0 ? 0 : 1);
