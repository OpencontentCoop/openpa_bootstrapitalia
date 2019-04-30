<?php

class OpenPABootstrapItaliaTableViewClassExtraParameters extends OpenPATableViewClassExtraParameters
{
    use OpenPABootstrapItaliaCustomAttributeTrait;

    public function getName()
    {
        return "Visualizzazione degli attributi nella pagina di contenuto";
    }

    public function attributes()
    {
        $attributes = parent::attributes();
        $attributes[] = 'in_overview';
        $attributes[] = 'main_image';

        return $attributes;
    }

    public function attribute( $key )
    {
        switch( $key )
        {
            case 'in_overview':
                return $this->getAttributeIdentifierListByParameter( 'in_overview', 1, false );

            case 'main_image':
                return $this->getAttributeIdentifierListByParameter( 'main_image', 1, false );
        }

        return parent::attribute( $key );
    }
}