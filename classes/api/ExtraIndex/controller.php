<?php

use Opencontent\OpenApi\Exception as OpenApiException;
use Opencontent\OpenApi\Exceptions\InvalidPayloadException;
use Opencontent\Opendata\Api\Exception\BaseException;
use Opencontent\Opendata\Api\Exception\ForbiddenException;

class ExtraIndexController extends ezpRestMvcController
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
        $access = eZUser::currentUser()->hasAccessTo('extraindex', 'crud');
        if ($access['accessWord'] === 'no'){
            throw new ForbiddenException( 'of extra index', 'edit');
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

    private function parseInput()
    {
        $input = $this->request->body;
        $data = json_decode($input, true);
        if (json_last_error() != JSON_ERROR_NONE) {
            throw new InvalidPayloadException("Invalid json: " . json_last_error_msg(), 1);
        }
        $externalData = new ExternalDataDocument($data);
        if (!$externalData instanceof ExternalDataDocument || !$externalData->hasValidData()) {
            throw new InvalidPayloadException("Invalid payload", 1);
        }
        return $externalData;
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

    public function doPost()
    {
        try {
            $this->checkAccess();
            $externalData = $this->parseInput();
            if (!$this->solr->addExternalDataDocument($externalData)) {
                throw new RuntimeException("Error committing to solr", 1);
            }

            $result = new ezpRestMvcResult();
            $result->variables = ExternalDataDocument::fromSolrResult($this->solr->findExternalDocumentByGuid($externalData->getGuid()))
                ->jsonSerialize();

        } catch (Exception $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public function doGet()
    {
        try {
//            $this->checkAccess();
            $result = new ezpRestMvcResult();
            $raw = $this->solr->findExternalDocumentByGuid($this->item);
            $data = ExternalDataDocument::fromSolrResult($raw);
            $result->variables = isset($this->request->get['raw']) ?
                $raw : $data->jsonSerialize();
            header('cache-control: private no-cache no-store');
        } catch (Exception $e) {
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

    public function doDelete()
    {
        try {
            $this->checkAccess();
            try {
                $externalData = ExternalDataDocument::fromSolrResult($this->solr->findExternalDocumentByGuid($this->item));
                if (!$this->solr->removeExternalDataDocument($externalData->getGuid())) {
                    throw new RuntimeException("Error committing to solr", 1);
                }
            } catch (\Opencontent\OpenApi\Exceptions\NotFoundException $e) {
            }
            $result = new ezpRestMvcResult();
            $result->variables = [];
        } catch (Exception $e) {
            $result = $this->doExceptionResult($e);
        }

        return $result;
    }

    public static function getServerUrl()
    {
        $endoint = '/api/extraindex/v1/';
        eZURI::transformURI($endoint, false, 'full');
        return $endoint;
    }

    private function getDocumentation()
    {
        $siteIni = eZINI::instance();
        $inPathParameter = [
            'name' => 'documentId',
            'in' => 'path',
            'description' => 'Document guid',
            'required' => 'true',
            'schema' => [
                'type' => 'string'
            ]
        ];
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
        return [
            'openapi' => '3.0.1',
            'info' => [
                'x-ApiId' => 'opencity-extraindex-1',
                'x-Audience' => 'internal',
                'title' => $siteIni->variable('SiteSettings', 'SiteName') . ' Extra Document API',
                'version' => '1.0.0 alpha',
                'description' => 'Web service to create and manage extra index content in search engine',
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
                ['name' => 'Document']
            ],
            'paths' => [
                '/document' => [
                    'post' => [
                        'tags' => ['Document'],
                        'operationId' => 'postExtraDocument',
                        'responses' => [
                            200 => [
                                'description' => 'Successful response',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            '$ref' => '#/components/schemas/Document'
                                        ]
                                    ]
                                ]
                            ],
                            400 => [
                                'description' => 'Invalid payload',
                                'headers' => $errorHeaders
                            ],
                            404 => [
                                'description' => 'Document not found',
                                'headers' => $errorHeaders
                            ],
                        ],
                        'parameters' => [],
                        'requestBody' => [
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        '$ref' => '#/components/schemas/Document'
                                    ]
                                ]
                            ]
                        ]
                    ],
                ],
                '/document/{documentId}' => [
                    'get' => [
                        'tags' => ['Document'],
                        'operationId' => 'getExtraDocument',
                        'responses' => [
                            200 => [
                                'description' => 'Successful response',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            '$ref' => '#/components/schemas/Document'
                                        ]
                                    ]
                                ]
                            ],
                            404 => [
                                'description' => 'Document not found',
                                'headers' => $errorHeaders,
                            ]
                        ],
                        'parameters' => [$inPathParameter]
                    ],
                    'put' => [
                        'tags' => ['Document'],
                        'operationId' => 'putExtraDocument',
                        'responses' => [
                            200 => [
                                'description' => 'Successful response',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            '$ref' => '#/components/schemas/Document'
                                        ]
                                    ]
                                ]
                            ],
                            400 => [
                                'description' => 'Invalid payload',
                                'headers' => $errorHeaders,
                            ],
                            404 => [
                                'description' => 'Document not found',
                                'headers' => $errorHeaders,
                            ]
                        ],
                        'parameters' => [$inPathParameter],
                        'requestBody' => [
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        '$ref' => '#/components/schemas/Document'
                                    ]
                                ]
                            ]
                        ]
                    ],
                    'delete' => [
                        'tags' => ['Document'],
                        'operationId' => 'deleteExtraDocument',
                        'responses' => [
                            200 => [
                                'description' => 'Successful response',
                            ],
                            400 => [
                                'description' => 'Invalid payload',
                                'headers' => $errorHeaders,
                            ],
                            404 => [
                                'description' => 'Document not found',
                                'headers' => $errorHeaders,
                            ]
                        ],
                        'parameters' => [$inPathParameter],
                    ],
                ]
            ],
            'components' => [
                'schemas' => [
                    'Document' => [
                        'title' => 'Document',
                        'type' => 'object',
                        'properties' => [
                            'guid' => [
                                'description' => 'Document unique identifier',
                                'type' => 'string',
                            ],
                            'source_name' => [
                                'description' => 'Source name',
                                'type' => 'string',
                            ],
                            'source_uri' => [
                                'description' => 'Source uri',
                                'type' => 'string',
                            ],
                            'uri' => [
                                'description' => 'Document target uri',
                                'type' => 'string',
                            ],
                            'name' => [
                                'description' => 'Document title',
                                'type' => 'string',
                            ],
                            'abstract' => [
                                'description' => 'Document abstract',
                                'type' => 'string',
                            ],
                            'published_at' => [
                                'description' => 'Document publication date',
                                'type' => 'string',
                                'format' => 'date',
                            ],
                            'modified_at' => [
                                'description' => 'Document modification date',
                                'type' => 'string',
                                'format' => 'date',
                            ],
                            'attachments' => [
                                'description' => '',
                                'type' => 'array',
                                'items' => [
                                    'type' => 'object',
                                    'properties' => [
                                        'name' => [
                                            'description' => 'Attachment title',
                                            'type' => 'string',
                                        ],
                                        'uri' => [
                                            'description' => 'Attachment uri',
                                            'type' => 'string',
                                        ],
                                    ],
                                    'required' => [
                                        'uri',
                                        'name',
                                    ],
                                ]
                            ],
                            'class_identifier' => [
                                'description' => 'Content class identifier',
                                'type' => 'string',
                            ],
                        ],
                        'required' => [
                            'guid',
                            'image',
                            'source_name',
                            'source_uri',
                            'uri',
                            'name',
                            'abstract',
                        ],
                    ]
                ],
                'requestBodies' => [
                    'Document' => [
                        'content' => [
                            'application/json' => [
                                'schema' => [
                                    '$ref' => '#/components/schemas/Document'
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