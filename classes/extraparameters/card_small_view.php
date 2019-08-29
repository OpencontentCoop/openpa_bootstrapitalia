<?php

class OpenPABootstrapItaliaCardSmallViewClassExtraParameters extends OpenPALineViewClassExtraParameters
{
    public function getIdentifier()
    {
        return 'card_small_view';
    }

    public function getName()
    {
        return "Visualizzazione degli attributi nella vista embed (template card-teaser)";
    }

    protected function handleCustomAttributes()
    {
        return true;
    }

    protected function getCustomAttributes()
    {
        $attributes = [
            OCClassExtraParametersCustomAttribute::create(
                'content_show_read_more',
                'Mostra link "Ulteriori dettagli"'
            )
        ];

        return $attributes;
    }
}