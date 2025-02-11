<?php

class ezjscPage extends ezjscServerFunctionsNode
{
    static public function action($args)
    {
        [$attributeId, $attributeVersion] = explode('-', $args[0], 2);
        $contentObjectAttribute = eZContentObjectAttribute::fetch(
            (int)$attributeId,
            (int)$attributeVersion
        );
        if (!$contentObjectAttribute instanceof eZContentObjectAttribute) {
            throw new InvalidArgumentException("Attribute not found");
        }
        if (!$contentObjectAttribute->objectVersion()->checkAccess('edit')) {
            throw new InvalidArgumentException("Current user can not edit content");
        }
        if (!$contentObjectAttribute->dataType() instanceof eZPageType) {
            throw new InvalidArgumentException("Invalid attribute type");
        }
        $action = str_replace(['CustomActionButton[', ']'], '', $args[1]);

        preg_match("#^([0-9]+)_(.*)$#", $action, $matchArray);

        $customActionAttributeId = (int)$matchArray[1];
        $customAction = $matchArray[2];

        if ($customActionAttributeId !== (int)$attributeId) {
            throw new InvalidArgumentException("Invalid attribute id in action request");
        }

        $http = eZHTTPTool::instance();
        $base = 'ContentObjectAttribute';
        $contentObjectAttribute->dataType()->fetchObjectAttributeHTTPInput(
            $http, $base, $contentObjectAttribute
        );
        $contentObjectAttribute->setContent($contentObjectAttribute->attribute('content'));
        $contentObjectAttribute->dataType()->customObjectAttributeHTTPAction(
            $http, $customAction, $contentObjectAttribute, []
        );
        $contentObjectAttribute->setContent($contentObjectAttribute->attribute('content'));
        $contentObjectAttribute->store();
    }
}