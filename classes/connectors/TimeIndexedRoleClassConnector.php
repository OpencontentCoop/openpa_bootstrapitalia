<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;

class TimeIndexedRoleClassConnector extends ClassConnector
{
    public function submit()
    {
        $data = $this->getSubmitData();
        $people = (array)$data['person'];

        $result = parent::submit();

        foreach ($people as $person) {
            $id = isset($person['id']) ? $person['id'] : $person;
            eZContentOperationCollection::registerSearchObject((int)$id);
        }

        return $result;
    }
}