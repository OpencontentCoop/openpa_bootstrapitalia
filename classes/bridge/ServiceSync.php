<?php

class ServiceSync
{
    private $service;

    private $client;

    private $info;

    private $errors;

    private $serviceList;

    private $categoryList;

    private static $syncNodeRemoteIdWithServiceUuid = false;

    private static $syncServiceName = false;

    private $localDomain;

    public function __construct(eZContentObjectTreeNode $service, StanzaDelCittadinoClient $client, $localDomain = null)
    {
        $this->service = $service;
        $this->client = $client;
        $this->localDomain = $localDomain ?? eZSiteAccess::getIni(OpenPABase::getFrontendSiteaccessName())->variable(
            'SiteSettings',
            'SiteURL'
        );
        StanzaDelCittadinoClient::$connectionTimeout = 10;
        StanzaDelCittadinoClient::$processTimeout = 10;
    }

    public function getInfo(): array
    {
        $this->collectInfo();
        return (array)$this->info;
    }

    public function getErrors(): array
    {
        $this->collectInfo();
        return (array)$this->errors;
    }

    private function collectInfo()
    {
        if ($this->info !== null) {
            return;
        }

        $object = $this->service->object();
        $dataMap = $object->dataMap();

        $this->info['name'] = $this->service->attribute('name');
        $this->info['node_id'] = $this->service->attribute('node_id');
        $this->info['object_id'] = $this->service->attribute('contentobject_id');
        $serviceIdentifier = '';
        if (isset($dataMap['identifier']) && $dataMap['identifier']->hasContent()) {
            $serviceIdentifier = trim($dataMap['identifier']->toString());
        }
        $this->info['identifier'] = $serviceIdentifier;

        if ($object->remoteID() != $serviceIdentifier) {
            $this->errors['LOCAL_OBJECT_REMOTE_ID_MISMATCH'] = [
                'topic' => 'strict',
                'message' => 'Object remote_id does not match with attribute identifier: '
                    . $object->remoteID() . ' ' . $serviceIdentifier,
                'fix_question' => 'Fix locale object remote id? ',
                'fix' => function () use ($object, $serviceIdentifier) {
                    eZDB::setErrorHandling(eZDB::ERROR_HANDLING_EXCEPTIONS);
                    try {
                        $object->setAttribute('remote_id', $serviceIdentifier);
                        $object->store();
                    } catch (Throwable $e) {
                        eZCLI::instance()->error($e->getMessage());
                    }
                },
            ];
        }

        $channelsIdList = isset($dataMap['has_channel']) ? explode('-', $dataMap['has_channel']->toString()) : [];
        $channels = OpenPABase::fetchObjects($channelsIdList);
        if (count($channels) === 0) {
            $this->errors['LOCAL_EMPTY_CHANNELS'] = [
                'topic' => 'strict',
                'message' => 'HasChannel relation is empty',
            ];
        }

        $accessUrls = $accessUrlList = $bookingUrls = $bookingUrlList = [];
        foreach ($channels as $channel) {
            $channelRemoteId = $channel->remoteID();
            $channelDataMap = $channel->dataMap();
            $url = isset($channelDataMap['channel_url']) ? trim($channelDataMap['channel_url']->content()) : '';
            if (strpos($channelRemoteId, 'access-') !== false || strpos($url, '/access') !== false) {
                $accessUrlList[] = $url;
                $accessUrls[] = $channelDataMap['channel_url'];
                $this->info['access_url'][] = trim($url);
            } elseif (strpos($channelRemoteId, 'booking-') !== false
                || strpos($url, '/prenota_appuntamento') !== false) {
                $bookingUrlList[] = $url;
                $bookingUrls[] = $channelDataMap['channel_url'];
                $this->info['booking_url'][] = trim($url);
            } else {
                $this->info['channel_urls'][] = trim($url);
            }
        }

        $remoteService = $this->getRemoteServiceByRemoteId()
            ?? $this->getRemoteServiceByIdentifier($serviceIdentifier)
            ?? $this->getRemoteServiceByAccessUrl($accessUrlList)
            ?? $this->getRemoteServiceByBookingUrl($bookingUrlList);

        if ($remoteService) {
            $remoteServiceUUID = $remoteService['id'];
            $this->info['digital_service_id'] = $remoteServiceUUID;

            if (!empty($remoteService['identifier']) && $serviceIdentifier != $remoteService['identifier']) {
                $this->errors['IDENTIFIER_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Service identifier does not match with remote service identifier',
                    'locale' => $serviceIdentifier,
                    'remote' => $remoteService['identifier'],
                    'fix_question' => 'Fix locale object remote id and identifier attribute? ',
                    'fix' => function () use ($remoteService, $object, $dataMap) {
                        eZDB::setErrorHandling(eZDB::ERROR_HANDLING_EXCEPTIONS);
                        try {
                            $object->setAttribute('remote_id', $remoteService['identifier']);
                            $object->store();
                            $dataMap['identifier']->fromString($remoteService['identifier']);
                            $dataMap['identifier']->store();
                        } catch (Throwable $e) {
                            eZCLI::instance()->error($e->getMessage());
                        }
                    },
                ];
            }

            if (self::$syncNodeRemoteIdWithServiceUuid && $this->service->remoteID() != $remoteServiceUUID) {
                $this->errors['LOCAL_NODE_REMOTE_ID_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Node remote_id does not match with remote service UUID',
                    'locale' => $this->service->remoteID(),
                    'remote' => $remoteServiceUUID,
                    'fix_question' => 'Fix locale mode remote id? ',
                    'fix' => function () use ($remoteServiceUUID) {
                        eZDB::setErrorHandling(eZDB::ERROR_HANDLING_EXCEPTIONS);
                        try {
                            $this->service->setAttribute('remote_id', $remoteServiceUUID);
                            $this->service->store();
                        } catch (Throwable $e) {
                            eZCLI::instance()->error($e->getMessage());
                        }
                    },
                ];
            }

            if (self::$syncServiceName && $remoteService['name'] != $this->service->attribute('name')) {
                $this->errors['NAME_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Name does not match',
                    'locale' => $this->service->attribute('name'),
                    'remote' => $remoteService['name'],
                ];
            }

            $urlAlias = $this->service->attribute('url_alias');
            $availableUrls = [
                '/' . $urlAlias,
                '/openpa/object/' . $object->attribute('id'),
                '/openpa/object/' . $object->remoteID(),
            ];

            //external_card_url
            $rightExternalCardUrl = implode('', [
                'https://',
                $this->localDomain,
                '/openpa/object/',
                $object->remoteID(),
            ]);
            $externalCardPath = parse_url($remoteService['external_card_url'], PHP_URL_PATH);
            if (!in_array($externalCardPath, $availableUrls)) {
                $this->errors['REMOTE_EXTERNAL_CARD_URL_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'External card url does not match',
                    'locale' => implode(' or ', $availableUrls),
                    'remote' => $externalCardPath ?? $remoteService['external_card_url'],
                    'fix_question' => "Fix remote external_card_url with value '$rightExternalCardUrl'? ",
                    'fix' => function () use ($remoteService, $rightExternalCardUrl) {
                        try {
                            $this->client->patchService(
                                $remoteService['id'],
                                ['external_card_url' => $rightExternalCardUrl]
                            );
                        } catch (Throwable $e) {
                            eZCLI::instance()->error($e->getMessage());
                        }
                    },
                ];
            }

            //access_url
            if (!in_array(trim($remoteService['access_url']), $accessUrlList)) {
                $this->errors['LOCAL_ACCESS_URL_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Access url does not match',
                    'locale' => implode(', ', $accessUrlList),
                    'remote' => $remoteService['access_url'],
                    'fix_question' => "Fix locale access url with value '" . $remoteService['access_url'] . "'? ",
                    'fix' => function () use ($remoteService, $accessUrls) {
                        eZDB::setErrorHandling(eZDB::ERROR_HANDLING_EXCEPTIONS);
                        try {
                            if (count($accessUrls) > 1) {
                                throw new RuntimeException('Access url is greater than 1');
                            }
                            $accessUrl = $accessUrls[0];
                            $accessUrl->setContent($remoteService['access_url']);
                            $accessUrl->store();
                        } catch (Throwable $e) {
                            eZCLI::instance()->error($e->getMessage());
                        }
                    },
                ];
            }

            //booking_url
            $rightBookingUrl = implode('', [
                'https://',
                $this->localDomain,
                '/prenota_appuntamento?service_id=',
                $remoteServiceUUID,
            ]);
            if (!in_array(trim($rightBookingUrl), $bookingUrlList)) {
                $this->errors['LOCAL_BOOKING_URL_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Local booking url does not match with compiled',
                    'locale' => implode(', ', $bookingUrlList),
                    'remote' => $rightBookingUrl,
                    'fix_question' => "Fix locale booking url with value '" . $rightBookingUrl . "'? ",
                    'fix' => function () use ($rightBookingUrl, $bookingUrls) {
                        eZDB::setErrorHandling(eZDB::ERROR_HANDLING_EXCEPTIONS);
                        try {
                            if (count($bookingUrls) > 1) {
                                throw new RuntimeException('Booking url is greater than 1');
                            }
                            $bookingUrl = $bookingUrls[0];
                            $bookingUrl->setContent($rightBookingUrl);
                            $bookingUrl->store();
                        } catch (Throwable $e) {
                            eZCLI::instance()->error($e->getMessage());
                        }
                    },
                ];
            }

            //booking_call_to_action
            if (!in_array(trim($remoteService['booking_call_to_action']), [$rightBookingUrl])) {
                $this->errors['REMOTE_BOOKING_URL_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Booking url does not match',
                    'locale' => $rightBookingUrl,
                    'remote' => $remoteService['booking_call_to_action'],
                    'fix_question' => "Fix remote booking_call_to_action with value '$rightBookingUrl'? ",
                    'fix' => function () use ($remoteService, $rightBookingUrl) {
                        try {
                            $this->client->patchService(
                                $remoteService['id'],
                                ['booking_call_to_action' => $rightBookingUrl]
                            );
                        } catch (Throwable $e) {
                            eZCLI::instance()->error($e->getMessage());
                        }
                    },
                ];
            }

            $inSync = true;
            $remoteStatus = $remoteService['status'];
            $isActivePublicService = OpenPABootstrapItaliaOperators::isActivePublicService($object);
            $remoteIsActive = (isset(StanzaDelCittadinoBridge::$mapServiceStatus[$remoteStatus])
                && StanzaDelCittadinoBridge::$mapServiceStatus[$remoteStatus] == StanzaDelCittadinoBridge::$mapServiceStatus['active']);
            if (!$remoteIsActive && $isActivePublicService) {
                $inSync = false;
            }
            if (!$inSync) {
                $statusError[] = [
                    'topic' => 'sync',
                    'message' => 'Status does not match',
                    'locale' => '?',
                    'remote' => $remoteService['status'],
                ];
                if (isset($dataMap['has_service_status'])) {
                    $status = $dataMap['has_service_status']->content();
                    $statusError['locale'] = $status instanceof eZTags ?
                        $status->keywordString(' ') : $dataMap['has_service_status']->toString();
                }
                $this->errors['LOCAL_STATUS_MISMATCH'] = $statusError;
            }

            $localMaxResponseTime = isset($dataMap['has_processing_time']) ?
                (int)$dataMap['has_processing_time']->toString() : 0;
            $remoteMaxResponseTime = (int)$remoteService['max_response_time'];
            if ($localMaxResponseTime != $remoteMaxResponseTime) {
                $this->errors['REMOTE_MAX_RESPONSE_TIME_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Max response time does not match',
                    'locale' => $localMaxResponseTime,
                    'remote' => $remoteMaxResponseTime,
                    'fix_question' => "Fix remote has_processing_time with value '$localMaxResponseTime'? ",
                    'fix' => function () use ($remoteService, $localMaxResponseTime) {
                        try {
                            $this->client->patchService(
                                $remoteService['id'],
                                ['has_processing_time' => $localMaxResponseTime]
                            );
                        } catch (Throwable $e) {
                            eZCLI::instance()->error($e->getMessage());
                        }
                    },
                ];
            }

            $messages = $remoteService['feedback_messages'];
            foreach ($messages as $messageId => $values) {
                $text = $values['message'] ?? false;
                $isActive = $values['is_active'] ?? false;
                if ($isActive && strpos($text, 'Entro 30 giorni') !== false && $localMaxResponseTime != 30) {
                    $newText = str_replace('Entro 30 giorni', 'Entro 30 giorni', $text);
                    $this->errors['REMOTE_WRONG_NOTIFICATION:' . strtoupper($messageId)] = [
                        'topic' => 'strict',
                        'message' => "Notification text for status change \"$messageId\" contains wrong max response time",
                        'fix_question' => "Fix remote feedback_messages message $messageId with value '$newText'? ",
                        'fix' => function () use ($remoteService, $messageId, $newText) {
                            $messages = $remoteService['feedback_messages'];
                            $messages[$messageId]['message'] = $newText;
                            try {
                                $this->client->patchService(
                                    $remoteService['id'],
                                    ['feedback_messages' => $messages]
                                );
                            } catch (Throwable $e) {
                                eZCLI::instance()->error($e->getMessage());
                            }
                        },
                    ];
                }
            }

            $topicId = $remoteService['topics_id'];
            $remoteCategory = $this->client->getCategory($topicId);
            $categoryName = $remoteCategory['name'];
            $type = [];
            if (isset($dataMap['type'])
                && $dataMap['type']->attribute('data_type_string') === eZTagsType::DATA_TYPE_STRING) {
                /** @var eZTags $tags */
                $tags = $dataMap['type']->content();
                $type = $tags->attribute('keywords');
            }
            if (count($type) && !in_array($categoryName, $type)) {
                $localCategory = $type[0];
                $this->errors['REMOTE_CATEGORY_MISMATCH'] = [
                    'topic' => 'sync',
                    'message' => 'Service category does not match',
                    'locale' => $localCategory,
                    'remote' => $categoryName,
                    'fix_question' => "Fix remote topics with value '$localCategory'? ",
                    'fix' => function () use ($remoteService, $localCategory) {
                        try {
                            $localCategoryId = null;
                            $categories = $this->getCategoryList();
                            foreach ($categories as $c){
                                if ($c['name'] == $localCategory){
                                    $localCategoryId = $c['slug'];
                                }
                            }
                            if (!$localCategoryId){
                                throw new Exception("Remote topic $localCategory not found");
                            }
                            $this->client->patchService(
                                $remoteService['id'],
                                ['topics' => $localCategoryId]
                            );

                        } catch (Throwable $e) {
                            eZCLI::instance()->error($e->getMessage());
                        }
                    },
                ];
            }
        }
    }

