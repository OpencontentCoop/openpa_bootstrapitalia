{* template da rifattorizzare form incluso in un form
{if $current_node.object.can_translate}
  {def $translation_list = fetch( 'content', 'translation_list' )
       $current = array()
       $translate_in = array()}
  {foreach $current_node.object.all_languages as $locale_code => $language}
    {set $current = $current|append($locale_code)}
  {/foreach}
  {foreach $translation_list as $locale}
      {if $current|contains($locale.locale_code)|not()}
        {set $translate_in = $translate_in|append( $locale )}
      {/if}
  {/foreach}
  {if $translate_in|count()|gt(0)}
  <form method="post" action={concat('ocbtools/translate/',$content_object.id)|ezurl}>
  <div class="ezwt-actiongroup">
    <input type="hidden" name="FromContentObjectLanguageCode" value="{$content_object.current_language}" />
    <select name="ToContentObjectLanguageCode">
    {foreach $translate_in as $language}
      <option value="{$language.locale_code}">Traduci in {$language.language_name|wash}</option>
    {/foreach}
    </select>
    <input class="ezwt-input-image" type="image" src={"websitetoolbar/ezwt-icon-translation.png"|ezimage} name="TranslateButton" title="{'Translate'|i18n( 'design/standard/content/edit' )}" />
  </div>
  </form>
  {/if}
{/if}
*}

