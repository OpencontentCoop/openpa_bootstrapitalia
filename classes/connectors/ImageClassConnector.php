<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;
use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnectorFactory;

class ImageClassConnector extends ClassConnector
{
	public function getSchema()
	{
		$schema = parent::getSchema();
		$schema['properties']['proprietary_license']['required'] = true;
		$schema['dependencies'] = array(
			'proprietary_license' => array('license'),
			'proprietary_license_source' => array('license'),
		);

		return $schema;
	}

	public function getOptions()
	{
		$options = parent::getOptions();

		$options['fields']['proprietary_license']['dependencies'] = array('license' => 'Licenza proprietaria');
		$options['fields']['proprietary_license_source']['dependencies'] = array('license' => 'Licenza proprietaria');

		return $options;
	}

	public function getFieldConnectors()
    {
        if ($this->fieldConnectors === null) {
            /** @var \eZContentClassAttribute[] $classDataMap */
            $classDataMap = $this->class->dataMap();
            $defaultCategory = \eZINI::instance('content.ini')->variable('ClassAttributeSettings', 'DefaultCategory');
            foreach ($classDataMap as $identifier => $attribute) {

                $category = $attribute->attribute('category');
                if (empty( $category )) {
                    $category = $defaultCategory;
                }

                $add = true;

                if (!in_array($identifier, array('proprietary_license', 'proprietary_license_source'))){

	                if ((bool)$this->getHelper()->getSetting('OnlyRequired')) {
	                    $add = (bool)$attribute->attribute('is_required');
	                }

	                if ($add == true && $this->getHelper()->hasSetting('ShowCategories')) {
	                    $add = in_array($category, (array)$this->getHelper()->getSetting('Categories'));
	                }

	                if ($add == true && $this->getHelper()->hasSetting('HideCategories')) {
	                    $add = !in_array($category, (array)$this->getHelper()->getSetting('HideCategories'));
	                }
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
}