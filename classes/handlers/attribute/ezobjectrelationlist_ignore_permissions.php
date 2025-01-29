<?php

class OpenPAAttributeRelationsWithoutPermissionHandler extends OpenPAAttributeHandler
{
    protected function hasContent()
    {
        return $this->attribute->attribute('has_content')
            || $this->is('force_has_content', []);
    }
}