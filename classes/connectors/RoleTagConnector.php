<?php

use Opencontent\Ocopendata\Forms\Connectors\AbstractBaseConnector;
use Opencontent\Opendata\Api\Structs\TagStruct;
use Opencontent\Opendata\Api\Structs\TagSynonymStruct;
use Opencontent\Opendata\Api\Structs\TagTranslationStruct;
use Opencontent\Opendata\Api\TagRepository;

class RoleTagConnector extends AbstractBaseConnector
{
    /**
     * @var eZTagsObject
     */
    private $rootTag;

    /**
     * @var eZTagsObject|null
     */
    private $currentTag;

    /**
     * @var string[]
     */
    private $languages;

    public function runService($serviceIdentifier)
    {
        $this->languages = [];
        foreach (eZINI::instance()->variable('RegionalSettings', 'SiteLanguageList') as $language) {
            $this->languages[$language] = eZLocale::instance($language)->languageName();
        }
        if (!$this->getHelper()->hasParameter('root_tag')) {
            throw new Exception("Missing root tag parameter");
        }
        $this->rootTag = eZTagsObject::fetch((int)$this->getHelper()->getParameter('root_tag'));
        if (!$this->rootTag instanceof eZTagsObject) {
            throw new Exception("Root tag not found");
        }
        if ($this->getHelper()->hasParameter('current_tag')) {
            $this->currentTag = eZTagsObject::fetch((int)$this->getHelper()->getParameter('current_tag'));
        }
        return parent::runService($serviceIdentifier);
    }

    protected function getData()
    {
        $data = [];
        if ($this->currentTag instanceof eZTagsObject) {
            foreach ($this->currentTag->getTranslations() as $translation) {
                $data[$translation->attribute('locale')] = $translation->attribute('keyword');
            }
            $data['synonyms'] = [];
            foreach ($this->currentTag->getSynonyms() as $synonym) {
                $data['synonyms'][] = [
                    'id' => $synonym->attribute('id'),
                    'locale' => $synonym->attribute('current_language'),
                    'keyword' => $synonym->attribute('keyword'),
                ];
            }
        }

        return $data;
    }

    protected function getSchema()
    {
        $schema = [
            'title' => '',
            'type' => 'object',
            'properties' => []
        ];

        foreach ($this->languages as $language => $languageName) {
            $schema['properties'][$language] = [
                'title' => $languageName,
                'required' => true
            ];
            if ($this->currentTag instanceof eZTagsObject) {
                $schema['properties'][$language]['readonly'] = true;
            }
        }

        $matrix = array(
            "type" => "array",
            "title" => ezpI18n::tr('extension/eztags/tags/view', 'Synonyms'),
            "items" => [
                "type" => "object",
                "properties" => [
                    'id' => [
                        "type" => "string"
                    ],
                    'locale' => [
                        "enum" => array_keys($this->languages),
                        "title" => ezpI18n::tr('design/ocbootstrap/content/draft', 'Language'),
                        'required' => true,
                    ],
                    'keyword' => [
                        "type" => "string",
                        "title" => ezpI18n::tr('design/ocbootstrap/content/draft', 'Name'),
                        'required' => true,
                    ]
                ]
            ]
        );
        $schema['properties']['synonyms'] = $matrix;

        return $schema;
    }

    protected function getOptions()
    {
        $options = [
            'form' => [
                'attributes' => [
                    "action" => $this->getHelper()->getServiceUrl('action', $this->getHelper()->getParameters()),
                    'method' => 'post',
                    'enctype' => 'multipart/form-data'
                ],
            ],
            'fields' => [
                'synonyms' => [
                    "type" => "table",
                    "items" => [
                        'fields' => [
                            'id' => [
                                'type' => 'hidden'
                            ],
                            'locale' => [
                                "optionLabels" => array_values($this->languages),
                                'type' => 'select',
                            ]
                        ]
                    ]
                ],
            ],
        ];

        return $options;
    }

    protected function getView()
    {
        $baseView = 'create';
        if ($this->currentTag instanceof eZTagsObject) {
            $baseView = 'edit';
        }

        $view = array(
            "parent" => $this->getAlpacaBaseDesign() . "-" . $baseView,
            "locale" => $this->getAlpacaLocale()
        );

        return $view;
    }

