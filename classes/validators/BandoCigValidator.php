<?php

class BandoCigValidator extends OneOfFieldValidator
{
    const IS_DRAFT_FIELD = 'is_draft';

    public function validate(): array
    {
        if ($this->isDraft()) {
            return [];
        }
        return parent::validate();
    }

    private function isDraft(): bool
    {
        foreach ($this->contentObjectAttributes as $contentObjectAttribute) {
            $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
            if ($contentClassAttribute->attribute('identifier') == self::IS_DRAFT_FIELD) {
                return $this->hasInputData($contentClassAttribute, $contentObjectAttribute);
            }
        }
        return false;
    }
}