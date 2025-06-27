<?php

class HomepageLockEditClassConnector extends LockEditClassConnector
{
    const MAIN_NEWS = '564803b7ce97a9f99e42d0d2ef086164';

    const SECTION_LATEST_NEWS = 'e60d1373e30187166ab36ff0f088d87f';

    const SECTION_NEWS = 'e60d1373e30187166ab36ff0f088d87f';

    const SECTION_MANAGEMENT = '3213d4722665b8ca7155847fb767eb62';

    const SECTION_NEXT_EVENTS = '9cd237a12fdb73a490fee0b01a3fab9d';

    const SECTION_CALENDAR = '9cd237a12fdb73a490fee0b01a3fab9d';

    const SECTION_TOPIC = 'a419663d8c23c8e9239dc6813b845538';

    const SECTION_GALLERY = 'section-gallery';

    const SECTION_PLACE = 'section-place';

    const SECTION_BANNER = 'd406949b1e96173e51f6a5492c699daf';

    const BACKGROUND_IMAGE = 'background-image';

    const SEARCH = '2813cdb2a2aa1271e299b1905160c1b4';

    private $menuTopics = [];

    private $editLockSettings = [];

    public static function getContentClass(): eZContentClass
    {
        return eZContentClass::fetchByIdentifier('edit_homepage');
    }

    public function getData()
    {
        $this->currentBlocks = $this->content['page']['content']['global']['blocks'];

        return [
            'main_news' => $this->mapSingoloToRelation(self::MAIN_NEWS),
            'title_news' => $this->findBlockById(self::SECTION_NEWS)['name'],
            'section_latest_news' => $hasLatestNews = $this->mapListaAutomaticaToBoolean(self::SECTION_LATEST_NEWS),
            'section_news' => $hasNews = $this->mapListaManualeToRelations(self::SECTION_NEWS),
            'section_management' => $this->mapListaManualeToRelations(self::SECTION_MANAGEMENT),
            'title_events' => $this->findBlockById(self::SECTION_NEXT_EVENTS)['name'],
            'section_next_events' => $hasNextEvents = $this->mapEventiToBoolean(self::SECTION_NEXT_EVENTS),
            'section_calendar' => $hasEvents = $this->mapListaManualeToRelations(self::SECTION_CALENDAR),
            'section_topic' => $this->mapArgomentiToRelations(self::SECTION_TOPIC),
            'menu_topic' => $this->mapMenuArgomentiToRelations(),
            'background_topic' => $this->mapCustomAttributeImageToRelation(self::SECTION_TOPIC),
            'section_gallery' => $this->mapListaManualeToRelations(self::SECTION_GALLERY),
            'section_place' => $this->mapListaManualeToRelations(self::SECTION_PLACE),
            'title_banner' => $this->findBlockById(self::SECTION_BANNER)['name'],
            'section_banner' => $hasBanner = $this->mapListaManualeToRelations(self::SECTION_BANNER),
            'background_search' => $hasSearchBg = $this->mapCustomAttributeImageToRelation(self::SEARCH),
            'section_search' => $hasLinks = $this->mapRicercaToRelations(self::SEARCH),
            'background_image' => $this->mapSingoloToRelation(self::BACKGROUND_IMAGE),
            'add_section_news' => $hasLatestNews || $hasNews,
            'add_section_events' => $hasNextEvents || $hasEvents,
            'add_section_banner' => is_array($hasBanner),
            'add_section_search' => is_array($hasLinks) || is_array($hasSearchBg),
            'logo_search' => $this->mapCustomAttributeImageToRelation(self::SEARCH, 'logo'),
        ];
    }

    protected function mapSubmitData($data): array
    {
        $this->currentBlocks = $this->content['page']['content']['global']['blocks'];
        $blocks = $this->mapSubmittedFormToBlocks($this->getSubmitData());

        $page = $this->content['page']['content'];
        $page['global']['blocks'] = $blocks;

        return [
            'page' => $page,
            'topics' => $this->menuTopics,
            'topic_menu_label' => ezpI18n::tr('bootstrapitalia', 'All topics...')
        ];
    }

