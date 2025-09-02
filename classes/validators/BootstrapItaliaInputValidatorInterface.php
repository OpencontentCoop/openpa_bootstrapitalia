<?php

interface BootstrapItaliaInputValidatorInterface
{
    public function initValidator(
        eZHTTPTool $http,
        ?eZModule $module,
        eZContentClass $class,
        eZContentObject $object,
        eZContentObjectVersion $version,
        array $contentObjectAttributes,
        $editVersion,
        $editLanguage,
        $fromLanguage,
        array $validationParameters,
        string $base
    );

    public function validate(): array;
}