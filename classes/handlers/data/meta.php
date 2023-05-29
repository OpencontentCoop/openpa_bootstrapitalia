<?php

class DataHandlerMeta implements OpenPADataHandlerInterface
{
    public function __construct(array $Params)
    {
    }

    public function getData()
    {
        return OpenPAMeta::instanceFromGlobals();
    }

}


