<?php

class BandoCigType extends eZWorkflowEventType
{
    const WORKFLOW_TYPE_STRING = "bandocig";

    public function __construct()
    {
        parent::__construct(
            BandoCigType::WORKFLOW_TYPE_STRING,
            'Gestisce la visibilità del bando (cig)'
        );
        $this->setTriggerTypes([
            'content' => [
                'publish' => ['before'],
            ],
        ]);
    }

    public function execute($process, $event)
    {
        $parameters = $process->attribute('parameter_list');

        try {
            $object = eZContentObject::fetch($parameters['object_id']);
            if ($object instanceof eZContentObject
                && $object->attribute('class_identifier') === 'bando') {
                $version = $object->version($parameters['version']);
                if (!$version) {
                    eZDebugSetting::writeError(
                        'The version of object with ID ' . $parameters['object_id'] . ' does not exist.',
                        __METHOD__
                    );
                    return eZWorkflowType::STATUS_WORKFLOW_CANCELLED;
                }

                $states = OpenPABase::initStateGroup('privacy', ['public', 'private']);
                $objectAttributes = $version->attribute('contentobject_attributes');
                $hasDraftAttribute = $isDraft = false;
                foreach ($objectAttributes as $objectAttribute) {
                    $contentClassAttributeIdentifier = $objectAttribute->attribute('contentclass_attribute_identifier');
                    if ($contentClassAttributeIdentifier === BandoCigValidator::IS_DRAFT_FIELD) {
                        $isDraft = intval($objectAttribute->attribute('data_int')) > 0;
                        $hasDraftAttribute = true;
                        break;
                    }
                }
                if ($hasDraftAttribute) {
                    if ($isDraft) {
                        $stateAssign = $states['privacy.private'];
                    } else {
                        $stateAssign = $states['privacy.public'];
                    }
                    if ($stateAssign instanceof eZContentObjectState) {
                        eZAudit::writeAudit('state-assign', [
                            'Content object ID' => $object->attribute('id'),
                            'Content object name' => $object->attribute('name'),
                            'Selected State ID Array' => $stateAssign->attribute('id'),
                            'Comment' => 'Updated state on publish bando: BandoCigType::execute()',
                        ]);
                        $object->assignState($stateAssign);
                    }
                }
            }
        } catch (Throwable $t) {
            eZDebug::writeError($t->getMessage(), __METHOD__);
        }

        return eZWorkflowType::STATUS_ACCEPTED;
    }
}

eZWorkflowEventType::registerEventType(BandoCigType::WORKFLOW_TYPE_STRING, 'BandoCigType');
