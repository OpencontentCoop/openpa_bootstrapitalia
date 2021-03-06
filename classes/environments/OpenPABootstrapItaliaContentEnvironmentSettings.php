<?php

use Opencontent\Opendata\Api\AttributeConverterLoader;
use Opencontent\Opendata\Api\ClassRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\Api\Values\ContentData;
use Opencontent\Opendata\Api\Values\ExtraData;

class OpenPABootstrapItaliaContentEnvironmentSettings extends DefaultEnvironmentSettings
{
    protected static $classDefinition = array();

    protected $maxSearchLimit = 300;

    public function filterContent(Content $content)
    {
        if (isset($this->request->get['view'])) {

            $viewData = false;
            $ViewMode = $this->request->get['view'];
            if (in_array($ViewMode, [
                'accordion_content',
                'banner',
                'banner_color',
                'card',
                'card_image',
                'card_teaser',
                'image',
                'text_linked',
            ])) {
                $NodeID = $content->metadata->mainNodeId;
                $Module = new eZModule("", "", 'opendata');
                $tpl = eZTemplate::factory();
                $LanguageCode = null;
                $Offset = 0;
                $ini = eZINI::instance();
                $viewParameters = [];
                $collectionAttributes = false;
                $validation = [];

                if ($ViewMode == 'card') {
                    $viewParameters['_custom'] = ['view_variation' => 'big'];
                }
                if ($ViewMode == 'banner' || $ViewMode == 'banner_color') {
                    $viewParameters['_custom'] = ['view_variation' => 'banner-round banner-shadow h-100'];
                }

                $cacheFileArray = eZNodeviewfunctions::generateViewCacheFile(
                    eZUser::currentUser(),
                    $NodeID,
                    $Offset,
                    false,
                    $LanguageCode,
                    $ViewMode
                );

                $args = compact([
                    "NodeID", "Module", "tpl", "LanguageCode", "ViewMode", "Offset", "ini", "viewParameters", "collectionAttributes", "validation"
                ]);
                $result = eZClusterFileHandler::instance($cacheFileArray['cache_path'])
                    ->processCache(
                        array('eZNodeviewfunctions', 'contentViewRetrieve'),
                        array('eZNodeviewfunctions', 'contentViewGenerate'),
                        null,
                        null,
                        $args
                    );

                if (is_array($result)) {
                    $viewData = $result['content'];
                }
            }

            $extra = new ExtraData();
            $extra->set('view', $viewData);
            $content->extradata = $extra;
        }

        return parent::filterContent($content);
    }

    protected function filterMetaData(Content $content)
    {
        $parentNodes = array();
        foreach ($content->metadata->parentNodes as $parentNode) {
            $parentNodes[] = $parentNode['id'];
        }

        $data = array(
            'id' => $content->metadata->id,
            'remoteId' => $content->metadata->remoteId,
            'classIdentifier' => $content->metadata->classIdentifier,
            'class' => str_replace('/content', '/classes', $this->requestBaseUri) . $content->metadata->classIdentifier,
            'ownerId' => $content->metadata->ownerId,
            'ownerName' => $content->metadata->ownerName,
            'mainNodeId' => (int)$content->metadata->mainNodeId,
            'sectionIdentifier' => $content->metadata->sectionIdentifier,
            'stateIdentifiers' => $content->metadata->stateIdentifiers,
            'published' => $content->metadata->published,
            'modified' => $content->metadata->modified,
            'languages' => $content->metadata->languages,
            'name' => $content->metadata->name,
            'parentNodes' => $parentNodes,
            'assignedNodes' => $content->metadata->assignedNodes,
            'link' => $this->requestBaseUri . 'read/' . $content->metadata->id,
            'classDefinition' => $this->getClassDefinition($content->metadata->classIdentifier)
        );
        $propertyBlackList = (array)EnvironmentLoader::ini()->variable('ContentSettings', 'PropertyBlackListForExternal');
        if (count($propertyBlackList) > 0 && !eZUser::isCurrentUserRegistered()) {
            foreach ($propertyBlackList as $property) {
                if (isset($data[$property])) {
                    $data[$property] = is_array($data[$property]) ? [] : null;
                }
            }
        }

        $content->metadata = new ContentData($data);
        return $content;
    }

