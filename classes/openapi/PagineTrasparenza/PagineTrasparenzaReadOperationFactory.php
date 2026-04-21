<?php

class PagineTrasparenzaReadOperationFactory extends \Opencontent\OpenApi\OperationFactory\Slug\ReadOperationFactory
{

    /** @phpstan-ignore constructor.unusedParameter */
    public function __construct($nodeIdMap, $pageLabel, $enum)
    {
        parent::__construct($pageLabel, $enum);
    }
}