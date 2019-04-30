{default enable_print=false()}

{def $favicon = openpaini('GeneralSettings','favicon', 'favicon.ico')}
{def $favicon_src = openpaini('GeneralSettings','favicon_src', 'ezimage')}

<link rel="Home" href={"/"|ezurl} title="{'%sitetitle front page'|i18n('design/ocbootstrap/link',,hash('%sitetitle',$site.title))|wash}" />
<link rel="Index" href={"/"|ezurl} />
<link rel="Search" href={"content/advancedsearch"|ezurl} title="{'Search %sitetitle'|i18n('design/ocbootstrap/link',,hash('%sitetitle',$site.title))|wash}" />

{if $favicon_src|eq('ezimage')}
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

{if $enable_print}
{* Add print <link> tag in JS to be cache safe with query string (not included in cache-block key by default in pagelayout) *}
<script>
(function() {ldelim}

    var head = document.getElementsByTagName('head')[0];
    var printNode = document.createElement('link');
    printNode.rel = 'Alternate';
    printNode.href = "{concat( 'layout/set/print/', $site.uri.original_uri )|ezurl( 'no' )}" + document.location.search;
    printNode.media = 'print';
    printNode.title = "{'Printable version'|i18n('design/ocbootstrap/link')}";
    head.appendChild(printNode);

{rdelim})();
</script>
{/if}

{undef $favicon}
{/default}