    private function getRemoteServiceByRemoteId()
    {
        if (self::$syncNodeRemoteIdWithServiceUuid && self::isUUid($this->service->remoteID())) {
            try {
                $this->info['digital_service_found_by'] = 'node_remote_id';
                return $this->client->getService($this->service->remoteID());
            } catch (Throwable $e) {
                $this->errors['REMOTE_BY_ID_NOT_FOUND'] = [
                    'topic' => 'strict',
                    'message' => 'Remote service by id not found ' . $e->getMessage(),
                ];
            }
        }

        return null;
    }

    private function getRemoteServiceByIdentifier($serviceIdentifier)
    {
        try {
            $this->info['digital_service_found_by'] = 'identifier';
            return $this->client->getServiceByIdentifier($serviceIdentifier);
        } catch (Throwable $e) {
            $this->errors['REMOTE_BY_IDENTIFIER_NOT_FOUND'] = [
                'topic' => 'strict',
                'message' => 'Remote service by identifier not found ' . $e->getMessage(),
            ];
        }

        return null;
    }

    private function getRemoteServiceByAccessUrl($channelUrls)
    {
        $remoteService = null;
        $msg = [];
        foreach ($channelUrls as $url) {
            if (strpos($url, '/access') !== false) {
                $parts = explode('/', $url);
                array_pop($parts);
                $slug = array_pop($parts);
                if ($slug) {
                    foreach ($this->getServiceList() as $s) {
                        if ($s['slug'] == $slug) {
                            try {
                                $remoteService = $s;
                                break;
                            } catch (Throwable $e) {
                                $msg[] = $e->getMessage();
                            }
                        }
                    }
                }
            }
        }
        if (!$remoteService) {
            $this->errors['REMOTE_BY_SLUG_NOT_FOUND'] = [
                'topic' => 'strict',
                'message' => 'Remote service by slug not found' . implode(' ', $msg),
            ];
        } else {
            $this->info['digital_service_found_by'] = 'access_url';
        }
        return $remoteService;
    }

