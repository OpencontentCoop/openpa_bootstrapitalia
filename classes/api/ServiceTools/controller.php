<?php

use Opencontent\OpenApi\Exception as OpenApiException;
use Opencontent\OpenApi\Exceptions\InvalidPayloadException;
use Opencontent\Opendata\Api\Exception\BaseException;
use Opencontent\Opendata\Api\Exception\ForbiddenException;

class ServiceToolsController extends ezpRestMvcController
{
    /**
     * @var ezpRestRequest
     */
    protected $request;

    protected $solr;

    public function __construct($action, ezcMvcRequest $request)
    {
        $this->solr = new eZSolrExternalDataAware();
        parent::__construct($action, $request);
    }

    private function checkAccess()
    {
        $access = eZUser::currentUser()->hasAccessTo('bootstrapitalia', 'service_tools');
        if ($access['accessWord'] === 'no'){
            throw new ForbiddenException( 'about service tools', 'edit');
        }
    }

    public function doPut()
    {
        try {
            $this->checkAccess();
            $selected = ExternalDataDocument::fromSolrResult($this->solr->findExternalDocumentByGuid($this->item));
            $externalData = $this->parseInput();
            $externalData->setGuid($selected->getGuid());
            if (!$this->solr->addExternalDataDocument($externalData)) {
                throw new RuntimeException("Error committing to solr", 1);
            }

            $result = new ezpRestMvcResult();
            $result->variables = ExternalDataDocument::fromSolrResult($this->solr->findExternalDocumentByGuid($selected->getGuid()))
                ->jsonSerialize();

        } catch (Exception $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    private function getUuidPayload()
    {
        $input = $this->request->body;
        $data = json_decode($input, true);
        if (json_last_error() != JSON_ERROR_NONE) {
            throw new InvalidPayloadException("Invalid json: " . json_last_error_msg(), 1);
        }
        if (!isset($data['uuid']) && !isset($data['identifier'])){
            throw new InvalidPayloadException('uuid or identifier', 'missing value');
        }
        if (!isset($data['uuid'])){
            $service = StanzaDelCittadinoBridge::factory()->getServiceByIdentifier($data['identifier']);
            $data['uuid'] = $service['id'];
        }

        return $data['uuid'];
    }

    private function doExceptionResult(Exception $exception)
    {
        $result = new ezcMvcResult;
        $result->variables['message'] = $exception->getMessage();

        $serverErrorCode = 500;
        $errorType = OpenApiException::cleanErrorCode(get_class($exception));

        if ($exception instanceof BaseException) {
            $serverErrorCode = $exception->getServerErrorCode();
            $errorType = $exception->getErrorType();
        }
        $result->status = new OpenApiErrorResponse(
            $serverErrorCode,
            $exception->getMessage(),
            $errorType,
            $exception
        );

        return $result;
    }

    public function doGetTenantInfo()
    {
        try {
            $this->checkAccess();
            $bridge = StanzaDelCittadinoBridge::factory();
            $result = new ezpRestMvcResult();
            $result->variables = $bridge->getTenantInfo();

        } catch (Throwable $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public function doGetMetaInfo()
    {
        try {
            $this->checkAccess();
            $result = new ezpRestMvcResult();
            $result->variables = StanzaDelCittadinoBridge::factory()->getSiteInfoToUpdate();

        } catch (Throwable $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public function doSyncService()
    {
        try {
            $this->checkAccess();
            $bridge = StanzaDelCittadinoBridge::factory();
            $result = new ezpRestMvcResult();
            $result->variables = ['url' => $bridge->updateServiceStatus($this->getUuidPayload())];

        } catch (Throwable $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public function doInstallService()
    {
        try {
            $this->checkAccess();
            $bridge = StanzaDelCittadinoBridge::factory();
            $result = new ezpRestMvcResult();
            $result->variables = ['url' => $bridge->importService($this->getUuidPayload())];

        } catch (Throwable $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public function doEndpoint()
    {
        $result = new ezpRestMvcResult();
        $result->variables = $this->getDocumentation();

        return $result;
    }

    public static function getServerUrl()
    {
        $endoint = '/api/servicetools/v1/';
        eZURI::transformURI($endoint, false, 'full');
        return $endoint;
    }

    private function getDocumentation()
    {
        $siteIni = eZINI::instance();
        $errorHeaders = [
            'x-Api-Error-Type' => [
                'schema' => [
                    'type' => 'string'
                ]
            ],
            'x-Api-Error-Message' => [
                'schema' => [
                    'type' => 'string'
                ]
            ],
        ];
        $responses = [
            200 => [
                'description' => 'Restituisce l\'url del servizio presente in questo sito',
                'content' => [
                    'application/json' => [
                        'schema' => ['$ref' => '#/components/schemas/PublicServiceUrl']
                    ]
                ]
            ],
            400 => [
                'description' => 'Invalid payload',
                'headers' => $errorHeaders
            ],
            403 => [
                'description' => 'Forbidden',
                'headers' => $errorHeaders
            ],
            500 => [
                'description' => 'Internal error',
                'headers' => $errorHeaders
            ],
        ];
        $requestBody = [
            'content' => [
                'application/json' => [
                    'schema' => [
                        'oneOf' => [
                            ['$ref' => '#/components/schemas/ServiceUuid'],
                            ['$ref' => '#/components/schemas/ServiceIdentifier'],
                        ]
                    ],
                    'examples' => [
                        'by-identifier' => [
                            'summary' => 'Request by identifier',
                            'value' => [
                                'identifier' => 'oc-pnrr-xxx'
                            ]
                        ],
                        'by-uuid' => [
                            'summary' => 'Request by uuid',
                            'value' => [
                                'uuid' => '1977f7ee-dbc2-4a0f-bb0a-36b00fc1fcac'
                            ]
                        ]
                    ]
                ]
            ]
        ];
        return [
            'openapi' => '3.0.1',
            'info' => [
                'x-ApiId' => 'opencity-servicetools-1',
                'x-Audience' => 'internal',
                'title' => $siteIni->variable('SiteSettings', 'SiteName') . ' Service Tools API',
                'version' => '1.0.0 alpha',
                'description' => 'Servizio ad uso interno per la sincronizzazione delle schede dei servizi',
                'termsOfService' => '',
                'contact' => [
                    'email' => 'support@opencontent.it'
                ],
                'license' => [
                    'name' => 'GNU General Public License, version 2',
                    'url' => 'https://www.gnu.org/licenses/old-licenses/gpl-2.0.html'
                ]
            ],
            'tags' => [
                ['name' => 'Tenant'],
                ['name' => 'Servizi'],
            ],
            'paths' => [
                '/sync_service' => [
                    'post' => [
                        'tags' => ['Servizi'],
                        'description' => 'Aggiorna lo stato del servizio dopo aver verificato che l\'area personale collegata al sito  offra il servizio.',
                        'operationId' => 'syncServiceTools',
                        'responses' => $responses,
                        'parameters' => [],
                        'requestBody' => $requestBody
                    ],
                ],
                '/install_service' => [
                    'post' => [
                        'tags' => ['Servizi'],
                        'description' => 'Installa la scheda del servizio dopo aver verificato che il sito prototipo offra il servizio e che l\'area personale collegata al sito offra il servizio.',
                        'operationId' => 'installServiceTools',
                        'responses' => $responses,
                        'parameters' => [],
                        'requestBody' => $requestBody
                    ],
                ],
                '/tenant_info' => [
                    'get' => [
                        'tags' => ['Tenant'],
                        'description' => 'Ottiene le informazioni sul tenant collegato',
                        'operationId' => 'getTenantInfo',
                        'responses' => [
                            200 => [
                                'description' => 'Successful response',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object'
                                        ]
                                    ]
                                ]
                            ],
                            403 => [
                                'description' => 'Forbidden',
                                'headers' => $errorHeaders
                            ],
                            500 => [
                                'description' => 'Internal error',
                                'headers' => $errorHeaders
                            ],
                        ],
                        'parameters' => [],
                    ],
                ],
                '/meta_info' => [
                    'get' => [
                        'tags' => ['Tenant'],
                        'description' => 'Ottiene le informazioni sul sito corrente utili all\'aggiornamento del tenant collegato',
                        'operationId' => 'getMetaInfo',
                        'responses' => [
                            200 => [
                                'description' => 'Successful response',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object'
                                        ]
                                    ]
                                ]
                            ],
                            403 => [
                                'description' => 'Forbidden',
                                'headers' => $errorHeaders
                            ],
                            500 => [
                                'description' => 'Internal error',
                                'headers' => $errorHeaders
                            ],
                        ],
                        'parameters' => [],
                    ],
                ],
            ],
            'components' => [
                'schemas' => [
                    'PublicServiceUrl' => [
                        'title' => 'PublicServiceUrl',
                        'type' => 'object',
                        'properties' => [
                            'url' => [
                                'description' => 'Service url',
                                'type' => 'string',
                                'format' => 'uri',
                            ],
                        ],
                        'required' => [
                            'url',
                        ],
                    ],
                    'ServiceUuid' => [
                        'title' => 'ServiceUuid',
                        'type' => 'object',
                        'properties' => [
                            'uuid' => [
                                'description' => 'Service uuid',
                                'type' => 'string',
                                'format' => 'uuid',
                            ],
                        ],
                        'required' => [
                            'uuid',
                        ],
                    ],
                    'ServiceIdentifier' => [
                        'title' => 'ServiceIdentifier',
                        'type' => 'object',
                        'properties' => [
                            'identifier' => [
                                'description' => 'Service unique identifier',
                                'type' => 'string',
                            ],
                        ],
                        'required' => [
                            'identifier',
                        ],
                    ]
                ],
                'requestBodies' => [
                    'ServiceUuid' => [
                        'content' => [
                            'application/json' => [
                                'schema' => [
                                    '$ref' => '#/components/schemas/ServiceUuid'
                                ]
                            ]
                        ]
                    ],
                    'ServiceIdentifier' => [
                        'content' => [
                            'application/json' => [
                                'schema' => [
                                    '$ref' => '#/components/schemas/ServiceIdentifier'
                                ]
                            ]
                        ]
                    ]
                ],
                'securitySchemes' => [
                    'basicAuth' => [
                        'type' => 'http',
                        'scheme'=> 'basic'
                    ]
                ]
            ],
            'security' => [
                ['basicAuth' => []]
            ],
            'servers' => [
                ['url' => self::getServerUrl(), 'description' => 'Production server']
            ]
        ];
    }
}