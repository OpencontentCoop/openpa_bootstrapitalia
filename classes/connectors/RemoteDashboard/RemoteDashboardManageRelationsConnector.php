<?php

class RemoteDashboardManageRelationsConnector extends RemoteDashboardImportConnector
{
    const ACTION_CREATE = 'create';

    const ACTION_IGNORE = 'ignore';

    private $missingRelatedIdentifierList = [];

    public function runService($serviceIdentifier)
    {
        if ($this->getHelper()->hasParameter('xr')) {
            $this->missingRelatedIdentifierList = $this->getHelper()->getParameter('xr');
        }

        return parent::runService($serviceIdentifier);
    }

    protected function getSchema()
    {
        $properties = [];

        $remoteFields = $this->remoteContent['data'][$this->language];
        foreach ($this->missingRelatedIdentifierList as $identifier) {
            if (isset($remoteFields[$identifier])) {
                $field = $this->getFieldDefinition($identifier);
                if ($field) {
                    $fieldProperties = [];
                    foreach ($remoteFields[$identifier] as $remoteField) {
                        $enum = array_keys($this->getActionsForRemoteContent($remoteField));
                        $fieldProperties[$remoteField['remoteId']] = [
                            'title' => $remoteField['name'][$this->language],
                            'enum' => $enum,
                            'default' => $enum[0],
                            'required' => 'true'
                        ];
                    }
                    $properties[$identifier] = [
                        'type' => 'object',
                        'title' => $field['name'][$this->language],
                        'properties' => $fieldProperties
                    ];
                }

            }
        }

        return array(
            "title" => "Per poter importare il contenuto selezionato, devi prima scegliere come gestire contenuti correlati",
            "type" => "object",
            "properties" => $properties
        );
    }

    private function getActionsForRemoteContent($remoteField)
    {
        $actions = [];
        if (in_array($remoteField['classIdentifier'], ['image'/*, 'file', 'document'*/])){
            $actions[self::ACTION_CREATE] = 'Crea contenuto se non è presente a sistema';
        }
        $actions[self::ACTION_IGNORE] = 'Aggiungi manualmente se non è presente a sistema';

        return $actions;
    }

    private function getFieldDefinition($identifier)
    {
        foreach ($this->remoteContent['metadata']['classDefinition']['fields'] as $field) {
            if ($field['identifier'] == $identifier) {
                return $field;
            }
        }

        return false;
    }

    protected function getData()
    {
        return [];
    }

    protected function getOptions()
    {
        $fields = [];

        $remoteFields = $this->remoteContent['data'][$this->language];
        foreach ($this->missingRelatedIdentifierList as $identifier) {
            if (isset($remoteFields[$identifier])) {
                foreach ($remoteFields[$identifier] as $remoteField) {
                    $fieldProperties[$remoteField['remoteId']] = [
                        'optionLabels' => array_values($this->getActionsForRemoteContent($remoteField)),
                        'hideNone' => true,
                        'type' => 'select',
                    ];
                }
                $fields[$identifier] = ['fields' => $fieldProperties];
            }
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
        $remoteFields = $this->remoteContent['data'][$this->language];
        foreach ($this->missingRelatedIdentifierList as $i =>  $identifier) {
            if (isset($remoteFields[$identifier])) {
                foreach ($remoteFields[$identifier] as $index => $remoteField) {
                    if (isset($_POST[$identifier][$remoteField['remoteId']])){
                        $this->mappedRelatedContentList[$identifier][$remoteField['remoteId']] = $_POST[$identifier][$remoteField['remoteId']];
                        unset($remoteFields[$identifier][$index]);
                    }
                }
                if (count($remoteFields[$identifier]) == 0){
                    unset($this->missingRelatedIdentifierList[$i]);
                }
            }
        }

        return [
            'missing' => $this->missingRelatedIdentifierList,
            'mapped' => $this->mappedRelatedContentList,
        ];
    }

    protected function upload()
    {
        throw new Exception("Method not allowed", 1);
    }

}