<?php

class PaginaSitoLockEditClassConnector extends PageLockEditClassConnector
{
    protected function getEvidenceBlockMaxItems($blockIndex = 1): int
    {
        $objectId = (int)$this->getHelper()->getParameter('object');
        $object = eZContentObject::fetch($objectId);
        if ($object instanceof eZContentObject && (
                $object->remoteID() == 'all-topics' || $object->remoteID() == 'topics'
            )
        ) {
            return 90;
        }
        return 6;
    }
}