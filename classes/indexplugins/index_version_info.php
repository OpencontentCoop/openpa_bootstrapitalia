<?php

use Opencontent\Opendata\Api\Values\ExtraDataProviderInterface;
use Opencontent\Opendata\Api\Values\ExtraData;
class ezfIndexVersionInfo implements ezfIndexPlugin, ExtraDataProviderInterface
{
    public function modify(eZContentObject $contentObject, &$docList)
    {
        $version = $contentObject->currentVersion();
        $versionInfo = $this->getVersionInfo($version, true);
        foreach ($version->translationList(false, false) as $languageCode) {
            if ($docList[$languageCode] instanceof eZSolrDoc) {
                foreach ($versionInfo as $field => $value) {
                    if (!isset($docList[$languageCode]->Doc[$field])) {
                        $docList[$languageCode]->addField($field, $value);
                    }
                }
            }
        }
    }

    public function setExtraDataFromContentObject(eZContentObject $object, ExtraData $extraData)
    {
        $extraData->set('version_info', $this->getVersionInfo($object->currentVersion()));
    }

    private function getVersionInfo(eZContentObjectVersion $version, $toSolrFormat = false): array
    {
        $data = [
            'number' => $version->attribute('version'),
            'creator_id' => $version->attribute('creator_id'),
            'creator' => $version->attribute('creator') ? $version->attribute('creator')->attribute('name') : '',
            'created' => $version->attribute('created'),
        ];
        if ($toSolrFormat){
            $data = [
                'extra_version_number_i' => (int)$data['number'],
                'extra_version_creator_id_i' => (int)$data['creator_id'],
                'extra_version_creator_s' => (string)$data['creator'],
                'extra_version_created_dt' => ezfSolrDocumentFieldBase::convertTimestampToDate($data['created']),
            ];
        }

        return $data;
    }
}