    protected function getClassDefinition($classIdentifier)
    {
        if (!isset(self::$classDefinition[$classIdentifier])) {
            $classRepository = new ClassRepository();
            $class = $classRepository->load($classIdentifier);

            $fields = array();
            foreach ($class->fields as $field) {
                $fields[] = array(
                    'identifier' => $field['identifier'],
                    'name' => $field['name'],
                    'dataType' => $field['dataType'],
                    'constraint' => $field['constraint'],
                );
            }

            self::$classDefinition[$classIdentifier] = array(
                'identifier' => $class->identifier,
                'name' => $class->name,
                'fields' => $fields
            );
        }

        return self::$classDefinition[$classIdentifier];
    }

    protected function getClassName($classIdentifier)
    {
        $language = eZLocale::currentLocaleCode();
        $definition = $this->getClassDefinition($classIdentifier);
        return isset($definition['name'][$language]) ? $definition['name'][$language] : array_shift($definition['name']);
    }

    protected function flatData(Content $content)
    {
        $flatData = array();
        foreach ($content->data as $language => $data) {
            foreach ($data as $identifier => $value) {
                $valueContent = $value['content'];
                if ($value['datatype'] == 'ezobjectrelationlist'
                    || $value['datatype'] == 'ezobjectrelation') {
                    $converter = AttributeConverterLoader::load(
                        $content->metadata->classIdentifier,
                        $identifier,
                        $value['datatype']
                    );

                    if ($converter instanceof FullRelationsAttributeConverter) {
                        $valueContent = $this->flatFullRelation($value, $language);
                    } else {
                        $valueContent = $this->flatDefaultRelation($value, $language);
                    }
                }

                if ($value['datatype'] == 'ezbinaryfile' && !empty($valueContent['filename'])) {
                    $valueContent['filename'] = OpenPABootstrapItaliaOperators::cleanFileName($valueContent['filename']);
                }

                if ($value['datatype'] == 'ocmultibinary' && !empty($valueContent)) {
                    foreach ($valueContent as $key => $value) {
                        $valueContent[$key]['filename'] = OpenPABootstrapItaliaOperators::cleanFileName($valueContent[$key]['filename']);
                    }
                }

                $flatData[$language][$identifier] = $valueContent;
            }
        }
        $content->data = new ContentData($flatData);
        return $content;
    }

    private function flatFullRelation($value, $language)
    {
        $valueContent = array();
        if (is_array($value['content'])) {
            foreach ($value['content'] as $content) {
                if (is_array($content) || $content instanceof ArrayAccess) {
                    $item = $content['metadata'];
                    $parentNodes = array();
                    foreach ($item['parentNodes'] as $parentNode) {
                        $parentNodes[] = $parentNode['id'];
                    }
                    $valueContent[] = array(
                        'id' => $item['id'],
                        'remoteId' => $item['remoteId'],
                        'classIdentifier' => $item['classIdentifier'],
                        'class' => str_replace('/content', '/classes', $this->requestBaseUri) . $item['classIdentifier'],
                        'languages' => $item['languages'],
                        'name' => $item['name'],
                        'link' => $this->requestBaseUri . 'read/' . $item['id'],
                        'mainNodeId' => $item['mainNodeId'],
                        'data' => isset($content['data'][$language]) ? $content['data'][$language] : []
                    );
                }
            }
        }

        return $valueContent;
    }

    private function flatDefaultRelation($value, $language)
    {
        $valueContent = array();
        if (is_array($value['content'])) {
            foreach ($value['content'] as $item) {
                if (is_array($item) || $item instanceof ArrayAccess) {
                    $parentNodes = array();
                    foreach ($item['parentNodes'] as $parentNode) {
                        $parentNodes[] = $parentNode['id'];
                    }
                    $valueContent[] = array(
                        'id' => $item['id'],
                        'remoteId' => $item['remoteId'],
                        'classIdentifier' => $item['classIdentifier'],
                        'class' => str_replace('/content', '/classes', $this->requestBaseUri) . $item['classIdentifier'],
                        'languages' => $item['languages'],
                        'name' => $item['name'],
                        'link' => $this->requestBaseUri . 'read/' . $item['id'],
                        'mainNodeId' => $item['mainNodeId']
                    );
                }
            }
        }

        return $valueContent;
    }
}
