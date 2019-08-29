<?php

trait OpenPABootstrapItaliaCustomAttributeTrait
{
    protected static $customAttributeServices;

    protected function handleCustomAttributes()
    {
        return true;
    }

    protected function getCustomAttributes()
    {
        $attributes = [];
        foreach ($this->getCustomAttributeClasses() as $class) {
            $attributes[] = OCClassExtraParametersCustomAttribute::create(
                $class::IDENTIFIER,
                $class::LABEL
            );
        }
        return $attributes;
    }

    protected function getCustomAttributeClasses()
    {
        if (self::$customAttributeServices === null) {
            self::$customAttributeServices = array();
            $availableServices = OpenPAINI::variable('ObjectHandlerServices', 'Services', array());
            foreach ($availableServices as $class) {
                if (is_subclass_of($class, 'ObjectHandlerServiceAttribute')) {
                    self::$customAttributeServices[] = $class;
                }
            }
        }

        return self::$customAttributeServices;
    }
}