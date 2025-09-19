<?php

abstract class PageLockEditClassConnector extends LockEditClassConnector
{
    private $timelineConnector = null;

    private function getTimelineConnector(): ?RelationsField
    {
        if (!in_array(
            $this->originalObject->remoteID(),
            OpenPAINI::variable('LockEdit_' . $this->originalObject->attribute('class_identifier'), 'EnableTimelineRemoteIds', [])
        )) {
            return null;
        }
        if ($this->timelineConnector === null) {
            $dataMap = $this->originalObject->dataMap();
            if (isset($dataMap['timeline_elements'])) {
                $this->timelineConnector = new RelationsField(
                    $dataMap['timeline_elements']->attribute('contentclass_attribute'),
                    $this->originalObject->attribute('content_class'),
                    $this->getHelper()
                );
                $this->getTimelineConnector()->setContent($this->content['timeline_elements'] ?? []);
            } else {
                $this->timelineConnector = false;
            }
        }
        return $this->timelineConnector;
    }

    public static function getContentClass(): eZContentClass
    {
        return eZContentClass::fetchByIdentifier('edit_page');
    }

    public function getData()
    {
        $this->currentBlocks = $this->content['layout']['content']['global']['blocks'] ?? [];

        $image = isset($this->content['image']['content'][0]) ? [
            [
                'id' => $this->content['image']['content'][0]['id'],
                'name' => $this->content['image']['content'][0]['name'][$this->getHelper()->getSetting('language')]
                    ?? current($this->content['image']['content'][0]['name']),
                'class' => $this->content['image']['content'][0]['classIdentifier'],
            ],
        ] : null;

        $data = [
            'abstract' => $this->content['abstract']['content'],
            'image' => $image,
            'section_evidence' => $this->mapEvidenceItemsToRelations(),
            'title_evidence' => $this->getEvidenceBlock()['name'],
        ];

        $sectionCount = $this->getEvidenceBlockSetupCount();
        if ($sectionCount > 1) {
            for ($i = 2; $i <= $sectionCount; $i++) {
                $data['section_evidence_' . $i] = $this->mapEvidenceItemsToRelations($i);
                $data['title_evidence_' . $i] = $this->getEvidenceBlock($i)['name'];
            }
        }

        if ($this->getTimelineConnector()) {
            $data['timeline_elements'] = $this->getTimelineConnector()->getData();
        }

        return $data;
    }

    public function getSchema()
    {
        $schema = parent::getSchema();

        $schema['properties']['section_evidence']['maxItems'] = $this->getEvidenceBlockMaxItems();

        $sectionCount = $this->getEvidenceBlockSetupCount();
        if ($sectionCount > 1) {
            for ($i = 2; $i <= $sectionCount; $i++) {
                $schema['properties']['section_evidence_' . $i]['maxItems'] = $this->getEvidenceBlockMaxItems($i);
            }
        }

        $schema = $this->filterSchemaByEvidenceBlock($schema);
        $sectionCount = $this->getEvidenceBlockSetupCount();
        if ($sectionCount > 1) {
            for ($i = 2; $i <= $sectionCount; $i++) {
                $schema = $this->filterSchemaByEvidenceBlock($schema, $i);
            }
        }

        if ($this->getTimelineConnector()) {
            $schema['properties']['timeline_elements'] = $this->getTimelineConnector()->getSchema();
        }

        return $schema;
    }

    public function getOptions()
    {
        $options = parent::getOptions();

        $options = $this->filterOptionsByEvidenceBlock($options);
        $sectionCount = $this->getEvidenceBlockSetupCount();
        if ($sectionCount > 1) {
            for ($i = 2; $i <= $sectionCount; $i++) {
                $options = $this->filterOptionsByEvidenceBlock($options, $i);
            }
        }
        $options['fields']['image']['browse']['openInSearchMode'] = true;

        if ($this->getTimelineConnector()) {
            $options['fields']['timeline_elements'] = $this->getTimelineConnector()->getOptions();
            $options['fields']['timeline_elements']['browse']['addCreateButton'] = true;
            $options['fields']['timeline_elements']['browse']['addEditButton'] = true;
        }

        return $options;
    }

    protected function filterOptionsByEvidenceBlock($options, $blockIndex = 1): array
    {
        if ($blockIndex > 1) {
            $options['fields']['title_evidence_' . $blockIndex]['helper'] = '';
            $options['fields']['section_evidence_' . $blockIndex]['browse']['subtree'] = '';
        } else {
            $options['fields']['title_evidence']['helper'] = '';
            $options['fields']['section_evidence']['browse']['subtree'] = (int)$this->originalObject->mainNodeID();
        }

        return $options;
    }

