<?php

class OpenPABootstrapItaliaImageUploadHandler extends eZContentUploadHandler
{
    function __construct()
    {
        parent::__construct('Image file upload handler', 'image-with-default-license');
    }

    /**
     * @param eZContentUpload $upload
     * @param array $result
     * @param string $filePath
     * @param string $originalFilename
     * @param array $mimeData
     * @param string $location
     * @param eZContentObjectTreeNode|false $existingNode
     * @return array
     */
    function handleFile(&$upload, &$result,
                        $filePath, $originalFilename, $mimeData,
                        $location, $existingNode)
    {
        $tmpDir = getcwd() . "/" . eZSys::cacheDirectory();

        $originalFilename = basename($originalFilename);
        $tmpFile = $tmpDir . "/" . $originalFilename;

        copy($filePath, $tmpFile);

        $this->handleLocalFile(
            $upload,
            $result,
            $tmpFile,
            $originalFilename,
            $mimeData,
            $location,
            $existingNode
        );
        unlink($tmpFile);

        return $result;
    }

    /**
     * @param eZContentUpload $upload
     * @param array $result
     * @param string $filePath
     * @param string $originalFilename
     * @param array $mimeData
     * @param string $location
     * @param eZContentObjectTreeNode|false $existingNode
     * @return bool
     */
    function handleLocalFile(&$upload, &$result,
                             $filePath, $originalFilename, $mimeData,
                             $location, $existingNode)
    {

        $mime = $mimeData['name'];

        $object = false;
        $class = false;
        // Figure out class identifier from an existing node
        // if not we will have to detect it from the mimetype
        if (is_object($existingNode)) {
            $object = $existingNode->object();
            $class = $object->contentClass();
            $classIdentifier = $class->attribute('identifier');
        } else {
            $classIdentifier = $upload->detectClassIdentifier($mime);
        }

        if (!$classIdentifier) {
            $result['errors'][] =
                array('description' => ezpI18n::tr('kernel/content/upload',
                    'No matching class identifier found.'));

            return false;
        }

        if (!is_object($class))
            $class = eZContentClass::fetchByIdentifier($classIdentifier);

        if (!$class) {
            $result['errors'][] =
                array('description' => ezpI18n::tr('kernel/content/upload',
                    'The class %class_identifier does not exist.', null,
                    array('%class_identifier' => $classIdentifier)));

            return false;
        }

        $parentNodes = false;
        $parentMainNode = false;
        // If do not have an existing node we need to figure
        // out the locations from $location and $classIdentifier
        if (!is_object($existingNode)) {
            $locationOK = $upload->detectLocations($classIdentifier, $class, $location, $parentNodes, $parentMainNode);
            if ($locationOK === false) {
                $result['errors'][] =
                    array('description' => ezpI18n::tr('kernel/content/upload',
                        'Was not able to figure out placement of object.'));

                return false;
            } elseif ($locationOK === null) {
                $result['status'] = eZContentUpload::STATUS_PERMISSION_DENIED;
                $result['errors'][] =
                    array('description' => ezpI18n::tr('kernel/content/upload',
                        'Permission denied'));

                return false;
            }
        }

        $uploadINI = eZINI::instance('upload.ini');
        $iniGroup = $classIdentifier . '_ClassSettings';
        if (!$uploadINI->hasGroup($iniGroup)) {
            $result['errors'][] =
                array('description' => ezpI18n::tr('kernel/content/upload',
                    'No configuration group in upload.ini for class identifier %class_identifier.', null,
                    array('%class_identifier' => $classIdentifier)));

            return false;
        }

        $fileAttribute = $uploadINI->variable($iniGroup, 'FileAttribute');
        $dataMap = $class->dataMap();

        $fileAttribute = $upload->findRegularFileAttribute($dataMap, $fileAttribute);
        if (!$fileAttribute) {
            $result['errors'][] =
                array('description' => ezpI18n::tr('kernel/content/upload',
                    'No matching file attribute found, cannot create content object without this.'));

            return false;
        }

        $nameAttribute = $uploadINI->variable($iniGroup, 'NameAttribute');
        if (!$nameAttribute) {
            $nameAttribute = $upload->findStringAttribute($dataMap, $nameAttribute);
        }
        if (!$nameAttribute) {
            $result['errors'][] =
                array('description' => ezpI18n::tr('kernel/content/upload',
                    'No matching name attribute found, cannot create content object without this.'));

            return false;
        }

        $variables = array(
            'original_filename' => $mimeData['filename'],
            'mime_type' => $mime
        );
        $variables['original_filename_base'] = $mimeData['basename'];
        $variables['original_filename_suffix'] = $mimeData['suffix'];

        $namePattern = $uploadINI->variable($iniGroup, 'NamePattern');
        $nameString = OpenPABootstrapItaliaOperators::cleanFileName($upload->processNamePattern($variables, $namePattern));

        $licenseAttribute = $uploadINI->variable($iniGroup, 'LicenseAttribute');
        $licenseString = $this->getLicenseString($uploadINI->variable($iniGroup, 'DefaultLicenseKeyword'));

        // If we have an existing node we need to create
        // a new version in it.
        // If we don't we have to make a new object
        if (is_object($existingNode)) {
            if ($existingNode->canEdit() != '1') {
                $result['status'] = eZContentUpload::STATUS_PERMISSION_DENIED;
                $result['errors'][] =
                    array('description' => ezpI18n::tr('kernel/content/upload',
                        'Permission denied'));

                return false;
            }
            $version = $object->createNewVersion(false, true);
            unset($dataMap);
            $dataMap = $version->dataMap();
            $publishVersion = $version->attribute('version');
        } else {
            $object = $class->instantiate();
            unset($dataMap);
            $dataMap = $object->dataMap();
            $publishVersion = $object->attribute('current_version');
        }

        $status = $dataMap[$fileAttribute]->insertRegularFile(
            $object,
            $publishVersion,
            eZContentObject::defaultLanguage(),
            $filePath,
            $storeResult
        );
        if ($status === null) {
            $result['errors'][] =
                array('description' => ezpI18n::tr('kernel/content/upload',
                    'The attribute %class_identifier does not support regular file storage.', null,
                    array('%class_identifier' => $dataMap[$fileAttribute]->attribute('contentclass_attribute_name'))));

            return false;
        } else if (!$status) {
            $result['errors'] = array_merge($result['errors'], $storeResult['errors']);

            return false;
        }
        if ($storeResult['require_storage'])
            $dataMap[$fileAttribute]->store();

        $status = $dataMap[$nameAttribute]->insertSimpleString(
            $object,
            $publishVersion,
            eZContentObject::defaultLanguage(),
            $nameString,
            $storeResult
        );
        if ($status === null) {
            $result['errors'][] =
                array('description' => ezpI18n::tr('kernel/content/upload',
                    'The attribute %class_identifier does not support simple string storage.', null,
                    array('%class_identifier' => $dataMap[$nameAttribute]->attribute('contentclass_attribute_name'))));


            return false;
        } else if (!$status) {
            $result['errors'] = array_merge($result['errors'], $storeResult['errors']);

            return false;
        }
        if ($storeResult['require_storage']) {
            $dataMap[$nameAttribute]->store();
        }

        if ($licenseAttribute && $licenseString) {
            $dataMap[$licenseAttribute]->fromString($licenseString);
            $dataMap[$licenseAttribute]->store();
        }

        if (is_array($parentNodes)) {
            foreach ($parentNodes as $parentNode) {
                $object->createNodeAssignment(
                    $parentNode,
                    $parentNode == $parentMainNode
                );
            }
        }

        return $upload->publishObject(
            $result,
            $result['errors'],
            $result['notices'],
            $object,
            $publishVersion,
            $class,
            $parentNodes,
            $parentMainNode
        );
    }

    private function getLicenseString($defaultLicenseKeyword)
    {        
        $tagsList = eZTagsObject::fetchByKeyword($defaultLicenseKeyword);
        if (is_array($tagsList) && !empty($tagsList)){
            $tag = $tagsList[0];
            $stringData = array(
                $tag->attribute('id'),
                $tag->attribute('keyword'),
                $tag->attribute('parent_id'),
                eZLocale::currentLocaleCode()
            );

            return implode('|#', $stringData);
        }

        return false;
    }

}
