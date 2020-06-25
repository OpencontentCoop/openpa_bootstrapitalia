<?php

class OpenPABootstrapItaliaOperators
{
    private static $cssData;

    function operatorList()
    {
        return array(
            'display_icon',
            'parse_search_get_params',
            'decode_search_params',
            'filtered_search_params_query_string',
            'openpa_roles_parent_node_id',
            'clean_filename',
            'class_identifier_by_id',
            'page_block',
            'primary_color',
            'header_color',
            'footer_color',
            'is_bookmark',
        );
    }

    function namedParameterPerOperator()
    {
        return true;
    }

    function namedParameterList()
    {
        return array(
            'display_icon' => array(
                'icon_text' => array('type' => 'string', 'required' => true),
                'icon_type' => array('type' => 'string', 'required' => true),
                'icon_class' => array('type' => 'string', 'required' => false, 'default' => null),
            ),
            'decode_search_params' => array(
                'data' => array('type' => 'array', 'required' => true),
            ),
            'filtered_search_params_query_string' => array(
                'data' => array('type' => 'array', 'required' => true),
                'filter' => array('type' => 'array', 'required' => true),
            ),
            'page_block' => array(
                'name' => array("type" => "string", "required" => true, "default" => false),
                'type' => array("type" => "string", "required" => true, "default" => false),
                'view' => array("type" => "string", "required" => true, "default" => false),
                'custom_attributes' => array("type" => "array", "required" => false, "default" => array()),
                'valid_nodes' => array("type" => "array", "required" => false, "default" => array())
            ),
            'is_bookmark' => array(
                'node_id' => array('type' => 'integer', 'required' => true),
            ),
        );
    }

    function modify(
        $tpl,
        $operatorName,
        $operatorParameters,
        $rootNamespace,
        $currentNamespace,
        &$operatorValue,
        $namedParameters
    )
    {
        switch ($operatorName) {

            case 'is_bookmark':
                $nodeId = (int)$namedParameters['node_id'];
                $operatorValue = eZContentBrowseBookmark::count(
                    eZContentBrowseBookmark::definition(),
                    [
                        'user_id' => eZUser::currentUserID(),
                        'node_id' => $nodeId
                    ]
                );
                break;

            case 'primary_color':
            case 'header_color':
            case 'footer_color':

                $cssData = self::getCss($tpl);

                $value = '#222';
                if ($operatorName == 'primary_color' && isset($cssData['.primary-bg']['background-color'])) {
                    $value = $cssData['.primary-bg']['background-color'];

                } elseif ($operatorName == 'header_color' && isset($cssData['.it-header-navbar-wrapper']['background'])) {
                    $value = $cssData['.it-header-navbar-wrapper']['background'];

                } elseif ($operatorName == 'footer_color' && isset($cssData['.it-footer-small-prints']['background-color'])) {
                    $value = $cssData['.it-footer-small-prints']['background-color'];
                }

                $operatorValue = $value;

                break;

            case 'page_block':

                $block = new eZPageBlock($namedParameters['name'], $namedParameters);
                $block->setAttribute('id', md5(mt_rand() . microtime()));

                $operatorValue = $block;

                break;

            case 'class_identifier_by_id':

                $operatorValue = eZContentClass::classIdentifierByID($operatorValue);

                break;

            case 'clean_filename':

                $operatorValue = self::cleanFileName($operatorValue);

                break;

            case 'openpa_roles_parent_node_id':

                $operatorValue = self::getOpenpaRolesParentNodeId();

                break;

            case 'display_icon':

                $iconText = $namedParameters['icon_text'];
                $iconType = $namedParameters['icon_type'];
                $iconClass = $namedParameters['icon_class'];

                if ($iconType == 'svg') {
                    $cssClass = '';
                    if ($iconClass) {
                        $cssClass = ' class="' . $iconClass . '"';
                    }
                    $path = eZURLOperator::eZDesign($tpl, 'images/svg/sprite.svg', 'ezdesign');
                    $operatorValue = '<svg' . $cssClass . '><use xlink:href="' . $path . '#' . $iconText . '"></use></svg>';
                }


                break;

            case 'parse_search_get_params':
                $operatorValue = $this->parseSearchGetParams();
                break;

            case 'decode_search_params':
                $operatorValue = $this->decodeSearchParams($namedParameters['data']);
                break;

            case 'filtered_search_params_query_string':
                $data = $namedParameters['data'];
                array_walk($data, function (&$item, $key) use ($namedParameters) {
                    $filter = $namedParameters['filter'];
                    if (isset($filter[$key])) {
                        if (is_array($item)) {
                            $item = array_diff($item, array($filter[$key]));
                        } else {
                            $item = false;
                        }
                    }

                });
                $decodeData = $this->decodeSearchParams($data);
                $operatorValue = $decodeData['_uri_suffix'];
                break;
        }
    }

