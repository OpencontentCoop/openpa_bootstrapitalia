<?php

use Aws\S3\Exception\S3Exception;
use Aws\S3\S3Client;

class S3StaticCache implements ezpStaticCache
{
    /**
     * An array with URLs that is to always be updated.
     *
     * @var array(int=>string)
     */
    private $alwaysUpdate;

    private $enableRefresh;

    private $alwaysUpdatedCacheRegistered = [];

    private $maxCacheDepth;

    private $cachedURLArray;

    private $staticStorageDir;

    private static $actionList = [];

    private $siteAccess;

    private static $cleanup = false;

    public function __construct()
    {
        $ini = eZINI::instance('staticcache.ini');
        $this->alwaysUpdate = $ini->variable('CacheSettings', 'AlwaysUpdateArray');
        $this->enableRefresh = $ini->hasVariable('CacheSettings', 'EnableRefresh')
            && $ini->variable('CacheSettings', 'EnableRefresh') == 'enabled';
        $this->cachedURLArray = $ini->variable('CacheSettings', 'CachedURLArray') ?? ['/*'];
        $this->maxCacheDepth = $ini->variable('CacheSettings', 'MaxCacheDepth');
        $this->siteAccess = OpenPABase::getFrontendSiteaccessName();
        $this->staticStorageDir = eZSiteAccess::getIni($this->siteAccess)->variable('SiteSettings', 'SiteURL');
    }

    private static function buildClientSettings()
    {
        $ini = eZINI::instance('staticcache.ini');
        $s3Settings = $ini->group('S3CacheHandler');

        $region = $s3Settings['Region'] ?? 'eu-west-1';

        $args = [
            'region' => $region,
            'version' => 'latest',
        ];
        if (!empty($s3Settings['Endpoint'])) {
            $args['endpoint'] = $s3Settings['Endpoint'];
        }
        if (!empty($s3Settings['UsePathStyleEndpoint'])) {
            $args['use_path_style_endpoint'] = $s3Settings['UsePathStyleEndpoint'] == 'enabled';
        }

        return [
            'client_args' => $args,
            'acl' => 'public-read',
            'bucket' => $s3Settings['Bucket'] ?? 'static',
        ];
    }

    private static function buildClient($settings): S3Client
    {
        $sdk = new Aws\Sdk($settings['client_args']);
        return $sdk->createS3();
    }

    private function storeCache($url, $alternativeStaticLocations = [], $skipUnlink = false, $delay = true)
    {
        self::log('info', '[S3StaticCache] Store cache ' . $url);
        $dirs = [
            [
                [
                    'dir' => '',
                    'access_name' => $this->siteAccess,
                    'site_url' => eZSiteAccess::getIni($this->siteAccess)->variable('SiteSettings', 'SiteURL'),
                ],
            ],
        ];
        foreach ($dirs as $dirParts) {
            foreach ($dirParts as $dirPart) {
                $dir = $dirPart['dir'];
                $siteURL = $dirPart['site_url'];
                $cacheFiles = [];
                $cacheFiles[] = $this->buildCacheFilename($dir . $url);
                foreach ($alternativeStaticLocations as $location) {
                    $cacheFiles[] = $this->buildCacheFilename($dir . $location);
                }

                // Store new content
                foreach ($cacheFiles as $file) {
                    if (!$skipUnlink || !self::cachedFileExists($file)) {
                        $currentUrl = "$dir$url";
                        if ($delay) {
                            $this->addAction('store', [$file, $currentUrl]);
                        } else {
                            $currentContent = self::generateContent($currentUrl);
                            if ($currentContent === false) {
                                self::log(
                                    'error',
                                    "Could not grab content (from $currentUrl), is the hostname correct and Apache running?"
                                );
                            } else {
                                self::storeCachedFile($file, $currentContent);
                            }
                        }
                    }
                }
            }
        }
    }

    public static function generateContent($url)
    {
        $siteAccess = OpenPABase::getFrontendSiteaccessName();
        $cmd = "php extension/openpa_bootstrapitalia/bin/php/generate_content.php --allow-root-user --url=\"$url\" -s$siteAccess";
        $content = shell_exec($cmd);
        $content = str_replace('Running scripts as root may be dangerous.', '', $content);
        return $content;
    }

    private function buildCacheFilename($url)
    {
        $file = "{$this->staticStorageDir}{$url}/index.html";
        return preg_replace('#//+#', '/', $file);
    }

