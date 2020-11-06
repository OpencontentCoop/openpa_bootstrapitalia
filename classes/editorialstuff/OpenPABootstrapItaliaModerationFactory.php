<?php

class OpenPABootstrapItaliaModerationFactory extends OpenPABootstrapItaliaAbstractFactory
{
    public function __construct($configuration)
    {
        parent::__construct($configuration);
        $defaults = eZINI::instance('editorialstuff.ini')->group('_moderation_defaults');
        $this->configuration = array_merge($defaults, $this->configuration);
        $this->setExtraConfigurations();
    }

    public function instancePost($data)
    {
        return new OpenPABootstrapItaliaModerationPost($data, $this);
    }

}