{if $attribute.data_text}
     <a class="btn btn-success" target="_blank" rel="noopener noreferrer" href="{$attribute.content|wash( xhtml )}">{$attribute.data_text|wash( xhtml )} <i class="fa fa-external-link"></i></a>
{else}
     <a class="btn btn-success" target="_blank" rel="noopener noreferrer" href="{$attribute.content|wash( xhtml )}">{$attribute.content|wash( xhtml )} <i class="fa fa-external-link"></i></a>
{/if}
