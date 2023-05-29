<?php

class ezjscBrowse extends ezjscServerFunctionsNode
{

    public static function subTree($args)
    {
        $parentNodeID = isset($args[0]) ? $args[0] : null;
        $limit = isset($args[1]) ? $args[1] : 25;
        $offset = isset($args[2]) ? $args[2] : 0;
        $sort = isset($args[3]) ? self::sortMap($args[3]) : 'published';
        $order = isset($args[4]) ? $args[4] : false;
        $objectNameFilter = isset($args[5]) ? $args[5] : '';

        if (!$parentNodeID) {
            throw new ezcBaseFunctionalityNotSupportedException('Fetch node list', 'Parent node id is not valid');
        }

        $node = eZContentObjectTreeNode::fetch($parentNodeID);
        if (!$node instanceof eZContentObjectTreeNode) {
            throw new ezcBaseFunctionalityNotSupportedException(
                'Fetch node list',
                "Parent node '$parentNodeID' is not valid"
            );
        }

        $ezjscoreIni = eZINI::instance('ezjscore.ini');
        $hardLimit = (int)$ezjscoreIni->variable('ezjscServer_ezjscnode', 'HardLimit');

        if ($hardLimit > 0 && $limit > $hardLimit) {
            $limit = $hardLimit;
        }

        $params = [
            'Depth' => 1,
            'Limit' => $limit,
            'Offset' => $offset,
            'SortBy' => [[$sort, $order]],
            'DepthOperator' => 'eq',
            'ObjectNameFilter' => $objectNameFilter,
            'AsObject' => true,
        ];

        // fetch nodes and total node count
        $count = $node->subTreeCount($params);
        if ($count) {
            $nodeArray = $node->subTree($params);
        } else {
            $nodeArray = [];
        }
        unset($node);// We have on purpose not checked permission on $node itself, so it should not be used

        // generate json response from node list
        if ($nodeArray) {
            $list = self::nodeEncode($nodeArray, [
                'formatDate' => 'shortdatetime',
                'fetchThumbPreview' => true,
                'fetchSection' => true,
                'fetchCreator' => true,
                'fetchClassIcon' => true,
//                'dataMap' => ['image'],
//                'dataMapType' => [eZObjectRelationListType::DATA_TYPE_STRING],
            ], 'raw');
        } else {
            $list = [];
        }

        return [
            'parent_node_id' => $parentNodeID,
            'count' => count($nodeArray),
            'total_count' => (int)$count,
            'list' => $list,
            'limit' => $limit,
            'offset' => $offset,
            'sort' => $sort,
            'order' => $order,
        ];
    }

    private static function nodeEncode($obj, $params = [], $type = 'json')
    {
        if (is_array($obj)) {
            $ret = [];
            foreach ($obj as $ob) {
                $ret[] = self::simplify($ob, $params);
            }
        } else {
            $ret = self::simplify($obj, $params);
        }

        if ($type === 'xml') {
            return ezjscAjaxContent::xmlEncode($ret);
        } else {
            if ($type === 'json') {
                return json_encode($ret);
            } else {
                return $ret;
            }
        }
    }