    private function parseSearchGetParams()
    {
        $http = eZHTTPTool::instance();
        $data = array(
            'text' => $http->hasVariable('SearchText') ? $http->variable('SearchText') : '',
            'subtree' => $http->hasVariable('Subtree') ? $http->variable('Subtree') : array(),
            'subtree_boundary' => $http->hasVariable('SubtreeBoundary') ? (int)$http->variable('SubtreeBoundary') : false,
            'topic' => $http->hasVariable('Topic') ? $http->variable('Topic') : array(),
            'only_active' => $http->hasVariable('OnlyActive') ? (bool)$http->variable('OnlyActive') : false,
            'from' => $http->hasVariable('From') ? $http->variable('From') : false,
            'to' => $http->hasVariable('To') ? $http->variable('To') : false,
            'class' => $http->hasVariable('Class') ? (array)$http->variable('Class') : array(),
        );

        return $this->decodeSearchParams($data);
    }

    private function decodeSearchParams($data)
    {
        $queryData = array();
        foreach ($data as $key => $value) {
            if ($key == 'text' && !empty($value)) {
                $queryData['SearchText'] = $value;
            }
            if ($key == 'subtree' && !empty($value)) {
                $queryData['Subtree'] = $value;
            }
            if ($key == 'subtree_boundary' && !empty($value)) {
                $queryData['SubtreeBoundary'] = $value;
            }
            if ($key == 'topic' && !empty($value)) {
                $queryData['Topic'] = $value;
            }
            if ($key == 'only_active' && $value) {
                $queryData['OnlyActive'] = $value;
            }
            if ($key == 'from' && $value) {
                $queryData['From'] = $value;
            }
            if ($key == 'to' && $value) {
                $queryData['To'] = $value;
            }
            if ($key == 'class' && $value) {
                $queryData['Class'] = $value;
            }
        }

        $data['_uri_suffix'] = '?' . http_build_query($queryData);

        $data['class'] = array_map('intval', $data['class']);
        $data['subtree'] = array_map('intval', $data['subtree']);
        $data['topic'] = array_map('intval', $data['topic']);
        if ($data['from']) {
            $data['from'] = $this->parseDate($data['from']);
        }
        if ($data['to']) {
            $data['to'] = $this->parseDate($data['to']);
        }

        $searchHash = array();
        $searchHash['sort_by'] = array('published' => 'desc');
        if (!empty($data['text'])) {
            $searchHash['query'] = $data['text'];
            $searchHash['sort_by'] = array('score' => 'desc');
        }
        if (!empty($data['subtree'])) {
            $searchHash['subtree_array'] = $data['subtree'];
        } elseif ($data['subtree_boundary']) {
            $searchHash['subtree_array'] = array($data['subtree_boundary']);
        }

        $filters = array();
        $facets = array(
            array('field' => ezfSolrDocumentFieldBase::generateMetaFieldName('path', 'filter'), 'limit' => 100),
            array('field' => OpenPASolr::generateSolrSubMetaField('topics', 'main_node_id', 'sint'), 'limit' => 100),
            array('field' => ezfSolrDocumentFieldBase::generateMetaFieldName('contentclass_id', 'filter'), 'limit' => 100),
        );

        if (!empty($data['topic'])) {
            $topicFilter = array();
            foreach ($data['topic'] as $topic) {
                $topicFilter[] = OpenPASolr::generateSolrSubMetaField('topics', 'main_node_id', 'sint') . ':' . $topic;
            }
            if (count($topicFilter) > 1) {
                array_unshift($topicFilter, 'or');
            }
            $filters[] = $topicFilter;
        }

        if ($data['from'] && !$data['to']) {
            $filters[] = eZSolr::getMetaFieldName('published') . ':[' . ezfSolrDocumentFieldBase::preProcessValue($data['from'], 'date') . ' TO *]';
        } elseif ($data['to'] && !$data['from']) {
            $filters[] = eZSolr::getMetaFieldName('published') . ':[* TO ' . ezfSolrDocumentFieldBase::preProcessValue($data['to'], 'date') . ']';
        } elseif ($data['to'] && $data['from']) {
            $filters[] = eZSolr::getMetaFieldName('published') . ':[' . ezfSolrDocumentFieldBase::preProcessValue($data['from'], 'date') . ' TO ' . ezfSolrDocumentFieldBase::preProcessValue($data['to'], 'date') . ']';
        }

        if ($data['only_active']) {
            $stateRepo = new \Opencontent\Opendata\Api\StateRepository();
            try {
                $visible = $stateRepo->load('albotelematico.visibile'); //@todo
                $filters[] = ezfSolrDocumentFieldBase::generateMetaFieldName('object_states') . ':' . $visible['id'];
            } catch (Exception $e) {
                eZDebug::writeError($e->getMessage(), __METHOD__);
            }
        }

        $searchHash['filter'] = $filters;
        $searchHash['facet'] = $facets;
        if (!empty($data['class'])) {
            $searchHash['class_id'] = $data['class'];
        } else {
            $searchHash['class_id'] = OpenPAINI::variable('MotoreRicerca', 'IncludiClassi', null);
        }

        $data['_search_hash'] = $searchHash;

        //eZDebug::writeDebug(print_r($data, 1), __METHOD__);

        return $data;
    }

