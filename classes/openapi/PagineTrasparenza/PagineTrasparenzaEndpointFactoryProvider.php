<?php

use eZContentObject;
use Opencontent\OpenApi\EndpointDiscover\AbstractSlugClassesEntryPointFactoryProvider;
use Opencontent\OpenApi\EndpointDiscover\Utils;
use Opencontent\OpenApi\EndpointFactory;
use Opencontent\OpenApi\OperationFactory\ContentObject\ReadOperationFactory;
use Opencontent\OpenApi\OperationFactoryCollection;
use OpenPAMenuTool;

class PagineTrasparenzaEndpointFactoryProvider extends AbstractSlugClassesEntryPointFactoryProvider
{
    const TRASPARENZA_REMOTE_ID = '5399ef12f98766b90f1804e5d52afd75';

    private static $nodeIdMap;

    protected function getSlugLabel()
    {
        return 'page';
    }

    protected function getPrefix()
    {
        return '/trasparenza';
    }

    protected function getClassIdentifiers()
    {
        return ['link', 'document', 'pagina_trasparenza'];
    }

    protected function getTag()
    {
        return 'trasparenza';
    }

    public static function generateSlug($name, $id): string
    {
        $slug = \eZCharTransform::instance()->transformByGroup($name, 'identifier');
        if (strlen($slug) > 100) {
            $substr = substr($slug, 0, 100);
            $lastUnderscore = strrpos($substr, " ");
            $slug = substr($substr, 0, $lastUnderscore);
        }
        if (!empty($slug)) {
            if (isset(self::$nodeIdMap[$slug]) && self::$nodeIdMap[$slug] != $id) {
                $slug .= '-' . $id;
            }
        }

        return $slug;
    }

    protected function getSlugIdMap()
    {
        $trasparenzaRoot = eZContentObject::fetchByRemoteID(self::TRASPARENZA_REMOTE_ID);
        if ($trasparenzaRoot instanceof eZContentObject) {
            if (self::$nodeIdMap === null) {
                self::$nodeIdMap = [];
                $menu = OpenPAMenuTool::getTreeMenu([
                    'root_node_id' => $trasparenzaRoot->mainNodeID(),
                    'user_hash' => false,
                    'scope' => 'side_menu',
                ]);
                self::recursiveFindNodeIdMap($menu);
            }
        }
        return self::$nodeIdMap;
    }

    private static function recursiveFindNodeIdMap($menu)
    {
        foreach ($menu['children'] as $item) {
            $slug = self::generateSlug($item['item']['name'], $item['item']['node_id']);
            if (!empty($slug)) {
                self::$nodeIdMap[$slug] = $item['item']['node_id'];
                self::recursiveFindNodeIdMap($item);
            }
        }
    }

    protected function build()
    {
        $prefix = $this->getPrefix();
        $classes = $this->getClassIdentifiers();
        $nodeIdMap = (array)$this->getSlugIdMap();
        $tag = $this->getTag();
        $endpoints = [];

        if (count($nodeIdMap)) {
            $slugEnum = array_keys($nodeIdMap);
            $slugLabel = $this->getSlugLabel();
            sort($slugEnum);

            $path = $prefix . '/{' . $slugLabel . '}';
            $endpoints[$path] = (new EndpointFactory\SlugClassesEntryPointFactory(
                $slugLabel,
                $classes,
                $nodeIdMap,
                $this->getSerializer()
            ))
                ->setPath($path)
                ->addTag($tag)
                ->setOperationFactoryCollection(
                    new OperationFactoryCollection([
                        (new PagineTrasparenzaSearchOperationFactory($nodeIdMap, $slugLabel, $slugEnum)),
                        (new PagineTrasparenzaCreateOperationFactory($nodeIdMap, $slugLabel, $slugEnum)),
                    ])
                );

            $path = $prefix . '/{' . $slugLabel . '}/{id}';
            $endpoints[$path] = (new EndpointFactory\SlugClassesEntryPointFactory(
                $slugLabel,
                $classes,
                $nodeIdMap,
                $this->getSerializer()
            ))
                ->setPath($path)
                ->addTag($tag)
                ->setOperationFactoryCollection(
                    new OperationFactoryCollection([
                        (new PagineTrasparenzaReadOperationFactory($nodeIdMap, $slugLabel, $slugEnum)),
                        (new PagineTrasparenzaMergePatchOperationFactory($nodeIdMap, $slugLabel, $slugEnum)),
                        (new PagineTrasparenzaDeleteOperationFactory($nodeIdMap, $slugLabel, $slugEnum)),
                    ])
                );

            $operation = $endpoints[$path]->getOperationByMethod('get');
            if ($operation instanceof ReadOperationFactory) {
                $subEndpoints = Utils::createMatrixSubEndpoints($endpoints[$path], $operation);
                foreach ($subEndpoints as $subPath => $subEndpoint) {
                    $endpoints[$subPath] = $subEndpoint;
                }
            }
        }

        $sort = [];
        foreach ($endpoints as $endpoint) {
            $path = $endpoint->getPath();
            $path = str_replace('{', 'aaa', $path);
            $sortKey = \eZCharTransform::instance()->transformByGroup($path, 'identifier');
            $sort[$sortKey] = $endpoint;
        }
        ksort($sort);
        $endpoints = array_values($sort);
        $this->endpoints = array_merge($this->endpoints, array_values($endpoints));
    }

}