    public static function simplify($obj, $params = [])
    {
        if (!$obj) {
            return [];
        } else {
            if ($obj instanceof eZContentObject) {
                $node = $obj->attribute('main_node');
                $contentObject = $obj;
            } else {
                if ($obj instanceof eZContentObjectTreeNode || $obj instanceof eZFindResultNode) {
                    $node = $obj;
                    $contentObject = $obj->attribute('object');
                } else {
                    if (isset($params['fetchNodeFunction']) && method_exists($obj, $params['fetchNodeFunction'])) {
                        // You can supply fetchNodeFunction parameter to be able to support other node related classes
                        $node = call_user_func([$obj, $params['fetchNodeFunction']]);
                        if (!$node instanceof eZContentObjectTreeNode) {
                            return '';
                        }
                        $contentObject = $node->attribute('object');
                    } else {
                        if (is_array($obj)) {
                            return $obj; // Array is returned as is
                        } else {
                            return ''; // Other passed objects are not supported
                        }
                    }
                }
            }
        }

        $ini = eZINI::instance('site.ini');
        $params = array_merge([
            'dataMap' => [], // collection of identifiers you want to load, load all with array('all')
            'fetchPath' => false, // fetch node path
            'fetchSection' => false, // fetch section
            'fetchChildrenCount' => false,
            'dataMapType' => [], //if you want to filter datamap by type
            'loadImages' => false,
            'imagePreGenerateSizes' => ['small'] //Pre generated images, loading all can be quite time consuming
        ], $params);

        if (!isset($params['imageSizes']))// list of available image sizes
        {
            $imageIni = eZINI::instance('image.ini');
            $params['imageSizes'] = $imageIni->variable('AliasSettings', 'AliasList');
        }

        if ($params['imageSizes'] === null || !isset($params['imageSizes'][0])) {
            $params['imageSizes'] = [];
        }

        if (!isset($params['imageDataTypes'])) {
            $params['imageDataTypes'] = $ini->variable('ImageDataTypeSettings', 'AvailableImageDataTypes');
        }

        $ret = [];
        $attributeArray = [];
        $ret['name'] = htmlentities($contentObject->attribute('name'), ENT_QUOTES, "UTF-8");
        $ret['contentobject_id'] = $ret['id'] = (int)$contentObject->attribute('id');
        $ret['contentobject_remote_id'] = $contentObject->attribute('remote_id');
        $ret['contentobject_state'] = implode(", ", $contentObject->attribute('state_identifier_array'));
        $ret['main_node_id'] = (int)$contentObject->attribute('main_node_id');
        $ret['version'] = (int)$contentObject->attribute('current_version');
        $ret['modified'] = $contentObject->attribute('modified');
        $ret['published'] = $contentObject->attribute('published');
        $ret['section_id'] = (int)$contentObject->attribute('section_id');
        $ret['current_language'] = $contentObject->attribute('current_language');
        $ret['owner_id'] = (int)$contentObject->attribute('owner_id');
        $ret['class_id'] = (int)$contentObject->attribute('contentclass_id');
        $ret['class_name'] = $contentObject->attribute('class_name');
        $ret['path_identification_string'] = $node ? $node->attribute('path_identification_string') : '';
        $ret['translations'] = eZContentLanguage::decodeLanguageMask($contentObject->attribute('language_mask'), true);
        $ret['can_edit'] = $contentObject->attribute('can_edit');

        if (isset($params['formatDate'])) {
            $ret['modified_date'] = ezjscAjaxContent::formatLocaleDate(
                $contentObject->attribute('modified'),
                $params['formatDate']
            );
            $ret['published_date'] = ezjscAjaxContent::formatLocaleDate(
                $contentObject->attribute('published'),
                $params['formatDate']
            );
        }

        if (isset($params['fetchCreator'])) {
            $creator = $contentObject->attribute('current')->attribute('creator');
            if ($creator instanceof eZContentObject) {
                $ret['creator'] = [
                    'id' => $creator->attribute('id'),
                    'name' => $creator->attribute('name'),
                ];
            } else {
                $ret['creator'] = [
                    'id' => $contentObject->attribute('current')->attribute('creator_id'),
                    'name' => null,
                ];// user has been deleted
            }
        }

        if (isset($params['fetchClassIcon'])) {
            $operator = new eZWordToImageOperator();
            $tpl = eZTemplate::instance();

            $operatorValue = $contentObject->attribute('class_identifier');

            $operatorParameters = [[[1, 'small']]];
            $namedParameters = [];

            $operatorName = 'class_icon';

            $operator->modify(
                $tpl, $operatorName, $operatorParameters, '', '',
                $operatorValue, $namedParameters, []
            );

            $ret['class_icon'] = $operatorValue;
        }

        if (isset($params['fetchThumbPreview'])) {
            $thumbUrl = '';
            $thumbWidth = 0;
            $thumbHeight = 0;
            $thumbDataType = isset($params['thumbDataType']) ? $params['thumbDataType'] : 'ezimage';
            $thumbImageSize = isset($params['thumbImageSize']) ? $params['thumbImageSize'] : 'small';
            $imageRelationAttribute = null;
            foreach ($contentObject->attribute('data_map') as $key => $atr) {
                if ($atr->attribute('data_type_string') == $thumbDataType
                    && $atr->attribute('has_content')) {
                    $imageContent = $atr->attribute('content');

                    if ($imageContent->hasAttribute($thumbImageSize)) {
                        $imageAlias = $imageContent->attribute($thumbImageSize);
                    } else {
                        eZDebug::writeError(
                            "Image alias does not exist: '{$thumbImageSize}', missing from image.ini?",
                            __METHOD__
                        );
                    }

                    $thumbUrl = isset($imageAlias['full_path']) ? $imageAlias['full_path'] : '';
                    $thumbWidth = isset($imageAlias['width']) ? (int)$imageAlias['width'] : 0;
                    $thumbHeight = isset($imageAlias['height']) ? (int)$imageAlias['height'] : 0;

                    if ($thumbUrl !== '') {
                        eZURI::transformURI($thumbUrl, true, null, false);
                    }

                    break;
                }
                if ($atr->attribute('data_type_string') == eZObjectRelationListType::DATA_TYPE_STRING
                    && $atr->attribute('contentclass_attribute_identifier') == 'image'
                    && $atr->attribute('has_content')){
                    $imageObjectId = (int)explode('-', $atr->toString())[0];
                    $imageObject = $imageObjectId > 0 ? eZContentObject::fetch($imageObjectId) : null;
                    if ($imageObject instanceof eZContentObject){
                        $imageEncoded = self::simplify($imageObject, [
                            'fetchThumbPreview' => true,
                            'fetchSection' => false,
                            'fetchCreator' => false,
                            'fetchClassIcon' => false,
                        ]);
                        $thumbUrl = $imageEncoded['thumbnail_url'] ?? '';
                        $thumbWidth = $imageEncoded['thumbnail_width'] ?? 0;
                        $thumbHeight = $imageEncoded['thumbnail_height'] ?? 0;
                    }
                }
            }

            $ret['thumbnail_url'] = $thumbUrl;
            $ret['thumbnail_width'] = $thumbWidth;
            $ret['thumbnail_height'] = $thumbHeight;
        }

        if ($params['fetchSection']) {
            $section = eZSection::fetch($ret['section_id']);
            if ($section instanceof eZSection) {
                $ret['section'] = [
                    'id' => $section->attribute('id'),
                    'name' => $section->attribute('name'),
                    'navigation_part_identifier' => $section->attribute('navigation_part_identifier'),
                    'locale' => $section->attribute('locale'),
                ];
            } else {
                $ret['section'] = null;
            }
        }

        if ($node) {
            // optimization for eZ Publish 4.1 (avoid fetching class)
            if ($node->hasAttribute('is_container')) {
                $ret['class_identifier'] = $node->attribute('class_identifier');
                $ret['is_container'] = (int)$node->attribute('is_container');
            } else {
                $class = $contentObject->attribute('content_class');
                $ret['class_identifier'] = $class->attribute('identifier');
                $ret['is_container'] = (int)$class->attribute('is_container');
            }

            $ret['node_id'] = (int)$node->attribute('node_id');
            $ret['parent_node_id'] = (int)$node->attribute('parent_node_id');
            $ret['node_remote_id'] = $node->attribute('remote_id');
            $ret['url_alias'] = $node->attribute('url_alias');
            $ret['url'] = $node->url();
            // force system url on empty urls (root node)
            if ($ret['url'] === '') {
                $ret['url'] = 'content/view/full/' . $node->attribute('node_id');
            }
            eZURI::transformURI($ret['url']);

            $ret['depth'] = (int)$node->attribute('depth');
            $ret['priority'] = (int)$node->attribute('priority');
            $ret['hidden_status_string'] = $node->attribute('hidden_status_string');

            if ($params['fetchPath']) {
                $ret['path'] = [];
                foreach ($node->attribute('path') as $n) {
                    $ret['path'][] = self::simplify($n);
                }
            } else {
                $ret['path'] = false;
            }

            if ($params['fetchChildrenCount']) {
                $ret['children_count'] = $ret['is_container'] ? (int)$node->attribute('children_count') : 0;
            } else {
                $ret['children_count'] = false;
            }
        } else {
            $class = $contentObject->attribute('content_class');
            $ret['class_identifier'] = $class->attribute('identifier');
            $ret['is_container'] = (int)$class->attribute('is_container');
        }

        $ret['image_attributes'] = [];

        if (is_array($params['dataMap']) && is_array($params['dataMapType'])) {
            $dataMap = $contentObject->attribute('data_map');
            $datatypeBlacklist = array_fill_keys(
                $ini->variable('ContentSettings', 'DatatypeBlackListForExternal'),
                true
            );
            foreach ($dataMap as $key => $atr) {
                $dataTypeString = $atr->attribute('data_type_string');
                //if ( in_array( $dataTypeString, $params['imageDataTypes'], true) !== false )

                if (!in_array('all', $params['dataMap'], true)
                    && !in_array($key, $params['dataMap'], true)
                    && !in_array($dataTypeString, $params['dataMapType'], true)
                    && !($params['loadImages'] && in_array($dataTypeString, $params['imageDataTypes'], true))) {
                    continue;
                }

                $attributeArray[$key]['id'] = $atr->attribute('id');
                $attributeArray[$key]['type'] = $dataTypeString;
                $attributeArray[$key]['identifier'] = $key;
                if (isset ($datatypeBlacklist[$dataTypeString])) {
                    $attributeArray[$key]['content'] = null;
                } else {
                    $attributeArray[$key]['content'] = $atr->toString();
                }

                // images
                if (in_array($dataTypeString, $params['imageDataTypes'], true) && $atr->hasContent()) {
                    $content = $atr->attribute('content');
                    $imageArray = [];
                    if ($content != null) {
                        foreach ($params['imageSizes'] as $size) {
                            $imageArray[$size] = false;
                            if (in_array($size, $params['imagePreGenerateSizes'], true)) {
                                if ($content->hasAttribute($size)) {
                                    $imageArray[$size] = $content->attribute($size);
                                } else {
                                    eZDebug::writeError(
                                        "Image alias does not exist: '$size', missing from image.ini?",
                                        __METHOD__
                                    );
                                }
                            }
                        }
                        $ret['image_attributes'][] = $key;
                    }

                    if (!isset($imageArray['original'])) {
                        $imageArray['original'] = $content->attribute('original');
                    }

                    array_walk_recursive(
                        $imageArray,
                        function (&$element, $key) {
                            // These fields can contain non utf-8 content
                            // badly handled by mb_check_encoding
                            // so they are just encoded in base64
                            // see https://jira.ez.no/browse/EZP-21358
                            if ($key == "MakerNote" || $key == "UserComment") {
                                $element = base64_encode((string)$element);
                            }
                            // json_encode/xmlEncode need UTF8 encoded strings
                            // (exif) metadata might not be for instance
                            // see https://jira.ez.no/browse/EZP-19929
                            else {
                                if (!mb_check_encoding($element, 'UTF-8')) {
                                    $element = mb_convert_encoding(
                                        (string)$element,
                                        'UTF-8'
                                    );
                                }
                            }
                            if ($key === 'url') {
                                eZURI::transformURI($element, true);
                            }
                        }
                    );

                    $attributeArray[$key]['content'] = $imageArray;
                }
            }
        }
        $ret['data_map'] = $attributeArray;
        return $ret;
    }

    public static function search($args)
    {

    }
}