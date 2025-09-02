<?php

class EventContactPointValidator extends AbstractBootstrapItaliaInputValidator
{
    const MULTIFIELD_ERROR_MESSAGE = "Popolare almeno un campo tra '%s' e '%s'";

    public function validate(): array
    {
        if ($this->class->attribute('identifier') == 'event') {
            $hasContactPoints = false;
            $hasContactPointsAsText = false;

            $hasContactPointsName = 'has_online_contact_point';
            $hasContactPointsAsTextName = 'has_online_contact_point_as_text';
            $countExisting = 0;

            foreach ($this->contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') == 'has_online_contact_point') {
                    $countExisting++;
                    $hasContactPoints = $this->hasRelations($contentObjectAttribute);
                    $hasContactPointsName = $contentClassAttribute->attribute('name');
                } elseif ($contentClassAttribute->attribute('identifier') == 'has_online_contact_point_as_text') {
                    $countExisting++;
                    $hasContactPointsAsText = $this->hasText($contentObjectAttribute);
                    $hasContactPointsAsTextName = $contentClassAttribute->attribute('name');
                }
            }

            if ($countExisting === 2 && !$hasContactPoints && !$hasContactPointsAsText) {
                return [
                    'identifier' => 'has_online_contact_point',
                    'text' => sprintf(
                        self::MULTIFIELD_ERROR_MESSAGE,
                        $hasContactPointsName,
                        $hasContactPointsAsTextName
                    ),
                ];
            }
        }

        return [];
    }
}