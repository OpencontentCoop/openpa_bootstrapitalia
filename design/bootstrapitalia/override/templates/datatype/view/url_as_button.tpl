{if $attribute.data_text}
     <a class="btn btn-success" href="{$attribute.content|wash( xhtml )}">{$attribute.data_text|wash( xhtml )}</a>
{else}
     <a class="btn btn-success" href="{$attribute.content|wash( xhtml )}">{$attribute.content|wash( xhtml )}</a>
{/if}