    protected function mapMenuArgomentiToRelations()
    {
        $data = [];
        $home = OpenPaFunctionCollection::fetchHome();
        if ($home instanceof eZContentObjectTreeNode) {
            $homeDataMap = $home->dataMap();
            if (isset($homeDataMap['topics']) && $homeDataMap['topics']->hasContent()){
                $content = $homeDataMap['topics']->content();
                foreach ($content['relation_list'] as $item){
                    $object = eZContentObject::fetch((int)$item['contentobject_id']);
                    if ($object instanceof eZContentObject){
                        $data[] = [
                            'id' => $object->attribute('id'),
                            'name' => $object->attribute('name'),
                            'class' => $object->contentClassIdentifier(),
                        ];
                    }
                }
            }
        }
        return $data;
    }

    public function getSchema()
    {
        $schema = parent::getSchema();
        $properties = [];
        foreach ($schema['properties'] as $identifier => $property) {
            $properties[$identifier] = $property;
            if ($identifier === 'main_news') {
                $properties['add_section_news'] = [
                    'type' => 'boolean',
                    'required' => false,
                ];
                $properties['add_section_events'] = [
                    'type' => 'boolean',
                    'required' => false,
                ];
                $properties['add_section_banner'] = [
                    'type' => 'boolean',
                    'required' => false,
                ];
                $properties['add_section_search'] = [
                    'type' => 'boolean',
                    'required' => false,
                ];
            }
        }
        $schema['properties'] = $properties;

        $schema['dependencies'] = [
            'section_news' => ['section_latest_news', 'add_section_news'],
            'section_latest_news' => ['add_section_news'],
            'title_news' => ['add_section_news'],

            'section_calendar' => ['section_next_events', 'add_section_events'],
            'section_next_events' => ['add_section_events'],
            'title_events' => ['add_section_events'],

            'section_banner' => ['add_section_banner'],
            'title_banner' => ['add_section_banner'],

            'section_search' => ['add_section_search'],
            'background_search' => ['add_section_search'],
        ];

        if ($this->isSearchBlockBoosted()){
            $schema['properties']['logo_search'] = $schema['properties']['background_search'];
            $schema['properties']['logo_search']['title'] = 'Banner in evidenza';
            $schema['dependencies']['logo_search'] = ['add_section_search'];
        }

        unset($schema['properties']['section_latest_news']['title']);
        unset($schema['properties']['section_next_events']['title']);

        $schema['properties']['section_news']['maxItems'] = OpenPAINI::variable('LockEdit_homepage', 'SectionNewsLimit', 3);
        $schema['properties']['section_management']['maxItems'] = OpenPAINI::variable('LockEdit_homepage', 'SectionManagementLimit', 3);
        $schema['properties']['section_calendar']['maxItems'] = OpenPAINI::variable('LockEdit_homepage', 'SectionCalendarLimit', 3);
        $schema['properties']['section_gallery']['maxItems'] = 3;
        $schema['properties']['section_place']['maxItems'] = 3;
        $schema['properties']['section_banner']['maxItems'] = OpenPAINI::variable('LockEdit_homepage', 'SectionBannerLimit', 9);
        $schema['properties']['section_search']['maxItems'] = $this->isSearchBlockBoosted() ? 15 : 5;
        $schema['properties']['section_topic']['minItems'] = 3;

        $schema['properties']['menu_topic']['maxItems'] = 3;

        return $schema;
    }

