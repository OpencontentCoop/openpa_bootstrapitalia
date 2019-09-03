<?php

class OpenPAAttributeIntegerHandler extends OpenPAAttributeHandler
{
    protected function hasContent()
    {
        $hasContent = (int)$this->attribute->attribute( 'data_int' ) > 0;
        if ( $this->is( 'zero_is_content', array( 'ente_controllato/onere_complessivo' ) ) )
        {
            $hasContent = true;
        }        
        if ( $this->is( 'force_has_content', array() ) )
        {
            $hasContent = true;
        }
        return $hasContent;
    }
}