<?php

use Opencontent\OpenApi\SchemaFactory\ContentClassSchemaFactory;
use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\Api\Values\ContentData;

final class RemoteIndexContentBuilder
{
    const DELETE = 'deletion';

    const UPDATE = 'update';

    /**
     * @var eZContentObject
     */
    private $object;

    /**
     * @var string
     */
    private $eventIdentifier;

    /**
     * @var string
     */
    private $languageCode;

    private static $installerVersion;

    public function __construct(string $eventIdentifier, eZContentObject $object, string $languageCode)
    {
        $this->eventIdentifier = $eventIdentifier;
        $this->object = $object;
        $this->languageCode = $languageCode;
    }

    public function build(): array
    {
        eZURI::setTransformURIMode('full');

        $tenantIdentifier = OpenPABase::getCurrentSiteaccessIdentifier();
        $isDeleted = $this->eventIdentifier === RemoteIndexContentBuilder::DELETE;
        $isPublic = !$isDeleted && $this->checkAccess();
        $href = $this->object->mainNode()->urlAlias();
        eZURI::transformURI($href);

        $content = Content::createFromEzContentObject($this->object);
        $content->metadata->app_id = 'opencity-cms';
        $content->metadata->app_version = self::getInstallerVersion();
        $content->metadata->event_id = self::uuid4();
        $content->metadata->event_created_at = (new DateTime())->format('c');
        $content->metadata->event_version = '1';
        $content->metadata->event_type = $this->eventIdentifier;
        $content->metadata->tenant = $tenantIdentifier;
        $content->metadata->distributor = OpenPABootstrapItaliaOperators::getCurrentPartner();
//        $content->metadata->content_states = $content->metadata->stateIdentifiers;
        $content->metadata->stateIdentifiers = $isPublic ? ['privacy.public'] : [];
        $content->metadata->link = $href;
        $content->metadata->language = $this->languageCode;
        $content->metadata->content_type_identifier = $content->metadata->classIdentifier;
        $content->metadata->content_version = $content->metadata->currentVersion;

        if ($isDeleted) {
            $content->data = [$this->languageCode => new ContentData()];
        }

        $schemaFactory = new ContentClassSchemaFactory($content->metadata->classIdentifier);
        $schemaFactory->setSerializer(new RemoteIndexContentClassSchemaSerializer());

        $schemaHandler = RemoteIndexContentClassSchemaSerializer::SCHEMA_PROVIDER_NAME;
        $schemaName = $schemaFactory->getName();

        $schemaUrl = "/schemas/$schemaHandler/$schemaName";
        eZURI::transformURI($schemaUrl);

        $data = $schemaFactory->serializeValue($content, $this->languageCode);

        return array_merge(
            ['$schema' => $schemaUrl],
            $data
        );
    }

    private static function getInstallerVersion(): ?string
    {
        if (self::$installerVersion === null) {
            $storage = eZSiteData::fetchByName('ocinstaller_version');
            if ($storage instanceof eZSiteData) {
                self::$installerVersion = $storage->attribute('value');
            } else {
                self::$installerVersion = OpenPAINI::variable('CreditsSettings', 'CodeVersion', '');
            }
        }

        return self::$installerVersion;
    }

    private static function uuid4($data = null): string
    {
        // Generate 16 bytes (128 bits) of random data or use the data passed into the function.
        $data = $data ?? random_bytes(16);
        assert(strlen($data) == 16);

        // Set version to 0100
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
        // Set bits 6-7 to 10
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80);

        // Output the 36 character UUID.
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }

    private function checkAccess(): bool
    {
        $anonymous = eZUser::fetch(eZUser::anonymousId());
        if ($anonymous instanceof eZUser) {
            $tool = new OpenPAWhoCan($this->object, 'read', $anonymous);
            return (bool)$tool->run();
        }
        return false;
    }
}