<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Fix document location\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();

$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

$parentNodes = [];
function getNodeIdFromRemoteId($remoteId): int
{
    global $parentNodes;
    if (!isset($parentNodes[$remoteId])) {
        $object = eZContentObject::fetchByRemoteID($remoteId);
        if (!$object instanceof eZContentObject) {
            throw new Exception("Object by remote $remoteId not found");
        }
        $parentNodes[$remoteId] = (int)$object->mainNodeID();
    }

    return $parentNodes[$remoteId];
}

function discoverParentNode($type): int
{
    $containers = [
        "Documenti albo pretorio" => 'b5cd50ff40706b1520e7b56fb4d18481',
        "Modulistica" => 'cfd0a916ca48eb7d4a78bb6beb7821f9',
        "Documenti funzionamento interno" => '76f8688f740d2f10c9e754305f16a546',
        "Normative" => '68a7f7f6dbc9b55b007918d6c04ce0e0',
        "Accordi tra enti" => '0b04fbb06981a2a30ca8d5516b636f48',
        "Documenti attività politica" => '2ae121d5e5b04047d990d15723a36675',
        "Documenti (tecnici) di supporto" => '972395281b6c293f05e8c6ce52b5643d',
        "Dataset" => 'dataset',
        "Documenti di programmazione e rendicontazione" => 'doc_progamma_rendiconto',
    ];

    $map = [
        "Documenti Albo Pretorio" => "Documenti albo pretorio",
        "Atto amministrativo" => "Documenti albo pretorio",
        "Decreto" => "Documenti albo pretorio",
        "Decreto del Dirigente" => "Documenti albo pretorio",
        "Decreti del Dirigente" => "Documenti albo pretorio",
        "Decreto del Sindaco" => "Documenti albo pretorio",
        "Deliberazione" => "Documenti albo pretorio",
        "Deliberazione del Commissario ad acta" => "Documenti albo pretorio",
        "Deliberazione del Consiglio circoscrizionale" => "Documenti albo pretorio",
        "Deliberazione del Consiglio comunale" => "Documenti albo pretorio",
        "Deliberazione consiliare" => "Documenti albo pretorio",
        "Deliberazione dell'Esecutivo circoscrizionale" => "Documenti albo pretorio",
        "Deliberazione della Giunta comunale" => "Documenti albo pretorio",
        "Deliberazione di altri Organi" => "Documenti albo pretorio",
        "Determinazione" => "Documenti albo pretorio",
        "Determinazione del Dirigente" => "Documenti albo pretorio",
        "Determinazione del Sindaco" => "Documenti albo pretorio",
        "Ordinanza" => "Documenti albo pretorio",
        "Ordinanza del Dirigente" => "Documenti albo pretorio",
        "Ordinanza del Sindaco" => "Documenti albo pretorio",
        "Atto autorizzativo" => "Documenti albo pretorio",
        "Permesso a costruire" => "Documenti albo pretorio",
        "Atto dello stato civile" => "Documenti albo pretorio",
        "Provvedimento di cancellazione per irreperibilità" => "Documenti albo pretorio",
        "Pubblicazione cambio nome" => "Documenti albo pretorio",
        "Pubblicazione di matrimonio" => "Documenti albo pretorio",
        "Atto generico" => "Documenti albo pretorio",
        "Avviso" => "Documenti albo pretorio",
        "Avviso/Manifesto" => "Documenti albo pretorio",
        "Bando" => "Documenti albo pretorio",
        "Pubblicazione esterna" => "Documenti albo pretorio",
        "Atto di terzi" => "Documenti albo pretorio",
        "Modulistica" => "Modulistica",
        "Documenti funzionamento interno" => "Documenti funzionamento interno",
        "Circolare" => "Documenti funzionamento interno",
        "Disciplinare" => "Documenti funzionamento interno",
        "Procedura" => "Documenti funzionamento interno",
        "Regolamento" => "Documenti funzionamento interno",
        "Statuto" => "Documenti funzionamento interno",
        "Trattamento" => "Documenti funzionamento interno",
        "Atti normativi" => "Normative",
        "Normative" => "Normative",
        "Normativa" => "Normative",
        "Accordi tra enti" => "Accordi tra enti",
        "Accordo" => "Accordi tra enti",
        "Accordi" => "Accordi tra enti",
        "Convenzione" => "Accordi tra enti",
        "Convenzioni" => "Accordi tra enti",
        "Parere" => "Accordi tra enti",
        "Partnership" => "Accordi tra enti",
        "Documenti attività politica" => "Documenti attività politica",
        "Interpellanza" => "Documenti attività politica",
        "Interrogazione" => "Documenti attività politica",
        "Mozione" => "Documenti attività politica",
        "Ordine del giorno" => "Documenti attività politica",
        "Seduta del consiglio" => "Documenti attività politica",
        "Documenti di programmazione e rendicontazione" => "Documenti (tecnici) di supporto",
        "Bilancio consuntivo" => "Documenti di programmazione e rendicontazione",
        "Bilancio preventivo" => "Documenti di programmazione e rendicontazione",
        "Documento unico di programmazione" => "Documenti di programmazione e rendicontazione",
        "Piano Esecutivo di Gestione" => "Documenti di programmazione e rendicontazione",
        "Rendiconto" => "Documenti di programmazione e rendicontazione",
        "Documenti (tecnici) di supporto" => "Documenti (tecnici) di supporto",
        "Piano/Progetto" => "Documenti di programmazione e rendicontazione",
        "Pubblicazione" => "Documenti (tecnici) di supporto",
        "Rapporto" => "Documenti di programmazione e rendicontazione",
    ];

    if (isset($map[$type])) {
        return getNodeIdFromRemoteId($containers[$map[$type]]);
    }

    if (stripos($type, 'bando') !== false) {
        return getNodeIdFromRemoteId($containers['Documenti albo pretorio']);
    }

    return false;
}

try {
    $documentiObject = eZContentObject::fetchByRemoteID('cb945b1cdaad4412faaa3a64f7cdd065'); // Documenti e dati
    if ($documentiObject instanceof eZContentObject) {
        $documenti = $documentiObject->mainNode();

        /** @var eZContentObjectTreeNode $child */
        foreach ($documenti->children() as $child) {
            if ($child->attribute('class_identifier') === 'document') {
                $dataMap = $child->dataMap();
                $keywords = $dataMap['document_type']->content()->attribute('keywords');
                $keywordsAsString = implode(', ', $keywords);
                $location = discoverParentNode($keywords[0]);
                if (!$location) {
                    $cli->warning(
                        '[' . $keywordsAsString . '] ' . $child->attribute('contentobject_id') . ' ' . $child->attribute('name') . ' ???'
                    );
                } else {
                    $cli->output(
                        '[' . $keywordsAsString . '] ' . $child->attribute('contentobject_id') . ' ' . $child->attribute('name') . ' -> ' . $location
                    );
                    $contentRepository = new \Opencontent\Opendata\Api\ContentRepository();
                    $contentRepository->move($child->attribute('contentobject_id'), $location, true);
                }
            }
        }
    }
    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}