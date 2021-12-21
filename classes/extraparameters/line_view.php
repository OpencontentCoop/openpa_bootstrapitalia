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
        $attributes[] = OCClassExtraParametersCustomAttribute::create(
            'disable_video',
            'Visualizza anteprima video'
        );
        $attributes[] = OCClassExtraParametersCustomAttribute::create(
            'disable_video_player',
            'Espone il player video nell\'anteprima'
        );

        return $attributes;
    }

    public function storeParameters( $data )
    {
        parent::storeParameters( $data );
        OpenPAINI::clearDynamicIniCache();
        eZContentCacheManager::clearAllContentCache(true);
    }
}
