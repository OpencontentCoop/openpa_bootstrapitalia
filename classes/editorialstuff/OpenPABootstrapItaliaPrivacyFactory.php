<?php

class OpenPABootstrapItaliaPrivacyFactory extends OpenPABootstrapItaliaAbstractFactory implements OpenPABootstrapitaliaAutoRegistrableInterface
{
    public function __construct($configuration)
    {
        parent::__construct($configuration);
        $defaults = eZINI::instance('editorialstuff.ini')->group('_privacy_defaults');
        $this->configuration = array_merge($defaults, $this->configuration);
        $this->setExtraConfigurations();
    }

    public function instancePost($data)
    {
        return new OpenPABootstrapItaliaPrivacyPost($data, $this);
    }

    public function canAutoRegister()
    {
        return isset($this->configuration['AutoRegistration'])
            && $this->configuration['AutoRegistration'] == 'enabled'
            && in_array($this->classIdentifier(), eZUser::fetchUserClassNames())
            && $this->isWorkflowIsActive();
    }

    private function isWorkflowIsActive()
    {
        $workflowTypeString = EditorialStuffType::WORKFLOW_TYPE_STRING;
        $query = "SELECT COUNT(*) FROM ezworkflow_event WHERE workflow_type_string = 'event_{$workflowTypeString}' AND workflow_id IN (SELECT workflow_id FROM eztrigger WHERE name = 'post_publish')";
        $result = eZDB::instance()->arrayQuery($query);

        return $result[0]['count'] > 0;
    }

}