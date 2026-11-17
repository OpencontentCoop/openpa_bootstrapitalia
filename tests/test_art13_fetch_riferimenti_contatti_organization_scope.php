<?php
/**
 * Verifica la nuova logica di Art13Serializer::fetchRiferimentiContatti()
 * (art.13-rif, cms#478 - vedi CLAUDE.md "Riferimenti e contatti"), decisa
 * con Marco il 2026-11-11: scope ristretto a `organization` invece di uno
 * scan slegato su tutta la classe `online_contact_point` (che includeva
 * anche contatti di event/public_service/place/topic/article/homepage/
 * private_organization/public_person - non "compiti istituzionali" ai sensi
 * di art.13 co.1 lett. d).
 *
 * Copre quattro comportamenti:
 * 1. Il contatto di una RADICE (organo politico di vertice, area
 *    amministrativa di vertice) viene incluso - non solo quello dei
 *    discendenti (fetchOrganiConUffici()/fetchOrganiAmministrativi() non lo
 *    catturano mai per conto proprio, vedi fetchUfficiFigli()).
 * 2. Il contatto di un discendente (ufficio/direzione) viene incluso.
 * 3. Un organo condiviso da piu' radici duplicate produce UN SOLO
 *    riferimento (deduplicazione per id di online_contact_point, non di
 *    organization - vedi sotto), non uno per radice che lo raggiunge -
 *    stesso scenario del test di memoizzazione
 *    (test_art13_fetch_ufficio_figli_duplicate_roots_memoization.php).
 * 4. Due organi REALMENTE DIVERSI (non raggiunti da radici duplicate) che
 *    condividono lo stesso online_contact_point (es. un contatto
 *    placeholder non ancora personalizzato, riusato da piu' Aree - caso
 *    reale trovato nei dati di dev il 2026-11-11) producono anch'essi UN
 *    SOLO riferimento, non uno per organo: l'obbligo di legge e' un elenco
 *    di contatti, l'unita' e' il contatto stesso, non l'organo che lo usa -
 *    per questo la deduplicazione e' per id di online_contact_point, non di
 *    organization (una prima versione deduplicava per organo e falliva
 *    esattamente questo caso).
 *
 * Run:
 *   docker exec sito-comunale-dev-app-1 sh -c \
 *     'OUT=$(php /var/www/html/extension/openpa_bootstrapitalia/tests/test_art13_fetch_riferimenti_contatti_organization_scope.php 2>&1); echo "$OUT"'
 */

$ezRoot = '/var/www/html';
chdir($ezRoot);
require_once $ezRoot . '/autoload.php';

$script = eZScript::instance([
    'description'    => 'fetchRiferimentiContatti organization scope test',
    'use-session'    => false,
    'use-modules'    => true,
    'use-extensions' => true,
]);
$script->startup();
$script->initialize();

$PASSED = 0;
$FAILED = 0;

function assert_true(bool $condition, string $label): void
{
    global $PASSED, $FAILED;
    if ($condition) { echo "\033[32m[PASS]\033[0m $label\n"; $PASSED++; }
    else            { echo "\033[31m[FAIL]\033[0m $label\n"; $FAILED++; }
}
function assert_eq($a, $b, string $label): void
{
    global $PASSED, $FAILED;
    if ($a === $b) { echo "\033[32m[PASS]\033[0m $label\n"; $PASSED++; }
    else            { echo "\033[31m[FAIL]\033[0m $label (got " . var_export($a, true) . ", expected " . var_export($b, true) . ")\n"; $FAILED++; }
}

$createdObjectIds = [];
function cleanup(array $ids): void
{
    if (empty($ids)) return;
    echo "\nCleanup: rimuovo " . count($ids) . " oggetti di test...\n";
    foreach ($ids as $id) {
        eZContentObjectOperations::remove($id);
    }
    echo "Rimossi.\n";
}
register_shutdown_function(function () use (&$createdObjectIds) { cleanup($createdObjectIds); });