    protected function submit()
    {
        $data = $_POST;
        $tagRepository = new TagRepository();
        if ($this->currentTag instanceof eZTagsObject) {
            $storeTagTranslations = [];
            $tagSynonyms = [];
            $deleteSynonymsIdList = array_fill_keys(array_column($this->getData()['synonyms'], 'id'), true);
            foreach ($data['synonyms'] as $synonym) {
                if (isset($synonym['id'])) {
                    $tag = eZTagsObject::fetch((int)$synonym['id'], $synonym['locale']);
                    if ($tag instanceof eZTagsObject
                        && $tag->attribute('keyword') !== $synonym['keyword']
                    ) {
                        if (eZTagsObject::exists($tag->attribute('id'), $synonym['keyword'], $tag->attribute('parent_id'))) {
                            throw new Exception(
                                $synonym['keyword'] . ': ' . ezpI18n::tr('extension/eztags/errors', 'Tag/synonym with that translation already exists in selected location.')
                            );
                        }
                        $tagTranslation = eZTagsKeyword::fetch($tag->attribute('id'), $synonym['locale']);
                        $tagTranslation->setAttribute('keyword', $synonym['keyword']);
                        $storeTagTranslations[] = $tagTranslation;
                    }
                    unset($deleteSynonymsIdList[$synonym['id']]);
                } else {
                    $tagSynonym = new TagSynonymStruct();
                    $tagSynonym->locale = $synonym['locale'];
                    $tagSynonym->keyword = $synonym['keyword'];
                    $tagSynonym->tagId = $this->currentTag->attribute('id');
                    $tagSynonyms[] = $tagSynonym;
                }
            }

            eZDB::instance()->begin();
            foreach ($storeTagTranslations as $storeTagTranslation) {
                $storeTagTranslation->store();
            }
            eZDB::instance()->commit();

            foreach ($tagSynonyms as $synonym){
                $tagRepository->addSynonym($synonym);
            }

            foreach (array_keys($deleteSynonymsIdList) as $deleteSynonymsId) {
                $tag = eZTagsObject::fetchWithMainTranslation($deleteSynonymsId);
                if ($tag instanceof eZTagsObject) {
                    $db = eZDB::instance();
                    $db->begin();
                    $parentTag = $tag->getParent(true);
                    if ($parentTag instanceof eZTagsObject) {
                        $parentTag->updateModified();
                    }
                    $tag->registerSearchObjects();
                    $tag->transferObjectsToAnotherTag($tag->attribute('main_tag_id'));
                    $tag->remove();
                    $db->commit();
                }
            }
        } else {
            $tagStruct = false;
            $tagTranslations = [];
            $tagSynonyms = [];
            foreach (array_keys($this->languages) as $index => $language) {
                if ($index == 0) {
                    $tagStruct = new TagStruct();
                    $tagStruct->locale = $language;
                    $tagStruct->keyword = $data[$language];
                    $tagStruct->parentTagId = $this->rootTag->attribute('id');
                } else {
                    $tagTranslation = new TagTranslationStruct();
                    $tagTranslation->keyword = $data[$language];
                    $tagTranslation->locale = $language;
                    $tagTranslations[] = $tagTranslation;
                }
            }
            foreach ($data['synonyms'] as $synonym) {
                $tagSynonym = new TagSynonymStruct();
                $tagSynonym->locale = $synonym['locale'];
                $tagSynonym->keyword = $synonym['keyword'];
                $tagSynonyms[] = $tagSynonym;
            }
            if ($tagStruct instanceof TagStruct) {
                $result = $tagRepository->create($tagStruct);
                if ($result['message'] == 'success') {
                    foreach ($tagTranslations as $translation) {
                        $translation->tagId = $result['tag']->id;
                        $tagRepository->addTranslation($translation);
                    }
                    foreach ($tagSynonyms as $synonym) {
                        $synonym->tagId = $result['tag']->id;
                        $tagRepository->addSynonym($synonym);
                    }
                }
            }
        }

        return true;
    }

    protected function upload()
    {
        throw new Exception('Not allowed');
    }

    protected function getAlpacaLocale()
    {
        $localeMap = array(
            'eng-GB' => false,
            'chi-CN' => 'zh_CN',
            'cze-CZ' => 'cs_CZ',
            'cro-HR' => 'hr_HR',
            'dut-NL' => 'nl_BE',
            'fin-FI' => 'fi_FI',
            'fre-FR' => 'fr_FR',
            //'ger-DE' => 'de_AT',
            'ger-DE' => 'de_DE',
            'ell-GR' => 'el_GR',
            'ita-IT' => 'it_IT',
            'jpn-JP' => 'ja_JP',
            'nor-NO' => 'nb_NO',
            'pol-PL' => 'pl_PL',
            'por-BR' => 'pt_BR',
            'esl-ES' => 'es_ES',
            'swe-SE' => 'sv_SE',
        );

        $currentLanguage = $this->getHelper()->getSetting('language');

        return isset($localeMap[$currentLanguage]) ? $localeMap[$currentLanguage] : "it_IT";
    }

    protected function getAlpacaBaseDesign()
    {
        return "bootstrap";
    }
}