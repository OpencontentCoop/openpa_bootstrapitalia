<?php

class PagineTrasparenzaMergePatchOperationFactory extends
    \Opencontent\OpenApi\OperationFactory\Slug\MergePatchOperationFactory
{
    /** @phpstan-ignore constructor.unusedParameter */
    public function __construct($nodeIdMap, $pageLabel, $enum)
    {
        parent::__construct($pageLabel, $enum);
    }

    public function handleCurrentRequest(\Opencontent\OpenApi\EndpointFactory $endpointFactory)
    {
        $response = parent::handleCurrentRequest($endpointFactory);
        TrasparenzaEndpointFactoryProvider::clearSchemaBuilder();
        return $response;
    }

}