    public function generateAlwaysUpdatedCache($quiet = false, $cli = false, $delay = true)
    {
        if ($this->enableRefresh) {
            if (!empty($this->alwaysUpdate)) {
                self::log('info', '[S3StaticCache] Refresh path ' . implode(', ', $this->alwaysUpdate));
            }
            foreach ($this->alwaysUpdate as $url) {
                if (!isset($this->alwaysUpdatedCacheRegistered[$url])) {
                    $this->alwaysUpdatedCacheRegistered[$url] = true;
                    if (!$quiet and $cli) {
                        $cli->output("caching: $url ", false);
                    }
                    $this->storeCache($url, [], false, $delay);
                    if (!$quiet and $cli) {
                        $cli->output("done");
                    }
                }
            }
        }
    }

    public function generateNodeListCache($nodeList): bool
    {
        if (!empty($nodeList)) {
            $cleanupValue = eZContentCache::calculateCleanupValue(count($nodeList));
            $doClearNodeList = eZContentCache::inCleanupThresholdRange($cleanupValue);
            if ($doClearNodeList) {
                $nodeIdList = [];
                foreach ($nodeList as $uri) {
                    if (is_array($uri)) {
                        if (!isset($uri['node_id'])) {
                            self::log('error',
                                sprintf(
                                    "node_id is not set for uri entry %s , will need to perform extra query to get node_id",
                                    var_export($uri, true)
                                )
                            );
                            $node = eZContentObjectTreeNode::fetchByURLPath($uri['path_identification_string']);
                            $nodeID = (int)$node->attribute('node_id');
                        } else {
                            $nodeID = (int)$uri['node_id'];
                        }
                    } else {
                        $nodeID = (int)$uri;
                    }
                    if ($nodeID > 1) {
                        $nodeIdList[] = $nodeID;
                    }
                    /** @var eZURLAliasML[] $elements */
                    $elements = eZURLAliasML::fetchByAction('eznode', $nodeID, true, true, true);
                    foreach ($elements as $element) {
                        $path = $element->getPath();
                        $this->cacheURL('/' . $path);
                    }
                }
                self::log('info', '[S3StaticCache] Generate cache for content nodes: ' . implode(', ', $nodeIdList));
            } else {
                $this->generateCache(true);
                self::log('info', '[S3StaticCache] Generate all cache');
            }
        }
        return true;
    }

    public function generateCache($force = false, $quiet = false, $cli = false, $delay = true)
    {
        self::log('info', '[S3StaticCache] Clear all cache');
        $staticURLArray = $this->cachedURLArray;

        // This contains parent elements which must checked to find new urls and put them in $generateList
        // Each entry contains:
        // - url - Url of parent
        // - glob - A glob string to filter direct children based on name
        // - org_url - The original url which was requested
        // - parent_id - The element ID of the parent (optional)
        // The parent_id will be used to quickly fetch the children, if not it will use the url
        $parentList = [];
        // A list of urls which must generated, each entry is a string with the url
        $generateList = [];
        foreach ($staticURLArray as $url) {
            if (strpos($url, '*') === false) {
                $generateList[] = $url;
            } else {
                $queryURL = ltrim(str_replace('*', '', $url), '/');
                $dir = dirname($queryURL);
                if ($dir == '.') {
                    $dir = '';
                }
                $glob = basename($queryURL);
                $parentList[] = [
                    'url' => $dir,
                    'glob' => $glob,
                    'org_url' => $url,
                ];
            }
        }

        // As long as we have urls to generate or parents to check we loop
        while (count($generateList) > 0 || count($parentList) > 0) {
            // First generate single urls
            foreach ($generateList as $generateURL) {
                if (!$quiet and $cli) {
                    $cli->output("caching: $generateURL ", false);
                }
                $this->cacheURL($generateURL, false, !$force, $delay);
                if (!$quiet and $cli) {
                    $cli->output("done");
                }
            }
            $generateList = [];

            // Then check for more data
            $newParentList = [];
            foreach ($parentList as $parentURL) {
                if (isset($parentURL['parent_id'])) {
                    /** @var eZURLAliasML[] $elements */
                    $elements = eZURLAliasML::fetchByParentID($parentURL['parent_id'], true, true, false);
                } else {
                    if (!$quiet and $cli and $parentURL['glob']) {
                        $cli->output("wildcard cache: " . $parentURL['url'] . '/' . $parentURL['glob'] . "*");
                    }
                    /** @var eZURLAliasML[] $elements */
                    $elements = eZURLAliasML::fetchByPath($parentURL['url'], $parentURL['glob']);
                }
                foreach ($elements as $element) {
                    $path = '/' . $element->getPath();
                    $generateList[] = $path;
                    $newParentList[] = ['parent_id' => $element->attribute('id')];
                }
            }
            $parentList = $newParentList;
        }
    }

