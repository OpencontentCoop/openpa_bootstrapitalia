{set_defaults(hash('css_class', 'btn btn-success fw-bold font-sans-serif'))}
{if $attribute.data_text}
     <a class="{$css_class}" target="_blank" rel="noopener noreferrer" href="{$attribute.content|wash( xhtml )}">{$attribute.data_text|wash( xhtml )} <i class="fa fa-external-link"></i></a>
{else}
     <a class="{$css_class}" target="_blank" rel="noopener noreferrer" href="{$attribute.content|wash( xhtml )}">{$attribute.content|wash( xhtml )} <i class="fa fa-external-link"></i></a>
{/if}
{unset_defaults(array('css_class'))}