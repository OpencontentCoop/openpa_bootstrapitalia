<?php

class GloboServiceLinksImportHandler extends SQLIImportAbstractHandler implements ISQLIImportHandler
{
    private $rowIndex = 0;

    private $rowCount;

    private $serviceContainerNodeId;

    private $validRemotes = [];

    public function initialize()
    {
        $this->dataSource = [];
        $serviceContainer = eZContentObject::fetchByRemoteID('all-services');
        if ($serviceContainer instanceof eZContentObject
            && $serviceContainer->mainNode() instanceof eZContentObjectTreeNode) {
            $this->serviceContainerNodeId = $serviceContainer->mainNodeID();
            $sourcePath = $this->options['endpoint'] ?? null; // https://sportellotelematico.comune.trani.bt.it/rest/pnrr/procedures
            if ($sourcePath) {
                if (strpos($sourcePath, '/rest/pnrr/procedures') === false) {
                    $sourcePath = rtrim($sourcePath, '/') . '/rest/pnrr/procedures';
                }
                $this->dataSource = (array)json_decode(@file_get_contents($sourcePath), true);
            }
        }
    }

    public function getProcessLength()
    {
        $this->rowCount = count($this->dataSource);
        return $this->rowCount;
    }

    public function getNextRow()
    {
        if ($this->rowIndex < $this->rowCount) {
            $row = $this->dataSource[$this->rowIndex];
            $this->rowIndex++;
        } else {
            $row = false;
        }
        return $row;
    }

    public function process($row)
    {
        $remoteId = 'globo_' . md5($row['urn']);
        $this->validRemotes[] = $remoteId;
        try {
            $contentPayload = [
                'type' => $row['categoria'],
                'name' => html_entity_decode($row['nome'], ENT_QUOTES),
                'identifier' => $row['urn'],
                'abstract' => html_entity_decode($row['descrizione_breve'], ENT_QUOTES),
                'location' => $row['url'] . '|Vai alla scheda del servizio',
            ];
            $topics = [];
            foreach ($row['argomenti'] as $topicName) {
                if (isset($topicsMap[$topicName])) {
                    $topics[] = $topicsMap[$topicName];
                }
            }
            if (!empty($topics)) {
                $contentPayload['topics'] = $topics;
            }
            $payload = [
                'metadata' => [
                    'classIdentifier' => 'public_service_link',
                    'remoteId' => $remoteId,
                    'parentNodes' => [$this->serviceContainerNodeId],
                ],
                'data' => $contentPayload,
            ];
            $this->progressionNotes = $contentPayload['identifier'] . ' ' . $contentPayload['name'] . PHP_EOL;
            $contentRepository = new \Opencontent\Opendata\Api\ContentRepository();
            $contentRepository->setEnvironment(new DefaultEnvironmentSettings());
            $contentRepository->createUpdate($payload, true);
        } catch (Throwable $t) {
            $this->progressionNotes = 'ERROR: ' . $t->getMessage();
        }
    }

    public function cleanup()
    {
        $states = OpenPABase::initStateGroup('privacy', ['public', 'private']);
        $state = $states['privacy.private'];
        $rows = eZDB::instance()->arrayQuery(
            "SELECT id, remote_id FROM ezcontentobject WHERE remote_id LIKE 'globo_%'"
        );
        foreach ($rows as $row) {
            if (!in_array($row['remote_id'], $this->validRemotes)) {
                $object = eZContentObject::fetchByRemoteID($row['remote_id']);
                if ($object instanceof eZContentObject
                    && $object->attribute('class_identifier') === 'public_service_link') {
                    $object->assignState($state);
                    eZSearch::addObject($object, true);
                    eZContentCacheManager::clearContentCache($object->attribute('id'));
                }
            }
        }
    }

    public function getHandlerName()
    {
        return 'Sync Globo service link';
    }

    public function getHandlerIdentifier()
    {
        return 'globoservicelinkshandler';
    }

    public function getProgressionNotes()
    {
        return $this->progressionNotes;
    }

}