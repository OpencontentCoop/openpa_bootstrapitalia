<?php

use Opencontent\OpenApi\Exception as OpenApiException;
use Opencontent\OpenApi\Exceptions\InvalidPayloadException;
use Opencontent\Opendata\Api\Exception\BaseException;
use Opencontent\Opendata\Api\Exception\ForbiddenException;

class CollectInefficiencyController extends ezpRestMvcController
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

    private function getPayload()
    {
        $input = $this->request->body;
        if (empty($input)) {
            throw new InvalidPayloadException("Empty payload", 1);
        }
        $data = json_decode($input, true);
        if (json_last_error() != JSON_ERROR_NONE) {
            throw new InvalidPayloadException("Invalid json: " . json_last_error_msg(), 1);
        }

        return $data;
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

    public function doCollect()
    {
        try {
            $result = new ezpRestMvcResult();
            $result->variables = CollectInefficiency::instance()
                ->collect($this->getPayload());
        } catch (Exception $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public function doEndpoint()
    {
        if (in_array('text/html', $this->request->accept->types)) {
            $tpl = eZTemplate::factory();
            $tpl->setVariable('endpoint_url', self::getServerUrl() . '/');
            echo $tpl->fetch('design:openapi.tpl');
            eZExecution::cleanExit();
        }

        $result = new ezpRestMvcResult();
        $result->variables = $this->getDocumentation();

        return $result;
    }

    public static function getServerUrl()
    {
        $endoint = '/api/inefficiency/v1/';
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
        return [
            'openapi' => '3.0.1',
            'info' => [
                'x-ApiId' => 'opencity-collect-inefficiency-1',
                'x-Audience' => 'internal',
                'title' => $siteIni->variable('SiteSettings', 'SiteName') . ' Collect inefficiency informations',
                'version' => '1.0.0 alpha',
                'description' => 'Web service to collect inefficiency webhook',
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
                ['name' => 'Collect inefficiency'],
            ],
            'paths' => [
                '/collect' => [
                    'post' => [
                        'tags' => ['Collect inefficiency'],
                        'operationId' => 'postInefficiency',
                        'responses' => [
                            200 => [
                                'description' => 'Inefficiency webhook collected',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            '$ref' => '#/components/schemas/InefficiencyCollect',
                                        ],
                                    ],
                                ],
                            ],
                            400 => [
                                'description' => 'Invalid payload',
                                'headers' => $errorHeaders,
                            ],
                        ],
                        'parameters' => [],
                        'requestBody' => [
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        '$ref' => '#/components/schemas/InefficiencyApplication',
                                    ],
                                ],
                            ],
                        ],
                    ],
                ],
            ],
            'components' => [
                'schemas' => [
                    'InefficiencyCollect' => [
                        'title' => 'InefficiencyCollect',
                        'type' => 'object',
                        'properties' => [
                            'action' => [
                                'type' => 'string',
                                'enum' => ['create', 'update', 'delete'],
                            ],
                            'payload' => [
                                'type' => 'object',
                                'properties' => [
                                    'uuid' => [
                                        'type' => 'string',
                                    ],
                                    'subject' => [
                                        'type' => 'string',
                                    ],
                                    'category' => [
                                        'type' => 'string',
                                    ],
                                    'text' => [
                                        'type' => 'string',
                                    ],
                                    'address' => [
                                        'type' => 'string',
                                    ],
                                    'geo' => [
                                        'type' => 'string',
                                    ],
                                    'published' => [
                                        'type' => 'string',
                                    ],
                                    'status' => [
                                        'type' => 'string',
                                    ],
                                    'image1' => [
                                        'type' => 'string',
                                    ],
                                    'image2' => [
                                        'type' => 'string',
                                    ],
                                    'image3' => [
                                        'type' => 'string',
                                    ],
                                    'source' => [
                                        'type' => 'string',
                                    ],
                                ],
                            ],
                        ],
                    ],
                    'InefficiencyApplication' => [
                        'title' => 'InefficiencyApplication',
                        'type' => 'object',
                        'properties' => [
                            'tenant' => [
                                'type' => 'string',
                                'format' => 'uuid',
                            ],
                            'id' => [
                                'type' => 'string',
                                'format' => 'uuid',
                            ],
                            'backoffice_data' => [
                                'type' => 'object',
                                'properties' => [
                                    'is_public' => [
                                        'type' => 'boolean',
                                    ],
                                ],
                                'required' => [
                                    'is_public',
                                ],
                            ],
                            'data' => [
                                'type' => 'object',
                                'properties' => [
                                    'subject' => [
                                        'type' => 'string',
                                        'example' => 'Problema a un tombino',
                                    ],
                                    'details' => [
                                        'type' => 'string',
                                        'example' => 'Un tombino in via Roma ha una perdita',
                                    ],
                                    'status' => [
                                        'type' => 'integer',
                                        'example' => 4000,
                                    ],
                                    'published' => [
                                        'type' => 'integer',
                                        'example' => time(),
                                    ],
                                    'type' => [
                                        'type' => 'object',
                                        'properties' => [
                                            'label' => [
                                                'type' => 'string',
                                                'example' => 'Manutenzione',
                                            ],
                                        ],
                                    ],
                                    'address' => [
                                        'type' => 'object',
                                        'properties' => [
                                            'display_name' => [
                                                'type' => 'string',
                                                'example' => 'Via Roma 1',
                                            ],
                                            'lat' => [
                                                'type' => 'number',
                                                'example' => '44.2604945',
                                            ],
                                            'lon' => [
                                                'type' => 'number',
                                                'example' => '9.6777915',
                                            ],
                                        ],
                                    ],
                                    'images' => [
                                        'type' => 'array',
                                        'items' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'url' => [
                                                    'type' => 'string',
                                                    'format' => 'uri',
                                                    'example' => 'https://s3-eu-west-1.amazonaws.com/static.opencity.opencontent.it/installer/opencityitalia.png',
                                                ],
                                            ],
                                        ],
                                    ],
                                ],
                            ],
                        ],
                        'required' => [
                            'id',
                            'tenant',
                            'backoffice_data',
                        ],
                    ],
                ],
                'requestBodies' => [
                    'InefficiencyDocument' => [
                        'content' => [
                            'application/json' => [
                                'schema' => [
                                    '$ref' => '#/components/schemas/InefficiencyApplication',
                                ],
                            ],
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