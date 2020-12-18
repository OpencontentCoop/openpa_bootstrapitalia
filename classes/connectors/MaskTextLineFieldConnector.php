<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector;

class MaskTextLineFieldConnector extends FieldConnector
{
    public function getData()
    {
        if ($this->isDisplay()){
            return parent::getData();
        }

        $rawContent = $this->getContent();
        return $rawContent ? $rawContent['data_text'] : null;
    }

    public function getOptions()
    {
        return array(
            "helper" => $this->attribute->attribute('description'),
        );
    }

    private function isDisplay()
    {
        return $this->getHelper()->hasParameter('view') && $this->getHelper()->getParameter('view') == 'display';
    }
}