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

{* @todo
<link rel="icon" href="/bootstrap-italia/favicon.ico">
<link rel="icon" href="/bootstrap-italia/docs/assets/img/favicons/favicon-32x32.png" sizes="32x32" type="image/png">
<link rel="icon" href="/bootstrap-italia/docs/assets/img/favicons/favicon-16x16.png" sizes="16x16" type="image/png">
<link rel="mask-icon" href="/bootstrap-italia/docs/assets/img/favicons/safari-pinned-tab.svg" color="#0066CC">
<link rel="apple-touch-icon" href="/bootstrap-italia/docs/assets/img/favicons/apple-touch-icon.png">

<link rel="manifest" href="/bootstrap-italia/docs/assets/img/favicons/manifest.webmanifest">
<meta name="msapplication-config" content="/bootstrap-italia/docs/assets/img/favicons/browserconfig.xml">
*}

{undef $favicon_attribute $favicon $favicon_src}
