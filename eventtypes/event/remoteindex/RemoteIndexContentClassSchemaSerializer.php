<?php

use Opencontent\OpenApi\SchemaFactory\ContentClassSchemaSerializer;
use Opencontent\OpenApi\SchemaFactory\ContentClassSchemaSerializerFactoriesLoader;
use Opencontent\OpenApi\SchemaFactory\ContentMetaPropertyFactory;

class RemoteIndexContentClassSchemaSerializer extends ContentClassSchemaSerializer
{
    const SCHEMA_PROVIDER_NAME = 'RemoteIndexEvent';

    protected static function getFactoriesLoader(eZContentClass $class): ContentClassSchemaSerializerFactoriesLoader
    {
        return new ContentClassSchemaSerializerFactoriesLoader(
            $class, [
                'app_id' => new ContentMetaPropertyFactory($class, 'app_id', [
                    "type" => 'string',
                    "description" => 'Source app identifier',
                ], true),
                'app_version' => new ContentMetaPropertyFactory($class, 'app_version', [
                    "type" => 'string',
                    "description" => 'Source app version',
                ], true),
                'event_id' => new ContentMetaPropertyFactory($class, 'event_id', [
                    "type" => 'string',
                    "description" => 'Event identifier',
                ], true),
                'event_created_at' => new ContentMetaPropertyFactory($class, 'event_created_at', [
                    "type" => 'string',
                    "description" => 'Event created at',
                ], true),
                'event_version' => new ContentMetaPropertyFactory($class, 'event_version', [
                    "type" => 'string',
                    "description" => 'Event version',
                ], true),
                'event_type' => new ContentMetaPropertyFactory($class, 'event_type', [
                    "type" => 'string',
                    "description" => 'Event type',
                ], true),
                'remoteId' => null,
                'tenant' => new ContentMetaPropertyFactory($class, 'tenant', [
                    "type" => 'string',
                    "description" => 'Tenant identifier',
                ], true),
                'distributor' => new ContentMetaPropertyFactory($class, 'tenant', [
                    "type" => 'string',
                    "description" => 'Distributor identifier',
                ], true),
                'language' => new ContentMetaPropertyFactory($class, 'language', [
                    "type" => 'string',
                    "description" => 'Language code',
                    "enum" => self::fetchLocaleList(),
                ], true),
                'content_type_identifier' => new ContentMetaPropertyFactory($class, 'content_type_identifier', [
                    "type" => 'string',
                    "description" => 'Content type identifier',
                ], true),
                'content_version' => new ContentMetaPropertyFactory($class, 'content_version', [
                    "type" => "integer",
                    'format' => 'int32',
                    "description" => 'Content version number',
                ], true),
//                'content_states' => new ContentMetaPropertyFactory($class, 'content_states', [
//                    "type" => 'array',
//                    "description" => 'Language code',
//                    "items" => ["type" => 'string',],
//                ], true),
                'privacy' => null,
                'link' => new ContentMetaPropertyFactory($class, 'link', [
                    "type" => 'string',
                    "description" => 'Public link of web page',
                ]),
                'uri' => null,
                'published' => null,
                'modified' => null,
            ]
        );
    }

    static function fetchLocaleList()
    {
        $languages = eZContentLanguage::fetchList();
        $localeList = [];

        foreach ($languages as $language) {
            if ($language->attribute('locale') !== 'ita-PA') {
                $localeList[] = $language->attribute('locale');
            }
        }

        return $localeList;
    }
}