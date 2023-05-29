{set_defaults(hash(
     'css_class', 'btn btn-success fw-bold font-sans-serif'
))}
{def $is_channel = cond($attribute.object.class_identifier|eq('channel'), true(), false())}
{if $attribute.data_text}
     <a class="{$css_class}" {if $is_channel|not()}target="_blank" rel="noopener noreferrer"{/if} href="{$attribute.content|wash( xhtml )}">{$attribute.data_text|wash( xhtml )}{if $is_channel|not()} <i class="fa fa-external-link"></i>{/if}</a>
{else}
     <a class="{$css_class}" {if $is_channel|not()}target="_blank" rel="noopener noreferrer"{/if} href="{$attribute.content|wash( xhtml )}">{$attribute.content|wash( xhtml )}{if $is_channel|not()} <i class="fa fa-external-link"></i>{/if}</a>
{/if}
{unset_defaults(array('css_class'))}