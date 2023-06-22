<?php

class ServiceToolsException extends \Opencontent\Opendata\Api\Exception\BaseException
{
    public function getServerErrorCode()
    {
        return 400;
    }

}