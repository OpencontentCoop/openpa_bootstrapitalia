{* Errors START *}
{switch match=$info_code}
{case match='feedback-removed'}
    <div class="message-feedback">
        <h2>{'The selected aliases were successfully removed.'|i18n( 'design/admin/content/urlalias' )}</h2>
    </div>
{/case}
{case match='feedback-removed-all'}
    <div class="message-feedback">
        <h2>{'All aliases for this node were successfully removed.'|i18n( 'design/admin/content/urlalias' )}</h2>
    </div>
{/case}
{case match='error-invalid-language'}
    <div class="message-warning">
        <h2>{'The specified language code <%language> is not valid.'|i18n( 'design/admin/content/urlalias',, hash('%language', $info_data['language']) )|wash}</h2>
    </div>
{/case}
{case match='error-no-alias-text'}
    <div class="message-warning">
        <h2>{'Text is missing for the URL alias'|i18n( 'design/admin/content/urlalias' )}</h2>
        <ul>
            <li>{'Enter text in the input box to create a new alias.'|i18n( 'design/admin/content/urlalias' )}</li>
        </ul>
    </div>
{/case}
{case match='feedback-alias-cleanup'}
    <div class="message-feedback">
        <h2>{'The URL alias was successfully created, but was modified by the system to <%new_alias>'|i18n( 'design/admin/content/urlalias',, hash('%new_alias', $info_data['new_alias'] ) )|wash}</h2>
        <ul>
            <li>{'Invalid characters will be removed or transformed to valid characters.'|i18n( 'design/admin/content/urlalias' )}</li>
            <li>{'Existing objects or functionality with the same name take precedence on the name.'|i18n( 'design/admin/content/urlalias' )}</li>
        </ul>
    </div>
{/case}
{case match='feedback-alias-created'}
    <div class="message-feedback">
        <h2>{'The URL alias <%new_alias> was successfully created'|i18n( 'design/admin/content/urlalias',, hash('%new_alias', $info_data['new_alias'] ) )|wash}</h2>
    </div>
{/case}
{case match='feedback-alias-exists'}
    <div class="message-warning">
        <h2>{'The URL alias &lt;%new_alias&gt; already exists, and it points to &lt;%action_url&gt;'|i18n( 'design/admin/content/urlalias',, hash( '%new_alias', concat( "<"|wash, '<a href=', $info_data['url']|ezurl, '>', $info_data['new_alias'], '</a>', ">"|wash ), '%action_url', concat( "<"|wash, '<a href=', $info_data['action_url']|ezurl, '>', $info_data['action_url']|wash, '</a>', ">"|wash ) ) )}</h2>
    </div>
{/case}
{case}
{/case}
{/switch}
{* Errors END *}


{def $aliasList=$filter.items}

