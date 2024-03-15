<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Upsert default images\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();

function parseName($string)
{
    $string = str_replace('-', ' ', $string);
    $string = str_replace('_', ' ', $string);
    $string = ucfirst($string);

    return $string;
}

function parseRemoteId($string)
{
    $string = parseName($string);
    $parts = explode('.', $string);

    return 'img-' . strtolower(\eZCharTransform::instance()->transformByGroup($parts[0], 'urlalias'));
}

$defaults = [
    'https://s3-eu-west-1.amazonaws.com/static.opencity.opencontent.it/installer/Consiglio-comunale.jpg',
    'https://s3-eu-west-1.amazonaws.com/static.opencity.opencontent.it/installer/Giunta-comunale.jpg',
    'https://s3-eu-west-1.amazonaws.com/static.opencity.opencontent.it/installer/Il-nuovo-modello-di-sito-web-comunale.png',
    'https://s3-eu-west-1.amazonaws.com/static.opencity.opencontent.it/installer/competenze-digitali.png',
    'https://s3-eu-west-1.amazonaws.com/static.opencity.opencontent.it/installer/comuni-2022.png',
    'https://s3-eu-west-1.amazonaws.com/static.opencity.opencontent.it/installer/kit_architettura.png',
    'https://s3-eu-west-1.amazonaws.com/static.opencity.opencontent.it/installer/opencityitalia.png',
    'https://s3-eu-west-1.amazonaws.com/static.opencity.opencontent.it/installer/sindaco.jpg',
    'https://s3-eu-west-1.amazonaws.com/static.opencity.opencontent.it/installer/viale-alberato.jpg',
    'https://s3-eu-west-1.amazonaws.com/static.opencity.opencontent.it/installer/digitale.jpg',
];

foreach ($defaults as $url){
    $cli->output($url . ' -> ' , false);
    $name = parseName(basename($url));
    $remoteId = parseRemoteId(basename($url));
    $data = file_get_contents($url);

    $alreadyExists = \eZContentObject::fetchByRemoteID($remoteId);

    $contentRepository = new ContentRepository();
    $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));
    $content = [
        'metadata' => [
            'remoteId' => $remoteId,
            'classIdentifier' => 'image',
            'parentNodes' => [51],
        ],
        'data' => [
            'name' => $name,
            'author' => "Autore sconosciuto",
            'license' => ["Licenza sconosciuta"],
            'image' => [
                'filename' => basename($url),
                'file' => base64_encode($data),
            ],
        ],
    ];
    $result = $contentRepository->createUpdate($content, true);
    $cli->output($result['message']);
}

$script->shutdown();