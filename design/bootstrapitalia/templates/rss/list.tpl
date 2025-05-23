{ezscript_require( 'tools/ezjsselection.js' )}
{ezpagedata_set( show_path, false() )}
<style>.breadcrumb-container,.cmp-breadcrumbs{ldelim}display:none{rdelim}</style>

{* Export window. *}
<form name="rssexportslist" method="post" action={'rss/list'|ezurl}>

    <h1 class="h3 pt-3">{'RSS exports [%exports_count]'|i18n( 'design/ocbootstrap/rss/list',, hash( '%exports_count', $rssexport_list|count ) )}</h1>

    {section show=$rssexport_list}
    <table class="list" cellspacing="0">
        <tr>
            <th class="tight"><img
                        src={'toggle-button-16x16.gif'|ezimage} alt="{'Invert selection'|i18n( 'design/ocbootstrap/rss/list' )}"
                        onclick="ezjs_toggleCheckboxes( document.rssexportslist, 'DeleteIDArray[]' ); return false;"
                        title="{'Invert selection.'|i18n( 'design/ocbootstrap/rss/list' )}"/></th>
            <th>{'Name'|i18n( 'design/ocbootstrap/rss/list' )}</th>
            <th>{'Version'|i18n( 'design/ocbootstrap/rss/list' )}</th>
            <th>{'Status'|i18n( 'design/ocbootstrap/rss/list' )}</th>
            <th>{'Modifier'|i18n( 'design/ocbootstrap/rss/list' )}</th>
            <th>{'Modified'|i18n( 'design/ocbootstrap/rss/list' )}</th>
            <th class="tight">&nbsp;</th>
        </tr>
        {section var=RSSExports loop=$rssexport_list sequence=array( bglight, bgdark )}
        <tr class="{$RSSExports.sequence}">

            {* Remove. *}
            <td class="align-middle">
                <input type="checkbox" name="DeleteIDArray[]" value="{$RSSExports.item.id}"
                       title="{'Select RSS export for removal.'|i18n( 'design/ocbootstrap/rss/list' )}"/></td>

            {* Name. *}
            <td class="align-middle">
                {section show=$RSSExports.item.active|eq( 1 )} <a
                        href={concat( 'rss/feed/', $RSSExports.item.access_url )|ezurl}>{$RSSExports.item.title|wash}</a>{section-else}{$RSSExports.item.title|wash}{/section}
            </td>

            {* Version. *}
            <td class="align-middle">{$RSSExports.item.rss_version|wash}</td>

            {* Status. *}
            <td class="align-middle">{section show=$RSSExports.item.active|eq( 1 )}{'Active'|i18n( 'design/ocbootstrap/rss/list' )}{section-else}{'Inactive'|i18n( 'design/ocbootstrap/rss/list' )}{/section}</td>

            {* Modifier. *}
            <td class="align-middle">{$RSSExports.item.modifier.contentobject.name|wash}</td>

            {* Modified. *}
            <td class="align-middle">{$RSSExports.item.modified|l10n( shortdatetime )}</td>

            {* Edit. *}
            <td class="align-middle">
                <a class="btn btn-link text-nowrap" href={concat( 'rss/edit_export/', $RSSExports.item.id )|ezurl} title="{'Edit the <%name> RSS export.'|i18n('design/ocbootstrap/rss/list',, hash( '%name', $RSSExports.item.title) )|wash}">
                    <span class="fa-stack">
                      <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
                      <i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i>
                    </span>
                </a>
            </td>

        </tr>
        {/section}
    </table>
    {section-else}
        <p class="lead">{'The RSS export list is empty.'|i18n( 'design/ocbootstrap/rss/list' )}</p>
    {/section}

    <div class="block">
        <input type="submit" name="RemoveExportButton" value="{'Remove selected'|i18n( 'design/ocbootstrap/rss/list' )}"
               title="{'Remove selected RSS exports.'|i18n( 'design/ocbootstrap/rss/list' ) }"
               {section show=$rssexport_list|not}class="button-disabled" disabled="disabled"
               {section-else}class="button"{/section}
        />
        <input class="button" type="submit" name="NewExportButton"
               value="{'New export'|i18n( 'design/ocbootstrap/rss/list' )}"
               title="{'Create a new RSS export.'|i18n( 'design/ocbootstrap/rss/list' )}"/>
    </div>

