<?php
require 'autoload.php';

$script = eZScript::instance( array( 'description' => ( "Remap menu remote_id\n\n" ),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true ) );

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators( true );
$cli = eZCLI::instance();
try
{
    $map = [
        'amministrazione' => 'management', // Amministrazione
        '37e90c85e11e1c2b7889c74cfb54845e' => 'news', // Novità
        'b04a731ca8cc79de8b7cf9f6c2f37705' => 'all-services', // Servizi
        //'topics' => 'all-topics', // Argomenti
    ];

    foreach ($map as $old => $new){
        $oldObj = eZContentObject::fetchByRemoteID($old);
        if ($oldObj instanceof eZContentObject) {
            $newObj = eZContentObject::fetchByRemoteID($new);
            if ($newObj instanceof eZContentObject){
                $cli->error("Object $new already exists");
            }else{
                $oldObj->setAttribute('remote_id', $new);
                $oldObj->store();
            }
        }else{
            $cli->error("Object $old not found");
        }
    }

    $script->shutdown();
}
catch( Exception $e )
{
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown( $errCode, $e->getMessage() );
}