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


    <form class="float-right" name="versionsback" action="{concat( '/content/history/', $object.id, '/' )|ezurl(no)}" method="post">
        {if is_set( $redirect_uri )}
            <input class="text" type="hidden" name="RedirectURI" value="{$redirect_uri}" />
        {/if}
        <button type="submit" class="btn btn-link go-back" name="BackButton">
            {display_icon('it-arrow-left', 'svg', 'icon icon-sm mr-2 me-2', 'Back'|i18n( 'design/ocbootstrap/content/history' ))}
            {'Back'|i18n( 'design/ocbootstrap/content/history' )}
        </button>
{*        <a href="{concat( '/content/history/', $object.id, '/' )|ezurl(no)}">*}
{*            {display_icon('it-arrow-left', 'svg', 'icon icon-sm mr-2 me-2', 'Back'|i18n( 'design/ocbootstrap/content/history' ))}*}
{*            {'Back'|i18n( 'design/ocbootstrap/content/history' )}*}
{*        </a>*}
    </form>
    <h2 class="mb-4">
        <i class="fa fa-history"></i> {$object.name|wash()}
    </h2>

    {def $page_limit   = 30
         $list_count   = fetch(content,version_count, hash(contentobject, $object))
         $current_user = fetch( 'user', 'current_user' )}


    <form name="versionsform" action="{concat( '/content/history/', $object.id, '/' )|ezurl(no)}" method="post">

        {if $list_count}
            <table class="table table-sm" cellspacing="0">
            <thead>
                <tr>
                    <th class="tight"></th>
                    <th>{'Version'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Status'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    {if and(is_approval_enabled(), current_class_needs_approval($object.class_identifier))}
                        <th>{'Approval'|i18n( 'bootstrapitalia/moderation' )}</th>
                    {/if}
                    <th>{'Modified translation'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Creator'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Modified'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th class="tight">&nbsp;</th>
                    <th class="tight">&nbsp;</th>
                </tr>
            </thead>
            <tbody>
            {foreach fetch( content, version_list, hash( 'contentobject', $object,
                                                         'limit', $page_limit,
                                                         'offset', $view_parameters.offset ) ) as $version}

            {def $initial_language = $version.initial_language}
            <tr {if array(2)|contains($version.status)}class="bg-light"{/if}>

                {* Remove. *}
                <td style="vertical-align:middle">
                    <!--{$version.id} {$version.status}-->
                    {if and( $version.can_remove, array( 0, 2, 3, 4, 5, 6 )|contains( $version.status ) )}
                        <input type="checkbox" name="DeleteIDArray[]" value="{$version.id}" title="{'Select version #%version_number for removal.'|i18n( 'design/ocbootstrap/content/history',, hash( '%version_number', $version.version ) )}" />
                    {/if}
                </td>

                {* Version/view. *}
                <td style="vertical-align:middle">
                    <a href={concat( '/content/versionview/', $object.id, '/', $version.version, '/', $initial_language.locale )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/ocbootstrap/content/history',, hash( '%version_number', $version.version, '%translation', $initial_language.name ) )}">{$version.version}</a>
                </td>

                {* Status. *}
                <td style="vertical-align:middle">
                    {$version.status|choose( 'Draft'|i18n( 'design/ocbootstrap/content/history' ), 'Published'|i18n( 'design/ocbootstrap/content/history' ), 'Pending'|i18n( 'design/ocbootstrap/content/history' ), 'Archived'|i18n( 'design/ocbootstrap/content/history' ), 'Rejected'|i18n( 'design/ocbootstrap/content/history' ), 'Untouched draft'|i18n( 'design/ocbootstrap/content/history' ) )}
                </td>

                {if and(is_approval_enabled(), current_class_needs_approval($object.class_identifier))}
                    <td style="vertical-align:middle">
                        {def $approval_status = approval_status_by_version_id($version.id)|choose( 'Pending'|i18n( 'bootstrapitalia/moderation' ), 'Approved'|i18n( 'bootstrapitalia/moderation' ), 'Rejected'|i18n( 'bootstrapitalia/moderation' ) )}
                        {if $approval_status|ne('')}
                            <a class="chip chip-simple chip-info" href="{concat('/bootstrapitalia/approval/version/', $version.id)|ezurl(no)}"><span class="chip-label">{$approval_status}</span></a>
                        {/if}
                        {undef $approval_status}
                    </td>
                {/if}

                {* Modified translation. *}
                <td style="vertical-align:middle">
                    <img src="{$initial_language.locale|flag_icon}" alt="{$initial_language.locale}" />&nbsp;<a href={concat('/content/versionview/', $object.id, '/', $version.version, '/', $initial_language.locale, '/' )|ezurl} title="{'View the contents of version #%version_number. Translation: %translation.'|i18n( 'design/ocbootstrap/content/history',, hash( '%translation', $initial_language.name, '%version_number', $version.version ) )}" >{$initial_language.name|wash}</a>
                </td>

                {* Creator. *}
                <td style="vertical-align:middle">{$version.creator.name|wash}</td>

                {* Created. *}
                <td style="vertical-align:middle">{$version.created|l10n( shortdatetime )}</td>

                {* Modified. *}
                <td style="vertical-align:middle">{$version.modified|l10n( shortdatetime )}</td>

                {* Copy button. *}
                <td style="vertical-align:middle" class="text-center">
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
                        <button class="" type="submit" name="HistoryCopyVersionButton[{$version.version}]"
                                title="{'Create a copy of version #%version_number.'|i18n( 'design/ocbootstrap/content/history',, hash( '%version_number', $version.version ) )}">
                            <span class="fa-stack">
                              <i class="fa fa-circle fa-stack-2x"></i>
                              <i class="fa fa-copy fa-stack-1x fa-inverse"></i>
                            </span>
                        </button>
                      {/if}
                    {elseif and(
                        is_set($object.state_identifier_array),
                        $object.state_identifier_array|contains('opencity_lock/locked'),
                        current_user_can_lock_edit($object)
                    )}
                        {if eq($version.status, 3)}
                            <a href="{concat('/bootstrapitalia/version_revert/', $object.id, '/', $version.version)|ezurl(no)}" title="Restore version">
                                <span class="fa-stack">
                                  <i class="fa fa-circle fa-stack-2x"></i>
                                  <i class="fa fa-refresh fa-stack-1x fa-inverse"></i>
                                </span>
                            </a>
                        {elseif and(eq($version.status, 0), $version.creator_id|eq( $current_user.contentobject_id ))}
                            <a href="{concat('/bootstrapitalia/version_remove/', $object.id, '/', $version.version)|ezurl(no)}" title="Restore version">
                                <span class="fa-stack">
                                  <i class="fa fa-circle fa-stack-2x"></i>
                                  <i class="fa fa-trash fa-stack-1x fa-inverse"></i>
                                </span>
                            </a>
                        {/if}
                    {/if}
                    {undef $can_edit_lang}
                </td>

                {* Edit button. *}
                <td style="vertical-align:middle" class="text-center">
                    {if and( array(0, 5)|contains($version.status), $version.creator_id|eq( $current_user.contentobject_id ), $can_edit ) }
                        <button class="" type="submit" name="HistoryEditButton[{$version.version}]" value="" title="{'Edit the contents of version #%version_number.'|i18n( 'design/ocbootstrap/content/history',, hash( '%version_number', $version.version ) )}">
                            <span class="fa-stack">
                              <i class="fa fa-circle fa-stack-2x"></i>
                              <i class="fa fa-pencil fa-stack-1x fa-inverse"></i>
                            </span>
                        </button>
                    {/if}
                </td>

            </tr>
            {undef $initial_language}
            {/foreach}
            </tbody>
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
                <input class="btn btn-danger btn-xs" type="submit" name="RemoveButton" value="{'Remove selected'|i18n( 'design/ocbootstrap/content/history' )}" title="{'Remove the selected versions from the object.'|i18n( 'design/ocbootstrap/content/history' )}" />
                <input type="hidden" name="DoNotEditAfterCopy" value="" />
            </div>
        </div>
        {/if}

    </form>

    <div class="py-3">
        <h4>{'Published version'|i18n( 'design/ocbootstrap/content/history' )}</h4>
        <table class="table table-sm" cellspacing="0">
        <thead>
            <tr>
                <th>{'Version'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th>{"Translations"|i18n("design/ocbootstrap/content/history")}</th>
                <th>{'Creator'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
                <th>{'Modified'|i18n( 'design/ocbootstrap/content/history' )}</th>
            </tr>
        </thead>

        <tbody>
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
        </tbody>
    </table>
    </div>

    {if $newerDraftVersionList|count|ge(1)}
    <div class="py-3">
        <h4>{'New drafts [%newerDraftCount]'|i18n( 'design/ocbootstrap/content/history',, hash( '%newerDraftCount', $newerDraftVersionListCount ) )}</h4>
        <table class="table table-sm" cellspacing="0">
            <thead>
                <tr>
                    <th>{'Version'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Modified translation'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Creator'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Created'|i18n( 'design/ocbootstrap/content/history' )}</th>
                    <th>{'Modified'|i18n( 'design/ocbootstrap/content/history' )}</th>
                </tr>
            </thead>

            <tbody>
            {foreach $newerDraftVersionList as $draft_version}
            {def $initial_language = $draft_version.initial_language}
            <tr>
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
            </tbody>
        </table>
    </div>
    {/if}

    {if and($object.can_diff, $object.versions|count|gt(1))}
        {def $languages=$object.languages}
        <div class="clearfix mt-4 mb-4 text-center">
            <form action={concat( $module.functions.history.uri, '/', $object.id, '/' )|ezurl} method="post">
                <div class="input-group mb-3 justify-content-center">
                    <select name="Language" class="custom-select px-3 rounded-start">
                        {foreach $languages as $lang}
                            <option value="{$lang.locale}">{$lang.name|wash}</option>
                        {/foreach}
                    </select>
                    <select name="FromVersion" class="custom-select px-3">
                        {foreach $object.versions as $ver}
                            <option {if eq( $ver.version, $selectOldVersion)}selected="selected"{/if} value="{$ver.version}">{$ver.version|wash}</option>
                        {/foreach}
                    </select>
                    <select name="ToVersion" class="custom-select px-3">
                        {foreach $object.versions as $ver}
                            <option {if eq( $ver.version, $selectNewVersion)}selected="selected"{/if} value="{$ver.version}">{$ver.version|wash}</option>
                        {/foreach}
                    </select>
                    <div class="input-group-append">
                        <input class="btn btn-primary" type="submit" name="DiffButton" value="{'Show differences'|i18n( 'design/ocbootstrap/content/history' )}" />
                    </div>
                </div>
                <input type="hidden" name="ObjectID" value="{$object.id}" />
            </form>
        </div>
    {/if}

    {if and( is_set( $object ), is_set( $diff ), is_set( $oldVersion ), is_set( $newVersion ) )}

    <div class="my-5 p-4 rounded border">

        {literal}<script type="text/javascript">function show( element, method ) {document.getElementById( element ).className = method;}</script>{/literal}

        <h3 class="mb-3 font-weight-normal pb-3" style="font-weight: normal;">{'Differences between versions %oldVersion and %newVersion'|i18n( 'design/ocbootstrap/content/history',, hash(
            '%oldVersion', concat($oldVersion, ' (', $oldVersionObject.status|choose( 'Draft'|i18n( 'design/ocbootstrap/content/history' ), 'Published'|i18n( 'design/ocbootstrap/content/history' ), 'Pending'|i18n( 'design/ocbootstrap/content/history' ), 'Archived'|i18n( 'design/ocbootstrap/content/history' ), 'Rejected'|i18n( 'design/ocbootstrap/content/history' ), 'Untouched draft'|i18n( 'design/ocbootstrap/content/history' ) ), ')'),
            '%newVersion', concat($newVersion, ' (', $newVersionObject.status|choose( 'Draft'|i18n( 'design/ocbootstrap/content/history' ), 'Published'|i18n( 'design/ocbootstrap/content/history' ), 'Pending'|i18n( 'design/ocbootstrap/content/history' ), 'Archived'|i18n( 'design/ocbootstrap/content/history' ), 'Rejected'|i18n( 'design/ocbootstrap/content/history' ), 'Untouched draft'|i18n( 'design/ocbootstrap/content/history' ) ), ')')
        ) )}</h3>

        <div id="diffview">
            {*<script type="text/javascript">
            document.write('<div class="context-toolbar"><div class="block"><ul><li><a href="#" onclick="show(\'diffview\', \'previous\'); return false;">{'Old version'|i18n( 'design/ocbootstrap/content/history' )}</a></li><li><a href="#" onclick="show(\'diffview\', \'inlinechanges\'); return false;">{'Inline changes'|i18n( 'design/ocbootstrap/content/history' )}</a></li><li><a href="#" onclick="show(\'diffview\', \'blockchanges\'); return false;">{'Block changes'|i18n( 'design/ocbootstrap/content/history' )}</a></li><li><a href="#" onclick="show(\'diffview\', \'latest\'); return false;">{'New version'|i18n( 'design/ocbootstrap/content/history' )}</a></li></ul></div></div>');
            </script>*}
            <table class="table table-sm" cellspacing="0">
            {foreach $object.data_map as $attr}
                <tr>
                    <td><strong>{$attr.contentclass_attribute.name}</strong></td>
                    <td>
                        <div class="attribute-view-diff">
                            {attribute_diff_gui view=diff attribute=$attr old=$oldVersion new=$newVersion diff=$diff[$attr.contentclassattribute_id]}
                        </div>
                    </td>
                </tr>
            {/foreach}
            </table>

        </div>
    </div>
    {/if}

</div>

{literal}
    <style>
    ins {
        text-decoration: underline;
        text-decoration-style: wavy;
    }
    del {
        text-decoration: line-through;
    }
    .attribute-view-diff-old label{
        margin-right: 5px;
        font-size: .8em;
    }
    .attribute-view-diff-new label{
        margin-right: 5px;
        font-size: .8em;
    }
    .attribute-view-diff th {
        font-size: .7em;
        line-height: 1;
        white-space: nowrap;
    }
    .attribute-view-diff td {
        font-size: .8em;
        vertical-align:center
    }
    .attribute-view-diff td label {
        background: #eee;
        border-radius: 4px;
        padding: 0 4px;
    }
    }
    </style>
{/literal}