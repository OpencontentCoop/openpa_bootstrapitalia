<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector;

class FullRelationField extends FieldConnector\RelationField
{
    public function getData()
    {
        $data = array();
        if ($this->getContent()) {
            $rawContent = $this->getContent();
            if (isset($rawContent['content']['metadata'])) {
                $item = $rawContent['content']['metadata'];

                $language = $this->getHelper()->getSetting('language');
                $itemName = $item['name'];
                $name = isset($itemName[$language]) ? $itemName[$language] : current($itemName);

                if ($this->selectionType == self::MODE_LIST_BROWSE) {
                    $data[] = array(
                        'id' => $item['id'],
                        'name' => $name,
                        'class' => $item['classIdentifier'],
                    );
                }else{
                    $data[] = (string)$item['id'];
                }
            }
        }

        return empty( $data ) ? null : $data;
    }

    public function getOptions()
    {
        $options = parent::getOptions();

        if ($this->attribute->attribute('identifier') == 'a_favore_di') {
            $options['browse']["classes"] = array('persona_fisica', 'societa');
            $options['browse']["addCreateButton"] = true;
            $options['browse']["openInSearchMode"] = true;
        }

        if ($this->class->attribute('identifier') == 'a2' 
            || $this->class->attribute('identifier') == 'b' 
            || $this->class->attribute('identifier') == 'c'
        ) {
            if ($this->attribute->attribute('identifier') == 'gn') {
                $options['browse']["classes"] = array('giornale_tavolare');
                $options['browse']["addCreateButton"] = true;
            }
        }

        return $options;
    }
}
