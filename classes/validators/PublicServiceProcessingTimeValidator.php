<?php

class PublicServiceProcessingTimeValidator extends AbstractBootstrapItaliaInputValidator
{
    const SERVICE_PROCESSING_TIME_ERROR_MESSAGE = 'Compilare almeno un campo tra "Tempi e scadenze" e "Giorni massimi di attesa dalla richiesta"';

    public function validate(): array
    {
        if ($this->class->attribute('identifier') == 'public_service') {
            $hasProcessingTime = $hasProcessingTimeAsText = false;
            foreach ($this->contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') == 'has_processing_time') {
                    $hasProcessingTime = $contentObjectAttribute;
                } elseif ($contentClassAttribute->attribute('identifier') == 'has_processing_time_text') {
                    $hasProcessingTimeAsText = $contentObjectAttribute;
                }
            }
            if ($hasProcessingTime && $hasProcessingTimeAsText) {
                $hasProcessingTimeHasContent = $this->hasInt($hasProcessingTime);
                $hasProcessingTimeAsTextHasContent = $this->hasText($hasProcessingTimeAsText);

                if (!$hasProcessingTimeHasContent && !$hasProcessingTimeAsTextHasContent) {
                    return [
                        'identifier' => 'has_processing_time_text',
                        'text' => self::SERVICE_PROCESSING_TIME_ERROR_MESSAGE,
                    ];
                }
            }
        }

        return [];
    }
}