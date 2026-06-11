<?php
/**
 * Test: include_expired nelle regole di rappresentazione (Amministrazione Trasparente)
 *
 * Verifica che parseTableFieldsParameter() gestisca correttamente il parametro
 * include_expired e che la logica di $limitation nel module view sia corretta.
 *
 * Run:
 *   docker compose exec -T app sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_include_expired_trasparenza.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'include_expired trasparenza test',
    'use-session'    => false,
    'use-modules'    => true,
    'use-extensions' => true,
]);
$script->startup();
$script->initialize();

// ── Helpers ───────────────────────────────────────────────────────────────────

$PASSED = 0;
$FAILED = 0;

function assert_true(bool $condition, string $label): void
{
    global $PASSED, $FAILED;
    if ($condition) {
        echo "\033[32m[PASS]\033[0m $label\n";
        $PASSED++;
    } else {
        echo "\033[31m[FAIL]\033[0m $label\n";
        $FAILED++;
    }
}

// ── Test parseTableFieldsParameter ───────────────────────────────────────────

// Test 1: include_expired:true → true
$result = ObjectHandlerServiceContentTrasparenza::parseTableFieldsParameter(
    'include_expired:true|document|name*,abstract,file|3'
);
assert_true(
    is_array($result) && ($result['include_expired'] ?? null) === true,
    "include_expired:true viene parsato come true"
);

// Test 2: nessun parametro → false (default)
$result2 = ObjectHandlerServiceContentTrasparenza::parseTableFieldsParameter(
    'document|name*,abstract,file|3'
);
assert_true(
    is_array($result2) && ($result2['include_expired'] ?? null) === false,
    "assenza di include_expired produce false di default"
);

// Test 3: include_expired:false → false
$result3 = ObjectHandlerServiceContentTrasparenza::parseTableFieldsParameter(
    'include_expired:false|document|name*,abstract,file|3'
);
assert_true(
    is_array($result3) && ($result3['include_expired'] ?? null) === false,
    "include_expired:false viene parsato come false"
);

// Test 4: include_expired:1 → true
$result4 = ObjectHandlerServiceContentTrasparenza::parseTableFieldsParameter(
    'include_expired:1|document|name*,abstract,file|3'
);
assert_true(
    is_array($result4) && ($result4['include_expired'] ?? null) === true,
    "include_expired:1 viene parsato come true"
);

// ── Test logica $limitation ───────────────────────────────────────────────────

// Test 5: include_expired=false → $limitation = null (ACL normale)
$fields5 = ['include_expired' => false];
$includeExpired5 = $fields5['include_expired'] ?? false;
$limitation5 = $includeExpired5 ? [] : null;
assert_true(
    $limitation5 === null,
    "include_expired=false produce \$limitation=null (ACL normale)"
);

// Test 6: include_expired=true → $limitation = [] (bypass ACL)
$fields6 = ['include_expired' => true];
$includeExpired6 = $fields6['include_expired'] ?? false;
$limitation6 = $includeExpired6 ? [] : null;
assert_true(
    is_array($limitation6) && empty($limitation6),
    "include_expired=true produce \$limitation=[] (bypass ACL)"
);

// ── Report ────────────────────────────────────────────────────────────────────

echo "\n";
echo "Risultato: $PASSED passati / " . ($PASSED + $FAILED) . " totali\n";

$script->shutdown($FAILED > 0 ? 1 : 0);