    public function getOptions()
    {
        $options = parent::getOptions();

        $options['fields']['add_section_news'] = [
            'type' => 'checkbox',
            'rightLabel' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Activate the "News in evidence" section'),
            'helper' => ezpI18n::tr('bootstrapitalia/editor-gui', 'The homepage of the site can have a section of 3 news in evidence'),
        ];
        $options['fields']['section_news']['dependencies'] = [
            'section_latest_news' => 'false',
            'add_section_news' => 'true',
        ];
        $options['fields']['section_latest_news']['dependencies'] = ['add_section_news' => 'true'];
        $options['fields']['title_news']['dependencies'] = ['add_section_news' => 'true'];

        $options['fields']['add_section_events'] = [
            'type' => 'checkbox',
            'rightLabel' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Activate the "Events in evidence" section'),
            'helper' => ezpI18n::tr(
                'bootstrapitalia/editor-gui',
                'The site homepage can have a section of events in evidence'
            ),
        ];
        $options['fields']['section_calendar']['dependencies'] = [
            'section_next_events' => 'false',
            'add_section_events' => 'true',
        ];
        $options['fields']['section_next_events']['dependencies'] = ['add_section_events' => 'true'];
        $options['fields']['title_events']['dependencies'] = ['add_section_events' => 'true'];

        $options['fields']['add_section_banner'] = [
            'type' => 'checkbox',
            'rightLabel' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Activate the "Thematic sites" section'),
            'helper' => ezpI18n::tr(
                'bootstrapitalia/editor-gui',
                'The site homepage can have a section with links to thematic sites'
            ),
        ];
        $options['fields']['section_banner']['dependencies'] = ['add_section_banner' => 'true'];
        $options['fields']['title_banner']['dependencies'] = ['add_section_banner' => 'true'];

        $options['fields']['add_section_search'] = [
            'type' => 'checkbox',
            'rightLabel' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Activate the "Search" section'),
            'helper' => '',
        ];
        $options['fields']['section_search']['dependencies'] = ['add_section_search' => 'true'];
        $options['fields']['background_search']['dependencies'] = ['add_section_search' => 'true'];

        $options['fields']['section_news']['browse']['subtree'] = $news = $this->fetchMainNodeIDByObjectRemoteID(
            'news'
        );
        $options['fields']['main_news']['actionbar'] = [
            'showLabels' => true,
            'actions' => [
                ['action' => 'add', 'enabled' => false],
                ['action' => 'up', 'enabled' => false],
                ['action' => 'down', 'enabled' => false],
            ],
        ];
        $options['fields']['main_news']['browse']['subtree'] = $news;
        $options['fields']['section_calendar']['browse']['subtree'] = $allEvents = $this->fetchMainNodeIDByObjectRemoteID(
            'all-events'
        );
        $options['fields']['section_management']['browse']['subtree'] = $this->fetchMainNodeIDByObjectRemoteID(
            'management'
        );
        $options['fields']['section_gallery']['browse']['subtree'] = $allEvents;
        $options['fields']['section_place']['browse']['subtree'] = $this->fetchMainNodeIDByObjectRemoteID('all-places');
        $options['fields']['section_banner']['browse']['subtree'] = $this->fetchMainNodeIDByObjectRemoteID('banners');
        $options['fields']['section_topic']['browse']['subtree'] = $topicNodeId = $this->fetchMainNodeIDByObjectRemoteID('topics');
        $options['fields']['menu_topic']['browse']['subtree'] = $topicNodeId;

        $options['fields']['background_image']['browse']['subtree'] = $media = 51;
        $options['fields']['background_image']['browse']['openInSearchMode'] = true;
        $options['fields']['background_image']['actionbar'] = $actionbar = [
            'showLabels' => true,
            'actions' => [
                ['action' => 'add', 'enabled' => false],
                ['action' => 'up', 'enabled' => false],
                ['action' => 'down', 'enabled' => false],
            ],
        ];

        $options['fields']['background_search']['browse']['subtree'] = $media;
        $options['fields']['background_search']['actionbar'] = $actionbar;
        if ($this->isSearchBlockBoosted()){
            $options['fields']['logo_search']['browse']['subtree'] = $media;
            $options['fields']['logo_search']['actionbar'] = $actionbar;
        }

        $options['fields']['background_topic']['browse']['subtree'] = $media;
        $options['fields']['background_topic']['actionbar'] = $actionbar;

        $options['fields']['section_search']['browse']['subtree'] = 2;
        if ($this->isSearchBlockBoosted()) {
            $options['fields']['logo_search'] = $options['fields']['background_search'];
            $options['fields']['logo_search']['browse']['subtree'] = eZContentObject::fetchByRemoteID('banners')->MainNodeID ?? 1;
            $options['fields']['logo_search']['browse']['classes'] = ['banner'];
            $options['fields']['section_search']['helper'] = str_replace(
                '5',
                '15',
                $options['fields']['section_search']['helper']
            );
            $options['fields']['logo_search']['dependencies'] = ['add_section_search' => 'true'];
        }

        return $options;
    }

