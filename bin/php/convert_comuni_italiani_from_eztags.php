<?php

require 'autoload.php';

$script = eZScript::instance([
        'description' => "",
        'use-session' => false,
        'use-modules' => true,
        'use-extensions' => true,
    ]
);

$script->startup();

$options = $script->getOptions('[class:][attribute:]',
    '',
    array(
        'class' => 'Identificatore della classe',
        'attribute' => "Identificatore dell'attributo"
    )
);

$script->initialize();
$script->setUseDebugAccumulators(true);

try {

    if (isset($options['class'], $options['attribute'])){
        $class = eZContentClass::fetchByIdentifier($options['class']);
        if ($class instanceof eZContentClass) {
            $attributes = $class->dataMap();
            $attributeClass = $attributes[$options['attribute']];
            OpenPAComuniItaliani::convertClassAttributeFromEzTags($attributeClass);
        }
    }else {
        OpenPAComuniItaliani::convertFromEzTags();
    }
    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}
