<?php

namespace Lotti;

use Opencontent\OpenApi\EndpointFactory;
use Opencontent\OpenApi\OperationFactory\ContentObject\CreateOperationFactory;

class LottiCreateOperationFactory extends CreateOperationFactory
{
    public function handleCurrentRequest(EndpointFactory $endpointFactory)
    {
        $response = parent::handleCurrentRequest($endpointFactory);
        \TrasparenzaEndpointFactoryProvider::clearSchemaBuilder();
        return $response;
    }

}