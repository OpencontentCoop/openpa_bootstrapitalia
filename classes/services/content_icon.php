<?php

class ObjectHandlerServiceContentIcon extends ObjectHandlerServiceBase
{
    protected $icon;

    protected $objectIcon;

    protected $contextIcon;

    protected static $classIcons = array();

    function run()
    {
        $this->fnData['icon'] = 'getIcon';
        $this->fnData['object_icon'] = 'getObjectIcon';
        $this->fnData['context_icon'] = 'getContextIcon';
        $this->fnData['class_icon'] = 'getClassIcon';
    }

    protected function getIcon()
    {
        if ($this->icon === null) {
            if ($this->getObjectIcon()){
                $this->icon = $this->getObjectIcon();
            }elseif ($this->getClassIcon()){
                $this->icon = $this->getClassIcon();
            }elseif ($this->getContextIcon()){
                $this->icon = $this->getContextIcon();
            }
        }

        return $this->icon;
    }

    protected function getObjectIcon()
    {
        if ($this->objectIcon === null) {
            $this->objectIcon = false;
            //@todo cercare per data_type_string
            if (isset($this->container->attributesHandlers['icon']) && $this->container->attributesHandlers['icon']->attribute('has_content')) {
                $this->objectIcon = [
                    'icon_text' => $this->container->attributesHandlers['icon']->attribute('contentobject_attribute')->content()
                ];
            }
        }

        return $this->objectIcon;
    }

    protected function getContextIcon()
    {
        if ($this->contextIcon === null) {
            $this->contextIcon = false;
            $node = $this->container->getContentNode();
            if ($node instanceof eZContentObjectTreeNode) {
                $iconList = OpenPABootstrapItaliaIcon::fetchByNode($node);
                if (!empty($iconList)) {
                    $pathArray = array_reverse($node->pathArray());
                    foreach ($pathArray as $nodeId) {
                        foreach ($iconList as $icon) {
                            if ($icon->attribute('node_id') == $nodeId) {
                                $this->contextIcon = $icon;
                                break(2);
                            }
                        }
                    }
                }
            }
        }

        return $this->contextIcon;
    }

    protected function getClassIcon()
    {
        if (!isset(self::$classIcons[$this->container->currentClassIdentifier])){
            self::$classIcons[$this->container->currentClassIdentifier] = false;

            $extraParameter = OCClassExtraParameters::fetchObject( OCClassExtraParameters::definition(), null, array(
                'handler' => OpenPABootstrapItaliaIconExtraParameter::IDENTIFIER,
                'class_identifier' => $this->container->currentClassIdentifier,
                OCClassExtraParameters::getKeyDefinitionName() => 'icon'
            ) );

            if ($extraParameter && $extraParameter->attribute('value') != '') {
                self::$classIcons[$this->container->currentClassIdentifier]= [
                    'icon_text' => $extraParameter->attribute('value')
                ];
            }
        }

        return self::$classIcons[$this->container->currentClassIdentifier];
    }


}