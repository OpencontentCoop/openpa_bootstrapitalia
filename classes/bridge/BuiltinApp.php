<?php

class BuiltinApp
{
    private $appIdentifier;

    private $appLabel;

    private $siteData;

    public function __construct(string $appName, string $appLabel)
    {
        $this->appIdentifier = $appName;
        $this->appLabel = $appLabel;
    }

    /**
     * @return string
     */
    public function getAppIdentifier(): string
    {
        return $this->appIdentifier;
    }

    /**
     * @return string
     */
    public function getAppLabel(): string
    {
        return $this->appLabel;
    }

    private function getSiteData(string $config = null): ?eZPersistentObject
    {
        if ($this->siteData === null || $config) {
            $name = "built_in_{$this->appIdentifier}_config";
            $this->siteData = eZSiteData::fetchByName($name) ?? null;
            if ($config !== null) {
                if (!$this->siteData instanceof eZSiteData) {
                    $this->siteData = eZSiteData::create($name, '');
                }
                $this->siteData->setAttribute('value', $config);
                $this->siteData->store();
            }
        }

        return $this->siteData;
    }

    public function hasCustomConfig(): bool
    {
        return $this->getSiteData() instanceof eZSiteData && !empty($this->getSiteData()->attribute('value'));
    }

    public function getCustomConfig(): string
    {
        return $this->hasCustomConfig() ? $this->getSiteData()->attribute('value') : '';
    }

    public function setCustomConfig(string $config): void
    {
        if (eZUser::currentUser()->hasAccessTo(
                'bootstrapitalia',
                'config_built_in_apps'
            )['accessWord'] === 'yes') {
            $this->getSiteData($config);
        }
    }

    public function getVariables(): array
    {
        $appIdentifier = strtoupper($this->appIdentifier);
        $privacy = eZContentObject::fetchByRemoteID('privacy-policy-link');
        $privacyUrl = $privacy ? $privacy->mainNode()->attribute('url_alias') : '/';
        eZURI::transformURI($privacyUrl, false, 'full');
        return [
            'OC_' . $appIdentifier . '_APIURL' => StanzaDelCittadinoBridge::factory()->getApiBaseUri(),
            'OC_' . $appIdentifier . '_PRIVACYURL' => $privacyUrl,
            'OC_' . $appIdentifier . '_AUTHURL' => StanzaDelCittadinoBridge::factory()->buildApiUrl('/login'),
        ];
    }

    public function getWidgetSrc(): string
    {
        return OpenPAINI::variable('StanzaDelCittadinoBridge', 'BuiltInWidgetSource_' . $this->getAppIdentifier(), '');
    }

    public function getModuleResult(): array
    {
        $tpl = eZTemplate::factory();
        $tpl->setVariable('built_in_app', $this->getAppIdentifier());
        $tpl->setVariable('built_in_app_variables', $this->getVariables());
        $tpl->setVariable('built_in_app_script', $this->getCustomConfig());
        $tpl->setVariable('built_in_app_src', $this->getWidgetSrc());
        $tpl->setVariable('built_in_app_api_base_url', StanzaDelCittadinoBridge::factory()->getApiBaseUri());

        $Result = [];
        $Result['content'] = $tpl->fetch('design:openpa/built_in_app.tpl');
        $path = [];
        $path[] = [
            'text' => OpenPaFunctionCollection::fetchHome()->getName(),
            'url' => '/',
        ];
        $allServices = eZContentObject::fetchByRemoteID('all-services');
        if ($allServices instanceof eZContentObject) {
            $path[] = [
                'text' => $allServices->attribute('name'),
                'url' => $allServices->mainNode()->urlAlias(),
            ];
        }
        $path[] = [
            'text' => ezpI18n::tr('bootstrapitalia', $this->getAppLabel()),
            'url' => false,
        ];
        $Result['path'] = $path;
        $contentInfoArray = [
            'node_id' => null,
            'class_identifier' => null,
        ];
        $contentInfoArray['persistent_variable'] = [
            'show_path' => true,
            'built_in_app' => $this->getAppIdentifier(),
        ];
        if (is_array($tpl->variable('persistent_variable'))) {
            $contentInfoArray['persistent_variable'] = array_merge(
                $contentInfoArray['persistent_variable'],
                $tpl->variable('persistent_variable')
            );
        }
        $Result['content_info'] = $contentInfoArray;

        return $Result;
    }
}