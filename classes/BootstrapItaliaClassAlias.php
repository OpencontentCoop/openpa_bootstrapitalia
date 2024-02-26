<?php

class BootstrapItaliaClassAlias
{
    private static $aliasList = [
        'public_service' => 'public_service_link',
        'event' => 'event_link',
    ];

    private static $aliasIdList = null;

    public static function getAliasIdList(): array
    {
        if (self::$aliasIdList === null){
            self::$aliasIdList = [];
            foreach (self::$aliasList as $visible => $hidden) {
                $hiddenClassId = eZContentClass::classIDByIdentifier($hidden);
                if ($hiddenClassId) {
                    $visibleClassId = eZContentClass::classIDByIdentifier($visible);
                    if ($visibleClassId) {
                        self::$aliasIdList[$visibleClassId] = $hiddenClassId;
                    }
                }
            }
        }

        return self::$aliasIdList;
    }
}