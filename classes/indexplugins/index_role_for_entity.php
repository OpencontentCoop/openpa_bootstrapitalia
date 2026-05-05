<?php

/**
 * Index plugin that injects for_entity sub-attribute fields directly into a time_indexed_role
 * Solr document during normal indexing.
 *
 * This complements ezfIndexRoleReverseRelations, which patches role docs when an org is indexed,
 * but never fires when the role itself is indexed (e.g. after a role's for_entity changes).
 *
 * Fixes: persons appearing in wrong organization's people page (for_entity.id stale in Solr).
 */
class ezfIndexRoleForEntity implements ezfIndexPlugin
{
    public function modify(eZContentObject $contentObject, &$docList)
    {
        if ($contentObject->attribute('class_identifier') !== 'time_indexed_role') {
            return;
        }

        $attrId = (int)eZContentClassAttribute::classAttributeIDByIdentifier('time_indexed_role/for_entity');
        if ($attrId <= 0) {
            return;
        }

        $roleId = (int)$contentObject->attribute('id');
        $res = (array)eZDB::instance()->arrayQuery(
            "SELECT ezcol.to_contentobject_id FROM ezcontentobject_link ezcol
             INNER JOIN ezcontentobject ezco ON (
                 ezco.id = $roleId
                 AND ezcol.from_contentobject_version = ezco.current_version
             )
             WHERE ezcol.contentclassattribute_id = $attrId
             AND ezcol.from_contentobject_id = $roleId"
        );

        if (empty($res)) {
            return;
        }

        $orgObject = eZContentObject::fetch((int)$res[0]['to_contentobject_id']);
        if (!$orgObject instanceof eZContentObject) {
            return;
        }

        $orgVersion = $orgObject->currentVersion();
        if ($orgVersion === false) {
            return;
        }

        $availableLanguages = $orgVersion->translationList(false, false);

        $data = BootstrapItaliaSolrTools::getObjectIndexDataAsSubAttribute(
            $orgObject,
            $orgVersion,
            $availableLanguages,
            'for_entity'
        );

        foreach ($docList as $languageCode => $doc) {
            if (!$doc instanceof eZSolrDoc) {
                continue;
            }
            $langData = $data[$languageCode] ?? (array_values($data)[0] ?? []);
            foreach ($langData as $field => $value) {
                // Skip fields already added by eZFind's normal relation indexing
                // (ezfSolrDocumentFieldObjectRelation adds submeta_for_entity___* meta fields
                // and attr_for_entity_t; re-adding them causes Solr to reject with
                // "multiple values for non-multiValued field").
                if (isset($doc->Doc[$field])) {
                    continue;
                }
                if (is_array($value)) {
                    foreach ($value as $v) {
                        $doc->addField($field, $v);
                    }
                } else {
                    $doc->addField($field, $value);
                }
            }
        }
    }
}
