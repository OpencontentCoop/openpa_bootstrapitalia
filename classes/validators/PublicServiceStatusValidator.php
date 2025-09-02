<?php

class PublicServiceStatusValidator extends AbstractBootstrapItaliaInputValidator
{
    const SERVICE_STATUS_ERROR_MESSAGE = "Inserire un testo nel campo 'Motivo dello stato' dal momento che il servizio non è attivo";

    public function validate(): array
    {
        if ($this->class->attribute('identifier') == 'public_service') {
            $serviceStatus = $statusNote = false;
            foreach ($this->contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') == 'has_service_status') {
                    $serviceStatus = $contentObjectAttribute;
                } elseif ($contentClassAttribute->attribute('identifier') == 'status_note') {
                    $statusNote = $contentObjectAttribute;
                }
            }
            if ($serviceStatus && $statusNote) {
                $serviceStatusPostVar = 'ContentObjectAttribute_eztags_data_text3_' . $serviceStatus->attribute('id');
                $isActive = true;
                $activeService = OpenPABootstrapItaliaOperators::getActiveServiceTag();
                if ($activeService) {
                    $isActive = false;
                    if ($this->http->hasPostVariable($serviceStatusPostVar)) {
                        $isActive = $activeService->attribute('id') == $this->http->postVariable($serviceStatusPostVar);
                    }
                }
                $statusNoteHasContent = $this->hasText($statusNote);
                if (!$isActive && !$statusNoteHasContent) {
                    return [
                        'identifier' => 'status_note',
                        'text' => self::SERVICE_STATUS_ERROR_MESSAGE,
                    ];
                }
            }
        }

        return [];
    }
}