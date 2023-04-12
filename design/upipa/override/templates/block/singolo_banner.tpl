{def $valid_node = $block.valid_nodes[0]
     $link = '#'}

{if object_handler($valid_node).content_link.full_link|ne('')}
    {set $link = object_handler($valid_node).content_link.full_link}
{/if}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {node_view_gui content_node=$valid_node view=banner}
</div>