$adminUser = eZUser::fetchByName('admin');
assert_true($adminUser instanceof eZUser, "Precondizione: utente 'admin' esiste");
eZUser::setCurrentlyLoggedInUser($adminUser, $adminUser->attribute('contentobject_id'), eZUser::NO_SESSION_REGENERATE);

$ownerId = $adminUser->attribute('contentobject_id');
$sectionId = eZSection::fetchByIdentifier('standard') ? eZSection::fetchByIdentifier('standard')->attribute('id') : 1;

$db = eZDB::instance();
$orgParentRows = $db->arrayQuery(
    "SELECT DISTINCT n.parent_node_id FROM ezcontentobject_tree n " .
    "JOIN ezcontentobject o ON o.id = n.contentobject_id " .
    "JOIN ezcontentclass c ON c.id = o.contentclass_id " .
    "WHERE c.identifier = 'organization' LIMIT 1"
);
$orgParentNodeId = !empty($orgParentRows) ? (int)$orgParentRows[0]['parent_node_id'] : 2;

$contactParentRows = $db->arrayQuery(
    "SELECT DISTINCT n.parent_node_id FROM ezcontentobject_tree n " .
    "JOIN ezcontentobject o ON o.id = n.contentobject_id " .
    "JOIN ezcontentclass c ON c.id = o.contentclass_id " .
    "WHERE c.identifier = 'online_contact_point' LIMIT 1"
);
$contactParentNodeId = !empty($contactParentRows) ? (int)$contactParentRows[0]['parent_node_id'] : $orgParentNodeId;

$areaTag = eZTagsObject::fetchByRemoteID(\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::TAG_REMOTE_ID_AREA);
assert_true($areaTag instanceof eZTagsObject, 'Precondizione: tag "Area" trovato per remote_id');
define('TAG_ID_AREA', (int)$areaTag->attribute('id'));

$strutturaPoliticaTag = eZTagsObject::fetchByRemoteID(\OpenPABootstrapItalia\Anac\Serializer\Art13Serializer::TAG_REMOTE_ID_STRUTTURA_POLITICA);
assert_true($strutturaPoliticaTag instanceof eZTagsObject, 'Precondizione: tag radice "Struttura politica" trovato per remote_id');
define('TAG_ID_STRUTTURA_POLITICA', (int)$strutturaPoliticaTag->attribute('id'));

/**
 * Crea un online_contact_point con un solo recapito telefonico (basta a
 * rendere fetchContatti()/parseContattiMatrix() non vuoto - vedi
 * contattiCompletiPerSchema() per il motivo per cui basta un campo).
 * Formato fromString() di ezmatrix: righe separate da "&", colonne da "|"
 * (eZMatrixType::fromString() nel kernel) - solo le prime due colonne
 * contano per parseContattiMatrix() (tipo, valore).
 */
function createContactPoint(string $legalName, string $telefono, int $ownerId, int $sectionId, int $parentNodeId, array &$createdObjectIds): eZContentObject
{
    $class = eZContentClass::fetchByIdentifier('online_contact_point');
    $object = $class->instantiate($ownerId, $sectionId, false, 'ita-IT');

    eZNodeAssignment::create([
        'contentobject_id'      => $object->attribute('id'),
        'contentobject_version' => 1,
        'parent_node'           => $parentNodeId,
        'is_main'               => 1,
        'sort_field'            => eZContentObjectTreeNode::SORT_FIELD_PUBLISHED,
        'sort_order'            => eZContentObjectTreeNode::SORT_ORDER_DESC,
    ])->store();

    $version = $object->version(1);
    foreach ($version->contentObjectAttributes('ita-IT') as $attr) {
        if ($attr->contentClassAttributeIdentifier() === 'name') {
            $attr->fromString($legalName);
            $attr->store();
        }
        if ($attr->contentClassAttributeIdentifier() === 'contact') {
            $attr->fromString('Telefono|' . $telefono);
            $attr->store();
        }
    }

    eZOperationHandler::execute('content', 'publish', ['object_id' => $object->attribute('id'), 'version' => 1]);
    $createdObjectIds[] = (int)$object->attribute('id');

    return eZContentObject::fetch((int)$object->attribute('id'));
}

