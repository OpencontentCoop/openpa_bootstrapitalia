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
            'current_theme',
            'current_theme_has_variation',
            'primary_color',
            'header_color',
            'footer_color',
            'is_bookmark',
            'privacy_states',
            'menu_item_tree_contains',
            'lang_selector_url',
            'valuation_translation',
            'max_upload_size',
            'explode_contact',
            'is_empty_matrix',
            'cookie_consent_config_translations',
            'subtree_classes',
            'find_common_class_attributes',
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
            'menu_item_tree_contains' => array(
                'item' => array('type' => 'array', 'required' => true),
                'id_list' => array('type' => 'array', 'required' => true),
            ),
            'lang_selector_url' => array(
                'siteaccess' => array(
                    'type' => 'string',
                    'required' => true,
                    'default' => ''
                )
            ),
            'valuation_translation' => array(
                'string' => array('type' => 'string', 'required' => true),
            ),
            'current_theme_has_variation' => array(
                'variation' => array('type' => 'string', 'required' => true),
            ),
            'subtree_classes' => array(
                'node' => array('type' => 'object', 'required' => true),
            ),
            'find_common_class_attributes' => array(
                'classes' => array( 'type' => 'array', 'required' => true ),
                'extra_identifier' => array( 'type' => 'string', 'required' => false, 'default' => false ),
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

            case 'find_common_class_attributes':
                $attributes = [];
                /** @var eZContentClass[] $classes */
                $classes = $namedParameters['classes'];
                $identifiers = [];
                $extra = [];
                foreach ($classes as $class){
                    if ($namedParameters['extra_identifier']){
                        $extra[$class->attribute('id')] = [];
                        $extraParameters = OCClassExtraParameters::fetchByHandlerAndClassIdentifier($namedParameters['extra_identifier'], $class->attribute('identifier'));
                        foreach ($extraParameters as $extraParameter) {
                            if ($extraParameter->attribute('attribute_identifier') != '*'){
                                $extra[$class->attribute('id')][] = $extraParameter->attribute('attribute_identifier');
                            }
                        }
                        eZDebug::writeDebug($extra, $class->attribute('identifier'));
                        $identifiers[$class->attribute('id')] = $extra[$class->attribute('id')];
                    }else{
                        $identifiers[$class->attribute('id')] = array_keys($class->dataMap());
                    }
                }

                $commonIdentifiers =  count($identifiers) > 1 ? call_user_func_array('array_intersect', $identifiers) : [];
                $commonAttributes = [];
                foreach ($classes as $class) {
                    $attributes['class-' . $class->attribute('id')] = [];
                    foreach ($class->dataMap() as $identifier => $attribute) {
                        if (in_array($identifier, $commonIdentifiers)) {
                            if (!isset($commonAttributes[$identifier])) {
                                $commonAttributes[$identifier] = $attribute;
                            }
                        } else {
                            if ($namedParameters['extra_identifier']) {
                                if (in_array($identifier, $extra[$class->attribute('id')])) {
                                    $attributes['class-' . $class->attribute('id')][$identifier] = $attribute;
                                }
                            } else {
                                $attributes['class-' . $class->attribute('id')][$identifier] = $attribute;
                            }
                        }
                    }
                }

                $attributes['common'] = $commonAttributes;
                $operatorValue = $attributes;

                break;

            case 'subtree_classes':
                $operatorValue = [];
                if ($namedParameters['node'] instanceof eZContentObjectTreeNode) {
                    $pathStringCond = '';
                    $notEqParentString = '';
                    eZContentObjectTreeNode::createPathConditionAndNotEqParentSQLStrings(
                        $pathStringCond,
                        $notEqParentString,
                        $namedParameters['node']->attribute('node_id'),
                        1,
                        'eq'
                    );
                    $limitation = false;
                    $limitationList = eZContentObjectTreeNode::getLimitationList($limitation);
                    $sqlPermissionChecking = eZContentObjectTreeNode::createPermissionCheckingSQL($limitationList);
                    $languageFilter = eZContentLanguage::languagesSQLFilter('ezcontentobject');

                    $query = "SELECT DISTINCT 
                                    ezcontentclass.*
                              FROM
                                   ezcontentobject_tree
                                   INNER JOIN ezcontentobject ON (ezcontentobject.id = ezcontentobject_tree.contentobject_id)
                                   INNER JOIN ezcontentclass ON (ezcontentclass.id = ezcontentobject.contentclass_id)
                                   INNER JOIN ezcontentobject_name ON (
                                       ezcontentobject_name.contentobject_id = ezcontentobject_tree.contentobject_id AND
                                       ezcontentobject_name.content_version = ezcontentobject_tree.contentobject_version
                                   )
                               WHERE $pathStringCond 
                                     ezcontentclass.version=0 AND
                                     $notEqParentString
                                     $sqlPermissionChecking[where]
                                     $languageFilter";

                    $classList = eZDB::instance()->arrayQuery($query);
                    $operatorValue = eZPersistentObject::handleRows($classList, 'eZContentClass', true);
                }

                break;

            case 'cookie_consent_config_translations':
                $operatorValue = json_encode(self::getCookieConsentConfigTranslations());
                break;

            case 'is_empty_matrix':
                if ($operatorValue instanceof eZContentObjectAttribute
                    && $operatorValue->attribute('data_type_string') == eZMatrixType::DATA_TYPE_STRING) {
                    /** @var eZMatrix $matrix */
                    $matrix = $operatorValue->attribute('content');
                    $rows = $matrix->attribute('rows');
                    $hasContent = false;
                    foreach ($rows['sequential'] as $index => $row) {
                        $isEmpty = true;
                        foreach ($row['columns'] as $column) {
                            $column = trim($column);
                            if (!empty($column)) {
                                $isEmpty = false;
                                break;
                            }
                        }
                        if (!$isEmpty) {
                            $hasContent = true;
                            break;
                        }
                    }
                    $operatorValue = !$hasContent;
                }else{
                    $operatorValue = true;
                }
                break;

            case 'explode_contact':
                $originalString = $operatorValue;
                $strings = [];
                $parts = explode(',', $originalString);
                foreach ($parts as $part){
                    $subParts = explode('|', $part);
                    $value = trim($subParts[0]);
                    $name = isset($subParts[1]) ? trim($subParts[1]) : $value;
                    if (!empty($value)){
                        $strings[$name] = $value;
                    }
                }
                $operatorValue = $strings;
                break;

            case 'max_upload_size':
                $postMaxSize = trim(ini_get('post_max_size'), 'M');
                if ($operatorValue == 0 || $operatorValue > $postMaxSize){
                    $operatorValue = $postMaxSize;
                }
                break;

            case 'valuation_translation':
                $operatorValue = self::translateValuation($namedParameters['string']);
                break;

            case 'lang_selector_url':
                {
                    if (empty($namedParameters['siteaccess'])) {
                        return;
                    }
                    $ini = eZSiteAccess::getIni($namedParameters['siteaccess'], 'site.ini');
                    $destinationLocale = $ini->variable('RegionalSettings', 'ContentObjectLocale');
                    $siteLanguageList = $ini->variable('RegionalSettings', 'SiteLanguageList');
                    $nodeID = eZURLAliasML::fetchNodeIDByPath($operatorValue);
                    $destinationElement = eZURLAliasML::fetchByAction('eznode', $nodeID, $destinationLocale, false);
                    if (empty($destinationElement) || (!isset($destinationElement[0]) && !($destinationElement[0] instanceof eZURLAliasML))) {
                        if ($this->isModuleUrl($operatorValue) || $this->isCurrentLocaleAvailable($siteLanguageList)) {
                            $destinationUrl = $operatorValue;
                        } else {
                            $destinationUrl = '';
                        }
                    } else {
                        $destinationUrl = $destinationElement[0]->getPath($destinationLocale, $siteLanguageList);
                    }
                    $destinationUrl = eZURI::encodeURL($destinationUrl);
                    if (eZINI::instance()->variable('SiteAccessSettings', 'MatchOrder') == 'host_uri'){
                        $scheme = eZSys::isSSLNow() ? 'https://' : 'http://';
                        $operatorValue = $scheme . rtrim($ini->variable('SiteSettings', 'SiteURL'), '/') . '/' . ltrim($destinationUrl, '/');
                    }else {
                        $prefix = '/' . $namedParameters['siteaccess'];
                        if (eZINI::instance()->variable('SiteSettings', 'DefaultAccess') == $namedParameters['siteaccess']
                            && eZINI::instance()->variable('SiteAccessSettings', 'RemoveSiteAccessIfDefaultAccess') == 'enabled') {
                            $prefix = '';
                        }
                        $operatorValue = $prefix . '/' . ltrim($destinationUrl, '/');
                    }
                }
                break;

            case 'menu_item_tree_contains':
                $item = $namedParameters['item'];
                $idList = (array)$namedParameters['id_list'];
                if (in_array($item['item']['node_id'], $idList)){
                    $operatorValue = true;
                }elseif ($item['has_children']){
                    $operatorValue = $this->recursiveMenuTreeContains($item, $idList);
                }else{
                    $operatorValue = false;
                }
                break;

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

            case 'privacy_states':
                try {
                    $operatorValue = OpenPABase::initStateGroup('privacy', ['public', 'private']);
                }catch (Exception $e){
                    eZDebug::writeError($e->getMessage(), __METHOD__);
                    $operatorValue = [
                        'privacy.public' => 0,
                        'privacy.private' => 0
                    ];
                }
                break;

            case 'current_theme':
                $operatorValue = self::getCurrentTheme()->getBaseIdentifier();
                break;

            case 'current_theme_has_variation':
                $operatorValue = self::getCurrentTheme()->hasVariation($namedParameters['variation']);
                break;

            case 'primary_color':
                $operatorValue = self::getCurrentTheme()->getCssData('primary_color', '#222');
                break;

            case 'header_color':
                $operatorValue = self::getCurrentTheme()->getCssData('header_color', '#222');
                break;

            case 'footer_color':
                $operatorValue = self::getCurrentTheme()->getCssData('footer_color', '#222');
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
            'sort' => $http->hasVariable('Sort') ? $http->variable('Sort') : false,
            'order' => $http->hasVariable('Order') ? $http->variable('Order') : 'desc',
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
        $subtree = [];
        $tags = [];
        foreach ($data['subtree'] as $index => $value){
            if (strpos($value, '-') !== false){
                list($nodeId, $tagId) = explode('-', $value);
                $data['subtree'][] = intval($nodeId) . '-' . intval($tagId);
                $subtree[] = (int)$nodeId;
                $tags[] = (int)$tagId;
            }else{
                $data['subtree'][] = (int)$value;
                $subtree[] = (int)$value;
            }
        }
        $data['topic'] = array_map('intval', $data['topic']);
        if ($data['from']) {
            $data['from'] = $this->parseDate($data['from']);
        }
        if ($data['to']) {
            $data['to'] = $this->parseDate($data['to']);
        }

        $searchHash = array();
        if (!in_array($data['sort'], ['published', 'score', 'class_name', 'name'])){
            $data['sort'] = false;
        }
        if (!$data['sort']){
            $data['sort'] = empty($data['text']) ? 'published' : 'score';
        }
        if (!in_array($data['order'], ['asc', 'desc'])){
            $data['order'] = 'desc';
        }
        $searchHash['sort_by'] = array($data['sort'] => $data['order']);
        if ($data['sort'] == 'score' && $data['order'] == 'desc'){
            $searchHash['sort_by']['published'] = 'desc';
        }
        if (!empty($data['text'])) {
            $searchHash['query'] = $data['text'];
        }

        if (!empty($subtree)) {
            $searchHash['subtree_array'] = array_unique($subtree);
        } elseif ($data['subtree_boundary']) {
            $searchHash['subtree_array'] = array($data['subtree_boundary']);
        }

        $filters = array();
        if (!empty($tags)){
            $filters[] = 'ezf_df_tag_ids:(' . implode(' OR ', $tags) . ')';
        }
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

//        eZDebug::writeDebug(print_r($data, 1), __METHOD__);

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
            $separator = (strpos($string, '/') === false) ? '.' : '/';
            $parts = explode($separator, $string);
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
        for ($i = 1; $i <= 100; $i++) {
            $filename = str_replace('('.$i.')', '', $filename);
        }
        $filename = trim($filename);

        return ucfirst($filename);
    }

    /**
     * @return BootstrapItaliaTheme
     */
    public static function getCurrentTheme()
    {
        $theme = OpenPAINI::variable('GeneralSettings', 'theme', 'default');
        return BootstrapItaliaTheme::fromString($theme);
    }

    private function recursiveMenuTreeContains($item, $idList)
    {
        $contains = false;
        foreach ($item['children'] as $child){
            if (in_array($child['item']['node_id'], $idList) && !$contains){
                $contains = true;
            }
            if ($child['has_children'] && !$contains){
                $contains = $this->recursiveMenuTreeContains($child, $idList);
            }
        }

        return $contains;
    }

    private function isModuleUrl($url)
    {
        // Grab the first URL element, representing the possible module name
        $urlElements = explode('/', $url);
        $moduleName = $urlElements[0];

        // Look up for a match in the module list
        $moduleIni = eZINI::instance('module.ini');
        $availableModules = $moduleIni->variable('ModuleSettings', 'ModuleList');
        return in_array($moduleName, $availableModules, true);
    }

    private function isCurrentLocaleAvailable($siteLanguageList)
    {
        return in_array(
            eZINI::instance()->variable('RegionalSettings', 'ContentObjectLocale'),
            $siteLanguageList,
            true
        );
    }

    public static function translateValuation($string)
    {
        $string = trim($string);
        return ezpI18n::tr('bootstrapitalia/valuation', $string);
    }

    public static function filterOembedHtml($html, $url, $data)
    {
        if (OpenPAINI::variable('CookiesSettings', 'Consent', 'advanced') === 'advanced'){
            $encodeUrl = base64_encode($url);
            $html = str_replace('src=', 'preview_placeholder data-coookieconsent="multimedia" data-src=', $html);
            $html = str_replace('preview_placeholder', "data-preview=\"/ocembed/preview/?u={$encodeUrl}\" src=\"/ocembed/preview/?u={$encodeUrl}\"", $html);
        }

        return $html;
    }

    private static function getCookieConsentConfigTranslations()
    {
        $modalMainTextMoreLink = false;
        $learnMore = ezpI18n::tr('bootstrapitalia/cookieconsent', 'Cookie policy');
        $barMainText = ezpI18n::tr('bootstrapitalia/cookieconsent', 'This website uses cookies to ensure you get the best experience on our website.');
        $barBtnAcceptAll = ezpI18n::tr('bootstrapitalia/cookieconsent', 'Accept all cookies');
        try{
            $homepage = OpenPaFunctionCollection::fetchHome();
            if ($homepage) {
                $dataMap = $homepage->dataMap();
                if (isset($dataMap['cookie_alert_info_button_link']) && $dataMap['cookie_alert_info_button_link']->hasContent()){
                    $modalMainTextMoreLink = $dataMap['cookie_alert_info_button_link']->toString();
                } elseif (isset($dataMap['cookie_policy']) && $dataMap['cookie_policy']->hasContent()) {
                    $modalMainTextMoreLink = '/openpa/cookie';
                }
                if (isset($dataMap['cookie_alert_info_button_text']) && $dataMap['cookie_alert_info_button_text']->hasContent()){
                    $learnMore = $dataMap['cookie_alert_info_button_text']->toString();
                }
                if (isset($dataMap['cookie_alert_text']) && $dataMap['cookie_alert_text']->hasContent()){
                    $barMainText = $dataMap['cookie_alert_text']->toString();
                }
                if (isset($dataMap['cookie_alert_accept_button_text']) && $dataMap['cookie_alert_accept_button_text']->hasContent()){
                    $barMainText = $dataMap['cookie_alert_accept_button_text']->toString();
                }
            }
        }catch (RuntimeException $e){
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }

        return [
            'modalMainTextMoreLink' => $modalMainTextMoreLink,
            'learnMore' => $learnMore,
            'barMainText' => $barMainText,
            'barBtnAcceptAll' => $barBtnAcceptAll,
            'barBtnRefuseAll' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'Refuse all cookies'),
            'modalMainText' => ezpI18n::tr('bootstrapitalia/cookieconsent', "Cookies are small piece of data sent from a website and stored on the user's computer by the user's web browser while the user is browsing. Your browser stores each message in a small file, called cookie. When you request another page from the server, your browser sends the cookie back to the server. Cookies were designed to be a reliable mechanism for websites to remember information or to record the user's browsing activity."),
            'modalMainTitle' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'Cookie information and preferences'),
            'barLinkSetting' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'Cookie settings'),
            'modalBtnAcceptAll' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'Accept all cookies and close'),
            'modalBtnRefuseAll' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'Refuse all cookies and close'),
            'modalBtnSave' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'Save current settings'),
            'modalAffectedSolutions' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'Affected solutions:'),
            'on' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'On'),
            'off' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'Off'),
            'necessary' => [
                'name' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'Strictly Necessary Cookies'),
                'description' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'They are necessary for the proper functioning of the site. They allow the browsing of the pages, the storage of a user\'s sessions (to keep them active while browsing). Without these cookies, the services for which users access the site could not be provided.'),
            ],
            'analytics' => [
                'name' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'Cookie analytics'),
                'description' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'The analytics cookies are used to collect information on the number of users and how they visit the website and then process general statistics on the service and its use. The data is collected anonymously.'),
            ],
            'multimedia' => [
                'name' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'Automatic embedding of multimedia contents'),
                'description' => ezpI18n::tr('bootstrapitalia/cookieconsent', 'This system uses the oEmbed specification to automatically embed multimedia content into pages. Each content provider (for example YouTube or Vimeo) may release technical, analytical and profiling cookies based on the settings configured by the video maker. If this setting is disabled, the multimedia contents will not be automatically incorporated into the site and instead a link will be displayed to be able to view them directly at the source.'),
            ],
        ];
    }
}
