{* Errors START *}
{switch match=$info_code}
{case match='feedback-removed'}
    <div class="message-feedback">
        <h2>{'The selected aliases were successfully removed.'|i18n( 'design/admin/content/urlalias_global' )}</h2>
    </div>
{/case}
{case match='feedback-removed-all'}
    <div class="message-feedback">
        <h2>{'All global aliases were successfully removed.'|i18n( 'design/admin/content/urlalias_global' )}</h2>
    </div>
{/case}
{case match='error-invalid-language'}
    <div class="message-warning">
        <h2>{'The specified language code <%language> is not valid.'|i18n( 'design/admin/content/urlalias_global',, hash('%language', $info_data['language']) )|wash}</h2>
    </div>
{/case}
{case match='error-no-alias-text'}
    <div class="message-warning">
        <h2>{'Text is missing for the URL alias'|i18n( 'design/admin/content/urlalias_global' )}</h2>
        <ul>
            <li>{'Enter text in the input box to create a new alias.'|i18n( 'design/admin/content/urlalias_global' )}</li>
        </ul>
    </div>
{/case}
{case match='error-no-alias-destination-text'}
    <div class="message-warning">
        <h2>{'Text is missing for the URL alias destination'|i18n( 'design/admin/content/urlalias_global' )}</h2>
        <ul>
            <li>{'Enter some text in the destination input box to create a new alias.'|i18n( 'design/admin/content/urlalias_global' )}</li>
        </ul>
    </div>
{/case}
{case match=error-action-invalid}
    <div class="message-error">
        <h2>{'The specified destination URL %url does not exist in the system, cannot create alias for it'|i18n( 'design/admin/content/urlalias_global',, hash('%url', concat( "<", $info_data['aliasText'], ">" ) ) )|wash}</h2>
        <p>{'Ensure that the destination points to a valid entry, one of:'|i18n( 'design/admin/content/urlalias_global' )}</p>
        <ul>
            <li>{'Built-in functionality, e.g. %example.'|i18n( 'design/admin/content/urlalias_global',, hash( '%example', '<i>user/login</i>' ) )}</li>
            <li>{'Existing aliases for the content structure.'|i18n( 'design/admin/content/urlalias_global' )}</li>
        </ul>
    </div>
{/case}
{case match='feedback-alias-cleanup'}
    <div class="message-feedback">
        <h2>{'The URL alias was successfully created, but was modified by the system to <%new_alias>'|i18n( 'design/admin/content/urlalias_global',, hash('%new_alias', $info_data['new_alias'] ) )|wash}</h2>
        <ul>
            {if $info_data['node_id']}
                <li>{'Note that the new alias points to a node and will not be displayed in the global list. It can be examined on the URL-Alias page of the node, %node_link.'|i18n( 'design/admin/content/urlalias_global',, hash( '%node_link', concat( '<a href=', concat( 'content/urlalias/', $info_data['node_id'] )|ezurl, '>', concat( 'content/urlalias/', $info_data['node_id'] ), '</a>' ) ) )}</li>
            {/if}
            <li>{'Invalid characters will be removed or transformed to valid characters.'|i18n( 'design/admin/content/urlalias_global' )}</li>
            <li>{'Existing objects or functionality with the same name take precedence on the name.'|i18n( 'design/admin/content/urlalias_global' )}</li>
        </ul>
    </div>
{/case}
{case match='feedback-alias-created'}
    <div class="message-feedback">
        <h2>{'The URL alias <%new_alias> was successfully created'|i18n( 'design/admin/content/urlalias_global',, hash('%new_alias', $info_data['new_alias'] ) )|wash}</h2>
        {if $info_data['node_id']}
            <ul>
                <li>{'Note that the new alias points to a node and will not be displayed in the global list. It can be examined on the URL-Alias page of the node, %node_link.'|i18n( 'design/admin/content/urlalias_global',, hash( '%node_link', concat( '<a href=', concat( 'content/urlalias/', $info_data['node_id'] )|ezurl, '>', concat( 'content/urlalias/', $info_data['node_id'] ), '</a>' ) ) )}</li>
            </ul>
        {/if}
    </div>
{/case}
{case match='feedback-alias-exists'}
    <div class="message-warning">
        <h2>{'The URL alias &lt;%new_alias&gt; already exists, and it points to &lt;%action_url&gt;'|i18n( 'design/admin/content/urlalias_global',, hash( '%new_alias', concat( "<"|wash, '<a href=', $info_data['url']|ezurl, '>', $info_data['new_alias'], '</a>', ">"|wash ), '%action_url', concat( "<"|wash, '<a href=', $info_data['action_url']|ezurl, '>', $info_data['action_url']|wash, '</a>', ">"|wash ) ) )}</h2>
    </div>
{/case}

