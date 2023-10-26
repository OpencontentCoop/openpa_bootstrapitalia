<?php

use Opencontent\OpenApi\Exception as OpenApiException;
use Opencontent\OpenApi\Exceptions\InvalidPayloadException;
use Opencontent\Opendata\Api\Exception\BaseException;
use Opencontent\Opendata\Api\Exception\ForbiddenException;
use Opencontent\Opendata\Api\Exception\NotFoundException;

class ServiceToolsController extends ezpRestMvcController
{
    /**
     * @var ezpRestRequest
     */
    protected $request;

    protected $solr;

    private static $statuses = [
        'Servizio attivo',
        'Servizio non attivo',
        'In fase di sviluppo',
    ];

    public function __construct($action, ezcMvcRequest $request)
    {
        $this->solr = new eZSolrExternalDataAware();
        parent::__construct($action, $request);
    }

    private function checkAccess()
    {
        $access = eZUser::currentUser()->hasAccessTo('bootstrapitalia', 'service_tools');
        if ($access['accessWord'] === 'no') {
            throw new ForbiddenException('about service tools', 'edit');
        }
    }

    private function getPayload()
    {
        $input = $this->request->body;
        $data = json_decode($input, true);
        if (json_last_error() != JSON_ERROR_NONE) {
            throw new InvalidPayloadException("Invalid json: " . json_last_error_msg(), 1);
        }

        return $data;
    }

    private function doExceptionResult(Throwable $exception)
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
            $exception instanceof Exception ? $exception : null
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

