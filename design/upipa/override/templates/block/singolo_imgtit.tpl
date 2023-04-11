{def $valid_node = $block.valid_nodes[0]}
<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if $block.name|ne('')}<h3 class="openpa-widget-title">{node_view_gui content_node=$valid_node view=text_linked text=$block.name}</h3>{/if}
    <div class="openpa-widget-content well">
        <h4 class="openpa-widget-title-lev2">{node_view_gui content_node=$valid_node view=text_linked}</h4>
        {node_view_gui content_node=$valid_node view=accordion_content image_class=large image_css_class='' fluid=true()}
        <a class="readmore" href="{object_handler($valid_node).content_link.full_link}" title="{$valid_node.name|wash()}">{'Read more'|i18n('openpa/widget')}</a>
    </div>
</div>

