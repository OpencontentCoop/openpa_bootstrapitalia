<?php

class NewsLockEditClassConnector extends FrontpageLockEditClassConnector
{
    protected function getEvidenceBlockId(): string
    {
        return 'faea9447f60187ee41982a5e776206b0';
    }

    protected function getEvidenceBlock(): array
    {
        $block = $this->findBlockById($this->getEvidenceBlockId());
        if (!$block || $block['type'] === 'ListaAutomatica'){
            $block = $this->getEmptyEvidenceBlock();
        }

        return $block;
    }
}