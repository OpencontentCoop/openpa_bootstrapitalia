{ezscript_require( 'tools/ezjsselection.js' )}

<div class="content-history">

{switch match=$edit_warning}
    {case match=1}
    <div class="alert alert-warning">
        <h2><span class="time">[{currentdate()|l10n( shortdatetime )}]</span> {'Version not a draft'|i18n( 'design/ocbootstrap/content/history' )}</h2>
        <ul>
            <li>{'Version %1 is not available for editing anymore. Only drafts can be edited.'|i18n( 'design/ocbootstrap/content/history',, array( $edit_version ) )}</li>
            <li>{'To edit this version, first create a copy of it.'|i18n( 'design/ocbootstrap/content/history' )}</li>
        </ul>
    </div>
    {/case}
    {case match=2}
    <div class="alert alert-warning">
        <h2><span class="time">[{currentdate()|l10n( shortdatetime )}]</span> {'Version not yours'|i18n( 'design/ocbootstrap/content/history' )}</h2>
        <ul>
            <li>{'Version %1 was not created by you. Only your own drafts can be edited.'|i18n( 'design/ocbootstrap/content/history',, array( $edit_version ) )}</li>
            <li>{'To edit this version, first create a copy of it.'|i18n( 'design/ocbootstrap/content/history' )}</li>
        </ul>
    </div>
    {/case}
    {case match=3}
    <div class="alert alert-warning">
        <h2><span class="time">[{currentdate()|l10n( shortdatetime )}]</span> {'Unable to create new version'|i18n( 'design/ocbootstrap/content/history' )}</h2>
        <ul>
            <li>{'Version history limit has been exceeded and no archived version can be removed by the system.'|i18n( 'design/ocbootstrap/content/history' )}</li>
            <li>{'You can either change your version history settings in content.ini, remove draft versions or edit existing drafts.'|i18n( 'design/ocbootstrap/content/history' )}</li>
        </ul>
    </div>
    {/case}
    {case}{/case}
{/switch}


    {if and( is_set( $object ), is_set( $diff ), is_set( $oldVersion ), is_set( $newVersion ) )|not}

        <form class="float-right" name="versionsback" action={concat( '/content/history/', $object.id, '/' )|ezurl} method="post">
            {if is_set( $redirect_uri )}
                <input class="text" type="hidden" name="RedirectURI" value="{$redirect_uri}" />
            {/if}
            <button type="submit" class="btn btn-link go-back" name="BackButton">
                {display_icon('it-arrow-left', 'svg', 'icon icon-sm mr-2 me-2')}
                {'Back'|i18n( 'design/ocbootstrap/content/history' )}
            </button>
        </form>
        <h2 class="mb-4">
            <i class="fa fa-history"></i> {$object.name|wash()}
        </h2>

        {def $page_limit   = 30
             $list_count   = fetch(content,version_count, hash(contentobject, $object))
             $current_user = fetch( 'user', 'current_user' )}


        <form name="versionsform" action={concat( '/content/history/', $object.id, '/' )|ezurl} method="post">

            {if $list_count}
                <table class="table table-striped table-sm" cellspacing="0">
                <tr>
                    <th class="tight">
                        <img src={'toggle-button-16x16.gif'|ezimage} alt="{'Toggle selection'|i18n( 'design/ocbootstrap/content/history' )}" onclick="ezjs_toggleCheckboxes( document.versionsform, 'DeleteIDArray[]' ); return false;" />
                    </th>
                    <th>{'Version'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Status'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Modified translation'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Creator'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Modified'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th class="tight">&nbsp;</th>
                    <th class="tight">&nbsp;</th>
                </tr>


                {foreach fetch( content, version_list, hash( 'contentobject', $object,
                                                             'limit', $page_limit,
                                                             'offset', $view_parameters.offset ) ) as $version
                         sequence array( bglight, bgdark ) as $seq}

                {def $initial_language = $version.initial_language}
                <tr class="{$seq}">

                    {* Remove. *}
                    <td>
                        {if and( $version.can_remove, array( 0, 3, 4, 5 )|contains( $version.status ) )}
                            <input type="checkbox" name="DeleteIDArray[]" value="{$version.id}" title="{'Select version #%version_number for removal.'|i18n( 'design/ocbootstrap/content/history',, hash( '%version_number', $version.version ) )}" />
                        {/if}
                    </td>

                    {* Version/view. *}
                    <td><a href={concat( '/content/versionview/', $object.id, '/', $version.version, '/', $initial_language.locale )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/ocbootstrap/content/history',, hash( '%version_number', $version.version, '%translation', $initial_language.name ) )}">{$version.version}</a></td>

                    {* Status. *}
                    <td>{$version.status|choose( 'Draft'|i18n( 'design/ocbootstrap/content/history' ), 'Published'|i18n( 'design/ocbootstrap/content/history' ), 'Pending'|i18n( 'design/ocbootstrap/content/history' ), 'Archived'|i18n( 'design/ocbootstrap/content/history' ), 'Rejected'|i18n( 'design/ocbootstrap/content/history' ), 'Untouched draft'|i18n( 'design/ocbootstrap/content/history' ) )}</td>

                    {* Modified translation. *}
                    <td>
                        <img src="{$initial_language.locale|flag_icon}" alt="{$initial_language.locale}" />&nbsp;<a href={concat('/content/versionview/', $object.id, '/', $version.version, '/', $initial_language.locale, '/' )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/ocbootstrap/content/history',, hash( '%translation', $initial_language.name, '%version_number', $version.version ) )}" >{$initial_language.name|wash}</a>
                    </td>

                    {* Creator. *}
                    <td>{$version.creator.name|wash}</td>

                    {* Created. *}
                    <td>{$version.created|l10n( shortdatetime )}</td>

                    {* Modified. *}
                    <td>{$version.modified|l10n( shortdatetime )}</td>

                    {* Copy button. *}
                    <td align="right" class="right">
                        {def $can_edit_lang = 0}
                        {foreach $object.can_edit_languages as $edit_language}
                            {if eq( $edit_language.id, $initial_language.id )}
                            {set $can_edit_lang = 1}
                            {/if}
                        {/foreach}

                        {if and( $can_edit, $can_edit_lang )}
                          {if eq( $version.status, 5 )}
                          {else}
                            <input type="hidden" name="CopyVersionLanguage[{$version.version}]" value="{$initial_language.locale}" />
                            <button class="btn btn-sm btn-link" type="submit" name="HistoryCopyVersionButton[{$version.version}]"
                                    title="{'Create a copy of version #%version_number.'|i18n( 'design/ocbootstrap/content/history',, hash( '%version_number', $version.version ) )}">
                                <i class="fa fa-copy"></i>
                            </button>
                          {/if}
                        {elseif and(
                            is_set($object.state_identifier_array),
                            $object.state_identifier_array|contains('opencity_lock/locked'),
                            current_user_can_lock_edit($object)
                        )}
                            {if eq($version.status, 3)}
                                <a href="{concat('/bootstrapitalia/version_revert/', $object.id, '/', $version.version)|ezurl(no)}" title="Restore version">
                                    <i class="fa fa-refresh"></i>
                                </a>
                            {elseif and(eq($version.status, 0), $version.creator_id|eq( $current_user.contentobject_id ))}
                                <a href="{concat('/bootstrapitalia/version_remove/', $object.id, '/', $version.version)|ezurl(no)}" title="Restore version">
                                    <i class="fa fa-trash"></i>
                                </a>
                            {/if}
                        {/if}
                        {undef $can_edit_lang}
                    </td>

                    {* Edit button. *}
                    <td>
                        {if and( array(0, 5)|contains($version.status), $version.creator_id|eq( $current_user.contentobject_id ), $can_edit ) }
                            <button class="btn btn-sm btn-link" type="submit" name="HistoryEditButton[{$version.version}]" value="" title="{'Edit the contents of version #%version_number.'|i18n( 'design/ocbootstrap/content/history',, hash( '%version_number', $version.version ) )}">
                                <i class="fa fa-edit"></i>
                            </button>
                        {/if}
                    </td>

                </tr>
                {undef $initial_language}
                {/foreach}
                </table>
            {else}
                <div class="alert alert-info">
                    <p>{'This object does not have any versions.'|i18n( 'design/ocbootstrap/content/history' )}</p>
                </div>
            {/if}

            {include name=navigator
                     uri='design:navigator/google.tpl'
                     page_uri=concat( '/content/history/', $object.id, '///' )
                     item_count=$list_count
                     view_parameters=$view_parameters
                     item_limit=$page_limit}

            {if fetch(user, has_access_to, hash(module, 'content', function, 'versionremove'))}
            <div class="clearfix">
                <div class="float-left">
                    <input class="btn btn-danger btn-sm" type="submit" name="RemoveButton" value="{'Remove selected'|i18n( 'design/ocbootstrap/content/history' )}" title="{'Remove the selected versions from the object.'|i18n( 'design/ocbootstrap/content/history' )}" />
                    <input type="hidden" name="DoNotEditAfterCopy" value="" />
                </div>
            </div>
            {/if}

        </form>

        {if and($object.can_diff, $object.versions|count|gt(1))}
            {def $languages=$object.languages}
            <div class="clearfix mt-4 mb-4 text-center">

                <form action={concat( $module.functions.history.uri, '/', $object.id, '/' )|ezurl} method="post">
                    <div class="row">
                        <div class="col-2 offset-2">
                        <select name="Language" class="form-control">
                            {foreach $languages as $lang}
                                <option value="{$lang.locale}">{$lang.name|wash}</option>
                            {/foreach}
                        </select>
                        </div>
                        <div class="col-2">
                        <select name="FromVersion" class="form-control">
                            {foreach $object.versions as $ver}
                                <option {if eq( $ver.version, $selectOldVersion)}selected="selected"{/if} value="{$ver.version}">{$ver.version|wash}</option>
                            {/foreach}
                        </select>
                        </div>
                        <div class="col-2">
                        <select name="ToVersion"  class="form-control">
                            {foreach $object.versions as $ver}
                                <option {if eq( $ver.version, $selectNewVersion)}selected="selected"{/if} value="{$ver.version}">{$ver.version|wash}</option>
                            {/foreach}
                        </select>
                        </div>
                        <div class="col-3">
                        <input type="hidden" name="ObjectID" value="{$object.id}" />
                        <input class="btn btn-info" type="submit" name="DiffButton" value="{'Show differences'|i18n( 'design/ocbootstrap/content/history' )}" />
                        </div>
                    </div>
                </form>
            </div>
        {/if}



        <h3>{'Published version'|i18n( 'design/ocbootstrap/content/history' )}</h3>

        <table class="table table-striped table-sm" cellspacing="0">
            <tr>
                <th>{'Version'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th>{"Translations"|i18n("design/ocbootstrap/content/history")}</th>
                <th>{'Creator'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th>{'Modified'|i18n( 'design/ocbootstrap/content/history' )}</th>
            </tr>

            {def $published_item=$object.current
                 $initial_language = $published_item.initial_language}
            <tr class="bglight">

                {* Version/view. *}
                <td><a href={concat( '/content/versionview/', $object.id, '/', $published_item.version, '/', $initial_language.locale )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/ocbootstrap/content/history',, hash( '%version_number', $published_item.version, '%translation', $initial_language.name ) )}">{$published_item.version}</a></td>

                {* Translations *}
                <td>
                    {foreach $published_item.language_list as $lang}
                        {delimiter}<br />{/delimiter}
                        <img src="{$lang.language_code|flag_icon}" alt="{$lang.language_code|wash}" />&nbsp;
                        <a href={concat("/content/versionview/",$object.id,"/",$published_item.version,"/",$lang.language_code,"/")|ezurl}>{$lang.locale.intl_language_name|wash}</a>
                    {/foreach}
                </td>

                {* Creator. *}
                <td>{$published_item.creator.name|wash}</td>

                {* Created. *}
                <td>{$published_item.created|l10n( shortdatetime )}</td>

                {* Modified. *}
                <td>{$published_item.modified|l10n( shortdatetime )}</td>

            </tr>
            {undef $initial_language}
        </table>

        {if $newerDraftVersionList|count|ge(1)}
            <h3>{'New drafts [%newerDraftCount]'|i18n( 'design/ocbootstrap/content/history',, hash( '%newerDraftCount', $newerDraftVersionListCount ) )}</h3>

            <table class="table table-striped table-sm" cellspacing="0">
            <tr>
                <th>{'Version'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th>{'Modified translation'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th>{'Creator'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th>{'Modified'|i18n( 'design/ocbootstrap/content/history' )}</th>
            </tr>

            {foreach $newerDraftVersionList as $draft_version
                sequence array( bglight, bgdark ) as $seq}
            {def $initial_language = $draft_version.initial_language}
            <tr class="{$seq}">

                {* Version/view. *}
                <td><a href={concat( '/content/versionview/', $object.id, '/', $draft_version.version, '/', $initial_language.locale )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/ocbootstrap/content/history',, hash( '%version_number', $draft_version.version, '%translation', $initial_language.name ) )}">{$draft_version.version}</a></td>

                {* Modified translation. *}
                <td>
                    <img src="{$initial_language.locale|flag_icon}" alt="{$initial_language.locale}" />&nbsp;<a href={concat('/content/versionview/', $object.id, '/', $draft_version.version, '/', $initial_language.locale, '/' )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/ocbootstrap/content/history',, hash( '%translation', $initial_language.name, '%version_number', $draft_version.version ) )}" >{$initial_language.name|wash}</a>
                </td>

                {* Creator. *}
                <td>{$draft_version.creator.name|wash}</td>

                {* Created. *}
                <td>{$draft_version.created|l10n( shortdatetime )}</td>

                {* Modified. *}
                <td>{$draft_version.modified|l10n( shortdatetime )}</td>

            </tr>
            {undef $initial_language}
            {/foreach}
            </table>
        {/if}

    {elseif and( is_set( $object ), is_set( $diff ), is_set( $oldVersion ), is_set( $newVersion ) )}

        {literal}<script type="text/javascript">function show( element, method ) {document.getElementById( element ).className = method;}</script>{/literal}


        <h2><a href="{concat( '/content/history/', $object.id, '/' )|ezurl(no)}"><i class="fa fa-history"></i> {$object.name|wash()}</a></h2>
        <h3 class="text-center mb-3">{'Differences between versions %oldVersion and %newVersion'|i18n( 'design/ocbootstrap/content/history',, hash( '%oldVersion', $oldVersion, '%newVersion', $newVersion ) )}</h3>

        <div id="diffview">

            {*<script type="text/javascript">
            document.write('<div class="context-toolbar"><div class="block"><ul><li><a href="#" onclick="show(\'diffview\', \'previous\'); return false;">{'Old version'|i18n( 'design/ocbootstrap/content/history' )}</a></li><li><a href="#" onclick="show(\'diffview\', \'inlinechanges\'); return false;">{'Inline changes'|i18n( 'design/ocbootstrap/content/history' )}</a></li><li><a href="#" onclick="show(\'diffview\', \'blockchanges\'); return false;">{'Block changes'|i18n( 'design/ocbootstrap/content/history' )}</a></li><li><a href="#" onclick="show(\'diffview\', \'latest\'); return false;">{'New version'|i18n( 'design/ocbootstrap/content/history' )}</a></li></ul></div></div>');
            </script>*}

            <table class="table table-striped table-sm" cellspacing="0">
            {foreach $object.data_map as $attr}
            <tr>
                <td><h6>{$attr.contentclass_attribute.name}</h6></td>
                <td>
                    <div class="attribute-view-diff">
                        {attribute_diff_gui view=diff attribute=$attr old=$oldVersion new=$newVersion diff=$diff[$attr.contentclassattribute_id]}
                    </div>
                </td>
            </tr>
            {/foreach}
            </table>

        </div>

        <div class="clearfix">
            <form class="float-right" name="versionsback" action={concat( '/content/history/', $object.id, '/' )|ezurl} method="post">
                <button type="submit" class="btn btn-link go-back" name="BackButton">
                    {display_icon('it-arrow-left', 'svg', 'icon icon-sm mr-2 me-2')}
                    {'Back'|i18n( 'design/ocbootstrap/content/history' )}
                </button>
            </form>
        </div>

    {/if}

</div>
