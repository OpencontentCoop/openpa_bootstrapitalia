<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;

class TimeIndexedRoleClassConnector extends ClassConnector
{
    public function submit()
    {
        $data = $this->getSubmitData();
        $people = (array)$data['person'];

        $result = parent::submit();

        foreach ($people as $person){
            eZContentOperationCollection::registerSearchObject((int)$person);
        }

        return $result;
    }
}