    protected function getLayout(): array
    {
        $searchCategory = [
            'identifier' => 'search',
            'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Research'),
            'identifiers' => ['add_section_search', 'background_search', 'section_search'],
        ];
        if ($this->isSearchBlockBoosted()){
            $searchCategory['identifiers'][] = 'logo_search';
        }
        $categories = [];
        if ($this->isSearchBlockBoosted()){
            $categories[] = $searchCategory;
        }
        $categories = array_merge($categories, [
            [
                'identifier' => 'main_news',
                'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'In evidence'),
                'identifiers' => ['main_news'],
            ],
            [
                'identifier' => 'management',
                'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Administration'),
                'identifiers' => ['section_management'],
            ],
            [
                'identifier' => 'news',
                'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'News'),
                'identifiers' => ['add_section_news', 'title_news', 'section_latest_news', 'section_news',],
            ],
            [
                'identifier' => 'events',
                'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Events'),
                'identifiers' => ['add_section_events', 'title_events', 'section_next_events', 'section_calendar',],
            ],
            [
                'identifier' => 'topic',
                'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Topics'),
                'identifiers' => ['section_topic', 'background_topic', 'menu_topic'],
            ],
            [
                'identifier' => 'other',
                'name' => $this->fetchObjectNameByObjectRemoteID('all-places'),
                'identifiers' => ['section_place',],
            ],
            [
                'identifier' => 'banner',
                'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Thematic sites'),
                'identifiers' => ['add_section_banner', 'title_banner', 'section_banner'],
            ],
        ]);
        if (!$this->isSearchBlockBoosted()){
            $categories[] = $searchCategory;
        }

        if ($this->canAttachBackgroundImage()) {
            $categories[] = [
                'identifier' => 'flowers',
                'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Other settings'),
                'identifiers' => ['background_image'],
            ];
        }

        $bindings = [];
        $tabs = '<div class="col-3"><ul class="nav nav-tabs nav-tabs-vertical" role="tablist" aria-orientation="vertical">';
