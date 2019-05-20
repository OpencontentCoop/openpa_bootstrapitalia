{def $openpa = object_handler($node)}
{set_defaults(hash(
    'a_class', '',
    'text_wrap_start', '',
    'text_wrap_end', ''
))}
<a href="{$openpa.content_link.full_link}"
   title="Link a {if is_set( $text )}{$text|wash()}{else}{$node.name|wash()}{/if}"
   {if $a_class|ne('')}class="{$a_class}"{/if}
   {if $openpa.content_link.target}target="_blank" rel="noopener noreferrer"{/if}>
    {$text_wrap_start}
    {if and( is_set( $text ), $text|ne('') )}
        {if is_set( $shorten )}
            {$text|shorten($shorten)|wash()}
        {else}
            {$text|wash()}
        {/if}
    {else}
        {if is_set( $shorten )}
            {$node.name|shorten($shorten)|wash()}
        {else}
            {$node.name|wash()}
        {/if}
    {/if}
    {$text_wrap_end}
</a>
{unset_defaults(array(
    'a_class',
    'text_wrap_start',
    'text_wrap_end'
))}
{undef $openpa}