    private function getServiceList()
    {
        if ($this->serviceList === null) {
            StanzaDelCittadinoClient::$connectionTimeout = 100;
            StanzaDelCittadinoClient::$processTimeout = 100;
            $this->serviceList = $this->client->getServiceList();
        }

        return $this->serviceList;
    }

    private function getCategoryList()
    {
        if ($this->categoryList === null){
            $this->categoryList = $this->client->getCategories();
        }

        return $this->categoryList;
    }

    private function getRemoteServiceByBookingUrl($channelUrls)
    {
        $remoteService = null;
        $msg = [];
        foreach ($channelUrls as $url) {
            if (strpos($url, 'prenota_appuntamento?service_id=') !== false) {
                $parts = explode('prenota_appuntamento?service_id=', $url);
                if (isset($parts[1]) && self::isUUid($parts[1])) {
                    try {
                        $remoteService = $this->client->getService($parts[1]);
                    } catch (Throwable $e) {
                        $msg[] = $e->getMessage();
                    }
                }
            }
        }
        if (!$remoteService) {
            $this->errors['REMOTE_BY_BOOKING_ID_NOT_FOUND'] = [
                'topic' => 'strict',
                'message' => 'Remote service by booking url service_id not found ' . implode(' ', $msg),
            ];
        } else {
            $this->info['digital_service_found_by'] = 'booking_url';
        }

        return $remoteService;
    }

    private static function isUuid(string $string)
    {
        return preg_match(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/',
            $string
        );
    }
}