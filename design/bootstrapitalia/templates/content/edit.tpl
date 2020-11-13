{def $_redirect = false()}
{if $object.id|eq(fetch(user, current_user).contentobject_id)}
    {set $_redirect = 'user/edit'}
{elseif ezhttp_hasvariable( 'RedirectURIAfterPublish', 'session' )}
    {set $_redirect = ezhttp( 'RedirectURIAfterPublish', 'session' )}
{elseif $object.main_node_id}
    {set $_redirect = concat( 'content/view/full/', $object.main_node_id )}
{elseif $object.main_parent_node_id}
    {set $_redirect = concat( 'content/view/full/', $object.main_parent_node_id )}
{elseif ezhttp( 'url', 'get', true() )}
    {set $_redirect = ezhttp( 'url', 'get' )}
{elseif ezhttp_hasvariable( 'LastAccessesURI', 'session' )}
    {set $_redirect = ezhttp( 'LastAccessesURI', 'session' )}
{/if}

{def $tab = ''}
{if and( ezhttp_hasvariable( 'tab', 'get' ), is_set( $view_parameters.tab )|not() )}    
    {set $_redirect = concat( $_redirect, '/(tab)/', ezhttp( 'tab', 'get' ) )}
{/if}

<form class="edit" enctype="multipart/form-data" method="post" action={concat("/content/edit/",$object.id,"/",$edit_version,"/",$edit_language|not|choose(concat($edit_language,"/"),''))|ezurl}>
    
    {include uri='design:parts/website_toolbar_edit.tpl'}
    <div class="clearfix">
        <h4 class="float-left">{if $edit_version|eq(1)}{"Create"|i18n( 'design/ocbootstrap/content/edit' )}{else}{"Edit"|i18n( 'design/ocbootstrap/content/edit' )}{/if} <span class="text-lowercase">{$class.name|wash}</span></h4>
        <div class="chip chip-lg float-right mt-2">
            {def $language_index = 0
                 $from_language_index = 0
                 $translation_list = $content_version.translation_list}

            {foreach $translation_list as $index => $translation}
               {if eq( $edit_language, $translation.language_code )}
                  {set $language_index = $index}
               {/if}
            {/foreach}

            {if $is_translating_content}
                {def $from_language_object = $object.languages[$from_language]}
                {'Translating content from %from_lang to %to_lang'|i18n( 'design/ezwebin/content/edit',, hash(
                    '%from_lang', concat( $from_language_object.name, '&nbsp;<img src="', $from_language_object.locale|flag_icon, '" style="vertical-align: middle;" alt="', $from_language_object.locale, '" />' ),
                    '%to_lang', concat( $translation_list[$language_index].locale.intl_language_name, '&nbsp;<img src="', $translation_list[$language_index].language_code|flag_icon, '" style="vertical-align: middle;" alt="', $translation_list[$language_index].language_code, '" />' ) ) )}
            {else}
                {$translation_list[$language_index].locale.language_name|wash()}&nbsp;<img src="{$translation_list[$language_index].language_code|flag_icon}" style="vertical-align: middle;" alt="{$translation_list[$language_index].language_code}" />
            {/if}
        </div>
    </div>

    <h1>{$object.name|wash}</h1>

    {include uri="design:content/edit_validation.tpl"}

    <div class="mb-3">
          {if ezini_hasvariable( 'EditSettings', 'AdditionalTemplates', 'content.ini' )}
            {foreach ezini( 'EditSettings', 'AdditionalTemplates', 'content.ini' ) as $additional_tpl}
              {include uri=concat( 'design:', $additional_tpl )}
            {/foreach}
          {/if}

          {include uri="design:content/edit_attribute.tpl"}

          <div class="clearfix">
              <input class="btn btn-lg btn-success float-right" type="submit" name="PublishButton" value="{'Store'|i18n('ocbootstrap')}" />
              <input class="btn btn-lg btn-warning float-right mr-3" type="submit" name="StoreButton" value="{'Store draft'|i18n('ocbootstrap')}" />
              <input class="btn btn-lg btn-dark" type="submit" name="DiscardButton" value="{'Discard'|i18n('ocbootstrap')}" />
              <input type="hidden" name="DiscardConfirm" value="0" />
              <input type="hidden" name="RedirectIfDiscarded" value="{if ezhttp_hasvariable( 'RedirectIfDiscarded', 'session' )}{ezhttp( 'RedirectIfDiscarded', 'session' )}{else}{$_redirect}{/if}" />
              <input type="hidden" name="RedirectURIAfterPublish" value="{$_redirect}" />
          </div>
    </div>
</form>

{undef $_redirect}

{run-once}
{literal}
<script>
var select_to_string = function(element) {
  var newValue = $(element).val();
  var $input = $(element).next();
  if (newValue.length > 0) {        
    var current = $input.val().length > 0 ? $input.val().split(',') : [];  
    current.push(newValue);
    function unique(array){
      return array.filter(function(el, index, arr) {
          return index === arr.indexOf(el);
      });
    }
    $input.val(unique(current).join(','));
  }else{
    $input.val('');
  }
}
$(document).ready(function () {
    $(document).on('keydown', 'input, select', function(e){
        if(e.keyCode === 13)
            e.preventDefault();
    });
});
</script>
{/literal}
{/run-once}
