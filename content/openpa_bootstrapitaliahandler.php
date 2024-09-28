<?php

class openpa_bootstrapitaliaHandler extends eZContentObjectEditHandler
{
    private $validators;

    /**
     * @param eZHTTPTool $http
     * @param eZModule $module
     * @param eZContentClass $class
     * @param eZContentObject $object
     * @param eZContentObjectVersion $version
     * @param eZContentObjectAttribute[] $contentObjectAttributes
     * @param int $editVersion
     * @param string $editLanguage
     * @param string $fromLanguage
     * @param array $validationParameters
     * @return array
     */
    function validateInput(
        $http,
        &$module,
        &$class,
        $object,
        &$version,
        $contentObjectAttributes,
        $editVersion,
        $editLanguage,
        $fromLanguage,
        $validationParameters
    ) {
        $base = 'ContentObjectAttribute';
        $result = parent::validateInput(
            $http,
            $module,
            $class,
            $object,
            $version,
            $contentObjectAttributes,
            $editVersion,
            $editLanguage,
            $fromLanguage,
            $validationParameters
        );

        foreach (
            $this->getRegisteredValidators(
                $http,
                $module,
                $class,
                $object,
                $version,
                $contentObjectAttributes,
                $editVersion,
                $editLanguage,
                $fromLanguage,
                $validationParameters,
                $base
            ) as $validator
        ) {
            $violation = $validator->validate();
            if (!empty($violation)) {
                $result['is_valid'] = false;
                if (isset($violation['items'])) {
                    foreach ($violation['items'] as $item) {
                        eZDebug::writeDebug(get_class($validator) . ' KO: ' . $item['text'], __METHOD__);
                        $result['warnings'][] = $item;
                    }
                } else {
                    eZDebug::writeDebug(get_class($validator) . ' KO: ' . $violation['text'], __METHOD__);
                    $result['warnings'][] = $violation;
                }
            } else {
                eZDebug::writeDebug(get_class($validator) . ' OK', __METHOD__);
            }
        }

        return $result;
    }

    /**
     * @return BootstrapItaliaInputValidatorInterface[]
     */
    private function getRegisteredValidators(
        $http,
        $module,
        $class,
        $object,
        $version,
        $contentObjectAttributes,
        $editVersion,
        $editLanguage,
        $fromLanguage,
        $validationParameters,
        $baseString
    ): array {
        if ($this->validators === null) {
            $this->validators = [];
            $validatorClassNames = OpenPAINI::variable('AttributeHandlers', 'InputValidators', []);
            foreach ($validatorClassNames as $validatorClassName) {
                if (class_exists($validatorClassName)) {
                    $validator = new $validatorClassName();
                    if ($validator instanceof BootstrapItaliaInputValidatorInterface) {
                        $validator->initValidator(
                            $http,
                            $module,
                            $class,
                            $object,
                            $version,
                            $contentObjectAttributes,
                            $editVersion,
                            $editLanguage,
                            $fromLanguage,
                            $validationParameters,
                            $baseString
                        );
                        $this->validators[] = $validator;
                    } else {
                        eZDebug::writeError(
                            sprintf(
                                'Registered validator %s does not implements BootstrapItaliaInputValidatorInterface interface',
                                $validatorClassName
                            )
                        );
                    }
                } else {
                    eZDebug::writeError(
                        sprintf(
                            'Registered validator %s class not found',
                            $validatorClassName
                        )
                    );
                }
            }
        }

        return $this->validators;
    }
}
