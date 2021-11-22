{default enable_print=false()}

<link rel="Home" href={"/"|ezurl} title="{'%sitetitle front page'|i18n('design/ocbootstrap/link',,hash('%sitetitle',$site.title))|wash}" />
<link rel="Index" href={"/"|ezurl} />
<link rel="Search" href={"content/advancedsearch"|ezurl} title="{'Search %sitetitle'|i18n('design/ocbootstrap/link',,hash('%sitetitle',$site.title))|wash}" />

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

{/default}
