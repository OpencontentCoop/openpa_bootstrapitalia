<?php

class PagineTrasparenzaSearchOperationFactory extends \Opencontent\OpenApi\OperationFactory\Slug\SearchOperationFactory
{
    public function __construct($nodeIdMap, $pageLabel, $enum)
    {
        parent::__construct($pageLabel, $enum);
    }
}