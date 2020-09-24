<?php

use Opencontent\Ocopendata\Forms\Connectors\AbstractBaseConnector;
use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnectorFactory;
use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnectorInterface;
use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector;
use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\UploadFieldConnector;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;

class RemoteDashboardImportConnector extends AbstractBaseConnector
{
    /**
     * @var ClassConnectorInterface
     */
    protected $classConnector;

    protected $remoteContent;

    protected $dashboard;

    protected $classMap;

    protected $attributeMap;

    protected $language;

    protected $mappedRelatedContentList = [];

    protected $remoteId;

    protected $baseRemoteUrl;

    protected $baseRemoteApiUrl;

    /**
     * @var ContentRepository
     */
    protected $contentRepository;

    public function runService($serviceIdentifier)
    {
        $this->language = \eZLocale::currentLocaleCode();
        $this->getHelper()->setSetting('language', $this->language);

        if ($this->getHelper()->hasParameter('d')) {
            $this->dashboard = eZContentObject::fetch((int)$this->getHelper()->getParameter('d'));
        }
        if (!$this->dashboard instanceof eZContentObject || $this->dashboard->attribute('class_identifier') !== 'remote_dashboard') {
            throw new Exception("dashboard not found", 1);
        }

        if (!$this->getHelper()->hasParameter('cm')) {
            throw new Exception("cm not found", 1);
        } else {
            $this->classMap = $this->getHelper()->getParameter('cm');
            $contentClass = eZContentClass::fetchByIdentifier($this->classMap['t']);
            if (!$contentClass instanceof eZContentClass) {
                throw new \Exception("Class {$this->classMap['t']} not found");
            }
        }

        if (!$this->getHelper()->hasParameter('am')) {
            throw new Exception("am not found", 1);
        } else {
            $this->attributeMap = $this->getHelper()->getParameter('am');
        }

        if ($this->getHelper()->hasParameter('rc')) {
            $this->remoteContent = json_decode(file_get_contents($this->getHelper()->getParameter('rc')), true);
        }
        if ($this->remoteContent === null) {
            throw new Exception("Remote content not found", 1);
        }

        $remoteUrlParts = explode('/', $this->getHelper()->getParameter('rc'));
        $this->remoteId = array_pop($remoteUrlParts);
        $this->baseRemoteApiUrl = implode('/', $remoteUrlParts);
        $parsedRemoteUrl = parse_url($this->baseRemoteApiUrl);
        $this->baseRemoteUrl = $parsedRemoteUrl['scheme'] . '://' . $parsedRemoteUrl['host'];

        if ($this->getHelper()->hasParameter('mr')) {
            $this->mappedRelatedContentList = $this->getHelper()->getParameter('mr');
        }
        if ($this->getHelper()->hasParameter('p')) {
            $parent = (int)$this->getHelper()->getParameter('p');
            if ($parent > 0) {
                $this->getHelper()->setParameter('parent', $parent);
            }
        }

        $this->getHelper()->setParameter('from', $this->getHelper()->getParameter('rc'));
        $this->classConnector = ClassConnectorFactory::load($contentClass, $this->getHelper());

        $this->contentRepository = new ContentRepository();
        $this->contentRepository->setEnvironment(new DefaultEnvironmentSettings());

        return parent::runService($serviceIdentifier);
    }


    protected function getData()
    {
        $contentMap = [];
        $fields = $this->remoteContent['data'][$this->language];
        foreach ($this->attributeMap as $map) {
            $contentMap[$map['t']] = $fields[$map['s']];
        }

        $data = [];
        foreach ($this->classConnector->getFieldConnectors() as $identifier => $connector) {
            if ($connector instanceof UploadFieldConnector) {
                $file = $contentMap[$identifier];
                $url = strpos($file['url'], 'http') === false ? $this->baseRemoteUrl . $file['url'] : $file['url'];
                $path = '/tmp/' . $file['filename'];
                file_put_contents($path, file_get_contents($url));
                $response = $connector->insertFiles([new SplFileObject($path)]);
                if ($connector instanceof FieldConnector\ImageField) {
                    $data[$identifier] = [
                        'image' => $response['files'][0],
                        'alt' => ''
                    ];
                }else{
                    $data[$identifier] = $response['files'][0];
                }
                @unlink($path);
            }

            $datatype = $connector->getAttribute()->attribute('data_type_string');

            switch ($datatype) {
                case eZXMLTextType::DATA_TYPE_STRING:
                    $data[$identifier] = $contentMap[$identifier];
                    break;

                case eZObjectRelationListType::DATA_TYPE_STRING:

                    /** @var array $classAttributeContent */
                    $classAttributeContent = $connector->getAttribute()->content();
                    $selectionType = $classAttributeContent['selection_type'];

                    $values = [];
                    foreach ($contentMap[$identifier] as $related) {
                        $object = eZContentObject::fetchByRemoteID($related['remoteId']);

                        if (!$object instanceof eZContentObject
                            && isset($this->mappedRelatedContentList[$identifier][$related['remoteId']])
                            && $this->mappedRelatedContentList[$identifier][$related['remoteId']] == RemoteDashboardManageRelationsConnector::ACTION_CREATE
                        ) {
                            $object = $this->createRelatedObject($related, $classAttributeContent);
                        }

                        if ($object instanceof eZContentObject) {
                            $values[] = array(
                                'id' => $object->attribute('id'),
                                'name' => $object->attribute('name'),
                                'class' => $object->attribute('class_identifier'),
                            );
                        }
                    }

                    if ($selectionType == FieldConnector\RelationsField::MODE_LIST_DROP_DOWN
                        || $selectionType == FieldConnector\RelationsField::MODE_LIST_MULTIPLE
                        || $selectionType == FieldConnector\RelationsField::MODE_LIST_TEMPLATE_SINGLE
                        || $selectionType == FieldConnector\RelationsField::MODE_LIST_TEMPLATE_MULTIPLE
                    ) {
                        $values = array_column($values, 'id');
                    } elseif ($selectionType != FieldConnector\RelationsField::MODE_LIST_BROWSE) {
                        $values = array_map('intval', array_column($values, 'id'));
                    }

                    $data[$identifier] = $values;
                    break;

                default:
                    if (!isset($data[$identifier])) {
                        $connector->setContent(['content' => $contentMap[$identifier]]);
                        $data[$identifier] = $connector->getData();
                    }
            }
        }

        return $data;
    }

