<?php

class openpa_bootstrapitaliaHandler extends eZContentObjectEditHandler
{
    const FILE_ERROR_MESSAGE = "Popolare almeno un campo tra '%s', '%s' e '%s'";

    const UNIQUE_FIELD_ERROR_MESSAGE = "Il valore del campo '%s' è già presente a sistema (%s)";

    const SERVICE_STATUS_ERROR_MESSAGE = "Inserire un testo nel campo 'Motivo dello stato' dal momento che il servizio non è attivo";

    const SERVICE_PROCESSING_TIME_ERROR_MESSAGE = 'Compilare almeno un campo tra "Tempi e scadenze" e "Giorni massimi di attesa dalla richiesta"';

    /**
     * @param eZHTTPTool $http
     * @param eZModule $module
     * @param eZContentClass $class
     * @param eZContentObject $object
     * @param eZContentObjectVersion $version
     * @param eZContentObjectAttribute[] $contentObjectAttributes
     * @param int $editVersion
     * @param string $editLanguage
     * @param string $fromLanguage
     * @param array $validationParameters
     * @return array
     */
    function validateInput(
        $http,
        &$module,
        &$class,
        $object,
        &$version,
        $contentObjectAttributes,
        $editVersion,
        $editLanguage,
        $fromLanguage,
        $validationParameters
    ) {
        $base = 'ContentObjectAttribute';
        $result = parent::validateInput(
            $http,
            $module,
            $class,
            $object,
            $version,
            $contentObjectAttributes,
            $editVersion,
            $editLanguage,
            $fromLanguage,
            $validationParameters
        );

        if ($class->attribute('identifier') == 'document') {
            $file = eZHTTPFile::UPLOADEDFILE_OK;
            $link = true;
            $attachments = true;

            $fileName = 'file';
            $linkName = 'link';
            $attachmentsName = 'attachments';

            foreach ($contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') == 'file') {
                    if ($contentObjectAttribute->hasContent()) {
                        $file = eZHTTPFile::UPLOADEDFILE_OK;
                    } else {
                        $httpFileName = $base . "_data_binaryfilename_" . $contentObjectAttribute->attribute("id");
                        $maxSize = 1024 * 1024 * $contentClassAttribute->attribute(
                                eZBinaryFileType::MAX_FILESIZE_FIELD
                            );
                        $file = eZHTTPFile::canFetch($httpFileName, $maxSize);
                    }
                    $fileName = $contentClassAttribute->attribute('name');
                } elseif ($contentClassAttribute->attribute('identifier') == 'link') {
                    $link = false;
                    if ($contentObjectAttribute->hasContent()) {
                        $link = $contentObjectAttribute->content();
                    } elseif ($http->hasPostVariable(
                        $base . "_ezurl_url_" . $contentObjectAttribute->attribute("id")
                    )) {
                        $link = $http->postVariable($base . "_ezurl_url_" . $contentObjectAttribute->attribute("id"));
                    }
                    $linkName = $contentClassAttribute->attribute('name');
                } elseif ($contentClassAttribute->attribute('identifier') == 'attachments') {
                    if ($contentClassAttribute->attribute('data_type_string') == OCMultiBinaryType::DATA_TYPE_STRING) {
                        $attachments = eZMultiBinaryFile::fetch(
                            $contentObjectAttribute->attribute('id'),
                            $contentObjectAttribute->attribute('version')
                        );
                    } else {
                        $attachments = $contentObjectAttribute->toString();
                    }
                    $attachmentsName = $contentClassAttribute->attribute('name');
                }
            }

            if ($file == eZHTTPFile::UPLOADEDFILE_DOES_NOT_EXIST && empty($link) && empty($attachments)) {
                $result = [
                    'is_valid' => false,
                    'warnings' => [
                        [
                            'identifier' => 'file',
                            'text' => sprintf(self::FILE_ERROR_MESSAGE, $fileName, $linkName, $attachmentsName),
                        ],
                    ],
                ];
            }
        }