    public function cacheURL($url, $nodeID = false, $skipExisting = false, $delay = true): bool
    {
        if ($this->enableRefresh && !isset($this->alwaysUpdatedCacheRegistered[$url])) {
            if (substr_count($url, "/") >= $this->maxCacheDepth) {
                return false;
            }
            $doCacheURL = false;
            foreach ($this->cachedURLArray as $cacheURL) {
                if ($url == $cacheURL) {
                    $doCacheURL = true;
                    break;
                } else {
                    if (strpos($cacheURL, '*') !== false) {
                        if (strpos($url, str_replace('*', '', $cacheURL)) === 0) {
                            $doCacheURL = true;
                            break;
                        }
                    }
                }
            }

            if (!$doCacheURL) {
                return false;
            }

            $this->storeCache(
                $url,
                [],
                $skipExisting,
                $delay
            );

            if (in_array($url, $this->alwaysUpdate)) {
                $this->alwaysUpdatedCacheRegistered[$url] = true;
            }
            return true;
        }

        return false;
    }

    public function removeURL($url)
    {
        self::log('info', '[S3StaticCache] Remove path ' . $url);
        //$dir = eZDir::path([$this->staticStorageDir, $url]);

        //@unlink($dir . "/index.html");
        //@rmdir($dir);
    }

    private function addAction($action, $parameters)
    {
        self::$actionList[] = [$action, $parameters];
        self::addCleanupAction();
    }

    private static function addCleanupAction()
    {
        if (!self::$cleanup) {
            \eZExecution::addCleanupHandler(['S3StaticCache', 'executeActions']);
        }
    }

    static function executeActions()
    {
        if (empty(self::$actionList)) {
            return;
        }

        $fileContentCache = [];
        $doneDestList = [];

//        $ini = eZINI::instance('staticcache.ini');
//        $clearByCronjob = ($ini->variable('CacheSettings', 'CronjobCacheClear') == 'enabled');
        $clearByCronjob = true;

        if ($clearByCronjob) {
            $db = eZDB::instance();
        }

        foreach (self::$actionList as $action) {
            [$action, $parameters] = $action;

            switch ($action) {
                case 'store':
                    [$destination, $source] = $parameters;

                    if (isset($doneDestList[$destination])) {
                        continue 2;
                    }

                    if ($clearByCronjob) {
                        $param = $db->escapeString($destination . ',' . $source);
                        $db->query(
                            'INSERT INTO ezpending_actions( action, param ) VALUES ( \'static_store\', \'' . $param . '\' )'
                        );
                        $doneDestList[$destination] = 1;
                    } else {
                        if (!isset($fileContentCache[$source])) {
                            $fileContentCache[$source] = self::generateContent($source);
                        }
                        if ($fileContentCache[$source] === false) {
                            self::log('error',
                                "Could not grab content (from $source), is the hostname correct and Apache running?"
                            );
                        } else {
                            self::storeCachedFile($destination, $fileContentCache[$source]);
                            $doneDestList[$destination] = 1;
                        }
                    }
                    break;
            }
        }
        self::$actionList = [];
    }

    static function cachedFileExists($file): bool
    {
        $settings = self::buildClientSettings();
        try {
            return self::buildClient($settings)->doesObjectExist($settings['bucket'], $file);
        } catch (S3Exception $e) {
            self::log('error', $e->getMessage());
            return false;
        }
    }

    static function storeCachedFile($file, $content): bool
    {
        self::log('info', '[S3StaticCache] Store cache file ' . $file);
        $settings = self::buildClientSettings();
        try {
            self::buildClient($settings)->upload($settings['bucket'], $file, $content, $settings['acl']);
            return true;
        } catch (S3Exception $e) {
            self::log('error', $e->getMessage());
            return false;
        }
    }

    private static function log($level, $message, array $context = [])
    {
        $instance = OpenPABase::getCurrentSiteaccessIdentifier();
        eZLog::write("[$level] [$instance] $message", 's3staticcache.log');
    }
}