    protected function filterSchemaByEvidenceBlock($schema, $blockIndex = 1): array
    {
        return $schema;
    }

    protected function getEvidenceBlockSetupCount(): int
    {
        return 1;
    }

    protected function mapEvidenceItemsToRelations($blockIndex = 1)
    {
        $block = $this->getEvidenceBlock($blockIndex);
        if (isset($block['valid_items'][0]) && $block['type'] == 'ListaManuale') {
            $data = [];
            foreach ($block['valid_items'] as $objectId) {
                $object = eZContentObject::fetchByRemoteID($objectId);
                if ($object instanceof eZContentObject) {
                    $data[] = [
                        'id' => $object->attribute('id'),
                        'name' => $object->attribute('name'),
                        'class' => $object->contentClassIdentifier(),
                    ];
                }
            }

            return $data;
        }
        return null;
    }

    protected function getEvidenceBlockId($blockIndex = 1): string
    {
        $suffix = $blockIndex > 1 ? $blockIndex . '' : '';
        $locale = $this->getHelper()->getSetting('language');
        if ($locale === 'ita-IT') {
            $locale = '';
        }
        return substr('evd' . $suffix . $this->originalObject->attribute('id') . $locale, 0, 32);
    }

    protected function getEmptyEvidenceBlock($blockIndex = 1): array
    {
        return [
            'block_id' => $this->getEvidenceBlockId($blockIndex),
            'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'In evidence'),
            "type" => "ListaManuale",
            "view" => "lista_card",
            "custom_attributes" => [
                "elementi_per_riga" => "3",
                "color_style" => "bg-100",
                "container_style" => "",
                "intro_text" => "",
            ],
            "valid_items" => [],
        ];
    }

    protected function getEvidenceBlockMaxItems($blockIndex = 1): int
    {
        return 6;
    }

    protected function getEvidenceBlock($blockIndex = 1): array
    {
        return $this->findBlockById($this->getEvidenceBlockId($blockIndex))
            ?? $this->getEmptyEvidenceBlock($blockIndex);
    }

    protected function fetchSourcePathInfo(): array
    {
        return [];
    }

    protected function cleanSourceBlocks($blocks): ?array
    {
        return (array)$blocks;
    }

    protected function resetEvidenceBlock($block, $blockIndex = 1)
    {
        $block['valid_items'] = [];

        return $block;
    }

    protected function mapSubmitData($data): array
    {
        $this->currentBlocks = $this->content['layout']['content']['global']['blocks'] ?? [];

        $evidenceBlocks = $this->retrieveEvidenceBlocksFromSubmitData($data);

        $layout = $this->content['layout']['content'];

        if (empty($layout)) {
            $layout = [
                "zone_layout" => "desItaGlobal",
                "global" => [
                    "zone_id" => md5($this->originalObject->attribute('id')),
                    "blocks" => [],
                ],
            ];
        }

        $locale = $this->getHelper()->getSetting('language');
        $currentBlockIdList = array_column($layout['global']['blocks'], 'block_id');
        $sectionCount = $this->getEvidenceBlockSetupCount();
        $evidenceBlockIdList = [];
        for ($i = 1; $i <= $sectionCount; $i++) {
            $evidenceBlockIdList[] = $this->getEvidenceBlockId($i);
        }
        foreach (array_reverse($evidenceBlockIdList) as $index => $evidenceBlockId) {
            if (isset($evidenceBlocks[$evidenceBlockId])) {
                if (!in_array($evidenceBlockId, $currentBlockIdList)) {
                    $this->insertEvidenceBlockLayout(
                        $evidenceBlocks[$evidenceBlockId],
                        $layout,
                        $index
                    );
                } else {
                    $this->updateEvidenceBlockLayout(
                        $evidenceBlocks[$evidenceBlockId],
                        $layout,
                        $index
                    );
                }
            } else {
                $this->removeEvidenceBlockFromLayout($evidenceBlockId, $layout);
            }
        }

        if ($locale !== 'ita-IT') {
            foreach ($currentBlockIdList as $blockId) {
                foreach ($evidenceBlockIdList as $evidenceBlockId) {
                    $removeBlockId = str_replace($locale, '', $evidenceBlockId);
                    $this->removeEvidenceBlockFromLayout($removeBlockId, $layout);
                }
            }
        }

        $response = [
            'abstract' => $data['abstract'] ?? '',
            'image' => isset($data['image']) ? array_column((array)$data['image'], 'id') : [],
            'layout' => $layout,
        ];

        if ($this->getTimelineConnector()) {
            $timelineData = [];
            $postData = (array)$data['timeline_elements'];
            foreach ($postData as $item) {
                if (is_numeric($item)) {
                    $timelineData[] = (int)$item;
                } elseif (is_array($item) && isset($item['id'])) {
                    $timelineData[] = (int)$item['id'];
                }
            }

            $response['timeline_elements'] = empty($timelineData) ? null : $timelineData;
        }

        return $response;
    }

