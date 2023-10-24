<?php

use Aws\S3\Exception\S3Exception;
use Aws\S3\S3Client;

class BootstrapItaliaSharedAssetsHandler implements ezjscSharedHandler
{
    private $settings;

    private $protocol = 'https';

    private $httpHost;

    private $bucket;

    private $prefix;

    private $acl = 'public-read';

    public function __construct()
    {
        $this->settings = eZINI::instance('ezjscore.ini')->group('CustomAssetsServer');
        $this->httpHost = 's3-' . $this->settings['Region'] . '.amazonaws.com';
        if (isset($this->settings['ServerUri'])) {
            $this->httpHost = $this->settings['ServerUri'];
        }
        $this->bucket = $this->settings['Bucket'];
        $this->prefix = rtrim($this->settings['Prefix'], '/');
    }

    public function packFiles($data, $subPath)
    {
        $mainDesign = eZINI::instance()->variable('DesignSettings', 'SiteDesign');
        $data['cache_dir'] = "compiled/$mainDesign/";

        $data['cache_hash'] = md5($data['cache_name'] . $data['pack_level']) .
            $data['file_post_name'] . $data['file_extension'];
        $data['cache_path'] = $data['cache_dir'] . $subPath . $data['cache_hash'];

        if (!$this->cachedFileExists($data['cache_path'])) {
            $content = $this->compileAssets($data);
            $this->storeCachedFile($data['cache_path'] . '.json', json_encode($data['locale']), false);
            $this->storeCachedFile($data['cache_path'], $content, $data['file_extension'] === '.css');
        }

        return [$this->applyServerUrl($data['cache_path'])];
    }

    private function buildClient(): S3Client
    {
        $region = $this->settings['Region'] ?? 'eu-west-1';
        $args = [
            'region' => $region,
            'version' => 'latest',
        ];
        if (!empty($this->settings['Endpoint'])) {
            $args['endpoint'] = $this->settings['Endpoint'];
        }
        if (!empty($this->settings['UsePathStyleEndpoint'])) {
            $args['use_path_style_endpoint'] = $this->settings['UsePathStyleEndpoint'] == 'enabled';
        }
        $sdk = new Aws\Sdk($args);
        return $sdk->createS3();
    }

    private function cachedFileExists($fileName): bool
    {
        try {
            return $this->buildClient()->doesObjectExist($this->bucket, $this->prefix . '/' . $fileName);
        } catch (S3Exception $e) {
            eZDebug::writeError('error', $e->getMessage());
            return false;
        }
    }

    private function storeCachedFile($fileName, $content, $asCss): bool
    {
        try {
            $this->buildClient()->upload($this->bucket, $this->prefix . '/' . $fileName, $content, $this->acl, [
                'params' => ['ContentType' => $asCss ? 'text/css' : 'text/javascript'],
            ]);
            return true;
        } catch (S3Exception $e) {
            eZDebug::writeError('error', $e->getMessage());
            return false;
        }
    }

    private function compileAssets($data)
    {
        $content = '';
        $isCSS = $data['file_extension'] === '.css';
        foreach ($data['locale'] as $i => $file) {
            // if this is a js / css generator, call to get content
            if ($file instanceof ezjscServerRouter) {
                $content .= $file->call($data['locale']);
                continue;
            } else {
                if (!$file) {
                    continue;
                }
            }

            // else, get content of normal file
            $fileContent = file_get_contents($file);

            if (!trim($fileContent)) {
                $content .= "/* empty: $file */\r\n";
                continue;
            }

            if ($isCSS) {
                // We need to fix relative background image paths if this is a css file
                $fileContent = $this->fixImgPaths($fileContent, $file);
                // Remove @charset if this is not the first file (some browsers will ignore css after a second occurance of this)
                if ($i) {
                    $fileContent = preg_replace('/^@charset[^;]+;/i', '', $fileContent);
                }
            }

            $content .= "/* start: $file */\r\n";
            $content .= $fileContent;
            $content .= "\r\n/* end: $file */\r\n\r\n";
        }

        if ($data['pack_level'] > 1) {
            $ezjscINI = eZINI::instance('ezjscore.ini');
            $isCSS = $data['file_extension'] === '.css';
            foreach ($ezjscINI->variable('eZJSCore', $isCSS ? 'CssOptimizer' : 'JavaScriptOptimizer') as $optimizer) {
                if (is_callable([$optimizer, 'optimize'])) {
                    $content = call_user_func([$optimizer, 'optimize'], $content, $data['pack_level']);
                } else {
                    eZDebug::writeWarning("Could not call optimizer '{$optimizer}'", __METHOD__);
                }
            }
        }

        return $content;
    }

    /**
     * Fix image paths in css.
     *
     * @param string $fileContent Css string
     * @param string $file File incl path to calculate relative paths from.
     * @return string
     */
    private function fixImgPaths($fileContent, $file)
    {
        if (preg_match_all(
            "/url\(\s*[\'|\"]?([A-Za-z0-9_\-\/\.\\%?&@#=]+)[\'|\"]?\s*\)/ix",
            $fileContent,
            $urlMatches
        )) {
            $urlPaths = [];
            $urlMatches = array_unique($urlMatches[1]);
            $cssPathArray = explode('/', $file);
            $wwwDir = eZSys::wwwDir() . '/';
            // Pop the css file name
            array_pop($cssPathArray);
            $cssPathCount = count($cssPathArray);
            foreach ($urlMatches as $match) {
                $match = str_replace('\\', '/', $match);
                $relativeCount = substr_count($match, '../');
                // Replace path if it is relative
                if ($match[0] !== '/' and strpos($match, 'http:') === false) {
                    $cssPathSlice = $relativeCount === 0 ? $cssPathArray : array_slice(
                        $cssPathArray,
                        0,
                        $cssPathCount - $relativeCount
                    );
                    $newMatchPath = $wwwDir . $this->bucket . $this->prefix . '/';
                    if (!empty($cssPathSlice)) {
                        $newMatchPath .= implode('/', $cssPathSlice) . '/';
                    }
                    $newMatchPath .= str_replace('../', '', $match);
                    $urlPaths[$match] = $newMatchPath;
                }
            }
            $fileContent = strtr($fileContent, $urlPaths);
        }
        return $fileContent;
    }

    public function applyServerUrl($filePath)
    {
        if ($this->settings['UseCustomAssetsServer'] !== 'enabled'){
            return $filePath;
        }

        return sprintf(
            '%s://%s/%s/%s',
            $this->protocol,
            $this->httpHost,
            ltrim($this->prefix, '/'),
            ltrim($filePath, '/')
        );
    }
}
