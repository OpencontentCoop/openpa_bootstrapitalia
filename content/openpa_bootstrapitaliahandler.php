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

        if (in_array($module->currentAction(), ['Store', 'StoreExit'])){
            return $result;
        }

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
            ) as $validatorName => $validator
        ) {
            $violation = $validator->validate();
            if (!empty($violation)) {
                $result['is_valid'] = false;
                if (isset($violation['items'])) {
                    foreach ($violation['items'] as $item) {
                        eZDebug::writeDebug($validatorName . ' KO: ' . $item['text'], __METHOD__);
                        $result['warnings'][] = $item;
                    }
                } else {
                    eZDebug::writeDebug($validatorName . ' KO: ' . $violation['text'], __METHOD__);
                    $result['warnings'][] = $violation;
                }
            } else {
                eZDebug::writeDebug($validatorName . ' OK', __METHOD__);
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
            foreach ($validatorClassNames as $validatorClassNameAndParameters) {
                if (strpos($validatorClassNameAndParameters, ':') !== false) {
                    [$validatorClassName, $validatorParameters] = explode(':', $validatorClassNameAndParameters);
                }else{
                    $validatorClassName = $validatorClassNameAndParameters;
                    $validatorParameters = null;
                }
                if (class_exists($validatorClassName)) {
                    $validator = $validatorParameters ? new $validatorClassName($validatorParameters) : new $validatorClassName();
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
                        $this->validators[$validatorClassNameAndParameters] = $validator;
                    } else {
                        eZDebug::writeError(
                            sprintf(
                                'Registered validator %s does not implements BootstrapItaliaInputValidatorInterface interface',
                                $validatorClassNameAndParameters
                            )
                        );
                    }
                } else {
                    eZDebug::writeError(
                        sprintf(
                            'Registered validator %s class not found',
                            $validatorClassNameAndParameters
                        )
                    );
                }
            }
        }

        return $this->validators;
    }
}
