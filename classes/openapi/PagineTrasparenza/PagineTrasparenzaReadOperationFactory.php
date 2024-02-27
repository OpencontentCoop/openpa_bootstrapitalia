<?php

class PagineTrasparenzaReadOperationFactory extends \Opencontent\OpenApi\OperationFactory\Slug\ReadOperationFactory
{

    public function __construct($nodeIdMap, $pageLabel, $enum)
    {
        parent::__construct($pageLabel, $enum);
    }
}