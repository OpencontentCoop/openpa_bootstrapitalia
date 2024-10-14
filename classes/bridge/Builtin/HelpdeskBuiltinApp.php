<?php

class HelpdeskBuiltinApp extends BuiltinApp
{
    private $isAppEnabled;

    private $serviceObject;

    public function __construct()
    {
        parent::__construct('support', 'Request assistance');
    }

    protected function getAppRootId(): string
    {
        return 'oc-helpdesk';
    }

//    protected function getServiceObject(): ?eZContentObject
//    {
//        if ($this->serviceObject === null) {
//            $this->serviceObject = eZContentObject::fetchByRemoteID('helpdesk');
//        }
//
//        return $this->serviceObject;
//    }

    protected function getServiceId(): ?string
    {
        return 'helpdesk';
    }

    protected function isAppEnabled(): bool
    {
        if ($this->isAppEnabled === null) {
            $contacts = (new OpenPAPageData())->getContactsData();
            $this->isAppEnabled = !(!empty($contacts['link_assistenza'])) && self::getCurrentOptions('TenantUrl');
        }

        return $this->isAppEnabled && !self::getCurrentOptions('EnableHelpdeskV2');
    }

    protected function getDescriptionListItem(): array
    {
        $text = '';
        return [
            'is_enabled' => $this->isAppEnabled(),
            'text' => $text,
        ];
    }
}