<?php

class MaxRelationsValidator extends AbstractBootstrapItaliaInputValidator
{
    public function validate(): array
    {
        $ini = eZINI::instance('openpa.ini');
        if (!$ini->hasVariable('AttributeHandlers', 'MaxRelations')) {
            return [];
        }

        $classIdentifier = $this->class->attribute('identifier');

        foreach ($ini->variable('AttributeHandlers', 'MaxRelations') as $key => $max) {
            if ((int)$max === 0) {
                continue;
            }
            [$configClass, $configAttr] = explode('/', $key, 2);
            if ($configClass !== $classIdentifier) {
                continue;
            }

            foreach ($this->contentObjectAttributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('identifier') !== $configAttr) {
                    continue;
                }

                $varName = $this->base . '_data_object_relation_list_' . $contentObjectAttribute->attribute('id');
                if (!$this->http->hasPostVariable($varName)) {
                    break;
                }

                $relations = $this->http->postVariable($varName);
                if (!is_array($relations)) {
                    break;
                }

                $relations = array_filter($relations, function ($r) { return $r !== 'no_relation'; });
                if (count($relations) > (int)$max) {
                    return [
                        'identifier' => $configAttr,
                        'text' => sprintf(
                            '%s: è possibile inserire al massimo %d %s',
                            $contentClassAttribute->attribute('name'),
                            (int)$max,
                            (int)$max === 1 ? 'elemento' : 'elementi'
                        ),
                    ];
                }
                break;
            }
        }

        return [];
    }
}
