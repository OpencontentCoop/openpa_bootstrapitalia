{def $valid_nodes = $block.valid_nodes
$valid_nodes_count = $valid_nodes|count()}

{set_defaults( hash('show_title', true()) )}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>
    {/if}


    {if $valid_nodes_count|eq(1)}

        {node_view_gui content_node=$valid_nodes[0] view=line}

    {elseif $valid_nodes_count|eq(2)}
        <div class="Grid Grid--withGutter">
            <div class="Grid-cell u-md-size1of2 u-lg-size1of2">
                <h4 class="openpa-widget-title-lev2">{node_view_gui content_node=$valid_nodes[0] view=text_linked}</h4>
                {node_view_gui content_node=$valid_nodes[0] view=accordion_content image_class=small}
                <a class="readmore" href="{object_handler($valid_nodes[0]).content_link.full_link}"
                   title="{$valid_nodes[0].name|wash()}">{'Read more'|i18n('bootstrapitalia')}</a>
            </div>
            <div class="Grid-cell u-md-size1of2 u-lg-size1of2">
                <h4 class="openpa-widget-title-lev2">{node_view_gui content_node=$valid_nodes[1] view=text_linked}</h4>
                {node_view_gui content_node=$valid_nodes[1] view=accordion_content image_class=small}
                <a class="readmore" href="{object_handler($valid_nodes[1]).content_link.full_link}"
                   title="{$valid_nodes[1].name|wash()}">{'Read more'|i18n('bootstrapitalia')}</a>
            </div>
        </div>
    {elseif $valid_nodes_count|ge(3)}
        {def $col-width=6 $modulo=2}
        {if and( $valid_nodes_count|eq(3), mod( 12, $valid_nodes_count )|eq(0) )}
            {set $col-width=4 $modulo=3}
        {/if}
        <div class="Grid">
        {foreach $valid_nodes as $__valid_node}
            <div class="Grid-cell u-md-size{$col-width}of12 u-lg-size{$col-width}of12">
                <h4 class="openpa-widget-title-lev2">{node_view_gui content_node=$__valid_node view=text_linked}</h4>
                {node_view_gui content_node=$__valid_node view=accordion_content image_class=small}
                <a class="readmore" href="{object_handler($__valid_node).content_link.full_link}"
                   title="{$__valid_node.name|wash()}">{'Read more'|i18n('bootstrapitalia')}</a>
            </div>
            {delimiter modulo=$modulo}</div><div class="Grid">{/delimiter}
        {/foreach}
        </div>
    {/if}
</div>