        if ($class->attribute('identifier') == 'public_service') {
            $serviceStatus = $statusNote = false;
            $hasProcessingTime = $hasProcessingTimeAsText = false;
            foreach ($contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') == 'has_service_status') {
                    $serviceStatus = $contentObjectAttribute;
                } elseif ($contentClassAttribute->attribute('identifier') == 'status_note') {
                    $statusNote = $contentObjectAttribute;
                } elseif ($contentClassAttribute->attribute('identifier') == 'has_processing_time') {
                    $hasProcessingTime = $contentObjectAttribute;
                } elseif ($contentClassAttribute->attribute('identifier') == 'has_processing_time_text') {
                    $hasProcessingTimeAsText = $contentObjectAttribute;
                }
            }
            if ($serviceStatus && $statusNote) {
                $serviceStatusPostVar = 'ContentObjectAttribute_eztags_data_text3_' . $serviceStatus->attribute('id');
                $statusNotePostVar = 'ContentObjectAttribute_data_text_' . $statusNote->attribute('id');
                $isActive = true;
                $activeService = OpenPABootstrapItaliaOperators::getActiveServiceTag();
                if ($activeService) {
                    $isActive = false;
                    if ($http->hasPostVariable($serviceStatusPostVar)) {
                        $isActive = $activeService->attribute('id') == $http->postVariable($serviceStatusPostVar);
                    }
                }
                $statusNoteHasContent = $http->hasPostVariable($statusNotePostVar)
                    && !empty($http->postVariable($statusNotePostVar));
                if (!$isActive && !$statusNoteHasContent) {
                    $result['is_valid'] = false;
                    $result['warnings'][] = [
                        'identifier' => 'status_note',
                        'text' => self::SERVICE_STATUS_ERROR_MESSAGE,
                    ];
                }
            }
            if ($hasProcessingTime && $hasProcessingTimeAsText) {
                $hasProcessingTimePostVar = 'ContentObjectAttribute_data_integer_' . $hasProcessingTime->attribute(
                        'id'
                    );
                $hasProcessingTimeAsTextPostVar = 'ContentObjectAttribute_data_text_' . $hasProcessingTimeAsText->attribute(
                        'id'
                    );
                $hasProcessingTimeHasContent = $http->hasPostVariable($hasProcessingTimePostVar)
                    && !empty($http->postVariable($hasProcessingTimePostVar));
                $hasProcessingTimeAsTextHasContent = $http->hasPostVariable($hasProcessingTimeAsTextPostVar)
                    && !empty($http->postVariable($hasProcessingTimeAsTextPostVar));

                if (!$hasProcessingTimeHasContent && !$hasProcessingTimeAsTextHasContent) {
                    $result['is_valid'] = false;
                    $result['warnings'][] = [
                        'identifier' => 'has_processing_time_text',
                        'text' => self::SERVICE_PROCESSING_TIME_ERROR_MESSAGE,
                    ];
                }
            }
        }

        $uniqueStringCheckList = OpenPAINI::variable('AttributeHandlers', 'UniqueStringCheck', []);
        $uniqueStringAllowedValues = OpenPAINI::variable('AttributeHandlers', 'UniqueStringAllowedValue', []);
        foreach ($uniqueStringCheckList as $uniqueStringCheck) {
            [$classIdentifier, $attributeIdentifier] = explode('/', $uniqueStringCheck);
            $uniqueResult = $this->checkUniqueStringField(
                $classIdentifier,
                $attributeIdentifier,
                $http,
                $class,
                $contentObjectAttributes,
                $uniqueStringAllowedValues
            );
            if (!$uniqueResult['is_valid']) {
                $result['is_valid'] = false;
                $result['warnings'][] = [
                    'identifier' => $attributeIdentifier,
                    'text' => $uniqueResult['message'],
                ];
            }
        }

        if ($class->attribute('identifier') == 'event'
            && (
                eZContentObject::fetchByRemoteID('all-events')
                || eZContentObject::fetchByRemoteID(OpenPABase::getCurrentSiteaccessIdentifier() . '_openpa_agenda')
            )
        ) {
            $isAccessibleForFree = false;
            $costNotes = false;
            $hasOffer = false;

            $isAccessibleForFreeName = 'is_accessible_for_free';
            $costNotesName = 'cost_notes';
            $hasOfferName = 'has_offer';
            $countExisting = 0;

            foreach ($contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') == 'is_accessible_for_free') {
                    $countExisting++;
                    $isAccessibleForFree = $http->hasPostVariable(
                        $base . "_data_boolean_" . $contentObjectAttribute->attribute("id")
                    );
                    $isAccessibleForFreeName = $contentClassAttribute->attribute('name');
                } elseif ($contentClassAttribute->attribute('identifier') == 'cost_notes') {
                    $countExisting++;
                    $costNotesData = $http->postVariable(
                        $base . "_data_text_" . $contentObjectAttribute->attribute("id")
                    );
                    $costNotesData = strip_tags($costNotesData);
                    $costNotesData = trim($costNotesData);
                    $costNotes = !empty($costNotesData);
                    $costNotesName = $contentClassAttribute->attribute('name');
                } elseif ($contentClassAttribute->attribute('identifier') == 'has_offer') {
                    $countExisting++;
                    $hasOfferData = $http->postVariable(
                        $base . "_data_object_relation_list_" . $contentObjectAttribute->attribute("id")
                    );
                    $hasOffer = is_array($hasOfferData) && (count(
                                $hasOfferData
                            ) > 1 || $hasOfferData[0] !== 'no_relation');
                    $hasOfferName = $contentClassAttribute->attribute('name');
                }
            }
            if ($countExisting === 3 && !$isAccessibleForFree && !$costNotes && !$hasOffer) {
                $result = [
                    'is_valid' => false,
                    'warnings' => [
                        [
                            'identifier' => 'is_accessible_for_free',
                            'text' => sprintf(
                                self::FILE_ERROR_MESSAGE,
                                $isAccessibleForFreeName,
                                $costNotesName,
                                $hasOfferName
                            ),
                        ],
                    ],
                ];
            }
        }

        return $result;
    }

    private function checkUniqueStringField(
        $classIdentifier,
        $attributeIdentifier,
        $http,
        $class,
        $contentObjectAttributes,
        $uniqueStringAllowedValues
    ) {
        $result = [
            'is_valid' => true,
            'message' => '',
        ];
        $hasUniqueValue = true;
        $duplicates = [];
        $attributeName = $attributeIdentifier;

        if ($class->attribute('identifier') == $classIdentifier) {
            foreach ($contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') == $attributeIdentifier
                    && $contentClassAttribute->attribute('data_type_string') == eZStringType::DATA_TYPE_STRING) {
                    $inputData = $http->postVariable(
                        'ContentObjectAttribute_ezstring_data_text_' . $contentObjectAttribute->attribute('id')
                    );
                    $hasAllowedValue = isset($uniqueStringAllowedValues[$classIdentifier . '/' . $attributeIdentifier])
                        && $uniqueStringAllowedValues[$classIdentifier . '/' . $attributeIdentifier] == trim($inputData);

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
