<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector;

class OpenPAAlboSequentialFieldConnector extends FieldConnector
{
    public function getData()
    {
        $data = parent::getData();
        return $this->isDisplay() ? $data : (bool)$data;
    }

    public function getSchema()
    {
        $data = parent::getSchema();
        $data['type'] = $this->isDisplay() ? "string" : "boolean";

        return $data;
    }

    public function getOptions()
    {
        return $this->isDisplay() ? parent::getOptions() : array(
            "helper" => $this->attribute->attribute('description'),
            'type' => 'checkbox',
            'disabled' => !empty(parent::getData()),
            'rightLabel' => $this->attribute->attribute('name')
        );
    }

    public function setPayload($postData)
    {
        return $postData === 'true';
    }

    private function isDisplay()
    {
        return $this->getHelper()->hasParameter('view') && $this->getHelper()->getParameter('view') == 'display';
    }
}