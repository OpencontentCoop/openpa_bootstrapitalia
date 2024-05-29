{def $openpa = object_handler($node)}
{set_defaults(hash(
    'a_class', '',
    'span_class', false(),
    'text_wrap_start', '',
    'text_wrap_end', '',
    'icon_wrap_start', '',
    'icon_wrap_end', '',
    'show_icon', false(),
    'icon_class', 'icon icon-primary icon-sm me-1',
    'shorten', false(),
    'add_abstract', false()
))}
{if $show_icon}
    <div class="cmp-icon-link mb-2">
        <a class="list-item icon-left d-inline-block font-sans-serif"
           {if or($node.class_identifier|eq('shared_link'), $openpa.content_link.target)}target="_blank"
           rel="noopener noreferrer"{/if}
           href="{$openpa.content_link.full_link}"
           aria-label="{if and( is_set( $text ), $text|ne('') )}{$text|wash()}{else}{$node.name|wash()}{/if}"
           title="{if and( is_set( $text ), $text|ne('') )}{$text|wash()}{else}{$node.name|wash()}{/if}"
           data-focus-mouse="false">
          <span class="list-item-title-icon-wrapper">{*
            *}{if and($show_icon, $openpa.content_icon.icon)}{display_icon($openpa.content_icon.icon.icon_text|wash(), 'svg', $icon_class)}{else}{display_icon('it-clip', 'svg', $icon_class)}{/if}{*
            *}<span class="list-item">{*
                *}{if and( is_set( $text ), $text|ne('') )}{if $shorten}{$text|shorten($shorten)|wash()}{else}{$text|wash()}{/if}{else}{if $shorten}{$node.name|shorten($shorten)|wash()}{else}{$node.name|wash()}{/if}{/if}{*
            *}</span>{*
          *}</span>
        </a>
    </div>
{else}
    <a href="{$openpa.content_link.full_link}"
       data-element="{$openpa.data_element.value|wash()}"
       title="Link a {if is_set( $text )}{$text|wash()}{else}{$node.name|wash()}{/if}"
       {if $a_class|ne('')}class="{$a_class}"{/if}
            {if or($node.class_identifier|eq('shared_link'), $openpa.content_link.target)}target="_blank" rel="noopener noreferrer"{/if}>
        {if $span_class}<span class="{$span_class}">{/if}
            {if and($show_icon, $openpa.content_icon.icon)}
                {$icon_wrap_start}
                {display_icon($openpa.content_icon.icon.icon_text|wash(), 'svg', $icon_class)}
                {$icon_wrap_end}
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
            {if $span_class}</span>{/if}
    </a>
{/if}
{unset_defaults(array(
    'shorten',
    'show_icon',
    'icon_class',
    'a_class',
    'span_class',
    'text_wrap_start',
    'text_wrap_end',
    'icon_wrap_start',
    'icon_wrap_end'
))}
{undef $openpa}