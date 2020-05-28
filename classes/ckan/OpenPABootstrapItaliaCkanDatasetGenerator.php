<?php

use Opencontent\Ckan\DatiTrentinoIt\DatasetGenerator\OpenPA as BaseDatasetGenerator;
use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\EnvironmentLoader;

class OpenPABootstrapItaliaCkanDatasetGenerator extends BaseDatasetGenerator
{
    public static $containerRemoteId = 'dataset';

    /**
     * @param $classIdentifier
     * @param array $parameters
     * @param null $dryRun
     * @return eZContentObject|false|mixed
     * @throws \Opencontent\Opendata\Api\Exception\EnvironmentForbiddenException
     * @throws \Opencontent\Opendata\Api\Exception\EnvironmentMisconfigurationException
     * @throws \Exception
     */
    public function createFromClassIdentifier($classIdentifier, $parameters = array(), $dryRun = null)
    {
        $tools = new OCOpenDataTools();

        $iniParamaters = eZINI::instance('ocopendata_datasetgenerator.ini')->groups();

        if (empty($parameters) && isset($iniParamaters[$classIdentifier])) {
            $parameters = $iniParamaters[$classIdentifier];
        }

        $containerRemoteId = self::$remoteIds['container'];
        $container = eZContentObject::fetchByRemoteID(self::$containerRemoteId);
        if (!$container instanceof eZContentObject) {
            throw new \Exception("Dataset container (remote $containerRemoteId) not found");
        }

        /** @var eZContentObjectAttribute[] $homeDataMap */
        $homeDataMap = OpenPaFunctionCollection::fetchHome()->attribute('data_map');

        $currentPublicOrganization = false;
        if (isset($homeDataMap['organization']) && $homeDataMap['organization']->hasContent()) {
            $currentPublicOrganization = $homeDataMap['organization']->content();
        }
        if (!$currentPublicOrganization instanceof eZContentObject) {
            throw new \Exception("Public Organization not found");
        }

        $currentContactPoint = false;
        if (isset($homeDataMap['contact_point']) && $homeDataMap['contact_point']->hasContent()) {
            $currentContactPoint = $homeDataMap['contact_point']->content();
        }
        if (!$currentContactPoint instanceof eZContentObject) {
            throw new \Exception("Contact Point not found");
        }

        $spatial = null;
        if (isset($homeDataMap['spatial']) && $homeDataMap['spatial']->hasContent()) {
            $spatial = $homeDataMap['spatial']->toString();
        } else {
            throw new \Exception("Spatial not found");
        }

        $frequency = null;
        $keywordsFound = eZTagsObject::fetchByKeyword('Costantemente aggiornato');
        if (!empty($keywordsFound)) {
            $frequency = implode('|#', [$keywordsFound[0]->ID, $keywordsFound[0]->Keyword, $keywordsFound[0]->ParentID, eZLocale::currentLocaleCode()]);
        } else {
            throw new \Exception("Frequency not found");
        }

        $license = null;
        $keywordsFound = eZTagsObject::fetchByKeyword('Italian Open Data License 2.0 (IODL 2.0)');
        if (!empty($keywordsFound)) {
            $license = implode('|#', [$keywordsFound[0]->ID, $keywordsFound[0]->Keyword, $keywordsFound[0]->ParentID, eZLocale::currentLocaleCode()]);
        } else {
            throw new \Exception("License not found");
        }

        $theme = null;
        $keywordsFound = eZTagsObject::fetchByKeyword('Governo e settore pubblico');
        if (!empty($keywordsFound)) {
            $theme = implode('|#', [$keywordsFound[0]->ID, $keywordsFound[0]->Keyword, $keywordsFound[0]->ParentID, eZLocale::currentLocaleCode()]);
        } else {
            throw new \Exception("Theme not found");
        }

        $language = null;
        $keywordsFound = eZTagsObject::fetchByKeyword('Italiano');
        if (!empty($keywordsFound)) {
            $language = implode('|#', [$keywordsFound[0]->ID, $keywordsFound[0]->Keyword, $keywordsFound[0]->ParentID, eZLocale::currentLocaleCode()]);
        }

        //controllo se l'organizzazione è valida
        $tools->getOrganizationBuilder()->build();

        $siteUrl = rtrim(eZINI::instance()->variable('SiteSettings', 'SiteURL'), '/');
        $siteName = eZINI::instance()->variable('SiteSettings', 'SiteName');

        $exists = eZContentObjectTreeNode::fetchByRemoteID($this->generateNodeRemoteId($classIdentifier));

        $rawQuery = isset($parameters['Query']) ? $parameters['Query'] : null;
        if (!$rawQuery) {
            throw new \Exception("Query for $classIdentifier not found");
        }

        $contentSearch = new ContentSearch();
        $contentEnvironment = EnvironmentLoader::loadPreset('content');
        $geoEnvironment = EnvironmentLoader::loadPreset('geo');
        $query = urlencode($rawQuery);

        $hasResource = false;

        if (isset($parameters['Plurale'], $parameters['Descrizione'])) {
            $title = $parameters['Plurale'] . ' del ' . $siteName;
            $notes = $parameters['Descrizione'] . ' pubblicati sul sito istituzionale del ' . $siteName;
            $tags = strtolower($parameters['Plurale']);
            $resourceTitle = $parameters['Plurale'];
        } else {
            throw new \Exception("Dataset parameters for $classIdentifier not found");
        }

        $contentSearch->setEnvironment($contentEnvironment);
        if ($this->anonymousSearch($contentSearch, $rawQuery)) {
            $hasResource = true;
        }

        if (!$hasResource) {
//            throw new \Exception("Nessuna risorsa trovata per $classIdentifier");
        }

        $distribuzioni = [];
        $distribuzioni[] = [
            'title' => $resourceTitle . ' in formato JSON',
            'url_download' => "https://$siteUrl/api/opendata/v2/content/search/" . $query,
            'format' => 'JSON',
        ];
        $distribuzioni[] = [
            'title' => $resourceTitle . ' in formato CSV',
            'url_download' => "https://$siteUrl/exportas/custom/csv_search/" . $query,
            'format' => 'CSV',
        ];

        $contentSearch->setEnvironment($geoEnvironment);
        if ($this->anonymousSearch($contentSearch, $rawQuery)) {
            $distribuzioni[] = [
                'title' => $resourceTitle . ' in formato GeoJSON',
                'url_download' => "https://$siteUrl/api/opendata/v2/geo/search/" . $query,
                'format' => 'GeoJSON',
            ];
        }

        $queryObject = $contentSearch->getQueryBuilder()->instanceQuery($rawQuery);
        $ezFindQuery = $queryObject->convert()->getArrayCopy();

        if (isset($ezFindQuery['SearchContentClassID'][0])) {
            $mainClassId = $ezFindQuery['SearchContentClassID'][0];
            $distribuzioni[] = [
                'title' => 'Descrizione dei campi',
                'url_download' => "https://$siteUrl/api/opendata/v2/classes/" . eZContentClass::classIdentifierByID($mainClassId),
                'format' => 'JSON',
            ];
        }

        $rows = array();
        foreach ($distribuzioni as $item) {
            $rows[] = implode('|', array_values($item));
        }
        $resources = implode('&', $rows);

        $attributeList = array();
        $attributeList['title'] = $title;
        $attributeList['rights_holder'] = $currentPublicOrganization->attribute('id');
        $attributeList['identifier'] = $this->generateNodeRemoteId($classIdentifier);
        $attributeList['description'] = $notes;
        $attributeList['spatial'] = $spatial;
        if (!$exists) {
            $attributeList['issued'] = time();
        }
        $attributeList['modified'] = time();
        $attributeList['accrualperiodicity'] = $frequency;
        $attributeList['keyword'] = $tags;
        $attributeList['contact_point'] = $currentContactPoint->attribute('id');
        $attributeList['creator'] = $currentPublicOrganization->attribute('id');
        $attributeList['license'] = $license;
        $attributeList['publisher'] = $currentPublicOrganization->attribute('id');
        $attributeList['theme'] = $theme;
        $attributeList['language'] = $language;
        $attributeList['version_info'] = '1.0';
        $attributeList['resources'] = $resources;

        $params = array();
        $params['class_identifier'] = $tools->getIni()->variable('GeneralSettings', 'DatasetClassIdentifier');
        $params['parent_node_id'] = $container->attribute('main_node_id');
        $params['attributes'] = $attributeList;

        if ($dryRun) {
            return true;
        }

        /** @var eZUser $user */
        $user = eZUser::fetchByName('admin');
        eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

        if ($exists) {
            $object = $exists->object();
            eZContentFunctions::updateAndPublishObject($object, $params);
            eZContentObject::clearCache();
            $object = eZContentObject::fetch($object->attribute('id'));
        } else {
            $object = eZContentFunctions::createAndPublishObject($params);
            eZContentObject::clearCache();
            $object = eZContentObject::fetch($object->attribute('id'));
        }
        if ($object instanceof eZContentObject) {
            $mainNode = $object->attribute('main_node');
            if ($mainNode instanceof eZContentObjectTreeNode) {
                $mainNode->setAttribute('remote_id', $this->generateNodeRemoteId($classIdentifier));
                $mainNode->store();
            }
        }

        return $object;
    }
}