{def $favicon_attribute = cond(
    and( $pagedata.homepage|has_attribute('favicon'), $pagedata.homepage|attribute('favicon').has_content ),
        $pagedata.homepage|attribute('favicon'),
        false()
)}
{def $favicon = openpaini('GeneralSettings','favicon', 'favicon.ico')}
{def $favicon_src = openpaini('GeneralSettings','favicon_src', 'ezimage')}
<!-- favicon -->
{if $favicon_attribute}
    <link rel="icon" href="{concat("content/download/",$favicon_attribute.contentobject_id,"/",$favicon_attribute.id,"/file/favicon.ico")|ezurl(no)}?v={$favicon_attribute.version}" type="image/x-icon" />
{elseif $favicon_src|eq('ezimage')}
    <link rel="icon" href="{$favicon|ezimage(no)}" type="image/x-icon" />
{else}
    <link rel="icon" href="{$favicon}" type="image/x-icon" />
{/if}

{def $apple_touch_icon_attribute = cond(
    and( $pagedata.homepage|has_attribute('apple_touch_icon'), $pagedata.homepage|attribute('apple_touch_icon').has_content ),
        $pagedata.homepage|attribute('apple_touch_icon'),
        false()
)}
{if $apple_touch_icon_attribute}
    <link rel="apple-touch-icon" href="{concat("content/download/",$apple_touch_icon_attribute.contentobject_id,"/",$apple_touch_icon_attribute.id,"/file/apple-touch-icon.png")|ezurl(no)}?v={$apple_touch_icon_attribute.version}" />
{elseif openpaini('CreditsSettings', 'IsOpenCityFork', 'false')|ne('true')} {* see pa-website-validator *}
    <link rel="apple-touch-icon" href="/extension/openpa_bootstrapitalia/design/standard/images/svg/icon.png">
{/if}

<link rel="manifest" href="/manifest.json" crossorigin = "use-credentials">

{undef $favicon_attribute $favicon $favicon_src $apple_touch_icon_attribute}
