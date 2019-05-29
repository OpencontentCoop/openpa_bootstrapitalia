<?php

trait OpenPABootstrapItaliaCustomAttributeTrait
{
    protected function handleCustomAttributes()
    {
        return true;
    }

    protected function getCustomAttributes()
    {
        return [
            OCClassExtraParametersCustomAttribute::create(ObjectHandlerServiceContentShowModified::IDENTIFIER, ObjectHandlerServiceContentShowModified::LABEL),
            OCClassExtraParametersCustomAttribute::create(ObjectHandlerServiceContentShowHistory::IDENTIFIER, ObjectHandlerServiceContentShowHistory::LABEL),
        ];
    }
}