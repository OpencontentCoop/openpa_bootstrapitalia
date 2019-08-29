{def $valid_node = $block.valid_nodes[0]}

{include uri='design:parts/block_name.tpl'}
<div class="container">
    {node_view_gui content_node=$valid_node view=card image_class=large show_icon=true() view_variation='big'}
</div>

{undef $valid_node}