<?php

class OpenPABootstrapItaliaModerationFactory extends OCEditorialStuffPostDefaultFactory
{
    public function __construct($configuration)
    {
        parent::__construct($configuration);
        $defaults = eZINI::instance('editorialstuff.ini')->group('_moderation_defaults');
        $this->configuration = array_merge($defaults, $this->configuration);
        $this->setExtraConfigurations();
    }

    protected function setExtraConfigurations()
    {
        $class = eZContentClass::fetchByIdentifier($this->classIdentifier());
        /** @var eZContentClassAttribute[] $dataMap */
        $dataMap = [];
        if ($class instanceof eZContentClass) {
            $dataMap = $class->dataMap();
        }
        $this->configuration['HasExtraGeo'] = false;
        $views = ['list'];
        $indexPluginClasses = eZINI::instance('ezfind.ini')->variable('IndexPlugins', 'Class');
        foreach ($indexPluginClasses as $class => $plugin) {
            if ($plugin == 'ezfIndexSubAttributeGeo' && $class == $this->classIdentifier()) {
                $views[] = 'geo';
                $this->configuration['HasExtraGeo'] = true;
                break;
            }
        }

        foreach ($dataMap as $attribute) {
            if ($attribute->attribute('data_type_string') == eZGmapLocationType::DATA_TYPE_STRING) {
                if (!$this->configuration['HasExtraGeo']) {
                    $views[] = 'geo';
                }
            }
            if ($attribute->attribute('data_type_string') == OCEventType::DATA_TYPE_STRING) {
                $views[] = 'agenda';
            }
        }
        $this->configuration['Views'] = $views;
    }

    public function instancePost($data)
    {
        return new OpenPABootstrapItaliaModerationPost($data, $this);
    }

    public function dashboardModuleResult( $parameters, OCEditorialStuffHandlerInterface $handler, eZModule $module )
    {
        $tpl = $this->dashboardModuleResultTemplate( $parameters, $handler, $module );
        $Result = array();
        $Result['content'] = $tpl->fetch( "design:{$this->getTemplateDirectory()}/dashboard.tpl" );
        $contentInfoArray = array(
            'node_id' => null,
            'class_identifier' => null
        );
        $contentInfoArray['persistent_variable'] = array(
            'show_path' => true,
            'site_title' => 'Dashboard ' . $this->classIdentifier()
        );
        if ( is_array( $tpl->variable( 'persistent_variable' ) ) )
        {
            $contentInfoArray['persistent_variable'] = array_merge( $contentInfoArray['persistent_variable'], $tpl->variable( 'persistent_variable' ) );
        }
        if ( isset( $this->configuration['PersistentVariable'] ) && is_array( $this->configuration['PersistentVariable'] ) )
        {
            $contentInfoArray['persistent_variable'] = array_merge( $contentInfoArray['persistent_variable'], $this->configuration['PersistentVariable'] );
        }
        $Result['content_info'] = $contentInfoArray;
        $Result['path'] = array( array( 'url' => false, 'text' => isset( $this->configuration['Name'] ) ? $this->configuration['Name'] : 'Dashboard' ) );
        return $Result;
    }

    protected function dashboardModuleResultTemplate( $parameters, OCEditorialStuffHandlerInterface $handler, eZModule $module )
    {
        if ( isset( $this->configuration['UiContext'] ) && is_string( $this->configuration['UiContext'] ) )
            $module->setUIContextName( $this->configuration['UiContext'] );
        $tpl = eZTemplate::factory();
        $tpl->setVariable( 'factory_identifier', $this->configuration['identifier'] );
        $tpl->setVariable( 'factory_configuration', $this->getConfiguration() );
        $tpl->setVariable( 'template_directory', $this->getTemplateDirectory() );
        $tpl->setVariable( 'view_parameters', $parameters );
        $tpl->setVariable( 'post_count', 0);
        $tpl->setVariable( 'posts', array());
        $tpl->setVariable( 'states', $this->states() );
        $tpl->setVariable( 'site_title', false );
        return $tpl;
    }

    protected function editModuleResultTemplate( $currentPost, $parameters, OCEditorialStuffHandlerInterface $handler, eZModule $module )
    {
        if ( isset( $this->configuration['UiContext'] ) && is_string( $this->configuration['UiContext'] ) )
            $module->setUIContextName( $this->configuration['UiContext'] );
        $tpl = eZTemplate::factory();
        $tpl->setVariable( 'persistent_variable', false );
        $tpl->setVariable( 'factory_identifier', $this->configuration['identifier'] );
        $tpl->setVariable( 'factory_configuration', $this->getConfiguration() );
        $tpl->setVariable( 'template_directory', $this->getTemplateDirectory() );
        $tpl->setVariable( 'post', $currentPost );
        $tpl->setVariable( 'site_title', false );
        return $tpl;
    }

    public function editModuleResult( $parameters, OCEditorialStuffHandlerInterface $handler, eZModule $module )
    {
        $currentPost = $this->getModuleCurrentPost( $parameters, $handler, $module );
        if ( !$currentPost instanceof OCEditorialStuffPostInterface )
        {
            return $currentPost;
        }
        $tpl = $this->editModuleResultTemplate( $currentPost, $parameters, $handler, $module );

        $Result = array();
        $Result['content'] = $tpl->fetch( "design:{$this->getTemplateDirectory()}/edit.tpl" );
        $contentInfoArray = array( 'url_alias' => 'editorialstuff/dashboard' );
        $contentInfoArray['persistent_variable'] = array(
            'show_path' => true,
            'site_title' => 'Edit ' . $currentPost->getObject()->attribute( 'name' )
        );
        if ( is_array( $tpl->variable( 'persistent_variable' ) ) )
        {
            $contentInfoArray['persistent_variable'] = array_merge( $contentInfoArray['persistent_variable'], $tpl->variable( 'persistent_variable' ) );
        }
        if ( isset( $this->configuration['PersistentVariable'] ) && is_array( $this->configuration['PersistentVariable'] ) )
        {
            $contentInfoArray['persistent_variable'] = array_merge( $contentInfoArray['persistent_variable'], $this->configuration['PersistentVariable'] );
        }
        $Result['content_info'] = $contentInfoArray;
        $Result['path'] = array(
            array( 'url' => 'editorialstuff/dashboard/' . $this->configuration['identifier'],
                'text' => isset( $this->configuration['Name'] ) ? $this->configuration['Name'] : 'Dashboard'
            )
        );
        if ( $currentPost instanceof OCEditorialStuffPostInterface )
        {
            $Result['path'][] = array(
                'url' => false,
                'text' => $currentPost->getObject()->attribute( 'name' )
            );
        }
        return $Result;
    }
}