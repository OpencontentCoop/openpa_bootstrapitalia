<?php

use Opencontent\OpenApi\EndpointDiscover\AbstractSlugClassesEntryPointFactoryProvider;
use Opencontent\OpenApi\EndpointDiscover\Utils;
use Opencontent\OpenApi\EndpointFactory;
use Opencontent\OpenApi\OperationFactory\ContentObject\ReadOperationFactory;
use Opencontent\OpenApi\OperationFactoryCollection;

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
        $treeRows = self::fetchTree((int)$id);
        return count($treeRows) > 0 ?
            self::formatSlug($treeRows[0]) :
            \eZCharTransform::instance()->transformByGroup($name, 'identifier');
    }

    protected function getSlugIdMap(): array
    {
        if (self::$nodeIdMap !== null) {
            return self::$nodeIdMap;
        }

        self::$nodeIdMap = [];
        $treeRows = self::fetchTree();
        foreach ($treeRows as $row){
            $slug = self::formatSlug($row);
            self::$nodeIdMap[$slug] = $row['node_id'];
        }

        return self::$nodeIdMap;
    }

    private static function fetchTree(?int $nodeId = null)
    {
        $trasparenzaRoot = eZContentObject::fetchByRemoteID(self::TRASPARENZA_REMOTE_ID);
        if ($trasparenzaRoot instanceof eZContentObject) {
            $contentClassId = (int)eZContentClass::classIDByIdentifier('pagina_trasparenza');
            $trasparenzaRootNode = $trasparenzaRoot->mainNode();
            $trasparenzaRootPath = $trasparenzaRootNode instanceof eZContentObjectTreeNode ?
                $trasparenzaRootNode->attribute('path_string') : '/invalid';
            $nodeIdFilter = $nodeId ? " WHERE node_id = $nodeId" : '';
            $treeQuery = "WITH tree AS (
                SELECT 
                  ezcontentobject.id,
                  ezcontentobject_tree.node_id,
                  ezcontentobject_name.name AS name,
                  ROW_NUMBER () OVER (
                        PARTITION BY ezcontentobject_name.name
                        ORDER BY
                            ezcontentobject.id
                    ) AS suffix
                FROM ezcontentobject
                  INNER JOIN ezcontentobject_name 
                    ON ( ezcontentobject.id = ezcontentobject_name.contentobject_id AND ezcontentobject.current_version = ezcontentobject_name.content_version )
                  INNER JOIN ezcontentobject_tree 
                    ON ( ezcontentobject.id = ezcontentobject_tree.contentobject_id AND ezcontentobject.current_version = ezcontentobject_tree.contentobject_version ) 
                WHERE ezcontentobject.contentclass_id  IN  ( $contentClassId ) 
                    AND ezcontentobject_tree.path_string like '$trasparenzaRootPath%' 
                    AND ezcontentobject_name.language_id = 2
                    AND ezcontentobject_tree.contentobject_is_published = 1
                    AND ezcontentobject_tree.is_hidden = 0 
                    AND ezcontentobject_tree.is_invisible = 0 
                GROUP BY ezcontentobject.id, ezcontentobject_name.name, ezcontentobject_tree.node_id
                ORDER BY ezcontentobject_name.name asc
            ) SELECT * FROM tree $nodeIdFilter";
            return eZDB::instance()->arrayQuery($treeQuery);
        }

        return [];
    }

    private static function formatSlug($treeItem)
    {
        $slug = \eZCharTransform::instance()->transformByGroup($treeItem['name'], 'identifier');
        if (strlen($slug) > 100) {
            $substr = substr($slug, 0, 100);
            $lastUnderscore = strrpos($substr, "_");
            $slug = substr($substr, 0, $lastUnderscore);
        }
        if ($treeItem['suffix'] > 1){
            $slug .= '-' .  $treeItem['node_id'];
        }

        return $slug;
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