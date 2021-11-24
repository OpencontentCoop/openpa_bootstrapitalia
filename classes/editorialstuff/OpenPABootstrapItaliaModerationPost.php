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

    public function executeAction($actionIdentifier, $actionParameters, eZModule $module = null)
    {
        if ($actionIdentifier == 'ActionSendToMailingList' && $this->attribute('is_published')) {
            $tpl = eZTemplate::factory();
            $tpl->setVariable('factory_identifier', $this->getFactory()->identifier());
            $tpl->setVariable('post', $this);
            $list = $this->getMailingList();
            $emails = [];
            foreach ($list as $item) {
                if (in_array($item['u_id'], $actionParameters['users']) && eZMail::validate($item['email'])) {
                    $emails[$item['u_id']] = $item['email'];
                }
            }
            $language = $actionParameters['language'];
            $tpl->setVariable('emails', $emails);
            $tpl->setVariable('language', $language);
            if (class_exists('ezxFormToken')) {
                $tpl->setVariable('token_field', ezxFormToken::FORM_FIELD);
                $tpl->setVariable('token', ezxFormToken::getToken());
            }
            echo $tpl->fetch('design:editorialstuff/send_confirmation.tpl');
            eZExecution::cleanExit();

        }

        if ($actionIdentifier == 'ActionDoSendToMailingList' && $this->attribute('is_published')) {
            $list = $this->getMailingList();
            $emails = [];
            foreach ($list as $item) {
                if (in_array($item['u_id'], (array)$actionParameters['users']) && eZMail::validate($item['email'])) {
                    $emails[] = $item['email'];
                }
            }
            $language = $actionParameters['language'];
            if (!empty($emails) && !empty($language)) {
                if ($this->sendMail($language, $emails)) {
                    OCEditorialStuffHistory::addHistoryToObjectId(
                        $this->object->attribute('id'),
                        'sent_to_mailing_list', [
                            'addresses' => $emails,
                            'mailing_list' => $this->getMailingListId(),
                            'language' => $language
                        ]
                    );
                }
            }
        }
    }

    public function attribute($property)
    {
        if ($property == 'is_published') {
            return $this->is('accepted') || $this->is('skipped');
        }
        if ($property == 'mailing_list') {
            return $this->getMailingList();
        }
        if ($property == 'mailing_list_url') {
            return $this->getMailingListUrl();
        }

        return parent::attribute($property);
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

    /**
     * @return int
     */
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

    /**
     * @param string $language
     * @param array $addressList
     * @return bool
     */
    private function sendMail($language, $addressList)
    {
        try {
            $mail = new eZMail();
            $mail->Mail = $this->composeMail($language);
            $chunks = array_chunk($addressList, 48);
            foreach ($chunks as $chunk) {
                $addresses = [];
                foreach ($chunk as $value) {
                    $addresses[] = ['email' => $value];
                }
                $mail->setBccElements($addresses);
                eZMailTransport::send($mail);
            }
            return true;
        } catch (Exception $e) {
            eZDebug::writeError($e->getMessage(), __METHOD__);
            return false;
        }
    }

    /**
     * @param string $language
     * @return ezcMailComposer
     * @throws ezcBaseFileNotFoundException
     */
    private function composeMail($language)
    {
        $ini = eZINI::instance();
        $emailSender = $ini->variable('MailSettings', 'EmailSender');
        if (!eZMail::validate($emailSender))
            $emailSender = $ini->variable("MailSettings", "AdminEmail");

        $mail = new ezcMailComposer();
        $mail->from = new ezcMailAddress($emailSender);
        $mail->subject = $this->composeSubject($language);
        $body = $this->composeBody($language);
        $mail->plainText = wordwrap(strip_tags($body), 80, "\n");
        $mail->htmlText = str_replace('=====', '', nl2br($body));
        foreach ($this->composeAttachments($language) as $file) {
            $mail->addFileAttachment($file);
        }
        $mail->build();

        return $mail;
    }

    private function composeSubject($currentLanguage)
    {
        $configuration = $this->getFactory()->getConfiguration();
        $subjectFields = isset($configuration['MailSubjectFields']) ? $configuration['MailSubjectFields'] : [];
        if (empty($subjectFields)) {
            return implode('/', $this->object->names());
        }

        $subjects = [];
        foreach ($this->object->availableLanguages() as $language) {
            if ($language == $currentLanguage) {
                $dataMap = $this->object->fetchDataMap(false, $language);
                $localizeSubjects = [];
                foreach ($subjectFields as $field) {
                    if (isset($dataMap[$field]) && $dataMap[$field]->hasContent()) {
                        $localizeSubjects[] = $this->getAttributeAsMailString($dataMap[$field]);
                    }
                }
                $subjects[] = implode(' ', $localizeSubjects);
            }
        }

        return implode('/', $subjects);
    }

    private function getAttributeAsMailString(eZContentObjectAttribute $attribute)
    {
        $content = $attribute->content();

        if ($content instanceof eZXMLText){
            return str_replace('&nbsp;', ' ', $content->attribute('output')->attribute('output_text'));
        }

        if ($content instanceof eZTags) {
            return $content->keywordString(', ');
        }

        if ($content instanceof eZDate || $content instanceof eZDateTime) {
            return $content->toString(true);
        }

        return $attribute->toString();
    }

    private function composeBody($currentLanguage)
    {
        $configuration = $this->getFactory()->getConfiguration();
        $bodyFields = isset($configuration['MailBodyFields']) ? $configuration['MailBodyFields'] : [];

        $bodies = [];
        foreach ($this->object->availableLanguages() as $language) {
            if ($language == $currentLanguage) {
                $dataMap = $this->object->fetchDataMap(false, $language);
                $localizeBodies = [];
                foreach ($bodyFields as $field) {
                    if (isset($dataMap[$field]) && $dataMap[$field]->hasContent()) {
                        $localizeBodies[] = $this->getAttributeAsMailString($dataMap[$field]);
                    }
                }
                $bodies[] = implode("\n", $localizeBodies);
            }
        }

        $ini = eZINI::instance();
        if ($ini->hasVariable('RegionalSettings', 'TranslationSA')) {
            $translationSiteAccesses = $ini->variable('RegionalSettings', 'TranslationSA');
            foreach ($translationSiteAccesses as $siteAccessName => $translationName) {
                $saIni = eZSiteAccess::getIni($siteAccessName);
                $locale = $saIni->variable('RegionalSettings', 'ContentObjectLocale');
                if ($locale == $currentLanguage) {
                    $host = $saIni->variable('SiteSettings', 'SiteURL');
                    $host = eZSys::serverProtocol() . "://" . $host;
                    $bodies[] = $host . '/' . eZURLAliasML::cleanURL('content/view/full/' . $this->object->mainNodeID());
                    break;
                }
            }
        } else {
            $fullUrl = eZURLAliasML::cleanURL('content/view/full/' . $this->object->mainNodeID());
            eZURI::transformURI($fullUrl, false, 'full');
            $bodies[] = $fullUrl;
        }

        return implode("\n=====\n", $bodies);
    }

    private function composeAttachments($currentLanguage)
    {
        $configuration = $this->getFactory()->getConfiguration();
        $attachmentsFields = isset($configuration['MailAttachmentsFields']) ? $configuration['MailAttachmentsFields'] : [];
        $attachments = [];
        foreach ($this->object->availableLanguages() as $language) {
            if ($language == $currentLanguage) {
                $dataMap = $this->object->fetchDataMap(false, $language);
                foreach ($attachmentsFields as $field) {
                    if (isset($dataMap[$field]) && $dataMap[$field]->hasContent()) {
                        $this->getAttributeAsMailAttachment($dataMap[$field], $attachments);
                    }
                }
            }
        }
        return array_unique($attachments);
    }

    private function getAttributeAsMailAttachment(eZContentObjectAttribute $attribute, &$attachments)
    {
        switch ($attribute->attribute('data_type_string')) {
            case eZObjectRelationListType::DATA_TYPE_STRING:
                $relationList = OpenPABase::fetchObjects(explode('-', $attribute->toString()));
                foreach ($relationList as $related) {
                    $dataMap = $related->dataMap();
                    if (isset($dataMap['image']) && $dataMap['image']->hasContent()) {
                        $this->getAttributeAsMailAttachment($dataMap['image'], $attachments);
                    }
                }
                break;

            case eZImageType::DATA_TYPE_STRING:
                /** @var eZImageAliasHandler $content */
                $content = $attribute->content();
                $original = $content->attribute('original');
                $filePath = $original['full_path'];
                eZClusterFileHandler::instance($filePath)->fetch();
                $attachments[] = $filePath;
                break;

            case eZBinaryFileType::DATA_TYPE_STRING:
                /** @var eZBinaryFile $content */
                $content = $attribute->content();
                $filePath = $content->filePath();
                eZClusterFileHandler::instance($filePath)->fetch();
                $attachments[] = $filePath;
                break;

            case OCMultiBinaryType::DATA_TYPE_STRING:
                /** @var eZMultiBinaryFile[] $contents */
                $contents = $attribute->content();
                foreach ($contents as $content) {
                    $filePath = $content->filePath();
                    eZClusterFileHandler::instance($filePath)->fetch();
                    $attachments[] = $filePath;
                }
                break;
        }
    }
}
