<?php

use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;

class PersonalAreaLogin
{
    use SiteDataStorageTrait;

    private static $instance = [];

    private $accesses;

    /**
     * @var string
     */
    private $uri;

    private $resetLogs = [];

    public static function instance()
    {
        $locale = eZLocale::currentLocaleCode();
        if (!isset(self::$instance[$locale])) {
            self::$instance[$locale] = new PersonalAreaLogin();
        }

        return self::$instance[$locale];
    }

    public function __clone()
    {
        $this->uri = null;
        $this->resetLogs = [];
    }

    public function getUri(): ?string
    {
        if ($this->uri === null) {
            $this->discoverUri();
        }

        return $this->uri;
    }

    public function setUri(?string $uri)
    {
        $this->uri = $uri;
    }

    private function discoverUri()
    {
        $pagedata = new \OpenPAPageData();
        $contacts = $pagedata->getContactsData();
        $this->setUri($contacts['link_area_personale'] ?? false);
    }

    public function resetUriTo(string $uri, $dryRun = true): array
    {
        $this->resetLogs = [];
        $currentUri = $this->getUri();
        $this->resetLogs['before_access_url'] = $currentUri;
        $this->resetLogs['after_access_url'] = $uri;

        $this->updateContactsValue($uri, $dryRun);

        $new = clone $this;
        $new->setUri($uri);
        $this->updateLinks($this, $new, $dryRun);

        $this->setUri($uri);

        if (!$dryRun) {
            OpenPAPageData::clearOnModifyHomepage();
        }
        $this->resetLogs['is_dry_run'] = $dryRun;

        return $this->resetLogs;
    }

    private function updateContactsValue(string $uri, bool $dryRun)
    {
        $contentRepository = new ContentRepository();
        $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));

        $home = OpenPaFunctionCollection::fetchHome()->object();
        $content = Content::createFromEzContentObject($home);
        $payload = new PayloadBuilder();
        $payload->setId($home->attribute('id'));
        $locales = [];
        foreach ($content->data as $locale => $data) {
            $locales[] = $locale;
            foreach ($data as $identifier => $value) {
                if ($identifier === 'contacts') {
                    $contactsValue = $value['content'];
                    foreach ($contactsValue as $index => $contact) {
                        if ($contact['media'] === 'Link area personale') {
                            $contactsValue[$index]['value'] = $uri;
                        }
                    }

                    $payload->setData($locale, $identifier, $contactsValue);
                }
            }
        }
        $payload->setLanguages($locales);
        $this->resetLogs['update_payload'] = json_encode($payload);
        if (!$dryRun) {
            try {
                $contentRepository->update($payload->getArrayCopy(), true);
                return;
            } catch (Throwable $e) {
                $this->resetLogs['update_error'] = $e->getMessage();
            }
        }
    }

    private function updateLinks(PersonalAreaLogin $before, PersonalAreaLogin $after, bool $dryRun)
    {
        $this->resetLogs['url_need_execution'] = false;

        try {
            $from = StanzaDelCittadinoBridge::instanceByPersonalAreaLogin($before)->getApiBaseUri();
            $to = StanzaDelCittadinoBridge::instanceByPersonalAreaLogin($after)->getApiBaseUri();
            $this->resetLogs['url_modifier'] = "$from -> $to";

            if (!empty($from) && !empty($to) && $from !== $to) {
                $fromCondition = "{$from}%";
                $query = "select * from ezurl where url like '{$fromCondition}';";
                $this->resetLogs['url_query'] = $query;
                $this->resetLogs['url_modified_list'] = [];
                $this->resetLogs['url_not_found_list'] = [];
                $rows = eZDB::instance()->arrayQuery($query);
                foreach ($rows as $row) {
                    $url = eZURL::fetch($row['id']);
                    $newUrl = str_replace($from, $to, $row['url']);
                    $newUrlMd5 = md5($newUrl);
                    $this->resetLogs['url_modified_list'][] = $row['url'] . ' -> ' . $newUrl;
                    if ($url instanceof eZURL) {
                        if (!$dryRun) {
                            $url->setAttribute('url', $newUrl);
                            $url->setAttribute('original_url_md5', $newUrlMd5);
                            $url->store();
                        }
                    } else {
                        $this->resetLogs['url_not_found_list'][] = $row['url'];
                    }
                }
                $this->resetLogs['url_need_execution'] = true;
            }
        }catch (Throwable $e){
            $this->resetLogs['url_error'] = $e->getMessage();
        }
    }

    public function hasAccess(string $key): bool
    {
        if ($key === 'spid'){
            return true;
        }
        $this->loadAccesses();
        return $this->accesses[$key] ?? false;
    }

    public function setAccess(string $key, bool $access): void
    {
        $this->accesses[$key] = $access;
    }

    private function loadAccesses()
    {
        if ($this->accesses === null) {
            $data = json_decode($this->getStorage('pal_accesses'), true);
            if (empty($data)) {
                $data = [
                    'spid' => true,
                    'cie' => false,
                    'eidas' => false,
                ];
            }
            $this->accesses = $data;
        }
    }
    public function storeAccesses()
    {
        $this->setStorage('pal_accesses', json_encode($this->accesses));
    }
}