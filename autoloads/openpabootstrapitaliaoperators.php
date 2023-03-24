<?php

class OpenPABootstrapItaliaOperators
{
    private static $cssData;

    private static $satisfyEntrypoint;

    private static $imageUrlList = [];

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
            'parse_layout_blocks',
            'parse_attribute_groups',
            'tag_tree_has_contents',
            'edit_attribute_groups',
            'get_default_integer_value',
            'satisfy_main_entrypoint',
            'user_token_url',
            'user_profile_url',
            'user_api_base_url',
            'decode_banner_color',
            'preload_script',
            'node_image',
            'preload_image',
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
            'parse_layout_blocks' => array(
                'zones' => array('type' => 'array', 'required' => true),
            ),
            'parse_attribute_groups' => array(
                'object' => array('type' => 'array', 'required' => true),
                'show_all' => array('type' => 'boolean', 'required' => false, 'default' => false),
            ),
            'tag_tree_has_contents' => array(
                'tag' => array('type' => 'object', 'required' => true),
            ),
            'edit_attribute_groups' => array(
                'class' => array('type' => 'object', 'required' => true),
                'attributes' => array('type' => 'array', 'required' => true),
            ),
            'get_default_integer_value' => array(
                'attribute' => array('type' => 'object', 'required' => true),
            ),
            'decode_banner_color' => array(
                'content' => array('type' => 'object', 'required' => false, 'default' => false),
            ),
            'preload_script' => array(
                'script_tag' => array('type' => 'string', 'required' => true, 'default' => ''),
            ),
            'node_image' => array(
                'node' => array('type' => 'objecy', 'required' => true),
                'alias' => array('type' => 'string', 'required' => false, 'default' => 'reference'),
            ),
        );
    }

    public static function getBannerColorStaticSelection(): array
    {
        return [
            'Nessuno' => [
                'background_color_class' => '',
                'text_color_class' => ''
            ],
            'primary' => [
                'background_color_class' => 'bg-primary',
                'text_color_class' => 'text-white'
            ],
            'dark' => [
                'background_color_class' => 'card-bg-dark',
                'text_color_class' => 'text-white'
            ],
            'warning' => [
                'background_color_class' => 'card-bg-warning',
                'text_color_class' => 'text-white'
            ],
            'blue' => [
                'background_color_class' => 'card-bg-blue',
                'text_color_class' => 'text-white'
            ],
        ];
    }

    public static function decodeBannerColorSelection($selected): ?string
    {
        $staticSelection = self::getBannerColorStaticSelection();
        if (!empty($selected)){
            if (!isset($staticSelection[$selected])){
                if (strpos($selected, 'primary') !== false){
                    $selected = 'primary';
                }
                if (strpos($selected, 'neutral') !== false){
                    $selected = 'dark';
                }
                if (strpos($selected, 'complementary') !== false){
                    $selected = 'warning';
                }
                if (strpos($selected, 'analogue') !== false){
                    $selected = 'blue';
                }
            }
            if (isset($staticSelection[$selected])){
                return $selected;
            }
        }

        return null;
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

            case 'preload_image':
                if (!empty($operatorValue)) {
                    ezjscPackerTemplateFunctions::setPersistentArray('preload_images', $operatorValue, $tpl, true);
                }
                break;

            case 'node_image':
                $node = $namedParameters['node'];
                $operatorValue = false;
                if ($node instanceof eZContentObjectTreeNode){
                    if (isset(self::$imageUrlList[$node->attribute('contentobject_id')])){
                        $image = self::$imageUrlList[$node->attribute('contentobject_id')];
                    }else{
                        $image = self::getNodeMainImage($node);
                        self::$imageUrlList[$node->attribute('contentobject_id')] = $image;
                    }
                    if ($image instanceof eZImageAliasHandler){
                        $operatorValue = $image->attribute($namedParameters['alias'] ?? 'reference');
                    }else{
                        eZDebug::writeError('Image not found for node ' . $node->attribute('name'), 'node_image');
                    }
                }else{
                    eZDebug::writeError('Node not found', 'node_image');
                }
                break;

            case 'preload_script':
                $operatorValue = '';
                $tag = $namedParameters['script_tag'];
                if (trim($tag) !== ''){
                    $parts = explode(' ', $tag);
                    foreach ($parts as $part){
                        if (strpos($part, 'src=') !== false){
                            $src = trim(substr($part, 4));
                            $operatorValue = '<link rel="preload" as="script" href=' . $src . '/>';
                        }
                    }
                }
                break;

            case 'decode_banner_color':
                $content = $namedParameters['content'];
                $operatorValue = [
                    'background_color_class' => 'bg-primary',
                    'text_color_class' => 'text-white'
                ];

                if ($content instanceof eZContentObject || $content instanceof eZContentObjectTreeNode){
                    $selected = false;

                    $attributeidentifier = 'background_color';
                    /** @var eZContentObjectAttribute[] $dataMap */
                    $dataMap = $content->attribute('data_map');
                    if (isset($dataMap[$attributeidentifier]) && $dataMap[$attributeidentifier]->hasContent()){
                        foreach ($dataMap[$attributeidentifier]->classContent()['options'] as $option){
                            if (in_array($option['id'], (array)$dataMap[$attributeidentifier]->content())){
                                $selected = $option['name'];
                                break;
                            }
                        }
                        if ($selected = self::decodeBannerColorSelection($selected)){
                            $operatorValue = self::getBannerColorStaticSelection()[$selected];
                        }
                    }
                }else{
                    $operatorValue = self::getBannerColorStaticSelection();
                }
                break;

            case 'user_api_base_url':
                $operatorValue = false;
                if (OpenPAINI::variable('GeneralSettings', 'AutoDiscoverProfileLinks', 'disabled') === 'enabled') {
                    $operatorValue = StanzaDelCittadinoBridge::factory()->getApiBaseUri();
                }
                break;
            case 'user_profile_url':
                $operatorValue = false;
                if (OpenPAINI::variable('GeneralSettings', 'AutoDiscoverProfileLinks', 'disabled') === 'enabled') {
                    $operatorValue = StanzaDelCittadinoBridge::factory()->getProfileUri();
                }
                break;
            case 'user_token_url':
                $operatorValue = false;
                if (OpenPAINI::variable('GeneralSettings', 'AutoDiscoverProfileLinks', 'disabled') === 'enabled') {
                    $operatorValue = StanzaDelCittadinoBridge::factory()->getTokenUri();
                }
                break;

            case 'satisfy_main_entrypoint':
                $operatorValue = self::getSatisfyEntrypoint();
                break;

            case 'get_default_integer_value':
                $value = '';
                $attribute = $namedParameters['attribute'];
                if ($attribute instanceof eZContentObjectAttribute){
                    $value = (int)$attribute->attribute('data_int');
                    $defaultIntegerAsNull = OpenPAINI::variable('AttributeHandlers', 'DefaultIntegerIsNull');
                    if ($value === 0 && in_array(
                        $attribute->object()->attribute('class_identifier').'/'.$attribute->attribute('contentclass_attribute_identifier'),
                        $defaultIntegerAsNull
                    )){
                        $value = '';
                    }
                }
                $operatorValue = $value;
                break;


            case 'edit_attribute_groups':
                $operatorValue = self::getEditAttributesGroups($namedParameters['class'], $namedParameters['attributes']);
                break;

            case 'tag_tree_has_contents':
                $operatorValue = self::tagTreeHasContents($namedParameters['tag']);
                break;

            case 'parse_attribute_groups':
                $operatorValue = self::parseAttributeGroups($namedParameters['object'], $namedParameters['show_all']);
                break;

            case 'parse_layout_blocks':
                $operatorValue = self::parseBlocks($namedParameters['zones']);
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
                [$nodeId, $tagId] = explode('-', $value);
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

    private static function parseBlocks($zones)
    {
        $data = [];
        if (is_array($zones)){
            foreach ($zones as $zone){
                if (is_array($zone) && isset($zone['blocks'])){
                    $zoneObj = new eZPageZone();
                    foreach ($zone['blocks'] as $block){
                        $zoneObj->addBlock($block);
                    }
                    $zone = $zoneObj;
                }
                if ($zone instanceof eZPageZone && $zone->hasAttribute('blocks')) {
                    $blocks = $zone->attribute('blocks');
                    foreach ($blocks as $index => $block){
                        if ($item = self::parseBlock($block, $index, $blocks)) {
                            $data[] = $item;
                        }
                    }
                }
            }
        }
        if (count($data) > 0) {
            $first = array_shift($data);
            array_unshift($data, $first);
            $last = array_pop($data);
            $data[] = $last;
        }else{
            $first = $last = null;
        }
        return [
            'wrappers' => $data,
            'first' => $first,
            'last' => $last,
        ];
    }

    private static function parseBlock(eZPageBlock $block, $index, $blocks)
    {
        $nextIndex = $index + 1;
        $trans = eZCharTransform::instance();
        $ini = eZINI::instance('block.ini')->group($block->attribute('type'));
        $blockWrapper = false;
        $customAttributes = $block->hasAttribute('custom_attributes') ? $block->attribute('custom_attributes') : [];
        $validNodes = $block->attribute('valid_nodes');
        $blockView = $block->attribute('view');
        $hasContent = count($validNodes) > 0
            || count($customAttributes) > 0
            || ($ini['ManualAddingOfItems'] == 'disabled' && isset($ini['FetchClass']));

        if ($hasContent){
            $currentItemsPerRow = 3;
            if (isset($customAttributes['elementi_per_riga'])
                && (
                    (is_numeric($customAttributes['elementi_per_riga'])
                        && $customAttributes['elementi_per_riga'] > 0
                        && $customAttributes['elementi_per_riga'] <= 6)
                    || $customAttributes['elementi_per_riga'] == 'auto'
                )
            ) {
                $currentItemsPerRow = $customAttributes['elementi_per_riga'];
            }elseif (isset($ini['ItemsPerRow'][$blockView])){
                $currentItemsPerRow = $ini['ItemsPerRow'][$blockView];
            }

            $slug = 'section-' . $index;
            if (!empty($block->attribute('name'))){
                $slug = 'section-' . $trans->transformByGroup( $block->attribute('name'), 'identifier' );
            }elseif (isset($validNodes[0])){
                $slug = 'section-' . $trans->transformByGroup( $validNodes[0]->attribute('name'), 'identifier' );
            }

            $isWide = isset($ini['Wide']) && in_array($blockView, (array)$ini['Wide']);

            $containerStyle = $ini['ContainerStyle'][$blockView] ?? false;

            $layoutStyle = $customAttributes['container_style'] ?? false;

            $colorStyle = $customAttributes['color_style'] ?? false;
            $colorStyle = str_replace('section section-muted section-inset-shadow pb-5', 'section section-muted ', $colorStyle);
            $colorStyle = str_replace('bg-100', 'bg-grey-card', $colorStyle);

            $showNextLink = $customAttributes['show_next_link'] ?? false;

            $openpaBlock = OpenPAObjectHandler::instanceFromObject($block);
            $blockHasContent = !$openpaBlock->hasAttribute('has_content') || $openpaBlock->attribute('has_content');
            if ($blockHasContent) {
                $blockWrapper = [
                    'block' => $block,
                    'view' => $blockView,
                    'slug' => $slug,
                    'items_per_row' => $currentItemsPerRow,
                    'is_wide' => $isWide,
                    'container_style' => $containerStyle,
                    'layout_style' => $layoutStyle,
                    'color_style' => $colorStyle,
                    'has_bg' => $colorStyle || $block->attribute('type') == 'Singolo',
                    'show_next_link' => $showNextLink && isset($blocks[$nextIndex])
                ];
            }
        }
        return $blockWrapper;
    }

    private static function parseAttributeGroups($object, $showAll = false)
    {
        if (!$object instanceof eZContentObject){
            return [];
        }

        $items = [];
        $dataMap = $object->dataMap();
        $extraManager = OCClassExtraParametersManager::instance($object->contentClass());
        $attributeGroups = $extraManager->getHandler('attribute_group');
        $openpa = OpenPAObjectHandler::instanceFromObject($object);

        $tableView = $extraManager->getHandler('table_view');
        $hiddenList = $attributeGroups->attribute('hidden_list');
        if ($showAll){
            foreach ($dataMap as $identifier => $attribute){
                if ($openpa->hasAttribute($identifier)){
                    $items[] = [
                        'slug' => $identifier,
                        'title' => $openpa->attribute($identifier)->attribute('label'),
                        'label' => $openpa->attribute($identifier)->attribute('label'),
                        'attributes' => [$openpa->attribute($identifier)],
                        'is_grouped' => false,
                        'wrap' => false,
                        'evidence' => false,
                        'data_element' => false,
                    ];
                }
            }
        }elseif($attributeGroups->attribute('enabled')){
            foreach ($attributeGroups->attribute('group_list') as $slug => $name){
                if (count($attributeGroups->attribute($slug)) > 0){
                    $attributes = [];
                    $wrapped = true;
                    foreach ($attributeGroups->attribute($slug) as $identifier) {
                        if ($openpa->hasAttribute($identifier)){
                            $openpaAttribute = $openpa->attribute($identifier);
                            if (!$openpaAttribute->attribute('full')['exclude']
                                && ($openpaAttribute->attribute('has_content') || $openpaAttribute->attribute('full')['show_empty'])) {
                                if (
                                    // workaround per ezboolean
                                    (
                                        $openpaAttribute->hasAttribute('contentobject_attribute')
                                        && $openpaAttribute->attribute('contentobject_attribute')->attribute('data_type_string') == eZBooleanType::DATA_TYPE_STRING
                                        && $openpaAttribute->attribute('contentobject_attribute')->attribute('data_int') != '1'
                                    )
                                    ||
                                    // evita di duplicare l'immagine principale nella galleria
                                    (
                                        in_array($identifier, $tableView->attribute('main_image'))
                                        && !in_array($identifier, $tableView->attribute('show_link'))
                                        && $openpaAttribute->hasAttribute('contentobject_attribute')
                                        && $openpaAttribute->attribute('contentobject_attribute')->attribute('data_type_string') == eZObjectRelationListType::DATA_TYPE_STRING
                                        && count($openpaAttribute->attribute('contentobject_attribute')->attribute('content')['relation_list']) <= 1
                                    )
                                ){
                                    continue;
                                }

                                $attributes[] = $openpaAttribute;
                                if ($wrapped && (!$openpaAttribute->attribute('full')['show_link'] || $openpaAttribute->attribute('full')['show_label'])){
                                    $wrapped = false;
                                }
                            }
                        }
                    }
                    if (count($attributes)){
                        $items[] = [
                            'slug' => $slug,
                            'title' => $attributeGroups->attribute('current_translation')[$slug],
                            'label' => in_array($slug, $hiddenList) ? false : $attributeGroups->attribute('current_translation')[$slug],
                            'attributes' => $attributes,
                            'is_grouped' => true,
                            'wrap' => $wrapped && count($attributes) > 1,
                            'evidence' => in_array($slug, $attributeGroups->attribute('evidence_list')),
                            'data_element' => $attributeGroups->attribute('translations')[$slug]['ita-PA'] ?? false,
                        ];
                    }
                }
            }
        }else{
            foreach ($tableView->attribute('show') as $identifier){
                if ($openpa->hasAttribute($identifier)) {
                    $openpaAttribute = $openpa->attribute($identifier);
                    if (!$openpaAttribute->attribute('full')['exclude']
                        && ($openpaAttribute->attribute('has_content')
                            || $openpaAttribute->attribute('full')['show_empty']
                        )
                    ) {
                        $items[] = [
                            'slug' => $identifier,
                            'title' => $openpa->attribute($identifier)->attribute('label'),
                            'label' => $openpa->attribute($identifier)->attribute('label'),
                            'attributes' => [$openpaAttribute],
                            'is_grouped' => false,
                            'wrap' => false,
                            'evidence' => false,
                            'data_element' => false,
                        ];
                    }
                }
            }
        }

        return [
            'has_items' => count($items) > 0,
            'show_index' => count($items) > 1 && !$attributeGroups->attribute('hide_index'),
            'items' => $items,
        ];
    }

    private static function tagTreeHasContents($tag)
    {
        $count = 0;
        if ($tag instanceof eZTagsObject) {
            $tagId = (int)$tag->attribute('id');
            $path = $tag->attribute('path_string');

            $db = eZDB::instance();
            $query = "SELECT COUNT(DISTINCT o.id) AS count FROM eztags_attribute_link l
                                   INNER JOIN ezcontentobject o ON l.object_id = o.id
                                   AND l.objectattribute_version = o.current_version
                                   AND o.status = " . eZContentObject::STATUS_PUBLISHED . "
                                   WHERE l.keyword_id IN (SELECT id FROM eztags WHERE id = $tagId OR path_string LIKE '{$path}%')";
            $result = $db->arrayQuery($query);

            $count = (is_array($result) && !empty($result)) ? (int)$result[0]['count'] : 0;
//            eZDebug::writeDebug($count . ' ' . $query, __METHOD__);
        }

        return $count > 0;
    }

    /**
     * @param eZContentClass $contentClass
     * @param eZContentObjectAttribute[] $contentObjectAttributes
     * @return array
     * @throws Exception
     */
    private static function getEditAttributesGroups(eZContentClass $contentClass, $contentObjectAttributes)
    {
        $extraManager = OCClassExtraParametersManager::instance($contentClass);
        $attributeGroups = $extraManager->getHandler('attribute_group');
        $tableView = $extraManager->getHandler('table_view');
        $attributeCategories = eZINI::instance('content.ini')->variable(
            'ClassAttributeSettings',
            'CategoryList'
        );
        $attributeDefaultCategory = eZINI::instance('content.ini')->variable(
            'ClassAttributeSettings',
            'DefaultCategory'
        );
        if ($attributeGroups->attribute('enabled')) {
            $contentObjectAttributeMap = [];
            $hiddenObjectAttributeMap = [];
            $sortMapper = [];
            foreach ($contentObjectAttributes as $attribute) {
                $classAttribute = $attribute->contentClassAttribute();
                $attributeCategory = $classAttribute->attribute('category');
                $attributeIdentifier = $classAttribute->attribute('identifier');
                $sortMapper[$classAttribute->attribute('placement')] = $attributeIdentifier;
                if ($attributeCategory === 'hidden') {
                    $hiddenObjectAttributeMap[$attributeIdentifier] = $attribute;
                } else {
                    $contentObjectAttributeMap[$attributeIdentifier] = $attribute;
                }
            }

            $groups = [];
            $default = array_merge(
                [
                    'name',
                    'alternative_name',
                    'alt_name',
                    'type',
                    'identifier',
                    'content_type',
                    'status_note',
                    'has_public_event_typology',
                    'document_type',
                    'announcement_type'
                ],
                $tableView->attribute('in_overview'),
                $tableView->attribute('main_image')
            );
            $defaultObjectAttributeMap = [];
            foreach ($default as $identifier) {
                if (isset($contentObjectAttributeMap[$identifier])) {
                    $defaultObjectAttributeMap[$identifier] = $contentObjectAttributeMap[$identifier];
                    unset($contentObjectAttributeMap[$identifier]);
                }
            }

            if (!empty($defaultObjectAttributeMap)) {
                $groups[] = [
                    'label' => $attributeCategories[$attributeDefaultCategory],
                    'identifier' => '_default',
                    'show' => true,
                    'attributes' => self::sortAttributes($defaultObjectAttributeMap, $sortMapper),
                ];
            }

            foreach (array_keys($attributeGroups->attribute('sort_list')) as $group){
                $groupObjectAttributeMap = [];
                $groupIdentifierList = (array)$attributeGroups->attribute($group);
                foreach ($groupIdentifierList as $identifier) {
                    if (isset($contentObjectAttributeMap[$identifier])) {
                        $groupObjectAttributeMap[$identifier] = $contentObjectAttributeMap[$identifier];
                        unset($contentObjectAttributeMap[$identifier]);
                    }
                }
                if (!empty($groupObjectAttributeMap)) {
                    $groups[] = [
                        'label' => $attributeGroups->attribute('current_translation')[$group],
                        'identifier' => $group,
                        'show' => true,
                        'attributes' => self::sortAttributes($groupObjectAttributeMap, $sortMapper),
                    ];
                }
            }

            foreach ($contentObjectAttributeMap as $identifier => $attribute){
                if ($attribute->attribute('is_required')){
                    $groups[0]['attributes'][$identifier] = $attribute;
                    $groups[0]['attributes'] = self::sortAttributes($groups[0]['attributes'], $sortMapper);
                    unset($contentObjectAttributeMap[$identifier]);
                }
            }

            if (!empty($contentObjectAttributeMap)){
                $groups[] = [
                    'label' => ezpI18n::tr('bootstrapitalia', 'Further details'),
                    'identifier' => 'other',
                    'show' => true,
                    'attributes' => self::sortAttributes($contentObjectAttributeMap, $sortMapper),
                ];
            }

            $hasHidden = 0;
            if (!empty($hiddenObjectAttributeMap)) {
                $groups[] = [
                    'label' => '(Campi nascosti)',
                    'identifier' => 'hidden',
                    'show' => eZUser::currentUser()->hasAccessTo('*')['accessWord'] == 'yes',
                    'attributes' => self::sortAttributes($hiddenObjectAttributeMap, $sortMapper),
                ];
                $hasHidden = 1;
            }

            if (!empty($groups)) {
                $count = count($groups);
                return [
                    'count' => $count - $hasHidden,
                    'groups' => $groups,
                ];
            }
        }

        return self::getDefaultEditAttributesGroups($contentObjectAttributes);
    }

    private static function sortAttributes($contentObjectAttributes, $sortMapper)
    {

        $sortedList = [];
        foreach ($sortMapper as $priority => $identifier){
            if (isset($contentObjectAttributes[$identifier])){
                $sortedList[$identifier] = $contentObjectAttributes[$identifier];
            }
        }

        return $sortedList;
    }

    private static function getDefaultEditAttributesGroups($contentObjectAttributes)
    {
        $attributeCategories = eZINI::instance('content.ini')->variable(
            'ClassAttributeSettings',
            'CategoryList'
        );
        $attributeDefaultCategory = eZINI::instance('content.ini')->variable(
            'ClassAttributeSettings',
            'DefaultCategory'
        );
        $groups = [];
        $data = eZContentObject::createGroupedDataMap($contentObjectAttributes);
        $hasHidden = 0;
        foreach ($data as $identifier => $attributeList){
            $groups[] = [
                'label' => isset($attributeCategories[$identifier]) ? $attributeCategories[$identifier] : $attributeCategories[$attributeDefaultCategory],
                'identifier' => $identifier,
                'show' => $identifier !== 'hidden',
                'attributes' => $attributeList
            ];
            if ($identifier === 'hidden'){
                $hasHidden++;
            }
        }

        $count = count($groups);
        return [
            'count' => $count - $hasHidden,
            'groups' => $groups,
        ];
    }

    public static function getSatisfyEntrypoint()
    {
        if (self::$satisfyEntrypoint === null){
            self::$satisfyEntrypoint = false;
            $siteData = eZSiteData::fetchByName('satisfy_entrypoint');
            if ($siteData instanceof eZSiteData){
                self::$satisfyEntrypoint = $siteData->attribute('value');
            }
        }

        return self::$satisfyEntrypoint;
    }

    public static function setSatisfyEntrypoint($id)
    {
        $siteData = eZSiteData::fetchByName('satisfy_entrypoint');
        if (!$siteData instanceof eZSiteData){
            $siteData = eZSiteData::create('satisfy_entrypoint', '');
        }
        $siteData->setAttribute('value', $id);
        $siteData->store();
        eZCache::clearByTag('template');
        try {
            eZExtension::getHandlerClass(
                new ezpExtensionOptions([
                    'iniFile' => 'site.ini',
                    'iniSection' => 'ContentSettings',
                    'iniVariable' => 'StaticCacheHandler'
                ])
            )->generateCache(true, true);
        }catch (Exception $e){
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }
        self::$satisfyEntrypoint = $id;
    }

    public static function minifyHtml($templateResult)
    {
        $currentSa = eZSiteAccess::current();
        if (!$currentSa || strpos($currentSa['name'], '_frontend') === false){
            return $templateResult;
        }

        //remove redundant (white-space) characters
        $replace = array(
            //remove tabs before and after HTML tags
            '/\>[^\S ]+/s'   => '>',
            '/[^\S ]+\</s'   => '<',
            //shorten multiple whitespace sequences; keep new-line characters because they matter in JS!!!
            '/([\t ])+/s'  => ' ',
            //remove leading and trailing spaces
//            '/^([\t ])+/m' => '',
//            '/([\t ])+$/m' => '',
            // remove JS line comments (simple only); do NOT remove lines containing URL (e.g. 'src="http://server.com/"')!!!
//            '~//[a-zA-Z0-9 ]+$~m' => '',
            //remove empty lines (sequence of line-end and white-space characters)
            '/[\r\n]+([\t ]?[\r\n]+)+/s'  => "\n",
            //remove empty lines (between HTML tags); cannot remove just any line-end characters because in inline JS they can matter!
//            '/\>[\r\n\t ]+\</s'    => '><',
            //remove "empty" lines containing only JS's block end character; join with next line (e.g. "}\n}\n</script>" --> "}}</script>"
//            '/}[\r\n\t ]+/s'  => '}',
//            '/}[\r\n\t ]+,[\r\n\t ]+/s'  => '},',
            //remove new-line after JS's function or condition start; join with next line
//            '/\)[\r\n\t ]?{[\r\n\t ]+/s'  => '){',
//            '/,[\r\n\t ]?{[\r\n\t ]+/s'  => ',{',
            //remove new-line after JS's line end (only most obvious and safe cases)
//            '/\),[\r\n\t ]+/s'  => '),',
            //remove quotes from HTML attributes that does not contain spaces; keep quotes around URLs!
//            '~([\r\n\t ])?([a-zA-Z0-9]+)="([a-zA-Z0-9_/\\-]+)"([\r\n\t ])?~s' => '$1$2=$3$4', //$1 and $4 insert first white-space character found before/after attribute
        );
        return preg_replace(array_keys($replace), array_values($replace), $templateResult);
    }

    private static function generateScriptPreloadFilename($fileArray)
    {
        $cacheNames = eZSys::indexDir() . '/';
        while (!empty($fileArray)) {
            $file = array_shift($fileArray);

            // if $file is array, concat it to the file array and continue
            if ($file && is_array($file)) {
                $fileArray = array_merge($file, $fileArray);
                continue;
            } else {
                if (!$file) {
                    continue;
                } else { // if the file name contains :: it is threated as a custom code genarator
                    if (strpos($file, '::') !== false) {
                        $server = ezjscPacker::serverCallHelper(explode('::', $file));
                        if (!$server instanceof ezjscServerRouter) {
                            continue;
                        }
                        $cacheNames .= $file . '_';
                        continue;
                    } else { // is it a http / https url  ?
                        if (strpos($file, 'http://') === 0 || strpos($file, 'https://') === 0) {
                            $data['http'][] = $file;
                            continue;
                        } else {  // is it a http / https url where protocol is selected dynamically  ?
                            if (strpos($file, '://') === 0) {
                                if (!isset($protocol)) {
                                    $protocol = eZSys::serverProtocol();
                                }
                                continue;
                            } else { // is it a absolute path ?
                                if (strpos($file, 'var/') === 0) {
                                    if (substr($file, 0, 2) === '//' || preg_match("#^[a-zA-Z0-9]+:#", $file)) {
                                        $file = '/';
                                    } else {
                                        if (strlen($file) > 0 && $file[0] !== '/') {
                                            $file = '/' . $file;
                                        }
                                    }

                                    eZURI::transformURI($file, true, 'relative');
                                } else { // or is it a relative path
                                    // Allow path to be outside subpath if it starts with '/'
                                    if ($file[0] === '/') {
                                        $file = ltrim($file, '/');
                                    }
                                    $triedFiles = [];
                                    $match = eZTemplateDesignResource::fileMatch(eZTemplateDesignResource::allDesignBases(), '', $file, $triedFiles);
                                    if ($match === false) {
                                        eZDebug::writeWarning("Could not find: $file", __METHOD__);
                                        continue;
                                    }
                                    $file = htmlspecialchars($match['path']);
                                }
                            }
                        }
                    }
                }
            }
            $cacheNames .= $file . '_';
        }
        return $cacheNames;
    }

    private static function getNodeMainImage(eZContentObjectTreeNode $node)
    {
        try {
            $mainAttributes = OCClassExtraParametersManager::instance(
                eZContentClass::fetchByIdentifier($node->classIdentifier())
            )->getHandler('table_view')->attribute('main_image');
            $dataMap = $node->dataMap();
            foreach ($mainAttributes as $identifier) {
                if (isset($dataMap[$identifier]) && $dataMap[$identifier]->hasContent()) {
                    if ($dataMap[$identifier]->attribute('data_type_string') === eZImageType::DATA_TYPE_STRING) {
                        return $dataMap[$identifier]->content();
                    } elseif ($dataMap[$identifier]->attribute(
                            'data_type_string'
                        ) === eZObjectRelationListType::DATA_TYPE_STRING) {
                        $relations = $dataMap[$identifier]->content();
                        foreach ($relations['relation_list'] as $relation) {
                            $relatedNode = eZContentObjectTreeNode::fetch($relation['node_id']);
                            if ($relatedNode instanceof eZContentObjectTreeNode) {
                                return self::getNodeMainImage($relatedNode);
                            }
                        }
                    }
                }
            }
        }catch (Throwable $e){
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }

        return false;
    }
}
