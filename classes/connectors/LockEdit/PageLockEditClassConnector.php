<?php

abstract class PageLockEditClassConnector extends LockEditClassConnector
{
    public static function getContentClass(): eZContentClass
    {
        return eZContentClass::fetchByIdentifier('edit_page');
    }

    public function getData()
    {
        $this->currentBlocks = $this->content['layout']['content']['global']['blocks'] ?? [];

        $image = isset($this->content['image']['content'][0]) ? [[
            'id' => $this->content['image']['content'][0]['id'],
            'name' => $this->content['image']['content'][0]['name'][$this->getHelper()->getSetting('language')] ?? current($this->content['image']['content'][0]['name']),
            'class' => $this->content['image']['content'][0]['classIdentifier'],
        ]] : null;

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

        return $options;
    }


    protected function filterOptionsByEvidenceBlock($options, $blockIndex = 1): array
    {
        if ($blockIndex > 1){
            $options['fields']['title_evidence_' . $blockIndex]['helper'] = '';
            $options['fields']['section_evidence_' . $blockIndex]['browse']['subtree'] = '';
        }else{
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
        return substr('evd'. $suffix . $this->originalObject->attribute('remote_id'), 0, 32);
    }

    protected function getEmptyEvidenceBlock($blockIndex = 1): array
    {
        return [
            'block_id' => $this->getEvidenceBlockId($blockIndex),
            'name' => 'In evidenza',
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
        return 3;
    }

    protected function getEvidenceBlock($blockIndex = 1): array
    {
        return $this->findBlockById($this->getEvidenceBlockId($blockIndex)) ?? $this->getEmptyEvidenceBlock($blockIndex);
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

        $hasEvidenceItems = isset($data['section_evidence'][0]['id']);
        $sectionCount = $this->getEvidenceBlockSetupCount();
        if ($sectionCount > 1) {
            for ($i = 2; $i <= $sectionCount; $i++) {
                if (!$hasEvidenceItems){
                    $hasEvidenceItems = isset($data['section_evidence_' . $i][0]['id']);
                }
            }
        }

        $evidenceBlock = $this->getEvidenceBlock();
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
        } else {
            $evidenceBlock = $this->resetEvidenceBlock($evidenceBlock);
        }

        $evidenceBlocks = [];
        if (isset($evidenceBlock['block_id']) && !empty($evidenceBlock['block_id'])) {
            $evidenceBlocks[$evidenceBlock['block_id']] = $evidenceBlock;
        }
        if ($sectionCount > 1) {
            for ($i = 2; $i <= $sectionCount; $i++) {
                $evidenceBlock = $this->getEvidenceBlock($i);
                if (!empty($evidenceBlock)) {
                    $evidenceBlock['name'] = $data['title_evidence_' . $i] ?? '';
                }
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
                } else {
                    $evidenceBlock = $this->resetEvidenceBlock($evidenceBlock, $i);
                }
            }
            if (isset($evidenceBlock['block_id']) && !empty($evidenceBlock['block_id'])) {
                $evidenceBlocks[$evidenceBlock['block_id']] = $evidenceBlock;
            }
        }

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

        $blocks = $layout['global']['blocks'];
        $firstBlockEvidenceIndex = -1;
        foreach ($blocks as $index => $block) {
            if ($block['type'] === 'HTML' && $block['custom_attributes']['html'] === '') {
                unset($layout['global']['blocks'][$index]);
                continue;
            }
            if (isset($evidenceBlocks[$block['block_id']])) {
                $layout['global']['blocks'][$index] = $evidenceBlocks[$block['block_id']];
                if ($firstBlockEvidenceIndex === -1) {
                    $firstBlockEvidenceIndex = $index;
                }
                $hasEvidenceItems = false;
            }else{
                for ($i = 1; $i <= $sectionCount; $i++) {
                    if ($block['block_id'] == $this->getEvidenceBlockId($i)){
                        unset($layout['global']['blocks'][$index]);
                    }
                }
            }
        }

        $countBlocks = count($layout['global']['blocks']);
        if ($hasEvidenceItems) {
            foreach (array_reverse($evidenceBlocks) as $evidenceBlock) {
                array_unshift($layout['global']['blocks'], $evidenceBlock);
            }
            $firstBlockEvidenceIndex = 0;
        }
        if ($countBlocks > 0 && $firstBlockEvidenceIndex >= 0) {
            $layout['global']['blocks'][$firstBlockEvidenceIndex]["custom_attributes"]["color_style"] =
                $this->originalObject->attribute('remote_id') !== 'topics' ? '' : 'bg-100';
        }

        if (count($layout['global']['blocks']) === 0) {
            $layout = [];
        }

        return [
            'abstract' => $data['abstract'] ?? '',
            'image' => isset($data['image']) ? array_column((array)$data['image'], 'id') : [],
            'layout' => $layout,
        ];
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
                'name' => 'Descrizione',
                'identifiers' => ['abstract', 'description', 'image', ],
            ],
            [
                'identifier' => 'evidence',
                'name' => 'In evidenza',
                'identifiers' => $evidences,
            ],
        ];

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
}