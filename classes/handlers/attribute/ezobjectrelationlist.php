<?php

class OpenPAAttributeRelations extends OpenPAAttributeHandler
{
    protected function fullData()
    {
        $data = parent::fullData();
        $data['show_as_accordion'] = $this->getExtraParameter('show_as_accordion');

        return $data;
    }
}