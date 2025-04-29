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
        $attributes[] = 'show_as_accordion';

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

            case 'show_as_accordion':
                return $this->getAttributeIdentifierListByParameter( 'show_as_accordion', 1, false  );
        }

        return parent::attribute( $key );
    }

    public function storeParameters( $data )
    {
        if (is_array($data['class_attribute'])) {
            foreach ($data['class_attribute'] as $classIdentifier => $attributeParams) {
                foreach ($attributeParams as $attributesIdentifier => $params) {
                    foreach ($params as $key => $value) {
                        if ($key == 'show_link' && $value == 2) {
                            $data['class_attribute'][$classIdentifier][$attributesIdentifier]['show_link'] = 1;
                            $data['class_attribute'][$classIdentifier][$attributesIdentifier]['show_as_accordion'] = 1;
                        }
                    }
                }
            }
        }

        parent::storeParameters( $data );
    }
}