/**
 * Stessa createOrganization() dei test precedenti, estesa per accettare
 * anche un id di online_contact_point da collegare via
 * has_online_contact_point.
 */
function createOrganization(string $legalName, int $typeTagId, array $holdEmploymentTargetIds, ?int $contactPointId, int $ownerId, int $sectionId, int $parentNodeId, array &$createdObjectIds): eZContentObject
{
    $class = eZContentClass::fetchByIdentifier('organization');
    $object = $class->instantiate($ownerId, $sectionId, false, 'ita-IT');

    eZNodeAssignment::create([
        'contentobject_id'      => $object->attribute('id'),
        'contentobject_version' => 1,
        'parent_node'           => $parentNodeId,
        'is_main'               => 1,
        'sort_field'            => eZContentObjectTreeNode::SORT_FIELD_PUBLISHED,
        'sort_order'            => eZContentObjectTreeNode::SORT_ORDER_DESC,
    ])->store();

    $tag = eZTagsObject::fetch($typeTagId);
    $tagString = $tag->attribute('id') . '|#' . $tag->attribute('keyword') . '|#' . $tag->attribute('parent_id') . '|#eng-GB';

    $version = $object->version(1);
    foreach ($version->contentObjectAttributes('ita-IT') as $attr) {
        if ($attr->contentClassAttributeIdentifier() === 'legal_name') {
            $attr->fromString($legalName);
            $attr->store();
        }
        if ($attr->contentClassAttributeIdentifier() === 'type') {
            $attr->fromString($tagString);
            $attr->store();
        }
        if (!empty($holdEmploymentTargetIds) && $attr->contentClassAttributeIdentifier() === 'hold_employment') {
            $attr->fromString(implode('-', $holdEmploymentTargetIds));
            $attr->store();
        }
        if ($contactPointId !== null && $attr->contentClassAttributeIdentifier() === 'has_online_contact_point') {
            $attr->fromString((string)$contactPointId);
            $attr->store();
        }
    }

    eZOperationHandler::execute('content', 'publish', ['object_id' => $object->attribute('id'), 'version' => 1]);
    $createdObjectIds[] = (int)$object->attribute('id');

    return eZContentObject::fetch((int)$object->attribute('id'));
}

$uniqueSuffix = date('Ymd-His') . '-' . substr(md5(uniqid()), 0, 6);

// 1. Organo politico di vertice, con un contatto PROPRIO (non su un ufficio
//    figlio) - fetchOrganiConUffici() non lo catturerebbe affatto da solo.
$contattoOrganoPolitico = createContactPoint("Contatto Organo Politico $uniqueSuffix", '0587111111', $ownerId, $sectionId, $contactParentNodeId, $createdObjectIds);
$organoPolitico = createOrganization("Spike Organo Politico $uniqueSuffix", TAG_ID_STRUTTURA_POLITICA, [], (int)$contattoOrganoPolitico->attribute('id'), $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);

// 2. Area amministrativa di vertice, con un contatto PROPRIO - il caso
//    specifico chiesto da Marco.
$contattoAreaVertice = createContactPoint("Contatto Area Vertice $uniqueSuffix", '0587222222', $ownerId, $sectionId, $contactParentNodeId, $createdObjectIds);
$areaVertice = createOrganization("Spike Area Vertice $uniqueSuffix", TAG_ID_AREA, [], (int)$contattoAreaVertice->attribute('id'), $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);

// 3. Ufficio DISCENDENTE dell'area di vertice, con il proprio contatto.
$contattoUfficioFiglio = createContactPoint("Contatto Ufficio Figlio $uniqueSuffix", '0587333333', $ownerId, $sectionId, $contactParentNodeId, $createdObjectIds);
$ufficioFiglio = createOrganization("Spike Ufficio Figlio $uniqueSuffix", TAG_ID_AREA, [(int)$areaVertice->attribute('id')], (int)$contattoUfficioFiglio->attribute('id'), $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);

