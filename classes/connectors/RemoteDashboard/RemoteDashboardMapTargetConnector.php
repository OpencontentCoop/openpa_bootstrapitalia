<?php

use Opencontent\Ocopendata\Forms\Connectors\AbstractBaseConnector;
use Opencontent\Opendata\Api\AttributeConverter\Matrix;
use Opencontent\Opendata\Api\ClassRepository;
use Opencontent\Opendata\Api\PublicationProcess;

class RemoteDashboardMapTargetConnector extends AbstractBaseConnector
{
    private $remoteClassDefinition;

    /**
     * @var eZContentObject
     */
    private $dashboard;

    private $language;

    private $targetClassDefinition;

    private $remoteFieldsByDatatype = [];

    public function runService($serviceIdentifier)
    {
        $this->language = \eZLocale::currentLocaleCode();

        if ($this->getHelper()->hasParameter('d')) {
            $this->dashboard = eZContentObject::fetch((int)$this->getHelper()->getParameter('d'));
        }
        if (!$this->dashboard instanceof eZContentObject || $this->dashboard->attribute('class_identifier') !== 'remote_dashboard') {
            throw new Exception("dashboard not found", 1);
        }

        if ($this->getHelper()->hasParameter('tc')) {
            $targetClassDefinition = (new ClassRepository())->load($this->getHelper()->getParameter('tc'));
            $this->targetClassDefinition = json_decode(json_encode($targetClassDefinition), true);
        }

        if ($this->getHelper()->hasParameter('rc')) {
            $remoteContent = json_decode(file_get_contents($this->getHelper()->getParameter('rc')), true);
            $this->remoteClassDefinition = $remoteContent['metadata']['classDefinition'];
        }
        if ($this->remoteClassDefinition === null) {
            throw new Exception("Remote content not found", 1);
        }

        return parent::runService($serviceIdentifier);
    }

    protected function getData()
    {
        return [];
    }

    protected function getSchema()
    {
        $properties = [];

        $properties['_save_map'] = array(
            "type" => "boolean"
        );

        foreach ($this->targetClassDefinition['fields'] as $field) {
            $properties[$field['identifier']] = [
                'title' => $field['name'][$this->language],
                'enum' => array_keys($this->getRemoteFieldsByDatatype($field['dataType'])),
                'default' => $this->getRemoteFieldByIdentifier($field['identifier'])
            ];
        }

        return array(
            "title" => "Mappa i campi di {$this->remoteClassDefinition['name'][$this->language]} in {$this->targetClassDefinition['name'][$this->language]}",
            "type" => "object",
            "properties" => $properties
        );
    }

    private function getRemoteFieldsByDatatype($dataType)
    {
        if (!isset($this->remoteFieldsByDatatype[$dataType])) {
            $this->remoteFieldsByDatatype[$dataType] = [];
            foreach ($this->remoteClassDefinition['fields'] as $field) {
                if ($field['dataType'] == $dataType) {
                    $this->remoteFieldsByDatatype[$dataType][$field['identifier']] = $field['name'][$this->language];
                }
            }
        }
        return $this->remoteFieldsByDatatype[$dataType];

    }

    private function getRemoteFieldByIdentifier($identifier)
    {
        foreach ($this->remoteClassDefinition['fields'] as $field) {
            if ($field['identifier'] == $identifier) {
                return $field['identifier'];
            }
        }

        return '';
    }

    protected function getOptions()
    {
        $fields = [];
        $fields['_save_map'] = [
            "type" => "checkbox",
            "rightLabel" => 'Registra questa impostazione per le future importazioni',
        ];
        foreach ($this->targetClassDefinition['fields'] as $field) {
            $fields[$field['identifier']] = [
                'optionLabels' => array_values($this->getRemoteFieldsByDatatype($field['dataType'])),
                'type' => 'select',
                'helper' => "Seleziona un campo di tipo {$field['dataType']} del contenuto remoto",
            ];
        }

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
            "fields" => $fields,
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
        $mapping = [];
        $save = isset($_POST['_save_map']) && $_POST['_save_map'] == 'true';
        unset($_POST['_save_map']);
        foreach ($_POST as $target => $source) {
            $mapping[] = [
                's' => $target,
                't' => $source
            ];
        }

        if ($save) {
            $this->saveMap($mapping);
        }

        return $mapping;
    }

    private function saveMap($mapping)
    {
        $source = $this->remoteClassDefinition['identifier'];
        $target = $this->targetClassDefinition['identifier'];
        $map = json_encode($mapping);

        $mapAttribute = $this->dashboard->dataMap()['map'];
        $converter = new Matrix('remote_dashboard', 'map');
        $data = $converter->get($mapAttribute)['content'];
        $data[] = [
            's' => $source,
            't' => $target,
            'm' => $map,
        ];
        $string = $converter->set($data, new PublicationProcess(null));
        eZContentFunctions::updateAndPublishObject($this->dashboard, ['attributes' => ['map' => $string]]);
    }

    protected function upload()
    {
        throw new Exception("Method not allowed", 1);
    }
}