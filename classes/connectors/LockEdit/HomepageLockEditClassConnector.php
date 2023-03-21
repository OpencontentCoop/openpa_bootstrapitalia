<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;
use Symfony\Component\Yaml\Yaml;

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

    public static function getContentClass(): eZContentClass
    {
        return eZContentClass::fetchByIdentifier('edit_homepage');
    }

    public function getData()
    {
        $this->currentBlocks = $this->content['page']['content']['global']['blocks'];
        return $this->mapOriginalContentToSimplifiedForm();
    }

    public function submit()
    {
        $this->currentBlocks = $this->content['page']['content']['global']['blocks'];
        $blocks = $this->mapSubmittedFormToBlocks($this->getSubmitData());

        $page = $this->content['page']['content'];
        $page['global']['blocks'] = $blocks;

        $contentRepository = new ContentRepository();
        $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));

        $payload = new PayloadBuilder();
        $payload->setId((int)$this->getHelper()->getParameter('object'));
        $payload->setData($this->helper->getSetting('language'), 'page', $page);
        $result = $contentRepository->update($payload->getArrayCopy(), true);
        $this->cleanup();
        $result['conversion'] = $blocks;

        return $result;
    }

    public function getSchema()
    {
        $schema = parent::getSchema();
        $schema['dependencies'] = [
            'section_news' => ['section_latest_news'],
            'section_calendar' => ['section_next_events'],
        ];

        unset($schema['properties']['section_latest_news']['title']);
        unset($schema['properties']['section_next_events']['title']);

        return $schema;
    }

    public function getOptions()
    {
        $options = parent::getOptions();

        $options['fields']['section_news']['dependencies'] = ['section_latest_news' => 'false'];
        $options['fields']['section_calendar']['dependencies'] = ['section_next_events' => 'false'];

        return $options;
    }

    protected function getLayout(): array
    {
        $categories = [
            [
                'identifier' => 'news',
                'name' => 'Notizie',
                'identifiers' => ['main_news', 'title_news', 'section_latest_news', 'section_news',],
            ],
            [
                'identifier' => 'management',
                'name' => 'Amministrazione',
                'identifiers' => ['section_management'],
            ],
            [
                'identifier' => 'events',
                'name' => 'Eventi',
                'identifiers' => ['title_events', 'section_next_events', 'section_calendar',],
            ],
            [
                'identifier' => 'topic',
                'name' => 'Argomenti',
                'identifiers' => ['section_topic', 'background_topic'],
            ],
            [
                'identifier' => 'other',
                'name' => 'Gallerie e luoghi',
                'identifiers' => ['section_gallery', 'section_place',],
            ],
            [
                'identifier' => 'banner',
                'name' => 'Siti tematici',
                'identifiers' => ['title_banner', 'section_banner'],
            ],
            [
                'identifier' => 'search',
                'name' => 'Ricerca',
                'identifiers' => ['background_search', 'section_search'],
            ],
            [
                'identifier' => 'flowers',
                'name' => 'Altre impostazioni',
                'identifiers' => ['background_image'],
            ],
        ];

        $bindings = [];
        $tabs = '<div class="col-3"><ul class="nav nav-tabs nav-tabs-vertical" role="tablist" aria-orientation="vertical"><li class="ps-0 pt-4 pb-2 text-uppercase"><span>' . ezpI18n::tr(
                'bootstrapitalia',
                'Table of contents'
            ) . '</span></li>';
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

    protected function mapOriginalContentToSimplifiedForm(): array
    {
        return [
            'main_news' => $this->mapSingoloToRelation(self::MAIN_NEWS),
            'title_news' => $this->findBlockById(self::SECTION_NEWS)['name'],
            'section_latest_news' => $this->mapListaAutomaticaToBoolean(self::SECTION_LATEST_NEWS),
            'section_news' => $this->mapListaManualeToRelations(self::SECTION_NEWS),
            'section_management' => $this->mapListaManualeToRelations(self::SECTION_MANAGEMENT),
            'title_events' => $this->findBlockById(self::SECTION_NEXT_EVENTS)['name'],
            'section_next_events' => $this->mapEventiToBoolean(self::SECTION_NEXT_EVENTS),
            'section_calendar' => $this->mapListaManualeToRelations(self::SECTION_CALENDAR),
            'section_topic' => $this->mapArgomentiToRelations(self::SECTION_TOPIC),
            'background_topic' => $this->mapCustomAttributeImageToRelation(self::SECTION_TOPIC),
            'section_gallery' => $this->mapListaManualeToRelations(self::SECTION_GALLERY),
            'section_place' => $this->mapListaManualeToRelations(self::SECTION_PLACE),
            'title_banner' => $this->findBlockById(self::SECTION_BANNER)['name'],
            'section_banner' => $this->mapListaManualeToRelations(self::SECTION_BANNER),
            'background_search' => $this->mapCustomAttributeImageToRelation(self::SEARCH),
            'section_search' => $this->mapRicercaToRelations(self::SEARCH),
            'background_image' => $this->mapSingoloToRelation(self::BACKGROUND_IMAGE),
        ];
    }

    protected function mapSubmittedFormToBlocks($data): array
    {
        $blocks = [];

        if ($block = $this->mapBackgroundImage($data)) {
            $blocks[] = $block;
        }

        if ($block = $this->mapMainNews($data)) {
            $blocks[] = $block;
        }

        if ($block = $this->mapSectionManagement($data)) {
            $blocks[] = $block;
        }

        if ($block = $this->mapSectionNews($data)) {
            $blocks[] = $block;
        }

        if ($block = $this->mapSectionEvents($data)) {
            $blocks[] = $block;
        }

        if ($block = $this->mapSectionTopics($data)) {
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

        if ($block = $this->mapSectionSearch($data)) {
            $blocks[] = $block;
        }

        return $blocks;
    }

    protected function fetchSourceBlocks(): array
    {
        $filePath = $this->installerDataDir . '/contents/OpenCity.yml';
        $data = file_get_contents($filePath);
        $sourceData = Yaml::parse($data);

        $dummyReplaces = [
            '$contenttree_OpenCity_Novita_node' => 'news',
            '$img-digitale' => 'img-digitale',
            '$img-viale-alberato' => 'img-viale-alberato',
            'node_id_from_remote_id(banners)' => 'banners',
        ];

        $blocks = isset($sourceData['data'][$this->helper->getSetting('language')]) ?
            $sourceData['data'][$this->helper->getSetting('language')]['page']['global']['blocks'] :
            $sourceData['data']['ita-IT']['page']['global']['blocks'];

        foreach ($blocks as $index => $block) {
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
            /** @var eZContentObjectTreeNode[] $newsList */
            $newsList = eZContentObjectTreeNode::subTreeByNodeID([
                'ClassFilterType' => 'include',
                'ClassFilterArray' => ['article'],
                'Limit' => 1,
                'SortBy' => ['published', 'desc'],
            ]);
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

        if (isset($data['background_image'][0]['id'])) {
            $block['custom_attributes']['container_style'] = 'overlay';
        }

        return $block;
    }

    private function mapSectionManagement($data): ?array
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
            $block = $this->findBlockById(self::SECTION_MANAGEMENT);
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
            $block = $this->findBlockById(self::SECTION_MANAGEMENT);
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
            return $originalBlock;
        }

        return null;
    }
}