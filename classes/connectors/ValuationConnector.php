<?php

use Opencontent\Ocopendata\Forms\Connectors\AbstractBaseConnector;

class ValuationConnector extends AbstractBaseConnector
{
    const BASE_URI = 'valuation/form/';

    private $isValid;

    private $valuationObject;

    private $hideAttributes = [
        'useful',
        'link',
        'context',
        'antispam',
    ];

    /**
     * @var eZContentObjectAttribute[]
     */
    private $valuationAttributes = [];

    public function __construct($identifier)
    {
        if (!eZSession::hasStarted()) {
            eZSession::start();
        }

        $this->valuationObject = eZContentObject::fetchByRemoteID('openpa-valuation');
        if ($this->valuationObject instanceof eZContentObject) {
            $attributes = $this->valuationObject->currentVersion()->contentObjectAttributes();
            foreach ($attributes as $contentObjectAttribute) {
                $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
                if ($contentClassAttribute->attribute('is_information_collector')) {
                    $this->valuationAttributes[$contentClassAttribute->attribute('identifier')] = $contentObjectAttribute;
                }
            }
        }

        parent::__construct($identifier);
    }

    public function submitOk()
    {
        if (!$this->isValid()) {
            return false;
        }

        $data = [
            'useful' => '1',
            'link' => $this->getCurrentPage(),
            'context' => eZSys::serverVariable('HTTP_USER_AGENT')
        ];

        return $this->store($data);
    }

    private function isValid()
    {
        if ($this->isValid === null) {
            $this->isValid = false;
            if ($this->valuationObject instanceof eZContentObject && $this->getHelper()->hasParameter('token')) {
                $recaptcha = new OpenPARecaptcha(3);
                eZHTTPTool::instance()->setPostVariable('g-recaptcha-response', $this->getHelper()->getParameter('token'));
                $this->isValid = $recaptcha->validate();
            }
        }

        return $this->isValid;
    }

    private function getCurrentPage()
    {
        $currentPage = $this->getHelper()->getParameter('page');
        eZURI::transformURI($currentPage, false, 'full');

        return $currentPage;
    }

    private function store($data)
    {
        $newCollection = false;
        $currentUserIdentifier = md5($data['link'] . eZHTTPTool::instance()->sessionID());
        $collection = eZPersistentObject::fetchObject(eZInformationCollection::definition(), null, [
            'user_identifier' => $currentUserIdentifier,
            'contentobject_id' => $this->valuationObject->attribute('id'),
            'creator_id' => eZUser::currentUserID()
        ]);
        if (!$collection instanceof eZInformationCollection) {
            $collection = eZInformationCollection::create($this->valuationObject->attribute('id'), $currentUserIdentifier, eZUser::currentUserID());
            $collection->store();
            $newCollection = true;
        } else {
            $collection->setAttribute('modified', time());
        }

        $db = eZDB::instance();
        $db->begin();
        foreach ($this->valuationAttributes as $identifier => $attribute) {
            if ($newCollection) {
                $collectionAttribute = eZInformationCollectionAttribute::create($collection->attribute('id'));
            } else {
                $collectionAttribute = eZInformationCollectionAttribute::fetchByObjectAttributeID($collection->attribute('id'), $attribute->attribute('id'));
            }

            if ($collectionAttribute) {
                $collectionAttribute->setAttribute('contentclass_attribute_id', $attribute->attribute('contentclassattribute_id'));
                $collectionAttribute->setAttribute('contentobject_attribute_id', $attribute->attribute('id'));
                $collectionAttribute->setAttribute('contentobject_id', $attribute->attribute('contentobject_id'));
                $collectionAttribute->setAttribute('data_text', isset($data[$identifier]) ? $data[$identifier] : '');
                $collectionAttribute->store();
            }
        }
        $db->commit();
        $collection->sync();
        //$this->sendEmail();

        return (int)$collection->attribute('id');
    }

    protected function getData()
    {
        return null;
    }

