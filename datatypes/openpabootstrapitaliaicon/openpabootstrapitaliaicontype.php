<?php

class OpenPABootstrapItaliaIconType extends eZDataType
{
    const DATA_TYPE_STRING = 'openpabootstrapitaliaicon';

    const CONTENT_FIELD_VARIABLE = '_openpabootstrapitaliaicon_data_text_';

    /**
     * Constructor
     */
    public function __construct()
    {
        parent::__construct(self::DATA_TYPE_STRING, 'Icona Bootstrap Italia');
    }

    public static function getIconList()
    {
        $iconList = array();
        $iniList = eZINI::instance('bootstrapitaliaicons.ini')->variable('IconsList', 'SvgIcons');
        foreach ($iniList as $value => $name) {
            $iconList[$name] = array(
                'name' => $name,
                'value' => $value,
            );
        }
        ksort($iconList);

        return $iconList;
    }

    function classAttributeContent($classAttribute)
    {
        return self::getIconList();
    }

    /**
     * Fetches all variables from the object and handles them
     * Data store can be done here
     * @param eZHTTPTool $http
     * @param string $base POST variable name prefix (Always "ContentObjectAttribute")
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return true if fetching of class attributes are successfull, false if not
     */
    public function fetchObjectAttributeHTTPInput($http, $base, $contentObjectAttribute)
    {
        $fieldName = $base . self::CONTENT_FIELD_VARIABLE . $contentObjectAttribute->attribute('id');

        if ($http->hasPostVariable($fieldName)) {
            $contentObjectAttribute->setAttribute('data_text', $http->postVariable($fieldName));
        }

        return true;
    }

    /**
     * Performs necessary actions with attribute data after object is published
     * Returns true if the value was stored correctly
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @param eZContentObject $contentObject The published object
     * @param eZContentObjectTreeNode[] $publishedNodes
     * @return bool
     * @see eZDataType::onPublish()
     */
    public function onPublish($contentObjectAttribute, $contentObject, $publishedNodes)
    {
        OpenPABootstrapItaliaIcon::removeByContentObjectAttributeId($contentObjectAttribute->attribute('id'));
        if ($contentObjectAttribute->attribute('data_text') != '') {
            $nodeIdList = array();
            foreach ($publishedNodes as $node){
                $nodeIdList[] = $node->attribute('node_id');
            }
            OpenPABootstrapItaliaIcon::createWithNodeList($nodeIdList, $contentObjectAttribute->attribute('data_text'), $contentObjectAttribute->attribute('id'));
        }
        return true;
    }

    /**
     * Deletes $objectAttribute datatype data, optionally in version $version.
     *
     * @param eZContentObjectAttribute $objectAttribute
     * @param int $version
     */
    public function deleteStoredObjectAttribute($objectAttribute, $version = null)
    {
        if ($version === null) {
            OpenPABootstrapItaliaIcon::removeByContentObjectAttributeId($objectAttribute->attribute('id'));
        }
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
        return trim($contentObjectAttribute->attribute('data_text')) != '';
    }

    /**
     * Returns the content.
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return string
     */
    public function objectAttributeContent($contentObjectAttribute)
    {
        return $contentObjectAttribute->attribute('data_text');
    }

    /**
     * Returns the meta data used for storing search indeces.
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return string
     */
    public function metaData($contentObjectAttribute)
    {
        return $contentObjectAttribute->attribute('data_text');
    }

    /**
     * Initializes the object attribute from a string representation
     * @param eZContentObjectAttribute $objectAttribute
     * @param string
     * @see eZDataType::fromString()
     */
    public function fromString($objectAttribute, $string)
    {
        $objectAttribute->setAttribute('data_text', $string);
    }

    /**
     * Returns the string representation of the object attribute
     * @param eZContentObjectAttribute $objectAttribute
     * @see eZDataType::toString()
     * @return string
     */
    public function toString($objectAttribute)
    {
        return $objectAttribute->attribute('data_text');
    }

}

eZDataType::register(OpenPABootstrapItaliaIconType::DATA_TYPE_STRING, 'OpenPABootstrapItaliaIconType');