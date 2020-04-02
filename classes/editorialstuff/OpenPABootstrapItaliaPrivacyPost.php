<?php

class OpenPABootstrapItaliaPrivacyPost extends OCEditorialStuffPostDefault
{
    public function tabs()
    {
        $templatePath = $this->getFactory()->getTemplateDirectory();
        $tabs = array(
            array(
                'identifier' => 'content',
                'name' => 'Contenuto',
                'template_uri' => "design:{$templatePath}/parts/content.tpl"
            )
        );
        $tabs[] = array(
            'identifier' => 'history',
            'name' => 'Cronologia',
            'template_uri' => "design:{$templatePath}/parts/history.tpl"
        );
        return $tabs;
    }

    public function onCreate()
    {
        if ($this->getObject()->attribute('current_version') == 1) {
            $states = $this->states();
            $default = 'privacy.private';
            if (isset($states[$default])) {
                $this->getObject()->assignState($states[$default]);
                eZSearch::addObject($this->object, true);
            }
        }
    }

    public function attribute($property)
    {
        if ($property == 'is_published') {
            return $this->is('accepted');
        }

        return parent::attribute($property);
    }
}