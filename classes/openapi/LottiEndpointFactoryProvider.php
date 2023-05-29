<?php

use Opencontent\OpenApi\EndpointDiscover\AbstractSlugClassesEntryPointFactoryProvider;
use Opencontent\OpenApi\OperationFactoryCollection;
use Opencontent\OpenApi\OperationFactory;

class LottiEndpointFactoryProvider extends AbstractSlugClassesEntryPointFactoryProvider
{
    const CONTAINER_REMOTE_ID = 'b77effe1c84fcd44a88379b94ac0e402';

    private static $nodeIdMap;

    private $containerRoot;

    protected function getSlugLabel()
    {
        return 'year';
    }

    protected function getPrefix()
    {
        return '/bandi-di-gara';
    }

    protected function getClassIdentifiers()
    {
        return ['lotto'];
    }

    protected function getTag()
    {
        return 'trasparenza';
    }

    protected function getSlugIdMap()
    {
        $containerRoot = $this->getContainerRoot();
        if ($containerRoot instanceof eZContentObject) {
            if (self::$nodeIdMap === null) {
                self::$nodeIdMap = [];
                if (eZContentClass::classIDByIdentifier('dataset_lotto')) {
                    /** @var eZContentObjectTreeNode[] $datasetList */
                    $datasetList = eZContentObjectTreeNode::subTreeByNodeID([
                        'ClassFilterType' => 'include',
                        'ClassFilterArray' => ['dataset_lotto'],
                        'SortBy' => [['published', true]],
                    ], $containerRoot->mainNodeID());
                    foreach ($datasetList as $dataset) {
                        $dataMap = $dataset->dataMap();
                        $slug = "" . $dataMap['anno_riferimento']->toString();
                        if (strlen($slug) > 100) {
                            $substr = substr($slug, 0, 100);
                            $lastUnderscore = strrpos($substr, " ");
                            $slug = substr($substr, 0, $lastUnderscore);
                        }
                        self::$nodeIdMap[$slug] = (int)$dataset->attribute('node_id');
                    }
                }
            }
        }
        return self::$nodeIdMap;
    }

    private function getContainerRoot()
    {
        if (!$this->containerRoot){
            $this->containerRoot = eZContentObject::fetchByRemoteID(self::CONTAINER_REMOTE_ID);
        }
        return $this->containerRoot;
    }

    protected function build()
    {
        if ($this->getContainerRoot() && eZContentClass::classIDByIdentifier('dataset_lotto')){
            $prefix = $this->getPrefix();
            $this->endpoints[] = (new \Opencontent\OpenApi\EndpointFactory\NodeClassesEndpointFactory(
                $this->getContainerRoot()->mainNodeID(),
                ['dataset_lotto']
            ))
                ->setPath($prefix)
                ->addTag($this->getTag())
                ->setOperationFactoryCollection(new OperationFactoryCollection([
                    (new OperationFactory\ContentObject\CreateOperationFactory()),
                ]));
        }

        parent::build();
    }
}