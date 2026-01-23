{def $openpa = object_handler($node)}
{set_defaults(hash(
    'a_class', '',
    'text_wrap_start', '',
    'text_wrap_end', '',
    'show_icon', false(),
    'shorten', false()
))}
{if $show_icon}
    {set $a_class = concat('d-flex ', $a_class)}
{/if}
<span class="text-nowrap {$a_class}">
<a href="{$openpa.content_link.full_link}"
   {if $openpa.content_link.target}target="_blank" rel="noopener noreferrer"{/if}>
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
    {$text_wrap_end}
</a>
<a class="btn btn-xs btn-link" href="{concat("exportas/avpc/lotto/",$node.node_id)|ezurl(no)}" title="Esporta in formato ANAC XML"><i class="fa fa-download"></i> ANAC XML</a>
</span>
{unset_defaults(array(
    'a_class',
    'text_wrap_start',
    'text_wrap_end'
))}
{undef $openpa}
