<?php

class ContentSecurityPolicyHandler
{
    private const TYPE_SRC_LIST_NOFB = 'source-list-no-fallback';

    private const TYPE_MEDIA_TYPE_LIST = 'media-type-list';

    private const TYPE_ANCESTOR_SRC_LIST = 'ancestor-source-list';

    private const TYPE_URI_REFERENCE = 'uri-reference';

    private const TYPE_NO_VALUE = 'no-value';

    private const TYPE_SRC_LIST = 'source-list';

    private const TYPE_REPORTING_GROUP = 'reporting-group';

    private static $directiveNames = [
        'default-src' => self::TYPE_SRC_LIST,
        'base-uri' => self::TYPE_SRC_LIST_NOFB,
        'block-all-mixed-content' => self::TYPE_NO_VALUE,
        'child-src' => self::TYPE_SRC_LIST,
        'connect-src' => self::TYPE_SRC_LIST,
        'font-src' => self::TYPE_SRC_LIST,
        'form-action' => self::TYPE_SRC_LIST_NOFB,
        'frame-ancestors' => self::TYPE_ANCESTOR_SRC_LIST,
        'frame-src' => self::TYPE_SRC_LIST,
        'img-src' => self::TYPE_SRC_LIST,
        'manifest-src' => self::TYPE_SRC_LIST,
        'media-src' => self::TYPE_SRC_LIST,
        'object-src' => self::TYPE_SRC_LIST,
        'plugin-types' => self::TYPE_MEDIA_TYPE_LIST,
        'script-src' => self::TYPE_SRC_LIST,
        'style-src' => self::TYPE_SRC_LIST,
        'upgrade-insecure-requests' => self::TYPE_NO_VALUE,
        'report-uri' => self::TYPE_URI_REFERENCE,
        'worker-src' => self::TYPE_SRC_LIST,
        'prefetch-src' => self::TYPE_SRC_LIST,
        'report-to' => self::TYPE_REPORTING_GROUP,
    ];

    private $directiveValues = [];

    private function __construct(array $config)
    {
        $parser = new ContentSecurityPolicyParser();
        foreach (self::$directiveNames as $name => $type) {
            if (!\array_key_exists($name, $config)) {
                continue;
            }

            $this->setDirective($name, $parser->parseSourceList($config[$name]));
        }
    }

    private function setDirective(string $name, $value): void
    {
        $this->checkDirectiveName($name);
        if (self::TYPE_NO_VALUE === self::$directiveNames[$name]) {
            if (true === $value) {
                $this->directiveValues[$name] = true;
            } else {
                unset($this->directiveValues[$name]);
            }
        } elseif ('' !== $value) {
            $this->directiveValues[$name] = $value;
        } else {
            unset($this->directiveValues[$name]);
        }
    }

    private function getAvailableDirective(): array
    {
        return [
            // level 1
            'default-src',
            'connect-src',
            'font-src',
            'frame-src',
            'img-src',
            'media-src',
            'object-src',
            'sandbox',
            'script-src',
            'style-src',
            'report-uri',

            // level 2
            'base-uri',
            'child-src',
            'form-action',
            'frame-ancestors',
            'plugin-types',

            // level 3
            'manifest-src',
            'reflected-xss',
            'worker-src',
            'prefetch-src',
            'report-to',

            // draft
            'block-all-mixed-content',
            'upgrade-insecure-requests',
        ];
    }

    private function checkDirectiveName(string $name): void
    {
        if (!array_key_exists($name, self::$directiveNames)) {
            throw new InvalidArgumentException('Unknown CSP directive name: ' . $name);
        }
    }

    private function getDirective(string $name)
    {
        $this->checkDirectiveName($name);

        if (array_key_exists($name, $this->directiveValues)) {
            return $this->directiveValues[$name];
        }

        return '';
    }

    private function canNotBeFallbackByDefault(string $name, string $value): bool
    {
        if ('default-src' === $name) {
            return true;
        }

        // Only source-list can be fallbacked by default
        if (self::TYPE_SRC_LIST !== self::$directiveNames[$name]) {
            return true;
        }

        // let's fallback if directives are strictly equals
        return $value !== $this->getDirective('default-src');
    }

    private function buildHeaderValue(): string
    {
        $policy = [];

        $availableDirectives = $this->getAvailableDirective();

        foreach ($this->directiveValues as $name => $value) {
            if (!in_array($name, $availableDirectives, true)) {
                continue;
            }
            if (true === $value) {
                $policy[] = $name;
            } elseif ($this->canNotBeFallbackByDefault($name, $value)) {
                $policy[] = $name . ' ' . $value;
            }
        }

        return implode('; ', $policy);
    }

    public static function getCspDirectives(): array
    {
        $cspIni = eZINI::instance('csp.ini');

        $autoEmbeds = [];
        if ($cspIni->variable('Settings', 'AutoEmbedStanzaDelCittadinoTenant') === 'enabled') {
            $stanzaDelCittadinoHost = StanzaDelCittadinoBridge::factory()->getHost();
            if (!empty($stanzaDelCittadinoHost)) {
                $directives = (array)$cspIni->variable(
                    'Settings',
                    'AutoEmbedStanzaDelCittadinoTenantDirectives'
                );
                foreach ($directives as $directive) {
                    $autoEmbeds[$directive][] = 'https://' . $stanzaDelCittadinoHost;
                }
            }
        }

        if ($cspIni->variable('Settings', 'AutoEmbedPerformanceMonitor') === 'enabled') {
            $sentryScriptLoader = OpenPABootstrapItaliaOperators::getSentryScriptLoader();
            if (!empty($sentryScriptLoader)) {
                $sentryScriptLoaderHost = parse_url($sentryScriptLoader, PHP_URL_HOST);
                if (!$sentryScriptLoaderHost) {
                    $directives = (array)$cspIni->variable(
                        'Settings',
                        'AutoEmbedPerformanceMonitorDirectives'
                    );
                    foreach ($directives as $directive) {
                        $autoEmbeds[$directive][] = '*.' . $sentryScriptLoaderHost;
                    }
                }
            }
        }
        $contentSecurityPolicy = [];
        if ($cspIni->variable('Settings', 'ContentSecurityPolicy') === 'enabled') {
            $contentSecurityPolicy = array_merge_recursive(
                $cspIni->group('ContentSecurityPolicy'),
                $autoEmbeds
            );
        }

        $contentSecurityPolicyReportOnly = [];
        if ($cspIni->variable('Settings', 'ContentSecurityPolicyReportOnly') === 'enabled') {
            $contentSecurityPolicyReportOnly = array_merge_recursive(
                $cspIni->group('ContentSecurityPolicyReportOnly'),
                $autoEmbeds
            );
        }

        return [
            'Content-Security-Policy' => $contentSecurityPolicy,
            'Content-Security-Policy-Report-Only' => $contentSecurityPolicyReportOnly,
        ];
    }

    public static function setCspHeaders($templateResult)
    {
        $directives = self::getCspDirectives();
        if (!empty($directives['Content-Security-Policy'])) {
            $contentSecurityPolicyHeader = (new self($directives['Content-Security-Policy']))->buildHeaderValue();
            header('Content-Security-Policy: ' . $contentSecurityPolicyHeader);
        }
        if (!empty($directives['Content-Security-Policy-Report-Only'])) {
            $contentSecurityPolicyReportOnlyHeader = (new self($directives['Content-Security-Policy-Report-Only']))->buildHeaderValue();
            header('Content-Security-Policy-Report-Only: ' . $contentSecurityPolicyReportOnlyHeader);
        }

        return $templateResult;
    }
}