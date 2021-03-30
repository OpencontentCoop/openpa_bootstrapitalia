<?php

class OpenPABootstrapItaliaModerationPost extends OpenPABootstrapItaliaAbstractPost implements OCEditorialStuffPostInputActionInterface
{
    public function tabs()
    {
        $templatePath = $this->getFactory()->getTemplateDirectory();
        $tabs = array(
            array(
                'identifier' => 'content',
                'name' => 'Contenuto',
                'template_uri' => "design:{$templatePath}/parts/content.tpl"
            )
        );
        $tabs[] = array(
            'identifier' => 'history',
            'name' => 'Cronologia',
            'template_uri' => "design:{$templatePath}/parts/history.tpl"
        );
        $configuration = $this->getFactory()->getConfiguration();
        if (isset($configuration['RelatedNewsletterList'])) {
            $tabs[] = array(
                'identifier' => 'mailing',
                'name' => 'Mailing List',
                'template_uri' => "design:{$templatePath}/parts/mailing.tpl"
            );
        }
        return $tabs;
    }

    public function onCreate()
    {
        if ($this->currentUserNeedModeration() && $this->getObject()->attribute('current_version') == 1) {
            $states = $this->states();
            $default = 'moderation.draft';
            if (isset($states[$default])) {
                $this->getObject()->assignState($states[$default]);
                eZSearch::addObject($this->object, true);
            }
        }
    }

    public function attributes()
    {
        $attributes = parent::attributes();
        $attributes[] = 'mailing_list';
        $attributes[] = 'mailing_list_url';
        $attributes[] = 'is_published';

        return $attributes;
    }

    public function attribute($property)
    {
        if ($property == 'is_published') {
            return $this->is('accepted');
        }
        if ($property == 'mailing_list') {
            return $this->getMailingList();
        }
        if ($property == 'mailing_list_url') {
            return $this->getMailingListUrl();
        }

        return parent::attribute($property);
    }

    private function getMailingListId()
    {
        $configuration = $this->getFactory()->getConfiguration();
        if (isset($configuration['RelatedNewsletterList'])) {
            return (int)$configuration['RelatedNewsletterList'];
        }

        return 0;
    }

    private function getMailingListUrl()
    {
        $object = eZContentObject::fetch($this->getMailingListId());
        if ($object instanceof eZContentObject) {
            return '/newsletter/subscription_list/' . $object->mainNodeID();
        }

        return false;
    }

    private function getMailingList()
    {
        $list = [];
        $listContentObjectId = $this->getMailingListId();
        $qryGetData = "SELECT 
                          s.id as s_id,
                          u.id as u_id,
                          u.email,
                          u.first_name,
                          u.last_name,
                          u.salutation,
                          u.status as u_status,                              
                          s.status as s_status
                   FROM cjwnl_subscription s, cjwnl_user u
                   WHERE s.list_contentobject_id=$listContentObjectId
                   AND s.newsletter_user_id=u.id
                   AND s.status in (1,2) 
                   AND u.status = 1
                   ORDER BY u.last_name ASC";

        // execute query
        $resQryGetData = eZDB::instance()->arrayQuery($qryGetData);

        if (is_array($resQryGetData) && count($resQryGetData) > 0) {
            $arrKeys = array_keys($resQryGetData[0]);
            array_unshift($resQryGetData, $arrKeys);
            unset($resQryGetData[0]);
            $list = $resQryGetData;
        }

        return $list;
    }

    public function executeAction($actionIdentifier, $actionParameters, eZModule $module = null)
    {
        if ($actionIdentifier == 'ActionSendToMailingList' && $this->attribute('is_published')) {
            $list = $this->getMailingList();
            $emails = [];
            foreach ($list as $item) {
                if (in_array($item['u_id'], $actionParameters) && eZMail::validate($item['email'])) {
                    $emails[] = $item['email'];
                }
            }
            if (!empty($emails)) {
                if ($this->sendMail($emails)) {
                    OCEditorialStuffHistory::addHistoryToObjectId(
                        $this->object->attribute('id'),
                        'sent_to_mailing_list', [
                            'addresses' => $emails,
                            'mailing_list' => $this->getMailingListId()
                        ]
                    );
                }
            }
        }
    }

    private function sendMail($addressList)
    {
        $mail = $this->composeMail();
        $chunks = array_chunk($addressList, 48);
        foreach ($chunks as $chunk) {
            $mail->setBccElements($chunk);
            eZMailTransport::send($mail);
        }
        return true;
    }

    private function composeMail()
    {
        $languages = $this->object->availableLanguages();
        $configuration = $this->getFactory()->getConfiguration();
        $subjectFields = isset($configuration['MailSubjectFields']) ? $configuration['MailSubjectFields'] : [];
        $bodyFields = isset($configuration['MailBodyFields']) ? $configuration['MailBodyFields'] : [];
        $attachmentsFields = isset($configuration['MailAttachmentsFields']) ? $configuration['MailAttachmentsFields'] : [];
        $subjectParts = [];


        $mail = new eZMail();
        $ini = eZINI::instance();
        $emailSender = $ini->variable('MailSettings', 'EmailSender');
        if (!eZMail::validate($emailSender))
            $emailSender = $ini->variable("MailSettings", "AdminEmail");

        $mail->setSender($emailSender);
        $mail->setSubject($subject);
        $mail->setBody($body);
        $mail->setReceiver($emailSender);

        return $mail;
    }
}