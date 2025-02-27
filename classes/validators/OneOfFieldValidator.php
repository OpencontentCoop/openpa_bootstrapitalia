<?php

class OneOfFieldValidator extends AbstractBootstrapItaliaInputValidator
{
    const ONE_OF_ERROR_MESSAGE = 'Compilare almeno un campo tra %s';

    const AND_MESSAGE = 'e';

    private $oneOfFields;

    private $validateClassIdentifier;

    public function __construct(string $parameters = '')
    {
        [$classParameter, $fieldsParameters] = explode(';', $parameters);
        $this->validateClassIdentifier = $classParameter;
        $this->oneOfFields = array_filter(explode(',', $fieldsParameters));
    }

    public function validate(): array
    {
        if ($this->class->attribute('identifier') !== $this->validateClassIdentifier || empty($this->oneOfFields)) {
            return [];
        }

        $attributes = [];
        $texts = [];
        foreach ($this->oneOfFields as $oneOfField) {
            foreach ($this->contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') == $oneOfField) {
                    $attributes[$oneOfField] = [
                        'attribute' => $contentObjectAttribute,
                        'class_attribute' => $contentClassAttribute,
                        'has_content' => $this->hasInputData($contentClassAttribute, $contentObjectAttribute),
                    ];
                    $texts[] = '"' . $contentClassAttribute->attribute('name') . '"';
                }
            }
        }

        if (count($this->oneOfFields) !== count($attributes)) {
            return [];
        }

        $hasValidContent = false;
        foreach ($attributes as $attribute) {
            if ($attribute['has_content']) {
                $hasValidContent = true;
            }
        }
        if (!$hasValidContent) {
            return [
                'identifier' => $attributes[$this->oneOfFields[0]]['class_attribute']->attribute('identifier'),
                'text' => sprintf(self::ONE_OF_ERROR_MESSAGE, $this->naturalLanguageJoin($texts, self::AND_MESSAGE)),
            ];
        }

        return [];
    }

    function naturalLanguageJoin(array $list, $conjunction = 'e')
    {
        $last = array_pop($list);
        if ($list) {
            return implode(', ', $list) . ' ' . $conjunction . ' ' . $last;
        }
        return $last;
    }
}