<form name="aliasform" method="post" action={concat('content/urlalias/', $node.node_id)|ezurl}>

    <div class="content-urlalias">

        <h1 class="h2">{'URL aliases for <%node_name> (%alias_count)'|i18n( 'design/admin/content/urlalias',, hash( '%node_name', $node.name, '%alias_count', $filter.count ) )|wash}</h1>

        {* list here *}
        {if eq( count( $aliasList ), 0)}
            <p class="lead">
                {"The current item does not have any aliases associated with it."|i18n( 'design/admin/content/urlalias' )}
            </p>
        {else}
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th class="tight"></th>
                        <th>{'URL alias'|i18n( 'design/admin/content/urlalias' )}</th>
                        <th>{'Language'|i18n( 'design/admin/content/urlalias' )}</th>
                        <th>{'Type'|i18n( 'design/admin/content/urlalias' )}</th>
                    </tr>
                </thead>
                <tbody>
                {foreach $aliasList as $element}
                    <tr>
                        {* Remove. *}
                        <td>
                            <input type="checkbox" name="ElementList[]"
                                   value="{$element.parent}.{$element.text_md5}.{$element.language_object.locale}"/>
                        </td>
                        <td>
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
                        <td>
                            <img src="{$element.language_object.locale|flag_icon}" width="18" height="12" alt="{$element.language_object.locale|wash}"/>
                            &nbsp;
                            {$element.language_object.name|wash}
                        </td>
                        <td>
                            {if $element.alias_redirects}
                                {'Redirect'|i18n( 'design/admin/content/urlalias' )}
                            {else}
                                {'Direct'|i18n( 'design/admin/content/urlalias' )}
                            {/if}
                        </td>
                    </tr>
                {/foreach}
                </tbody>
            </table>
            {include name=navigator
                     uri='design:navigator/google.tpl'
                     page_uri=concat('content/urlalias/', $node.node_id)
                     item_count=$filter.count
                     view_parameters=$view_parameters
                     node_id=$node.node_id
                     item_limit=$filter.limit}
            {if $node.can_edit}
                <div class="my-3 row">
                    <div class="col">
                        <input class="btn btn-xs btn-danger" type="submit" name="RemoveAliasButton"
                               value="{'Remove selected'|i18n( 'design/admin/content/urlalias' )}"
                               title="{'Remove selected alias from the list above.'|i18n( 'design/admin/content/urlalias' )}"
                               onclick="return confirm( '{'Are you sure you want to remove the selected aliases?'|i18n( 'design/admin/content/urlalias' )}' );"/>
                    </div>
                    <div class="col text-right">
                        <input class="btn btn-xs btn-danger" type="submit" name="RemoveAllAliasesButton"
                               value="{'Remove all'|i18n( 'design/admin/content/urlalias' )}"
                               title="{'Remove all aliases for this node.'|i18n( 'design/admin/content/urlalias' )}"
                               onclick="return confirm( '{'Are you sure you want to remove all aliases for this node?'|i18n( 'design/admin/content/urlalias' )}' );"/>
                    </div>
                </div>
            {/if}
        {/if}
    </div>


    {* Create new alias window. *}
    <div class="my-4 p-4 border rounded">
        <h2 class="h3">{'Create new alias'|i18n( 'design/admin/content/urlalias' )}</h2>
        <div class="row">
            {* Name field. *}
            <div class="col-5 mb-3">
                <label for="ezcontent_urlalias_name">{"URL alias name:"|i18n( 'design/admin/content/urlalias' )}</label>
                <input id="ezcontent_urlalias_name" class="form-control" type="text" name="AliasText" value="{$aliasText|wash}"
                       title="{'Enter the URL for the new alias. Use forward slashes (/) to create subentries.'|i18n( 'design/admin/content/urlalias' )}"/>
            </div>
            <div class="col-5 mb-3">
                <label for="ezcontent_urlalias_destination">{"Destination:"|i18n( 'design/admin/content/urlalias' )}</label>
                <input id="ezcontent_urlalias_destination" disabled="disabled" class="form-control" type="text"
                       name="DestinationText" value="{$node.name|shorten(40)|wash}"
                       title="{'Destination.'|i18n( 'design/admin/content/urlalias' )}"/>
            </div>
            {* Language dropdown. *}
            <div class="col-2 mb-3">
                <label for="ezcontent_urlalias_language">{"Language:"|i18n( 'design/admin/content/urlalias' )}</label>
                {if $node.can_edit}
                    <select id="ezcontent_urlalias_language" name="LanguageCode" class="form-control"
                            title="{'Choose the language for the new URL alias.'|i18n( 'design/admin/content/urlalias' )}">
                        {foreach $languages as $language}
                            <option value="{$language.locale|wash}"{if $language.locale|eq($node.object.current_language)} selected="selected"{/if}>{$language.name|wash}</option>
                        {/foreach}
                    </select>
                {else}
                    <select id="ezcontent_urlalias_language" name="LanguageCode" disabled="disabled">
                        <option value="">{'Not available'|i18n( 'design/admin/content/urlalias')}</option>
                    </select>
                {/if}
            </div>
            {* Alias should redirect *}
            <div class="col-12 mb-1">
                <input type="checkbox" name="AliasRedirects" id="alias_redirects" value="alias_redirects"
                       checked="checked"/>
                <label class="radio" for="alias_redirects"
                       title="{'Alias should redirect to its destination'|i18n( 'design/admin/content/urlalias_global' )}">{'Alias should redirect to its destination'|i18n( 'design/admin/content/urlalias' )}</label>
                <p>{"With <em>Alias should redirect to its destination</em> checked eZ Publish will redirect to the destination using a HTTP 301 response. Un-check it and the URL will stay the same &#8212; no redirection will be performed."|i18n( 'design/admin/content/urlalias' )}</p>
            </div>
            {* Relative flag. *}
            <div class="col-12 mb-3">
                {if $node.parent.parent.node_id|eq(1)}
                    <input type="checkbox" name="ParentIsRoot" id="parent-is-root" value="{$node.node_id}" checked="checked"
                           disabled="disabled"/>
                {else}
                    <input type="checkbox" name="ParentIsRoot" id="parent-is-root" value="{$node.node_id}"
                           checked="checked"/>
                {/if}
                <label class="radio" for="parent-is-root"
                       title="{'If checked the alias will start from the parent of the current node. If un-checked the aliases will start from the root of the site.'|i18n( 'design/admin/content/urlalias' )}">
                    {'Place alias on the site root'|i18n( 'design/admin/content/urlalias' )}
                </label>
                <p class="text-muted">
                    {if $node.parent.parent.node_id|eq(1)}
                        {"The new alias be placed under %link"|i18n( 'design/admin/content/urlalias', '', hash( '%link', concat( '<em><a href=', $node.parent.url_alias|ezurl, '>', $node.parent.name|wash, '</a></em>' ) ) )}
                    {else}
                        {"<em>Un-check</em> to create the new alias under %link. Leave it checked and the new alias will be created on <em><a href='/'>%siteroot</a></em>."|i18n( 'design/admin/content/urlalias', '', hash( '%link', concat( '<em><a href=', $node.parent.url_alias|ezurl, '>', $node.parent.name|wash, '</a></em>' ),
                    '%siteroot', 'homepage' ) )}
                    {/if}
                </p>
            </div>
            <div class="col-12">
                {* Create button. *}
                <input class="btn btn-success" type="submit" name="NewAliasButton"
                       value="{'Create'|i18n( 'design/admin/content/urlalias_global' )}"
                       title="{'Create a new global URL alias.'|i18n( 'design/admin/content/urlalias_global' )}"/>
            </div>
        </div>
    </div>

    <div class="mt-5">
        <h2 class="h3">{'Generated aliases (%count)'|i18n( 'design/admin/content/urlalias',, hash('%count', count( $elements ) ) )}</h2>
        <p class="lead">{"Note that these entries are automatically generated from the name of the object. To change these names you must edit the object in the specific language and publish the changes."|i18n( 'design/admin/content/urlalias' )}</p>
        <table class="table table-striped">
            <thead>
            <tr>
                <th>{'URL alias'|i18n( 'design/admin/content/urlalias' )}</th>
                <th>{'Language'|i18n( 'design/admin/content/urlalias' )}</th>
            </tr>
            </thead>
            {def $isCurrentLanguage=false()
                 $language_obj=false()
                 $locale=false()
                 $img_title=false()}
            <tbody>
            {foreach $elements as $element}
                {set $language_obj=$element.language_object
                     $locale=$language_obj.locale
                     $isCurrentLanguage=eq( $locale, $node.object.current_language )}
                <tr>
                    <td>
                        <a href={concat("/",$element.path)|ezurl}>
                            {if $isCurrentLanguage}<b>{/if}
                            {concat("/",$element.path)|wash}
                            {if $isCurrentLanguage}</b>{/if}
                        </a>
                    </td>
                    <td>
                        <img src="{$element.language_object.locale|flag_icon}" width="18" height="12"
                             alt="{$element.language_object.locale|wash}"/>
                        &nbsp;
                        {$element.language_object.name|wash}
                    </td>
                </tr>
            {/foreach}
            </tbody>
        </table>
    </div>


</form>

{literal}
    <script type="text/javascript">
      jQuery(function ($)//called on document.ready
      {
        with (document.aliasform) {
          for (var i = 0, l = elements.length; i < l; i++) {
            if (elements[i].type == 'text' && elements[i].name == 'AliasText') {
              elements[i].select();
              elements[i].focus();
              return;
            }
          }
        }
      });
    </script>
{/literal}