{case}
{/case}

{/switch}
{* Errors END *}

{def $aliasList=$filter.items}

<form name="aliasform" method="post" action={"content/urltranslator/"|ezurl}>
    <div class="context-block content-urlalias-global">
        <div class="row">
            <div class="col col-md-8">
                <h1 class="h2">{'Globally defined URL aliases (%alias_count)'|i18n( 'design/admin/content/urlalias_global',, hash( '%alias_count', $filter.count ) )|wash}</h1>
            </div>
            {* Items per page selector. *}
            <div class="col col-md-4 text-right pt-2">
                {foreach $limitList as $limitEntry}
                    <a class="btn btn-xs px-2 py-1 {if eq($limitID, $limitEntry['id'])}btn-outline-primary{else}btn-primary{/if}" href={concat('/user/preferences/set/admin_urlalias_list_limit/', $limitEntry['id'])|ezurl} title="{'Show %number_of items per page.'|i18n( 'design/admin/content/urlalias_global',, hash( '%number_of', $limitEntry['value'] ) )}">{$limitEntry['value']}</a>            {/foreach}
            </div>
        </div>

        {* list here *}
        {if eq( count( $aliasList ), 0)}
            <p class="lead">{"The global list does not contain any aliases."|i18n( 'design/admin/content/urlalias_global' )}</p>
        {else}
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th class="tight"></th>
                        <th>{'URL alias'|i18n( 'design/admin/content/urlalias_global' )}</th>
                        <th>{'Destination'|i18n( 'design/admin/content/urlalias_global' )}</th>
                        <th class="text-center">{'Language'|i18n( 'design/admin/content/urlalias_global' )}</th>
                        <th>{'Type'|i18n( 'design/admin/content/urlalias_global' )}</th>
                    </tr>
                </thead>
                <tbody>
                {foreach $aliasList as $element}
                    <tr>
                        <td>
                            <input type="checkbox" name="ElementList[]"
                                   value="{$element.parent}.{$element.text_md5}.{$element.language_object.locale}"/>
                        </td>
                        <td width="30%">
                            {def $url_alias_path=""}
                            {foreach $element.path_array as $el}
                                {if ne( $el.action, "nop:" )}
                                    {set $url_alias_path=concat($url_alias_path, '/','<a href=', concat("/",$el.path)|ezurl, ">",$el.text|wash,'</a>')}
                                {else}
                                    {set $url_alias_path=concat($url_alias_path, '/', $el.text|wash)}
                                {/if}
                            {/foreach}
                            {$url_alias_path}
                            {undef $url_alias_path}
                        </td>
                        <td width="30%">
                            <a href={$element.action_url|ezurl}>{$element.action_url}</a>
                        </td>
                        <td class="text-center">
                            <img src="{$element.language_object.locale|flag_icon}" width="18" height="12"
                                 title="{$element.language_object.locale|wash}"
                                 alt="{$element.language_object.locale|wash}"/>
                            {if $element.always_available}
                                <small class="d-block"><em>{'Always available'|i18n( 'design/admin/content/urlalias_global' )}</em></small>
                            {/if}
                        </td>
                        <td>
                            {if $element.alias_redirects}
                                {'Redirect'|i18n( 'design/admin/content/urlalias_global' )}
                            {else}
                                {'Direct'|i18n( 'design/admin/content/urlalias_global' )}
                            {/if}
                        </td>
                    </tr>
                {/foreach}
                </tbody>
            </table>
            {include name=navigator
                     uri='design:navigator/google.tpl'
                     page_uri='content/urltranslator/'
                     item_count=$filter.count
                     view_parameters=$view_parameters
                     item_limit=$filter.limit}
            <div class="my-3 row">
                <div class="col">
                    <input class="btn btn-xs btn-danger" type="submit" name="RemoveAliasButton"
                           value="{'Remove selected'|i18n( 'design/admin/content/urlalias_global' )}"
                           title="{'Remove selected aliases from the list above.'|i18n( 'design/admin/content/urlalias_global' )}"
                           onclick="return confirm( '{'Are you sure you want to remove the selected aliases?'|i18n( 'design/admin/content/urlalias_global' )}' );"/>
                </div>
                <div class="col text-right">
                    <input class="btn btn-xs btn-danger" type="submit" name="RemoveAllAliasesButton"
                           value="{'Remove all'|i18n( 'design/admin/content/urlalias_global' )}"
                           title="{'Remove all global aliases.'|i18n( 'design/admin/content/urlalias_global' )}"
                           onclick="return confirm( '{'Are you sure you want to remove all global aliases?'|i18n( 'design/admin/content/urlalias_global' )}' );"/>
                </div>
            </div>
        {/if}


        {* Generated aliases context block start *}
        {* Generated aliases window. *}
        <div class="my-4 p-4 border rounded">
            <h2 class="h3">{'Create new alias'|i18n( 'design/admin/content/urlalias' )}</h2>
            <div class="row">
                <div class="col-4 mb-3">
                    {* Alias name field. *}
                    <label for="ezcontent_urlalias_global_source">{'New URL alias'|i18n( 'design/admin/content/urlalias_global' )}:</label>
                    <input id="ezcontent_urlalias_global_source" class="form-control" type="text" name="AliasSourceText"
                           value="{$aliasSourceText|wash}"
                           placeholder="my/Awesome/Custom/url"
                           title="{'Enter the URL for the new alias. Use forward slashes (/) to create subentries.'|i18n( 'design/admin/content/urlalias_global' )}"/>
                </div>
                <div class="col-5 mb-3">
                    {* Destination field. *}
                    <label for="ezcontent_urlalias_global_destination">{'Destination (path to existing functionality or resource)'|i18n( 'design/admin/content/urlalias_global' )}:</label>
                    <input id="ezcontent_urlalias_global_destination" class="form-control" type="text" name="AliasDestinationText"
                           value="{$aliasDestinationText|wash}"
                           placeholder="content/download/for/example"
                           title="{'Enter the destination URL for the new alias. Use forward slashes (/) to create subentries.'|i18n( 'design/admin/content/urlalias_global' )}"/>
                </div>
                <div class="col-3 mb-3">
                        <label for="LanguageCode">{'Language'|i18n( 'design/admin/content/urlalias_global' )}</label>
                        {* Language dropdown. *}
                        <div class="block">
                            <select name="LanguageCode" id="LanguageCode" class="form-control"
                                    title="{'Choose the language for the new URL alias.'|i18n( 'design/admin/content/urlalias_global' )}">
                                {foreach $languages as $language}
                                    <option value="{$language.locale|wash}">{$language.name|wash}</option>
                                {/foreach}
                            </select>
                        </div>
                        <label class="mt-1">
                        {* All languages flag. *}
                            <input type="checkbox" name="AllLanguages" id="all-languages" value="all-languages"
                                    class="radio" for="all-languages"
                                    title="{'Makes the alias available in languages other than the one specified.'|i18n( 'design/admin/content/urlalias_global' )}" />
                            {'Include in other languages'|i18n( 'design/admin/content/urlalias' )}
                        </label>
                </div>
                {* Alias should redirect *}
                <div class="col-12 mb-1">
                    <input type="checkbox" name="AliasRedirects" id="alias_redirects" value="alias_redirects"
                           checked="checked"/>
                    <label class="radio" for="alias_redirects"
                           title="{'Alias should redirect to its destination'|i18n( 'design/admin/content/urlalias_global' )}">{'Alias should redirect to its destination'|i18n( 'design/admin/content/urlalias' )}</label>
                    <p>{'With <em>Alias should redirect to its destination</em> checked eZ Publish will redirect to the destination using a HTTP 301 response. Un-check it and the URL will stay the same &#8212; no redirection will be performed.'|i18n( 'design/admin/content/urlalias' )}
                    </p>
                </div>

                <div class="col-12">
                    {* Create button. *}
                    <input class="btn btn-success" type="submit" name="NewAliasButton"
                           value="{'Create'|i18n( 'design/admin/content/urlalias_global' )}"
                           title="{'Create a new global URL alias.'|i18n( 'design/admin/content/urlalias_global' )}"/>
                </div>

            </div>

</form>

{literal}
    <script type="text/javascript">
      jQuery(function ($)//called on document.ready
      {
        with (document.aliasform) {
          for (var i = 0, l = elements.length; i < l; i++) {
            if (elements[i].type == 'text' && elements[i].name == 'AliasSourceText') {
              elements[i].select();
              elements[i].focus();
              return;
            }
          }
        }
      });
    </script>
{/literal}
