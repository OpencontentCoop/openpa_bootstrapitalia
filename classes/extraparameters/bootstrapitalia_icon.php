<?php

class OpenPABootstrapItaliaIconExtraParameter extends OCClassExtraParametersHandlerBase
{
    const IDENTIFIER = 'bootstrapitalia_icon';

    public function getIdentifier()
    {
        return self::IDENTIFIER;
    }

    public function getName()
    {
        return 'Icona per la classe di contenuto';
    }

    public function attributes()
    {
        $attributes = parent::attributes();
        $attributes[] = 'icon_list';
        $attributes[] = 'icon';
        $attributes[] = 'icon_label';

        return $attributes;
    }

    public function attribute($key)
    {
        switch ($key) {

            case 'icon_list':
                return OpenPABootstrapItaliaIconType::getIconList();

            case 'icon':
                return $this->getClassParameter('icon');

            case 'icon_label':
                return $this->getAttributeIdentifierListByParameter( 'icon_label', 1, false );
        }

        return parent::attribute($key);
    }

    protected function handleAttributes()
    {
        return true;
    }

    protected function classEditTemplateUrl()
    {
        return 'design:openpa/extraparameters/' . $this->getIdentifier() . '/edit_class.tpl';
    }

    protected function attributeEditTemplateUrl()
    {
        return 'design:openpa/extraparameters/' . $this->getIdentifier() . '/edit_attribute.tpl';
    }
}