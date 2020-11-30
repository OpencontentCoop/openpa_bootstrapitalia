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

    public function onRegister(OCEditorialStuffPost $post)
    {
        if (!$this->canAutoRegister()) {
            return false;
        }

        $ini = eZINI::instance();
        $tpl = eZTemplate::factory();
        $hostname = eZSys::hostname();
        $user = eZUser::fetch($post->id());

        if ($user instanceof eZUser) {

            $mail = new eZMail();
            $tpl->resetVariables();
            $tpl->setVariable('user', $user);
            $tpl->setVariable('object', $post->getObject());
            $tpl->setVariable('hostname', $hostname);

            $templateResult = $tpl->fetch('design:user/registrationfeedback.tpl');

            if ($tpl->hasVariable('content_type')) {
                $mail->setContentType($tpl->variable('content_type'));
            }

            $emailSender = $ini->variable('MailSettings', 'EmailSender');
            if ($tpl->hasVariable('email_sender')) {
                $emailSender = $tpl->variable('email_sender');
            } else if (!$emailSender) {
                $emailSender = $ini->variable('MailSettings', 'AdminEmail');
            }
            $mail->setSender($emailSender);

            $receiverId = isset($this->configuration['AutoRegistrationNotificationReceiver']) ? $this->configuration['AutoRegistrationNotificationReceiver'] : 0;
            if ($receiverId === 0) {
                $feedbackReceiver = $ini->variable('UserSettings', 'RegistrationEmail');
                if ($tpl->hasVariable('email_receiver')) {
                    $feedbackReceiver = $tpl->variable('email_receiver');
                } else if (!$feedbackReceiver) {
                    $feedbackReceiver = $ini->variable('MailSettings', 'AdminEmail');
                }
                $mail->setReceiver($feedbackReceiver);
            }else{
                if (strpos($receiverId, 'group-') === false) {
                    $user = eZUser::fetch((int)$receiverId);
                    if ($user instanceof eZUser) {
                        $mail->setReceiver($user->attribute('email'));
                    }
                }else{
                    $receiverId = str_replace('group-', '', $receiverId);
                    $groupLocation = eZContentObjectTreeNode::fetch((int)$receiverId);
                    if ($groupLocation instanceof eZContentObjectTreeNode) {
                        $userClasses = eZUser::contentClassIDs();
                        $children = $groupLocation->subTree(
                            array(
                                'ClassFilterType' => 'include',
                                'ClassFilterArray' => $userClasses,
                                'Limitation' => array(),
                                'AsObject' => false
                            )
                        );
                        foreach ($children as $child) {
                            $id = isset($child['contentobject_id']) ? $child['contentobject_id'] : $child['id'];
                            $user = eZUser::fetch($id);
                            if ($user instanceof eZUser) {
                                $mail->setReceiver($user->attribute('email'));
                            }
                        }
                    }
                }
            }

            if ($tpl->hasVariable('subject')) {
                $mail->setSubject($tpl->variable('subject'));
            } else {
                $mail->setSubject(ezpI18n::tr('kernel/user/register', 'New user registered'));
            }

            $mail->setBody($templateResult);

            return eZMailTransport::send($mail);
        }

        return false;
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