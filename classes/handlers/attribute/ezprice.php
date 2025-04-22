<?php

class OpenPAAttributePriceHandler extends OpenPAAttributeHandler
{
    protected function hasContent()
    {
        $hasContent = $this->attribute->attribute('data_float') > 0;
        if ($this->is('zero_is_content')) {
            $hasContent = true;
        }
        if ($this->is('force_has_content')) {
            $hasContent = true;
        }
        return $hasContent;
    }
}
