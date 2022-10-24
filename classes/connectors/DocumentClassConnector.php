<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;
use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnectorFactory;

class DocumentClassConnector extends ClassConnector
{
    private $fileName;

    private $linkName;

    private $attachmentsName;

    /**
     * @var eZContentClassAttribute[]
     */
    private $classDataMap;

    public function __construct(eZContentClass $class, $helper)
    {
        parent::__construct($class, $helper);
        $this->classDataMap = $this->class->dataMap();
        $this->fileName = isset($this->classDataMap['file']) ? $this->classDataMap['file']->attribute('name') : null;
        $this->linkName = isset($this->classDataMap['link']) ? $this->classDataMap['link']->attribute('name') : null;
        $this->attachmentsName = isset($this->classDataMap['attachments']) ? $this->classDataMap['attachments']->attribute('name') : null;
    }

    public function getFieldConnectors()
    {
        if ($this->fieldConnectors === null) {

            $defaultCategory = \eZINI::instance('content.ini')->variable('ClassAttributeSettings', 'DefaultCategory');
            foreach ($this->classDataMap as $identifier => $attribute) {

                $category = $attribute->attribute('category');
                if (empty( $category )) {
                    $category = $defaultCategory;
                }

                $add = true;

                if ((bool)$this->getHelper()->getSetting('OnlyRequired')) {
                    $add = (bool)$attribute->attribute('is_required');
                }

                if ($add == true && $this->getHelper()->hasSetting('ShowCategories')) {
                    $add = in_array($category, (array)$this->getHelper()->getSetting('Categories'));
                }

                if ($add == true && $this->getHelper()->hasSetting('HideCategories')) {
                    $add = !in_array($category, (array)$this->getHelper()->getSetting('HideCategories'));
                }

                if ($identifier == 'file' || $identifier == 'link'){
                    $add = true;

                }

                if ($add) {
                    $this->fieldConnectors[$identifier] = FieldConnectorFactory::load(
                        $attribute,
                        $this->class,
                        $this->getHelper()
                    );
                }else{
                    $this->copyFieldFromPrevVersion($identifier);
                }
            }
        }

        return $this->fieldConnectors;
    }

    public function submit()
    {
        $submitData = $this->getSubmitData();
        if (empty($submitData['file']) && empty($submitData['link'])){
            throw new Exception(
                sprintf(openpa_bootstrapitaliaHandler::FILE_ERROR_MESSAGE, $this->fileName, $this->linkName, $this->attachmentsName)
            );
        }

        return parent::submit();
    }
}