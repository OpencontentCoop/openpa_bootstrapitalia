<?php

class NewsLockEditClassConnector extends PageLockEditClassConnector
{
    protected function getEvidenceBlockSetupCount(): int
    {
        return 1;
    }

    protected function getEvidenceBlockId($blockIndex = 1): string
    {
        return 'faea9447f60187ee41982a5e776206b0';
    }

    protected function getEvidenceBlock($blockIndex = 1): array
    {
        $block = $this->findBlockById($this->getEvidenceBlockId($blockIndex));
        if (!$block || $block['type'] === 'ListaAutomatica') {
            $block = $this->getEmptyEvidenceBlock($blockIndex);
        }

        return $block;
    }

}