<?php

class OpenPABootstrapItaliaPrivacyPost extends OpenPABootstrapItaliaAbstractPost implements OCEditorialStuffPostInputActionInterface
{
    public function tabs()
    {
        $templatePath = $this->getFactory()->getTemplateDirectory();
        $tabs = [
            [
                'identifier' => 'content',
                'name' => 'Contenuto',
                'template_uri' => "design:{$templatePath}/parts/content.tpl",
            ],
        ];
        if ($this->hasAutoRegistrableFactory()) {
            $tabs[] = [
                'identifier' => 'private_mail',
                'name' => 'Invia un messaggio',
                'template_uri' => "design:{$templatePath}/parts/private_mail.tpl",
            ];
        }
        $tabs[] = [
            'identifier' => 'history',
            'name' => 'Cronologia',
            'template_uri' => "design:{$templatePath}/parts/history.tpl",
        ];
        return $tabs;
    }

    private function hasAutoRegistrableFactory()
    {
        $factory = $this->getFactory();
        if ($factory instanceof OpenPABootstrapitaliaAutoRegistrableInterface) {
            return $factory->canAutoRegister();
        }

        return false;
    }

    public function onCreate()
    {
        $this->updateOwner();
        if ($this->hasAutoRegistrableFactory()) {
            $factory = $this->getFactory();
            if ($factory instanceof OpenPABootstrapitaliaAutoRegistrableInterface) {
                $factory->onRegister($this);
            }
        }
        if ($this->currentUserNeedModeration() && $this->getObject()->attribute('current_version') == 1) {
            $states = $this->states();
            $default = 'privacy.private';
            if (isset($states[$default])) {
                $this->getObject()->assignState($states[$default]);
                $this->disableUser();
                $this->flushObject();
                eZSearch::addObject($this->getObject(), true);
            }
        }
    }

    private function updateOwner()
    {
        if ($this->hasAutoRegistrableFactory()) {
            if ($this->getObject()->attribute('owner_id') != $this->id()) {
                $this->getObject()->setAttribute('owner_id', $this->id());
                $this->getObject()->store();
            }
        }
    }

    private function disableUser()
    {
        if ($this->hasAutoRegistrableFactory()) {
            $userSetting = eZUserSetting::fetch($this->id());
            if ($userSetting instanceof eZUserSetting) {
                if ($userSetting->attribute("is_enabled") != 0) {
                    eZContentCacheManager::clearContentCacheIfNeeded($this->id());
                    eZContentCacheManager::generateObjectViewCache($this->id());
                }
                $userSetting->setAttribute("is_enabled", 0);
                $userSetting->store();
            }
        }
    }

    public function onUpdate()
    {
        $this->updateOwner();
    }

    public function onChangeState(eZContentObjectState $beforeState, eZContentObjectState $afterState)
    {
        if ($afterState->attribute('identifier') == 'private') {
            $this->disableUser();
            $this->flushObject();
        } elseif ($afterState->attribute('identifier') == 'public') {
            $this->enableUser();
            $this->flushObject();
            $this->emitPostPublishWebhook();
        }

        if ($beforeState->attribute('identifier') != $afterState->attribute('identifier')) {
            $this->setObjectLastModified();
        }

        return parent::onChangeState($beforeState, $afterState);
    }

    private function enableUser()
    {
        if ($this->hasAutoRegistrableFactory()) {
            $userSetting = eZUserSetting::fetch($this->id());
            if ($userSetting instanceof eZUserSetting) {
                if ($userSetting->attribute("is_enabled") != 1) {
                    eZContentCacheManager::clearContentCacheIfNeeded($this->id());
                    eZContentCacheManager::generateObjectViewCache($this->id());
                }
                $userSetting->setAttribute("is_enabled", 1);
                $userSetting->store();
            }
        }
    }

    private function getUser()
    {
        return eZUser::fetch($this->id());
    }

    public function attribute($property)
    {
        if ($property == 'is_published') {
            return $this->is('public');
        }

        return parent::attribute($property);
    }

    public function executeAction($actionIdentifier, $actionParameters, eZModule $module = null)
    {
        if ($actionIdentifier == 'ActionSendPrivateMessage'){
            $subject = $actionParameters['subject'];
            $text = $actionParameters['text'];
            if (!empty($text) && !empty($subject)){
                try {
                    $this->sendMessage($subject, $text);
                    OCEditorialStuffHistory::addHistoryToObjectId(
                        $this->object->attribute('id'),
                        'sent_private_message', [
                            'address' => $this->getUser()->attribute('email'),
                            'subject' => $subject,
                            'text' => $text,
                        ]
                    );
                }catch (Exception $e){
                    OCEditorialStuffHistory::addHistoryToObjectId(
                        $this->object->attribute('id'),
                        'fail_sent_private_message', [
                            'text' => $text,
                            'subject' => $subject,
                            'error' => $e->getMessage(),
                        ]
                    );
                }
            }
        }
    }

    private function sendMessage($subject, $text)
    {
        $user = $this->getUser();
        if (!$user instanceof eZUser){
            throw new Exception('User not found');
        }
        if (!eZMail::validate($user->attribute('email'))){
            throw new Exception('Invalid user email');
        }

        $ini = eZINI::instance();
        $emailSender = $ini->variable('MailSettings', 'EmailSender');
        if (!eZMail::validate($emailSender))
            $emailSender = $ini->variable("MailSettings", "AdminEmail");

        $mail = new ezcMailComposer();
        $mail->from = new ezcMailAddress($emailSender);
        $mail->subject = $subject;
        $mail->plainText = wordwrap($text, 80, "\n");
        $mail->htmlText = nl2br($text);
        $mail->build();

        $ezMail = new eZMail();
        $ezMail->Mail = $mail;
        $ezMail->setReceiver($user->attribute('email'));
        if (!eZMailTransport::send($ezMail)){
            throw new Exception('Transport unhandled exception');
        }
    }

}
