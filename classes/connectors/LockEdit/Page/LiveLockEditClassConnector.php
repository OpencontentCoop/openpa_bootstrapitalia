<?php

class LiveLockEditClassConnector extends PageLockEditClassConnector
{
    protected function getEvidenceBlockSetupCount(): int
    {
        return 2;
    }

    protected function getEvidenceBlockId($blockIndex = 1): string
    {
        return $blockIndex == 1 ? '0d1bb6e2c1f40c5872fa3ed913aff35f' : 'c397de8a43b6f1080290f852f1d2463d';
    }

    protected function getEvidenceBlockMaxItems($blockIndex = 1): int
    {
        return 6;
    }

    protected function getEvidenceBlock($blockIndex = 1): array
    {
        $block = $this->findBlockById($this->getEvidenceBlockId($blockIndex));
        if (!$block) {
            $block = $this->getEmptyEvidenceBlock($blockIndex);
        }
        $block['type'] = 'ListaManuale';

        return $block;
    }

    protected function resetEvidenceBlock($block, $blockIndex = 1)
    {
        $name = $block['name'];
        $block = $this->findBlockById($this->getEvidenceBlockId($blockIndex), true);
        if (!empty($name)){
            $block['name'] = $name;
        }

        return $block;
    }

    protected function fetchSourcePathInfo(): array
    {
        return [
            'path' => $this->installerDataDir . '/contenttrees/OpenCity/Vivere-il-comune.yml',
            'identifier' => 'layout',
        ];
    }

    protected function filterOptionsByEvidenceBlock($options, $blockIndex = 1): array
    {
        if ($blockIndex > 1){
            $options['fields']['title_evidence_2']['helper'] = '';
            $options['fields']['section_evidence_2']['browse']['subtree'] = $this->fetchMainNodeIDByObjectRemoteID('all-places');
        }else{
            $options['fields']['title_evidence']['helper'] = '';
            $options['fields']['section_evidence']['browse']['subtree'] = $this->fetchMainNodeIDByObjectRemoteID('all-events');
        }

        return $options;
    }

    protected function filterSchemaByEvidenceBlock($schema, $blockIndex = 1): array
    {
        if ($blockIndex > 1){
            $schema['properties']['title_evidence_2']['title'] = 'Titolo del blocco "Luoghi in evidenza"';
            $schema['properties']['section_evidence_2']['title'] = 'Luoghi in evidenza';
        }else{
            $schema['properties']['title_evidence']['title'] = 'Titolo del blocco "Eventi in evidenza"';
            $schema['properties']['section_evidence']['title'] = 'Eventi in evidenza';
        }

        return $schema;
    }

    protected function cleanSourceBlocks($blocks): ?array
    {
        $stateGroup = eZContentObjectStateGroup::fetchByIdentifier('privacy');
        $dummyReplaces = [
            '$state_privacy_public' => eZContentObjectState::fetchByIdentifier('public', $stateGroup->attribute('id'))->attribute('id'),
        ];

        foreach ((array)$blocks as $index => $block) {
            if (isset($block['custom_attributes'])) {
                foreach ($block['custom_attributes'] as $key => $value) {
                    if (isset($dummyReplaces[$value])) {
                        $blocks[$index]['custom_attributes'][$key] = $dummyReplaces[$value];
                    }
                }
            }
        }

        return $blocks;
    }

}