<?php

class OpenPABootstrapItaliaPrivacyPost extends OpenPABootstrapItaliaAbstractPost
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
        return $tabs;
    }

    public function onCreate()
    {
        $this->updateOwner();
        if ($this->hasAutoRegistrableFactory()) {
            $factory = $this->getFactory();
            if ($factory instanceof OpenPABootstrapitaliaAutoRegistrableInterface) {
                return $factory->onRegister($this);
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
        }

        if ($beforeState->attribute('identifier') != $afterState->attribute('identifier')) {
            $this->setObjectLastModified();
        }

        return parent::onChangeState($beforeState, $afterState);
    }

    public function attribute($property)
    {
        if ($property == 'is_published') {
            return $this->is('accepted');
        }

        return parent::attribute($property);
    }

    private function hasAutoRegistrableFactory()
    {
        $factory = $this->getFactory();
        if ($factory instanceof OpenPABootstrapitaliaAutoRegistrableInterface) {
            return $factory->canAutoRegister();
        }

        return false;
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

    private function updateOwner()
    {
        if ($this->hasAutoRegistrableFactory()) {
            if ($this->getObject()->attribute('owner_id') != $this->id()) {
                $this->getObject()->setAttribute('owner_id', $this->id());
                $this->getObject()->store();
            }
        }
    }
}