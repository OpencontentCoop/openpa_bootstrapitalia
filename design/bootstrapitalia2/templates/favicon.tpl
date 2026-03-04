{def $favicon_attribute = cond(
    and( $pagedata.homepage|has_attribute('favicon'), $pagedata.homepage|attribute('favicon').has_content ),
        $pagedata.homepage|attribute('favicon'),
        false()
)}

{def $apple_touch_icon_attribute = cond(
    and( $pagedata.homepage|has_attribute('apple_touch_icon'), $pagedata.homepage|attribute('apple_touch_icon').has_content ),
        $pagedata.homepage|attribute('apple_touch_icon'),
        false()
)}

{def $favicon_static_src = '/extension/openpa_bootstrapitalia/design/standard/images/svg/'}

{if $favicon_attribute}
    <link rel="icon" href="{"/favicon"|ezurl(no)}" type="image/x-icon" />
{else}
    <link rel="icon" href="{concat($favicon_static_src,'favicon-96x96.png')}" type="image/x-icon" />
{/if}

{if $apple_touch_icon_attribute}
    <link rel="apple-touch-icon"
      href="{concat("content/download/",$apple_touch_icon_attribute.contentobject_id,"/",$apple_touch_icon_attribute.id,"/file/apple-touch-icon.png")|ezurl(no)}?v={$apple_touch_icon_attribute.version}" />
{else}
    <link rel="apple-touch-icon"
      sizes="180x180"
      href="{concat($favicon_static_src,'apple-touch-icon.png')}" />
{/if}

<meta name="apple-mobile-web-app-title" content="{ezini('SiteSettings','SiteName')}" />

{def $manifest_app = $pagedata.persistent_variable.built_in_app}

<link rel="manifest" href="/manifest.json{if $manifest_app}?app={$manifest_app}{/if}" crossorigin="use-credentials" />


{undef $favicon_attribute $apple_touch_icon_attribute $manifest_app}