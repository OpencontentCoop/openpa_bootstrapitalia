<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();
$ClassIdentifier = isset($Params['Parameters'][0]) ? $Params['Parameters'][0] : false;
$Action = isset($Params['Parameters'][1]) ? $Params['Parameters'][1] : false;

$tpl->setVariable('class_identifier', $ClassIdentifier);

$UserParameters = array();
if (isset($Params['UserParameters'])) {
    $UserParameters = $Params['UserParameters'];
}
$viewParameters = array();
$viewParameters = array_merge($viewParameters, $UserParameters);

$recaptcha = new OpenPARecaptcha();
$tpl->setVariable('recaptcha_public_key', $recaptcha->getPublicKey());

try {
    $stuffHandler = OCEditorialStuffHandler::instance($ClassIdentifier);
    $stuffFactory = $stuffHandler->getFactory();
}catch (Exception $e){
    eZDebug::writeError($e->getMessage(), __METHOD__);
    return $Module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}

if ($stuffFactory instanceof OpenPABootstrapitaliaAutoRegistrableInterface && $stuffFactory->canAutoRegister()) {
    if ($Action == 'activate') {

        $tpl->setVariable('success', true);
        $tpl->setVariable('view_parameters', $viewParameters);

        $Result = array();
        $Result['content'] = $tpl->fetch('design:editorialstuff/join.tpl');
        $Result['node_id'] = 0;

        $contentInfoArray = array('url_alias' => "join/as/{$ClassIdentifier}");
        $Result['content_info'] = $contentInfoArray;
        $Result['path'] = array();


    } else {

        $Module->setUIContextName('edit');
        $Params['TemplateName'] = "design:editorialstuff/join.tpl";
        $EditVersion = 1;

        $tpl = eZTemplate::factory();
        $tpl->setVariable('view_parameters', $viewParameters);
        $tpl->setVariable('success', false);
        $Params['TemplateObject'] = $tpl;

        $db = eZDB::instance();
        $db->begin();

        // Fix issue EZP-22524
        if ($http->hasSessionVariable("Register{$ClassIdentifier}ID")) {
            if ($http->hasSessionVariable("StartedRegistration{$ClassIdentifier}")) {

                eZDebug::writeWarning('Cancel module run to protect against multiple form submits', __FILE__);
                $http->removeSessionVariable("Register{$ClassIdentifier}ID");
                $http->removeSessionVariable("StartedRegistration{$ClassIdentifier}");
                $db->commit();

                return eZModule::HOOK_STATUS_CANCEL_RUN;
            }

            $objectId = $http->sessionVariable("Register{$ClassIdentifier}ID");

            $object = eZContentObject::fetch($objectId);
            if ($object === null) {
                $http->removeSessionVariable("Register{$ClassIdentifier}ID");
                $http->removeSessionVariable("StartedRegistration{$ClassIdentifier}");
            }
        } else {
            if ($http->hasSessionVariable("StartedRegistration{$ClassIdentifier}")) {
                eZDebug::writeWarning('Cancel module run to protect against multiple form submits', __FILE__);
                $http->removeSessionVariable("Register{$ClassIdentifier}ID");
                $http->removeSessionVariable("StartedRegistration{$ClassIdentifier}");
                $db->commit();

                return eZModule::HOOK_STATUS_CANCEL_RUN;
            } else if ($http->hasPostVariable('PublishButton') or $http->hasPostVariable('CancelButton')) {
                $http->setSessionVariable("StartedRegistration{$ClassIdentifier}", 1);
            }

            $class = eZContentClass::fetchByIdentifier($stuffHandler->getFactory()->classIdentifier());
            if (!$class instanceof eZContentClass) {
                return $Module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
            }

            $parent = $stuffHandler->getFactory()->creationRepositoryNode();
            $node = eZContentObjectTreeNode::fetch(intval($parent));

            if ($node instanceof eZContentObjectTreeNode && $class->attribute('id')) {
                $languageCode = eZINI::instance()->variable('RegionalSettings', 'Locale');

                $sectionID = $node->attribute('object')->attribute('section_id');

                $object = eZContentObject::createWithNodeAssignment(
                    $node,
                    $class->attribute('id'),
                    $languageCode,
                    false
                );

                $object = $class->instantiateIn(
                    $languageCode,
                    false,
                    $sectionID,
                    false,
                    eZContentObjectVersion::STATUS_INTERNAL_DRAFT
                );

                $nodeAssignment = $object->createNodeAssignment(
                    $node->attribute('node_id'),
                    true,
                    'auto_' . eZRemoteIdUtility::generate('eznode_assignment'),
                    $class->attribute('sort_field'),
                    $class->attribute('sort_order')
                );

                if ($object) {
                    $http->setSessionVariable('RedirectURIAfterPublish', "/join/as/{$ClassIdentifier}/activate");
                    $http->setSessionVariable('RedirectIfDiscarded', '/');

                    $http->setSessionVariable("Register{$ClassIdentifier}ID", $object->attribute('id'));
                    $objectId = $object->attribute('id');

                } else {
                    $http->removeSessionVariable("Register{$ClassIdentifier}ID");
                    $http->removeSessionVariable("StartedRegistration{$ClassIdentifier}");

                    return $Module->handleError(eZError::KERNEL_ACCESS_DENIED, 'kernel');
                }
            } else {
                $http->removeSessionVariable("Register{$ClassIdentifier}ID");
                $http->removeSessionVariable("StartedRegistration{$ClassIdentifier}");

                return $Module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
            }
        }

        $Params['ObjectID'] = $objectId;

        if (!function_exists('checkContentActions')) {
            /**
             * @param eZModule $Module
             * @param eZContentClass $class
             * @param eZContentObject $object
             * @param eZContentObjectVersion $version
             *
             * @return int
             */
            function checkContentActions($Module, $class, $object, $version)
            {
                $ClassIdentifier = $class->attribute('identifier');

                if ($Module->isCurrentAction('Cancel')) {
                    $Module->redirectTo('/');

                    $version->removeThis();

                    $http = eZHTTPTool::instance();
                    $http->removeSessionVariable("Register{$ClassIdentifier}ID");
                    $http->removeSessionVariable("StartedRegistration{$ClassIdentifier}");

                    return eZModule::HOOK_STATUS_CANCEL_RUN;
                }

                if ($Module->isCurrentAction('Publish')) {

                    $recaptcha = new OpenPARecaptcha();
                    if (!$recaptcha->validate()) {
                        $Module->redirectTo("/join/as/{$ClassIdentifier}/(error)/invalid_recaptcha");

                        return eZModule::HOOK_STATUS_CANCEL_RUN;
                    }

                    $operationResult = eZOperationHandler::execute('content', 'publish', array(
                        'object_id' => $object->attribute('id'),
                        'version' => $version->attribute('version')
                    ));

                    if ($operationResult['status'] != eZModuleOperationInfo::STATUS_REPEAT || $operationResult['status'] != eZModuleOperationInfo::STATUS_CONTINUE) {
                        eZDebug::writeError('Unexpected operation status: ' . $operationResult['status'], __FILE__);
                    }

                    $http = eZHTTPTool::instance();
                    $http->removeSessionVariable("GeneratedPassword");
                    $http->removeSessionVariable("Register{$ClassIdentifier}ID");
                    $http->removeSessionVariable("StartedRegistration{$ClassIdentifier}");
                    $Module->redirectTo("join/as/{$ClassIdentifier}/activate");

                    return eZModule::HOOK_STATUS_OK;
                }
            }
        }
        $Module->addHook('action_check', 'checkContentActions');

        $OmitSectionSetting = true;

        $includeResult = include('kernel/content/attribute_edit.php');

        $db->commit();

        $contentInfoArray = array(
            'node_id' => null,
            'class_identifier' => null
        );
        $contentInfoArray['persistent_variable'] = array(
            'show_path' => true
        );
        if ( is_array( $tpl->variable( 'persistent_variable' ) ) ) {
            $contentInfoArray['persistent_variable'] = array_merge( $contentInfoArray['persistent_variable'], $tpl->variable( 'persistent_variable' ) );
        }
        $Result['content_info'] = $contentInfoArray;

        if ($includeResult != 1) {
            return $includeResult;
        }

    }
} else {
    return $Module->handleError(eZError::KERNEL_ACCESS_DENIED, 'kernel');
}