</form>

{* Import window.
<form name="rssimportslist" method="post" action={'rss/list'|ezurl}>

<h2>{'RSS imports [%imports_count]'|i18n( 'design/ocbootstrap/rss/list',, hash( '%imports_count', $rssimport_list|count ) )}</h2>

{section show=$rssimport_list}
<table class="list" cellspacing="0">
<tr>
    <th class="tight"><img src={'toggle-button-16x16.gif'|ezimage} alt="{'Invert selection'|i18n( 'design/ocbootstrap/rss/list' )}" onclick="ezjs_toggleCheckboxes( document.rssimportslist, 'DeleteIDArrayImport[]' ); return false;" title="{'Invert selection.'|i18n( 'design/ocbootstrap/rss/list' )}" /></th>
    <th>{'Name'|i18n( 'design/ocbootstrap/rss/list' )}</th>
    <th>{'Status'|i18n( 'design/ocbootstrap/rss/list' )}</th>
    <th>{'Modifier'|i18n( 'design/ocbootstrap/rss/list' )}</th>
    <th>{'Modified'|i18n( 'design/ocbootstrap/rss/list' )}</th>
    <th class="tight">&nbsp;</th>
</tr>
{section var=RSSImports loop=$rssimport_list sequence=array( bglight, bgdark )}
<tr class="{$RSSImports.sequence}">
    <td><input type="checkbox" name="DeleteIDArrayImport[]" value="{$RSSImports.item.id}" title="{'Select RSS import for removal.'|i18n( 'design/ocbootstrap/rss/list' )}" /></td>
    <td>{$RSSImports.item.name|wash}</td>
    <td>{section show=$RSSImports.item.active|eq(1)}{'Active'|i18n( 'design/ocbootstrap/rss/list' )}{section-else}{'Inactive'|i18n( 'design/ocbootstrap/rss/list' )}{/section}</td>
    <td><a href={$RSSImports.item.modifier.contentobject.main_node.url_alias|ezurl}>{$RSSImports.item.modifier.contentobject.name|wash}</a></td>
    <td>{$RSSImports.item.modified|l10n( shortdatetime )}</td>
    <td><a href={concat( 'rss/edit_import/', $RSSImports.item.id )|ezurl}><img class="button" src={'edit.gif'|ezimage} width="16" height="16" alt="{'Edit'|i18n( 'design/ocbootstrap/rss/list' )}" title="{'Edit the <%name> RSS import.'|i18n('design/ocbootstrap/rss/list',, hash( '%name', $RSSImports.item.name) )|wash }" /></a></td>
</tr>
{/section}
</table>
{section-else}
<div class="block">
    <p>{'The RSS import list is empty.'|i18n( 'design/ocbootstrap/rss/list' )}</p>
</div>
{/section}
<div class="block">
    <input {section show=$rssimport_list|count}class="button"{section-else}class="button-disabled" disabled="disabled"{/section} type="submit" name="RemoveImportButton" value="{'Remove selected'|i18n( 'design/ocbootstrap/rss/list' )}" title="{'Remove selected RSS imports.'|i18n( 'design/ocbootstrap/rss/list' ) }" />
    <input class="button" type="submit" name="NewImportButton" value="{'New import'|i18n( 'design/ocbootstrap/rss/list' )}" title="{'Create a new RSS import.'|i18n( 'design/ocbootstrap/rss/list' )}" />
</div>
</form>
*}