// 4. Due radici amministrative duplicate che condividono lo stesso organo
//    figlio (stesso scenario del test di memoizzazione) - il figlio ha il
//    proprio contatto, deve comparire UNA sola volta nel risultato finale.
$radiceDup1 = createOrganization("Spike Radice Dup 1 $uniqueSuffix", TAG_ID_AREA, [], null, $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);
$radiceDup2 = createOrganization("Spike Radice Dup 2 $uniqueSuffix", TAG_ID_AREA, [], null, $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);
$contattoCondiviso = createContactPoint("Contatto Condiviso $uniqueSuffix", '0587444444', $ownerId, $sectionId, $contactParentNodeId, $createdObjectIds);
$condiviso = createOrganization(
    "Spike Organo Condiviso $uniqueSuffix",
    TAG_ID_AREA,
    [(int)$radiceDup1->attribute('id'), (int)$radiceDup2->attribute('id')],
    (int)$contattoCondiviso->attribute('id'),
    $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds
);

// 5. Due radici AMMINISTRATIVE INDIPENDENTI (nessun hold_employment in comune,
//    nessuna parentela) che pero' condividono LO STESSO online_contact_point
//    - caso reale trovato nei dati di dev il 2026-11-11 (un placeholder non
//    ancora personalizzato riusato da piu' Aree). Deve comparire UNA sola
//    volta, non una per organo: la deduplicazione e' per id del contatto.
$contattoPlaceholderCondiviso = createContactPoint("Contatto Placeholder Condiviso $uniqueSuffix", '0587555555', $ownerId, $sectionId, $contactParentNodeId, $createdObjectIds);
$areaIndipendente1 = createOrganization("Spike Area Indipendente 1 $uniqueSuffix", TAG_ID_AREA, [], (int)$contattoPlaceholderCondiviso->attribute('id'), $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);
$areaIndipendente2 = createOrganization("Spike Area Indipendente 2 $uniqueSuffix", TAG_ID_AREA, [], (int)$contattoPlaceholderCondiviso->attribute('id'), $ownerId, $sectionId, $orgParentNodeId, $createdObjectIds);

$solrIndexer = eZSearch::getEngine();
foreach ([$contattoOrganoPolitico, $organoPolitico, $contattoAreaVertice, $areaVertice, $contattoUfficioFiglio, $ufficioFiglio, $radiceDup1, $radiceDup2, $contattoCondiviso, $condiviso, $contattoPlaceholderCondiviso, $areaIndipendente1, $areaIndipendente2] as $object) {
    $solrIndexer->addObject(eZContentObject::fetch($object->attribute('id')), false);
}
$solrIndexer->commit();
sleep(2);

$serializer = new \OpenPABootstrapItalia\Anac\Serializer\Art13Serializer();
$riferimenti = $serializer->fetchRiferimentiContatti();

$telefoni = array_map(function ($r) { return $r['recapitoTelefonico'] ?? null; }, $riferimenti);

assert_true(in_array('0587111111', $telefoni, true), "Il contatto proprio dell'organo politico di vertice compare nel risultato");
assert_true(in_array('0587222222', $telefoni, true), "Il contatto proprio dell'area amministrativa di vertice compare nel risultato (richiesta di Marco)");
assert_true(in_array('0587333333', $telefoni, true), "Il contatto di un ufficio discendente compare nel risultato");

$occorrenzeCondiviso = count(array_filter($telefoni, function ($t) { return $t === '0587444444'; }));
assert_eq($occorrenzeCondiviso, 1, "Il contatto dell'organo condiviso da due radici duplicate compare UNA sola volta, non due");

$occorrenzePlaceholder = count(array_filter($telefoni, function ($t) { return $t === '0587555555'; }));
assert_eq($occorrenzePlaceholder, 1, "Lo stesso contatto condiviso da due organi REALMENTE DIVERSI (non radici duplicate) compare UNA sola volta, non una per organo");

echo "\n$PASSED passed, $FAILED failed\n";
$script->shutdown($FAILED > 0 ? 1 : 0);
