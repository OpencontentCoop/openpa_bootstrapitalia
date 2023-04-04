<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector;

class LockEditConnector extends OpendataConnector
{
    /**
     * @var eZContentObject
     */
    protected $object;

    protected $language;

    protected static $isLoaded;

    protected function load()
    {
        if (!self::$isLoaded) {
            $this->language = \eZLocale::currentLocaleCode();

            $this->getHelper()->setSetting('language', $this->language);

            if (!$this->hasParameter('object')) {
                throw new Exception("Content not found");
            }

            $this->object = eZContentObject::fetch((int)$this->getParameter('object'));
            if ($this->object instanceof eZContentObject) {
                $parents = $this->object->assignedNodes(false);
                $parentsIdList = array_column($parents, 'parent_node_id');
                $this->getHelper()->setParameter('parent', $parentsIdList);
            }

            if ($this->object instanceof eZContentObject) {
                if (!$this->object->canRead()) {
                    throw new Exception("User can not read object #" . $this->object->attribute('id'));
                }
                if (!self::canLockEdit($this->object)) {
                    throw new \Exception("User can not edit object #" . $this->object->attribute('id'));
                }
            }

            $this->classConnector = LockEditConnectorFactory::load($this->object, $this->getHelper(), $this->language);

//            eZINI::instance('ezflow.ini')->setVariable('eZFlowOperations', 'UpdateOnPublish', 'disabled');

            self::$isLoaded = true;
        }
    }

    public static function canLockEdit($object)
    {
        $capabilities = eZUser::currentUser()->hasAccessTo('bootstrapitalia', 'opencity_locked_editor');

        if ($capabilities['accessWord'] === 'yes') {
            return true;
        }

        if ($capabilities['accessWord'] === 'limited') {
            if (!$object instanceof eZContentObject){
                return true;
            }

            $policies = $capabilities['policies'];
            foreach ($policies as $limitations) {
                foreach ($limitations as $type => $values) {
                    if ($type === 'Node') {
                        if (in_array($object->mainNodeID(), $values)) {
                            return true;
                        }
                    } elseif ($type === 'Subtree') {
                        foreach ($values as $value) {
                            if (strpos($object->mainNode()->attribute('path_string'), $value) !== false) {
                                return true;
                            }
                        }
                    }
                }
            }
        }

        return false;
    }
}