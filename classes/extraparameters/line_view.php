<?php

class OpenPABootstrapItaliaLineViewClassExtraParameters extends OpenPALineViewClassExtraParameters
{
    protected function handleAttributes()
    {
        return false;
    }

    protected function handleCustomAttributes()
    {
        return true;
    }

    protected function getCustomAttributes()
    {
        $attributes = [];
        $attributes[] = OCClassExtraParametersCustomAttribute::create(
            'show_icon',
            'Mostra icona'
        );

        return $attributes;
    }
}