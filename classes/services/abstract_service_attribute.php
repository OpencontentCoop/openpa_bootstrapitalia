<?php

abstract class ObjectHandlerServiceAttribute extends ObjectHandlerServiceBase
{
    const IDENTIFIER = '';

    const LABEL = '';

    function run()
    {
        $this->fnData['full'] = 'getFullData';
        $this->fnData['line'] = 'getLineData';
        $this->fnData['has_content'] = 'hasContent';
        $this->fnData['label'] = 'getLabel';
    }

    protected function getFullData()
    {
        $extraHandler =  $this->container->extraParametersManager->getHandler('table_view');
        return array(
            'show_label' => in_array(static::IDENTIFIER, $extraHandler->attribute('show_label')),
            'exclude' => !in_array(static::IDENTIFIER, $extraHandler->attribute('show')),
            'highlight' => in_array(static::IDENTIFIER, $extraHandler->attribute('highlight')),
            'has_content' => $this->hasContent(),
            'show_link' => in_array(static::IDENTIFIER, $extraHandler->attribute('show_link')),
            'show_empty' => in_array(static::IDENTIFIER, $extraHandler->attribute('show_empty')),
            'contatti' => false,
            'collapse_label' => in_array(static::IDENTIFIER, $extraHandler->attribute('collapse_label'))
        );
    }

    protected function getLineData()
    {
        $extraHandler =  $this->container->extraParametersManager->getHandler('line_view');
        return array(
            'show_label' => in_array(static::IDENTIFIER, $extraHandler->attribute('show_label')),
            'exclude' => !in_array(static::IDENTIFIER, $extraHandler->attribute('show')),
            'has_content' => $this->hasContent(),
            'show_link' => !in_array(static::IDENTIFIER, $extraHandler->attribute('show_link'))
        );
    }

    protected function hasContent()
    {
        return true;
    }

    protected function getLabel()
    {
        return static::LABEL;
    }
}