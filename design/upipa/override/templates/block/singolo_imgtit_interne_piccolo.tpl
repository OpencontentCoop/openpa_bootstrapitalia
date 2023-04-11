{def $valid_node = $block.valid_nodes[0]}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    <h3 class="openpa-widget-title">{node_view_gui content_node=$valid_node view=text_linked text=cond(ne($block.name,''),$block.name,false())}</h3>
    <div class="openpa-widget-content Prose">
        {if $valid_node|has_attribute('image')}
            {attribute_view_gui alt=$valid_node.name|wash() attribute=$valid_node|attribute('image') image_class='medium'}
        {/if}
        {if $block.name|ne('')}
            <h4><a href="{$valid_node.url_alias|ezurl(no)}" title="Link a {$valid_node.name|wash()}">{$valid_node.name|wash()}</a></h4>
        {/if}
    </div>
</div>
