<?php

class OpenPARestrictedAreaType extends eZDataType
{
    const DATA_TYPE_STRING = 'openparestrictedarea';

    public function __construct()
    {
        parent::__construct(
            self::DATA_TYPE_STRING,
            'Accesso area riservata',
            array('serialize_supported' => true)
        );
    }

    /**
     * @param eZHTTPTool $http
     * @param string $action
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @param array $parameters
     */
    function customObjectAttributeHTTPAction($http, $action, $contentObjectAttribute, $parameters)
    {
        $content = $contentObjectAttribute->content();

        switch ($action) {
            case 'browse_user':
                {
                    $module = $parameters['module'];
                    $redirectionURI = $parameters['current-redirection-uri'];

                    $userClasses = [];
                    $userClassIdList = eZUser::contentClassIDs();
                    foreach ($userClassIdList as $userClassId) {
                        $userClasses[] = eZContentClass::classIdentifierByID($userClassId);
                    }

                    $browseParameters = array(
                        'action_name' => 'AddRestrictedUserObject_' . $contentObjectAttribute->attribute('id'),
                        'type' => 'AddRestrictedUserObjectToDataType',
                        'browse_custom_action' => array(
                            'name' => 'CustomActionButton[' . $contentObjectAttribute->attribute('id') . '_set_user]',
                            'value' => $contentObjectAttribute->attribute('id')),
                        'persistent_data' => array('HasObjectInput' => 0),
                        'from_page' => $redirectionURI,
                        'start_node' => eZINI::instance('content.ini')->variable('NodeSettings', 'RootNode'),
                        'class_array' => $userClasses,
                        'selection' => 'multiple',
                        'return_type' => 'ObjectID'
                    );
                    eZContentBrowse::browse($browseParameters, $module);

                }
                break;

            case 'set_user':
                {
                    $selectedObjectIDArray = $http->postVariable("SelectedObjectIDArray");
                    $newContent = array_merge($content, $selectedObjectIDArray);
                    $contentObjectAttribute->setContent($newContent);
                    $contentObjectAttribute->store();
                }
                break;

            case 'remove_user':
                {
                    $data = $http->postVariable('CustomActionButton');
                    $removeIdList = $data[$contentObjectAttribute->attribute('id') . '_remove_user'];
                    $newContent = [];
                    foreach ($content as $id) {
                        if (!isset($removeIdList[$id])) {
                            $newContent[] = $id;
                        }
                    }
                    $contentObjectAttribute->setContent($newContent);
                    $contentObjectAttribute->store();
                }
                break;
        }
    }

    function storeObjectAttribute($contentObjectAttribute)
    {
        $content = $contentObjectAttribute->content();
        $contentObjectAttribute->setAttribute('data_text', implode('-', array_unique($content)));
    }


    /**
     * Checks if current content object attribute has content
     * Returns true if it has content
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return bool
     * @see eZDataType::hasObjectAttributeContent()
     */
    public function hasObjectAttributeContent($contentObjectAttribute)
    {
        return $contentObjectAttribute->attribute('data_text') != '';
    }

    /**
     * Returns the content.
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return string
     */
    public function objectAttributeContent($contentObjectAttribute)
    {
        if ($contentObjectAttribute->attribute('data_text') != '')
            return explode('-', $contentObjectAttribute->attribute('data_text'));
        return array();
    }

    public function onPublish($contentObjectAttribute, $contentObject, $publishedNodes)
    {
        $userIdList = $contentObjectAttribute->content();
        $section = $this->createSection($contentObject);
        if ($section instanceof eZSection) {
            $this->assignRole($section, $userIdList);
        }
        if ($contentObject->attribute('current_version') == 1) {
            $section->applyTo($contentObject);
        }
    }

    function deleteStoredObjectAttribute($contentObjectAttribute, $version = null)
    {
        if ($version == null) {
            $section = $this->createSection($contentObjectAttribute->attribute('object'));
            if ($section instanceof eZSection) {
                $this->assignRole($section, array());
                if ($section->canBeRemoved()) {
                    eZContentCacheManager::clearContentCacheIfNeededBySectionID($section->attribute('id'));
                    $section->remove();
                    ezpEvent::getInstance()->notify('content/section/cache', array($section->attribute('id')));
                }
            }
        }
    }

    function isIndexable()
    {
        return true;
    }

    function metaData($contentObjectAttribute)
    {
        return implode(', ', $contentObjectAttribute->content());
    }

    private function createSection($contentObject)
    {
        try {
            $name = '_' . $contentObject->attribute('name');
            $identifier = 'restricted_area_' . $contentObject->attribute('id');
            $section = OpenPABase::initSection($name, $identifier);
            if ($section->attribute('name') != $name) {
                $section->setAttribute('name', $name);
                $section->store();
            }

            return $section;
        } catch (Exception $e) {
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }

        return null;
    }

    private function assignRole(eZSection $section, array $userIdList)
    {
        $role = OpenPABase::initRole(
            '_Accesso area riservata',
            array(
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read'
                )
            )
        );

        $limitIdent = 'Section';
        $limitValue = $section->attribute('id');

        $query = "DELETE FROM ezuser_role WHERE role_id='{$role->ID}' AND limit_identifier='$limitIdent' AND limit_value='$limitValue'";
        eZDB::instance()->arrayQuery($query);
        foreach ($userIdList as $userId) {
            $role->assignToUser($userId, 'section', $section->attribute('id'));
        }
        eZRole::expireCache();
    }
}

eZDataType::register(OpenPARestrictedAreaType::DATA_TYPE_STRING, 'OpenPARestrictedAreaType');