    protected function getLayout(): array
    {
        $evidences = ['title_evidence', 'section_evidence',];

        $sectionCount = $this->getEvidenceBlockSetupCount();
        if ($sectionCount > 1) {
            for ($i = 2; $i <= $sectionCount; $i++) {
                $evidences[] = 'title_evidence_' . $i;
                $evidences[] = 'section_evidence_' . $i;
            }
        }

        $categories = [
            [
                'identifier' => 'abstract',
                'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Description'),
                'identifiers' => ['abstract', 'description', 'image',],
            ],
            [
                'identifier' => 'evidence',
                'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'In evidence'),
                'identifiers' => $evidences,
            ],
        ];

        if ($this->getTimelineConnector()) {
            $categories[] = [
                'identifier' => 'timeline',
                'name' => ezpI18n::tr('bootstrapitalia/editor-gui', 'Timeline'),
                'identifiers' => ['timeline_elements'],
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

    private function retrieveEvidenceBlocksFromSubmitData($data): array
    {
        $evidenceBlocks = [];

        $evidenceBlock = $this->getEvidenceBlock();
        if (!empty($evidenceBlock['block_id'])) {
            $evidenceBlock['name'] = $data['title_evidence'] ?? '';
            $remoteIdList = [];
            if (isset($data['section_evidence'])) {
                foreach ($data['section_evidence'] as $item) {
                    $object = eZContentObject::fetch((int)$item['id']);
                    if ($object instanceof eZContentObject) {
                        $remoteIdList[] = $object->attribute('remote_id');
                    }
                }
            }
            if (count($remoteIdList)) {
                $evidenceBlock['valid_items'] = $remoteIdList;
                $evidenceBlocks[$evidenceBlock['block_id']] = $evidenceBlock;
            }
        }

        $sectionCount = $this->getEvidenceBlockSetupCount();
        if ($sectionCount > 1) {
            for ($i = 2; $i <= $sectionCount; $i++) {
                $evidenceBlock = $this->getEvidenceBlock($i);
                if (!empty($evidenceBlock['block_id'])) {
                    $evidenceBlock['name'] = $data['title_evidence_' . $i] ?? '';
                    $remoteIdList = [];
                    if (isset($data['section_evidence_' . $i])) {
                        foreach ($data['section_evidence_' . $i] as $item) {
                            $object = eZContentObject::fetch((int)$item['id']);
                            if ($object instanceof eZContentObject) {
                                $remoteIdList[] = $object->attribute('remote_id');
                            }
                        }
                    }
                    if (count($remoteIdList)) {
                        $evidenceBlock['valid_items'] = $remoteIdList;
                        $evidenceBlocks[$evidenceBlock['block_id']] = $evidenceBlock;
                    }
                }
            }
        }


        return $evidenceBlocks;
    }

    protected function applyBackgroundToEvidenceBlock(&$evidenceBlock, $blockIndex)
    {
        $evidenceBlock["custom_attributes"]["color_style"] =
            $this->originalObject->attribute('remote_id') !== 'topics' ? '' : 'bg-100';
    }

    protected function insertEvidenceBlockLayout($evidenceBlock, &$layout, $blockIndex)
    {
        $this->applyBackgroundToEvidenceBlock($evidenceBlock, $blockIndex);
        array_unshift($layout['global']['blocks'], $evidenceBlock);
    }

    protected function updateEvidenceBlockLayout($evidenceBlock, &$layout, $blockIndex)
    {
        $this->applyBackgroundToEvidenceBlock($evidenceBlock, $blockIndex);
        foreach ($layout['global']['blocks'] as $index => $block) {
            if ($block['block_id'] == $evidenceBlock['block_id']) {
                $layout['global']['blocks'][$index] = $evidenceBlock;
            }
        }
    }

    protected function removeEvidenceBlockFromLayout($blockId, &$layout)
    {
        foreach ($layout['global']['blocks'] as $index => $block) {
            if ($block['block_id'] == $blockId) {
                unset($layout['global']['blocks'][$index]);
            }
        }
    }
}