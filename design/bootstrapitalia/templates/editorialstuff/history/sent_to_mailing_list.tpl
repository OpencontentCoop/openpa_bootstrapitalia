{if is_set($item.parameters.language)}
<img src="{$item.parameters.language|flag_icon}" alt="{$item.parameters.language|wash()}" />
{/if}
{'Sent to mailing list'} #{$item.parameters.mailing_list|wash()} <br /> <small>{$item.parameters.addresses|implode(', ')}</small>