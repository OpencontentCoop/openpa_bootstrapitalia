<?php

class PagineTrasparenzaSearchOperationFactory extends \Opencontent\OpenApi\OperationFactory\Slug\SearchOperationFactory
{
    /** @phpstan-ignore constructor.unusedParameter */
    public function __construct($nodeIdMap, $pageLabel, $enum)
    {
        parent::__construct($pageLabel, $enum);
    }
}