<?php

class UniqueStringValidator extends AbstractBootstrapItaliaInputValidator
{
    const UNIQUE_FIELD_ERROR_MESSAGE = "Il valore del campo '%s' è già presente a sistema (%s)";

    public function validate(): array
    {
        $uniqueStringCheckList = OpenPAINI::variable('AttributeHandlers', 'UniqueStringCheck', []);
        $uniqueStringAllowedValues = OpenPAINI::variable('AttributeHandlers', 'UniqueStringAllowedValue', []);
        eZDebug::writeDebug(implode(', ', $uniqueStringCheckList), 'uniqueStringCheckList');
        eZDebug::writeDebug(implode(', ', $uniqueStringAllowedValues), 'uniqueStringAllowedValues');
        foreach ($uniqueStringCheckList as $uniqueStringCheck) {
            [$classIdentifier, $attributeIdentifier] = explode('/', $uniqueStringCheck);
            $uniqueResult = $this->checkUniqueStringField(
                $classIdentifier,
                $attributeIdentifier,
                $uniqueStringAllowedValues
            );
            if (!$uniqueResult['is_valid']) {
                return [
                    'identifier' => $attributeIdentifier,
                    'text' => $uniqueResult['message'],
                ];
            }
        }

        return [];
    }

    private function checkUniqueStringField(
        $classIdentifier,
        $attributeIdentifier,
        $uniqueStringAllowedValues
    ) {
        $result = [
            'is_valid' => true,
            'message' => '',
        ];
        $hasUniqueValue = true;
        $duplicates = [];
        $attributeName = $attributeIdentifier;

        if ($this->class->attribute('identifier') == $classIdentifier) {
            foreach ($this->contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') == $attributeIdentifier
                    && $contentClassAttribute->attribute('data_type_string') == eZStringType::DATA_TYPE_STRING) {
                    $inputData = $this->http->postVariable(
                        'ContentObjectAttribute_ezstring_data_text_' . $contentObjectAttribute->attribute('id')
                    );
                    $hasAllowedValue = isset($uniqueStringAllowedValues[$classIdentifier . '/' . $attributeIdentifier])
                        && $uniqueStringAllowedValues[$classIdentifier . '/' . $attributeIdentifier] == trim(
                            $inputData
                        );

                    if (!$hasAllowedValue) {
                        $duplicates = $this->getObjectIdListByAttributeDataText($contentObjectAttribute, $inputData);
                        if ($contentObjectAttribute->hasContent() && count($duplicates) > 0) {
                            $hasUniqueValue = false;
                        }
                    }
                    $attributeName = $contentClassAttribute->attribute('name');

                    break;
                }
            }
        }

        if (!$hasUniqueValue) {
            $duplicateLinks = [];
            foreach ($duplicates as $duplicate) {
                $duplicateObject = eZContentObject::fetch((int)$duplicate);
                $duplicateName = $duplicateObject instanceof eZContentObject ? $duplicateObject->attribute(
                    'name'
                ) : $duplicate;
                $duplicateLinks[] = '<a href="/openpa/object/' . $duplicate . '" target="_blank">' . $duplicateName . '</a>';
            }
            $result['is_valid'] = false;
            $result['message'] = sprintf(
                self::UNIQUE_FIELD_ERROR_MESSAGE,
                $attributeName,
                implode(', ', $duplicateLinks)
            );
        }

        return $result;
    }

    private function getObjectIdListByAttributeDataText(eZContentObjectAttribute $contentObjectAttribute, $inputData)
    {
        $contentObjectID = $contentObjectAttribute->attribute('contentobject_id');
        $contentClassAttributeID = $contentObjectAttribute->attribute('contentclassattribute_id');
        $db = eZDB::instance();
        $query = "SELECT coa.contentobject_id as id
            FROM ezcontentobject co, ezcontentobject_attribute coa
            WHERE co.id = coa.contentobject_id
            AND co.current_version = coa.version
            AND co.status = " . eZContentObject::STATUS_PUBLISHED . "
            AND coa.contentobject_id <> " . $db->escapeString($contentObjectID) . "
            AND coa.contentclassattribute_id = " . $db->escapeString($contentClassAttributeID) . "
            AND coa.data_text = '" . $db->escapeString($inputData) . "'";


        $results = $db->arrayQuery($query);
        if (count($results) > 0) {
            return array_column($results, 'id');
        }
        return [];
    }

}