<?php

class ezfIndexRoleReverseRelations implements ezfIndexPlugin
{
    public function modify(eZContentObject $contentObject, &$docList)
    {
        $personClasses = ['public_person'];
        $forEntityClasses = ['private_organization', 'organization'];

        $version = $contentObject->currentVersion();
        if ($version === false) {
            return;
        }
        $availableLanguages = $version->translationList(false, false);

        $contentClassAttributeId = 0;
        $contentClassAttributeIdentifier = '';
        if (in_array($contentObject->attribute('class_identifier'), $personClasses)) {
            $contentClassAttributeIdentifier = 'person';
            $contentClassAttributeId = (int)eZContentClassAttribute::classAttributeIDByIdentifier(
                'time_indexed_role/person'
            );
        } elseif (in_array($contentObject->attribute('class_identifier'), $forEntityClasses)) {
            $contentClassAttributeIdentifier = 'for_entity';
            $contentClassAttributeId = (int)eZContentClassAttribute::classAttributeIDByIdentifier(
                'time_indexed_role/for_entity'
            );
        }
        if ($contentClassAttributeId > 0) {
            $contentObjectId = (int)$contentObject->attribute('id');
            $query = "SELECT ezcol.from_contentobject_id
                FROM ezcontentobject_link ezcol
                INNER JOIN ezcontentobject ezco ON (
                    ezco.id = ezcol.from_contentobject_id
                    AND ezco.current_version = ezcol.from_contentobject_version
                )
                WHERE ezcol.contentclassattribute_id = $contentClassAttributeId
                AND ezcol.to_contentobject_id = $contentObjectId";
            $res = (array)eZDB::instance()->arrayQuery($query);

            $roleIdList = array_column($res, 'from_contentobject_id');
            $roleIdList = array_map('intval', $roleIdList);

            $data = BootstrapItaliaSolrTools::getObjectIndexDataAsSubAttribute(
                $contentObject,
                $version,
                $availableLanguages,
                $contentClassAttributeIdentifier
            );

            foreach ($roleIdList as $roleId) {
                foreach ($availableLanguages as $language) {
                    $patchData = array_merge(
                        $data[$language],
                        BootstrapItaliaSolrTools::getOpendataIndexData($roleId)
                    );
                    BootstrapItaliaSolrTools::sendPatch($roleId, [$language], $patchData);
                }
            }
        }
    }
}
