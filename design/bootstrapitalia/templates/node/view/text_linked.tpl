{def $openpa = object_handler($node)}
{set_defaults(hash(
    'a_class', '',
    'text_wrap_start', '',
    'text_wrap_end', '',
    'show_icon', false(),
    'shorten', false(),
    'add_abstract', false()
))}
{if $show_icon}
    {set $a_class = concat('d-flex ', $a_class)}
{/if}
<a href="{$openpa.content_link.full_link}"
   title="Link a {if is_set( $text )}{$text|wash()}{else}{$node.name|wash()}{/if}"
   {if $a_class|ne('')}class="{$a_class}"{/if}
   {if or($node.class_identifier|eq('shared_link'), $openpa.content_link.target)}target="_blank" rel="noopener noreferrer"{/if}>
    {if and($show_icon, $openpa.content_icon.icon)}
        {display_icon($openpa.content_icon.icon.icon_text|wash(), 'svg', 'icon icon-sm mr-2 me-2')}
    {/if}
    {$text_wrap_start}
    {if and( is_set( $text ), $text|ne('') )}
        {if $shorten}
            {$text|shorten($shorten)|wash()}
        {else}
            {$text|wash()}
        {/if}
    {else}
        {if $shorten}
            {$node.name|shorten($shorten)|wash()}
        {else}
            {$node.name|wash()}
        {/if}
    {/if}
    {if $add_abstract}<em>{$node|abstract()|oc_shorten(400)}</em>{/if}
    {$text_wrap_end}
</a>
{unset_defaults(array(
    'a_class',
    'text_wrap_start',
    'text_wrap_end'
))}
{undef $openpa}
