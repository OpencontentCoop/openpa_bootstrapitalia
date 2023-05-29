<?php

class BootstrapItaliaTheme implements JsonSerializable
{
    private static $instances = [];

    private $identifier;

    private $baseIdentifier;

    private $variations;

    private $cssData;

    private function __construct($identifier)
    {
        $this->identifier = $identifier;
        $parts = explode('::', $identifier);
        $this->baseIdentifier = array_shift($parts);
        $path = ltrim(
            eZURLOperator::eZDesign(eZTemplate::factory(), "stylesheets/{$this->baseIdentifier}.css", 'ezdesign'),
            '/'
        );
        if (!file_exists($path)) {
            $this->baseIdentifier = 'default';
        }
        $this->variations = $parts;
    }

    public static function fromString($string)
    {
        if (empty($string)){
            return new BootstrapItaliaTheme($string);
        }
        if (!isset(self::$instances[$string])) {
            self::$instances[$string] = new BootstrapItaliaTheme($string);
        }

        return self::$instances[$string];
    }

    /**
     * @return mixed|string
     */
    public function getBaseIdentifier()
    {
        return $this->baseIdentifier;
    }

    /**
     * @return string
     */
    public function getIdentifier()
    {
        return $this->identifier;
    }

    /**
     * @return string[]
     */
    public function getVariations()
    {
        return $this->variations;
    }

    /**
     * @return bool
     */
    public function hasVariation($variation)
    {
        return in_array($variation, $this->variations);
    }

    /**
     * @param string $rule
     * @param string $fallback
     * @return array
     */
    public function getCssData($rule = null, $fallback = null)
    {
        $tpl = eZTemplate::factory();
        if ($this->cssData === null) {
            $this->cssData = [];
            $theme = $this->baseIdentifier;
            $path = ltrim(eZURLOperator::eZDesign($tpl, "stylesheets/{$theme}.css", 'ezdesign'), '/');
            if (!file_exists($path)) {
                $currentDesign = eZINI::instance()->variable('DesignSettings', 'SiteDesign');
                $path = "extension/openpa_bootstrapitalia/design/{$currentDesign}/stylesheets/default.css";
            }
            $this->cssData = $this->parseCss($path);
        }

        if ($rule) {
            switch ($rule) {
                case 'primary_color':
                    if (isset($this->cssData['.primary-bg']['background-color'])) {
                        $fallback = $this->cssData['.primary-bg']['background-color'];
                    }
                    break;
                case 'header_color':
                    $selector = '.it-header-center-wrapper';
                    if (in_array('light_center', $this->variations)){
                        $selector .= '.theme-light';
                    }
                    if (isset($this->cssData[$selector]['background'])) {
                        $fallback = $this->cssData[$selector]['background'];
                    }
                    break;
                case 'service_color':
                    $selector = '.it-header-slim-wrapper';
                    if (in_array('light_slim', $this->variations)){
                        $selector .= '.theme-light';
                    }
                    if (isset($this->cssData[$selector]['background'])) {
                        $fallback = $this->cssData[$selector]['background'];
                    }
                    break;
                case 'main_menu_color':
                    $selector = '.it-header-navbar-wrapper';
                    if (in_array('light_navbar', $this->variations)){
                        $selector .= '.theme-light-desk';
                    }
                    if (isset($this->cssData[$selector]['background'])) {
                        $fallback = $this->cssData[$selector]['background'];
                    }
                    break;
                case 'footer_color':
                    if (isset($this->cssData['.it-footer-small-prints']['background-color'])) {
                        $fallback = $this->cssData['.it-footer-small-prints']['background-color'];
                    }
                    break;
                case 'footer_main_color':
                    if (isset($this->cssData['.it-footer-main']['background-color'])) {
                        $fallback = $this->cssData['.it-footer-main']['background-color'];
                    }
                    break;
            }

            return str_replace(' !important', '', $fallback);
        }

        return $this->cssData;
    }

    /**
     * @param $file
     * @return array
     */
    private function parseCss($file)
    {
        $css = file_get_contents($file);
        preg_match_all('/(?ims)([a-z0-9\s\.\:#_\-@,]+)\{([^\}]*)\}/', $css, $arr);
        $result = array();
        foreach ($arr[0] as $i => $x) {
            $selector = trim($arr[1][$i]);
            $rules = explode(';', trim($arr[2][$i]));
            $rules_arr = array();
            foreach ($rules as $strRule) {
                if (!empty($strRule)) {
                    $rule = explode(":", $strRule);
                    if (isset($rule[1])) {
                        $rules_arr[trim($rule[0])] = trim($rule[1]);
                    }
                }
            }
            $selectors = explode(',', trim($selector));
            foreach ($selectors as $strSel) {
                if (isset($result[$strSel])){
                    $result[$strSel] = array_merge($result[$strSel], $rules_arr);
                }else {
                    $result[$strSel] = $rules_arr;
                }
            }
        }

        return $result;
    }

    public function jsonSerialize()
    {
        return [
            'identifier' => $this->getIdentifier(),
            'base' => $this->getBaseIdentifier(),
            'variations' => $this->getVariations(),
            'colors' => [
                'primary' => $this->getCssData('primary_color'),
                'header' => $this->getCssData('header_color'),
                'service' => $this->getCssData('service_color'),
                'main_menu' => $this->getCssData('main_menu_color'),
                'footer_main' => $this->getCssData('footer_main_color'),
                'footer' => $this->getCssData('footer_color'),
            ],
//            'css' => $this->getCssData(),
        ];
    }


}