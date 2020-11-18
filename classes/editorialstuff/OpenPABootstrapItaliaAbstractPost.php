<?php


abstract class OpenPABootstrapItaliaAbstractPost extends OCEditorialStuffPostDefault
{
    protected function currentUserNeedModeration()
    {
        $configurations = $this->getFactory()->getConfiguration();
        $whiteListGroupRemoteId = isset($configurations['WhiteListGroupRemoteId']) ? $configurations['WhiteListGroupRemoteId'] : 'editors_base';
        $editorsBaseGroup = eZContentObject::fetchByRemoteID($whiteListGroupRemoteId);
        if ($editorsBaseGroup instanceof eZContentObject) {
            $currentUserGroups = eZUser::currentUser()->groups(false);
            if (in_array($editorsBaseGroup->attribute('id'), $currentUserGroups)){
                return false;
            }
        }

        return true;
    }
}