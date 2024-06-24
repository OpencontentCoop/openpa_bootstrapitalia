<?php

class BootstrapItaliaImage
{
    private static $instance;

    /**
     * @var string
     */
    private $flyImgBaseUrl;

    /**
     * @var string
     */
    private $backendBaseUrl;

    /**
     * @var string
     */
    private $backendBaseScheme;

    /**
     * @var string
     */
    private $defaultFilter;

    /**
     * @var eZTemplate
     */
    private $templateEngine;

    private function __construct(?eZTemplate $tpl = null)
    {
        $this->templateEngine = $tpl ?? eZTemplate::factory();
        $this->flyImgBaseUrl = rtrim(OpenPAINI::variable('ImageSettings', 'FlyImgBaseUrl', ''), '/');
        $this->backendBaseUrl = OpenPAINI::variable('ImageSettings', 'BackendBaseUrl', '');
        $this->backendBaseScheme = OpenPAINI::variable('ImageSettings', 'BackendBaseScheme', '');
        $this->defaultFilter = OpenPAINI::variable('ImageSettings', 'FlyImgDefaultFilter', '');
    }

    public static function instance(?eZTemplate $tpl = null): BootstrapItaliaImage
    {
        if (self::$instance === null) {
            self::$instance = new BootstrapItaliaImage($tpl);
        }
        return self::$instance;
    }

    public function process($url, array $parameters): array
    {
//        eZDebug::writeDebug(var_export($parameters, true), __METHOD__);
        $defaultAlias = 'reference';
        $parameters = array_merge([
            'context' => 'default',
            'info' => null,
            'alias' => 'reference',
            'alias_url' => null,
            'alias_info' => null,
            'preload' => null,
        ], $parameters);

        if ($url instanceof eZImageAliasHandler) {
            if (empty($this->flyImgBaseUrl) && $parameters['alias'] !== $defaultAlias) {
                $aliasInfo = $url->attribute($parameters['alias']);
                $parameters['alias_info'] = $aliasInfo;
                $alias = $aliasInfo['full_path'];
                eZURI::transformURI($alias, true, 'full');
                $parameters['alias_url'] = $alias;
            }

            $info = $url->attribute($defaultAlias);
            $parameters['info'] = $info;
            $url = $info['full_path'];
            eZURI::transformURI($url, true, 'full');
        }

        if (strpos($url, 'http') === false){
            eZURI::transformURI($url, true, 'full');
        }

        $processUrl = $this->prefixUrl($url, $parameters);
        if ($parameters['preload']) {
            ezjscPackerTemplateFunctions::setPersistentArray(
                'preload_images',
                $processUrl,
                $this->templateEngine,
                true
            );
        }
        return [
            'src' => $processUrl,
        ];
    }

    private function prefixUrl($url, array $parameters): string
    {
        if (!empty($this->flyImgBaseUrl)) {
            if (!empty($this->backendBaseUrl)) {
                $urlBase = parse_url($url, PHP_URL_HOST);
                $urlScheme = parse_url($url, PHP_URL_SCHEME);
                if (!empty($this->backendBaseScheme) && $urlScheme !== $this->backendBaseScheme) {
                    $url = str_replace($urlScheme, $this->backendBaseScheme, $url);
                }
                $url = str_replace($urlBase, $this->backendBaseUrl, $url);
            }

            $parts = [$this->flyImgBaseUrl];
            $parts[] = $this->generateFilters($parameters);
            $parts[] = urlencode($url);

            $url = implode('/', $parts);
        }

        return $parameters['alias_url'] ?? $url;
    }

    private function generateFilters(array $parameters): string
    {
        $filters = [];
        if (!empty($this->defaultFilter)) {
            $filters[] = $this->defaultFilter;
        }

        $alias = $parameters['alias'] ?? 'reference';
        switch ($alias){
            case 'reference':
                $filters[] = 'w_2500';
                $filters[] = 'h_2500';
                break;

            case 'large':
            case 'imagelargeoverlay':
                $filters[] = 'w_800';
                $filters[] = 'h_800';
                break;

            case 'medium':
                $filters[] = 'w_400';
                $filters[] = 'h_400';
                break;

            case 'small':
                $filters[] = 'w_200';
                $filters[] = 'h_200';
                break;

            case 'rss':
                $filters[] = 'w_100';
                $filters[] = 'h_100';
                break;
        }

        return implode(',', $filters);
    }

    public function getCssClassAndStyle(int $width, int $height, string $context = 'main'): array
    {
        $response = [
            'css_class' => '',
            'inline_style' => '',
            'can_enlarge' => true,
        ];
        switch ($context){
//            case 'card':
//                if ($height > 0 && (($width/$height) <= 1)){
//                    $response['css_class'] = 'of-contain bg-light';
//                }
//                break;
            case 'main':
                $response['inline_style'] = 'max-width: 2500px;width: 100%;';
                if ($height > 0 && ($width < 1440 || $height < 600 || ($width/$height) <= 0.7)){
                    $response['css_class'] = 'of-contain';
                    $response['can_enlarge'] = false;
                    $response['inline_style'] .= 'max-height: 600px;';
                }
                break;
        }

        return $response;
    }
}