    /**
     * @param $string
     * @param int $hour
     * @param int $minute
     * @return false|int|null
     */
    private function parseDate($string, $hour = 0, $minute = 0)
    {
        if (!empty($string)) {
            $parts = explode('/', $string);
            if (count($parts) == 3) {
                return mktime($hour, $minute, 0, $parts[1], $parts[0], $parts[2]);
            }
        }

        return null;
    }

    public static function getOpenpaRolesParentNodeId()
    {
        $parentObject = eZContentObject::fetchByRemoteID(OpenPaFunctionCollection::$remoteRoles);
        if ($parentObject instanceof eZContentObject) {
            return $parentObject->attribute('main_node_id');
        }
        return 0;
    }

    public static function cleanFileName($filename)
    {
        $parts = explode('.', $filename);
        if (count($parts) > 1) {
            array_pop($parts);
        }
        $filename = implode('.', $parts);
        $filename = str_replace(array('_', '-', '+'), ' ', $filename);
        $filename = str_replace(':', '/', $filename);
        $filename = str_replace('(1)', '', $filename);
        $filename = str_replace('(2)', '', $filename);
        $filename = str_replace('(3)', '', $filename);
        $filename = str_replace('(4)', '', $filename);
        $filename = str_replace('(5)', '', $filename);

        $filename = trim($filename);

        return ucfirst($filename);
    }

    public static function getCss(eZTemplate $tpl)
    {
        if (self::$cssData === null) {

            $theme = OpenPAINI::variable('GeneralSettings', 'theme', 'default');
            $path = ltrim(eZURLOperator::eZDesign($tpl, "stylesheets/{$theme}.css", 'ezdesign'), '/');
            if (!file_exists($path)) {
                $path = "extension/openpa_bootstrapitalia/design/bootstrapitalia/stylesheets/default.css";
            }

            function parseCss($file)
            {
                $css = file_get_contents($file);
                preg_match_all('/(?ims)([a-z0-9\s\.\:#_\-@,]+)\{([^\}]*)\}/', $css, $arr);
                $result = array();
                foreach ($arr[0] as $i => $x) {
                    $selector = trim($arr[1][$i]);
                    $rules = explode(';', trim($arr[2][$i]));
                    $rules_arr = array();
                    foreach ($rules as $strRule) {
                        if (!empty($strRule)) {
                            $rule = explode(":", $strRule);
                            if (isset($rule[1])) {
                                $rules_arr[trim($rule[0])] = trim($rule[1]);
                            }
                        }
                    }

                    $selectors = explode(',', trim($selector));
                    foreach ($selectors as $strSel) {
                        $result[$strSel] = $rules_arr;
                    }
                }
                return $result;
            }

            self::$cssData = parseCss($path);
        }

        return self::$cssData;
    }
}
