<?php

class DataHandlerTheme implements OpenPADataHandlerInterface
{
    private $theme;

    public function __construct(array $Params)
    {
        $this->theme = eZHTTPTool::instance()->getVariable('identifier', 'default');
    }

    public function getData()
    {
        return BootstrapItaliaTheme::fromString($this->theme);
    }

}