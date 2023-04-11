{def $valid_node = $block.valid_nodes[0]}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    <h3 class="openpa-widget-title">{node_view_gui content_node=$valid_node view=text_linked text=cond(ne($block.name,''),$block.name,false())}</h3>
    {if $valid_node|has_attribute('image')}
        <div class="openpa-widget-content">
            {attribute_view_gui alt=$valid_node.name|wash() attribute=$valid_node|attribute('image') image_class=large}
        </div>
    {/if}
</div>
