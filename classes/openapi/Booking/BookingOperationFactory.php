<?php

use Opencontent\OpenApi\OperationFactory\GetOperationFactory;
use Opencontent\OpenApi\EndpointFactory;
use erasys\OpenApi\Spec\v3 as OA;
use Opencontent\OpenApi\OperationFactory\CacheAwareInterface;

class BookingOperationFactory extends GetOperationFactory implements CacheAwareInterface
{
    const DEFAULT_LIMIT = 200;

    public function setResponseHeaders(EndpointFactory $endpointFactory, ezpRestMvcResult $result): void
    {
        header("Cache-Control: public, must-revalidate, max-age=10, s-maxage=600");
    }

    public function hasResponseHeaders(EndpointFactory $endpointFactory, ezpRestMvcResult $result): bool
    {
        return true;
    }

    public function handleCurrentRequest(EndpointFactory $endpointFactory)
    {
        $filters = [
            'service_id' => $this->getCurrentRequestParameter('id'),
            'office_id' => $this->getCurrentRequestParameter('office_id'),
            'place_id' => $this->getCurrentRequestParameter('place_id'),
            'calendar_id' => $this->getCurrentRequestParameter('calendar_id'),
            'refresh' => (bool)$this->getCurrentRequestParameter('refresh'),
            'drop' => (bool)$this->getCurrentRequestParameter('drop'),
        ];
        $limit = intval($this->getCurrentRequestParameter('limit') ?? static::DEFAULT_LIMIT);
        $offset = (int)$this->getCurrentRequestParameter('offset');

        $path = $endpointFactory->getBaseUri() . $endpointFactory->getPath();
        $parameters = [
            'offset' => $offset,
            'limit' => $limit,
        ];
        foreach ($this->generateSearchParameters() as $parameter) {
            if ($this->getCurrentRequestParameter($parameter->name)) {
                $parameters[$parameter->name] = $this->getCurrentRequestParameter($parameter->name);
            }
        }

        $response = StanzaDelCittadinoBooking::findBookingService($filters, $limit, $offset);
        $next = null;
        if ($response['count'] > ($limit + $offset)) {
            $nextParameters = $parameters;
            $nextParameters['offset'] += $nextParameters['limit'];
            $next = $path . '?' . http_build_query($nextParameters);
        }
        $prev = null;
        if ($parameters['offset'] > 0) {
            $prevParameters = $parameters;
            $prevParameters['offset'] -= $prevParameters['limit'];
            if ($prevParameters['offset'] < 0) {
                $prevParameters['offset'] = 0;
            }
            $prev = $path . '?' . http_build_query($prevParameters);
        }

        $result = new \ezpRestMvcResult();
        $result->variables = [
            'items' => $response['data'],
            'self' => $path . '?' . http_build_query($parameters),
            'next' => $next,
            'prev' => $prev,
            'count' => $response['count'],
        ];

        return $result;
    }

    protected function generateOperationAdditionalProperties()
    {
        $properties = parent::generateOperationAdditionalProperties();
        $properties['parameters'] = $this->generateSearchParameters();

        return $properties;
    }

    protected function generateSearchParameters(): array
    {
        return [
            new OA\Parameter('id', OA\Parameter::IN_QUERY, 'Filter by service id', [
                'schema' => $this->generateSchemaProperty([
                    'type' => 'integer',
                    'nullable' => true,
                ]),
                'required' => false,
            ]),
            new OA\Parameter('office_id', OA\Parameter::IN_QUERY, 'Filter by office id', [
                'schema' => $this->generateSchemaProperty([
                    'type' => 'integer',
                    'nullable' => true,
                ]),
                'required' => false,
            ]),
            new OA\Parameter('place_id', OA\Parameter::IN_QUERY, 'Filter by place id', [
                'schema' => $this->generateSchemaProperty([
                    'type' => 'integer',
                    'nullable' => true,
                ]),
                'required' => false,
            ]),
            new OA\Parameter('calendar_id', OA\Parameter::IN_QUERY, 'Filter by calendar id', [
                'schema' => $this->generateSchemaProperty([
                    'type' => 'string',
                    'nullable' => true,
                ]),
                'required' => false,
            ]),
            new OA\Parameter('limit', OA\Parameter::IN_QUERY, 'Limit to restrict the number of entries on a page', [
                'schema' => $this->generateSchemaProperty(
                    ['type' => 'integer', 'minimum' => 1, 'default' => static::DEFAULT_LIMIT, 'nullable' => true]
                ),
            ]),
            new OA\Parameter(
                'offset',
                OA\Parameter::IN_QUERY,
                'Numeric offset of the first element provided on a page representing a collection request',
                [
                    'schema' => $this->generateSchemaProperty(['type' => 'integer', 'nullable' => true]),
                ]
            ),
        ];
    }

    protected function generateResponseList(): array
    {
        $resultSchema = new OA\Schema();
        $resultSchema->type = 'object';
        $resultSchema->properties = [
            'items' => $this->generateSchemaProperty(
                [
                    'type' => 'array',
                    'items' => new OA\Reference('#/components/schemas/' . $this->getSchemaFactories()[0]->getName()),
                ]
            ),
            'self' => $this->generateSchemaProperty(['type' => 'string', 'title' => 'Current result page']),
            'prev' => $this->generateSchemaProperty(
                ['type' => 'string', 'title' => 'Previous result page', 'nullable' => true]
            ),
            'next' => $this->generateSchemaProperty(
                ['type' => 'string', 'title' => 'Next result page', 'nullable' => true]
            ),
            'count' => $this->generateSchemaProperty(
                ['type' => 'integer', 'format' => 'int32', 'description' => 'Total number of items available.']
            ),
        ];

        return [
            '200' => new OA\Response('Successful response', [
                'application/json' => new OA\MediaType([
                    'schema' => $resultSchema,
                ]),
            ], $this->generateResponseHeaders()),
            '400' => new OA\Response('Invalid input provided.', null, $this->generateResponseHeaders(true)),
            '500' => new OA\Response('Internal error', null, $this->generateResponseHeaders(true)),
        ];
    }
}