<?php

use Opencontent\OpenApi\OperationFactory\GetOperationFactory;
use Opencontent\OpenApi\EndpointFactory;
use erasys\OpenApi\Spec\v3 as OA;
use Opencontent\OpenApi\OperationFactory\CacheAwareInterface;

class ServiceCategoryOperationFactory extends GetOperationFactory implements CacheAwareInterface
{
    private $allServiceObject = null;

    public function setResponseHeaders(EndpointFactory $endpointFactory, ezpRestMvcResult $result): void
    {
        if ($this->allServiceObject instanceof eZContentObject) {
            $nodeID = $this->allServiceObject->mainNodeID();
            header("Cache-Control: public, must-revalidate, max-age=10, s-maxage=259200"); //@todo make configurable
            header("X-Cache-Tags: node-{$nodeID}");
            header("Vary: Accept-Language");
        }
    }

    public function hasResponseHeaders(EndpointFactory $endpointFactory, ezpRestMvcResult $result): bool
    {
        return $this->allServiceObject instanceof eZContentObject;
    }

    public function handleCurrentRequest(EndpointFactory $endpointFactory)
    {
        $path = $endpointFactory->getBaseUri() . $endpointFactory->getPath();

        if ($this->getCurrentRequestLanguage() !== eZLocale::currentLocaleCode()) {
            $parts = explode('-', $this->getCurrentRequestLanguage());
            $locale = $parts[0];
            $accessName = sprintf(
                '%s_%s_frontend',
                OpenPABase::getCurrentSiteaccessIdentifier(),
                $locale
            );
            if (file_exists('settings/siteaccess/' . $accessName)) {
                eZSiteAccess::change([
                    'name' => $accessName,
                    'type' => eZSiteAccess::TYPE_STATIC,
                ]);
                eZINI::resetAllInstances(false);
                unset($GLOBALS['eZDBGlobalInstance']);
            }
        }

        $result = new \ezpRestMvcResult();
        $result->variables = [
            'items' => [],
            'self' => $path,
            'next' => null,
            'prev' => null,
            'count' => 0,
        ];
        $this->allServiceObject = eZContentObject::fetchByRemoteID('all-services');
        if ($this->allServiceObject instanceof eZContentObject) {
            $tagMenu = (array)OpenPAMenuTool::getTreeMenu([
                'root_node_id' => $this->allServiceObject->mainNodeID(),
                'scope' => 'side_menu',
                'hide_empty_tag' => true,
                'hide_empty_tag_callback',
                ['OpenPABootstrapItaliaOperators', 'tagTreeHasContents'],
            ]);
            foreach ($tagMenu['children'] as $item) {
                $result->variables['items'][] = [
                    'name' => $item['item']['name'],
                ];
            }
            $result->variables['count'] = count($result->variables['items']);
        }

        return $result;
    }

    /**
     * @return OA\Response[]
     */
    protected function generateResponseList()
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
            '500' => new OA\Response('Internal error', null, $this->generateResponseHeaders(true)),
        ];
    }

    protected function generateOperationAdditionalProperties()
    {
        $properties = parent::generateOperationAdditionalProperties();
        $properties['parameters'] = [
            $this->generateHeaderLanguageParameter(),
        ];

        return $properties;
    }

}