    protected function getSchema()
    {
        if (!$this->isValid()) {
            throw new Exception('Valuation object not found');
        }

        $data = [
            'useful' => '0',
            'link' => $this->getCurrentPage(),
            'context' => eZSys::serverVariable('HTTP_USER_AGENT')
        ];

        $this->store($data);

        $schema = [
            'title' => '',
            'type' => 'object',
            'properties' => []
        ];

        foreach ($this->valuationAttributes as $identifier => $attribute) {
            if (!in_array($identifier, $this->hideAttributes)) {
                $property = [
                    'title' => $attribute->attribute('contentclass_attribute_name'),
                    'required' => false
                ];
                if ($attribute->attribute('data_type_string') == eZSelectionType::DATA_TYPE_STRING) {
                    /** @var array $optionsArray */
                    $optionsArray = $attribute->attribute('class_content');
                    $property['enum'] = array_column($optionsArray['options'], 'id');

                }
                $schema['properties'][$identifier] = $property;
            }
        }

        return $schema;
    }

    protected function getOptions()
    {
        if (!$this->isValid()) {
            throw new Exception('Valuation object not found a');
        }

        $description = '';
        $dataMap = $this->valuationObject->dataMap();
        if (isset($dataMap['description']) && $dataMap['description']->hasContent()) {
            $description = str_replace('&nbsp;', ' ', $dataMap['description']->content()->attribute('output')->attribute('output_text'));
        }

        $options = [
            'form' => [
                'attributes' => [
                    'action' => $this->getServiceUrl('action', $this->getHelper()->getParameters()),
                    'method' => 'post',
                    'enctype' => 'multipart/form-data'
                ],
            ],
            'helper' => strip_tags($description),
            'fields' => [],
        ];

        foreach ($this->valuationAttributes as $identifier => $attribute) {
            if (!in_array($identifier, $this->hideAttributes)) {
                $option = [
                    'helper' => $attribute->attribute('contentclass_attribute')->attribute('description'),
                ];

                if ($attribute->attribute('data_type_string') == eZTextType::DATA_TYPE_STRING) {
                    $option['type'] = 'textarea';
                }

                if ($attribute->attribute('data_type_string') == eZSelectionType::DATA_TYPE_STRING) {
                    /** @var array $optionsArray */
                    $optionsArray = $attribute->attribute('class_content');
                    $option['type'] = 'radio';
                    $option['hideNone'] = true;
                    $option['sort'] = false;
                    $option['optionLabels'] = array_column($optionsArray['options'], 'name');
                }

                $options['fields'][$identifier] = $option;
            }
        }

        return $options;
    }

    private function getServiceUrl($serviceIdentifier, array $params = array())
    {
        $suffix = '';
        if (!empty($params)) {
            $suffix .= '?' . http_build_query($params);
        }
        $url = self::BASE_URI . "{$serviceIdentifier}";
        \eZURI::transformURI($url, false, 'full');

        $url .= $suffix;
        return $url;
    }

    protected function getView()
    {
        $parent = 'bootstrap-edit-horizontal';
        $steps = $bindings = [];
        $index = 1;
        foreach ($this->valuationAttributes as $identifier => $attribute) {
            if (!in_array($identifier, $this->hideAttributes)) {
                $steps[] = [
                    'title' => $attribute->attribute('contentclass_attribute_name'),
                ];
                $bindings[$identifier] = $index;
                $index++;
            }
        }
        $wizard = [
            'bindings' => $bindings,
            'steps' => $steps
        ];
        return [
            'parent' => $parent,
            'wizard' => $wizard,
            'locale' => $this->getAlpacaLocale()
        ];
    }

    protected function getAlpacaLocale()
    {
        $localeMap = [
            'eng-GB' => false,
            'chi-CN' => 'zh_CN',
            'cze-CZ' => 'cs_CZ',
            'cro-HR' => 'hr_HR',
            'dut-NL' => 'nl_BE',
            'fin-FI' => 'fi_FI',
            'fre-FR' => 'fr_FR',
            'ger-DE' => 'de_DE',
            'ell-GR' => 'el_GR',
            'ita-IT' => 'it_IT',
            'jpn-JP' => 'ja_JP',
            'nor-NO' => 'nb_NO',
            'pol-PL' => 'pl_PL',
            'por-BR' => 'pt_BR',
            'esl-ES' => 'es_ES',
            'swe-SE' => 'sv_SE',
        ];

        $currentLanguage = $this->getHelper()->getSetting('language');

        return isset($localeMap[$currentLanguage]) ? $localeMap[$currentLanguage] : 'it_IT';
    }

    protected function submit()
    {
        $data = array_merge([
            'useful' => '0',
            'link' => $this->getHelper()->getParameter('page'),
            'context' => eZSys::serverVariable('HTTP_USER_AGENT')
        ], $_POST);

        return $this->store($data);
    }

    protected function upload()
    {
        throw new Exception('Not allowed');
    }

}