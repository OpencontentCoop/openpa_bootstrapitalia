<?php

class ContentSecurityPolicyParser
{
    private $keywords = [
        'self',
        'unsafe-inline',
        'unsafe-eval',
        'wasm-unsafe-eval',
        'strict-dynamic',
        'unsafe-hashes',
        'report-sample',
        'unsafe-allow-redirects',
        'none',
    ];

    /**
     * @param list<string>|true $sourceList
     *
     * @return string|true
     */
    public function parseSourceList($sourceList)
    {
        if (!is_array($sourceList)) {
            return $sourceList;
        }

        $sourceList = $this->quoteKeywords($sourceList);

        return implode(' ', array_unique($sourceList));
    }

    /**
     * @param list<string> $sourceList
     *
     * @return list<string>
     */
    private function quoteKeywords(array $sourceList): array
    {
        $keywords = $this->keywords;

        return array_map(
            static function (string $source) use ($keywords) {
                if (in_array($source, $keywords, true)) {
                    return sprintf("'%s'", $source);
                }

                return $source;
            },
            $sourceList
        );
    }
}