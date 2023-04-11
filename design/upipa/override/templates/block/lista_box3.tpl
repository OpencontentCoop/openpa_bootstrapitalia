{def $openpa= object_handler($block)}
{set_defaults(hash('show_title', true()))}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        <h3 class="openpa-widget-title"><a href={$openpa.root_node.url_alias|ezurl()}>{$block.name|wash()}</a></h3>
    {/if}

    <div class="openpa-widget-content">
        {foreach $openpa.content as $item}
            {node_view_gui content_node=$item view=line}
        {/foreach}
    </div>
</div>