//        $tabs .= '<li class="ps-0 pt-4 pb-2 text-uppercase"><span>' . ezpI18n::tr('bootstrapitalia', 'Table of contents') . '</span></li>';
        $panels = '<div class="col-9 tab-content">';
        $i = 0;

        foreach ($categories as $category) {
            $activeClass = $i == 0 ? 'active' : '';
            $tabs .= '<li class="nav-item"><a class="nav-link ps-0 ' . $activeClass . '" data-toggle="tab" data-bs-toggle="tab" href="#' . $category['identifier'] . '" data-focus-mouse="false">' . $category['name'] . '</a></li>';
            $panels .= '<div class="lockedit-tab position-relative clearfix attribute-edit tab-pane p-2 mt-2 ' . $activeClass . '" id="' . $category['identifier'] . '"></div>';
            foreach ($category['identifiers'] as $field) {
                $bindings[$field] = $category['identifier'];
            }
            $i++;
        }
        $tabs .= '</ul></div>';
        $panels .= '</div>';

        return [
            'template' => '<div class="container px-4 my-4"><legend class="alpaca-container-label">{{options.label}}</legend><small>{{schema.description}}</small><div class="row mt-4 mb-5">' . $tabs . $panels . '</div></div>',
            'bindings' => $bindings,
        ];
    }

    protected function mapSubmittedFormToBlocks($data): array
    {
        $blocks = [];

        $searchBlock = $this->mapSectionSearch($data);
        if ($this->isSearchBlockBoosted() && $searchBlock) {
            $blocks[] = $searchBlock;
        }

        if ($this->canAttachBackgroundImage()) {
            if ($block = $this->mapBackgroundImage($data)) {
                $blocks[] = $block;
            }
        }

        $hasMainNews = false;
        if ($block = $this->mapMainNews($data)) {
            if ($this->isSearchBlockBoosted() && !empty($searchBlock['custom_attributes']['image'])) {
                $styles = eZINI::instance('openpa.ini')->variableArray('Stili', 'Nodo_NomeStile');
                $style = $styles[1][1] ?? '';
                $block['custom_attributes']['color_style'] = $style;
            }
            $blocks[] = $block;
            $hasMainNews = true;
        }

        if ($block = $this->mapSectionManagement($data, $hasMainNews)) {
            $blocks[] = $block;
        }

        if ($block = $this->mapSectionNews($data)) {
            $blocks[] = $block;
        }

        if ($block = $this->mapSectionEvents($data)) {
            $blocks[] = $block;
        }

        if ($block = $this->mapSectionTopics($data)) {
//            $this->menuTopics = array_slice($block['valid_items'], 0, 3);
            $blocks[] = $block;
        }

        $this->menuTopics = [];
        if (isset($data['menu_topic'][0]['id'])) {
            $this->menuTopics = array_column($data['menu_topic'], 'id');
        }

        if ($block = $this->mapSectionPlaces($data)) {
            $blocks[] = $block;
        }

//        if ($block = $this->mapSectionGallery($data)){
//            $blocks[] = $block;
//        }
//
//        if ($block = $this->mapSectionPlace($data)){
//            $blocks[] = $block;
//        }

        if ($block = $this->mapSectionBanner($data)) {
            $blocks[] = $block;
        }

        if (!$this->isSearchBlockBoosted() && $searchBlock) {
            $blocks[] = $searchBlock;
        }

        return $blocks;
    }

    protected function fetchSourcePathInfo(): array
    {
        return [
            'path' => $this->installerDataDir . '/contents/OpenCity.yml',
            'identifier' => 'page',
        ];
    }

    protected function cleanSourceBlocks($blocks): ?array
    {
        $dummyReplaces = [
            '$contenttree_OpenCity_Novita_node' => 'news',
            '$img-digitale' => 'img-digitale',
            '$img-viale-alberato' => 'img-viale-alberato',
            'node_id_from_remote_id(banners)' => 'banners',
        ];

        foreach ((array)$blocks as $index => $block) {
            if (isset($block['custom_attributes'])) {
                foreach ($block['custom_attributes'] as $key => $value) {
                    if (isset($dummyReplaces[$value])) {
                        $object = eZContentObject::fetchByRemoteID($dummyReplaces[$value]);
                        if ($object instanceof eZContentObject) {
                            $blocks[$index]['custom_attributes'][$key] = $object->mainNodeID();
                        }
                    }
                }
            }
        }

        return $blocks;
    }

    private function mapBackgroundImage($data): ?array
    {
        if (isset($data['background_image'][0]['id'])) {
            $image = eZContentObject::fetch((int)$data['background_image'][0]['id']);
            if ($image instanceof eZContentObject) {
                $block = $this->findBlockById(self::BACKGROUND_IMAGE);
                if (!$block) {
                    $block = $this->findBlockById(self::MAIN_NEWS, true);
                    $block['view'] = 'image';
                    $block['block_id'] = self::BACKGROUND_IMAGE;
                }
                $block['valid_items'] = [$image->attribute('remote_id')];
                return $block;
            }
        }
        return null;
    }

    private function mapMainNews($data): ?array
    {
        $newsRemoteId = false;
        if (!isset($data['main_news'][0]['id'])) {
            if ($this->canRemoveMainNews()){
                return null;
            }
            /** @var eZContentObjectTreeNode[] $newsList */
            $newsList = eZContentObjectTreeNode::subTreeByNodeID([
                'ClassFilterType' => 'include',
                'ClassFilterArray' => ['article'],
                'Limit' => 1,
                'SortBy' => [['published', false]],
            ], 1);
            if (count($newsList) > 0) {
                $newsRemoteId = $newsList[0]->attribute('object')->attribute('remote_id');
            }
        } else {
            $news = eZContentObject::fetch((int)$data['main_news'][0]['id']);
            if ($news instanceof eZContentObject) {
                $newsRemoteId = $news->attribute('remote_id');
            }
        }
        $block = $this->findBlockById(self::MAIN_NEWS, true);
        if ($newsRemoteId) {
            $block['valid_items'] = [$newsRemoteId];
        }

        if (isset($data['background_image'][0]['id']) && $this->canAttachBackgroundImage()) {
            $block['custom_attributes']['container_style'] = 'overlay';
        }

        return $block;
    }

    private function mapSectionManagement($data, $hasMainNews): ?array
    {
        $originalBlockManagement = $this->findBlockById(self::SECTION_MANAGEMENT, true);
        if (isset($data['section_management'][0]['id'])) {
            $managementRemoteIdList = [];
            foreach ($data['section_management'] as $managementItem) {
                $management = eZContentObject::fetch((int)$managementItem['id']);
                if ($management instanceof eZContentObject) {
                    $managementRemoteIdList[] = $management->attribute('remote_id');
                }
            }
            $originalBlockManagement['valid_items'] = $managementRemoteIdList;
            if (!$hasMainNews){
                $originalBlockManagement['custom_attributes']['container_style'] = false;
            }
            return $originalBlockManagement;
        }

        return null;
    }

    private function mapSectionNews($data): ?array
    {
        $originalBlockNews = $this->findBlockById(self::SECTION_NEWS, true);
        $originalBlockNews['name'] = $data['title_news'] ?? '';

        if (isset($data['section_latest_news']) && $data['section_latest_news'] === 'true') {
            return $originalBlockNews;
        } elseif (isset($data['section_news'][0]['id'])) {
            $block = $this->findBlockById(self::SECTION_MANAGEMENT, true);
            $block['block_id'] = self::SECTION_NEWS;
            $block['name'] = $originalBlockNews['name'];
            $block['custom_attributes']['container_style'] = false;
            $newsRemoteIdList = [];
            foreach ($data['section_news'] as $newsItem) {
                $news = eZContentObject::fetch((int)$newsItem['id']);
                if ($news instanceof eZContentObject) {
                    $newsRemoteIdList[] = $news->attribute('remote_id');
                }
            }
            $block['valid_items'] = $newsRemoteIdList;
            return $block;
        }

        return null;
    }

    private function mapSectionEvents($data): ?array
    {
        $originalBlockEvent = $this->findBlockById(self::SECTION_NEXT_EVENTS, true);
        $originalBlockEvent['name'] = $data['title_events'] ?? '';
        if (isset($data['section_next_events']) && $data['section_next_events'] === 'true') {
            return $originalBlockEvent;
        } elseif (isset($data['section_calendar'][0]['id'])) {
            $block = $this->findBlockById(self::SECTION_MANAGEMENT, true);
            $block['block_id'] = self::SECTION_NEXT_EVENTS;
            $block['name'] = $originalBlockEvent['name'];
            $block['custom_attributes']['container_style'] = false;
            $eventRemoteIdList = [];
            foreach ($data['section_calendar'] as $eventItem) {
                $event = eZContentObject::fetch((int)$eventItem['id']);
                if ($event instanceof eZContentObject) {
                    $eventRemoteIdList[] = $event->attribute('remote_id');
                }
            }
            $block['valid_items'] = $eventRemoteIdList;
            return $block;
        }

        return null;
    }

    private function mapSectionTopics($data): ?array
    {
        $originalBlock = $this->findBlockById(self::SECTION_TOPIC, true);
        if (isset($data['section_topic'][0]['id'])) {
            $remoteIdList = [];
            foreach ($data['section_topic'] as $item) {
                $object = eZContentObject::fetch((int)$item['id']);
                if ($object instanceof eZContentObject) {
                    $remoteIdList[] = $object->attribute('remote_id');
                }
            }
            $originalBlock['valid_items'] = $remoteIdList;

            if (isset($data['background_topic'][0]['id'])) {
                $object = eZContentObject::fetch((int)$data['background_topic'][0]['id']);
                if ($object instanceof eZContentObject) {
                    $originalBlock['custom_attributes']['image'] = $object->mainNodeID();
                }
            } else {
                $originalBlock['custom_attributes']['image'] = '';
            }

            return $originalBlock;
        }

        return null;
    }

    private function mapSectionBanner($data): ?array
    {
        if (isset($data['section_banner'][0]['id'])) {
            $originalBlock = $this->findBlockById(self::SECTION_BANNER, true);
            $originalBlock['name'] = $data['title_banner'] ?? '';
            $originalBlock['type'] = 'ListaManuale';
            $originalCustomAttributes = $originalBlock['custom_attributes'];
            $originalBlock['custom_attributes'] = [
                'elementi_per_riga' => $originalCustomAttributes['elementi_per_riga'],
                'color_style' => $originalCustomAttributes['color_style'],
                'container_style' => $originalCustomAttributes['container_style'],
                'intro_text' => $originalCustomAttributes['intro_text'],
            ];
            $remoteIdList = [];
            foreach ($data['section_banner'] as $item) {
                $object = eZContentObject::fetch((int)$item['id']);
                if ($object instanceof eZContentObject) {
                    $remoteIdList[] = $object->attribute('remote_id');
                }
            }
            $originalBlock['valid_items'] = $remoteIdList;
            return $originalBlock;
        }

        return null;
    }

    private function mapSectionPlaces($data): ?array
    {
        if (isset($data['section_place'][0]['id'])) {
            $originalBlock = $this->findBlockById(self::SECTION_PLACE, true);
            $originalBlock['type'] = 'ListaManuale';
            $originalCustomAttributes = $originalBlock['custom_attributes'];
            $originalBlock['custom_attributes'] = [
                'elementi_per_riga' => $originalCustomAttributes['elementi_per_riga'],
                'color_style' => $originalCustomAttributes['color_style'],
                'container_style' => $originalCustomAttributes['container_style'],
                'intro_text' => $originalCustomAttributes['intro_text'],
            ];
            $remoteIdList = [];
            foreach ($data['section_place'] as $item) {
                $object = eZContentObject::fetch((int)$item['id']);
                if ($object instanceof eZContentObject) {
                    $remoteIdList[] = $object->attribute('remote_id');
                }
            }
            $originalBlock['valid_items'] = $remoteIdList;
            return $originalBlock;
        }

        return null;
    }

    private function mapSectionSearch($data): ?array
    {
        if (isset($data['section_search'][0]['id']) || isset($data['background_search'][0]['id'])) {
            $originalBlock = $this->findBlockById(self::SEARCH, true);
            if (isset($data['background_search'][0]['id'])) {
                $object = eZContentObject::fetch((int)$data['background_search'][0]['id']);
                if ($object instanceof eZContentObject) {
                    $originalBlock['custom_attributes']['image'] = $object->mainNodeID();
                }
            } else {
                $originalBlock['custom_attributes']['image'] = '';
            }
            if (isset($data['logo_search'][0]['id'])) {
                $object = eZContentObject::fetch((int)$data['logo_search'][0]['id']);
                if ($object instanceof eZContentObject) {
                    $originalBlock['custom_attributes']['logo'] = $object->mainNodeID();
                }
            } else {
                $originalBlock['custom_attributes']['logo'] = '';
            }

            $remoteIdList = [];
            if (isset($data['section_search'])) {
                foreach ($data['section_search'] as $item) {
                    $object = eZContentObject::fetch((int)$item['id']);
                    if ($object instanceof eZContentObject) {
                        $remoteIdList[] = $object->attribute('remote_id');
                    }
                }
            }
            $originalBlock['valid_items'] = $remoteIdList;

            if ($this->isSearchBlockBoosted()) {
                $originalBlock['custom_attributes']['show_links_as_buttons'] = true;
            }

            return $originalBlock;
        }

        return null;
    }

    private function getEditLockSettings(?string $key = null)
    {
        if (empty($this->editLockSettings)) {
            $this->editLockSettings = eZINI::instance('openpa.ini')->group('LockEdit_homepage');
        }

        if ($key) {
            return $this->editLockSettings[$key] ?? null;
        }

        return $this->editLockSettings;
    }

    private function canAttachBackgroundImage(): bool
    {
        return $this->getEditLockSettings('EnableBackgroundImage') !== 'disabled' && !$this->isSearchBlockBoosted();
    }

    private function canRemoveMainNews(): bool
    {
        return $this->getEditLockSettings('AllowRemoveMainNews') !== 'disabled';
    }

    private function isSearchBlockBoosted(): bool
    {
        return $this->getEditLockSettings('BoostSearchBlock') !== 'disabled';
    }
}