    private function createRelatedObject($relatedItem, $classAttributeContent)
    {
        $defaultPlacementNode = (is_array($classAttributeContent['default_placement']) and isset($classAttributeContent['default_placement']['node_id'])) ? $classAttributeContent['default_placement']['node_id'] : false;
        if (!$defaultPlacementNode) {
            eZDebug::writeError('Missing defaultPlacementNode', __METHOD__);
            return false;
        }

        $remoteUrl = $this->baseRemoteApiUrl . '/' . $relatedItem['id'];
        $data = json_decode(file_get_contents($remoteUrl), true);
        if (!$data) {
            eZDebug::writeError("No response from $remoteUrl", __METHOD__);
            return false;
        }

        unset($data['metadata']['id']);
        unset($data['metadata']['class']);
        unset($data['metadata']['sectionIdentifier']);
        unset($data['metadata']['ownerId']);
        unset($data['metadata']['ownerName']);
        unset($data['metadata']['mainNodeId']);
        unset($data['metadata']['published']);
        unset($data['metadata']['modified']);
        unset($data['metadata']['name']);
        unset($data['metadata']['link']);
        unset($data['metadata']['stateIdentifiers']);
        unset($data['metadata']['assignedNodes']);
        unset($data['metadata']['classDefinition']);

        $payload = new PayloadBuilder($data);
        $payload->setParentNodes([$defaultPlacementNode]);

        switch ($relatedItem['classIdentifier']) {
            case 'image':
                $images = $payload->getData('image');
                foreach ($images as $language => $image) {
                    unset($image['mime_type']);
                    unset($image['width']);
                    unset($image['height']);
                    $image['url'] = $this->baseRemoteUrl . $image['url'];
                    $payload->setData($language, 'image', $image);
                }

                try {
                    $creationResult = $this->contentRepository->create($payload->getArrayCopy());
                    if ($creationResult['message'] == 'success') {
                        return eZContentObject::fetch($creationResult['content']['metadata']['id']);
                    }
                } catch (Exception $e) {
                    eZDebug::writeError($e->getMessage(), __METHOD__);
                }

                break;
//
//            case 'document':
//                break;
//
//            case 'file':
//                break;
        }

        return false;
    }

    protected function getSchema()
    {
        return $this->classConnector->getSchema();
    }

    protected function getOptions()
    {
        return array_merge_recursive(
            array(
                "form" => array(
                    "attributes" => array(
                        "class" => 'opendata-connector',
                        "action" => $this->getHelper()->getServiceUrl('action', $this->getHelper()->getParameters()),
                        "method" => "post",
                        "enctype" => "multipart/form-data"
                    )
                ),
            ),
            $this->classConnector->getOptions()
        );
    }

    protected function getView()
    {
        return $this->classConnector->getView();
    }

    protected function submit()
    {
        $this->classConnector->setSubmitData($_POST);
        $creationResult = $this->classConnector->submit();
        if ($creationResult['message'] == 'success') {
            $object = eZContentObject::fetch($creationResult['content']['metadata']['id']);
            $object->setAttribute('remote_id', $this->remoteId);
            $object->setAttribute('modified', $object->attribute('modified') + 1);
            $object->store();
            eZSearch::addObject($object);
            $creationResult['content'] = $this->contentRepository->read($object->attribute('id'));
        }

        return $creationResult;
    }

    protected function upload()
    {
        return $this->classConnector->upload();
    }

}