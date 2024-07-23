<?php

class EventCostsValidator extends AbstractBootstrapItaliaInputValidator
{
    public function validate(): array
    {
        if ($this->class->attribute('identifier') == 'event') {
            if (
                eZContentObject::fetchByRemoteID('all-events')
                || eZContentObject::fetchByRemoteID(OpenPABase::getCurrentSiteaccessIdentifier() . '_openpa_agenda')
            ) {
                $isAccessibleForFree = false;
                $costNotes = false;
                $hasOffer = false;

                $isAccessibleForFreeName = 'is_accessible_for_free';
                $costNotesName = 'cost_notes';
                $hasOfferName = 'has_offer';
                $countExisting = 0;

                foreach ($this->contentObjectAttributes as $contentObjectAttribute) {
                    $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                    if ($contentClassAttribute->attribute('identifier') == 'is_accessible_for_free') {
                        $countExisting++;
                        $isAccessibleForFree = $this->hasBoolean($contentObjectAttribute);
                        $isAccessibleForFreeName = $contentClassAttribute->attribute('name');
                    } elseif ($contentClassAttribute->attribute('identifier') == 'cost_notes') {
                        $countExisting++;
                        $costNotes = $this->hasText($contentObjectAttribute);
                        $costNotesName = $contentClassAttribute->attribute('name');
                    } elseif ($contentClassAttribute->attribute('identifier') == 'has_offer') {
                        $countExisting++;
                        $hasOffer = $this->hasRelations($contentObjectAttribute);
                        $hasOfferName = $contentClassAttribute->attribute('name');
                    }
                }
                if ($countExisting === 3 && !$isAccessibleForFree && !$costNotes && !$hasOffer) {
                    return [
                        'identifier' => 'is_accessible_for_free',
                        'text' => sprintf(
                            self::MULTIFIELD_ERROR_MESSAGE,
                            $isAccessibleForFreeName,
                            $costNotesName,
                            $hasOfferName
                        ),
                    ];
                }
            }
        }

        return [];
    }
}