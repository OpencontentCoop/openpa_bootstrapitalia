<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;
use Symfony\Component\Yaml\Yaml;

class FrontpageLockEditClassConnector extends LockEditClassConnector
{
    public static function getContentClass(): eZContentClass
    {
        return eZContentClass::fetchByIdentifier('edit_frontpage');
    }

    public function getData()
    {
        $this->currentBlocks = $this->content['layout']['content']['global']['blocks'] ?? [];
        return $this->mapOriginalContentToSimplifiedForm();
    }

    protected function mapOriginalContentToSimplifiedForm()
    {
        $image = isset($this->content['image']['content'][0]) ? [[
            'id' => $this->content['image']['content'][0]['id'],
            'name' => $this->content['image']['content'][0]['name'][$this->getHelper()->getSetting('language')] ?? current($this->content['image']['content'][0]['name']),
            'class' => $this->content['image']['content'][0]['classIdentifier'],
        ]] : null;
        return [
            'abstract' => $this->content['abstract']['content'],
            'image' => $image,
            'section_evidence' => $this->mapEvidenceItemsToRelations(),
            'title_evidence' => $this->getEvidenceBlock()['name'],
        ];
    }

    protected function mapEvidenceItemsToRelations()
    {
        $block = $this->getEvidenceBlock();
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

    protected function getEvidenceBlockId(): string
    {
        return substr('evd' . $this->originalObject->attribute('remote_id'), 0, 32);
    }

    protected function getEmptyEvidenceBlock(): array
    {
        return [
            'block_id' => $this->getEvidenceBlockId(),
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

    protected function getEvidenceBlock(): array
    {
        return $this->findBlockById($this->getEvidenceBlockId()) ?? $this->getEmptyEvidenceBlock();
    }

    protected function fetchSourceBlocks(): array
    {
        return [];
    }

    public function submit()
    {
        $this->currentBlocks = $this->content['layout']['content']['global']['blocks'] ?? [];
        $contents = $this->mapSubmittedFormToOriginalContent($this->getSubmitData());

        $contentRepository = new ContentRepository();
        $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));

        $payload = new PayloadBuilder();
        $payload->setId((int)$this->getHelper()->getParameter('object'));
        foreach ($contents as $identifier => $value) {
            $payload->setData($this->helper->getSetting('language'), $identifier, $value);
        }

        $result = $contentRepository->update($payload->getArrayCopy(), true);
        $this->cleanup();
        $result['conversion'] = $contents;

        return $result;
    }

    protected function mapSubmittedFormToOriginalContent($data)
    {
        $hasEvidenceItems = isset($data['section_evidence'][0]['id']);
        $evidenceBlock = $this->getEvidenceBlock();
        $evidenceBlock['name'] = $data['title_evidence'] ?? '';
        if ($hasEvidenceItems) {
            $remoteIdList = [];
            foreach ($data['section_evidence'] as $item) {
                $object = eZContentObject::fetch((int)$item['id']);
                if ($object instanceof eZContentObject) {
                    $remoteIdList[] = $object->attribute('remote_id');
                }
            }
            $evidenceBlock['valid_items'] = $remoteIdList;
        } else {
            $evidenceBlock['valid_items'] = [];
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
        $blockEvidenceIndex = -1;
        foreach ($blocks as $index => $block) {
            if ($block['type'] === 'HTML' && $block['custom_attributes']['html'] === '') {
                unset($layout['global']['blocks'][$index]);
                continue;
            }
            if ($block['block_id'] === $evidenceBlock['block_id']) {
                $layout['global']['blocks'][$index] = $evidenceBlock;
                $blockEvidenceIndex = $index;
                $hasEvidenceItems = false;
            }
        }

        $countBlocks = count($layout['global']['blocks']);
        if ($hasEvidenceItems) {
            array_unshift($layout['global']['blocks'], $evidenceBlock);
            $blockEvidenceIndex = 0;
        }
        if ($countBlocks > 0 && $blockEvidenceIndex >= 0) {
            $layout['global']['blocks'][$blockEvidenceIndex]["custom_attributes"]["color_style"] = '';
        }

        if (count($layout['global']['blocks']) === 0) {
            $layout = [];
        }
        return [
            'abstract' => $data['abstract'],
            'image' => array_column((array)$data['image'], 'id'),
            'layout' => $layout,
        ];
    }

    protected function getLayout(): array
    {
        $categories = [
            [
                'identifier' => 'abstract',
                'name' => 'Descrizione',
                'identifiers' => ['abstract', 'description', 'image', ],
            ],
            [
                'identifier' => 'evidence',
                'name' => 'In evidenza',
                'identifiers' => ['title_evidence', 'section_evidence',],
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
}