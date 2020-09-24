<?php

use Opencontent\Ocopendata\Forms\Connectors\AbstractBaseConnector;
use Opencontent\Opendata\Api\ClassRepository;

class RemoteDashboardSelectTargetConnector extends AbstractBaseConnector
{
    private $remoteContent;

    private $dashboard;

    private $contentClasses = [];

    public function runService($serviceIdentifier)
    {
        if ($this->getHelper()->hasParameter('d')) {
            $this->dashboard = eZContentObject::fetch((int)$this->getHelper()->getParameter('d'));
        }
        if (!$this->dashboard instanceof eZContentObject || $this->dashboard->attribute('class_identifier') !== 'remote_dashboard') {
            throw new Exception("dashboard not found", 1);
        }

        if ($this->getHelper()->hasParameter('rc')) {
            $this->remoteContent = json_decode(file_get_contents($this->getHelper()->getParameter('rc')), true);
        }
        if ($this->remoteContent === null) {
            throw new Exception("Remote content not found", 1);
        }

        $classRepo = new ClassRepository();
        $classes = $classRepo->listAll();
        foreach ($classes as $class){
            $this->contentClasses[$class['identifier']] = $class['name'];
        }
        $contentClasses = array_flip($this->contentClasses);
        ksort($contentClasses);
        $this->contentClasses = $contentClasses;

        return parent::runService($serviceIdentifier);
    }

    private function getDefaultTarget()
    {
        if (in_array($this->remoteContent['metadata']['classIdentifier'], $this->contentClasses)){
            return $this->remoteContent['metadata']['classIdentifier'];
        }

        return false;
    }

    protected function getData()
    {
        return [];
    }

    protected function getSchema()
    {
        return array(
            "title" => "Seleziona la tipologia di contenuto di destinazione",
            "type" => "object",
            "properties" => array(
                "target_class" => array(
                    "enum" => array_values($this->contentClasses),
                    'required' => true,
                    "default" => $this->getDefaultTarget(),
                ),
            )
        );
    }

    protected function getOptions()
    {
        return array(
            "form" => array(
                "attributes" => array(
                    "action" => $this->getHelper()->getServiceUrl('action', $this->getHelper()->getParameters()),
                    "method" => "post"
                ),
                "buttons" => array(
                    "submit" => array()
                ),
            ),
            "fields" => array(
                "target_class" => array(
                    "optionLabels" => array_keys($this->contentClasses),
                ),
            ),
        );
    }

    protected function getView()
    {
        return array(
            "parent" => "bootstrap-edit",
            "locale" => "it_IT"
        );
    }

    protected function submit()
    {
        return [
            's' => $this->remoteContent['metadata']['classIdentifier'],
            't' => $_POST['target_class']
        ];
    }

    protected function upload()
    {
        throw new Exception("Method not allowed", 1);
    }

}