    public function doGetServiceByIdentifier()
    {
        try {
            $this->checkAccess();
            $bridge = StanzaDelCittadinoBridge::factory();
            $result = new ezpRestMvcResult();
            $result->variables = ['url' => $bridge->hasServiceByIdentifier((string)$this->request->variables['identifier'])];
        } catch (Throwable $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public function doInstallServiceByIdentifier()
    {
        try {
            $this->checkAccess();
            $bridge = StanzaDelCittadinoBridge::factory();
            $result = new ezpRestMvcResult();
            $result->variables = ['url' => $bridge->importServiceByIdentifier($this->request->variables['identifier'])];
        } catch (Throwable $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public function doReinstallServiceByIdentifier()
    {
        try {
            $this->checkAccess();
            $bridge = StanzaDelCittadinoBridge::factory();
            $result = new ezpRestMvcResult();
            $result->variables = ['url' => $bridge->importServiceByIdentifier($this->request->variables['identifier'], true)];
        } catch (Throwable $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public function doSyncServiceStatusByIdentifier()
    {
        try {
            $this->checkAccess();
            $bridge = StanzaDelCittadinoBridge::factory();
            $result = new ezpRestMvcResult();
            $payload = $this->getPayload();
            $status = $payload['status'] ?? null;
            if (!$status) {
                throw new InvalidPayloadException('status', 'missing value');
            }
            if (!in_array($status, self::$statuses)) {
                throw new InvalidPayloadException('status', $status);
            }
            $message = $payload['message'] ?? null;
            $result->variables = [
                'url' => $bridge->updateServiceStatusByIdentifier(
                    $this->request->variables['identifier'],
                    $status,
                    $message
                ),
            ];
        } catch (Throwable $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    private function updateServiceChannelByIdentifier($type)
    {
        try {
            $this->checkAccess();
            $bridge = StanzaDelCittadinoBridge::factory();
            $result = new ezpRestMvcResult();
            $payload = $this->getPayload();
            $url = $payload['url'] ?? null;
            if (!$url) {
                throw new InvalidPayloadException('url', 'missing value');
            }
            $label = $payload['label'] ?? null;
            $result->variables = [
                'url' => $bridge->updateServiceChannelByIdentifier(
                    $this->request->variables['identifier'],
                    $type,
                    $url,
                    $label
                ),
            ];
        } catch (Throwable $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public function doSyncServiceBookingUrlByIdentifier()
    {
        return $this->updateServiceChannelByIdentifier('booking');
    }

    public function doSyncServiceAccessUrlByIdentifier()
    {
        return $this->updateServiceChannelByIdentifier('access');
    }

    public function doEndpoint()
    {
        $result = new ezpRestMvcResult();
        $result->variables = $this->getDocumentation();

        return $result;
    }

    public function doSetTenantUrl()
    {
        try {
            $this->checkAccess();
            $bridge = StanzaDelCittadinoBridge::factory();
            $result = new ezpRestMvcResult();
            $payload = $this->getPayload();
            $url = $payload['url'] ?? null;
            if (!$url) {
                throw new InvalidPayloadException('url', 'missing value');
            }
            $result->variables = $bridge->setTenantByUrl($url);
        } catch (Throwable $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public function doGetTenantUrl()
    {
        try {
            $this->checkAccess();
            $bridge = StanzaDelCittadinoBridge::factory();
            $result = new ezpRestMvcResult();
            $result->variables = ['url' => $bridge->getTenantUri()];
        } catch (Throwable $e) {
            $result = $this->doExceptionResult($e);
        }

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
                    'type' => 'string',
                ],
            ],
            'x-Api-Error-Message' => [
                'schema' => [
                    'type' => 'string',
                ],
            ],
        ];
        $responses = [
            200 => [
                'description' => 'Restituisce l\'url del servizio presente in questo sito',
                'content' => [
                    'application/json' => [
                        'schema' => ['$ref' => '#/components/schemas/Url'],
                    ],
                ],
            ],
            400 => [
                'description' => 'Invalid payload',
                'headers' => $errorHeaders,
            ],
            403 => [
                'description' => 'Forbidden',
                'headers' => $errorHeaders,
            ],
            404 => [
                'description' => 'Not found',
                'headers' => $errorHeaders,
            ],
            500 => [
                'description' => 'Internal error',
                'headers' => $errorHeaders,
            ],
        ];
        $inPathParams = [
            'in' => 'path',
            'name' => 'identifier',
            'required' => true,
            'schema' => [
                'type' => 'string',
            ],
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
                    'email' => 'support@opencontent.it',
                ],
                'license' => [
                    'name' => 'GNU General Public License, version 2',
                    'url' => 'https://www.gnu.org/licenses/old-licenses/gpl-2.0.html',
                ],
            ],
            'tags' => [
                ['name' => 'Tenant'],
                ['name' => 'Servizi'],
            ],
            'paths' => [
                '/service/{identifier}' => [
                    'get' => [
                        'tags' => ['Servizi'],
                        'description' => 'Restituisce l\'url del servizio in base all\'identificatore',
                        'operationId' => 'readServiceTools',
                        'responses' => $responses,
                        'parameters' => [$inPathParams],
                    ],
                    'post' => [
                        'tags' => ['Servizi'],
                        'description' => 'Installa la scheda del servizio clonandola dal sito prototipo ' . StanzaDelCittadinoBridge::getServiceContentPrototypeBaseUrl(
                            ),
                        'operationId' => 'installServiceTools',
                        'responses' => $responses,
                        'parameters' => [$inPathParams],
                    ],
                    'put' => [
                        'tags' => ['Servizi'],
                        'description' => 'Reinstalla la scheda del servizio clonandola dal sito prototipo ' . StanzaDelCittadinoBridge::getServiceContentPrototypeBaseUrl(
                            ),
                        'operationId' => 'reinstallServiceTools',
                        'responses' => $responses,
                        'parameters' => [$inPathParams],
                    ],
                ],
                '/service/{identifier}/status' => [
                    'put' => [
                        'tags' => ['Servizi'],
                        'description' => 'Aggiorna lo stato del servizio',
                        'operationId' => 'syncStatusServiceTools',
                        'responses' => $responses,
                        'parameters' => [$inPathParams],
                        'requestBody' => [
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        '$ref' => '#/components/schemas/ServiceStatus',
                                    ],
                                ],
                            ],
                        ],
                    ],
                ],
                '/service/{identifier}/access_url' => [
                    'put' => [
                        'tags' => ['Servizi'],
                        'description' => 'Aggiorna il canale digitale con l\'url di accesso al servizio',
                        'operationId' => 'syncAccessUrlServiceTools',
                        'responses' => $responses,
                        'parameters' => [$inPathParams],
                        'requestBody' => [
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        '$ref' => '#/components/schemas/Link',
                                    ],
                                ],
                            ],
                        ],
                    ],
                ],
                '/service/{identifier}/booking_call_to_action' => [
                    'put' => [
                        'tags' => ['Servizi'],
                        'description' => 'Aggiorna il canale digitale con l\'url di accesso alla prenotazione di un appuntamento per il servizio',
                        'operationId' => 'syncBookingUrlServiceTools',
                        'responses' => $responses,
                        'parameters' => [$inPathParams],
                        'requestBody' => [
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        '$ref' => '#/components/schemas/Link',
                                    ],
                                ],
                            ],
                        ],
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
                                            'type' => 'object',
                                        ],
                                    ],
                                ],
                            ],
                            403 => [
                                'description' => 'Forbidden',
                                'headers' => $errorHeaders,
                            ],
                            500 => [
                                'description' => 'Internal error',
                                'headers' => $errorHeaders,
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
                                            'type' => 'object',
                                        ],
                                    ],
                                ],
                            ],
                            403 => [
                                'description' => 'Forbidden',
                                'headers' => $errorHeaders,
                            ],
                            500 => [
                                'description' => 'Internal error',
                                'headers' => $errorHeaders,
                            ],
                        ],
                        'parameters' => [],
                    ],
                ],
                '/tenant_url' => [
                    'get' => [
                        'tags' => ['Tenant'],
                        'description' => 'Ottiene le informazioni sul collegamento a area personale.',
                        'operationId' => 'getTenantUrl',
                        'responses' => [
                            200 => [
                                'description' => 'Successful response',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object',
                                        ],
                                    ],
                                ],
                            ],
                            403 => [
                                'description' => 'Forbidden',
                                'headers' => $errorHeaders,
                            ],
                            500 => [
                                'description' => 'Internal error',
                                'headers' => $errorHeaders,
                            ],
                        ],
                        'parameters' => [],
                    ],
                    'post' => [
                        'tags' => ['Tenant'],
                        'description' => 'Aggiorna il collegamento a area personale. L\'url inserito deve comprendere il suffisso (esempio: https://servizi.comune.bugliano.pi.it/lang)',
                        'operationId' => 'setTenantUrl',
                        'responses' => [
                            200 => [
                                'description' => 'Successful response',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object',
                                        ],
                                    ],
                                ],
                            ],
                            403 => [
                                'description' => 'Forbidden',
                                'headers' => $errorHeaders,
                            ],
                            500 => [
                                'description' => 'Internal error',
                                'headers' => $errorHeaders,
                            ],
                        ],
                        'parameters' => [],
                        'requestBody' => [
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        '$ref' => '#/components/schemas/Url',
                                    ],
                                ],
                            ],
                        ],
                    ],
                ],
            ],
            'components' => [
                'schemas' => [
                    'Url' => [
                        'title' => 'Url',
                        'type' => 'object',
                        'properties' => [
                            'url' => [
                                'description' => 'Url string',
                                'type' => 'string',
                                'format' => 'uri',
                            ],
                        ],
                        'required' => [
                            'url',
                        ],
                    ],
                    'Link' => [
                        'title' => 'Link',
                        'type' => 'object',
                        'properties' => [
                            'url' => [
                                'description' => 'Link url',
                                'type' => 'string',
                                'format' => 'uri',
                            ],
                            'label' => [
                                'description' => 'Link label',
                                'type' => 'string',
                            ],
                        ],
                        'required' => [
                            'url',
                            'label',
                        ],
                    ],
                    'ServiceStatus' => [
                        'title' => 'ServiceStatus',
                        'type' => 'object',
                        'properties' => [
                            'status' => [
                                'description' => 'Status string',
                                'type' => 'string',
                                'enum' => self::$statuses,
                            ],
                            'message' => [
                                'description' => 'Status message',
                                'type' => 'string',
                            ],
                        ],
                        'required' => [
                            'status',
                        ],
                    ],
                ],
                'securitySchemes' => [
                    'basicAuth' => [
                        'type' => 'http',
                        'scheme' => 'basic',
                    ],
                ],
            ],
            'security' => [
                ['basicAuth' => []],
            ],
            'servers' => [
                ['url' => self::getServerUrl(), 'description' => 'Production server'],
            ],
        ];
    }
}